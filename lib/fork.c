// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
		panic("pgfault: faulting access was not a write or to a copy-on-write page");
	}

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
	int ret = sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P);
	if (ret < 0) {
		panic("pgfault: sys_page_alloc failed: %e", ret);
	}
	memmove(PFTEMP, addr, PGSIZE);
	ret = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_W | PTE_P);
	if (ret < 0) {
		panic("pgfault: sys_page_map failed: %e", ret);
	}
	ret = sys_page_unmap(0, PFTEMP);
	if (ret < 0) {
		panic("pgfault: sys_page_unmap failed: %e", ret);
	}
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	void *addr = (void *)(pn * PGSIZE);
	int perm = uvpt[pn] & PTE_SYSCALL;
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
		perm &= ~PTE_W;
		perm |= PTE_COW;
		int ret = sys_page_map(0, addr, envid, addr, perm);
		if (ret < 0) {
			panic("duppage: sys_page_map failed: %e", ret);
		}
		ret = sys_page_map(0, addr, 0, addr, perm);
		if (ret < 0) {
			panic("duppage: sys_page_map failed: %e", ret);
		}
	} else {
		int ret = sys_page_map(0, addr, envid, addr, perm);
		if (ret < 0) {
			panic("duppage: sys_page_map failed: %e", ret);
		}
	}
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
	envid_t envid = sys_exofork();
	if (envid < 0) {
		panic("fork: sys_exofork failed: %e", envid);
	}
	if (envid == 0) {
		// child process
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// parent process

	for (uintptr_t addr = 0; addr < USTACKTOP; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)) {
			duppage(envid, PGNUM(addr));
		}
	}

	int ret = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
	if (ret < 0) {
		panic("fork: sys_page_alloc failed: %e", ret);
	}

	ret = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (ret < 0) {
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
	}

	ret = sys_env_set_status(envid, ENV_RUNNABLE);
	if (ret < 0) {
		panic("fork: sys_env_set_status failed: %e", ret);
	}
	return envid;
}

static int
sduppage(envid_t envid, unsigned pn)
{
	void *addr = (void *)(pn * PGSIZE);
	int perm = uvpt[pn] & PTE_SYSCALL;
	int ret = sys_page_map(0, addr, envid, addr, perm);
	if (ret < 0) {
		panic("sduppage: sys_page_map failed: %e", ret);
	}
	return 0;
}

// Challenge!
int
sfork(void)
{
	extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
	envid_t envid = sys_exofork();
	if (envid < 0) {
		panic("fork: sys_exofork failed: %e", envid);
	}
	if (envid == 0) {
		// child process
		return 0;
	}
	// parent process

	for (uintptr_t addr = 0; addr < (USTACKTOP - PGSIZE); addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			sduppage(envid, PGNUM(addr));
		}
	}
	duppage(envid, PGNUM(USTACKTOP - PGSIZE));

	int ret = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
	if (ret < 0) {
		panic("fork: sys_page_alloc failed: %e", ret);
	}

	ret = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (ret < 0) {
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
	}

	ret = sys_env_set_status(envid, ENV_RUNNABLE);
	if (ret < 0) {
		panic("fork: sys_env_set_status failed: %e", ret);
	}
	return envid;

}
// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display information about the stack trace", mon_backtrace },
	{ "showmappings", "Display the physical page mappingsthat apply to a particular range of virtual/linear addresses.", mon_showmappings },
	{ "setperm", "Explicitly set, clear, or change the permissions of any mapping.", mon_setperm },
	{ "dumpmem", "Dump the contents of a range of memory given either a virtual or physical address range.", mon_dumpmem },
	{ "continue", "Continue execution from the current location.", mon_continue },
	{ "stepi", "Single step one instruction at a time through the code.", mon_stepi },
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	cprintf("Stack backtrace:\n");
	uint32_t *ebp, eip;
	struct Eipdebuginfo info;

	ebp = (uint32_t *)read_ebp();
	while (ebp) {
		eip = *(ebp + 1);
		debuginfo_eip(eip, &info);
		cprintf("  ebp %08x  eip %08x  args", ebp, eip);
		for (int i = 0; i < 5; i++) {
			cprintf(" %08x", *(ebp + 2 + i));
			if (i == 4) {
				cprintf("\n");
			}
		}
		cprintf("		 %s:%d: %.*s+%d\n", info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t *)*ebp;
	}
	return 0;
}

int 
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	if (argc != 3) {
		cprintf("Usage: showmappings [start] [end]\n");
		return 0;
	}
	uintptr_t start_va = (uintptr_t)strtol(argv[1], NULL, 0);
	uintptr_t end_va = (uintptr_t)strtol(argv[2], NULL, 0);
	if ((start_va % PGSIZE) || (end_va % PGSIZE)) {
		cprintf("showmappings error: start and end must be page aligned\n");
		return 0;
	}
	if (start_va > end_va) {
		cprintf("showmappings error: start must be less than end\n");
	}
	while (start_va <= end_va) {
		pte_t *pte = pgdir_walk(kern_pgdir, (void *)start_va, 0);
		if ((!pte) || (!(*pte & PTE_P))) {
			cprintf("VA:0x%08x: unmapped\n", start_va);
		} else {
			cprintf("VA:0x%08x -> PA:0x%08x ", start_va, PTE_ADDR(*pte));
			if (*pte & PTE_U) {
				cputchar('U');
			} else {
				cputchar('-');
			}
			if (*pte & PTE_W) {
				cputchar('W');
			} else {
				cputchar('-');
			}
			cputchar('\n');
		}
		start_va += PGSIZE;
	}
	return 0;
}

int 
mon_setperm(int argc, char **argv, struct Trapframe *tf) {
	if (argc != 4) {
		cprintf("Usage: setperm [VADDR] [U|W] [0|1]\n");
		return 0;
	}
	if ((argv[2][0] != 'U' && argv[2][0] != 'W') || (argv[3][0] != '0' && argv[3][0] != '1')) {
		cprintf("Usage: setperm [VADDR] [U|W] [0|1]\n");
		return 0;
	}
	uintptr_t va = (uintptr_t)strtol(argv[1], NULL, 0);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)va, 0);
	if (!pte) {
		cprintf("setperm error: VA:0x%08x is not mapped\n", va);
		return 0;
	}
	pte_t perm_mod = 0;
	if (argv[2][0] == 'U') {
		perm_mod = PTE_U;
	} else {
		perm_mod = PTE_W;
	}
	if (argv[3][0] == '1') {
		*pte |= perm_mod;
	} else {
		*pte &= ~perm_mod;
	}
	return 0;
}

int 
mon_dumpmem(int argc, char **argv, struct Trapframe *tf) {
	if (argc != 4) {
		cprintf("Usage: dumpmem [V|P] [Start] [length]\n");
		return 0;
	}
	if ((argv[1][0] != 'V' && argv[1][0] != 'P')) {
		cprintf("Usage: dumpmem [V|P] [Start] [length]\n");
		return 0;
	}
	uintptr_t start_va = (uintptr_t)strtol(argv[2], NULL, 0);
	uint32_t length = (uint32_t)strtol(argv[3], NULL, 0);
	if (argv[1][0] == 'P') {
		if (start_va + length > PGSIZE * npages) {
			cprintf("dumpmem error: address overflow\n");
			return 0;
		}
		start_va = (uintptr_t)KADDR((physaddr_t)start_va);
	}
	for (int i = 0; i < length; i++) {
		cprintf("VADDR 0x%08x: 0x", start_va + i);
		for (int j = 3; j >= 0; j--) {
			void* nowptr = (void *)(start_va + i * 4);
			pte_t *pte = pgdir_walk(kern_pgdir, nowptr, 0);
			if ((!pte) || (!(*pte & PTE_P))) {
				cprintf("??");
			} else {
				cprintf("%02x", *((uint8_t *)nowptr + j));
			}
		}
		cprintf("\n");
	}
	return 0;
}

int 
mon_continue(int argc, char **argv, struct Trapframe *tf) {
    if (!(tf && (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT) && 
          ((tf->tf_cs & 3) == 3)))
        return 0;
    tf->tf_eflags &= ~FL_TF;
    return -1;
}

int 
mon_stepi(int argc, char **argv, struct Trapframe *tf) {
    if (!(tf && (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT) && 
          ((tf->tf_cs & 3) == 3)))
        return 0;
    tf->tf_eflags |= FL_TF;
    return -1;
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}

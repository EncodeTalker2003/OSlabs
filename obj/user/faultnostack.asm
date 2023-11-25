
obj/user/faultnostack:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 ea 0f 80 00       	push   $0x800fea
  80011e:	6a 23                	push   $0x23
  800120:	68 07 10 80 00       	push   $0x801007
  800125:	e8 11 02 00 00       	call   80033b <_panic>

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7f 08                	jg     800194 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 ea 0f 80 00       	push   $0x800fea
  80019f:	6a 23                	push   $0x23
  8001a1:	68 07 10 80 00       	push   $0x801007
  8001a6:	e8 90 01 00 00       	call   80033b <_panic>

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7f 08                	jg     8001d6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 ea 0f 80 00       	push   $0x800fea
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 07 10 80 00       	push   $0x801007
  8001e8:	e8 4e 01 00 00       	call   80033b <_panic>

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 ea 0f 80 00       	push   $0x800fea
  800223:	6a 23                	push   $0x23
  800225:	68 07 10 80 00       	push   $0x801007
  80022a:	e8 0c 01 00 00       	call   80033b <_panic>

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	b8 08 00 00 00       	mov    $0x8,%eax
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7f 08                	jg     80025a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 ea 0f 80 00       	push   $0x800fea
  800265:	6a 23                	push   $0x23
  800267:	68 07 10 80 00       	push   $0x801007
  80026c:	e8 ca 00 00 00       	call   80033b <_panic>

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 09 00 00 00       	mov    $0x9,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 ea 0f 80 00       	push   $0x800fea
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 07 10 80 00       	push   $0x801007
  8002ae:	e8 88 00 00 00       	call   80033b <_panic>

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	be 00 00 00 00       	mov    $0x0,%esi
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7f 08                	jg     800300 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	6a 0c                	push   $0xc
  800306:	68 ea 0f 80 00       	push   $0x800fea
  80030b:	6a 23                	push   $0x23
  80030d:	68 07 10 80 00       	push   $0x801007
  800312:	e8 24 00 00 00       	call   80033b <_panic>

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  800322:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  800327:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %edx
  80032b:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80032f:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  800331:	83 c4 08             	add    $0x8,%esp
	popal
  800334:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800335:	83 c4 04             	add    $0x4,%esp
	popfl
  800338:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800339:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80033a:	c3                   	ret    

0080033b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800343:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800349:	e8 dc fd ff ff       	call   80012a <sys_getenvid>
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	ff 75 0c             	push   0xc(%ebp)
  800354:	ff 75 08             	push   0x8(%ebp)
  800357:	56                   	push   %esi
  800358:	50                   	push   %eax
  800359:	68 18 10 80 00       	push   $0x801018
  80035e:	e8 b3 00 00 00       	call   800416 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800363:	83 c4 18             	add    $0x18,%esp
  800366:	53                   	push   %ebx
  800367:	ff 75 10             	push   0x10(%ebp)
  80036a:	e8 56 00 00 00       	call   8003c5 <vcprintf>
	cprintf("\n");
  80036f:	c7 04 24 3b 10 80 00 	movl   $0x80103b,(%esp)
  800376:	e8 9b 00 00 00       	call   800416 <cprintf>
  80037b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037e:	cc                   	int3   
  80037f:	eb fd                	jmp    80037e <_panic+0x43>

00800381 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	53                   	push   %ebx
  800385:	83 ec 04             	sub    $0x4,%esp
  800388:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038b:	8b 13                	mov    (%ebx),%edx
  80038d:	8d 42 01             	lea    0x1(%edx),%eax
  800390:	89 03                	mov    %eax,(%ebx)
  800392:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800395:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800399:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039e:	74 09                	je     8003a9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a7:	c9                   	leave  
  8003a8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	68 ff 00 00 00       	push   $0xff
  8003b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b4:	50                   	push   %eax
  8003b5:	e8 f2 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c0:	83 c4 10             	add    $0x10,%esp
  8003c3:	eb db                	jmp    8003a0 <putch+0x1f>

008003c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d5:	00 00 00 
	b.cnt = 0;
  8003d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e2:	ff 75 0c             	push   0xc(%ebp)
  8003e5:	ff 75 08             	push   0x8(%ebp)
  8003e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ee:	50                   	push   %eax
  8003ef:	68 81 03 80 00       	push   $0x800381
  8003f4:	e8 14 01 00 00       	call   80050d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f9:	83 c4 08             	add    $0x8,%esp
  8003fc:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800402:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800408:	50                   	push   %eax
  800409:	e8 9e fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80040e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800414:	c9                   	leave  
  800415:	c3                   	ret    

00800416 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041f:	50                   	push   %eax
  800420:	ff 75 08             	push   0x8(%ebp)
  800423:	e8 9d ff ff ff       	call   8003c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    

0080042a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	57                   	push   %edi
  80042e:	56                   	push   %esi
  80042f:	53                   	push   %ebx
  800430:	83 ec 1c             	sub    $0x1c,%esp
  800433:	89 c7                	mov    %eax,%edi
  800435:	89 d6                	mov    %edx,%esi
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043d:	89 d1                	mov    %edx,%ecx
  80043f:	89 c2                	mov    %eax,%edx
  800441:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800444:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800447:	8b 45 10             	mov    0x10(%ebp),%eax
  80044a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800450:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800457:	39 c2                	cmp    %eax,%edx
  800459:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80045c:	72 3e                	jb     80049c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045e:	83 ec 0c             	sub    $0xc,%esp
  800461:	ff 75 18             	push   0x18(%ebp)
  800464:	83 eb 01             	sub    $0x1,%ebx
  800467:	53                   	push   %ebx
  800468:	50                   	push   %eax
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	ff 75 e4             	push   -0x1c(%ebp)
  80046f:	ff 75 e0             	push   -0x20(%ebp)
  800472:	ff 75 dc             	push   -0x24(%ebp)
  800475:	ff 75 d8             	push   -0x28(%ebp)
  800478:	e8 23 09 00 00       	call   800da0 <__udivdi3>
  80047d:	83 c4 18             	add    $0x18,%esp
  800480:	52                   	push   %edx
  800481:	50                   	push   %eax
  800482:	89 f2                	mov    %esi,%edx
  800484:	89 f8                	mov    %edi,%eax
  800486:	e8 9f ff ff ff       	call   80042a <printnum>
  80048b:	83 c4 20             	add    $0x20,%esp
  80048e:	eb 13                	jmp    8004a3 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	ff 75 18             	push   0x18(%ebp)
  800497:	ff d7                	call   *%edi
  800499:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80049c:	83 eb 01             	sub    $0x1,%ebx
  80049f:	85 db                	test   %ebx,%ebx
  8004a1:	7f ed                	jg     800490 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	56                   	push   %esi
  8004a7:	83 ec 04             	sub    $0x4,%esp
  8004aa:	ff 75 e4             	push   -0x1c(%ebp)
  8004ad:	ff 75 e0             	push   -0x20(%ebp)
  8004b0:	ff 75 dc             	push   -0x24(%ebp)
  8004b3:	ff 75 d8             	push   -0x28(%ebp)
  8004b6:	e8 05 0a 00 00       	call   800ec0 <__umoddi3>
  8004bb:	83 c4 14             	add    $0x14,%esp
  8004be:	0f be 80 3d 10 80 00 	movsbl 0x80103d(%eax),%eax
  8004c5:	50                   	push   %eax
  8004c6:	ff d7                	call   *%edi
}
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ce:	5b                   	pop    %ebx
  8004cf:	5e                   	pop    %esi
  8004d0:	5f                   	pop    %edi
  8004d1:	5d                   	pop    %ebp
  8004d2:	c3                   	ret    

008004d3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e2:	73 0a                	jae    8004ee <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ec:	88 02                	mov    %al,(%edx)
}
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <printfmt>:
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f9:	50                   	push   %eax
  8004fa:	ff 75 10             	push   0x10(%ebp)
  8004fd:	ff 75 0c             	push   0xc(%ebp)
  800500:	ff 75 08             	push   0x8(%ebp)
  800503:	e8 05 00 00 00       	call   80050d <vprintfmt>
}
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <vprintfmt>:
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	53                   	push   %ebx
  800513:	83 ec 3c             	sub    $0x3c,%esp
  800516:	8b 75 08             	mov    0x8(%ebp),%esi
  800519:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051f:	eb 0a                	jmp    80052b <vprintfmt+0x1e>
			putch(ch, putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	53                   	push   %ebx
  800525:	50                   	push   %eax
  800526:	ff d6                	call   *%esi
  800528:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052b:	83 c7 01             	add    $0x1,%edi
  80052e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800532:	83 f8 25             	cmp    $0x25,%eax
  800535:	74 0c                	je     800543 <vprintfmt+0x36>
			if (ch == '\0')
  800537:	85 c0                	test   %eax,%eax
  800539:	75 e6                	jne    800521 <vprintfmt+0x14>
}
  80053b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80053e:	5b                   	pop    %ebx
  80053f:	5e                   	pop    %esi
  800540:	5f                   	pop    %edi
  800541:	5d                   	pop    %ebp
  800542:	c3                   	ret    
		padc = ' ';
  800543:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800547:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80054e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800555:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8d 47 01             	lea    0x1(%edi),%eax
  800564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800567:	0f b6 17             	movzbl (%edi),%edx
  80056a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056d:	3c 55                	cmp    $0x55,%al
  80056f:	0f 87 bb 03 00 00    	ja     800930 <vprintfmt+0x423>
  800575:	0f b6 c0             	movzbl %al,%eax
  800578:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800582:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800586:	eb d9                	jmp    800561 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80058f:	eb d0                	jmp    800561 <vprintfmt+0x54>
  800591:	0f b6 d2             	movzbl %dl,%edx
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80059f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ac:	83 f9 09             	cmp    $0x9,%ecx
  8005af:	77 55                	ja     800606 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8005b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b4:	eb e9                	jmp    80059f <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 40 04             	lea    0x4(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ce:	79 91                	jns    800561 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005dd:	eb 82                	jmp    800561 <vprintfmt+0x54>
  8005df:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e9:	0f 49 c2             	cmovns %edx,%eax
  8005ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f2:	e9 6a ff ff ff       	jmp    800561 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005fa:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800601:	e9 5b ff ff ff       	jmp    800561 <vprintfmt+0x54>
  800606:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	eb bc                	jmp    8005ca <vprintfmt+0xbd>
			lflag++;
  80060e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800614:	e9 48 ff ff ff       	jmp    800561 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 78 04             	lea    0x4(%eax),%edi
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	ff 30                	push   (%eax)
  800625:	ff d6                	call   *%esi
			break;
  800627:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80062a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80062d:	e9 9d 02 00 00       	jmp    8008cf <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 78 04             	lea    0x4(%eax),%edi
  800638:	8b 10                	mov    (%eax),%edx
  80063a:	89 d0                	mov    %edx,%eax
  80063c:	f7 d8                	neg    %eax
  80063e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800641:	83 f8 08             	cmp    $0x8,%eax
  800644:	7f 23                	jg     800669 <vprintfmt+0x15c>
  800646:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  80064d:	85 d2                	test   %edx,%edx
  80064f:	74 18                	je     800669 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800651:	52                   	push   %edx
  800652:	68 5e 10 80 00       	push   $0x80105e
  800657:	53                   	push   %ebx
  800658:	56                   	push   %esi
  800659:	e8 92 fe ff ff       	call   8004f0 <printfmt>
  80065e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800661:	89 7d 14             	mov    %edi,0x14(%ebp)
  800664:	e9 66 02 00 00       	jmp    8008cf <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800669:	50                   	push   %eax
  80066a:	68 55 10 80 00       	push   $0x801055
  80066f:	53                   	push   %ebx
  800670:	56                   	push   %esi
  800671:	e8 7a fe ff ff       	call   8004f0 <printfmt>
  800676:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800679:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80067c:	e9 4e 02 00 00       	jmp    8008cf <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	83 c0 04             	add    $0x4,%eax
  800687:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80068f:	85 d2                	test   %edx,%edx
  800691:	b8 4e 10 80 00       	mov    $0x80104e,%eax
  800696:	0f 45 c2             	cmovne %edx,%eax
  800699:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80069c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a0:	7e 06                	jle    8006a8 <vprintfmt+0x19b>
  8006a2:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a6:	75 0d                	jne    8006b5 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ab:	89 c7                	mov    %eax,%edi
  8006ad:	03 45 e0             	add    -0x20(%ebp),%eax
  8006b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b3:	eb 55                	jmp    80070a <vprintfmt+0x1fd>
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	ff 75 d8             	push   -0x28(%ebp)
  8006bb:	ff 75 cc             	push   -0x34(%ebp)
  8006be:	e8 0a 03 00 00       	call   8009cd <strnlen>
  8006c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c6:	29 c1                	sub    %eax,%ecx
  8006c8:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006d0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	eb 0f                	jmp    8006e8 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	ff 75 e0             	push   -0x20(%ebp)
  8006e0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	85 ff                	test   %edi,%edi
  8006ea:	7f ed                	jg     8006d9 <vprintfmt+0x1cc>
  8006ec:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f6:	0f 49 c2             	cmovns %edx,%eax
  8006f9:	29 c2                	sub    %eax,%edx
  8006fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006fe:	eb a8                	jmp    8006a8 <vprintfmt+0x19b>
					putch(ch, putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	52                   	push   %edx
  800705:	ff d6                	call   *%esi
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80070d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070f:	83 c7 01             	add    $0x1,%edi
  800712:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800716:	0f be d0             	movsbl %al,%edx
  800719:	85 d2                	test   %edx,%edx
  80071b:	74 4b                	je     800768 <vprintfmt+0x25b>
  80071d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800721:	78 06                	js     800729 <vprintfmt+0x21c>
  800723:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800727:	78 1e                	js     800747 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800729:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80072d:	74 d1                	je     800700 <vprintfmt+0x1f3>
  80072f:	0f be c0             	movsbl %al,%eax
  800732:	83 e8 20             	sub    $0x20,%eax
  800735:	83 f8 5e             	cmp    $0x5e,%eax
  800738:	76 c6                	jbe    800700 <vprintfmt+0x1f3>
					putch('?', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	53                   	push   %ebx
  80073e:	6a 3f                	push   $0x3f
  800740:	ff d6                	call   *%esi
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb c3                	jmp    80070a <vprintfmt+0x1fd>
  800747:	89 cf                	mov    %ecx,%edi
  800749:	eb 0e                	jmp    800759 <vprintfmt+0x24c>
				putch(' ', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	6a 20                	push   $0x20
  800751:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800753:	83 ef 01             	sub    $0x1,%edi
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 ff                	test   %edi,%edi
  80075b:	7f ee                	jg     80074b <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80075d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800760:	89 45 14             	mov    %eax,0x14(%ebp)
  800763:	e9 67 01 00 00       	jmp    8008cf <vprintfmt+0x3c2>
  800768:	89 cf                	mov    %ecx,%edi
  80076a:	eb ed                	jmp    800759 <vprintfmt+0x24c>
	if (lflag >= 2)
  80076c:	83 f9 01             	cmp    $0x1,%ecx
  80076f:	7f 1b                	jg     80078c <vprintfmt+0x27f>
	else if (lflag)
  800771:	85 c9                	test   %ecx,%ecx
  800773:	74 63                	je     8007d8 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077d:	99                   	cltd   
  80077e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 40 04             	lea    0x4(%eax),%eax
  800787:	89 45 14             	mov    %eax,0x14(%ebp)
  80078a:	eb 17                	jmp    8007a3 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8b 50 04             	mov    0x4(%eax),%edx
  800792:	8b 00                	mov    (%eax),%eax
  800794:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800797:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 40 08             	lea    0x8(%eax),%eax
  8007a0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a9:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	0f 89 ff 00 00 00    	jns    8008b5 <vprintfmt+0x3a8>
				putch('-', putdat);
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	6a 2d                	push   $0x2d
  8007bc:	ff d6                	call   *%esi
				num = -(long long) num;
  8007be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c4:	f7 da                	neg    %edx
  8007c6:	83 d1 00             	adc    $0x0,%ecx
  8007c9:	f7 d9                	neg    %ecx
  8007cb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007ce:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007d3:	e9 dd 00 00 00       	jmp    8008b5 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	99                   	cltd   
  8007e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8d 40 04             	lea    0x4(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ed:	eb b4                	jmp    8007a3 <vprintfmt+0x296>
	if (lflag >= 2)
  8007ef:	83 f9 01             	cmp    $0x1,%ecx
  8007f2:	7f 1e                	jg     800812 <vprintfmt+0x305>
	else if (lflag)
  8007f4:	85 c9                	test   %ecx,%ecx
  8007f6:	74 32                	je     80082a <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8b 10                	mov    (%eax),%edx
  8007fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800802:	8d 40 04             	lea    0x4(%eax),%eax
  800805:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800808:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80080d:	e9 a3 00 00 00       	jmp    8008b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8b 10                	mov    (%eax),%edx
  800817:	8b 48 04             	mov    0x4(%eax),%ecx
  80081a:	8d 40 08             	lea    0x8(%eax),%eax
  80081d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800820:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800825:	e9 8b 00 00 00       	jmp    8008b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80082a:	8b 45 14             	mov    0x14(%ebp),%eax
  80082d:	8b 10                	mov    (%eax),%edx
  80082f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800834:	8d 40 04             	lea    0x4(%eax),%eax
  800837:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80083f:	eb 74                	jmp    8008b5 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800841:	83 f9 01             	cmp    $0x1,%ecx
  800844:	7f 1b                	jg     800861 <vprintfmt+0x354>
	else if (lflag)
  800846:	85 c9                	test   %ecx,%ecx
  800848:	74 2c                	je     800876 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80084a:	8b 45 14             	mov    0x14(%ebp),%eax
  80084d:	8b 10                	mov    (%eax),%edx
  80084f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800854:	8d 40 04             	lea    0x4(%eax),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80085a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80085f:	eb 54                	jmp    8008b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	8b 48 04             	mov    0x4(%eax),%ecx
  800869:	8d 40 08             	lea    0x8(%eax),%eax
  80086c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80086f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800874:	eb 3f                	jmp    8008b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8b 10                	mov    (%eax),%edx
  80087b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800880:	8d 40 04             	lea    0x4(%eax),%eax
  800883:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800886:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80088b:	eb 28                	jmp    8008b5 <vprintfmt+0x3a8>
			putch('0', putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	6a 30                	push   $0x30
  800893:	ff d6                	call   *%esi
			putch('x', putdat);
  800895:	83 c4 08             	add    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	6a 78                	push   $0x78
  80089b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 10                	mov    (%eax),%edx
  8008a2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008a7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008aa:	8d 40 04             	lea    0x4(%eax),%eax
  8008ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b0:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8008b5:	83 ec 0c             	sub    $0xc,%esp
  8008b8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008bc:	50                   	push   %eax
  8008bd:	ff 75 e0             	push   -0x20(%ebp)
  8008c0:	57                   	push   %edi
  8008c1:	51                   	push   %ecx
  8008c2:	52                   	push   %edx
  8008c3:	89 da                	mov    %ebx,%edx
  8008c5:	89 f0                	mov    %esi,%eax
  8008c7:	e8 5e fb ff ff       	call   80042a <printnum>
			break;
  8008cc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d2:	e9 54 fc ff ff       	jmp    80052b <vprintfmt+0x1e>
	if (lflag >= 2)
  8008d7:	83 f9 01             	cmp    $0x1,%ecx
  8008da:	7f 1b                	jg     8008f7 <vprintfmt+0x3ea>
	else if (lflag)
  8008dc:	85 c9                	test   %ecx,%ecx
  8008de:	74 2c                	je     80090c <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8b 10                	mov    (%eax),%edx
  8008e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ea:	8d 40 04             	lea    0x4(%eax),%eax
  8008ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f0:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008f5:	eb be                	jmp    8008b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	8b 10                	mov    (%eax),%edx
  8008fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ff:	8d 40 08             	lea    0x8(%eax),%eax
  800902:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800905:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80090a:	eb a9                	jmp    8008b5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8b 10                	mov    (%eax),%edx
  800911:	b9 00 00 00 00       	mov    $0x0,%ecx
  800916:	8d 40 04             	lea    0x4(%eax),%eax
  800919:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800921:	eb 92                	jmp    8008b5 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	53                   	push   %ebx
  800927:	6a 25                	push   $0x25
  800929:	ff d6                	call   *%esi
			break;
  80092b:	83 c4 10             	add    $0x10,%esp
  80092e:	eb 9f                	jmp    8008cf <vprintfmt+0x3c2>
			putch('%', putdat);
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	53                   	push   %ebx
  800934:	6a 25                	push   $0x25
  800936:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800938:	83 c4 10             	add    $0x10,%esp
  80093b:	89 f8                	mov    %edi,%eax
  80093d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800941:	74 05                	je     800948 <vprintfmt+0x43b>
  800943:	83 e8 01             	sub    $0x1,%eax
  800946:	eb f5                	jmp    80093d <vprintfmt+0x430>
  800948:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094b:	eb 82                	jmp    8008cf <vprintfmt+0x3c2>

0080094d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 18             	sub    $0x18,%esp
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800959:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800960:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800963:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096a:	85 c0                	test   %eax,%eax
  80096c:	74 26                	je     800994 <vsnprintf+0x47>
  80096e:	85 d2                	test   %edx,%edx
  800970:	7e 22                	jle    800994 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800972:	ff 75 14             	push   0x14(%ebp)
  800975:	ff 75 10             	push   0x10(%ebp)
  800978:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097b:	50                   	push   %eax
  80097c:	68 d3 04 80 00       	push   $0x8004d3
  800981:	e8 87 fb ff ff       	call   80050d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800986:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800989:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80098f:	83 c4 10             	add    $0x10,%esp
}
  800992:	c9                   	leave  
  800993:	c3                   	ret    
		return -E_INVAL;
  800994:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800999:	eb f7                	jmp    800992 <vsnprintf+0x45>

0080099b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a4:	50                   	push   %eax
  8009a5:	ff 75 10             	push   0x10(%ebp)
  8009a8:	ff 75 0c             	push   0xc(%ebp)
  8009ab:	ff 75 08             	push   0x8(%ebp)
  8009ae:	e8 9a ff ff ff       	call   80094d <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b3:	c9                   	leave  
  8009b4:	c3                   	ret    

008009b5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c0:	eb 03                	jmp    8009c5 <strlen+0x10>
		n++;
  8009c2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c9:	75 f7                	jne    8009c2 <strlen+0xd>
	return n;
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	eb 03                	jmp    8009e0 <strnlen+0x13>
		n++;
  8009dd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e0:	39 d0                	cmp    %edx,%eax
  8009e2:	74 08                	je     8009ec <strnlen+0x1f>
  8009e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009e8:	75 f3                	jne    8009dd <strnlen+0x10>
  8009ea:	89 c2                	mov    %eax,%edx
	return n;
}
  8009ec:	89 d0                	mov    %edx,%eax
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	53                   	push   %ebx
  8009f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ff:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a03:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	84 d2                	test   %dl,%dl
  800a0b:	75 f2                	jne    8009ff <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a0d:	89 c8                	mov    %ecx,%eax
  800a0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	83 ec 10             	sub    $0x10,%esp
  800a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a1e:	53                   	push   %ebx
  800a1f:	e8 91 ff ff ff       	call   8009b5 <strlen>
  800a24:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a27:	ff 75 0c             	push   0xc(%ebp)
  800a2a:	01 d8                	add    %ebx,%eax
  800a2c:	50                   	push   %eax
  800a2d:	e8 be ff ff ff       	call   8009f0 <strcpy>
	return dst;
}
  800a32:	89 d8                	mov    %ebx,%eax
  800a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a44:	89 f3                	mov    %esi,%ebx
  800a46:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a49:	89 f0                	mov    %esi,%eax
  800a4b:	eb 0f                	jmp    800a5c <strncpy+0x23>
		*dst++ = *src;
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	0f b6 0a             	movzbl (%edx),%ecx
  800a53:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a56:	80 f9 01             	cmp    $0x1,%cl
  800a59:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a5c:	39 d8                	cmp    %ebx,%eax
  800a5e:	75 ed                	jne    800a4d <strncpy+0x14>
	}
	return ret;
}
  800a60:	89 f0                	mov    %esi,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a71:	8b 55 10             	mov    0x10(%ebp),%edx
  800a74:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a76:	85 d2                	test   %edx,%edx
  800a78:	74 21                	je     800a9b <strlcpy+0x35>
  800a7a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a7e:	89 f2                	mov    %esi,%edx
  800a80:	eb 09                	jmp    800a8b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a82:	83 c1 01             	add    $0x1,%ecx
  800a85:	83 c2 01             	add    $0x1,%edx
  800a88:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a8b:	39 c2                	cmp    %eax,%edx
  800a8d:	74 09                	je     800a98 <strlcpy+0x32>
  800a8f:	0f b6 19             	movzbl (%ecx),%ebx
  800a92:	84 db                	test   %bl,%bl
  800a94:	75 ec                	jne    800a82 <strlcpy+0x1c>
  800a96:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a98:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a9b:	29 f0                	sub    %esi,%eax
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aaa:	eb 06                	jmp    800ab2 <strcmp+0x11>
		p++, q++;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ab2:	0f b6 01             	movzbl (%ecx),%eax
  800ab5:	84 c0                	test   %al,%al
  800ab7:	74 04                	je     800abd <strcmp+0x1c>
  800ab9:	3a 02                	cmp    (%edx),%al
  800abb:	74 ef                	je     800aac <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800abd:	0f b6 c0             	movzbl %al,%eax
  800ac0:	0f b6 12             	movzbl (%edx),%edx
  800ac3:	29 d0                	sub    %edx,%eax
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ad6:	eb 06                	jmp    800ade <strncmp+0x17>
		n--, p++, q++;
  800ad8:	83 c0 01             	add    $0x1,%eax
  800adb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ade:	39 d8                	cmp    %ebx,%eax
  800ae0:	74 18                	je     800afa <strncmp+0x33>
  800ae2:	0f b6 08             	movzbl (%eax),%ecx
  800ae5:	84 c9                	test   %cl,%cl
  800ae7:	74 04                	je     800aed <strncmp+0x26>
  800ae9:	3a 0a                	cmp    (%edx),%cl
  800aeb:	74 eb                	je     800ad8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aed:	0f b6 00             	movzbl (%eax),%eax
  800af0:	0f b6 12             	movzbl (%edx),%edx
  800af3:	29 d0                	sub    %edx,%eax
}
  800af5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af8:	c9                   	leave  
  800af9:	c3                   	ret    
		return 0;
  800afa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aff:	eb f4                	jmp    800af5 <strncmp+0x2e>

00800b01 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0b:	eb 03                	jmp    800b10 <strchr+0xf>
  800b0d:	83 c0 01             	add    $0x1,%eax
  800b10:	0f b6 10             	movzbl (%eax),%edx
  800b13:	84 d2                	test   %dl,%dl
  800b15:	74 06                	je     800b1d <strchr+0x1c>
		if (*s == c)
  800b17:	38 ca                	cmp    %cl,%dl
  800b19:	75 f2                	jne    800b0d <strchr+0xc>
  800b1b:	eb 05                	jmp    800b22 <strchr+0x21>
			return (char *) s;
	return 0;
  800b1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b31:	38 ca                	cmp    %cl,%dl
  800b33:	74 09                	je     800b3e <strfind+0x1a>
  800b35:	84 d2                	test   %dl,%dl
  800b37:	74 05                	je     800b3e <strfind+0x1a>
	for (; *s; s++)
  800b39:	83 c0 01             	add    $0x1,%eax
  800b3c:	eb f0                	jmp    800b2e <strfind+0xa>
			break;
	return (char *) s;
}
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
  800b46:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b49:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b4c:	85 c9                	test   %ecx,%ecx
  800b4e:	74 2f                	je     800b7f <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b50:	89 f8                	mov    %edi,%eax
  800b52:	09 c8                	or     %ecx,%eax
  800b54:	a8 03                	test   $0x3,%al
  800b56:	75 21                	jne    800b79 <memset+0x39>
		c &= 0xFF;
  800b58:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5c:	89 d0                	mov    %edx,%eax
  800b5e:	c1 e0 08             	shl    $0x8,%eax
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	c1 e3 18             	shl    $0x18,%ebx
  800b66:	89 d6                	mov    %edx,%esi
  800b68:	c1 e6 10             	shl    $0x10,%esi
  800b6b:	09 f3                	or     %esi,%ebx
  800b6d:	09 da                	or     %ebx,%edx
  800b6f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b71:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b74:	fc                   	cld    
  800b75:	f3 ab                	rep stos %eax,%es:(%edi)
  800b77:	eb 06                	jmp    800b7f <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b79:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7c:	fc                   	cld    
  800b7d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7f:	89 f8                	mov    %edi,%eax
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5f                   	pop    %edi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b91:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b94:	39 c6                	cmp    %eax,%esi
  800b96:	73 32                	jae    800bca <memmove+0x44>
  800b98:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b9b:	39 c2                	cmp    %eax,%edx
  800b9d:	76 2b                	jbe    800bca <memmove+0x44>
		s += n;
		d += n;
  800b9f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba2:	89 d6                	mov    %edx,%esi
  800ba4:	09 fe                	or     %edi,%esi
  800ba6:	09 ce                	or     %ecx,%esi
  800ba8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bae:	75 0e                	jne    800bbe <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bb0:	83 ef 04             	sub    $0x4,%edi
  800bb3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bb9:	fd                   	std    
  800bba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbc:	eb 09                	jmp    800bc7 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bbe:	83 ef 01             	sub    $0x1,%edi
  800bc1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bc4:	fd                   	std    
  800bc5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc7:	fc                   	cld    
  800bc8:	eb 1a                	jmp    800be4 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bca:	89 f2                	mov    %esi,%edx
  800bcc:	09 c2                	or     %eax,%edx
  800bce:	09 ca                	or     %ecx,%edx
  800bd0:	f6 c2 03             	test   $0x3,%dl
  800bd3:	75 0a                	jne    800bdf <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bd5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bd8:	89 c7                	mov    %eax,%edi
  800bda:	fc                   	cld    
  800bdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bdd:	eb 05                	jmp    800be4 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bdf:	89 c7                	mov    %eax,%edi
  800be1:	fc                   	cld    
  800be2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be4:	5e                   	pop    %esi
  800be5:	5f                   	pop    %edi
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bee:	ff 75 10             	push   0x10(%ebp)
  800bf1:	ff 75 0c             	push   0xc(%ebp)
  800bf4:	ff 75 08             	push   0x8(%ebp)
  800bf7:	e8 8a ff ff ff       	call   800b86 <memmove>
}
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c09:	89 c6                	mov    %eax,%esi
  800c0b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0e:	eb 06                	jmp    800c16 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c10:	83 c0 01             	add    $0x1,%eax
  800c13:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c16:	39 f0                	cmp    %esi,%eax
  800c18:	74 14                	je     800c2e <memcmp+0x30>
		if (*s1 != *s2)
  800c1a:	0f b6 08             	movzbl (%eax),%ecx
  800c1d:	0f b6 1a             	movzbl (%edx),%ebx
  800c20:	38 d9                	cmp    %bl,%cl
  800c22:	74 ec                	je     800c10 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c24:	0f b6 c1             	movzbl %cl,%eax
  800c27:	0f b6 db             	movzbl %bl,%ebx
  800c2a:	29 d8                	sub    %ebx,%eax
  800c2c:	eb 05                	jmp    800c33 <memcmp+0x35>
	}

	return 0;
  800c2e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c40:	89 c2                	mov    %eax,%edx
  800c42:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c45:	eb 03                	jmp    800c4a <memfind+0x13>
  800c47:	83 c0 01             	add    $0x1,%eax
  800c4a:	39 d0                	cmp    %edx,%eax
  800c4c:	73 04                	jae    800c52 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4e:	38 08                	cmp    %cl,(%eax)
  800c50:	75 f5                	jne    800c47 <memfind+0x10>
			break;
	return (void *) s;
}
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c60:	eb 03                	jmp    800c65 <strtol+0x11>
		s++;
  800c62:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c65:	0f b6 02             	movzbl (%edx),%eax
  800c68:	3c 20                	cmp    $0x20,%al
  800c6a:	74 f6                	je     800c62 <strtol+0xe>
  800c6c:	3c 09                	cmp    $0x9,%al
  800c6e:	74 f2                	je     800c62 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c70:	3c 2b                	cmp    $0x2b,%al
  800c72:	74 2a                	je     800c9e <strtol+0x4a>
	int neg = 0;
  800c74:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c79:	3c 2d                	cmp    $0x2d,%al
  800c7b:	74 2b                	je     800ca8 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c83:	75 0f                	jne    800c94 <strtol+0x40>
  800c85:	80 3a 30             	cmpb   $0x30,(%edx)
  800c88:	74 28                	je     800cb2 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8a:	85 db                	test   %ebx,%ebx
  800c8c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c91:	0f 44 d8             	cmove  %eax,%ebx
  800c94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c99:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c9c:	eb 46                	jmp    800ce4 <strtol+0x90>
		s++;
  800c9e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ca1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca6:	eb d5                	jmp    800c7d <strtol+0x29>
		s++, neg = 1;
  800ca8:	83 c2 01             	add    $0x1,%edx
  800cab:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb0:	eb cb                	jmp    800c7d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb2:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cb6:	74 0e                	je     800cc6 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800cb8:	85 db                	test   %ebx,%ebx
  800cba:	75 d8                	jne    800c94 <strtol+0x40>
		s++, base = 8;
  800cbc:	83 c2 01             	add    $0x1,%edx
  800cbf:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cc4:	eb ce                	jmp    800c94 <strtol+0x40>
		s += 2, base = 16;
  800cc6:	83 c2 02             	add    $0x2,%edx
  800cc9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cce:	eb c4                	jmp    800c94 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800cd0:	0f be c0             	movsbl %al,%eax
  800cd3:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd6:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cd9:	7d 3a                	jge    800d15 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cdb:	83 c2 01             	add    $0x1,%edx
  800cde:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ce2:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ce4:	0f b6 02             	movzbl (%edx),%eax
  800ce7:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cea:	89 f3                	mov    %esi,%ebx
  800cec:	80 fb 09             	cmp    $0x9,%bl
  800cef:	76 df                	jbe    800cd0 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cf1:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cf4:	89 f3                	mov    %esi,%ebx
  800cf6:	80 fb 19             	cmp    $0x19,%bl
  800cf9:	77 08                	ja     800d03 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cfb:	0f be c0             	movsbl %al,%eax
  800cfe:	83 e8 57             	sub    $0x57,%eax
  800d01:	eb d3                	jmp    800cd6 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800d03:	8d 70 bf             	lea    -0x41(%eax),%esi
  800d06:	89 f3                	mov    %esi,%ebx
  800d08:	80 fb 19             	cmp    $0x19,%bl
  800d0b:	77 08                	ja     800d15 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800d0d:	0f be c0             	movsbl %al,%eax
  800d10:	83 e8 37             	sub    $0x37,%eax
  800d13:	eb c1                	jmp    800cd6 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d19:	74 05                	je     800d20 <strtol+0xcc>
		*endptr = (char *) s;
  800d1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d20:	89 c8                	mov    %ecx,%eax
  800d22:	f7 d8                	neg    %eax
  800d24:	85 ff                	test   %edi,%edi
  800d26:	0f 45 c8             	cmovne %eax,%ecx
}
  800d29:	89 c8                	mov    %ecx,%eax
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d36:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d3d:	74 0a                	je     800d49 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed: %e", ret);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d47:	c9                   	leave  
  800d48:	c3                   	ret    
		int ret = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800d49:	83 ec 04             	sub    $0x4,%esp
  800d4c:	6a 07                	push   $0x7
  800d4e:	68 00 f0 bf ee       	push   $0xeebff000
  800d53:	6a 00                	push   $0x0
  800d55:	e8 0e f4 ff ff       	call   800168 <sys_page_alloc>
		if (ret < 0) {
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	78 28                	js     800d89 <set_pgfault_handler+0x59>
		ret = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  800d61:	83 ec 08             	sub    $0x8,%esp
  800d64:	68 17 03 80 00       	push   $0x800317
  800d69:	6a 00                	push   $0x0
  800d6b:	e8 01 f5 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
		if (ret < 0) {
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	85 c0                	test   %eax,%eax
  800d75:	79 c8                	jns    800d3f <set_pgfault_handler+0xf>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed: %e", ret);
  800d77:	50                   	push   %eax
  800d78:	68 b4 12 80 00       	push   $0x8012b4
  800d7d:	6a 26                	push   $0x26
  800d7f:	68 ef 12 80 00       	push   $0x8012ef
  800d84:	e8 b2 f5 ff ff       	call   80033b <_panic>
			panic("set_pgfault_handler: sys_page_alloc failed: %e", ret);
  800d89:	50                   	push   %eax
  800d8a:	68 84 12 80 00       	push   $0x801284
  800d8f:	6a 22                	push   $0x22
  800d91:	68 ef 12 80 00       	push   $0x8012ef
  800d96:	e8 a0 f5 ff ff       	call   80033b <_panic>
  800d9b:	66 90                	xchg   %ax,%ax
  800d9d:	66 90                	xchg   %ax,%ax
  800d9f:	90                   	nop

00800da0 <__udivdi3>:
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 1c             	sub    $0x1c,%esp
  800dab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800db3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	75 19                	jne    800dd8 <__udivdi3+0x38>
  800dbf:	39 f3                	cmp    %esi,%ebx
  800dc1:	76 4d                	jbe    800e10 <__udivdi3+0x70>
  800dc3:	31 ff                	xor    %edi,%edi
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	89 f2                	mov    %esi,%edx
  800dc9:	f7 f3                	div    %ebx
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 f0                	cmp    %esi,%eax
  800dda:	76 14                	jbe    800df0 <__udivdi3+0x50>
  800ddc:	31 ff                	xor    %edi,%edi
  800dde:	31 c0                	xor    %eax,%eax
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	83 c4 1c             	add    $0x1c,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
  800dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df0:	0f bd f8             	bsr    %eax,%edi
  800df3:	83 f7 1f             	xor    $0x1f,%edi
  800df6:	75 48                	jne    800e40 <__udivdi3+0xa0>
  800df8:	39 f0                	cmp    %esi,%eax
  800dfa:	72 06                	jb     800e02 <__udivdi3+0x62>
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	39 eb                	cmp    %ebp,%ebx
  800e00:	77 de                	ja     800de0 <__udivdi3+0x40>
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	eb d7                	jmp    800de0 <__udivdi3+0x40>
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d9                	mov    %ebx,%ecx
  800e12:	85 db                	test   %ebx,%ebx
  800e14:	75 0b                	jne    800e21 <__udivdi3+0x81>
  800e16:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f3                	div    %ebx
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	89 f0                	mov    %esi,%eax
  800e25:	f7 f1                	div    %ecx
  800e27:	89 c6                	mov    %eax,%esi
  800e29:	89 e8                	mov    %ebp,%eax
  800e2b:	89 f7                	mov    %esi,%edi
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	ba 20 00 00 00       	mov    $0x20,%edx
  800e47:	29 fa                	sub    %edi,%edx
  800e49:	d3 e0                	shl    %cl,%eax
  800e4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e4f:	89 d1                	mov    %edx,%ecx
  800e51:	89 d8                	mov    %ebx,%eax
  800e53:	d3 e8                	shr    %cl,%eax
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 c1                	or     %eax,%ecx
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	d3 e8                	shr    %cl,%eax
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	89 eb                	mov    %ebp,%ebx
  800e71:	d3 e6                	shl    %cl,%esi
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 f3                	or     %esi,%ebx
  800e79:	89 c6                	mov    %eax,%esi
  800e7b:	89 f2                	mov    %esi,%edx
  800e7d:	89 d8                	mov    %ebx,%eax
  800e7f:	f7 74 24 08          	divl   0x8(%esp)
  800e83:	89 d6                	mov    %edx,%esi
  800e85:	89 c3                	mov    %eax,%ebx
  800e87:	f7 64 24 0c          	mull   0xc(%esp)
  800e8b:	39 d6                	cmp    %edx,%esi
  800e8d:	72 19                	jb     800ea8 <__udivdi3+0x108>
  800e8f:	89 f9                	mov    %edi,%ecx
  800e91:	d3 e5                	shl    %cl,%ebp
  800e93:	39 c5                	cmp    %eax,%ebp
  800e95:	73 04                	jae    800e9b <__udivdi3+0xfb>
  800e97:	39 d6                	cmp    %edx,%esi
  800e99:	74 0d                	je     800ea8 <__udivdi3+0x108>
  800e9b:	89 d8                	mov    %ebx,%eax
  800e9d:	31 ff                	xor    %edi,%edi
  800e9f:	e9 3c ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eab:	31 ff                	xor    %edi,%edi
  800ead:	e9 2e ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 1c             	sub    $0x1c,%esp
  800ecb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ecf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ed3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800ed7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800edb:	89 f0                	mov    %esi,%eax
  800edd:	89 da                	mov    %ebx,%edx
  800edf:	85 ff                	test   %edi,%edi
  800ee1:	75 15                	jne    800ef8 <__umoddi3+0x38>
  800ee3:	39 dd                	cmp    %ebx,%ebp
  800ee5:	76 39                	jbe    800f20 <__umoddi3+0x60>
  800ee7:	f7 f5                	div    %ebp
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	39 df                	cmp    %ebx,%edi
  800efa:	77 f1                	ja     800eed <__umoddi3+0x2d>
  800efc:	0f bd cf             	bsr    %edi,%ecx
  800eff:	83 f1 1f             	xor    $0x1f,%ecx
  800f02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f06:	75 40                	jne    800f48 <__umoddi3+0x88>
  800f08:	39 df                	cmp    %ebx,%edi
  800f0a:	72 04                	jb     800f10 <__umoddi3+0x50>
  800f0c:	39 f5                	cmp    %esi,%ebp
  800f0e:	77 dd                	ja     800eed <__umoddi3+0x2d>
  800f10:	89 da                	mov    %ebx,%edx
  800f12:	89 f0                	mov    %esi,%eax
  800f14:	29 e8                	sub    %ebp,%eax
  800f16:	19 fa                	sbb    %edi,%edx
  800f18:	eb d3                	jmp    800eed <__umoddi3+0x2d>
  800f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f20:	89 e9                	mov    %ebp,%ecx
  800f22:	85 ed                	test   %ebp,%ebp
  800f24:	75 0b                	jne    800f31 <__umoddi3+0x71>
  800f26:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	f7 f5                	div    %ebp
  800f2f:	89 c1                	mov    %eax,%ecx
  800f31:	89 d8                	mov    %ebx,%eax
  800f33:	31 d2                	xor    %edx,%edx
  800f35:	f7 f1                	div    %ecx
  800f37:	89 f0                	mov    %esi,%eax
  800f39:	f7 f1                	div    %ecx
  800f3b:	89 d0                	mov    %edx,%eax
  800f3d:	31 d2                	xor    %edx,%edx
  800f3f:	eb ac                	jmp    800eed <__umoddi3+0x2d>
  800f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f48:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f4c:	ba 20 00 00 00       	mov    $0x20,%edx
  800f51:	29 c2                	sub    %eax,%edx
  800f53:	89 c1                	mov    %eax,%ecx
  800f55:	89 e8                	mov    %ebp,%eax
  800f57:	d3 e7                	shl    %cl,%edi
  800f59:	89 d1                	mov    %edx,%ecx
  800f5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f5f:	d3 e8                	shr    %cl,%eax
  800f61:	89 c1                	mov    %eax,%ecx
  800f63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f67:	09 f9                	or     %edi,%ecx
  800f69:	89 df                	mov    %ebx,%edi
  800f6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	d3 e5                	shl    %cl,%ebp
  800f73:	89 d1                	mov    %edx,%ecx
  800f75:	d3 ef                	shr    %cl,%edi
  800f77:	89 c1                	mov    %eax,%ecx
  800f79:	89 f0                	mov    %esi,%eax
  800f7b:	d3 e3                	shl    %cl,%ebx
  800f7d:	89 d1                	mov    %edx,%ecx
  800f7f:	89 fa                	mov    %edi,%edx
  800f81:	d3 e8                	shr    %cl,%eax
  800f83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f88:	09 d8                	or     %ebx,%eax
  800f8a:	f7 74 24 08          	divl   0x8(%esp)
  800f8e:	89 d3                	mov    %edx,%ebx
  800f90:	d3 e6                	shl    %cl,%esi
  800f92:	f7 e5                	mul    %ebp
  800f94:	89 c7                	mov    %eax,%edi
  800f96:	89 d1                	mov    %edx,%ecx
  800f98:	39 d3                	cmp    %edx,%ebx
  800f9a:	72 06                	jb     800fa2 <__umoddi3+0xe2>
  800f9c:	75 0e                	jne    800fac <__umoddi3+0xec>
  800f9e:	39 c6                	cmp    %eax,%esi
  800fa0:	73 0a                	jae    800fac <__umoddi3+0xec>
  800fa2:	29 e8                	sub    %ebp,%eax
  800fa4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fa8:	89 d1                	mov    %edx,%ecx
  800faa:	89 c7                	mov    %eax,%edi
  800fac:	89 f5                	mov    %esi,%ebp
  800fae:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fb2:	29 fd                	sub    %edi,%ebp
  800fb4:	19 cb                	sbb    %ecx,%ebx
  800fb6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	d3 e0                	shl    %cl,%eax
  800fbf:	89 f1                	mov    %esi,%ecx
  800fc1:	d3 ed                	shr    %cl,%ebp
  800fc3:	d3 eb                	shr    %cl,%ebx
  800fc5:	09 e8                	or     %ebp,%eax
  800fc7:	89 da                	mov    %ebx,%edx
  800fc9:	83 c4 1c             	add    $0x1c,%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

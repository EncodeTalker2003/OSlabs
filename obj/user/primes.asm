
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 51 11 00 00       	call   80119d <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 80 15 80 00       	push   $0x801580
  800060:	e8 c2 01 00 00       	call   800227 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 d3 0e 00 00       	call   800f3d <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 2e                	js     8000a1 <primeproc+0x6e>
		panic("fork: %e", id);
	if (id == 0)
  800073:	74 ca                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800075:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800078:	83 ec 04             	sub    $0x4,%esp
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	56                   	push   %esi
  800080:	e8 18 11 00 00       	call   80119d <ipc_recv>
  800085:	89 c1                	mov    %eax,%ecx
		if (i % p)
  800087:	99                   	cltd   
  800088:	f7 fb                	idiv   %ebx
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	85 d2                	test   %edx,%edx
  80008f:	74 e7                	je     800078 <primeproc+0x45>
			ipc_send(id, i, 0, 0);
  800091:	6a 00                	push   $0x0
  800093:	6a 00                	push   $0x0
  800095:	51                   	push   %ecx
  800096:	57                   	push   %edi
  800097:	e8 74 11 00 00       	call   801210 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb d7                	jmp    800078 <primeproc+0x45>
		panic("fork: %e", id);
  8000a1:	50                   	push   %eax
  8000a2:	68 8c 15 80 00       	push   $0x80158c
  8000a7:	6a 1a                	push   $0x1a
  8000a9:	68 95 15 80 00       	push   $0x801595
  8000ae:	e8 99 00 00 00       	call   80014c <_panic>

008000b3 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000b8:	e8 80 0e 00 00       	call   800f3d <fork>
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	78 1a                	js     8000dd <umain+0x2a>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000c3:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000c8:	74 25                	je     8000ef <umain+0x3c>
		ipc_send(id, i, 0, 0);
  8000ca:	6a 00                	push   $0x0
  8000cc:	6a 00                	push   $0x0
  8000ce:	53                   	push   %ebx
  8000cf:	56                   	push   %esi
  8000d0:	e8 3b 11 00 00       	call   801210 <ipc_send>
	for (i = 2; ; i++)
  8000d5:	83 c3 01             	add    $0x1,%ebx
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	eb ed                	jmp    8000ca <umain+0x17>
		panic("fork: %e", id);
  8000dd:	50                   	push   %eax
  8000de:	68 8c 15 80 00       	push   $0x80158c
  8000e3:	6a 2d                	push   $0x2d
  8000e5:	68 95 15 80 00       	push   $0x801595
  8000ea:	e8 5d 00 00 00       	call   80014c <_panic>
		primeproc();
  8000ef:	e8 3f ff ff ff       	call   800033 <primeproc>

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000ff:	e8 bb 0a 00 00       	call   800bbf <sys_getenvid>
  800104:	25 ff 03 00 00       	and    $0x3ff,%eax
  800109:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800111:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800116:	85 db                	test   %ebx,%ebx
  800118:	7e 07                	jle    800121 <libmain+0x2d>
		binaryname = argv[0];
  80011a:	8b 06                	mov    (%esi),%eax
  80011c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
  800126:	e8 88 ff ff ff       	call   8000b3 <umain>

	// exit gracefully
	exit();
  80012b:	e8 0a 00 00 00       	call   80013a <exit>
}
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800140:	6a 00                	push   $0x0
  800142:	e8 37 0a 00 00       	call   800b7e <sys_env_destroy>
}
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800151:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800154:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015a:	e8 60 0a 00 00       	call   800bbf <sys_getenvid>
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	ff 75 0c             	push   0xc(%ebp)
  800165:	ff 75 08             	push   0x8(%ebp)
  800168:	56                   	push   %esi
  800169:	50                   	push   %eax
  80016a:	68 b0 15 80 00       	push   $0x8015b0
  80016f:	e8 b3 00 00 00       	call   800227 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	83 c4 18             	add    $0x18,%esp
  800177:	53                   	push   %ebx
  800178:	ff 75 10             	push   0x10(%ebp)
  80017b:	e8 56 00 00 00       	call   8001d6 <vcprintf>
	cprintf("\n");
  800180:	c7 04 24 d3 15 80 00 	movl   $0x8015d3,(%esp)
  800187:	e8 9b 00 00 00       	call   800227 <cprintf>
  80018c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x43>

00800192 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	53                   	push   %ebx
  800196:	83 ec 04             	sub    $0x4,%esp
  800199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019c:	8b 13                	mov    (%ebx),%edx
  80019e:	8d 42 01             	lea    0x1(%edx),%eax
  8001a1:	89 03                	mov    %eax,(%ebx)
  8001a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	74 09                	je     8001ba <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ba:	83 ec 08             	sub    $0x8,%esp
  8001bd:	68 ff 00 00 00       	push   $0xff
  8001c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c5:	50                   	push   %eax
  8001c6:	e8 76 09 00 00       	call   800b41 <sys_cputs>
		b->idx = 0;
  8001cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d1:	83 c4 10             	add    $0x10,%esp
  8001d4:	eb db                	jmp    8001b1 <putch+0x1f>

008001d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e6:	00 00 00 
	b.cnt = 0;
  8001e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f3:	ff 75 0c             	push   0xc(%ebp)
  8001f6:	ff 75 08             	push   0x8(%ebp)
  8001f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ff:	50                   	push   %eax
  800200:	68 92 01 80 00       	push   $0x800192
  800205:	e8 14 01 00 00       	call   80031e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020a:	83 c4 08             	add    $0x8,%esp
  80020d:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800213:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800219:	50                   	push   %eax
  80021a:	e8 22 09 00 00       	call   800b41 <sys_cputs>

	return b.cnt;
}
  80021f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800225:	c9                   	leave  
  800226:	c3                   	ret    

00800227 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800230:	50                   	push   %eax
  800231:	ff 75 08             	push   0x8(%ebp)
  800234:	e8 9d ff ff ff       	call   8001d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	57                   	push   %edi
  80023f:	56                   	push   %esi
  800240:	53                   	push   %ebx
  800241:	83 ec 1c             	sub    $0x1c,%esp
  800244:	89 c7                	mov    %eax,%edi
  800246:	89 d6                	mov    %edx,%esi
  800248:	8b 45 08             	mov    0x8(%ebp),%eax
  80024b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024e:	89 d1                	mov    %edx,%ecx
  800250:	89 c2                	mov    %eax,%edx
  800252:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800255:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800258:	8b 45 10             	mov    0x10(%ebp),%eax
  80025b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800261:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800268:	39 c2                	cmp    %eax,%edx
  80026a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80026d:	72 3e                	jb     8002ad <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	ff 75 18             	push   0x18(%ebp)
  800275:	83 eb 01             	sub    $0x1,%ebx
  800278:	53                   	push   %ebx
  800279:	50                   	push   %eax
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	push   -0x1c(%ebp)
  800280:	ff 75 e0             	push   -0x20(%ebp)
  800283:	ff 75 dc             	push   -0x24(%ebp)
  800286:	ff 75 d8             	push   -0x28(%ebp)
  800289:	e8 b2 10 00 00       	call   801340 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9f ff ff ff       	call   80023b <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 13                	jmp    8002b4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	push   0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002ad:	83 eb 01             	sub    $0x1,%ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f ed                	jg     8002a1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	83 ec 08             	sub    $0x8,%esp
  8002b7:	56                   	push   %esi
  8002b8:	83 ec 04             	sub    $0x4,%esp
  8002bb:	ff 75 e4             	push   -0x1c(%ebp)
  8002be:	ff 75 e0             	push   -0x20(%ebp)
  8002c1:	ff 75 dc             	push   -0x24(%ebp)
  8002c4:	ff 75 d8             	push   -0x28(%ebp)
  8002c7:	e8 94 11 00 00       	call   801460 <__umoddi3>
  8002cc:	83 c4 14             	add    $0x14,%esp
  8002cf:	0f be 80 d5 15 80 00 	movsbl 0x8015d5(%eax),%eax
  8002d6:	50                   	push   %eax
  8002d7:	ff d7                	call   *%edi
}
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002df:	5b                   	pop    %ebx
  8002e0:	5e                   	pop    %esi
  8002e1:	5f                   	pop    %edi
  8002e2:	5d                   	pop    %ebp
  8002e3:	c3                   	ret    

008002e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ea:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f3:	73 0a                	jae    8002ff <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f8:	89 08                	mov    %ecx,(%eax)
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	88 02                	mov    %al,(%edx)
}
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <printfmt>:
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800307:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030a:	50                   	push   %eax
  80030b:	ff 75 10             	push   0x10(%ebp)
  80030e:	ff 75 0c             	push   0xc(%ebp)
  800311:	ff 75 08             	push   0x8(%ebp)
  800314:	e8 05 00 00 00       	call   80031e <vprintfmt>
}
  800319:	83 c4 10             	add    $0x10,%esp
  80031c:	c9                   	leave  
  80031d:	c3                   	ret    

0080031e <vprintfmt>:
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
  800324:	83 ec 3c             	sub    $0x3c,%esp
  800327:	8b 75 08             	mov    0x8(%ebp),%esi
  80032a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800330:	eb 0a                	jmp    80033c <vprintfmt+0x1e>
			putch(ch, putdat);
  800332:	83 ec 08             	sub    $0x8,%esp
  800335:	53                   	push   %ebx
  800336:	50                   	push   %eax
  800337:	ff d6                	call   *%esi
  800339:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033c:	83 c7 01             	add    $0x1,%edi
  80033f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800343:	83 f8 25             	cmp    $0x25,%eax
  800346:	74 0c                	je     800354 <vprintfmt+0x36>
			if (ch == '\0')
  800348:	85 c0                	test   %eax,%eax
  80034a:	75 e6                	jne    800332 <vprintfmt+0x14>
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    
		padc = ' ';
  800354:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800358:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80035f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800366:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80036d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800372:	8d 47 01             	lea    0x1(%edi),%eax
  800375:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800378:	0f b6 17             	movzbl (%edi),%edx
  80037b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80037e:	3c 55                	cmp    $0x55,%al
  800380:	0f 87 bb 03 00 00    	ja     800741 <vprintfmt+0x423>
  800386:	0f b6 c0             	movzbl %al,%eax
  800389:	ff 24 85 a0 16 80 00 	jmp    *0x8016a0(,%eax,4)
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800393:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800397:	eb d9                	jmp    800372 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003a0:	eb d0                	jmp    800372 <vprintfmt+0x54>
  8003a2:	0f b6 d2             	movzbl %dl,%edx
  8003a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ad:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003b0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ba:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003bd:	83 f9 09             	cmp    $0x9,%ecx
  8003c0:	77 55                	ja     800417 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003c2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c5:	eb e9                	jmp    8003b0 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	8b 00                	mov    (%eax),%eax
  8003cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 40 04             	lea    0x4(%eax),%eax
  8003d5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003df:	79 91                	jns    800372 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ee:	eb 82                	jmp    800372 <vprintfmt+0x54>
  8003f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f3:	85 d2                	test   %edx,%edx
  8003f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fa:	0f 49 c2             	cmovns %edx,%eax
  8003fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800403:	e9 6a ff ff ff       	jmp    800372 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80040b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800412:	e9 5b ff ff ff       	jmp    800372 <vprintfmt+0x54>
  800417:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80041a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041d:	eb bc                	jmp    8003db <vprintfmt+0xbd>
			lflag++;
  80041f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800425:	e9 48 ff ff ff       	jmp    800372 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8d 78 04             	lea    0x4(%eax),%edi
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	53                   	push   %ebx
  800434:	ff 30                	push   (%eax)
  800436:	ff d6                	call   *%esi
			break;
  800438:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80043b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80043e:	e9 9d 02 00 00       	jmp    8006e0 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 78 04             	lea    0x4(%eax),%edi
  800449:	8b 10                	mov    (%eax),%edx
  80044b:	89 d0                	mov    %edx,%eax
  80044d:	f7 d8                	neg    %eax
  80044f:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800452:	83 f8 08             	cmp    $0x8,%eax
  800455:	7f 23                	jg     80047a <vprintfmt+0x15c>
  800457:	8b 14 85 00 18 80 00 	mov    0x801800(,%eax,4),%edx
  80045e:	85 d2                	test   %edx,%edx
  800460:	74 18                	je     80047a <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800462:	52                   	push   %edx
  800463:	68 f6 15 80 00       	push   $0x8015f6
  800468:	53                   	push   %ebx
  800469:	56                   	push   %esi
  80046a:	e8 92 fe ff ff       	call   800301 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800472:	89 7d 14             	mov    %edi,0x14(%ebp)
  800475:	e9 66 02 00 00       	jmp    8006e0 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80047a:	50                   	push   %eax
  80047b:	68 ed 15 80 00       	push   $0x8015ed
  800480:	53                   	push   %ebx
  800481:	56                   	push   %esi
  800482:	e8 7a fe ff ff       	call   800301 <printfmt>
  800487:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80048a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80048d:	e9 4e 02 00 00       	jmp    8006e0 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	83 c0 04             	add    $0x4,%eax
  800498:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004a0:	85 d2                	test   %edx,%edx
  8004a2:	b8 e6 15 80 00       	mov    $0x8015e6,%eax
  8004a7:	0f 45 c2             	cmovne %edx,%eax
  8004aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b1:	7e 06                	jle    8004b9 <vprintfmt+0x19b>
  8004b3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b7:	75 0d                	jne    8004c6 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004bc:	89 c7                	mov    %eax,%edi
  8004be:	03 45 e0             	add    -0x20(%ebp),%eax
  8004c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c4:	eb 55                	jmp    80051b <vprintfmt+0x1fd>
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 d8             	push   -0x28(%ebp)
  8004cc:	ff 75 cc             	push   -0x34(%ebp)
  8004cf:	e8 0a 03 00 00       	call   8007de <strnlen>
  8004d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d7:	29 c1                	sub    %eax,%ecx
  8004d9:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004e1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e8:	eb 0f                	jmp    8004f9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	ff 75 e0             	push   -0x20(%ebp)
  8004f1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	83 ef 01             	sub    $0x1,%edi
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 ff                	test   %edi,%edi
  8004fb:	7f ed                	jg     8004ea <vprintfmt+0x1cc>
  8004fd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800500:	85 d2                	test   %edx,%edx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c2             	cmovns %edx,%eax
  80050a:	29 c2                	sub    %eax,%edx
  80050c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050f:	eb a8                	jmp    8004b9 <vprintfmt+0x19b>
					putch(ch, putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	52                   	push   %edx
  800516:	ff d6                	call   *%esi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051e:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800520:	83 c7 01             	add    $0x1,%edi
  800523:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800527:	0f be d0             	movsbl %al,%edx
  80052a:	85 d2                	test   %edx,%edx
  80052c:	74 4b                	je     800579 <vprintfmt+0x25b>
  80052e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800532:	78 06                	js     80053a <vprintfmt+0x21c>
  800534:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800538:	78 1e                	js     800558 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80053a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053e:	74 d1                	je     800511 <vprintfmt+0x1f3>
  800540:	0f be c0             	movsbl %al,%eax
  800543:	83 e8 20             	sub    $0x20,%eax
  800546:	83 f8 5e             	cmp    $0x5e,%eax
  800549:	76 c6                	jbe    800511 <vprintfmt+0x1f3>
					putch('?', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	6a 3f                	push   $0x3f
  800551:	ff d6                	call   *%esi
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb c3                	jmp    80051b <vprintfmt+0x1fd>
  800558:	89 cf                	mov    %ecx,%edi
  80055a:	eb 0e                	jmp    80056a <vprintfmt+0x24c>
				putch(' ', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	6a 20                	push   $0x20
  800562:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800564:	83 ef 01             	sub    $0x1,%edi
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	85 ff                	test   %edi,%edi
  80056c:	7f ee                	jg     80055c <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80056e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
  800574:	e9 67 01 00 00       	jmp    8006e0 <vprintfmt+0x3c2>
  800579:	89 cf                	mov    %ecx,%edi
  80057b:	eb ed                	jmp    80056a <vprintfmt+0x24c>
	if (lflag >= 2)
  80057d:	83 f9 01             	cmp    $0x1,%ecx
  800580:	7f 1b                	jg     80059d <vprintfmt+0x27f>
	else if (lflag)
  800582:	85 c9                	test   %ecx,%ecx
  800584:	74 63                	je     8005e9 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058e:	99                   	cltd   
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
  80059b:	eb 17                	jmp    8005b4 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 50 04             	mov    0x4(%eax),%edx
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 40 08             	lea    0x8(%eax),%eax
  8005b1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ba:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005bf:	85 c9                	test   %ecx,%ecx
  8005c1:	0f 89 ff 00 00 00    	jns    8006c6 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	6a 2d                	push   $0x2d
  8005cd:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d5:	f7 da                	neg    %edx
  8005d7:	83 d1 00             	adc    $0x0,%ecx
  8005da:	f7 d9                	neg    %ecx
  8005dc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005df:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005e4:	e9 dd 00 00 00       	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	99                   	cltd   
  8005f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fe:	eb b4                	jmp    8005b4 <vprintfmt+0x296>
	if (lflag >= 2)
  800600:	83 f9 01             	cmp    $0x1,%ecx
  800603:	7f 1e                	jg     800623 <vprintfmt+0x305>
	else if (lflag)
  800605:	85 c9                	test   %ecx,%ecx
  800607:	74 32                	je     80063b <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	8d 40 04             	lea    0x4(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800619:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80061e:	e9 a3 00 00 00       	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	8b 48 04             	mov    0x4(%eax),%ecx
  80062b:	8d 40 08             	lea    0x8(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800631:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800636:	e9 8b 00 00 00       	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800650:	eb 74                	jmp    8006c6 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800652:	83 f9 01             	cmp    $0x1,%ecx
  800655:	7f 1b                	jg     800672 <vprintfmt+0x354>
	else if (lflag)
  800657:	85 c9                	test   %ecx,%ecx
  800659:	74 2c                	je     800687 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	b9 00 00 00 00       	mov    $0x0,%ecx
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80066b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800670:	eb 54                	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	8b 48 04             	mov    0x4(%eax),%ecx
  80067a:	8d 40 08             	lea    0x8(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800680:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800685:	eb 3f                	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 10                	mov    (%eax),%edx
  80068c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800697:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80069c:	eb 28                	jmp    8006c6 <vprintfmt+0x3a8>
			putch('0', putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 30                	push   $0x30
  8006a4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a6:	83 c4 08             	add    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 78                	push   $0x78
  8006ac:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 10                	mov    (%eax),%edx
  8006b3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006bb:	8d 40 04             	lea    0x4(%eax),%eax
  8006be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c1:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006c6:	83 ec 0c             	sub    $0xc,%esp
  8006c9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006cd:	50                   	push   %eax
  8006ce:	ff 75 e0             	push   -0x20(%ebp)
  8006d1:	57                   	push   %edi
  8006d2:	51                   	push   %ecx
  8006d3:	52                   	push   %edx
  8006d4:	89 da                	mov    %ebx,%edx
  8006d6:	89 f0                	mov    %esi,%eax
  8006d8:	e8 5e fb ff ff       	call   80023b <printnum>
			break;
  8006dd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e3:	e9 54 fc ff ff       	jmp    80033c <vprintfmt+0x1e>
	if (lflag >= 2)
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	7f 1b                	jg     800708 <vprintfmt+0x3ea>
	else if (lflag)
  8006ed:	85 c9                	test   %ecx,%ecx
  8006ef:	74 2c                	je     80071d <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800701:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800706:	eb be                	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	8b 48 04             	mov    0x4(%eax),%ecx
  800710:	8d 40 08             	lea    0x8(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800716:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80071b:	eb a9                	jmp    8006c6 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072d:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800732:	eb 92                	jmp    8006c6 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 25                	push   $0x25
  80073a:	ff d6                	call   *%esi
			break;
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb 9f                	jmp    8006e0 <vprintfmt+0x3c2>
			putch('%', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	53                   	push   %ebx
  800745:	6a 25                	push   $0x25
  800747:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	89 f8                	mov    %edi,%eax
  80074e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800752:	74 05                	je     800759 <vprintfmt+0x43b>
  800754:	83 e8 01             	sub    $0x1,%eax
  800757:	eb f5                	jmp    80074e <vprintfmt+0x430>
  800759:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80075c:	eb 82                	jmp    8006e0 <vprintfmt+0x3c2>

0080075e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 18             	sub    $0x18,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 26                	je     8007a5 <vsnprintf+0x47>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 22                	jle    8007a5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	ff 75 14             	push   0x14(%ebp)
  800786:	ff 75 10             	push   0x10(%ebp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	50                   	push   %eax
  80078d:	68 e4 02 80 00       	push   $0x8002e4
  800792:	e8 87 fb ff ff       	call   80031e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800797:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a0:	83 c4 10             	add    $0x10,%esp
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    
		return -E_INVAL;
  8007a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007aa:	eb f7                	jmp    8007a3 <vsnprintf+0x45>

008007ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 10             	push   0x10(%ebp)
  8007b9:	ff 75 0c             	push   0xc(%ebp)
  8007bc:	ff 75 08             	push   0x8(%ebp)
  8007bf:	e8 9a ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 03                	jmp    8007d6 <strlen+0x10>
		n++;
  8007d3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f7                	jne    8007d3 <strlen+0xd>
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 03                	jmp    8007f1 <strnlen+0x13>
		n++;
  8007ee:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	39 d0                	cmp    %edx,%eax
  8007f3:	74 08                	je     8007fd <strnlen+0x1f>
  8007f5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f9:	75 f3                	jne    8007ee <strnlen+0x10>
  8007fb:	89 c2                	mov    %eax,%edx
	return n;
}
  8007fd:	89 d0                	mov    %edx,%eax
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	53                   	push   %ebx
  800805:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800814:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800817:	83 c0 01             	add    $0x1,%eax
  80081a:	84 d2                	test   %dl,%dl
  80081c:	75 f2                	jne    800810 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80081e:	89 c8                	mov    %ecx,%eax
  800820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	83 ec 10             	sub    $0x10,%esp
  80082c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082f:	53                   	push   %ebx
  800830:	e8 91 ff ff ff       	call   8007c6 <strlen>
  800835:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800838:	ff 75 0c             	push   0xc(%ebp)
  80083b:	01 d8                	add    %ebx,%eax
  80083d:	50                   	push   %eax
  80083e:	e8 be ff ff ff       	call   800801 <strcpy>
	return dst;
}
  800843:	89 d8                	mov    %ebx,%eax
  800845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 75 08             	mov    0x8(%ebp),%esi
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
  800855:	89 f3                	mov    %esi,%ebx
  800857:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085a:	89 f0                	mov    %esi,%eax
  80085c:	eb 0f                	jmp    80086d <strncpy+0x23>
		*dst++ = *src;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	0f b6 0a             	movzbl (%edx),%ecx
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 f9 01             	cmp    $0x1,%cl
  80086a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80086d:	39 d8                	cmp    %ebx,%eax
  80086f:	75 ed                	jne    80085e <strncpy+0x14>
	}
	return ret;
}
  800871:	89 f0                	mov    %esi,%eax
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 75 08             	mov    0x8(%ebp),%esi
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800882:	8b 55 10             	mov    0x10(%ebp),%edx
  800885:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800887:	85 d2                	test   %edx,%edx
  800889:	74 21                	je     8008ac <strlcpy+0x35>
  80088b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088f:	89 f2                	mov    %esi,%edx
  800891:	eb 09                	jmp    80089c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800893:	83 c1 01             	add    $0x1,%ecx
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80089c:	39 c2                	cmp    %eax,%edx
  80089e:	74 09                	je     8008a9 <strlcpy+0x32>
  8008a0:	0f b6 19             	movzbl (%ecx),%ebx
  8008a3:	84 db                	test   %bl,%bl
  8008a5:	75 ec                	jne    800893 <strlcpy+0x1c>
  8008a7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008a9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ac:	29 f0                	sub    %esi,%eax
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008bb:	eb 06                	jmp    8008c3 <strcmp+0x11>
		p++, q++;
  8008bd:	83 c1 01             	add    $0x1,%ecx
  8008c0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008c3:	0f b6 01             	movzbl (%ecx),%eax
  8008c6:	84 c0                	test   %al,%al
  8008c8:	74 04                	je     8008ce <strcmp+0x1c>
  8008ca:	3a 02                	cmp    (%edx),%al
  8008cc:	74 ef                	je     8008bd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 c0             	movzbl %al,%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e2:	89 c3                	mov    %eax,%ebx
  8008e4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e7:	eb 06                	jmp    8008ef <strncmp+0x17>
		n--, p++, q++;
  8008e9:	83 c0 01             	add    $0x1,%eax
  8008ec:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ef:	39 d8                	cmp    %ebx,%eax
  8008f1:	74 18                	je     80090b <strncmp+0x33>
  8008f3:	0f b6 08             	movzbl (%eax),%ecx
  8008f6:	84 c9                	test   %cl,%cl
  8008f8:	74 04                	je     8008fe <strncmp+0x26>
  8008fa:	3a 0a                	cmp    (%edx),%cl
  8008fc:	74 eb                	je     8008e9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 00             	movzbl (%eax),%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
}
  800906:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800909:	c9                   	leave  
  80090a:	c3                   	ret    
		return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb f4                	jmp    800906 <strncmp+0x2e>

00800912 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091c:	eb 03                	jmp    800921 <strchr+0xf>
  80091e:	83 c0 01             	add    $0x1,%eax
  800921:	0f b6 10             	movzbl (%eax),%edx
  800924:	84 d2                	test   %dl,%dl
  800926:	74 06                	je     80092e <strchr+0x1c>
		if (*s == c)
  800928:	38 ca                	cmp    %cl,%dl
  80092a:	75 f2                	jne    80091e <strchr+0xc>
  80092c:	eb 05                	jmp    800933 <strchr+0x21>
			return (char *) s;
	return 0;
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800942:	38 ca                	cmp    %cl,%dl
  800944:	74 09                	je     80094f <strfind+0x1a>
  800946:	84 d2                	test   %dl,%dl
  800948:	74 05                	je     80094f <strfind+0x1a>
	for (; *s; s++)
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	eb f0                	jmp    80093f <strfind+0xa>
			break;
	return (char *) s;
}
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	57                   	push   %edi
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 7d 08             	mov    0x8(%ebp),%edi
  80095a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095d:	85 c9                	test   %ecx,%ecx
  80095f:	74 2f                	je     800990 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800961:	89 f8                	mov    %edi,%eax
  800963:	09 c8                	or     %ecx,%eax
  800965:	a8 03                	test   $0x3,%al
  800967:	75 21                	jne    80098a <memset+0x39>
		c &= 0xFF;
  800969:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d0                	mov    %edx,%eax
  80096f:	c1 e0 08             	shl    $0x8,%eax
  800972:	89 d3                	mov    %edx,%ebx
  800974:	c1 e3 18             	shl    $0x18,%ebx
  800977:	89 d6                	mov    %edx,%esi
  800979:	c1 e6 10             	shl    $0x10,%esi
  80097c:	09 f3                	or     %esi,%ebx
  80097e:	09 da                	or     %ebx,%edx
  800980:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800982:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800985:	fc                   	cld    
  800986:	f3 ab                	rep stos %eax,%es:(%edi)
  800988:	eb 06                	jmp    800990 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098d:	fc                   	cld    
  80098e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800990:	89 f8                	mov    %edi,%eax
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a5:	39 c6                	cmp    %eax,%esi
  8009a7:	73 32                	jae    8009db <memmove+0x44>
  8009a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ac:	39 c2                	cmp    %eax,%edx
  8009ae:	76 2b                	jbe    8009db <memmove+0x44>
		s += n;
		d += n;
  8009b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	89 d6                	mov    %edx,%esi
  8009b5:	09 fe                	or     %edi,%esi
  8009b7:	09 ce                	or     %ecx,%esi
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 0e                	jne    8009cf <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009c1:	83 ef 04             	sub    $0x4,%edi
  8009c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ca:	fd                   	std    
  8009cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cd:	eb 09                	jmp    8009d8 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009cf:	83 ef 01             	sub    $0x1,%edi
  8009d2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d5:	fd                   	std    
  8009d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d8:	fc                   	cld    
  8009d9:	eb 1a                	jmp    8009f5 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009db:	89 f2                	mov    %esi,%edx
  8009dd:	09 c2                	or     %eax,%edx
  8009df:	09 ca                	or     %ecx,%edx
  8009e1:	f6 c2 03             	test   $0x3,%dl
  8009e4:	75 0a                	jne    8009f0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009e6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ee:	eb 05                	jmp    8009f5 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009f0:	89 c7                	mov    %eax,%edi
  8009f2:	fc                   	cld    
  8009f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ff:	ff 75 10             	push   0x10(%ebp)
  800a02:	ff 75 0c             	push   0xc(%ebp)
  800a05:	ff 75 08             	push   0x8(%ebp)
  800a08:	e8 8a ff ff ff       	call   800997 <memmove>
}
  800a0d:	c9                   	leave  
  800a0e:	c3                   	ret    

00800a0f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1a:	89 c6                	mov    %eax,%esi
  800a1c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1f:	eb 06                	jmp    800a27 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a27:	39 f0                	cmp    %esi,%eax
  800a29:	74 14                	je     800a3f <memcmp+0x30>
		if (*s1 != *s2)
  800a2b:	0f b6 08             	movzbl (%eax),%ecx
  800a2e:	0f b6 1a             	movzbl (%edx),%ebx
  800a31:	38 d9                	cmp    %bl,%cl
  800a33:	74 ec                	je     800a21 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c1             	movzbl %cl,%eax
  800a38:	0f b6 db             	movzbl %bl,%ebx
  800a3b:	29 d8                	sub    %ebx,%eax
  800a3d:	eb 05                	jmp    800a44 <memcmp+0x35>
	}

	return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a51:	89 c2                	mov    %eax,%edx
  800a53:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a56:	eb 03                	jmp    800a5b <memfind+0x13>
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	39 d0                	cmp    %edx,%eax
  800a5d:	73 04                	jae    800a63 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5f:	38 08                	cmp    %cl,(%eax)
  800a61:	75 f5                	jne    800a58 <memfind+0x10>
			break;
	return (void *) s;
}
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a71:	eb 03                	jmp    800a76 <strtol+0x11>
		s++;
  800a73:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a76:	0f b6 02             	movzbl (%edx),%eax
  800a79:	3c 20                	cmp    $0x20,%al
  800a7b:	74 f6                	je     800a73 <strtol+0xe>
  800a7d:	3c 09                	cmp    $0x9,%al
  800a7f:	74 f2                	je     800a73 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a81:	3c 2b                	cmp    $0x2b,%al
  800a83:	74 2a                	je     800aaf <strtol+0x4a>
	int neg = 0;
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	74 2b                	je     800ab9 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a94:	75 0f                	jne    800aa5 <strtol+0x40>
  800a96:	80 3a 30             	cmpb   $0x30,(%edx)
  800a99:	74 28                	je     800ac3 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9b:	85 db                	test   %ebx,%ebx
  800a9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aa2:	0f 44 d8             	cmove  %eax,%ebx
  800aa5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaa:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aad:	eb 46                	jmp    800af5 <strtol+0x90>
		s++;
  800aaf:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ab2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab7:	eb d5                	jmp    800a8e <strtol+0x29>
		s++, neg = 1;
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac1:	eb cb                	jmp    800a8e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac7:	74 0e                	je     800ad7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ac9:	85 db                	test   %ebx,%ebx
  800acb:	75 d8                	jne    800aa5 <strtol+0x40>
		s++, base = 8;
  800acd:	83 c2 01             	add    $0x1,%edx
  800ad0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad5:	eb ce                	jmp    800aa5 <strtol+0x40>
		s += 2, base = 16;
  800ad7:	83 c2 02             	add    $0x2,%edx
  800ada:	bb 10 00 00 00       	mov    $0x10,%ebx
  800adf:	eb c4                	jmp    800aa5 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ae1:	0f be c0             	movsbl %al,%eax
  800ae4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800aea:	7d 3a                	jge    800b26 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800aec:	83 c2 01             	add    $0x1,%edx
  800aef:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800af3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800af5:	0f b6 02             	movzbl (%edx),%eax
  800af8:	8d 70 d0             	lea    -0x30(%eax),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 09             	cmp    $0x9,%bl
  800b00:	76 df                	jbe    800ae1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b02:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b05:	89 f3                	mov    %esi,%ebx
  800b07:	80 fb 19             	cmp    $0x19,%bl
  800b0a:	77 08                	ja     800b14 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b0c:	0f be c0             	movsbl %al,%eax
  800b0f:	83 e8 57             	sub    $0x57,%eax
  800b12:	eb d3                	jmp    800ae7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b14:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b17:	89 f3                	mov    %esi,%ebx
  800b19:	80 fb 19             	cmp    $0x19,%bl
  800b1c:	77 08                	ja     800b26 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b1e:	0f be c0             	movsbl %al,%eax
  800b21:	83 e8 37             	sub    $0x37,%eax
  800b24:	eb c1                	jmp    800ae7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2a:	74 05                	je     800b31 <strtol+0xcc>
		*endptr = (char *) s;
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b31:	89 c8                	mov    %ecx,%eax
  800b33:	f7 d8                	neg    %eax
  800b35:	85 ff                	test   %edi,%edi
  800b37:	0f 45 c8             	cmovne %eax,%ecx
}
  800b3a:	89 c8                	mov    %ecx,%eax
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b94:	89 cb                	mov    %ecx,%ebx
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	89 ce                	mov    %ecx,%esi
  800b9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7f 08                	jg     800ba8 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 03                	push   $0x3
  800bae:	68 24 18 80 00       	push   $0x801824
  800bb3:	6a 23                	push   $0x23
  800bb5:	68 41 18 80 00       	push   $0x801841
  800bba:	e8 8d f5 ff ff       	call   80014c <_panic>

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_yield>:

void
sys_yield(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c06:	be 00 00 00 00       	mov    $0x0,%esi
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	b8 04 00 00 00       	mov    $0x4,%eax
  800c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c19:	89 f7                	mov    %esi,%edi
  800c1b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7f 08                	jg     800c29 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c29:	83 ec 0c             	sub    $0xc,%esp
  800c2c:	50                   	push   %eax
  800c2d:	6a 04                	push   $0x4
  800c2f:	68 24 18 80 00       	push   $0x801824
  800c34:	6a 23                	push   $0x23
  800c36:	68 41 18 80 00       	push   $0x801841
  800c3b:	e8 0c f5 ff ff       	call   80014c <_panic>

00800c40 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7f 08                	jg     800c6b <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 05                	push   $0x5
  800c71:	68 24 18 80 00       	push   $0x801824
  800c76:	6a 23                	push   $0x23
  800c78:	68 41 18 80 00       	push   $0x801841
  800c7d:	e8 ca f4 ff ff       	call   80014c <_panic>

00800c82 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7f 08                	jg     800cad <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 06                	push   $0x6
  800cb3:	68 24 18 80 00       	push   $0x801824
  800cb8:	6a 23                	push   $0x23
  800cba:	68 41 18 80 00       	push   $0x801841
  800cbf:	e8 88 f4 ff ff       	call   80014c <_panic>

00800cc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7f 08                	jg     800cef <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 08                	push   $0x8
  800cf5:	68 24 18 80 00       	push   $0x801824
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 41 18 80 00       	push   $0x801841
  800d01:	e8 46 f4 ff ff       	call   80014c <_panic>

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7f 08                	jg     800d31 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 09                	push   $0x9
  800d37:	68 24 18 80 00       	push   $0x801824
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 41 18 80 00       	push   $0x801841
  800d43:	e8 04 f4 ff ff       	call   80014c <_panic>

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d59:	be 00 00 00 00       	mov    $0x0,%esi
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d64:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7f 08                	jg     800d95 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 0c                	push   $0xc
  800d9b:	68 24 18 80 00       	push   $0x801824
  800da0:	6a 23                	push   $0x23
  800da2:	68 41 18 80 00       	push   $0x801841
  800da7:	e8 a0 f3 ff ff       	call   80014c <_panic>

00800dac <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	void *addr = (void *)(pn * PGSIZE);
  800db1:	89 d6                	mov    %edx,%esi
  800db3:	c1 e6 0c             	shl    $0xc,%esi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800db6:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800dbd:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800dc4:	f6 c1 02             	test   $0x2,%cl
  800dc7:	75 0c                	jne    800dd5 <duppage+0x29>
  800dc9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd0:	f6 c6 08             	test   $0x8,%dh
  800dd3:	74 64                	je     800e39 <duppage+0x8d>
		perm &= ~PTE_W;
  800dd5:	81 e3 05 0e 00 00    	and    $0xe05,%ebx
		perm |= PTE_COW;
  800ddb:	80 cf 08             	or     $0x8,%bh
		int ret = sys_page_map(0, addr, envid, addr, perm);
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	53                   	push   %ebx
  800de2:	56                   	push   %esi
  800de3:	50                   	push   %eax
  800de4:	56                   	push   %esi
  800de5:	6a 00                	push   $0x0
  800de7:	e8 54 fe ff ff       	call   800c40 <sys_page_map>
		if (ret < 0) {
  800dec:	83 c4 20             	add    $0x20,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	78 22                	js     800e15 <duppage+0x69>
			panic("duppage: sys_page_map failed: %e", ret);
		}
		ret = sys_page_map(0, addr, 0, addr, perm);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	53                   	push   %ebx
  800df7:	56                   	push   %esi
  800df8:	6a 00                	push   $0x0
  800dfa:	56                   	push   %esi
  800dfb:	6a 00                	push   $0x0
  800dfd:	e8 3e fe ff ff       	call   800c40 <sys_page_map>
		if (ret < 0) {
  800e02:	83 c4 20             	add    $0x20,%esp
  800e05:	85 c0                	test   %eax,%eax
  800e07:	78 1e                	js     800e27 <duppage+0x7b>
		if (ret < 0) {
			panic("duppage: sys_page_map failed: %e", ret);
		}
	}
	return 0;
}
  800e09:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
			panic("duppage: sys_page_map failed: %e", ret);
  800e15:	50                   	push   %eax
  800e16:	68 50 18 80 00       	push   $0x801850
  800e1b:	6a 4f                	push   $0x4f
  800e1d:	68 b6 19 80 00       	push   $0x8019b6
  800e22:	e8 25 f3 ff ff       	call   80014c <_panic>
			panic("duppage: sys_page_map failed: %e", ret);
  800e27:	50                   	push   %eax
  800e28:	68 50 18 80 00       	push   $0x801850
  800e2d:	6a 53                	push   $0x53
  800e2f:	68 b6 19 80 00       	push   $0x8019b6
  800e34:	e8 13 f3 ff ff       	call   80014c <_panic>
		int ret = sys_page_map(0, addr, envid, addr, perm);
  800e39:	83 ec 0c             	sub    $0xc,%esp
	int perm = uvpt[pn] & PTE_SYSCALL;
  800e3c:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
		int ret = sys_page_map(0, addr, envid, addr, perm);
  800e42:	53                   	push   %ebx
  800e43:	56                   	push   %esi
  800e44:	50                   	push   %eax
  800e45:	56                   	push   %esi
  800e46:	6a 00                	push   $0x0
  800e48:	e8 f3 fd ff ff       	call   800c40 <sys_page_map>
		if (ret < 0) {
  800e4d:	83 c4 20             	add    $0x20,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	79 b5                	jns    800e09 <duppage+0x5d>
			panic("duppage: sys_page_map failed: %e", ret);
  800e54:	50                   	push   %eax
  800e55:	68 50 18 80 00       	push   $0x801850
  800e5a:	6a 58                	push   $0x58
  800e5c:	68 b6 19 80 00       	push   $0x8019b6
  800e61:	e8 e6 f2 ff ff       	call   80014c <_panic>

00800e66 <pgfault>:
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	53                   	push   %ebx
  800e6a:	83 ec 04             	sub    $0x4,%esp
  800e6d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e70:	8b 02                	mov    (%edx),%eax
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800e72:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e76:	74 7b                	je     800ef3 <pgfault+0x8d>
  800e78:	89 c2                	mov    %eax,%edx
  800e7a:	c1 ea 0c             	shr    $0xc,%edx
  800e7d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e84:	f6 c6 08             	test   $0x8,%dh
  800e87:	74 6a                	je     800ef3 <pgfault+0x8d>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e8e:	89 c3                	mov    %eax,%ebx
	int ret = sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P);
  800e90:	83 ec 04             	sub    $0x4,%esp
  800e93:	6a 07                	push   $0x7
  800e95:	68 00 f0 7f 00       	push   $0x7ff000
  800e9a:	6a 00                	push   $0x0
  800e9c:	e8 5c fd ff ff       	call   800bfd <sys_page_alloc>
	if (ret < 0) {
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 5f                	js     800f07 <pgfault+0xa1>
	memmove(PFTEMP, addr, PGSIZE);
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	68 00 10 00 00       	push   $0x1000
  800eb0:	53                   	push   %ebx
  800eb1:	68 00 f0 7f 00       	push   $0x7ff000
  800eb6:	e8 dc fa ff ff       	call   800997 <memmove>
	ret = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_W | PTE_P);
  800ebb:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ec2:	53                   	push   %ebx
  800ec3:	6a 00                	push   $0x0
  800ec5:	68 00 f0 7f 00       	push   $0x7ff000
  800eca:	6a 00                	push   $0x0
  800ecc:	e8 6f fd ff ff       	call   800c40 <sys_page_map>
	if (ret < 0) {
  800ed1:	83 c4 20             	add    $0x20,%esp
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	78 41                	js     800f19 <pgfault+0xb3>
	ret = sys_page_unmap(0, PFTEMP);
  800ed8:	83 ec 08             	sub    $0x8,%esp
  800edb:	68 00 f0 7f 00       	push   $0x7ff000
  800ee0:	6a 00                	push   $0x0
  800ee2:	e8 9b fd ff ff       	call   800c82 <sys_page_unmap>
	if (ret < 0) {
  800ee7:	83 c4 10             	add    $0x10,%esp
  800eea:	85 c0                	test   %eax,%eax
  800eec:	78 3d                	js     800f2b <pgfault+0xc5>
}
  800eee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    
		panic("pgfault: faulting access was not a write or to a copy-on-write page");
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 74 18 80 00       	push   $0x801874
  800efb:	6a 1d                	push   $0x1d
  800efd:	68 b6 19 80 00       	push   $0x8019b6
  800f02:	e8 45 f2 ff ff       	call   80014c <_panic>
		panic("pgfault: sys_page_alloc failed: %e", ret);
  800f07:	50                   	push   %eax
  800f08:	68 b8 18 80 00       	push   $0x8018b8
  800f0d:	6a 2a                	push   $0x2a
  800f0f:	68 b6 19 80 00       	push   $0x8019b6
  800f14:	e8 33 f2 ff ff       	call   80014c <_panic>
		panic("pgfault: sys_page_map failed: %e", ret);
  800f19:	50                   	push   %eax
  800f1a:	68 dc 18 80 00       	push   $0x8018dc
  800f1f:	6a 2f                	push   $0x2f
  800f21:	68 b6 19 80 00       	push   $0x8019b6
  800f26:	e8 21 f2 ff ff       	call   80014c <_panic>
		panic("pgfault: sys_page_unmap failed: %e", ret);
  800f2b:	50                   	push   %eax
  800f2c:	68 00 19 80 00       	push   $0x801900
  800f31:	6a 33                	push   $0x33
  800f33:	68 b6 19 80 00       	push   $0x8019b6
  800f38:	e8 0f f2 ff ff       	call   80014c <_panic>

00800f3d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  800f42:	83 ec 0c             	sub    $0xc,%esp
  800f45:	68 66 0e 80 00       	push   $0x800e66
  800f4a:	e8 56 03 00 00       	call   8012a5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f4f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f54:	cd 30                	int    $0x30
  800f56:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0) {
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 23                	js     800f82 <fork+0x45>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// parent process

	for (uintptr_t addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f5f:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f64:	75 3c                	jne    800fa2 <fork+0x65>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f66:	e8 54 fc ff ff       	call   800bbf <sys_getenvid>
  800f6b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f70:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f73:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f78:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800f7d:	e9 87 00 00 00       	jmp    801009 <fork+0xcc>
		panic("fork: sys_exofork failed: %e", envid);
  800f82:	50                   	push   %eax
  800f83:	68 c1 19 80 00       	push   $0x8019c1
  800f88:	6a 77                	push   $0x77
  800f8a:	68 b6 19 80 00       	push   $0x8019b6
  800f8f:	e8 b8 f1 ff ff       	call   80014c <_panic>
	for (uintptr_t addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f94:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fa0:	74 29                	je     800fcb <fork+0x8e>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)) {
  800fa2:	89 d8                	mov    %ebx,%eax
  800fa4:	c1 e8 16             	shr    $0x16,%eax
  800fa7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fae:	a8 01                	test   $0x1,%al
  800fb0:	74 e2                	je     800f94 <fork+0x57>
  800fb2:	89 da                	mov    %ebx,%edx
  800fb4:	c1 ea 0c             	shr    $0xc,%edx
  800fb7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800fbe:	a8 01                	test   $0x1,%al
  800fc0:	74 d2                	je     800f94 <fork+0x57>
			duppage(envid, PGNUM(addr));
  800fc2:	89 f0                	mov    %esi,%eax
  800fc4:	e8 e3 fd ff ff       	call   800dac <duppage>
  800fc9:	eb c9                	jmp    800f94 <fork+0x57>
		}
	}

	int ret = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	6a 07                	push   $0x7
  800fd0:	68 00 f0 bf ee       	push   $0xeebff000
  800fd5:	56                   	push   %esi
  800fd6:	e8 22 fc ff ff       	call   800bfd <sys_page_alloc>
	if (ret < 0) {
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 30                	js     801012 <fork+0xd5>
		panic("fork: sys_page_alloc failed: %e", ret);
	}

	ret = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fe2:	83 ec 08             	sub    $0x8,%esp
  800fe5:	68 10 13 80 00       	push   $0x801310
  800fea:	56                   	push   %esi
  800feb:	e8 16 fd ff ff       	call   800d06 <sys_env_set_pgfault_upcall>
	if (ret < 0) {
  800ff0:	83 c4 10             	add    $0x10,%esp
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 30                	js     801027 <fork+0xea>
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
	}

	ret = sys_env_set_status(envid, ENV_RUNNABLE);
  800ff7:	83 ec 08             	sub    $0x8,%esp
  800ffa:	6a 02                	push   $0x2
  800ffc:	56                   	push   %esi
  800ffd:	e8 c2 fc ff ff       	call   800cc4 <sys_env_set_status>
	if (ret < 0) {
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	78 33                	js     80103c <fork+0xff>
		panic("fork: sys_env_set_status failed: %e", ret);
	}
	return envid;
}
  801009:	89 f0                	mov    %esi,%eax
  80100b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    
		panic("fork: sys_page_alloc failed: %e", ret);
  801012:	50                   	push   %eax
  801013:	68 24 19 80 00       	push   $0x801924
  801018:	68 88 00 00 00       	push   $0x88
  80101d:	68 b6 19 80 00       	push   $0x8019b6
  801022:	e8 25 f1 ff ff       	call   80014c <_panic>
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
  801027:	50                   	push   %eax
  801028:	68 44 19 80 00       	push   $0x801944
  80102d:	68 8d 00 00 00       	push   $0x8d
  801032:	68 b6 19 80 00       	push   $0x8019b6
  801037:	e8 10 f1 ff ff       	call   80014c <_panic>
		panic("fork: sys_env_set_status failed: %e", ret);
  80103c:	50                   	push   %eax
  80103d:	68 70 19 80 00       	push   $0x801970
  801042:	68 92 00 00 00       	push   $0x92
  801047:	68 b6 19 80 00       	push   $0x8019b6
  80104c:	e8 fb f0 ff ff       	call   80014c <_panic>

00801051 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
	extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	68 66 0e 80 00       	push   $0x800e66
  80105e:	e8 42 02 00 00       	call   8012a5 <set_pgfault_handler>
  801063:	b8 07 00 00 00       	mov    $0x7,%eax
  801068:	cd 30                	int    $0x30
  80106a:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0) {
  80106c:	83 c4 10             	add    $0x10,%esp
  80106f:	85 c0                	test   %eax,%eax
  801071:	78 0d                	js     801080 <sfork+0x2f>
		panic("fork: sys_exofork failed: %e", envid);
	}
	if (envid == 0) {
  801073:	0f 84 dc 00 00 00    	je     801155 <sfork+0x104>
		// child process
		return 0;
	}
	// parent process

	for (uintptr_t addr = 0; addr < (USTACKTOP - PGSIZE); addr += PGSIZE) {
  801079:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107e:	eb 23                	jmp    8010a3 <sfork+0x52>
		panic("fork: sys_exofork failed: %e", envid);
  801080:	50                   	push   %eax
  801081:	68 c1 19 80 00       	push   $0x8019c1
  801086:	68 ac 00 00 00       	push   $0xac
  80108b:	68 b6 19 80 00       	push   $0x8019b6
  801090:	e8 b7 f0 ff ff       	call   80014c <_panic>
	for (uintptr_t addr = 0; addr < (USTACKTOP - PGSIZE); addr += PGSIZE) {
  801095:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80109b:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  8010a1:	74 68                	je     80110b <sfork+0xba>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  8010a3:	89 d8                	mov    %ebx,%eax
  8010a5:	c1 e8 16             	shr    $0x16,%eax
  8010a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010af:	a8 01                	test   $0x1,%al
  8010b1:	74 e2                	je     801095 <sfork+0x44>
  8010b3:	89 d8                	mov    %ebx,%eax
  8010b5:	c1 e8 0c             	shr    $0xc,%eax
  8010b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	74 d1                	je     801095 <sfork+0x44>
  8010c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010cb:	f6 c2 04             	test   $0x4,%dl
  8010ce:	74 c5                	je     801095 <sfork+0x44>
	void *addr = (void *)(pn * PGSIZE);
  8010d0:	89 c2                	mov    %eax,%edx
  8010d2:	c1 e2 0c             	shl    $0xc,%edx
	int perm = uvpt[pn] & PTE_SYSCALL;
  8010d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int ret = sys_page_map(0, addr, envid, addr, perm);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
	int perm = uvpt[pn] & PTE_SYSCALL;
  8010df:	25 07 0e 00 00       	and    $0xe07,%eax
	int ret = sys_page_map(0, addr, envid, addr, perm);
  8010e4:	50                   	push   %eax
  8010e5:	52                   	push   %edx
  8010e6:	56                   	push   %esi
  8010e7:	52                   	push   %edx
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 51 fb ff ff       	call   800c40 <sys_page_map>
	if (ret < 0) {
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 9f                	jns    801095 <sfork+0x44>
		panic("sduppage: sys_page_map failed: %e", ret);
  8010f6:	50                   	push   %eax
  8010f7:	68 94 19 80 00       	push   $0x801994
  8010fc:	68 9e 00 00 00       	push   $0x9e
  801101:	68 b6 19 80 00       	push   $0x8019b6
  801106:	e8 41 f0 ff ff       	call   80014c <_panic>
			sduppage(envid, PGNUM(addr));
		}
	}
	duppage(envid, PGNUM(USTACKTOP - PGSIZE));
  80110b:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  801110:	89 f0                	mov    %esi,%eax
  801112:	e8 95 fc ff ff       	call   800dac <duppage>

	int ret = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  801117:	83 ec 04             	sub    $0x4,%esp
  80111a:	6a 07                	push   $0x7
  80111c:	68 00 f0 bf ee       	push   $0xeebff000
  801121:	56                   	push   %esi
  801122:	e8 d6 fa ff ff       	call   800bfd <sys_page_alloc>
	if (ret < 0) {
  801127:	83 c4 10             	add    $0x10,%esp
  80112a:	85 c0                	test   %eax,%eax
  80112c:	78 30                	js     80115e <sfork+0x10d>
		panic("fork: sys_page_alloc failed: %e", ret);
	}

	ret = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80112e:	83 ec 08             	sub    $0x8,%esp
  801131:	68 10 13 80 00       	push   $0x801310
  801136:	56                   	push   %esi
  801137:	e8 ca fb ff ff       	call   800d06 <sys_env_set_pgfault_upcall>
	if (ret < 0) {
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 30                	js     801173 <sfork+0x122>
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
	}

	ret = sys_env_set_status(envid, ENV_RUNNABLE);
  801143:	83 ec 08             	sub    $0x8,%esp
  801146:	6a 02                	push   $0x2
  801148:	56                   	push   %esi
  801149:	e8 76 fb ff ff       	call   800cc4 <sys_env_set_status>
	if (ret < 0) {
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 33                	js     801188 <sfork+0x137>
		panic("fork: sys_env_set_status failed: %e", ret);
	}
	return envid;

  801155:	89 f0                	mov    %esi,%eax
  801157:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    
		panic("fork: sys_page_alloc failed: %e", ret);
  80115e:	50                   	push   %eax
  80115f:	68 24 19 80 00       	push   $0x801924
  801164:	68 bd 00 00 00       	push   $0xbd
  801169:	68 b6 19 80 00       	push   $0x8019b6
  80116e:	e8 d9 ef ff ff       	call   80014c <_panic>
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
  801173:	50                   	push   %eax
  801174:	68 44 19 80 00       	push   $0x801944
  801179:	68 c2 00 00 00       	push   $0xc2
  80117e:	68 b6 19 80 00       	push   $0x8019b6
  801183:	e8 c4 ef ff ff       	call   80014c <_panic>
		panic("fork: sys_env_set_status failed: %e", ret);
  801188:	50                   	push   %eax
  801189:	68 70 19 80 00       	push   $0x801970
  80118e:	68 c7 00 00 00       	push   $0xc7
  801193:	68 b6 19 80 00       	push   $0x8019b6
  801198:	e8 af ef ff ff       	call   80014c <_panic>

0080119d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
  8011a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) UTOP;
	} else {
		pg = ROUNDDOWN(pg, PGSIZE);
  8011ab:	89 d0                	mov    %edx,%eax
  8011ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b2:	85 d2                	test   %edx,%edx
  8011b4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011b9:	0f 44 c2             	cmove  %edx,%eax
	}
	int ret = sys_ipc_recv(pg);
  8011bc:	83 ec 0c             	sub    $0xc,%esp
  8011bf:	50                   	push   %eax
  8011c0:	e8 a6 fb ff ff       	call   800d6b <sys_ipc_recv>
	if (ret < 0) {
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 2e                	js     8011fa <ipc_recv+0x5d>
			*perm_store = 0;
		}
		return ret;
	}
	// uncomment this line if you want to do the `sfork` challenge
	const volatile struct Env *thisenv = envs + ENVX(sys_getenvid());
  8011cc:	e8 ee f9 ff ff       	call   800bbf <sys_getenvid>
  8011d1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011d9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
	
	if (from_env_store != NULL) {
  8011de:	85 f6                	test   %esi,%esi
  8011e0:	74 05                	je     8011e7 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  8011e2:	8b 50 74             	mov    0x74(%eax),%edx
  8011e5:	89 16                	mov    %edx,(%esi)
	}
	if (perm_store != NULL) {
  8011e7:	85 db                	test   %ebx,%ebx
  8011e9:	74 05                	je     8011f0 <ipc_recv+0x53>
		*perm_store = thisenv->env_ipc_perm;
  8011eb:	8b 50 78             	mov    0x78(%eax),%edx
  8011ee:	89 13                	mov    %edx,(%ebx)
	}
	return thisenv->env_ipc_value;
  8011f0:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f6:	5b                   	pop    %ebx
  8011f7:	5e                   	pop    %esi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    
		if (from_env_store != NULL) {
  8011fa:	85 f6                	test   %esi,%esi
  8011fc:	74 06                	je     801204 <ipc_recv+0x67>
			*from_env_store = 0;
  8011fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  801204:	85 db                	test   %ebx,%ebx
  801206:	74 eb                	je     8011f3 <ipc_recv+0x56>
			*perm_store = 0;
  801208:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80120e:	eb e3                	jmp    8011f3 <ipc_recv+0x56>

00801210 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	8b 7d 08             	mov    0x8(%ebp),%edi
  80121c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80121f:	8b 45 10             	mov    0x10(%ebp),%eax
	if (pg == NULL) {
		pg = (void *) UTOP;
	} else {
		pg = ROUNDDOWN(pg, PGSIZE);
  801222:	89 c3                	mov    %eax,%ebx
  801224:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  80122a:	85 c0                	test   %eax,%eax
  80122c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801231:	0f 44 d8             	cmove  %eax,%ebx
	}
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801234:	ff 75 14             	push   0x14(%ebp)
  801237:	53                   	push   %ebx
  801238:	56                   	push   %esi
  801239:	57                   	push   %edi
  80123a:	e8 09 fb ff ff       	call   800d48 <sys_ipc_try_send>
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	79 1e                	jns    801264 <ipc_send+0x54>
		if (ret != -E_IPC_NOT_RECV) {
  801246:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801249:	75 07                	jne    801252 <ipc_send+0x42>
			panic("ipc_send: %e", ret);
		}
		sys_yield();
  80124b:	e8 8e f9 ff ff       	call   800bde <sys_yield>
  801250:	eb e2                	jmp    801234 <ipc_send+0x24>
			panic("ipc_send: %e", ret);
  801252:	50                   	push   %eax
  801253:	68 de 19 80 00       	push   $0x8019de
  801258:	6a 48                	push   $0x48
  80125a:	68 eb 19 80 00       	push   $0x8019eb
  80125f:	e8 e8 ee ff ff       	call   80014c <_panic>
	}
}
  801264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5f                   	pop    %edi
  80126a:	5d                   	pop    %ebp
  80126b:	c3                   	ret    

0080126c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801272:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801277:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80127a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801280:	8b 52 50             	mov    0x50(%edx),%edx
  801283:	39 ca                	cmp    %ecx,%edx
  801285:	74 11                	je     801298 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801287:	83 c0 01             	add    $0x1,%eax
  80128a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80128f:	75 e6                	jne    801277 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb 0b                	jmp    8012a3 <ipc_find_env+0x37>
			return envs[i].env_id;
  801298:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80129b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8012a3:	5d                   	pop    %ebp
  8012a4:	c3                   	ret    

008012a5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012a5:	55                   	push   %ebp
  8012a6:	89 e5                	mov    %esp,%ebp
  8012a8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012ab:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8012b2:	74 0a                	je     8012be <set_pgfault_handler+0x19>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed: %e", ret);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b7:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    
		int ret = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8012be:	83 ec 04             	sub    $0x4,%esp
  8012c1:	6a 07                	push   $0x7
  8012c3:	68 00 f0 bf ee       	push   $0xeebff000
  8012c8:	6a 00                	push   $0x0
  8012ca:	e8 2e f9 ff ff       	call   800bfd <sys_page_alloc>
		if (ret < 0) {
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 28                	js     8012fe <set_pgfault_handler+0x59>
		ret = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	68 10 13 80 00       	push   $0x801310
  8012de:	6a 00                	push   $0x0
  8012e0:	e8 21 fa ff ff       	call   800d06 <sys_env_set_pgfault_upcall>
		if (ret < 0) {
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	79 c8                	jns    8012b4 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed: %e", ret);
  8012ec:	50                   	push   %eax
  8012ed:	68 28 1a 80 00       	push   $0x801a28
  8012f2:	6a 26                	push   $0x26
  8012f4:	68 63 1a 80 00       	push   $0x801a63
  8012f9:	e8 4e ee ff ff       	call   80014c <_panic>
			panic("set_pgfault_handler: sys_page_alloc failed: %e", ret);
  8012fe:	50                   	push   %eax
  8012ff:	68 f8 19 80 00       	push   $0x8019f8
  801304:	6a 22                	push   $0x22
  801306:	68 63 1a 80 00       	push   $0x801a63
  80130b:	e8 3c ee ff ff       	call   80014c <_panic>

00801310 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801310:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801311:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801316:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801318:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80131b:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  801320:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %edx
  801324:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801328:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  80132a:	83 c4 08             	add    $0x8,%esp
	popal
  80132d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  80132e:	83 c4 04             	add    $0x4,%esp
	popfl
  801331:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801332:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801333:	c3                   	ret    
  801334:	66 90                	xchg   %ax,%ax
  801336:	66 90                	xchg   %ax,%ax
  801338:	66 90                	xchg   %ax,%ax
  80133a:	66 90                	xchg   %ax,%ax
  80133c:	66 90                	xchg   %ax,%ax
  80133e:	66 90                	xchg   %ax,%ax

00801340 <__udivdi3>:
  801340:	f3 0f 1e fb          	endbr32 
  801344:	55                   	push   %ebp
  801345:	57                   	push   %edi
  801346:	56                   	push   %esi
  801347:	53                   	push   %ebx
  801348:	83 ec 1c             	sub    $0x1c,%esp
  80134b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80134f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801353:	8b 74 24 34          	mov    0x34(%esp),%esi
  801357:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80135b:	85 c0                	test   %eax,%eax
  80135d:	75 19                	jne    801378 <__udivdi3+0x38>
  80135f:	39 f3                	cmp    %esi,%ebx
  801361:	76 4d                	jbe    8013b0 <__udivdi3+0x70>
  801363:	31 ff                	xor    %edi,%edi
  801365:	89 e8                	mov    %ebp,%eax
  801367:	89 f2                	mov    %esi,%edx
  801369:	f7 f3                	div    %ebx
  80136b:	89 fa                	mov    %edi,%edx
  80136d:	83 c4 1c             	add    $0x1c,%esp
  801370:	5b                   	pop    %ebx
  801371:	5e                   	pop    %esi
  801372:	5f                   	pop    %edi
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    
  801375:	8d 76 00             	lea    0x0(%esi),%esi
  801378:	39 f0                	cmp    %esi,%eax
  80137a:	76 14                	jbe    801390 <__udivdi3+0x50>
  80137c:	31 ff                	xor    %edi,%edi
  80137e:	31 c0                	xor    %eax,%eax
  801380:	89 fa                	mov    %edi,%edx
  801382:	83 c4 1c             	add    $0x1c,%esp
  801385:	5b                   	pop    %ebx
  801386:	5e                   	pop    %esi
  801387:	5f                   	pop    %edi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    
  80138a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801390:	0f bd f8             	bsr    %eax,%edi
  801393:	83 f7 1f             	xor    $0x1f,%edi
  801396:	75 48                	jne    8013e0 <__udivdi3+0xa0>
  801398:	39 f0                	cmp    %esi,%eax
  80139a:	72 06                	jb     8013a2 <__udivdi3+0x62>
  80139c:	31 c0                	xor    %eax,%eax
  80139e:	39 eb                	cmp    %ebp,%ebx
  8013a0:	77 de                	ja     801380 <__udivdi3+0x40>
  8013a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a7:	eb d7                	jmp    801380 <__udivdi3+0x40>
  8013a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	89 d9                	mov    %ebx,%ecx
  8013b2:	85 db                	test   %ebx,%ebx
  8013b4:	75 0b                	jne    8013c1 <__udivdi3+0x81>
  8013b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013bb:	31 d2                	xor    %edx,%edx
  8013bd:	f7 f3                	div    %ebx
  8013bf:	89 c1                	mov    %eax,%ecx
  8013c1:	31 d2                	xor    %edx,%edx
  8013c3:	89 f0                	mov    %esi,%eax
  8013c5:	f7 f1                	div    %ecx
  8013c7:	89 c6                	mov    %eax,%esi
  8013c9:	89 e8                	mov    %ebp,%eax
  8013cb:	89 f7                	mov    %esi,%edi
  8013cd:	f7 f1                	div    %ecx
  8013cf:	89 fa                	mov    %edi,%edx
  8013d1:	83 c4 1c             	add    $0x1c,%esp
  8013d4:	5b                   	pop    %ebx
  8013d5:	5e                   	pop    %esi
  8013d6:	5f                   	pop    %edi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    
  8013d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013e0:	89 f9                	mov    %edi,%ecx
  8013e2:	ba 20 00 00 00       	mov    $0x20,%edx
  8013e7:	29 fa                	sub    %edi,%edx
  8013e9:	d3 e0                	shl    %cl,%eax
  8013eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ef:	89 d1                	mov    %edx,%ecx
  8013f1:	89 d8                	mov    %ebx,%eax
  8013f3:	d3 e8                	shr    %cl,%eax
  8013f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013f9:	09 c1                	or     %eax,%ecx
  8013fb:	89 f0                	mov    %esi,%eax
  8013fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801401:	89 f9                	mov    %edi,%ecx
  801403:	d3 e3                	shl    %cl,%ebx
  801405:	89 d1                	mov    %edx,%ecx
  801407:	d3 e8                	shr    %cl,%eax
  801409:	89 f9                	mov    %edi,%ecx
  80140b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80140f:	89 eb                	mov    %ebp,%ebx
  801411:	d3 e6                	shl    %cl,%esi
  801413:	89 d1                	mov    %edx,%ecx
  801415:	d3 eb                	shr    %cl,%ebx
  801417:	09 f3                	or     %esi,%ebx
  801419:	89 c6                	mov    %eax,%esi
  80141b:	89 f2                	mov    %esi,%edx
  80141d:	89 d8                	mov    %ebx,%eax
  80141f:	f7 74 24 08          	divl   0x8(%esp)
  801423:	89 d6                	mov    %edx,%esi
  801425:	89 c3                	mov    %eax,%ebx
  801427:	f7 64 24 0c          	mull   0xc(%esp)
  80142b:	39 d6                	cmp    %edx,%esi
  80142d:	72 19                	jb     801448 <__udivdi3+0x108>
  80142f:	89 f9                	mov    %edi,%ecx
  801431:	d3 e5                	shl    %cl,%ebp
  801433:	39 c5                	cmp    %eax,%ebp
  801435:	73 04                	jae    80143b <__udivdi3+0xfb>
  801437:	39 d6                	cmp    %edx,%esi
  801439:	74 0d                	je     801448 <__udivdi3+0x108>
  80143b:	89 d8                	mov    %ebx,%eax
  80143d:	31 ff                	xor    %edi,%edi
  80143f:	e9 3c ff ff ff       	jmp    801380 <__udivdi3+0x40>
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80144b:	31 ff                	xor    %edi,%edi
  80144d:	e9 2e ff ff ff       	jmp    801380 <__udivdi3+0x40>
  801452:	66 90                	xchg   %ax,%ax
  801454:	66 90                	xchg   %ax,%ax
  801456:	66 90                	xchg   %ax,%ax
  801458:	66 90                	xchg   %ax,%ax
  80145a:	66 90                	xchg   %ax,%ax
  80145c:	66 90                	xchg   %ax,%ax
  80145e:	66 90                	xchg   %ax,%ax

00801460 <__umoddi3>:
  801460:	f3 0f 1e fb          	endbr32 
  801464:	55                   	push   %ebp
  801465:	57                   	push   %edi
  801466:	56                   	push   %esi
  801467:	53                   	push   %ebx
  801468:	83 ec 1c             	sub    $0x1c,%esp
  80146b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80146f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801473:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801477:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80147b:	89 f0                	mov    %esi,%eax
  80147d:	89 da                	mov    %ebx,%edx
  80147f:	85 ff                	test   %edi,%edi
  801481:	75 15                	jne    801498 <__umoddi3+0x38>
  801483:	39 dd                	cmp    %ebx,%ebp
  801485:	76 39                	jbe    8014c0 <__umoddi3+0x60>
  801487:	f7 f5                	div    %ebp
  801489:	89 d0                	mov    %edx,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	83 c4 1c             	add    $0x1c,%esp
  801490:	5b                   	pop    %ebx
  801491:	5e                   	pop    %esi
  801492:	5f                   	pop    %edi
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    
  801495:	8d 76 00             	lea    0x0(%esi),%esi
  801498:	39 df                	cmp    %ebx,%edi
  80149a:	77 f1                	ja     80148d <__umoddi3+0x2d>
  80149c:	0f bd cf             	bsr    %edi,%ecx
  80149f:	83 f1 1f             	xor    $0x1f,%ecx
  8014a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014a6:	75 40                	jne    8014e8 <__umoddi3+0x88>
  8014a8:	39 df                	cmp    %ebx,%edi
  8014aa:	72 04                	jb     8014b0 <__umoddi3+0x50>
  8014ac:	39 f5                	cmp    %esi,%ebp
  8014ae:	77 dd                	ja     80148d <__umoddi3+0x2d>
  8014b0:	89 da                	mov    %ebx,%edx
  8014b2:	89 f0                	mov    %esi,%eax
  8014b4:	29 e8                	sub    %ebp,%eax
  8014b6:	19 fa                	sbb    %edi,%edx
  8014b8:	eb d3                	jmp    80148d <__umoddi3+0x2d>
  8014ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014c0:	89 e9                	mov    %ebp,%ecx
  8014c2:	85 ed                	test   %ebp,%ebp
  8014c4:	75 0b                	jne    8014d1 <__umoddi3+0x71>
  8014c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014cb:	31 d2                	xor    %edx,%edx
  8014cd:	f7 f5                	div    %ebp
  8014cf:	89 c1                	mov    %eax,%ecx
  8014d1:	89 d8                	mov    %ebx,%eax
  8014d3:	31 d2                	xor    %edx,%edx
  8014d5:	f7 f1                	div    %ecx
  8014d7:	89 f0                	mov    %esi,%eax
  8014d9:	f7 f1                	div    %ecx
  8014db:	89 d0                	mov    %edx,%eax
  8014dd:	31 d2                	xor    %edx,%edx
  8014df:	eb ac                	jmp    80148d <__umoddi3+0x2d>
  8014e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014ec:	ba 20 00 00 00       	mov    $0x20,%edx
  8014f1:	29 c2                	sub    %eax,%edx
  8014f3:	89 c1                	mov    %eax,%ecx
  8014f5:	89 e8                	mov    %ebp,%eax
  8014f7:	d3 e7                	shl    %cl,%edi
  8014f9:	89 d1                	mov    %edx,%ecx
  8014fb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014ff:	d3 e8                	shr    %cl,%eax
  801501:	89 c1                	mov    %eax,%ecx
  801503:	8b 44 24 04          	mov    0x4(%esp),%eax
  801507:	09 f9                	or     %edi,%ecx
  801509:	89 df                	mov    %ebx,%edi
  80150b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80150f:	89 c1                	mov    %eax,%ecx
  801511:	d3 e5                	shl    %cl,%ebp
  801513:	89 d1                	mov    %edx,%ecx
  801515:	d3 ef                	shr    %cl,%edi
  801517:	89 c1                	mov    %eax,%ecx
  801519:	89 f0                	mov    %esi,%eax
  80151b:	d3 e3                	shl    %cl,%ebx
  80151d:	89 d1                	mov    %edx,%ecx
  80151f:	89 fa                	mov    %edi,%edx
  801521:	d3 e8                	shr    %cl,%eax
  801523:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801528:	09 d8                	or     %ebx,%eax
  80152a:	f7 74 24 08          	divl   0x8(%esp)
  80152e:	89 d3                	mov    %edx,%ebx
  801530:	d3 e6                	shl    %cl,%esi
  801532:	f7 e5                	mul    %ebp
  801534:	89 c7                	mov    %eax,%edi
  801536:	89 d1                	mov    %edx,%ecx
  801538:	39 d3                	cmp    %edx,%ebx
  80153a:	72 06                	jb     801542 <__umoddi3+0xe2>
  80153c:	75 0e                	jne    80154c <__umoddi3+0xec>
  80153e:	39 c6                	cmp    %eax,%esi
  801540:	73 0a                	jae    80154c <__umoddi3+0xec>
  801542:	29 e8                	sub    %ebp,%eax
  801544:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801548:	89 d1                	mov    %edx,%ecx
  80154a:	89 c7                	mov    %eax,%edi
  80154c:	89 f5                	mov    %esi,%ebp
  80154e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801552:	29 fd                	sub    %edi,%ebp
  801554:	19 cb                	sbb    %ecx,%ebx
  801556:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80155b:	89 d8                	mov    %ebx,%eax
  80155d:	d3 e0                	shl    %cl,%eax
  80155f:	89 f1                	mov    %esi,%ecx
  801561:	d3 ed                	shr    %cl,%ebp
  801563:	d3 eb                	shr    %cl,%ebx
  801565:	09 e8                	or     %ebp,%eax
  801567:	89 da                	mov    %ebx,%edx
  801569:	83 c4 1c             	add    $0x1c,%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5e                   	pop    %esi
  80156e:	5f                   	pop    %edi
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

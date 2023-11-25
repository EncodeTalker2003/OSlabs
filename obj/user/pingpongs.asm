
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 d9 0f 00 00       	call   80101a <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 0e 11 00 00       	call   801166 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 04 20 80 00       	mov    0x802004,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 17 0b 00 00       	call   800b88 <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	push   -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 d0 15 80 00       	push   $0x8015d0
  800080:	e8 6b 01 00 00       	call   8001f0 <cprintf>
		if (val == 10)
  800085:	a1 04 20 80 00       	mov    0x802004,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	push   -0x1c(%ebp)
  8000a3:	e8 31 11 00 00       	call   8011d9 <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c2:	e8 c1 0a 00 00       	call   800b88 <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 a0 15 80 00       	push   $0x8015a0
  8000d1:	e8 1a 01 00 00       	call   8001f0 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 aa 0a 00 00       	call   800b88 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 ba 15 80 00       	push   $0x8015ba
  8000e8:	e8 03 01 00 00       	call   8001f0 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	push   -0x1c(%ebp)
  8000f6:	e8 de 10 00 00       	call   8011d9 <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80010e:	e8 75 0a 00 00       	call   800b88 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 db                	test   %ebx,%ebx
  800127:	7e 07                	jle    800130 <libmain+0x2d>
		binaryname = argv[0];
  800129:	8b 06                	mov    (%esi),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
  800135:	e8 f9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013a:	e8 0a 00 00 00       	call   800149 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014f:	6a 00                	push   $0x0
  800151:	e8 f1 09 00 00       	call   800b47 <sys_env_destroy>
}
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	74 09                	je     800183 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 76 09 00 00       	call   800b0a <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb db                	jmp    80017a <putch+0x1f>

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	ff 75 0c             	push   0xc(%ebp)
  8001bf:	ff 75 08             	push   0x8(%ebp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	68 5b 01 80 00       	push   $0x80015b
  8001ce:	e8 14 01 00 00       	call   8002e7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d3:	83 c4 08             	add    $0x8,%esp
  8001d6:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 22 09 00 00       	call   800b0a <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	push   0x8(%ebp)
  8001fd:	e8 9d ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 d1                	mov    %edx,%ecx
  800219:	89 c2                	mov    %eax,%edx
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800221:	8b 45 10             	mov    0x10(%ebp),%eax
  800224:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800227:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800231:	39 c2                	cmp    %eax,%edx
  800233:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800236:	72 3e                	jb     800276 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	ff 75 18             	push   0x18(%ebp)
  80023e:	83 eb 01             	sub    $0x1,%ebx
  800241:	53                   	push   %ebx
  800242:	50                   	push   %eax
  800243:	83 ec 08             	sub    $0x8,%esp
  800246:	ff 75 e4             	push   -0x1c(%ebp)
  800249:	ff 75 e0             	push   -0x20(%ebp)
  80024c:	ff 75 dc             	push   -0x24(%ebp)
  80024f:	ff 75 d8             	push   -0x28(%ebp)
  800252:	e8 f9 10 00 00       	call   801350 <__udivdi3>
  800257:	83 c4 18             	add    $0x18,%esp
  80025a:	52                   	push   %edx
  80025b:	50                   	push   %eax
  80025c:	89 f2                	mov    %esi,%edx
  80025e:	89 f8                	mov    %edi,%eax
  800260:	e8 9f ff ff ff       	call   800204 <printnum>
  800265:	83 c4 20             	add    $0x20,%esp
  800268:	eb 13                	jmp    80027d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	56                   	push   %esi
  80026e:	ff 75 18             	push   0x18(%ebp)
  800271:	ff d7                	call   *%edi
  800273:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800276:	83 eb 01             	sub    $0x1,%ebx
  800279:	85 db                	test   %ebx,%ebx
  80027b:	7f ed                	jg     80026a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	56                   	push   %esi
  800281:	83 ec 04             	sub    $0x4,%esp
  800284:	ff 75 e4             	push   -0x1c(%ebp)
  800287:	ff 75 e0             	push   -0x20(%ebp)
  80028a:	ff 75 dc             	push   -0x24(%ebp)
  80028d:	ff 75 d8             	push   -0x28(%ebp)
  800290:	e8 db 11 00 00       	call   801470 <__umoddi3>
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	0f be 80 00 16 80 00 	movsbl 0x801600(%eax),%eax
  80029f:	50                   	push   %eax
  8002a0:	ff d7                	call   *%edi
}
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b7:	8b 10                	mov    (%eax),%edx
  8002b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bc:	73 0a                	jae    8002c8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c1:	89 08                	mov    %ecx,(%eax)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	88 02                	mov    %al,(%edx)
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <printfmt>:
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 10             	push   0x10(%ebp)
  8002d7:	ff 75 0c             	push   0xc(%ebp)
  8002da:	ff 75 08             	push   0x8(%ebp)
  8002dd:	e8 05 00 00 00       	call   8002e7 <vprintfmt>
}
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	c9                   	leave  
  8002e6:	c3                   	ret    

008002e7 <vprintfmt>:
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 3c             	sub    $0x3c,%esp
  8002f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f9:	eb 0a                	jmp    800305 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	53                   	push   %ebx
  8002ff:	50                   	push   %eax
  800300:	ff d6                	call   *%esi
  800302:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800305:	83 c7 01             	add    $0x1,%edi
  800308:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030c:	83 f8 25             	cmp    $0x25,%eax
  80030f:	74 0c                	je     80031d <vprintfmt+0x36>
			if (ch == '\0')
  800311:	85 c0                	test   %eax,%eax
  800313:	75 e6                	jne    8002fb <vprintfmt+0x14>
}
  800315:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    
		padc = ' ';
  80031d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800321:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800328:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8d 47 01             	lea    0x1(%edi),%eax
  80033e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800341:	0f b6 17             	movzbl (%edi),%edx
  800344:	8d 42 dd             	lea    -0x23(%edx),%eax
  800347:	3c 55                	cmp    $0x55,%al
  800349:	0f 87 bb 03 00 00    	ja     80070a <vprintfmt+0x423>
  80034f:	0f b6 c0             	movzbl %al,%eax
  800352:	ff 24 85 c0 16 80 00 	jmp    *0x8016c0(,%eax,4)
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80035c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800360:	eb d9                	jmp    80033b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800365:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800369:	eb d0                	jmp    80033b <vprintfmt+0x54>
  80036b:	0f b6 d2             	movzbl %dl,%edx
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800383:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800386:	83 f9 09             	cmp    $0x9,%ecx
  800389:	77 55                	ja     8003e0 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 40 04             	lea    0x4(%eax),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a8:	79 91                	jns    80033b <vprintfmt+0x54>
				width = precision, precision = -1;
  8003aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003b7:	eb 82                	jmp    80033b <vprintfmt+0x54>
  8003b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c3:	0f 49 c2             	cmovns %edx,%eax
  8003c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cc:	e9 6a ff ff ff       	jmp    80033b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003db:	e9 5b ff ff ff       	jmp    80033b <vprintfmt+0x54>
  8003e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e6:	eb bc                	jmp    8003a4 <vprintfmt+0xbd>
			lflag++;
  8003e8:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ee:	e9 48 ff ff ff       	jmp    80033b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 78 04             	lea    0x4(%eax),%edi
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	53                   	push   %ebx
  8003fd:	ff 30                	push   (%eax)
  8003ff:	ff d6                	call   *%esi
			break;
  800401:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800404:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800407:	e9 9d 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	8b 10                	mov    (%eax),%edx
  800414:	89 d0                	mov    %edx,%eax
  800416:	f7 d8                	neg    %eax
  800418:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041b:	83 f8 08             	cmp    $0x8,%eax
  80041e:	7f 23                	jg     800443 <vprintfmt+0x15c>
  800420:	8b 14 85 20 18 80 00 	mov    0x801820(,%eax,4),%edx
  800427:	85 d2                	test   %edx,%edx
  800429:	74 18                	je     800443 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80042b:	52                   	push   %edx
  80042c:	68 21 16 80 00       	push   $0x801621
  800431:	53                   	push   %ebx
  800432:	56                   	push   %esi
  800433:	e8 92 fe ff ff       	call   8002ca <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80043e:	e9 66 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800443:	50                   	push   %eax
  800444:	68 18 16 80 00       	push   $0x801618
  800449:	53                   	push   %ebx
  80044a:	56                   	push   %esi
  80044b:	e8 7a fe ff ff       	call   8002ca <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800456:	e9 4e 02 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	83 c0 04             	add    $0x4,%eax
  800461:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800464:	8b 45 14             	mov    0x14(%ebp),%eax
  800467:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800469:	85 d2                	test   %edx,%edx
  80046b:	b8 11 16 80 00       	mov    $0x801611,%eax
  800470:	0f 45 c2             	cmovne %edx,%eax
  800473:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800476:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047a:	7e 06                	jle    800482 <vprintfmt+0x19b>
  80047c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800480:	75 0d                	jne    80048f <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800485:	89 c7                	mov    %eax,%edi
  800487:	03 45 e0             	add    -0x20(%ebp),%eax
  80048a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048d:	eb 55                	jmp    8004e4 <vprintfmt+0x1fd>
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 d8             	push   -0x28(%ebp)
  800495:	ff 75 cc             	push   -0x34(%ebp)
  800498:	e8 0a 03 00 00       	call   8007a7 <strnlen>
  80049d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a0:	29 c1                	sub    %eax,%ecx
  8004a2:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004aa:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	eb 0f                	jmp    8004c2 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	ff 75 e0             	push   -0x20(%ebp)
  8004ba:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	83 ef 01             	sub    $0x1,%edi
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	7f ed                	jg     8004b3 <vprintfmt+0x1cc>
  8004c6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004c9:	85 d2                	test   %edx,%edx
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	0f 49 c2             	cmovns %edx,%eax
  8004d3:	29 c2                	sub    %eax,%edx
  8004d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004d8:	eb a8                	jmp    800482 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	53                   	push   %ebx
  8004de:	52                   	push   %edx
  8004df:	ff d6                	call   *%esi
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e7:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	83 c7 01             	add    $0x1,%edi
  8004ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f0:	0f be d0             	movsbl %al,%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	74 4b                	je     800542 <vprintfmt+0x25b>
  8004f7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fb:	78 06                	js     800503 <vprintfmt+0x21c>
  8004fd:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800501:	78 1e                	js     800521 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800503:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800507:	74 d1                	je     8004da <vprintfmt+0x1f3>
  800509:	0f be c0             	movsbl %al,%eax
  80050c:	83 e8 20             	sub    $0x20,%eax
  80050f:	83 f8 5e             	cmp    $0x5e,%eax
  800512:	76 c6                	jbe    8004da <vprintfmt+0x1f3>
					putch('?', putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	6a 3f                	push   $0x3f
  80051a:	ff d6                	call   *%esi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb c3                	jmp    8004e4 <vprintfmt+0x1fd>
  800521:	89 cf                	mov    %ecx,%edi
  800523:	eb 0e                	jmp    800533 <vprintfmt+0x24c>
				putch(' ', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	53                   	push   %ebx
  800529:	6a 20                	push   $0x20
  80052b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80052d:	83 ef 01             	sub    $0x1,%edi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	85 ff                	test   %edi,%edi
  800535:	7f ee                	jg     800525 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	e9 67 01 00 00       	jmp    8006a9 <vprintfmt+0x3c2>
  800542:	89 cf                	mov    %ecx,%edi
  800544:	eb ed                	jmp    800533 <vprintfmt+0x24c>
	if (lflag >= 2)
  800546:	83 f9 01             	cmp    $0x1,%ecx
  800549:	7f 1b                	jg     800566 <vprintfmt+0x27f>
	else if (lflag)
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	74 63                	je     8005b2 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8b 00                	mov    (%eax),%eax
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	99                   	cltd   
  800558:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8d 40 04             	lea    0x4(%eax),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
  800564:	eb 17                	jmp    80057d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 50 04             	mov    0x4(%eax),%edx
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 08             	lea    0x8(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80057d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800580:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800583:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800588:	85 c9                	test   %ecx,%ecx
  80058a:	0f 89 ff 00 00 00    	jns    80068f <vprintfmt+0x3a8>
				putch('-', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	53                   	push   %ebx
  800594:	6a 2d                	push   $0x2d
  800596:	ff d6                	call   *%esi
				num = -(long long) num;
  800598:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059e:	f7 da                	neg    %edx
  8005a0:	83 d1 00             	adc    $0x0,%ecx
  8005a3:	f7 d9                	neg    %ecx
  8005a5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a8:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005ad:	e9 dd 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	99                   	cltd   
  8005bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 40 04             	lea    0x4(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c7:	eb b4                	jmp    80057d <vprintfmt+0x296>
	if (lflag >= 2)
  8005c9:	83 f9 01             	cmp    $0x1,%ecx
  8005cc:	7f 1e                	jg     8005ec <vprintfmt+0x305>
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 32                	je     800604 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dc:	8d 40 04             	lea    0x4(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005e7:	e9 a3 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 10                	mov    (%eax),%edx
  8005f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f4:	8d 40 08             	lea    0x8(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fa:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005ff:	e9 8b 00 00 00       	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800614:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800619:	eb 74                	jmp    80068f <vprintfmt+0x3a8>
	if (lflag >= 2)
  80061b:	83 f9 01             	cmp    $0x1,%ecx
  80061e:	7f 1b                	jg     80063b <vprintfmt+0x354>
	else if (lflag)
  800620:	85 c9                	test   %ecx,%ecx
  800622:	74 2c                	je     800650 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 10                	mov    (%eax),%edx
  800629:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800634:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800639:	eb 54                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	8b 48 04             	mov    0x4(%eax),%ecx
  800643:	8d 40 08             	lea    0x8(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800649:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80064e:	eb 3f                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065a:	8d 40 04             	lea    0x4(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800660:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800665:	eb 28                	jmp    80068f <vprintfmt+0x3a8>
			putch('0', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 30                	push   $0x30
  80066d:	ff d6                	call   *%esi
			putch('x', putdat);
  80066f:	83 c4 08             	add    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 78                	push   $0x78
  800675:	ff d6                	call   *%esi
			num = (unsigned long long)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800681:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068a:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800696:	50                   	push   %eax
  800697:	ff 75 e0             	push   -0x20(%ebp)
  80069a:	57                   	push   %edi
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	89 da                	mov    %ebx,%edx
  80069f:	89 f0                	mov    %esi,%eax
  8006a1:	e8 5e fb ff ff       	call   800204 <printnum>
			break;
  8006a6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006ac:	e9 54 fc ff ff       	jmp    800305 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006b1:	83 f9 01             	cmp    $0x1,%ecx
  8006b4:	7f 1b                	jg     8006d1 <vprintfmt+0x3ea>
	else if (lflag)
  8006b6:	85 c9                	test   %ecx,%ecx
  8006b8:	74 2c                	je     8006e6 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8b 10                	mov    (%eax),%edx
  8006bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006cf:	eb be                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d9:	8d 40 08             	lea    0x8(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006df:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006e4:	eb a9                	jmp    80068f <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006fb:	eb 92                	jmp    80068f <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	6a 25                	push   $0x25
  800703:	ff d6                	call   *%esi
			break;
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb 9f                	jmp    8006a9 <vprintfmt+0x3c2>
			putch('%', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	6a 25                	push   $0x25
  800710:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	89 f8                	mov    %edi,%eax
  800717:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80071b:	74 05                	je     800722 <vprintfmt+0x43b>
  80071d:	83 e8 01             	sub    $0x1,%eax
  800720:	eb f5                	jmp    800717 <vprintfmt+0x430>
  800722:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800725:	eb 82                	jmp    8006a9 <vprintfmt+0x3c2>

00800727 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 18             	sub    $0x18,%esp
  80072d:	8b 45 08             	mov    0x8(%ebp),%eax
  800730:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800733:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800736:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800744:	85 c0                	test   %eax,%eax
  800746:	74 26                	je     80076e <vsnprintf+0x47>
  800748:	85 d2                	test   %edx,%edx
  80074a:	7e 22                	jle    80076e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074c:	ff 75 14             	push   0x14(%ebp)
  80074f:	ff 75 10             	push   0x10(%ebp)
  800752:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	68 ad 02 80 00       	push   $0x8002ad
  80075b:	e8 87 fb ff ff       	call   8002e7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800760:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800763:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800766:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800769:	83 c4 10             	add    $0x10,%esp
}
  80076c:	c9                   	leave  
  80076d:	c3                   	ret    
		return -E_INVAL;
  80076e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800773:	eb f7                	jmp    80076c <vsnprintf+0x45>

00800775 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077e:	50                   	push   %eax
  80077f:	ff 75 10             	push   0x10(%ebp)
  800782:	ff 75 0c             	push   0xc(%ebp)
  800785:	ff 75 08             	push   0x8(%ebp)
  800788:	e8 9a ff ff ff       	call   800727 <vsnprintf>
	va_end(ap);

	return rc;
}
  80078d:	c9                   	leave  
  80078e:	c3                   	ret    

0080078f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	eb 03                	jmp    80079f <strlen+0x10>
		n++;
  80079c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80079f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a3:	75 f7                	jne    80079c <strlen+0xd>
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	eb 03                	jmp    8007ba <strnlen+0x13>
		n++;
  8007b7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ba:	39 d0                	cmp    %edx,%eax
  8007bc:	74 08                	je     8007c6 <strnlen+0x1f>
  8007be:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c2:	75 f3                	jne    8007b7 <strnlen+0x10>
  8007c4:	89 c2                	mov    %eax,%edx
	return n;
}
  8007c6:	89 d0                	mov    %edx,%eax
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	53                   	push   %ebx
  8007ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007dd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e0:	83 c0 01             	add    $0x1,%eax
  8007e3:	84 d2                	test   %dl,%dl
  8007e5:	75 f2                	jne    8007d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e7:	89 c8                	mov    %ecx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	53                   	push   %ebx
  8007f2:	83 ec 10             	sub    $0x10,%esp
  8007f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f8:	53                   	push   %ebx
  8007f9:	e8 91 ff ff ff       	call   80078f <strlen>
  8007fe:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800801:	ff 75 0c             	push   0xc(%ebp)
  800804:	01 d8                	add    %ebx,%eax
  800806:	50                   	push   %eax
  800807:	e8 be ff ff ff       	call   8007ca <strcpy>
	return dst;
}
  80080c:	89 d8                	mov    %ebx,%eax
  80080e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800811:	c9                   	leave  
  800812:	c3                   	ret    

00800813 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081e:	89 f3                	mov    %esi,%ebx
  800820:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	89 f0                	mov    %esi,%eax
  800825:	eb 0f                	jmp    800836 <strncpy+0x23>
		*dst++ = *src;
  800827:	83 c0 01             	add    $0x1,%eax
  80082a:	0f b6 0a             	movzbl (%edx),%ecx
  80082d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800830:	80 f9 01             	cmp    $0x1,%cl
  800833:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800836:	39 d8                	cmp    %ebx,%eax
  800838:	75 ed                	jne    800827 <strncpy+0x14>
	}
	return ret;
}
  80083a:	89 f0                	mov    %esi,%eax
  80083c:	5b                   	pop    %ebx
  80083d:	5e                   	pop    %esi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	56                   	push   %esi
  800844:	53                   	push   %ebx
  800845:	8b 75 08             	mov    0x8(%ebp),%esi
  800848:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084b:	8b 55 10             	mov    0x10(%ebp),%edx
  80084e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800850:	85 d2                	test   %edx,%edx
  800852:	74 21                	je     800875 <strlcpy+0x35>
  800854:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800858:	89 f2                	mov    %esi,%edx
  80085a:	eb 09                	jmp    800865 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	83 c2 01             	add    $0x1,%edx
  800862:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800865:	39 c2                	cmp    %eax,%edx
  800867:	74 09                	je     800872 <strlcpy+0x32>
  800869:	0f b6 19             	movzbl (%ecx),%ebx
  80086c:	84 db                	test   %bl,%bl
  80086e:	75 ec                	jne    80085c <strlcpy+0x1c>
  800870:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800872:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800875:	29 f0                	sub    %esi,%eax
}
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800884:	eb 06                	jmp    80088c <strcmp+0x11>
		p++, q++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80088c:	0f b6 01             	movzbl (%ecx),%eax
  80088f:	84 c0                	test   %al,%al
  800891:	74 04                	je     800897 <strcmp+0x1c>
  800893:	3a 02                	cmp    (%edx),%al
  800895:	74 ef                	je     800886 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800897:	0f b6 c0             	movzbl %al,%eax
  80089a:	0f b6 12             	movzbl (%edx),%edx
  80089d:	29 d0                	sub    %edx,%eax
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	53                   	push   %ebx
  8008a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 06                	jmp    8008b8 <strncmp+0x17>
		n--, p++, q++;
  8008b2:	83 c0 01             	add    $0x1,%eax
  8008b5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	39 d8                	cmp    %ebx,%eax
  8008ba:	74 18                	je     8008d4 <strncmp+0x33>
  8008bc:	0f b6 08             	movzbl (%eax),%ecx
  8008bf:	84 c9                	test   %cl,%cl
  8008c1:	74 04                	je     8008c7 <strncmp+0x26>
  8008c3:	3a 0a                	cmp    (%edx),%cl
  8008c5:	74 eb                	je     8008b2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 00             	movzbl (%eax),%eax
  8008ca:	0f b6 12             	movzbl (%edx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
}
  8008cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d2:	c9                   	leave  
  8008d3:	c3                   	ret    
		return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d9:	eb f4                	jmp    8008cf <strncmp+0x2e>

008008db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 03                	jmp    8008ea <strchr+0xf>
  8008e7:	83 c0 01             	add    $0x1,%eax
  8008ea:	0f b6 10             	movzbl (%eax),%edx
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	74 06                	je     8008f7 <strchr+0x1c>
		if (*s == c)
  8008f1:	38 ca                	cmp    %cl,%dl
  8008f3:	75 f2                	jne    8008e7 <strchr+0xc>
  8008f5:	eb 05                	jmp    8008fc <strchr+0x21>
			return (char *) s;
	return 0;
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800908:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090b:	38 ca                	cmp    %cl,%dl
  80090d:	74 09                	je     800918 <strfind+0x1a>
  80090f:	84 d2                	test   %dl,%dl
  800911:	74 05                	je     800918 <strfind+0x1a>
	for (; *s; s++)
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	eb f0                	jmp    800908 <strfind+0xa>
			break;
	return (char *) s;
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	53                   	push   %ebx
  800920:	8b 7d 08             	mov    0x8(%ebp),%edi
  800923:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800926:	85 c9                	test   %ecx,%ecx
  800928:	74 2f                	je     800959 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092a:	89 f8                	mov    %edi,%eax
  80092c:	09 c8                	or     %ecx,%eax
  80092e:	a8 03                	test   $0x3,%al
  800930:	75 21                	jne    800953 <memset+0x39>
		c &= 0xFF;
  800932:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800936:	89 d0                	mov    %edx,%eax
  800938:	c1 e0 08             	shl    $0x8,%eax
  80093b:	89 d3                	mov    %edx,%ebx
  80093d:	c1 e3 18             	shl    $0x18,%ebx
  800940:	89 d6                	mov    %edx,%esi
  800942:	c1 e6 10             	shl    $0x10,%esi
  800945:	09 f3                	or     %esi,%ebx
  800947:	09 da                	or     %ebx,%edx
  800949:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80094e:	fc                   	cld    
  80094f:	f3 ab                	rep stos %eax,%es:(%edi)
  800951:	eb 06                	jmp    800959 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800953:	8b 45 0c             	mov    0xc(%ebp),%eax
  800956:	fc                   	cld    
  800957:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800959:	89 f8                	mov    %edi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5f                   	pop    %edi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096e:	39 c6                	cmp    %eax,%esi
  800970:	73 32                	jae    8009a4 <memmove+0x44>
  800972:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800975:	39 c2                	cmp    %eax,%edx
  800977:	76 2b                	jbe    8009a4 <memmove+0x44>
		s += n;
		d += n;
  800979:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	89 d6                	mov    %edx,%esi
  80097e:	09 fe                	or     %edi,%esi
  800980:	09 ce                	or     %ecx,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	75 0e                	jne    800998 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098a:	83 ef 04             	sub    $0x4,%edi
  80098d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800990:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800993:	fd                   	std    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 09                	jmp    8009a1 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800998:	83 ef 01             	sub    $0x1,%edi
  80099b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80099e:	fd                   	std    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a1:	fc                   	cld    
  8009a2:	eb 1a                	jmp    8009be <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 f2                	mov    %esi,%edx
  8009a6:	09 c2                	or     %eax,%edx
  8009a8:	09 ca                	or     %ecx,%edx
  8009aa:	f6 c2 03             	test   $0x3,%dl
  8009ad:	75 0a                	jne    8009b9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009af:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb 05                	jmp    8009be <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c8:	ff 75 10             	push   0x10(%ebp)
  8009cb:	ff 75 0c             	push   0xc(%ebp)
  8009ce:	ff 75 08             	push   0x8(%ebp)
  8009d1:	e8 8a ff ff ff       	call   800960 <memmove>
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e8:	eb 06                	jmp    8009f0 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009f0:	39 f0                	cmp    %esi,%eax
  8009f2:	74 14                	je     800a08 <memcmp+0x30>
		if (*s1 != *s2)
  8009f4:	0f b6 08             	movzbl (%eax),%ecx
  8009f7:	0f b6 1a             	movzbl (%edx),%ebx
  8009fa:	38 d9                	cmp    %bl,%cl
  8009fc:	74 ec                	je     8009ea <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009fe:	0f b6 c1             	movzbl %cl,%eax
  800a01:	0f b6 db             	movzbl %bl,%ebx
  800a04:	29 d8                	sub    %ebx,%eax
  800a06:	eb 05                	jmp    800a0d <memcmp+0x35>
	}

	return 0;
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a1a:	89 c2                	mov    %eax,%edx
  800a1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1f:	eb 03                	jmp    800a24 <memfind+0x13>
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	73 04                	jae    800a2c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a28:	38 08                	cmp    %cl,(%eax)
  800a2a:	75 f5                	jne    800a21 <memfind+0x10>
			break;
	return (void *) s;
}
  800a2c:	5d                   	pop    %ebp
  800a2d:	c3                   	ret    

00800a2e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	57                   	push   %edi
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 55 08             	mov    0x8(%ebp),%edx
  800a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3a:	eb 03                	jmp    800a3f <strtol+0x11>
		s++;
  800a3c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a3f:	0f b6 02             	movzbl (%edx),%eax
  800a42:	3c 20                	cmp    $0x20,%al
  800a44:	74 f6                	je     800a3c <strtol+0xe>
  800a46:	3c 09                	cmp    $0x9,%al
  800a48:	74 f2                	je     800a3c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a4a:	3c 2b                	cmp    $0x2b,%al
  800a4c:	74 2a                	je     800a78 <strtol+0x4a>
	int neg = 0;
  800a4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a53:	3c 2d                	cmp    $0x2d,%al
  800a55:	74 2b                	je     800a82 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5d:	75 0f                	jne    800a6e <strtol+0x40>
  800a5f:	80 3a 30             	cmpb   $0x30,(%edx)
  800a62:	74 28                	je     800a8c <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a6b:	0f 44 d8             	cmove  %eax,%ebx
  800a6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a76:	eb 46                	jmp    800abe <strtol+0x90>
		s++;
  800a78:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a80:	eb d5                	jmp    800a57 <strtol+0x29>
		s++, neg = 1;
  800a82:	83 c2 01             	add    $0x1,%edx
  800a85:	bf 01 00 00 00       	mov    $0x1,%edi
  800a8a:	eb cb                	jmp    800a57 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8c:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a90:	74 0e                	je     800aa0 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	75 d8                	jne    800a6e <strtol+0x40>
		s++, base = 8;
  800a96:	83 c2 01             	add    $0x1,%edx
  800a99:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9e:	eb ce                	jmp    800a6e <strtol+0x40>
		s += 2, base = 16;
  800aa0:	83 c2 02             	add    $0x2,%edx
  800aa3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa8:	eb c4                	jmp    800a6e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aaa:	0f be c0             	movsbl %al,%eax
  800aad:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab0:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ab3:	7d 3a                	jge    800aef <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ab5:	83 c2 01             	add    $0x1,%edx
  800ab8:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800abc:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800abe:	0f b6 02             	movzbl (%edx),%eax
  800ac1:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ac4:	89 f3                	mov    %esi,%ebx
  800ac6:	80 fb 09             	cmp    $0x9,%bl
  800ac9:	76 df                	jbe    800aaa <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800acb:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 19             	cmp    $0x19,%bl
  800ad3:	77 08                	ja     800add <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ad5:	0f be c0             	movsbl %al,%eax
  800ad8:	83 e8 57             	sub    $0x57,%eax
  800adb:	eb d3                	jmp    800ab0 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800add:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 08                	ja     800aef <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ae7:	0f be c0             	movsbl %al,%eax
  800aea:	83 e8 37             	sub    $0x37,%eax
  800aed:	eb c1                	jmp    800ab0 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af3:	74 05                	je     800afa <strtol+0xcc>
		*endptr = (char *) s;
  800af5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af8:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800afa:	89 c8                	mov    %ecx,%eax
  800afc:	f7 d8                	neg    %eax
  800afe:	85 ff                	test   %edi,%edi
  800b00:	0f 45 c8             	cmovne %eax,%ecx
}
  800b03:	89 c8                	mov    %ecx,%eax
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b10:	b8 00 00 00 00       	mov    $0x0,%eax
  800b15:	8b 55 08             	mov    0x8(%ebp),%edx
  800b18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b1b:	89 c3                	mov    %eax,%ebx
  800b1d:	89 c7                	mov    %eax,%edi
  800b1f:	89 c6                	mov    %eax,%esi
  800b21:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b33:	b8 01 00 00 00       	mov    $0x1,%eax
  800b38:	89 d1                	mov    %edx,%ecx
  800b3a:	89 d3                	mov    %edx,%ebx
  800b3c:	89 d7                	mov    %edx,%edi
  800b3e:	89 d6                	mov    %edx,%esi
  800b40:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5f                   	pop    %edi
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
  800b4d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b55:	8b 55 08             	mov    0x8(%ebp),%edx
  800b58:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5d:	89 cb                	mov    %ecx,%ebx
  800b5f:	89 cf                	mov    %ecx,%edi
  800b61:	89 ce                	mov    %ecx,%esi
  800b63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b65:	85 c0                	test   %eax,%eax
  800b67:	7f 08                	jg     800b71 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b71:	83 ec 0c             	sub    $0xc,%esp
  800b74:	50                   	push   %eax
  800b75:	6a 03                	push   $0x3
  800b77:	68 44 18 80 00       	push   $0x801844
  800b7c:	6a 23                	push   $0x23
  800b7e:	68 61 18 80 00       	push   $0x801861
  800b83:	e8 e6 06 00 00       	call   80126e <_panic>

00800b88 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 02 00 00 00       	mov    $0x2,%eax
  800b98:	89 d1                	mov    %edx,%ecx
  800b9a:	89 d3                	mov    %edx,%ebx
  800b9c:	89 d7                	mov    %edx,%edi
  800b9e:	89 d6                	mov    %edx,%esi
  800ba0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <sys_yield>:

void
sys_yield(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb7:	89 d1                	mov    %edx,%ecx
  800bb9:	89 d3                	mov    %edx,%ebx
  800bbb:	89 d7                	mov    %edx,%edi
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bcf:	be 00 00 00 00       	mov    $0x0,%esi
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bda:	b8 04 00 00 00       	mov    $0x4,%eax
  800bdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800be2:	89 f7                	mov    %esi,%edi
  800be4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be6:	85 c0                	test   %eax,%eax
  800be8:	7f 08                	jg     800bf2 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 04                	push   $0x4
  800bf8:	68 44 18 80 00       	push   $0x801844
  800bfd:	6a 23                	push   $0x23
  800bff:	68 61 18 80 00       	push   $0x801861
  800c04:	e8 65 06 00 00       	call   80126e <_panic>

00800c09 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	b8 05 00 00 00       	mov    $0x5,%eax
  800c1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c23:	8b 75 18             	mov    0x18(%ebp),%esi
  800c26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	7f 08                	jg     800c34 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	50                   	push   %eax
  800c38:	6a 05                	push   $0x5
  800c3a:	68 44 18 80 00       	push   $0x801844
  800c3f:	6a 23                	push   $0x23
  800c41:	68 61 18 80 00       	push   $0x801861
  800c46:	e8 23 06 00 00       	call   80126e <_panic>

00800c4b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c64:	89 df                	mov    %ebx,%edi
  800c66:	89 de                	mov    %ebx,%esi
  800c68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7f 08                	jg     800c76 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c76:	83 ec 0c             	sub    $0xc,%esp
  800c79:	50                   	push   %eax
  800c7a:	6a 06                	push   $0x6
  800c7c:	68 44 18 80 00       	push   $0x801844
  800c81:	6a 23                	push   $0x23
  800c83:	68 61 18 80 00       	push   $0x801861
  800c88:	e8 e1 05 00 00       	call   80126e <_panic>

00800c8d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca6:	89 df                	mov    %ebx,%edi
  800ca8:	89 de                	mov    %ebx,%esi
  800caa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cac:	85 c0                	test   %eax,%eax
  800cae:	7f 08                	jg     800cb8 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 08                	push   $0x8
  800cbe:	68 44 18 80 00       	push   $0x801844
  800cc3:	6a 23                	push   $0x23
  800cc5:	68 61 18 80 00       	push   $0x801861
  800cca:	e8 9f 05 00 00       	call   80126e <_panic>

00800ccf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	57                   	push   %edi
  800cd3:	56                   	push   %esi
  800cd4:	53                   	push   %ebx
  800cd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce3:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce8:	89 df                	mov    %ebx,%edi
  800cea:	89 de                	mov    %ebx,%esi
  800cec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cee:	85 c0                	test   %eax,%eax
  800cf0:	7f 08                	jg     800cfa <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 09                	push   $0x9
  800d00:	68 44 18 80 00       	push   $0x801844
  800d05:	6a 23                	push   $0x23
  800d07:	68 61 18 80 00       	push   $0x801861
  800d0c:	e8 5d 05 00 00       	call   80126e <_panic>

00800d11 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d22:	be 00 00 00 00       	mov    $0x0,%esi
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	57                   	push   %edi
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4a:	89 cb                	mov    %ecx,%ebx
  800d4c:	89 cf                	mov    %ecx,%edi
  800d4e:	89 ce                	mov    %ecx,%esi
  800d50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d52:	85 c0                	test   %eax,%eax
  800d54:	7f 08                	jg     800d5e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 0c                	push   $0xc
  800d64:	68 44 18 80 00       	push   $0x801844
  800d69:	6a 23                	push   $0x23
  800d6b:	68 61 18 80 00       	push   $0x801861
  800d70:	e8 f9 04 00 00       	call   80126e <_panic>

00800d75 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
	int r;

	// LAB 4: Your code here.
	void *addr = (void *)(pn * PGSIZE);
  800d7a:	89 d6                	mov    %edx,%esi
  800d7c:	c1 e6 0c             	shl    $0xc,%esi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800d7f:	8b 1c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ebx
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800d86:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800d8d:	f6 c1 02             	test   $0x2,%cl
  800d90:	75 0c                	jne    800d9e <duppage+0x29>
  800d92:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d99:	f6 c6 08             	test   $0x8,%dh
  800d9c:	74 64                	je     800e02 <duppage+0x8d>
		perm &= ~PTE_W;
  800d9e:	81 e3 05 0e 00 00    	and    $0xe05,%ebx
		perm |= PTE_COW;
  800da4:	80 cf 08             	or     $0x8,%bh
		int ret = sys_page_map(0, addr, envid, addr, perm);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	53                   	push   %ebx
  800dab:	56                   	push   %esi
  800dac:	50                   	push   %eax
  800dad:	56                   	push   %esi
  800dae:	6a 00                	push   $0x0
  800db0:	e8 54 fe ff ff       	call   800c09 <sys_page_map>
		if (ret < 0) {
  800db5:	83 c4 20             	add    $0x20,%esp
  800db8:	85 c0                	test   %eax,%eax
  800dba:	78 22                	js     800dde <duppage+0x69>
			panic("duppage: sys_page_map failed: %e", ret);
		}
		ret = sys_page_map(0, addr, 0, addr, perm);
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	53                   	push   %ebx
  800dc0:	56                   	push   %esi
  800dc1:	6a 00                	push   $0x0
  800dc3:	56                   	push   %esi
  800dc4:	6a 00                	push   $0x0
  800dc6:	e8 3e fe ff ff       	call   800c09 <sys_page_map>
		if (ret < 0) {
  800dcb:	83 c4 20             	add    $0x20,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	78 1e                	js     800df0 <duppage+0x7b>
		if (ret < 0) {
			panic("duppage: sys_page_map failed: %e", ret);
		}
	}
	return 0;
}
  800dd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    
			panic("duppage: sys_page_map failed: %e", ret);
  800dde:	50                   	push   %eax
  800ddf:	68 70 18 80 00       	push   $0x801870
  800de4:	6a 4f                	push   $0x4f
  800de6:	68 d6 19 80 00       	push   $0x8019d6
  800deb:	e8 7e 04 00 00       	call   80126e <_panic>
			panic("duppage: sys_page_map failed: %e", ret);
  800df0:	50                   	push   %eax
  800df1:	68 70 18 80 00       	push   $0x801870
  800df6:	6a 53                	push   $0x53
  800df8:	68 d6 19 80 00       	push   $0x8019d6
  800dfd:	e8 6c 04 00 00       	call   80126e <_panic>
		int ret = sys_page_map(0, addr, envid, addr, perm);
  800e02:	83 ec 0c             	sub    $0xc,%esp
	int perm = uvpt[pn] & PTE_SYSCALL;
  800e05:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
		int ret = sys_page_map(0, addr, envid, addr, perm);
  800e0b:	53                   	push   %ebx
  800e0c:	56                   	push   %esi
  800e0d:	50                   	push   %eax
  800e0e:	56                   	push   %esi
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 f3 fd ff ff       	call   800c09 <sys_page_map>
		if (ret < 0) {
  800e16:	83 c4 20             	add    $0x20,%esp
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	79 b5                	jns    800dd2 <duppage+0x5d>
			panic("duppage: sys_page_map failed: %e", ret);
  800e1d:	50                   	push   %eax
  800e1e:	68 70 18 80 00       	push   $0x801870
  800e23:	6a 58                	push   $0x58
  800e25:	68 d6 19 80 00       	push   $0x8019d6
  800e2a:	e8 3f 04 00 00       	call   80126e <_panic>

00800e2f <pgfault>:
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	53                   	push   %ebx
  800e33:	83 ec 04             	sub    $0x4,%esp
  800e36:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800e39:	8b 02                	mov    (%edx),%eax
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) {
  800e3b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800e3f:	74 7b                	je     800ebc <pgfault+0x8d>
  800e41:	89 c2                	mov    %eax,%edx
  800e43:	c1 ea 0c             	shr    $0xc,%edx
  800e46:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e4d:	f6 c6 08             	test   $0x8,%dh
  800e50:	74 6a                	je     800ebc <pgfault+0x8d>
	addr = ROUNDDOWN(addr, PGSIZE);
  800e52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e57:	89 c3                	mov    %eax,%ebx
	int ret = sys_page_alloc(0, PFTEMP, PTE_U | PTE_W | PTE_P);
  800e59:	83 ec 04             	sub    $0x4,%esp
  800e5c:	6a 07                	push   $0x7
  800e5e:	68 00 f0 7f 00       	push   $0x7ff000
  800e63:	6a 00                	push   $0x0
  800e65:	e8 5c fd ff ff       	call   800bc6 <sys_page_alloc>
	if (ret < 0) {
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	78 5f                	js     800ed0 <pgfault+0xa1>
	memmove(PFTEMP, addr, PGSIZE);
  800e71:	83 ec 04             	sub    $0x4,%esp
  800e74:	68 00 10 00 00       	push   $0x1000
  800e79:	53                   	push   %ebx
  800e7a:	68 00 f0 7f 00       	push   $0x7ff000
  800e7f:	e8 dc fa ff ff       	call   800960 <memmove>
	ret = sys_page_map(0, PFTEMP, 0, addr, PTE_U | PTE_W | PTE_P);
  800e84:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e8b:	53                   	push   %ebx
  800e8c:	6a 00                	push   $0x0
  800e8e:	68 00 f0 7f 00       	push   $0x7ff000
  800e93:	6a 00                	push   $0x0
  800e95:	e8 6f fd ff ff       	call   800c09 <sys_page_map>
	if (ret < 0) {
  800e9a:	83 c4 20             	add    $0x20,%esp
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	78 41                	js     800ee2 <pgfault+0xb3>
	ret = sys_page_unmap(0, PFTEMP);
  800ea1:	83 ec 08             	sub    $0x8,%esp
  800ea4:	68 00 f0 7f 00       	push   $0x7ff000
  800ea9:	6a 00                	push   $0x0
  800eab:	e8 9b fd ff ff       	call   800c4b <sys_page_unmap>
	if (ret < 0) {
  800eb0:	83 c4 10             	add    $0x10,%esp
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	78 3d                	js     800ef4 <pgfault+0xc5>
}
  800eb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    
		panic("pgfault: faulting access was not a write or to a copy-on-write page");
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	68 94 18 80 00       	push   $0x801894
  800ec4:	6a 1d                	push   $0x1d
  800ec6:	68 d6 19 80 00       	push   $0x8019d6
  800ecb:	e8 9e 03 00 00       	call   80126e <_panic>
		panic("pgfault: sys_page_alloc failed: %e", ret);
  800ed0:	50                   	push   %eax
  800ed1:	68 d8 18 80 00       	push   $0x8018d8
  800ed6:	6a 2a                	push   $0x2a
  800ed8:	68 d6 19 80 00       	push   $0x8019d6
  800edd:	e8 8c 03 00 00       	call   80126e <_panic>
		panic("pgfault: sys_page_map failed: %e", ret);
  800ee2:	50                   	push   %eax
  800ee3:	68 fc 18 80 00       	push   $0x8018fc
  800ee8:	6a 2f                	push   $0x2f
  800eea:	68 d6 19 80 00       	push   $0x8019d6
  800eef:	e8 7a 03 00 00       	call   80126e <_panic>
		panic("pgfault: sys_page_unmap failed: %e", ret);
  800ef4:	50                   	push   %eax
  800ef5:	68 20 19 80 00       	push   $0x801920
  800efa:	6a 33                	push   $0x33
  800efc:	68 d6 19 80 00       	push   $0x8019d6
  800f01:	e8 68 03 00 00       	call   80126e <_panic>

00800f06 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  800f0b:	83 ec 0c             	sub    $0xc,%esp
  800f0e:	68 2f 0e 80 00       	push   $0x800e2f
  800f13:	e8 9c 03 00 00       	call   8012b4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f18:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1d:	cd 30                	int    $0x30
  800f1f:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0) {
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	78 23                	js     800f4b <fork+0x45>
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// parent process

	for (uintptr_t addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f28:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (envid == 0) {
  800f2d:	75 3c                	jne    800f6b <fork+0x65>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2f:	e8 54 fc ff ff       	call   800b88 <sys_getenvid>
  800f34:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f39:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f41:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f46:	e9 87 00 00 00       	jmp    800fd2 <fork+0xcc>
		panic("fork: sys_exofork failed: %e", envid);
  800f4b:	50                   	push   %eax
  800f4c:	68 e1 19 80 00       	push   $0x8019e1
  800f51:	6a 77                	push   $0x77
  800f53:	68 d6 19 80 00       	push   $0x8019d6
  800f58:	e8 11 03 00 00       	call   80126e <_panic>
	for (uintptr_t addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f5d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f63:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f69:	74 29                	je     800f94 <fork+0x8e>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)) {
  800f6b:	89 d8                	mov    %ebx,%eax
  800f6d:	c1 e8 16             	shr    $0x16,%eax
  800f70:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f77:	a8 01                	test   $0x1,%al
  800f79:	74 e2                	je     800f5d <fork+0x57>
  800f7b:	89 da                	mov    %ebx,%edx
  800f7d:	c1 ea 0c             	shr    $0xc,%edx
  800f80:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800f87:	a8 01                	test   $0x1,%al
  800f89:	74 d2                	je     800f5d <fork+0x57>
			duppage(envid, PGNUM(addr));
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	e8 e3 fd ff ff       	call   800d75 <duppage>
  800f92:	eb c9                	jmp    800f5d <fork+0x57>
		}
	}

	int ret = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  800f94:	83 ec 04             	sub    $0x4,%esp
  800f97:	6a 07                	push   $0x7
  800f99:	68 00 f0 bf ee       	push   $0xeebff000
  800f9e:	56                   	push   %esi
  800f9f:	e8 22 fc ff ff       	call   800bc6 <sys_page_alloc>
	if (ret < 0) {
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 30                	js     800fdb <fork+0xd5>
		panic("fork: sys_page_alloc failed: %e", ret);
	}

	ret = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	68 1f 13 80 00       	push   $0x80131f
  800fb3:	56                   	push   %esi
  800fb4:	e8 16 fd ff ff       	call   800ccf <sys_env_set_pgfault_upcall>
	if (ret < 0) {
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 30                	js     800ff0 <fork+0xea>
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
	}

	ret = sys_env_set_status(envid, ENV_RUNNABLE);
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	6a 02                	push   $0x2
  800fc5:	56                   	push   %esi
  800fc6:	e8 c2 fc ff ff       	call   800c8d <sys_env_set_status>
	if (ret < 0) {
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 33                	js     801005 <fork+0xff>
		panic("fork: sys_env_set_status failed: %e", ret);
	}
	return envid;
}
  800fd2:	89 f0                	mov    %esi,%eax
  800fd4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd7:	5b                   	pop    %ebx
  800fd8:	5e                   	pop    %esi
  800fd9:	5d                   	pop    %ebp
  800fda:	c3                   	ret    
		panic("fork: sys_page_alloc failed: %e", ret);
  800fdb:	50                   	push   %eax
  800fdc:	68 44 19 80 00       	push   $0x801944
  800fe1:	68 88 00 00 00       	push   $0x88
  800fe6:	68 d6 19 80 00       	push   $0x8019d6
  800feb:	e8 7e 02 00 00       	call   80126e <_panic>
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
  800ff0:	50                   	push   %eax
  800ff1:	68 64 19 80 00       	push   $0x801964
  800ff6:	68 8d 00 00 00       	push   $0x8d
  800ffb:	68 d6 19 80 00       	push   $0x8019d6
  801000:	e8 69 02 00 00       	call   80126e <_panic>
		panic("fork: sys_env_set_status failed: %e", ret);
  801005:	50                   	push   %eax
  801006:	68 90 19 80 00       	push   $0x801990
  80100b:	68 92 00 00 00       	push   $0x92
  801010:	68 d6 19 80 00       	push   $0x8019d6
  801015:	e8 54 02 00 00       	call   80126e <_panic>

0080101a <sfork>:
}

// Challenge!
int
sfork(void)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
	extern void _pgfault_upcall(void);

	set_pgfault_handler(pgfault);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	68 2f 0e 80 00       	push   $0x800e2f
  801027:	e8 88 02 00 00       	call   8012b4 <set_pgfault_handler>
  80102c:	b8 07 00 00 00       	mov    $0x7,%eax
  801031:	cd 30                	int    $0x30
  801033:	89 c6                	mov    %eax,%esi
	envid_t envid = sys_exofork();
	if (envid < 0) {
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	78 0d                	js     801049 <sfork+0x2f>
		panic("fork: sys_exofork failed: %e", envid);
	}
	if (envid == 0) {
  80103c:	0f 84 dc 00 00 00    	je     80111e <sfork+0x104>
		// child process
		return 0;
	}
	// parent process

	for (uintptr_t addr = 0; addr < (USTACKTOP - PGSIZE); addr += PGSIZE) {
  801042:	bb 00 00 00 00       	mov    $0x0,%ebx
  801047:	eb 23                	jmp    80106c <sfork+0x52>
		panic("fork: sys_exofork failed: %e", envid);
  801049:	50                   	push   %eax
  80104a:	68 e1 19 80 00       	push   $0x8019e1
  80104f:	68 ac 00 00 00       	push   $0xac
  801054:	68 d6 19 80 00       	push   $0x8019d6
  801059:	e8 10 02 00 00       	call   80126e <_panic>
	for (uintptr_t addr = 0; addr < (USTACKTOP - PGSIZE); addr += PGSIZE) {
  80105e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801064:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  80106a:	74 68                	je     8010d4 <sfork+0xba>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  80106c:	89 d8                	mov    %ebx,%eax
  80106e:	c1 e8 16             	shr    $0x16,%eax
  801071:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801078:	a8 01                	test   $0x1,%al
  80107a:	74 e2                	je     80105e <sfork+0x44>
  80107c:	89 d8                	mov    %ebx,%eax
  80107e:	c1 e8 0c             	shr    $0xc,%eax
  801081:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801088:	f6 c2 01             	test   $0x1,%dl
  80108b:	74 d1                	je     80105e <sfork+0x44>
  80108d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801094:	f6 c2 04             	test   $0x4,%dl
  801097:	74 c5                	je     80105e <sfork+0x44>
	void *addr = (void *)(pn * PGSIZE);
  801099:	89 c2                	mov    %eax,%edx
  80109b:	c1 e2 0c             	shl    $0xc,%edx
	int perm = uvpt[pn] & PTE_SYSCALL;
  80109e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	int ret = sys_page_map(0, addr, envid, addr, perm);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
	int perm = uvpt[pn] & PTE_SYSCALL;
  8010a8:	25 07 0e 00 00       	and    $0xe07,%eax
	int ret = sys_page_map(0, addr, envid, addr, perm);
  8010ad:	50                   	push   %eax
  8010ae:	52                   	push   %edx
  8010af:	56                   	push   %esi
  8010b0:	52                   	push   %edx
  8010b1:	6a 00                	push   $0x0
  8010b3:	e8 51 fb ff ff       	call   800c09 <sys_page_map>
	if (ret < 0) {
  8010b8:	83 c4 20             	add    $0x20,%esp
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	79 9f                	jns    80105e <sfork+0x44>
		panic("sduppage: sys_page_map failed: %e", ret);
  8010bf:	50                   	push   %eax
  8010c0:	68 b4 19 80 00       	push   $0x8019b4
  8010c5:	68 9e 00 00 00       	push   $0x9e
  8010ca:	68 d6 19 80 00       	push   $0x8019d6
  8010cf:	e8 9a 01 00 00       	call   80126e <_panic>
			sduppage(envid, PGNUM(addr));
		}
	}
	duppage(envid, PGNUM(USTACKTOP - PGSIZE));
  8010d4:	ba fd eb 0e 00       	mov    $0xeebfd,%edx
  8010d9:	89 f0                	mov    %esi,%eax
  8010db:	e8 95 fc ff ff       	call   800d75 <duppage>

	int ret = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	6a 07                	push   $0x7
  8010e5:	68 00 f0 bf ee       	push   $0xeebff000
  8010ea:	56                   	push   %esi
  8010eb:	e8 d6 fa ff ff       	call   800bc6 <sys_page_alloc>
	if (ret < 0) {
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 30                	js     801127 <sfork+0x10d>
		panic("fork: sys_page_alloc failed: %e", ret);
	}

	ret = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010f7:	83 ec 08             	sub    $0x8,%esp
  8010fa:	68 1f 13 80 00       	push   $0x80131f
  8010ff:	56                   	push   %esi
  801100:	e8 ca fb ff ff       	call   800ccf <sys_env_set_pgfault_upcall>
	if (ret < 0) {
  801105:	83 c4 10             	add    $0x10,%esp
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 30                	js     80113c <sfork+0x122>
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
	}

	ret = sys_env_set_status(envid, ENV_RUNNABLE);
  80110c:	83 ec 08             	sub    $0x8,%esp
  80110f:	6a 02                	push   $0x2
  801111:	56                   	push   %esi
  801112:	e8 76 fb ff ff       	call   800c8d <sys_env_set_status>
	if (ret < 0) {
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 33                	js     801151 <sfork+0x137>
		panic("fork: sys_env_set_status failed: %e", ret);
	}
	return envid;

  80111e:	89 f0                	mov    %esi,%eax
  801120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5d                   	pop    %ebp
  801126:	c3                   	ret    
		panic("fork: sys_page_alloc failed: %e", ret);
  801127:	50                   	push   %eax
  801128:	68 44 19 80 00       	push   $0x801944
  80112d:	68 bd 00 00 00       	push   $0xbd
  801132:	68 d6 19 80 00       	push   $0x8019d6
  801137:	e8 32 01 00 00       	call   80126e <_panic>
		panic("fork: sys_env_set_pgfault_upcall failed: %e", ret);
  80113c:	50                   	push   %eax
  80113d:	68 64 19 80 00       	push   $0x801964
  801142:	68 c2 00 00 00       	push   $0xc2
  801147:	68 d6 19 80 00       	push   $0x8019d6
  80114c:	e8 1d 01 00 00       	call   80126e <_panic>
		panic("fork: sys_env_set_status failed: %e", ret);
  801151:	50                   	push   %eax
  801152:	68 90 19 80 00       	push   $0x801990
  801157:	68 c7 00 00 00       	push   $0xc7
  80115c:	68 d6 19 80 00       	push   $0x8019d6
  801161:	e8 08 01 00 00       	call   80126e <_panic>

00801166 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	8b 75 08             	mov    0x8(%ebp),%esi
  80116e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801171:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *) UTOP;
	} else {
		pg = ROUNDDOWN(pg, PGSIZE);
  801174:	89 d0                	mov    %edx,%eax
  801176:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80117b:	85 d2                	test   %edx,%edx
  80117d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801182:	0f 44 c2             	cmove  %edx,%eax
	}
	int ret = sys_ipc_recv(pg);
  801185:	83 ec 0c             	sub    $0xc,%esp
  801188:	50                   	push   %eax
  801189:	e8 a6 fb ff ff       	call   800d34 <sys_ipc_recv>
	if (ret < 0) {
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 2e                	js     8011c3 <ipc_recv+0x5d>
			*perm_store = 0;
		}
		return ret;
	}
	// uncomment this line if you want to do the `sfork` challenge
	const volatile struct Env *thisenv = envs + ENVX(sys_getenvid());
  801195:	e8 ee f9 ff ff       	call   800b88 <sys_getenvid>
  80119a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80119f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
	
	if (from_env_store != NULL) {
  8011a7:	85 f6                	test   %esi,%esi
  8011a9:	74 05                	je     8011b0 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  8011ab:	8b 50 74             	mov    0x74(%eax),%edx
  8011ae:	89 16                	mov    %edx,(%esi)
	}
	if (perm_store != NULL) {
  8011b0:	85 db                	test   %ebx,%ebx
  8011b2:	74 05                	je     8011b9 <ipc_recv+0x53>
		*perm_store = thisenv->env_ipc_perm;
  8011b4:	8b 50 78             	mov    0x78(%eax),%edx
  8011b7:	89 13                	mov    %edx,(%ebx)
	}
	return thisenv->env_ipc_value;
  8011b9:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    
		if (from_env_store != NULL) {
  8011c3:	85 f6                	test   %esi,%esi
  8011c5:	74 06                	je     8011cd <ipc_recv+0x67>
			*from_env_store = 0;
  8011c7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) {
  8011cd:	85 db                	test   %ebx,%ebx
  8011cf:	74 eb                	je     8011bc <ipc_recv+0x56>
			*perm_store = 0;
  8011d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011d7:	eb e3                	jmp    8011bc <ipc_recv+0x56>

008011d9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	57                   	push   %edi
  8011dd:	56                   	push   %esi
  8011de:	53                   	push   %ebx
  8011df:	83 ec 0c             	sub    $0xc,%esp
  8011e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011e8:	8b 45 10             	mov    0x10(%ebp),%eax
	if (pg == NULL) {
		pg = (void *) UTOP;
	} else {
		pg = ROUNDDOWN(pg, PGSIZE);
  8011eb:	89 c3                	mov    %eax,%ebx
  8011ed:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011fa:	0f 44 d8             	cmove  %eax,%ebx
	}
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8011fd:	ff 75 14             	push   0x14(%ebp)
  801200:	53                   	push   %ebx
  801201:	56                   	push   %esi
  801202:	57                   	push   %edi
  801203:	e8 09 fb ff ff       	call   800d11 <sys_ipc_try_send>
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	85 c0                	test   %eax,%eax
  80120d:	79 1e                	jns    80122d <ipc_send+0x54>
		if (ret != -E_IPC_NOT_RECV) {
  80120f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801212:	75 07                	jne    80121b <ipc_send+0x42>
			panic("ipc_send: %e", ret);
		}
		sys_yield();
  801214:	e8 8e f9 ff ff       	call   800ba7 <sys_yield>
  801219:	eb e2                	jmp    8011fd <ipc_send+0x24>
			panic("ipc_send: %e", ret);
  80121b:	50                   	push   %eax
  80121c:	68 fe 19 80 00       	push   $0x8019fe
  801221:	6a 48                	push   $0x48
  801223:	68 0b 1a 80 00       	push   $0x801a0b
  801228:	e8 41 00 00 00       	call   80126e <_panic>
	}
}
  80122d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801230:	5b                   	pop    %ebx
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801240:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801243:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801249:	8b 52 50             	mov    0x50(%edx),%edx
  80124c:	39 ca                	cmp    %ecx,%edx
  80124e:	74 11                	je     801261 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801250:	83 c0 01             	add    $0x1,%eax
  801253:	3d 00 04 00 00       	cmp    $0x400,%eax
  801258:	75 e6                	jne    801240 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80125a:	b8 00 00 00 00       	mov    $0x0,%eax
  80125f:	eb 0b                	jmp    80126c <ipc_find_env+0x37>
			return envs[i].env_id;
  801261:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801264:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801269:	8b 40 48             	mov    0x48(%eax),%eax
}
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801273:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801276:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80127c:	e8 07 f9 ff ff       	call   800b88 <sys_getenvid>
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	ff 75 0c             	push   0xc(%ebp)
  801287:	ff 75 08             	push   0x8(%ebp)
  80128a:	56                   	push   %esi
  80128b:	50                   	push   %eax
  80128c:	68 18 1a 80 00       	push   $0x801a18
  801291:	e8 5a ef ff ff       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801296:	83 c4 18             	add    $0x18,%esp
  801299:	53                   	push   %ebx
  80129a:	ff 75 10             	push   0x10(%ebp)
  80129d:	e8 fd ee ff ff       	call   80019f <vcprintf>
	cprintf("\n");
  8012a2:	c7 04 24 b8 15 80 00 	movl   $0x8015b8,(%esp)
  8012a9:	e8 42 ef ff ff       	call   8001f0 <cprintf>
  8012ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012b1:	cc                   	int3   
  8012b2:	eb fd                	jmp    8012b1 <_panic+0x43>

008012b4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012ba:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8012c1:	74 0a                	je     8012cd <set_pgfault_handler+0x19>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed: %e", ret);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c6:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    
		int ret = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_W | PTE_P);
  8012cd:	83 ec 04             	sub    $0x4,%esp
  8012d0:	6a 07                	push   $0x7
  8012d2:	68 00 f0 bf ee       	push   $0xeebff000
  8012d7:	6a 00                	push   $0x0
  8012d9:	e8 e8 f8 ff ff       	call   800bc6 <sys_page_alloc>
		if (ret < 0) {
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 28                	js     80130d <set_pgfault_handler+0x59>
		ret = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	68 1f 13 80 00       	push   $0x80131f
  8012ed:	6a 00                	push   $0x0
  8012ef:	e8 db f9 ff ff       	call   800ccf <sys_env_set_pgfault_upcall>
		if (ret < 0) {
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	79 c8                	jns    8012c3 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall failed: %e", ret);
  8012fb:	50                   	push   %eax
  8012fc:	68 6c 1a 80 00       	push   $0x801a6c
  801301:	6a 26                	push   $0x26
  801303:	68 a7 1a 80 00       	push   $0x801aa7
  801308:	e8 61 ff ff ff       	call   80126e <_panic>
			panic("set_pgfault_handler: sys_page_alloc failed: %e", ret);
  80130d:	50                   	push   %eax
  80130e:	68 3c 1a 80 00       	push   $0x801a3c
  801313:	6a 22                	push   $0x22
  801315:	68 a7 1a 80 00       	push   $0x801aa7
  80131a:	e8 4f ff ff ff       	call   80126e <_panic>

0080131f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80131f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801320:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801325:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801327:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	subl $0x4, 0x30(%esp)
  80132a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	movl 0x30(%esp), %eax
  80132f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 0x28(%esp), %edx
  801333:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801337:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $0x8, %esp
  801339:	83 c4 08             	add    $0x8,%esp
	popal
  80133c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  80133d:	83 c4 04             	add    $0x4,%esp
	popfl
  801340:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801341:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801342:	c3                   	ret    
  801343:	66 90                	xchg   %ax,%ax
  801345:	66 90                	xchg   %ax,%ax
  801347:	66 90                	xchg   %ax,%ax
  801349:	66 90                	xchg   %ax,%ax
  80134b:	66 90                	xchg   %ax,%ax
  80134d:	66 90                	xchg   %ax,%ax
  80134f:	90                   	nop

00801350 <__udivdi3>:
  801350:	f3 0f 1e fb          	endbr32 
  801354:	55                   	push   %ebp
  801355:	57                   	push   %edi
  801356:	56                   	push   %esi
  801357:	53                   	push   %ebx
  801358:	83 ec 1c             	sub    $0x1c,%esp
  80135b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80135f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801363:	8b 74 24 34          	mov    0x34(%esp),%esi
  801367:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80136b:	85 c0                	test   %eax,%eax
  80136d:	75 19                	jne    801388 <__udivdi3+0x38>
  80136f:	39 f3                	cmp    %esi,%ebx
  801371:	76 4d                	jbe    8013c0 <__udivdi3+0x70>
  801373:	31 ff                	xor    %edi,%edi
  801375:	89 e8                	mov    %ebp,%eax
  801377:	89 f2                	mov    %esi,%edx
  801379:	f7 f3                	div    %ebx
  80137b:	89 fa                	mov    %edi,%edx
  80137d:	83 c4 1c             	add    $0x1c,%esp
  801380:	5b                   	pop    %ebx
  801381:	5e                   	pop    %esi
  801382:	5f                   	pop    %edi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
  801385:	8d 76 00             	lea    0x0(%esi),%esi
  801388:	39 f0                	cmp    %esi,%eax
  80138a:	76 14                	jbe    8013a0 <__udivdi3+0x50>
  80138c:	31 ff                	xor    %edi,%edi
  80138e:	31 c0                	xor    %eax,%eax
  801390:	89 fa                	mov    %edi,%edx
  801392:	83 c4 1c             	add    $0x1c,%esp
  801395:	5b                   	pop    %ebx
  801396:	5e                   	pop    %esi
  801397:	5f                   	pop    %edi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    
  80139a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013a0:	0f bd f8             	bsr    %eax,%edi
  8013a3:	83 f7 1f             	xor    $0x1f,%edi
  8013a6:	75 48                	jne    8013f0 <__udivdi3+0xa0>
  8013a8:	39 f0                	cmp    %esi,%eax
  8013aa:	72 06                	jb     8013b2 <__udivdi3+0x62>
  8013ac:	31 c0                	xor    %eax,%eax
  8013ae:	39 eb                	cmp    %ebp,%ebx
  8013b0:	77 de                	ja     801390 <__udivdi3+0x40>
  8013b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b7:	eb d7                	jmp    801390 <__udivdi3+0x40>
  8013b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	89 d9                	mov    %ebx,%ecx
  8013c2:	85 db                	test   %ebx,%ebx
  8013c4:	75 0b                	jne    8013d1 <__udivdi3+0x81>
  8013c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013cb:	31 d2                	xor    %edx,%edx
  8013cd:	f7 f3                	div    %ebx
  8013cf:	89 c1                	mov    %eax,%ecx
  8013d1:	31 d2                	xor    %edx,%edx
  8013d3:	89 f0                	mov    %esi,%eax
  8013d5:	f7 f1                	div    %ecx
  8013d7:	89 c6                	mov    %eax,%esi
  8013d9:	89 e8                	mov    %ebp,%eax
  8013db:	89 f7                	mov    %esi,%edi
  8013dd:	f7 f1                	div    %ecx
  8013df:	89 fa                	mov    %edi,%edx
  8013e1:	83 c4 1c             	add    $0x1c,%esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5e                   	pop    %esi
  8013e6:	5f                   	pop    %edi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    
  8013e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013f0:	89 f9                	mov    %edi,%ecx
  8013f2:	ba 20 00 00 00       	mov    $0x20,%edx
  8013f7:	29 fa                	sub    %edi,%edx
  8013f9:	d3 e0                	shl    %cl,%eax
  8013fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ff:	89 d1                	mov    %edx,%ecx
  801401:	89 d8                	mov    %ebx,%eax
  801403:	d3 e8                	shr    %cl,%eax
  801405:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801409:	09 c1                	or     %eax,%ecx
  80140b:	89 f0                	mov    %esi,%eax
  80140d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801411:	89 f9                	mov    %edi,%ecx
  801413:	d3 e3                	shl    %cl,%ebx
  801415:	89 d1                	mov    %edx,%ecx
  801417:	d3 e8                	shr    %cl,%eax
  801419:	89 f9                	mov    %edi,%ecx
  80141b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80141f:	89 eb                	mov    %ebp,%ebx
  801421:	d3 e6                	shl    %cl,%esi
  801423:	89 d1                	mov    %edx,%ecx
  801425:	d3 eb                	shr    %cl,%ebx
  801427:	09 f3                	or     %esi,%ebx
  801429:	89 c6                	mov    %eax,%esi
  80142b:	89 f2                	mov    %esi,%edx
  80142d:	89 d8                	mov    %ebx,%eax
  80142f:	f7 74 24 08          	divl   0x8(%esp)
  801433:	89 d6                	mov    %edx,%esi
  801435:	89 c3                	mov    %eax,%ebx
  801437:	f7 64 24 0c          	mull   0xc(%esp)
  80143b:	39 d6                	cmp    %edx,%esi
  80143d:	72 19                	jb     801458 <__udivdi3+0x108>
  80143f:	89 f9                	mov    %edi,%ecx
  801441:	d3 e5                	shl    %cl,%ebp
  801443:	39 c5                	cmp    %eax,%ebp
  801445:	73 04                	jae    80144b <__udivdi3+0xfb>
  801447:	39 d6                	cmp    %edx,%esi
  801449:	74 0d                	je     801458 <__udivdi3+0x108>
  80144b:	89 d8                	mov    %ebx,%eax
  80144d:	31 ff                	xor    %edi,%edi
  80144f:	e9 3c ff ff ff       	jmp    801390 <__udivdi3+0x40>
  801454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801458:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80145b:	31 ff                	xor    %edi,%edi
  80145d:	e9 2e ff ff ff       	jmp    801390 <__udivdi3+0x40>
  801462:	66 90                	xchg   %ax,%ax
  801464:	66 90                	xchg   %ax,%ax
  801466:	66 90                	xchg   %ax,%ax
  801468:	66 90                	xchg   %ax,%ax
  80146a:	66 90                	xchg   %ax,%ax
  80146c:	66 90                	xchg   %ax,%ax
  80146e:	66 90                	xchg   %ax,%ax

00801470 <__umoddi3>:
  801470:	f3 0f 1e fb          	endbr32 
  801474:	55                   	push   %ebp
  801475:	57                   	push   %edi
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	83 ec 1c             	sub    $0x1c,%esp
  80147b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80147f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801483:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801487:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80148b:	89 f0                	mov    %esi,%eax
  80148d:	89 da                	mov    %ebx,%edx
  80148f:	85 ff                	test   %edi,%edi
  801491:	75 15                	jne    8014a8 <__umoddi3+0x38>
  801493:	39 dd                	cmp    %ebx,%ebp
  801495:	76 39                	jbe    8014d0 <__umoddi3+0x60>
  801497:	f7 f5                	div    %ebp
  801499:	89 d0                	mov    %edx,%eax
  80149b:	31 d2                	xor    %edx,%edx
  80149d:	83 c4 1c             	add    $0x1c,%esp
  8014a0:	5b                   	pop    %ebx
  8014a1:	5e                   	pop    %esi
  8014a2:	5f                   	pop    %edi
  8014a3:	5d                   	pop    %ebp
  8014a4:	c3                   	ret    
  8014a5:	8d 76 00             	lea    0x0(%esi),%esi
  8014a8:	39 df                	cmp    %ebx,%edi
  8014aa:	77 f1                	ja     80149d <__umoddi3+0x2d>
  8014ac:	0f bd cf             	bsr    %edi,%ecx
  8014af:	83 f1 1f             	xor    $0x1f,%ecx
  8014b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014b6:	75 40                	jne    8014f8 <__umoddi3+0x88>
  8014b8:	39 df                	cmp    %ebx,%edi
  8014ba:	72 04                	jb     8014c0 <__umoddi3+0x50>
  8014bc:	39 f5                	cmp    %esi,%ebp
  8014be:	77 dd                	ja     80149d <__umoddi3+0x2d>
  8014c0:	89 da                	mov    %ebx,%edx
  8014c2:	89 f0                	mov    %esi,%eax
  8014c4:	29 e8                	sub    %ebp,%eax
  8014c6:	19 fa                	sbb    %edi,%edx
  8014c8:	eb d3                	jmp    80149d <__umoddi3+0x2d>
  8014ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8014d0:	89 e9                	mov    %ebp,%ecx
  8014d2:	85 ed                	test   %ebp,%ebp
  8014d4:	75 0b                	jne    8014e1 <__umoddi3+0x71>
  8014d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8014db:	31 d2                	xor    %edx,%edx
  8014dd:	f7 f5                	div    %ebp
  8014df:	89 c1                	mov    %eax,%ecx
  8014e1:	89 d8                	mov    %ebx,%eax
  8014e3:	31 d2                	xor    %edx,%edx
  8014e5:	f7 f1                	div    %ecx
  8014e7:	89 f0                	mov    %esi,%eax
  8014e9:	f7 f1                	div    %ecx
  8014eb:	89 d0                	mov    %edx,%eax
  8014ed:	31 d2                	xor    %edx,%edx
  8014ef:	eb ac                	jmp    80149d <__umoddi3+0x2d>
  8014f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014f8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014fc:	ba 20 00 00 00       	mov    $0x20,%edx
  801501:	29 c2                	sub    %eax,%edx
  801503:	89 c1                	mov    %eax,%ecx
  801505:	89 e8                	mov    %ebp,%eax
  801507:	d3 e7                	shl    %cl,%edi
  801509:	89 d1                	mov    %edx,%ecx
  80150b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80150f:	d3 e8                	shr    %cl,%eax
  801511:	89 c1                	mov    %eax,%ecx
  801513:	8b 44 24 04          	mov    0x4(%esp),%eax
  801517:	09 f9                	or     %edi,%ecx
  801519:	89 df                	mov    %ebx,%edi
  80151b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80151f:	89 c1                	mov    %eax,%ecx
  801521:	d3 e5                	shl    %cl,%ebp
  801523:	89 d1                	mov    %edx,%ecx
  801525:	d3 ef                	shr    %cl,%edi
  801527:	89 c1                	mov    %eax,%ecx
  801529:	89 f0                	mov    %esi,%eax
  80152b:	d3 e3                	shl    %cl,%ebx
  80152d:	89 d1                	mov    %edx,%ecx
  80152f:	89 fa                	mov    %edi,%edx
  801531:	d3 e8                	shr    %cl,%eax
  801533:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801538:	09 d8                	or     %ebx,%eax
  80153a:	f7 74 24 08          	divl   0x8(%esp)
  80153e:	89 d3                	mov    %edx,%ebx
  801540:	d3 e6                	shl    %cl,%esi
  801542:	f7 e5                	mul    %ebp
  801544:	89 c7                	mov    %eax,%edi
  801546:	89 d1                	mov    %edx,%ecx
  801548:	39 d3                	cmp    %edx,%ebx
  80154a:	72 06                	jb     801552 <__umoddi3+0xe2>
  80154c:	75 0e                	jne    80155c <__umoddi3+0xec>
  80154e:	39 c6                	cmp    %eax,%esi
  801550:	73 0a                	jae    80155c <__umoddi3+0xec>
  801552:	29 e8                	sub    %ebp,%eax
  801554:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801558:	89 d1                	mov    %edx,%ecx
  80155a:	89 c7                	mov    %eax,%edi
  80155c:	89 f5                	mov    %esi,%ebp
  80155e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801562:	29 fd                	sub    %edi,%ebp
  801564:	19 cb                	sbb    %ecx,%ebx
  801566:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80156b:	89 d8                	mov    %ebx,%eax
  80156d:	d3 e0                	shl    %cl,%eax
  80156f:	89 f1                	mov    %esi,%ecx
  801571:	d3 ed                	shr    %cl,%ebp
  801573:	d3 eb                	shr    %cl,%ebx
  801575:	09 e8                	or     %ebp,%eax
  801577:	89 da                	mov    %ebx,%edx
  801579:	83 c4 1c             	add    $0x1c,%esp
  80157c:	5b                   	pop    %ebx
  80157d:	5e                   	pop    %esi
  80157e:	5f                   	pop    %edi
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

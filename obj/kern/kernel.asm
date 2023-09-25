
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 9e 00 00 00       	call   f01000dc <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 a8 01 00 00       	call   f01001f2 <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 98 08 ff ff    	lea    -0xf768(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 f5 0a 00 00       	call   f0100b58 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7e 29                	jle    f0100093 <test_backtrace+0x53>
		test_backtrace(x-1);
f010006a:	83 ec 0c             	sub    $0xc,%esp
f010006d:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100070:	50                   	push   %eax
f0100071:	e8 ca ff ff ff       	call   f0100040 <test_backtrace>
f0100076:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f0100079:	83 ec 08             	sub    $0x8,%esp
f010007c:	56                   	push   %esi
f010007d:	8d 83 b4 08 ff ff    	lea    -0xf74c(%ebx),%eax
f0100083:	50                   	push   %eax
f0100084:	e8 cf 0a 00 00       	call   f0100b58 <cprintf>
}
f0100089:	83 c4 10             	add    $0x10,%esp
f010008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010008f:	5b                   	pop    %ebx
f0100090:	5e                   	pop    %esi
f0100091:	5d                   	pop    %ebp
f0100092:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100093:	83 ec 04             	sub    $0x4,%esp
f0100096:	6a 00                	push   $0x0
f0100098:	6a 00                	push   $0x0
f010009a:	6a 00                	push   $0x0
f010009c:	e8 25 08 00 00       	call   f01008c6 <mon_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d3                	jmp    f0100079 <test_backtrace+0x39>

f01000a6 <call_l1e8>:

void 
call_l1e8(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 18             	sub    $0x18,%esp
f01000ad:	e8 40 01 00 00       	call   f01001f2 <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	unsigned int i = 0x00646c72;
f01000b8:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
    cprintf("H%x Wo%s", 57616, &i);
f01000bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01000c2:	50                   	push   %eax
f01000c3:	68 10 e1 00 00       	push   $0xe110
f01000c8:	8d 83 cf 08 ff ff    	lea    -0xf731(%ebx),%eax
f01000ce:	50                   	push   %eax
f01000cf:	e8 84 0a 00 00       	call   f0100b58 <cprintf>
}
f01000d4:	83 c4 10             	add    $0x10,%esp
f01000d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01000da:	c9                   	leave  
f01000db:	c3                   	ret    

f01000dc <i386_init>:

void
i386_init(void)
{
f01000dc:	55                   	push   %ebp
f01000dd:	89 e5                	mov    %esp,%ebp
f01000df:	53                   	push   %ebx
f01000e0:	83 ec 08             	sub    $0x8,%esp
f01000e3:	e8 0a 01 00 00       	call   f01001f2 <__x86.get_pc_thunk.bx>
f01000e8:	81 c3 20 12 01 00    	add    $0x11220,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000ee:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000f4:	c7 c0 c0 36 11 f0    	mov    $0xf01136c0,%eax
f01000fa:	29 d0                	sub    %edx,%eax
f01000fc:	50                   	push   %eax
f01000fd:	6a 00                	push   $0x0
f01000ff:	52                   	push   %edx
f0100100:	e8 59 16 00 00       	call   f010175e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100105:	e8 40 05 00 00       	call   f010064a <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010010a:	83 c4 08             	add    $0x8,%esp
f010010d:	68 ac 1a 00 00       	push   $0x1aac
f0100112:	8d 83 d8 08 ff ff    	lea    -0xf728(%ebx),%eax
f0100118:	50                   	push   %eax
f0100119:	e8 3a 0a 00 00       	call   f0100b58 <cprintf>
	

	//call_l1e8();

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f010011e:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100125:	e8 16 ff ff ff       	call   f0100040 <test_backtrace>
f010012a:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010012d:	83 ec 0c             	sub    $0xc,%esp
f0100130:	6a 00                	push   $0x0
f0100132:	e8 5f 08 00 00       	call   f0100996 <monitor>
f0100137:	83 c4 10             	add    $0x10,%esp
f010013a:	eb f1                	jmp    f010012d <i386_init+0x51>

f010013c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010013c:	55                   	push   %ebp
f010013d:	89 e5                	mov    %esp,%ebp
f010013f:	56                   	push   %esi
f0100140:	53                   	push   %ebx
f0100141:	e8 ac 00 00 00       	call   f01001f2 <__x86.get_pc_thunk.bx>
f0100146:	81 c3 c2 11 01 00    	add    $0x111c2,%ebx
	va_list ap;

	if (panicstr)
f010014c:	83 bb 58 1d 00 00 00 	cmpl   $0x0,0x1d58(%ebx)
f0100153:	74 0f                	je     f0100164 <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100155:	83 ec 0c             	sub    $0xc,%esp
f0100158:	6a 00                	push   $0x0
f010015a:	e8 37 08 00 00       	call   f0100996 <monitor>
f010015f:	83 c4 10             	add    $0x10,%esp
f0100162:	eb f1                	jmp    f0100155 <_panic+0x19>
	panicstr = fmt;
f0100164:	8b 45 10             	mov    0x10(%ebp),%eax
f0100167:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	asm volatile("cli; cld");
f010016d:	fa                   	cli    
f010016e:	fc                   	cld    
	va_start(ap, fmt);
f010016f:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100172:	83 ec 04             	sub    $0x4,%esp
f0100175:	ff 75 0c             	push   0xc(%ebp)
f0100178:	ff 75 08             	push   0x8(%ebp)
f010017b:	8d 83 f3 08 ff ff    	lea    -0xf70d(%ebx),%eax
f0100181:	50                   	push   %eax
f0100182:	e8 d1 09 00 00       	call   f0100b58 <cprintf>
	vcprintf(fmt, ap);
f0100187:	83 c4 08             	add    $0x8,%esp
f010018a:	56                   	push   %esi
f010018b:	ff 75 10             	push   0x10(%ebp)
f010018e:	e8 8e 09 00 00       	call   f0100b21 <vcprintf>
	cprintf("\n");
f0100193:	8d 83 2f 09 ff ff    	lea    -0xf6d1(%ebx),%eax
f0100199:	89 04 24             	mov    %eax,(%esp)
f010019c:	e8 b7 09 00 00       	call   f0100b58 <cprintf>
f01001a1:	83 c4 10             	add    $0x10,%esp
f01001a4:	eb af                	jmp    f0100155 <_panic+0x19>

f01001a6 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01001a6:	55                   	push   %ebp
f01001a7:	89 e5                	mov    %esp,%ebp
f01001a9:	56                   	push   %esi
f01001aa:	53                   	push   %ebx
f01001ab:	e8 42 00 00 00       	call   f01001f2 <__x86.get_pc_thunk.bx>
f01001b0:	81 c3 58 11 01 00    	add    $0x11158,%ebx
	va_list ap;

	va_start(ap, fmt);
f01001b6:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f01001b9:	83 ec 04             	sub    $0x4,%esp
f01001bc:	ff 75 0c             	push   0xc(%ebp)
f01001bf:	ff 75 08             	push   0x8(%ebp)
f01001c2:	8d 83 0b 09 ff ff    	lea    -0xf6f5(%ebx),%eax
f01001c8:	50                   	push   %eax
f01001c9:	e8 8a 09 00 00       	call   f0100b58 <cprintf>
	vcprintf(fmt, ap);
f01001ce:	83 c4 08             	add    $0x8,%esp
f01001d1:	56                   	push   %esi
f01001d2:	ff 75 10             	push   0x10(%ebp)
f01001d5:	e8 47 09 00 00       	call   f0100b21 <vcprintf>
	cprintf("\n");
f01001da:	8d 83 2f 09 ff ff    	lea    -0xf6d1(%ebx),%eax
f01001e0:	89 04 24             	mov    %eax,(%esp)
f01001e3:	e8 70 09 00 00       	call   f0100b58 <cprintf>
	va_end(ap);
}
f01001e8:	83 c4 10             	add    $0x10,%esp
f01001eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001ee:	5b                   	pop    %ebx
f01001ef:	5e                   	pop    %esi
f01001f0:	5d                   	pop    %ebp
f01001f1:	c3                   	ret    

f01001f2 <__x86.get_pc_thunk.bx>:
f01001f2:	8b 1c 24             	mov    (%esp),%ebx
f01001f5:	c3                   	ret    

f01001f6 <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001f6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001fb:	ec                   	in     (%dx),%al
static int bg_col = 0x0;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001fc:	a8 01                	test   $0x1,%al
f01001fe:	74 0a                	je     f010020a <serial_proc_data+0x14>
f0100200:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100205:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100206:	0f b6 c0             	movzbl %al,%eax
f0100209:	c3                   	ret    
		return -1;
f010020a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010020f:	c3                   	ret    

f0100210 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100210:	55                   	push   %ebp
f0100211:	89 e5                	mov    %esp,%ebp
f0100213:	57                   	push   %edi
f0100214:	56                   	push   %esi
f0100215:	53                   	push   %ebx
f0100216:	83 ec 1c             	sub    $0x1c,%esp
f0100219:	e8 6c 05 00 00       	call   f010078a <__x86.get_pc_thunk.si>
f010021e:	81 c6 ea 10 01 00    	add    $0x110ea,%esi
f0100224:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100226:	8d 1d 98 1d 00 00    	lea    0x1d98,%ebx
f010022c:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100232:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100235:	eb 25                	jmp    f010025c <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100237:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f010023e:	8d 51 01             	lea    0x1(%ecx),%edx
f0100241:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100244:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100247:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010024d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100252:	0f 44 d0             	cmove  %eax,%edx
f0100255:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f010025c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010025f:	ff d0                	call   *%eax
f0100261:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100264:	74 06                	je     f010026c <cons_intr+0x5c>
		if (c == 0)
f0100266:	85 c0                	test   %eax,%eax
f0100268:	75 cd                	jne    f0100237 <cons_intr+0x27>
f010026a:	eb f0                	jmp    f010025c <cons_intr+0x4c>
	}
}
f010026c:	83 c4 1c             	add    $0x1c,%esp
f010026f:	5b                   	pop    %ebx
f0100270:	5e                   	pop    %esi
f0100271:	5f                   	pop    %edi
f0100272:	5d                   	pop    %ebp
f0100273:	c3                   	ret    

f0100274 <kbd_proc_data>:
{
f0100274:	55                   	push   %ebp
f0100275:	89 e5                	mov    %esp,%ebp
f0100277:	56                   	push   %esi
f0100278:	53                   	push   %ebx
f0100279:	e8 74 ff ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f010027e:	81 c3 8a 10 01 00    	add    $0x1108a,%ebx
f0100284:	ba 64 00 00 00       	mov    $0x64,%edx
f0100289:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010028a:	a8 01                	test   $0x1,%al
f010028c:	0f 84 f7 00 00 00    	je     f0100389 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f0100292:	a8 20                	test   $0x20,%al
f0100294:	0f 85 f6 00 00 00    	jne    f0100390 <kbd_proc_data+0x11c>
f010029a:	ba 60 00 00 00       	mov    $0x60,%edx
f010029f:	ec                   	in     (%dx),%al
f01002a0:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002a2:	3c e0                	cmp    $0xe0,%al
f01002a4:	74 64                	je     f010030a <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f01002a6:	84 c0                	test   %al,%al
f01002a8:	78 75                	js     f010031f <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f01002aa:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f01002b0:	f6 c1 40             	test   $0x40,%cl
f01002b3:	74 0e                	je     f01002c3 <kbd_proc_data+0x4f>
		data |= 0x80;
f01002b5:	83 c8 80             	or     $0xffffff80,%eax
f01002b8:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002ba:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002bd:	89 8b 78 1d 00 00    	mov    %ecx,0x1d78(%ebx)
	shift |= shiftcode[data];
f01002c3:	0f b6 d2             	movzbl %dl,%edx
f01002c6:	0f b6 84 13 58 0a ff 	movzbl -0xf5a8(%ebx,%edx,1),%eax
f01002cd:	ff 
f01002ce:	0b 83 78 1d 00 00    	or     0x1d78(%ebx),%eax
	shift ^= togglecode[data];
f01002d4:	0f b6 8c 13 58 09 ff 	movzbl -0xf6a8(%ebx,%edx,1),%ecx
f01002db:	ff 
f01002dc:	31 c8                	xor    %ecx,%eax
f01002de:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002e4:	89 c1                	mov    %eax,%ecx
f01002e6:	83 e1 03             	and    $0x3,%ecx
f01002e9:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002f0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002f4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002f7:	a8 08                	test   $0x8,%al
f01002f9:	74 61                	je     f010035c <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002fb:	89 f2                	mov    %esi,%edx
f01002fd:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100300:	83 f9 19             	cmp    $0x19,%ecx
f0100303:	77 4b                	ja     f0100350 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f0100305:	83 ee 20             	sub    $0x20,%esi
f0100308:	eb 0c                	jmp    f0100316 <kbd_proc_data+0xa2>
		shift |= E0ESC;
f010030a:	83 8b 78 1d 00 00 40 	orl    $0x40,0x1d78(%ebx)
		return 0;
f0100311:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100316:	89 f0                	mov    %esi,%eax
f0100318:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010031b:	5b                   	pop    %ebx
f010031c:	5e                   	pop    %esi
f010031d:	5d                   	pop    %ebp
f010031e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010031f:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f0100325:	83 e0 7f             	and    $0x7f,%eax
f0100328:	f6 c1 40             	test   $0x40,%cl
f010032b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010032e:	0f b6 d2             	movzbl %dl,%edx
f0100331:	0f b6 84 13 58 0a ff 	movzbl -0xf5a8(%ebx,%edx,1),%eax
f0100338:	ff 
f0100339:	83 c8 40             	or     $0x40,%eax
f010033c:	0f b6 c0             	movzbl %al,%eax
f010033f:	f7 d0                	not    %eax
f0100341:	21 c8                	and    %ecx,%eax
f0100343:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
		return 0;
f0100349:	be 00 00 00 00       	mov    $0x0,%esi
f010034e:	eb c6                	jmp    f0100316 <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f0100350:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100353:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100356:	83 fa 1a             	cmp    $0x1a,%edx
f0100359:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010035c:	f7 d0                	not    %eax
f010035e:	a8 06                	test   $0x6,%al
f0100360:	75 b4                	jne    f0100316 <kbd_proc_data+0xa2>
f0100362:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100368:	75 ac                	jne    f0100316 <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f010036a:	83 ec 0c             	sub    $0xc,%esp
f010036d:	8d 83 25 09 ff ff    	lea    -0xf6db(%ebx),%eax
f0100373:	50                   	push   %eax
f0100374:	e8 df 07 00 00       	call   f0100b58 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100379:	b8 03 00 00 00       	mov    $0x3,%eax
f010037e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100383:	ee                   	out    %al,(%dx)
}
f0100384:	83 c4 10             	add    $0x10,%esp
f0100387:	eb 8d                	jmp    f0100316 <kbd_proc_data+0xa2>
		return -1;
f0100389:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010038e:	eb 86                	jmp    f0100316 <kbd_proc_data+0xa2>
		return -1;
f0100390:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100395:	e9 7c ff ff ff       	jmp    f0100316 <kbd_proc_data+0xa2>

f010039a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010039a:	55                   	push   %ebp
f010039b:	89 e5                	mov    %esp,%ebp
f010039d:	57                   	push   %edi
f010039e:	56                   	push   %esi
f010039f:	53                   	push   %ebx
f01003a0:	83 ec 1c             	sub    $0x1c,%esp
f01003a3:	e8 4a fe ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f01003a8:	81 c3 60 0f 01 00    	add    $0x10f60,%ebx
f01003ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f01003b1:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003b6:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01003bb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003c0:	89 fa                	mov    %edi,%edx
f01003c2:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003c3:	a8 20                	test   $0x20,%al
f01003c5:	75 13                	jne    f01003da <cons_putc+0x40>
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 0b                	jg     f01003da <cons_putc+0x40>
f01003cf:	89 ca                	mov    %ecx,%edx
f01003d1:	ec                   	in     (%dx),%al
f01003d2:	ec                   	in     (%dx),%al
f01003d3:	ec                   	in     (%dx),%al
f01003d4:	ec                   	in     (%dx),%al
	     i++)
f01003d5:	83 c6 01             	add    $0x1,%esi
f01003d8:	eb e6                	jmp    f01003c0 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003da:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f01003de:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003e1:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003e6:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003e7:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ec:	bf 79 03 00 00       	mov    $0x379,%edi
f01003f1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f6:	89 fa                	mov    %edi,%edx
f01003f8:	ec                   	in     (%dx),%al
f01003f9:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ff:	7f 0f                	jg     f0100410 <cons_putc+0x76>
f0100401:	84 c0                	test   %al,%al
f0100403:	78 0b                	js     f0100410 <cons_putc+0x76>
f0100405:	89 ca                	mov    %ecx,%edx
f0100407:	ec                   	in     (%dx),%al
f0100408:	ec                   	in     (%dx),%al
f0100409:	ec                   	in     (%dx),%al
f010040a:	ec                   	in     (%dx),%al
f010040b:	83 c6 01             	add    $0x1,%esi
f010040e:	eb e6                	jmp    f01003f6 <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100410:	ba 78 03 00 00       	mov    $0x378,%edx
f0100415:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100419:	ee                   	out    %al,(%dx)
f010041a:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010041f:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100424:	ee                   	out    %al,(%dx)
f0100425:	b8 08 00 00 00       	mov    $0x8,%eax
f010042a:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010042b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010042e:	89 f8                	mov    %edi,%eax
f0100430:	80 cc 07             	or     $0x7,%ah
f0100433:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100439:	0f 45 c7             	cmovne %edi,%eax
f010043c:	89 c7                	mov    %eax,%edi
f010043e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100441:	0f b6 c0             	movzbl %al,%eax
f0100444:	89 f9                	mov    %edi,%ecx
f0100446:	80 f9 0a             	cmp    $0xa,%cl
f0100449:	0f 84 e4 00 00 00    	je     f0100533 <cons_putc+0x199>
f010044f:	83 f8 0a             	cmp    $0xa,%eax
f0100452:	7f 46                	jg     f010049a <cons_putc+0x100>
f0100454:	83 f8 08             	cmp    $0x8,%eax
f0100457:	0f 84 a8 00 00 00    	je     f0100505 <cons_putc+0x16b>
f010045d:	83 f8 09             	cmp    $0x9,%eax
f0100460:	0f 85 da 00 00 00    	jne    f0100540 <cons_putc+0x1a6>
		cons_putc(' ');
f0100466:	b8 20 00 00 00       	mov    $0x20,%eax
f010046b:	e8 2a ff ff ff       	call   f010039a <cons_putc>
		cons_putc(' ');
f0100470:	b8 20 00 00 00       	mov    $0x20,%eax
f0100475:	e8 20 ff ff ff       	call   f010039a <cons_putc>
		cons_putc(' ');
f010047a:	b8 20 00 00 00       	mov    $0x20,%eax
f010047f:	e8 16 ff ff ff       	call   f010039a <cons_putc>
		cons_putc(' ');
f0100484:	b8 20 00 00 00       	mov    $0x20,%eax
f0100489:	e8 0c ff ff ff       	call   f010039a <cons_putc>
		cons_putc(' ');
f010048e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100493:	e8 02 ff ff ff       	call   f010039a <cons_putc>
		break;
f0100498:	eb 26                	jmp    f01004c0 <cons_putc+0x126>
	switch (c & 0xff) {
f010049a:	83 f8 0d             	cmp    $0xd,%eax
f010049d:	0f 85 9d 00 00 00    	jne    f0100540 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01004a3:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f01004aa:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004b0:	c1 e8 16             	shr    $0x16,%eax
f01004b3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004b6:	c1 e0 04             	shl    $0x4,%eax
f01004b9:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01004c0:	66 81 bb a0 1f 00 00 	cmpw   $0x7cf,0x1fa0(%ebx)
f01004c7:	cf 07 
f01004c9:	0f 87 98 00 00 00    	ja     f0100567 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f01004cf:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f01004d5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004da:	89 ca                	mov    %ecx,%edx
f01004dc:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004dd:	0f b7 9b a0 1f 00 00 	movzwl 0x1fa0(%ebx),%ebx
f01004e4:	8d 71 01             	lea    0x1(%ecx),%esi
f01004e7:	89 d8                	mov    %ebx,%eax
f01004e9:	66 c1 e8 08          	shr    $0x8,%ax
f01004ed:	89 f2                	mov    %esi,%edx
f01004ef:	ee                   	out    %al,(%dx)
f01004f0:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004f5:	89 ca                	mov    %ecx,%edx
f01004f7:	ee                   	out    %al,(%dx)
f01004f8:	89 d8                	mov    %ebx,%eax
f01004fa:	89 f2                	mov    %esi,%edx
f01004fc:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100500:	5b                   	pop    %ebx
f0100501:	5e                   	pop    %esi
f0100502:	5f                   	pop    %edi
f0100503:	5d                   	pop    %ebp
f0100504:	c3                   	ret    
		if (crt_pos > 0) {
f0100505:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f010050c:	66 85 c0             	test   %ax,%ax
f010050f:	74 be                	je     f01004cf <cons_putc+0x135>
			crt_pos--;
f0100511:	83 e8 01             	sub    $0x1,%eax
f0100514:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010051b:	0f b7 c0             	movzwl %ax,%eax
f010051e:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100522:	b2 00                	mov    $0x0,%dl
f0100524:	83 ca 20             	or     $0x20,%edx
f0100527:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f010052d:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100531:	eb 8d                	jmp    f01004c0 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f0100533:	66 83 83 a0 1f 00 00 	addw   $0x50,0x1fa0(%ebx)
f010053a:	50 
f010053b:	e9 63 ff ff ff       	jmp    f01004a3 <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100540:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100547:	8d 50 01             	lea    0x1(%eax),%edx
f010054a:	66 89 93 a0 1f 00 00 	mov    %dx,0x1fa0(%ebx)
f0100551:	0f b7 c0             	movzwl %ax,%eax
f0100554:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f010055a:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f010055e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100562:	e9 59 ff ff ff       	jmp    f01004c0 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100567:	8b 83 a4 1f 00 00    	mov    0x1fa4(%ebx),%eax
f010056d:	83 ec 04             	sub    $0x4,%esp
f0100570:	68 00 0f 00 00       	push   $0xf00
f0100575:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010057b:	52                   	push   %edx
f010057c:	50                   	push   %eax
f010057d:	e8 22 12 00 00       	call   f01017a4 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100582:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100588:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010058e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100594:	83 c4 10             	add    $0x10,%esp
f0100597:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010059c:	83 c0 02             	add    $0x2,%eax
f010059f:	39 d0                	cmp    %edx,%eax
f01005a1:	75 f4                	jne    f0100597 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f01005a3:	66 83 ab a0 1f 00 00 	subw   $0x50,0x1fa0(%ebx)
f01005aa:	50 
f01005ab:	e9 1f ff ff ff       	jmp    f01004cf <cons_putc+0x135>

f01005b0 <serial_intr>:
{
f01005b0:	e8 d1 01 00 00       	call   f0100786 <__x86.get_pc_thunk.ax>
f01005b5:	05 53 0d 01 00       	add    $0x10d53,%eax
	if (serial_exists)
f01005ba:	80 b8 ac 1f 00 00 00 	cmpb   $0x0,0x1fac(%eax)
f01005c1:	75 01                	jne    f01005c4 <serial_intr+0x14>
f01005c3:	c3                   	ret    
{
f01005c4:	55                   	push   %ebp
f01005c5:	89 e5                	mov    %esp,%ebp
f01005c7:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005ca:	8d 80 ee ee fe ff    	lea    -0x11112(%eax),%eax
f01005d0:	e8 3b fc ff ff       	call   f0100210 <cons_intr>
}
f01005d5:	c9                   	leave  
f01005d6:	c3                   	ret    

f01005d7 <set_fg_col>:
}
f01005d7:	c3                   	ret    

f01005d8 <set_bg_col>:
}
f01005d8:	c3                   	ret    

f01005d9 <kbd_intr>:
{
f01005d9:	55                   	push   %ebp
f01005da:	89 e5                	mov    %esp,%ebp
f01005dc:	83 ec 08             	sub    $0x8,%esp
f01005df:	e8 a2 01 00 00       	call   f0100786 <__x86.get_pc_thunk.ax>
f01005e4:	05 24 0d 01 00       	add    $0x10d24,%eax
	cons_intr(kbd_proc_data);
f01005e9:	8d 80 6c ef fe ff    	lea    -0x11094(%eax),%eax
f01005ef:	e8 1c fc ff ff       	call   f0100210 <cons_intr>
}
f01005f4:	c9                   	leave  
f01005f5:	c3                   	ret    

f01005f6 <cons_getc>:
{
f01005f6:	55                   	push   %ebp
f01005f7:	89 e5                	mov    %esp,%ebp
f01005f9:	53                   	push   %ebx
f01005fa:	83 ec 04             	sub    $0x4,%esp
f01005fd:	e8 f0 fb ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f0100602:	81 c3 06 0d 01 00    	add    $0x10d06,%ebx
	serial_intr();
f0100608:	e8 a3 ff ff ff       	call   f01005b0 <serial_intr>
	kbd_intr();
f010060d:	e8 c7 ff ff ff       	call   f01005d9 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100612:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
	return 0;
f0100618:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010061d:	3b 83 9c 1f 00 00    	cmp    0x1f9c(%ebx),%eax
f0100623:	74 1e                	je     f0100643 <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f0100625:	8d 48 01             	lea    0x1(%eax),%ecx
f0100628:	0f b6 94 03 98 1d 00 	movzbl 0x1d98(%ebx,%eax,1),%edx
f010062f:	00 
			cons.rpos = 0;
f0100630:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100635:	b8 00 00 00 00       	mov    $0x0,%eax
f010063a:	0f 45 c1             	cmovne %ecx,%eax
f010063d:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
}
f0100643:	89 d0                	mov    %edx,%eax
f0100645:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100648:	c9                   	leave  
f0100649:	c3                   	ret    

f010064a <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010064a:	55                   	push   %ebp
f010064b:	89 e5                	mov    %esp,%ebp
f010064d:	57                   	push   %edi
f010064e:	56                   	push   %esi
f010064f:	53                   	push   %ebx
f0100650:	83 ec 1c             	sub    $0x1c,%esp
f0100653:	e8 9a fb ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f0100658:	81 c3 b0 0c 01 00    	add    $0x10cb0,%ebx
	was = *cp;
f010065e:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100665:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066c:	5a a5 
	if (*cp != 0xA55A) {
f010066e:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100675:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010067a:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f010067f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100683:	0f 84 ac 00 00 00    	je     f0100735 <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100689:	89 8b a8 1f 00 00    	mov    %ecx,0x1fa8(%ebx)
f010068f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100694:	89 ca                	mov    %ecx,%edx
f0100696:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100697:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069a:	89 f2                	mov    %esi,%edx
f010069c:	ec                   	in     (%dx),%al
f010069d:	0f b6 c0             	movzbl %al,%eax
f01006a0:	c1 e0 08             	shl    $0x8,%eax
f01006a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ab:	89 ca                	mov    %ecx,%edx
f01006ad:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ae:	89 f2                	mov    %esi,%edx
f01006b0:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006b1:	89 bb a4 1f 00 00    	mov    %edi,0x1fa4(%ebx)
	pos |= inb(addr_6845 + 1);
f01006b7:	0f b6 c0             	movzbl %al,%eax
f01006ba:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f01006bd:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006c9:	89 c8                	mov    %ecx,%eax
f01006cb:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006d0:	ee                   	out    %al,(%dx)
f01006d1:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006d6:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006db:	89 fa                	mov    %edi,%edx
f01006dd:	ee                   	out    %al,(%dx)
f01006de:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006e3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006ee:	89 c8                	mov    %ecx,%eax
f01006f0:	89 f2                	mov    %esi,%edx
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	b8 03 00 00 00       	mov    $0x3,%eax
f01006f8:	89 fa                	mov    %edi,%edx
f01006fa:	ee                   	out    %al,(%dx)
f01006fb:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100700:	89 c8                	mov    %ecx,%eax
f0100702:	ee                   	out    %al,(%dx)
f0100703:	b8 01 00 00 00       	mov    $0x1,%eax
f0100708:	89 f2                	mov    %esi,%edx
f010070a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100710:	ec                   	in     (%dx),%al
f0100711:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100713:	3c ff                	cmp    $0xff,%al
f0100715:	0f 95 83 ac 1f 00 00 	setne  0x1fac(%ebx)
f010071c:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100721:	ec                   	in     (%dx),%al
f0100722:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100727:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100728:	80 f9 ff             	cmp    $0xff,%cl
f010072b:	74 1e                	je     f010074b <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f010072d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100730:	5b                   	pop    %ebx
f0100731:	5e                   	pop    %esi
f0100732:	5f                   	pop    %edi
f0100733:	5d                   	pop    %ebp
f0100734:	c3                   	ret    
		*cp = was;
f0100735:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f010073c:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100741:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f0100746:	e9 3e ff ff ff       	jmp    f0100689 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f010074b:	83 ec 0c             	sub    $0xc,%esp
f010074e:	8d 83 31 09 ff ff    	lea    -0xf6cf(%ebx),%eax
f0100754:	50                   	push   %eax
f0100755:	e8 fe 03 00 00       	call   f0100b58 <cprintf>
f010075a:	83 c4 10             	add    $0x10,%esp
}
f010075d:	eb ce                	jmp    f010072d <cons_init+0xe3>

f010075f <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010075f:	55                   	push   %ebp
f0100760:	89 e5                	mov    %esp,%ebp
f0100762:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100765:	8b 45 08             	mov    0x8(%ebp),%eax
f0100768:	e8 2d fc ff ff       	call   f010039a <cons_putc>
}
f010076d:	c9                   	leave  
f010076e:	c3                   	ret    

f010076f <getchar>:

int
getchar(void)
{
f010076f:	55                   	push   %ebp
f0100770:	89 e5                	mov    %esp,%ebp
f0100772:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100775:	e8 7c fe ff ff       	call   f01005f6 <cons_getc>
f010077a:	85 c0                	test   %eax,%eax
f010077c:	74 f7                	je     f0100775 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010077e:	c9                   	leave  
f010077f:	c3                   	ret    

f0100780 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100780:	b8 01 00 00 00       	mov    $0x1,%eax
f0100785:	c3                   	ret    

f0100786 <__x86.get_pc_thunk.ax>:
f0100786:	8b 04 24             	mov    (%esp),%eax
f0100789:	c3                   	ret    

f010078a <__x86.get_pc_thunk.si>:
f010078a:	8b 34 24             	mov    (%esp),%esi
f010078d:	c3                   	ret    

f010078e <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010078e:	55                   	push   %ebp
f010078f:	89 e5                	mov    %esp,%ebp
f0100791:	56                   	push   %esi
f0100792:	53                   	push   %ebx
f0100793:	e8 5a fa ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f0100798:	81 c3 70 0b 01 00    	add    $0x10b70,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079e:	83 ec 04             	sub    $0x4,%esp
f01007a1:	8d 83 58 0b ff ff    	lea    -0xf4a8(%ebx),%eax
f01007a7:	50                   	push   %eax
f01007a8:	8d 83 76 0b ff ff    	lea    -0xf48a(%ebx),%eax
f01007ae:	50                   	push   %eax
f01007af:	8d b3 7b 0b ff ff    	lea    -0xf485(%ebx),%esi
f01007b5:	56                   	push   %esi
f01007b6:	e8 9d 03 00 00       	call   f0100b58 <cprintf>
f01007bb:	83 c4 0c             	add    $0xc,%esp
f01007be:	8d 83 34 0c ff ff    	lea    -0xf3cc(%ebx),%eax
f01007c4:	50                   	push   %eax
f01007c5:	8d 83 84 0b ff ff    	lea    -0xf47c(%ebx),%eax
f01007cb:	50                   	push   %eax
f01007cc:	56                   	push   %esi
f01007cd:	e8 86 03 00 00       	call   f0100b58 <cprintf>
f01007d2:	83 c4 0c             	add    $0xc,%esp
f01007d5:	8d 83 5c 0c ff ff    	lea    -0xf3a4(%ebx),%eax
f01007db:	50                   	push   %eax
f01007dc:	8d 83 8d 0b ff ff    	lea    -0xf473(%ebx),%eax
f01007e2:	50                   	push   %eax
f01007e3:	56                   	push   %esi
f01007e4:	e8 6f 03 00 00       	call   f0100b58 <cprintf>
	return 0;
}
f01007e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007f1:	5b                   	pop    %ebx
f01007f2:	5e                   	pop    %esi
f01007f3:	5d                   	pop    %ebp
f01007f4:	c3                   	ret    

f01007f5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f5:	55                   	push   %ebp
f01007f6:	89 e5                	mov    %esp,%ebp
f01007f8:	57                   	push   %edi
f01007f9:	56                   	push   %esi
f01007fa:	53                   	push   %ebx
f01007fb:	83 ec 18             	sub    $0x18,%esp
f01007fe:	e8 ef f9 ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f0100803:	81 c3 05 0b 01 00    	add    $0x10b05,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100809:	8d 83 97 0b ff ff    	lea    -0xf469(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 43 03 00 00       	call   f0100b58 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100815:	83 c4 08             	add    $0x8,%esp
f0100818:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f010081e:	8d 83 88 0c ff ff    	lea    -0xf378(%ebx),%eax
f0100824:	50                   	push   %eax
f0100825:	e8 2e 03 00 00       	call   f0100b58 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082a:	83 c4 0c             	add    $0xc,%esp
f010082d:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100833:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100839:	50                   	push   %eax
f010083a:	57                   	push   %edi
f010083b:	8d 83 b0 0c ff ff    	lea    -0xf350(%ebx),%eax
f0100841:	50                   	push   %eax
f0100842:	e8 11 03 00 00       	call   f0100b58 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100847:	83 c4 0c             	add    $0xc,%esp
f010084a:	c7 c0 81 1b 10 f0    	mov    $0xf0101b81,%eax
f0100850:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100856:	52                   	push   %edx
f0100857:	50                   	push   %eax
f0100858:	8d 83 d4 0c ff ff    	lea    -0xf32c(%ebx),%eax
f010085e:	50                   	push   %eax
f010085f:	e8 f4 02 00 00       	call   f0100b58 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100864:	83 c4 0c             	add    $0xc,%esp
f0100867:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010086d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100873:	52                   	push   %edx
f0100874:	50                   	push   %eax
f0100875:	8d 83 f8 0c ff ff    	lea    -0xf308(%ebx),%eax
f010087b:	50                   	push   %eax
f010087c:	e8 d7 02 00 00       	call   f0100b58 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100881:	83 c4 0c             	add    $0xc,%esp
f0100884:	c7 c6 c0 36 11 f0    	mov    $0xf01136c0,%esi
f010088a:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100890:	50                   	push   %eax
f0100891:	56                   	push   %esi
f0100892:	8d 83 1c 0d ff ff    	lea    -0xf2e4(%ebx),%eax
f0100898:	50                   	push   %eax
f0100899:	e8 ba 02 00 00       	call   f0100b58 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010089e:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008a1:	29 fe                	sub    %edi,%esi
f01008a3:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008a9:	c1 fe 0a             	sar    $0xa,%esi
f01008ac:	56                   	push   %esi
f01008ad:	8d 83 40 0d ff ff    	lea    -0xf2c0(%ebx),%eax
f01008b3:	50                   	push   %eax
f01008b4:	e8 9f 02 00 00       	call   f0100b58 <cprintf>
	return 0;
}
f01008b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008c1:	5b                   	pop    %ebx
f01008c2:	5e                   	pop    %esi
f01008c3:	5f                   	pop    %edi
f01008c4:	5d                   	pop    %ebp
f01008c5:	c3                   	ret    

f01008c6 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c6:	55                   	push   %ebp
f01008c7:	89 e5                	mov    %esp,%ebp
f01008c9:	57                   	push   %edi
f01008ca:	56                   	push   %esi
f01008cb:	53                   	push   %ebx
f01008cc:	83 ec 48             	sub    $0x48,%esp
f01008cf:	e8 1e f9 ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f01008d4:	81 c3 34 0a 01 00    	add    $0x10a34,%ebx
	cprintf("Stack backtrace:\n");
f01008da:	8d 83 b0 0b ff ff    	lea    -0xf450(%ebx),%eax
f01008e0:	50                   	push   %eax
f01008e1:	e8 72 02 00 00       	call   f0100b58 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008e6:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp, eip;
	struct Eipdebuginfo info;

	ebp = (uint32_t *)read_ebp();
f01008e8:	89 c7                	mov    %eax,%edi
	while (ebp) {
f01008ea:	83 c4 10             	add    $0x10,%esp
		eip = *(ebp + 1);
		debuginfo_eip(eip, &info);
		cprintf("  ebp %08x  eip %08x  args", ebp, eip);
f01008ed:	8d 83 c2 0b ff ff    	lea    -0xf43e(%ebx),%eax
f01008f3:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (int i = 0; i < 5; i++) {
			cprintf(" %08x", *(ebp + 2 + i));
f01008f6:	8d 83 dd 0b ff ff    	lea    -0xf423(%ebx),%eax
f01008fc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (ebp) {
f01008ff:	eb 39                	jmp    f010093a <mon_backtrace+0x74>
			if (i == 4) {
				cprintf("\n");
f0100901:	83 ec 0c             	sub    $0xc,%esp
f0100904:	8d 83 2f 09 ff ff    	lea    -0xf6d1(%ebx),%eax
f010090a:	50                   	push   %eax
f010090b:	e8 48 02 00 00       	call   f0100b58 <cprintf>
f0100910:	83 c4 10             	add    $0x10,%esp
			}
		}
		cprintf("		 %s:%d: %.*s+%d\n", info.eip_file, info.eip_line,
f0100913:	83 ec 08             	sub    $0x8,%esp
f0100916:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100919:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010091c:	50                   	push   %eax
f010091d:	ff 75 d8             	push   -0x28(%ebp)
f0100920:	ff 75 dc             	push   -0x24(%ebp)
f0100923:	ff 75 d4             	push   -0x2c(%ebp)
f0100926:	ff 75 d0             	push   -0x30(%ebp)
f0100929:	8d 83 e3 0b ff ff    	lea    -0xf41d(%ebx),%eax
f010092f:	50                   	push   %eax
f0100930:	e8 23 02 00 00       	call   f0100b58 <cprintf>
			info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t *)*ebp;
f0100935:	8b 3f                	mov    (%edi),%edi
f0100937:	83 c4 20             	add    $0x20,%esp
	while (ebp) {
f010093a:	85 ff                	test   %edi,%edi
f010093c:	74 4b                	je     f0100989 <mon_backtrace+0xc3>
		eip = *(ebp + 1);
f010093e:	8b 47 04             	mov    0x4(%edi),%eax
f0100941:	89 c6                	mov    %eax,%esi
f0100943:	89 45 c0             	mov    %eax,-0x40(%ebp)
		debuginfo_eip(eip, &info);
f0100946:	83 ec 08             	sub    $0x8,%esp
f0100949:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010094c:	50                   	push   %eax
f010094d:	56                   	push   %esi
f010094e:	e8 0e 03 00 00       	call   f0100c61 <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args", ebp, eip);
f0100953:	83 c4 0c             	add    $0xc,%esp
f0100956:	56                   	push   %esi
f0100957:	57                   	push   %edi
f0100958:	ff 75 bc             	push   -0x44(%ebp)
f010095b:	e8 f8 01 00 00       	call   f0100b58 <cprintf>
f0100960:	83 c4 10             	add    $0x10,%esp
		for (int i = 0; i < 5; i++) {
f0100963:	be 00 00 00 00       	mov    $0x0,%esi
			cprintf(" %08x", *(ebp + 2 + i));
f0100968:	83 ec 08             	sub    $0x8,%esp
f010096b:	ff 74 b7 08          	push   0x8(%edi,%esi,4)
f010096f:	ff 75 c4             	push   -0x3c(%ebp)
f0100972:	e8 e1 01 00 00       	call   f0100b58 <cprintf>
			if (i == 4) {
f0100977:	83 c4 10             	add    $0x10,%esp
f010097a:	83 fe 04             	cmp    $0x4,%esi
f010097d:	74 82                	je     f0100901 <mon_backtrace+0x3b>
		for (int i = 0; i < 5; i++) {
f010097f:	83 c6 01             	add    $0x1,%esi
f0100982:	83 fe 05             	cmp    $0x5,%esi
f0100985:	75 e1                	jne    f0100968 <mon_backtrace+0xa2>
f0100987:	eb 8a                	jmp    f0100913 <mon_backtrace+0x4d>
	}
	return 0;
}
f0100989:	b8 00 00 00 00       	mov    $0x0,%eax
f010098e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100991:	5b                   	pop    %ebx
f0100992:	5e                   	pop    %esi
f0100993:	5f                   	pop    %edi
f0100994:	5d                   	pop    %ebp
f0100995:	c3                   	ret    

f0100996 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100996:	55                   	push   %ebp
f0100997:	89 e5                	mov    %esp,%ebp
f0100999:	57                   	push   %edi
f010099a:	56                   	push   %esi
f010099b:	53                   	push   %ebx
f010099c:	83 ec 68             	sub    $0x68,%esp
f010099f:	e8 4e f8 ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f01009a4:	81 c3 64 09 01 00    	add    $0x10964,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009aa:	8d 83 6c 0d ff ff    	lea    -0xf294(%ebx),%eax
f01009b0:	50                   	push   %eax
f01009b1:	e8 a2 01 00 00       	call   f0100b58 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009b6:	8d 83 90 0d ff ff    	lea    -0xf270(%ebx),%eax
f01009bc:	89 04 24             	mov    %eax,(%esp)
f01009bf:	e8 94 01 00 00       	call   f0100b58 <cprintf>
f01009c4:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009c7:	8d bb fa 0b ff ff    	lea    -0xf406(%ebx),%edi
f01009cd:	eb 4a                	jmp    f0100a19 <monitor+0x83>
f01009cf:	83 ec 08             	sub    $0x8,%esp
f01009d2:	0f be c0             	movsbl %al,%eax
f01009d5:	50                   	push   %eax
f01009d6:	57                   	push   %edi
f01009d7:	e8 43 0d 00 00       	call   f010171f <strchr>
f01009dc:	83 c4 10             	add    $0x10,%esp
f01009df:	85 c0                	test   %eax,%eax
f01009e1:	74 08                	je     f01009eb <monitor+0x55>
			*buf++ = 0;
f01009e3:	c6 06 00             	movb   $0x0,(%esi)
f01009e6:	8d 76 01             	lea    0x1(%esi),%esi
f01009e9:	eb 76                	jmp    f0100a61 <monitor+0xcb>
		if (*buf == 0)
f01009eb:	80 3e 00             	cmpb   $0x0,(%esi)
f01009ee:	74 7c                	je     f0100a6c <monitor+0xd6>
		if (argc == MAXARGS-1) {
f01009f0:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009f4:	74 0f                	je     f0100a05 <monitor+0x6f>
		argv[argc++] = buf;
f01009f6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009f9:	8d 48 01             	lea    0x1(%eax),%ecx
f01009fc:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009ff:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a03:	eb 41                	jmp    f0100a46 <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a05:	83 ec 08             	sub    $0x8,%esp
f0100a08:	6a 10                	push   $0x10
f0100a0a:	8d 83 ff 0b ff ff    	lea    -0xf401(%ebx),%eax
f0100a10:	50                   	push   %eax
f0100a11:	e8 42 01 00 00       	call   f0100b58 <cprintf>
			return 0;
f0100a16:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a19:	8d 83 f6 0b ff ff    	lea    -0xf40a(%ebx),%eax
f0100a1f:	89 c6                	mov    %eax,%esi
f0100a21:	83 ec 0c             	sub    $0xc,%esp
f0100a24:	56                   	push   %esi
f0100a25:	e8 a4 0a 00 00       	call   f01014ce <readline>
		if (buf != NULL)
f0100a2a:	83 c4 10             	add    $0x10,%esp
f0100a2d:	85 c0                	test   %eax,%eax
f0100a2f:	74 f0                	je     f0100a21 <monitor+0x8b>
	argv[argc] = 0;
f0100a31:	89 c6                	mov    %eax,%esi
f0100a33:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a3a:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a41:	eb 1e                	jmp    f0100a61 <monitor+0xcb>
			buf++;
f0100a43:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a46:	0f b6 06             	movzbl (%esi),%eax
f0100a49:	84 c0                	test   %al,%al
f0100a4b:	74 14                	je     f0100a61 <monitor+0xcb>
f0100a4d:	83 ec 08             	sub    $0x8,%esp
f0100a50:	0f be c0             	movsbl %al,%eax
f0100a53:	50                   	push   %eax
f0100a54:	57                   	push   %edi
f0100a55:	e8 c5 0c 00 00       	call   f010171f <strchr>
f0100a5a:	83 c4 10             	add    $0x10,%esp
f0100a5d:	85 c0                	test   %eax,%eax
f0100a5f:	74 e2                	je     f0100a43 <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a61:	0f b6 06             	movzbl (%esi),%eax
f0100a64:	84 c0                	test   %al,%al
f0100a66:	0f 85 63 ff ff ff    	jne    f01009cf <monitor+0x39>
	argv[argc] = 0;
f0100a6c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a6f:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a76:	00 
	if (argc == 0)
f0100a77:	85 c0                	test   %eax,%eax
f0100a79:	74 9e                	je     f0100a19 <monitor+0x83>
f0100a7b:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a81:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a86:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a89:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a8b:	83 ec 08             	sub    $0x8,%esp
f0100a8e:	ff 36                	push   (%esi)
f0100a90:	ff 75 a8             	push   -0x58(%ebp)
f0100a93:	e8 27 0c 00 00       	call   f01016bf <strcmp>
f0100a98:	83 c4 10             	add    $0x10,%esp
f0100a9b:	85 c0                	test   %eax,%eax
f0100a9d:	74 28                	je     f0100ac7 <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a9f:	83 c7 01             	add    $0x1,%edi
f0100aa2:	83 c6 0c             	add    $0xc,%esi
f0100aa5:	83 ff 03             	cmp    $0x3,%edi
f0100aa8:	75 e1                	jne    f0100a8b <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aaa:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100aad:	83 ec 08             	sub    $0x8,%esp
f0100ab0:	ff 75 a8             	push   -0x58(%ebp)
f0100ab3:	8d 83 1c 0c ff ff    	lea    -0xf3e4(%ebx),%eax
f0100ab9:	50                   	push   %eax
f0100aba:	e8 99 00 00 00       	call   f0100b58 <cprintf>
	return 0;
f0100abf:	83 c4 10             	add    $0x10,%esp
f0100ac2:	e9 52 ff ff ff       	jmp    f0100a19 <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100ac7:	89 f8                	mov    %edi,%eax
f0100ac9:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100acc:	83 ec 04             	sub    $0x4,%esp
f0100acf:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100ad2:	ff 75 08             	push   0x8(%ebp)
f0100ad5:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ad8:	52                   	push   %edx
f0100ad9:	ff 75 a4             	push   -0x5c(%ebp)
f0100adc:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100ae3:	83 c4 10             	add    $0x10,%esp
f0100ae6:	85 c0                	test   %eax,%eax
f0100ae8:	0f 89 2b ff ff ff    	jns    f0100a19 <monitor+0x83>
				break;
	}
}
f0100aee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100af1:	5b                   	pop    %ebx
f0100af2:	5e                   	pop    %esi
f0100af3:	5f                   	pop    %edi
f0100af4:	5d                   	pop    %ebp
f0100af5:	c3                   	ret    

f0100af6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100af6:	55                   	push   %ebp
f0100af7:	89 e5                	mov    %esp,%ebp
f0100af9:	56                   	push   %esi
f0100afa:	53                   	push   %ebx
f0100afb:	e8 f2 f6 ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f0100b00:	81 c3 08 08 01 00    	add    $0x10808,%ebx
f0100b06:	8b 75 0c             	mov    0xc(%ebp),%esi
	cputchar(ch);
f0100b09:	83 ec 0c             	sub    $0xc,%esp
f0100b0c:	ff 75 08             	push   0x8(%ebp)
f0100b0f:	e8 4b fc ff ff       	call   f010075f <cputchar>
	(*cnt)++;
f0100b14:	83 06 01             	addl   $0x1,(%esi)
}
f0100b17:	83 c4 10             	add    $0x10,%esp
f0100b1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b1d:	5b                   	pop    %ebx
f0100b1e:	5e                   	pop    %esi
f0100b1f:	5d                   	pop    %ebp
f0100b20:	c3                   	ret    

f0100b21 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b21:	55                   	push   %ebp
f0100b22:	89 e5                	mov    %esp,%ebp
f0100b24:	53                   	push   %ebx
f0100b25:	83 ec 14             	sub    $0x14,%esp
f0100b28:	e8 c5 f6 ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f0100b2d:	81 c3 db 07 01 00    	add    $0x107db,%ebx
	int cnt = 0;
f0100b33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b3a:	ff 75 0c             	push   0xc(%ebp)
f0100b3d:	ff 75 08             	push   0x8(%ebp)
f0100b40:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b43:	50                   	push   %eax
f0100b44:	8d 83 ee f7 fe ff    	lea    -0x10812(%ebx),%eax
f0100b4a:	50                   	push   %eax
f0100b4b:	e8 5d 04 00 00       	call   f0100fad <vprintfmt>
	return cnt;
}
f0100b50:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b56:	c9                   	leave  
f0100b57:	c3                   	ret    

f0100b58 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b58:	55                   	push   %ebp
f0100b59:	89 e5                	mov    %esp,%ebp
f0100b5b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b5e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b61:	50                   	push   %eax
f0100b62:	ff 75 08             	push   0x8(%ebp)
f0100b65:	e8 b7 ff ff ff       	call   f0100b21 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b6a:	c9                   	leave  
f0100b6b:	c3                   	ret    

f0100b6c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b6c:	55                   	push   %ebp
f0100b6d:	89 e5                	mov    %esp,%ebp
f0100b6f:	57                   	push   %edi
f0100b70:	56                   	push   %esi
f0100b71:	53                   	push   %ebx
f0100b72:	83 ec 14             	sub    $0x14,%esp
f0100b75:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b7b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b7e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b81:	8b 1a                	mov    (%edx),%ebx
f0100b83:	8b 01                	mov    (%ecx),%eax
f0100b85:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b88:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b8f:	eb 2f                	jmp    f0100bc0 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b91:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b94:	39 c3                	cmp    %eax,%ebx
f0100b96:	7f 4e                	jg     f0100be6 <stab_binsearch+0x7a>
f0100b98:	0f b6 0a             	movzbl (%edx),%ecx
f0100b9b:	83 ea 0c             	sub    $0xc,%edx
f0100b9e:	39 f1                	cmp    %esi,%ecx
f0100ba0:	75 ef                	jne    f0100b91 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100ba2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ba5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ba8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100bac:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100baf:	73 3a                	jae    f0100beb <stab_binsearch+0x7f>
			*region_left = m;
f0100bb1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bb4:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100bb6:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100bb9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100bc0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100bc3:	7f 53                	jg     f0100c18 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100bc8:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100bcb:	89 d0                	mov    %edx,%eax
f0100bcd:	c1 e8 1f             	shr    $0x1f,%eax
f0100bd0:	01 d0                	add    %edx,%eax
f0100bd2:	89 c7                	mov    %eax,%edi
f0100bd4:	d1 ff                	sar    %edi
f0100bd6:	83 e0 fe             	and    $0xfffffffe,%eax
f0100bd9:	01 f8                	add    %edi,%eax
f0100bdb:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bde:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100be2:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100be4:	eb ae                	jmp    f0100b94 <stab_binsearch+0x28>
			l = true_m + 1;
f0100be6:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100be9:	eb d5                	jmp    f0100bc0 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100beb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bee:	76 14                	jbe    f0100c04 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100bf0:	83 e8 01             	sub    $0x1,%eax
f0100bf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bf6:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bf9:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100bfb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c02:	eb bc                	jmp    f0100bc0 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100c04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c07:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100c09:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c0d:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100c0f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c16:	eb a8                	jmp    f0100bc0 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100c18:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c1c:	75 15                	jne    f0100c33 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c21:	8b 00                	mov    (%eax),%eax
f0100c23:	83 e8 01             	sub    $0x1,%eax
f0100c26:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c29:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c2b:	83 c4 14             	add    $0x14,%esp
f0100c2e:	5b                   	pop    %ebx
f0100c2f:	5e                   	pop    %esi
f0100c30:	5f                   	pop    %edi
f0100c31:	5d                   	pop    %ebp
f0100c32:	c3                   	ret    
		for (l = *region_right;
f0100c33:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c36:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c3b:	8b 0f                	mov    (%edi),%ecx
f0100c3d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c40:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c43:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0100c47:	39 c1                	cmp    %eax,%ecx
f0100c49:	7d 0f                	jge    f0100c5a <stab_binsearch+0xee>
f0100c4b:	0f b6 1a             	movzbl (%edx),%ebx
f0100c4e:	83 ea 0c             	sub    $0xc,%edx
f0100c51:	39 f3                	cmp    %esi,%ebx
f0100c53:	74 05                	je     f0100c5a <stab_binsearch+0xee>
		     l--)
f0100c55:	83 e8 01             	sub    $0x1,%eax
f0100c58:	eb ed                	jmp    f0100c47 <stab_binsearch+0xdb>
		*region_left = l;
f0100c5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c5d:	89 07                	mov    %eax,(%edi)
}
f0100c5f:	eb ca                	jmp    f0100c2b <stab_binsearch+0xbf>

f0100c61 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c61:	55                   	push   %ebp
f0100c62:	89 e5                	mov    %esp,%ebp
f0100c64:	57                   	push   %edi
f0100c65:	56                   	push   %esi
f0100c66:	53                   	push   %ebx
f0100c67:	83 ec 3c             	sub    $0x3c,%esp
f0100c6a:	e8 83 f5 ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f0100c6f:	81 c3 99 06 01 00    	add    $0x10699,%ebx
f0100c75:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c78:	8d 83 b5 0d ff ff    	lea    -0xf24b(%ebx),%eax
f0100c7e:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c80:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c87:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c8a:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c91:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c94:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c97:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c9e:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0100ca3:	0f 86 46 01 00 00    	jbe    f0100def <debuginfo_eip+0x18e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ca9:	c7 c0 31 5d 10 f0    	mov    $0xf0105d31,%eax
f0100caf:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100cb5:	0f 86 d8 01 00 00    	jbe    f0100e93 <debuginfo_eip+0x232>
f0100cbb:	c7 c0 ca 73 10 f0    	mov    $0xf01073ca,%eax
f0100cc1:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100cc5:	0f 85 cf 01 00 00    	jne    f0100e9a <debuginfo_eip+0x239>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100ccb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100cd2:	c7 c0 d4 22 10 f0    	mov    $0xf01022d4,%eax
f0100cd8:	c7 c2 30 5d 10 f0    	mov    $0xf0105d30,%edx
f0100cde:	29 c2                	sub    %eax,%edx
f0100ce0:	c1 fa 02             	sar    $0x2,%edx
f0100ce3:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100ce9:	83 ea 01             	sub    $0x1,%edx
f0100cec:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cef:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cf2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cf5:	83 ec 08             	sub    $0x8,%esp
f0100cf8:	ff 75 08             	push   0x8(%ebp)
f0100cfb:	6a 64                	push   $0x64
f0100cfd:	e8 6a fe ff ff       	call   f0100b6c <stab_binsearch>
	if (lfile == 0)
f0100d02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d05:	83 c4 10             	add    $0x10,%esp
f0100d08:	85 ff                	test   %edi,%edi
f0100d0a:	0f 84 91 01 00 00    	je     f0100ea1 <debuginfo_eip+0x240>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d10:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f0100d13:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d16:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100d19:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d1c:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d1f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d22:	83 ec 08             	sub    $0x8,%esp
f0100d25:	ff 75 08             	push   0x8(%ebp)
f0100d28:	6a 24                	push   $0x24
f0100d2a:	c7 c0 d4 22 10 f0    	mov    $0xf01022d4,%eax
f0100d30:	e8 37 fe ff ff       	call   f0100b6c <stab_binsearch>

	if (lfun <= rfun) {
f0100d35:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100d38:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f0100d3b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100d3e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0100d41:	83 c4 10             	add    $0x10,%esp
f0100d44:	89 f8                	mov    %edi,%eax
f0100d46:	39 d1                	cmp    %edx,%ecx
f0100d48:	7f 39                	jg     f0100d83 <debuginfo_eip+0x122>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d4a:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f0100d4d:	c7 c2 d4 22 10 f0    	mov    $0xf01022d4,%edx
f0100d53:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100d56:	8b 11                	mov    (%ecx),%edx
f0100d58:	c7 c0 ca 73 10 f0    	mov    $0xf01073ca,%eax
f0100d5e:	81 e8 31 5d 10 f0    	sub    $0xf0105d31,%eax
f0100d64:	39 c2                	cmp    %eax,%edx
f0100d66:	73 09                	jae    f0100d71 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d68:	81 c2 31 5d 10 f0    	add    $0xf0105d31,%edx
f0100d6e:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d71:	8b 41 08             	mov    0x8(%ecx),%eax
f0100d74:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d77:	29 45 08             	sub    %eax,0x8(%ebp)
f0100d7a:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100d7d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100d80:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0100d83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d86:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100d89:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d8c:	83 ec 08             	sub    $0x8,%esp
f0100d8f:	6a 3a                	push   $0x3a
f0100d91:	ff 76 08             	push   0x8(%esi)
f0100d94:	e8 a9 09 00 00       	call   f0101742 <strfind>
f0100d99:	2b 46 08             	sub    0x8(%esi),%eax
f0100d9c:	89 46 0c             	mov    %eax,0xc(%esi)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d9f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100da2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100da5:	83 c4 08             	add    $0x8,%esp
f0100da8:	ff 75 08             	push   0x8(%ebp)
f0100dab:	6a 44                	push   $0x44
f0100dad:	c7 c0 d4 22 10 f0    	mov    $0xf01022d4,%eax
f0100db3:	e8 b4 fd ff ff       	call   f0100b6c <stab_binsearch>
    info->eip_line = lline > rline ? -1 : stabs[rline].n_desc;
f0100db8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dbb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100dbe:	83 c4 10             	add    $0x10,%esp
f0100dc1:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0100dc6:	39 d0                	cmp    %edx,%eax
f0100dc8:	7f 0e                	jg     f0100dd8 <debuginfo_eip+0x177>
f0100dca:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100dcd:	c7 c2 d4 22 10 f0    	mov    $0xf01022d4,%edx
f0100dd3:	0f b7 4c 8a 06       	movzwl 0x6(%edx,%ecx,4),%ecx
f0100dd8:	89 4e 04             	mov    %ecx,0x4(%esi)
f0100ddb:	89 c2                	mov    %eax,%edx
f0100ddd:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100de0:	c7 c0 d4 22 10 f0    	mov    $0xf01022d4,%eax
f0100de6:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100dea:	89 75 0c             	mov    %esi,0xc(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100ded:	eb 1e                	jmp    f0100e0d <debuginfo_eip+0x1ac>
  	        panic("User address");
f0100def:	83 ec 04             	sub    $0x4,%esp
f0100df2:	8d 83 bf 0d ff ff    	lea    -0xf241(%ebx),%eax
f0100df8:	50                   	push   %eax
f0100df9:	6a 7f                	push   $0x7f
f0100dfb:	8d 83 cc 0d ff ff    	lea    -0xf234(%ebx),%eax
f0100e01:	50                   	push   %eax
f0100e02:	e8 35 f3 ff ff       	call   f010013c <_panic>
f0100e07:	83 ea 01             	sub    $0x1,%edx
f0100e0a:	83 e8 0c             	sub    $0xc,%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e0d:	39 d7                	cmp    %edx,%edi
f0100e0f:	7f 3c                	jg     f0100e4d <debuginfo_eip+0x1ec>
	       && stabs[lline].n_type != N_SOL
f0100e11:	0f b6 08             	movzbl (%eax),%ecx
f0100e14:	80 f9 84             	cmp    $0x84,%cl
f0100e17:	74 0b                	je     f0100e24 <debuginfo_eip+0x1c3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e19:	80 f9 64             	cmp    $0x64,%cl
f0100e1c:	75 e9                	jne    f0100e07 <debuginfo_eip+0x1a6>
f0100e1e:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100e22:	74 e3                	je     f0100e07 <debuginfo_eip+0x1a6>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e24:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e27:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100e2a:	c7 c0 d4 22 10 f0    	mov    $0xf01022d4,%eax
f0100e30:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e33:	c7 c0 ca 73 10 f0    	mov    $0xf01073ca,%eax
f0100e39:	81 e8 31 5d 10 f0    	sub    $0xf0105d31,%eax
f0100e3f:	39 c2                	cmp    %eax,%edx
f0100e41:	73 0d                	jae    f0100e50 <debuginfo_eip+0x1ef>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e43:	81 c2 31 5d 10 f0    	add    $0xf0105d31,%edx
f0100e49:	89 16                	mov    %edx,(%esi)
f0100e4b:	eb 03                	jmp    f0100e50 <debuginfo_eip+0x1ef>
f0100e4d:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e50:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e55:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0100e58:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100e5b:	39 cf                	cmp    %ecx,%edi
f0100e5d:	7d 4e                	jge    f0100ead <debuginfo_eip+0x24c>
		for (lline = lfun + 1;
f0100e5f:	83 c7 01             	add    $0x1,%edi
f0100e62:	89 f8                	mov    %edi,%eax
f0100e64:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f0100e67:	c7 c2 d4 22 10 f0    	mov    $0xf01022d4,%edx
f0100e6d:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e71:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e74:	eb 04                	jmp    f0100e7a <debuginfo_eip+0x219>
			info->eip_fn_narg++;
f0100e76:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e7a:	39 c3                	cmp    %eax,%ebx
f0100e7c:	7e 2a                	jle    f0100ea8 <debuginfo_eip+0x247>
f0100e7e:	0f b6 0a             	movzbl (%edx),%ecx
f0100e81:	83 c0 01             	add    $0x1,%eax
f0100e84:	83 c2 0c             	add    $0xc,%edx
f0100e87:	80 f9 a0             	cmp    $0xa0,%cl
f0100e8a:	74 ea                	je     f0100e76 <debuginfo_eip+0x215>
	return 0;
f0100e8c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e91:	eb 1a                	jmp    f0100ead <debuginfo_eip+0x24c>
		return -1;
f0100e93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e98:	eb 13                	jmp    f0100ead <debuginfo_eip+0x24c>
f0100e9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e9f:	eb 0c                	jmp    f0100ead <debuginfo_eip+0x24c>
		return -1;
f0100ea1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ea6:	eb 05                	jmp    f0100ead <debuginfo_eip+0x24c>
	return 0;
f0100ea8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ead:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eb0:	5b                   	pop    %ebx
f0100eb1:	5e                   	pop    %esi
f0100eb2:	5f                   	pop    %edi
f0100eb3:	5d                   	pop    %ebp
f0100eb4:	c3                   	ret    

f0100eb5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100eb5:	55                   	push   %ebp
f0100eb6:	89 e5                	mov    %esp,%ebp
f0100eb8:	57                   	push   %edi
f0100eb9:	56                   	push   %esi
f0100eba:	53                   	push   %ebx
f0100ebb:	83 ec 2c             	sub    $0x2c,%esp
f0100ebe:	e8 07 06 00 00       	call   f01014ca <__x86.get_pc_thunk.cx>
f0100ec3:	81 c1 45 04 01 00    	add    $0x10445,%ecx
f0100ec9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100ecc:	89 c7                	mov    %eax,%edi
f0100ece:	89 d6                	mov    %edx,%esi
f0100ed0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ed6:	89 d1                	mov    %edx,%ecx
f0100ed8:	89 c2                	mov    %eax,%edx
f0100eda:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100edd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100ee0:	8b 45 10             	mov    0x10(%ebp),%eax
f0100ee3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ee6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ee9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100ef0:	39 c2                	cmp    %eax,%edx
f0100ef2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100ef5:	72 41                	jb     f0100f38 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ef7:	83 ec 0c             	sub    $0xc,%esp
f0100efa:	ff 75 18             	push   0x18(%ebp)
f0100efd:	83 eb 01             	sub    $0x1,%ebx
f0100f00:	53                   	push   %ebx
f0100f01:	50                   	push   %eax
f0100f02:	83 ec 08             	sub    $0x8,%esp
f0100f05:	ff 75 e4             	push   -0x1c(%ebp)
f0100f08:	ff 75 e0             	push   -0x20(%ebp)
f0100f0b:	ff 75 d4             	push   -0x2c(%ebp)
f0100f0e:	ff 75 d0             	push   -0x30(%ebp)
f0100f11:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f14:	e8 37 0a 00 00       	call   f0101950 <__udivdi3>
f0100f19:	83 c4 18             	add    $0x18,%esp
f0100f1c:	52                   	push   %edx
f0100f1d:	50                   	push   %eax
f0100f1e:	89 f2                	mov    %esi,%edx
f0100f20:	89 f8                	mov    %edi,%eax
f0100f22:	e8 8e ff ff ff       	call   f0100eb5 <printnum>
f0100f27:	83 c4 20             	add    $0x20,%esp
f0100f2a:	eb 13                	jmp    f0100f3f <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f2c:	83 ec 08             	sub    $0x8,%esp
f0100f2f:	56                   	push   %esi
f0100f30:	ff 75 18             	push   0x18(%ebp)
f0100f33:	ff d7                	call   *%edi
f0100f35:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f38:	83 eb 01             	sub    $0x1,%ebx
f0100f3b:	85 db                	test   %ebx,%ebx
f0100f3d:	7f ed                	jg     f0100f2c <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f3f:	83 ec 08             	sub    $0x8,%esp
f0100f42:	56                   	push   %esi
f0100f43:	83 ec 04             	sub    $0x4,%esp
f0100f46:	ff 75 e4             	push   -0x1c(%ebp)
f0100f49:	ff 75 e0             	push   -0x20(%ebp)
f0100f4c:	ff 75 d4             	push   -0x2c(%ebp)
f0100f4f:	ff 75 d0             	push   -0x30(%ebp)
f0100f52:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f55:	e8 16 0b 00 00       	call   f0101a70 <__umoddi3>
f0100f5a:	83 c4 14             	add    $0x14,%esp
f0100f5d:	0f be 84 03 da 0d ff 	movsbl -0xf226(%ebx,%eax,1),%eax
f0100f64:	ff 
f0100f65:	50                   	push   %eax
f0100f66:	ff d7                	call   *%edi
}
f0100f68:	83 c4 10             	add    $0x10,%esp
f0100f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f6e:	5b                   	pop    %ebx
f0100f6f:	5e                   	pop    %esi
f0100f70:	5f                   	pop    %edi
f0100f71:	5d                   	pop    %ebp
f0100f72:	c3                   	ret    

f0100f73 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f73:	55                   	push   %ebp
f0100f74:	89 e5                	mov    %esp,%ebp
f0100f76:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f79:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f7d:	8b 10                	mov    (%eax),%edx
f0100f7f:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f82:	73 0a                	jae    f0100f8e <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f84:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f87:	89 08                	mov    %ecx,(%eax)
f0100f89:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f8c:	88 02                	mov    %al,(%edx)
}
f0100f8e:	5d                   	pop    %ebp
f0100f8f:	c3                   	ret    

f0100f90 <printfmt>:
{
f0100f90:	55                   	push   %ebp
f0100f91:	89 e5                	mov    %esp,%ebp
f0100f93:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f96:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f99:	50                   	push   %eax
f0100f9a:	ff 75 10             	push   0x10(%ebp)
f0100f9d:	ff 75 0c             	push   0xc(%ebp)
f0100fa0:	ff 75 08             	push   0x8(%ebp)
f0100fa3:	e8 05 00 00 00       	call   f0100fad <vprintfmt>
}
f0100fa8:	83 c4 10             	add    $0x10,%esp
f0100fab:	c9                   	leave  
f0100fac:	c3                   	ret    

f0100fad <vprintfmt>:
{
f0100fad:	55                   	push   %ebp
f0100fae:	89 e5                	mov    %esp,%ebp
f0100fb0:	57                   	push   %edi
f0100fb1:	56                   	push   %esi
f0100fb2:	53                   	push   %ebx
f0100fb3:	83 ec 3c             	sub    $0x3c,%esp
f0100fb6:	e8 cb f7 ff ff       	call   f0100786 <__x86.get_pc_thunk.ax>
f0100fbb:	05 4d 03 01 00       	add    $0x1034d,%eax
f0100fc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fc3:	8b 75 08             	mov    0x8(%ebp),%esi
f0100fc6:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100fc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100fcc:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f0100fd2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100fd5:	eb 0a                	jmp    f0100fe1 <vprintfmt+0x34>
			putch(ch, putdat);
f0100fd7:	83 ec 08             	sub    $0x8,%esp
f0100fda:	57                   	push   %edi
f0100fdb:	50                   	push   %eax
f0100fdc:	ff d6                	call   *%esi
f0100fde:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100fe1:	83 c3 01             	add    $0x1,%ebx
f0100fe4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100fe8:	83 f8 25             	cmp    $0x25,%eax
f0100feb:	74 0c                	je     f0100ff9 <vprintfmt+0x4c>
			if (ch == '\0')
f0100fed:	85 c0                	test   %eax,%eax
f0100fef:	75 e6                	jne    f0100fd7 <vprintfmt+0x2a>
}
f0100ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ff4:	5b                   	pop    %ebx
f0100ff5:	5e                   	pop    %esi
f0100ff6:	5f                   	pop    %edi
f0100ff7:	5d                   	pop    %ebp
f0100ff8:	c3                   	ret    
		padc = ' ';
f0100ff9:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100ffd:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0101004:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010100b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0101012:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101017:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010101a:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010101d:	8d 43 01             	lea    0x1(%ebx),%eax
f0101020:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101023:	0f b6 13             	movzbl (%ebx),%edx
f0101026:	8d 42 dd             	lea    -0x23(%edx),%eax
f0101029:	3c 55                	cmp    $0x55,%al
f010102b:	0f 87 fd 03 00 00    	ja     f010142e <.L20>
f0101031:	0f b6 c0             	movzbl %al,%eax
f0101034:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101037:	89 ce                	mov    %ecx,%esi
f0101039:	03 b4 81 64 0e ff ff 	add    -0xf19c(%ecx,%eax,4),%esi
f0101040:	ff e6                	jmp    *%esi

f0101042 <.L68>:
f0101042:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0101045:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0101049:	eb d2                	jmp    f010101d <vprintfmt+0x70>

f010104b <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f010104b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010104e:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0101052:	eb c9                	jmp    f010101d <vprintfmt+0x70>

f0101054 <.L31>:
f0101054:	0f b6 d2             	movzbl %dl,%edx
f0101057:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f010105a:	b8 00 00 00 00       	mov    $0x0,%eax
f010105f:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0101062:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101065:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0101069:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f010106c:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010106f:	83 f9 09             	cmp    $0x9,%ecx
f0101072:	77 58                	ja     f01010cc <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0101074:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0101077:	eb e9                	jmp    f0101062 <.L31+0xe>

f0101079 <.L34>:
			precision = va_arg(ap, int);
f0101079:	8b 45 14             	mov    0x14(%ebp),%eax
f010107c:	8b 00                	mov    (%eax),%eax
f010107e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101081:	8b 45 14             	mov    0x14(%ebp),%eax
f0101084:	8d 40 04             	lea    0x4(%eax),%eax
f0101087:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010108a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f010108d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101091:	79 8a                	jns    f010101d <vprintfmt+0x70>
				width = precision, precision = -1;
f0101093:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101096:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101099:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01010a0:	e9 78 ff ff ff       	jmp    f010101d <vprintfmt+0x70>

f01010a5 <.L33>:
f01010a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01010a8:	85 d2                	test   %edx,%edx
f01010aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01010af:	0f 49 c2             	cmovns %edx,%eax
f01010b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01010b8:	e9 60 ff ff ff       	jmp    f010101d <vprintfmt+0x70>

f01010bd <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01010bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01010c0:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01010c7:	e9 51 ff ff ff       	jmp    f010101d <vprintfmt+0x70>
f01010cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010cf:	89 75 08             	mov    %esi,0x8(%ebp)
f01010d2:	eb b9                	jmp    f010108d <.L34+0x14>

f01010d4 <.L27>:
			lflag++;
f01010d4:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010d8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01010db:	e9 3d ff ff ff       	jmp    f010101d <vprintfmt+0x70>

f01010e0 <.L30>:
			putch(va_arg(ap, int), putdat);
f01010e0:	8b 75 08             	mov    0x8(%ebp),%esi
f01010e3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010e6:	8d 58 04             	lea    0x4(%eax),%ebx
f01010e9:	83 ec 08             	sub    $0x8,%esp
f01010ec:	57                   	push   %edi
f01010ed:	ff 30                	push   (%eax)
f01010ef:	ff d6                	call   *%esi
			break;
f01010f1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010f4:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01010f7:	e9 c8 02 00 00       	jmp    f01013c4 <.L25+0x45>

f01010fc <.L28>:
			err = va_arg(ap, int);
f01010fc:	8b 75 08             	mov    0x8(%ebp),%esi
f01010ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0101102:	8d 58 04             	lea    0x4(%eax),%ebx
f0101105:	8b 10                	mov    (%eax),%edx
f0101107:	89 d0                	mov    %edx,%eax
f0101109:	f7 d8                	neg    %eax
f010110b:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010110e:	83 f8 06             	cmp    $0x6,%eax
f0101111:	7f 27                	jg     f010113a <.L28+0x3e>
f0101113:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101116:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101119:	85 d2                	test   %edx,%edx
f010111b:	74 1d                	je     f010113a <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f010111d:	52                   	push   %edx
f010111e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101121:	8d 80 d5 08 ff ff    	lea    -0xf72b(%eax),%eax
f0101127:	50                   	push   %eax
f0101128:	57                   	push   %edi
f0101129:	56                   	push   %esi
f010112a:	e8 61 fe ff ff       	call   f0100f90 <printfmt>
f010112f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101132:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101135:	e9 8a 02 00 00       	jmp    f01013c4 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010113a:	50                   	push   %eax
f010113b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010113e:	8d 80 f2 0d ff ff    	lea    -0xf20e(%eax),%eax
f0101144:	50                   	push   %eax
f0101145:	57                   	push   %edi
f0101146:	56                   	push   %esi
f0101147:	e8 44 fe ff ff       	call   f0100f90 <printfmt>
f010114c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010114f:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101152:	e9 6d 02 00 00       	jmp    f01013c4 <.L25+0x45>

f0101157 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0101157:	8b 75 08             	mov    0x8(%ebp),%esi
f010115a:	8b 45 14             	mov    0x14(%ebp),%eax
f010115d:	83 c0 04             	add    $0x4,%eax
f0101160:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0101163:	8b 45 14             	mov    0x14(%ebp),%eax
f0101166:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0101168:	85 d2                	test   %edx,%edx
f010116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010116d:	8d 80 eb 0d ff ff    	lea    -0xf215(%eax),%eax
f0101173:	0f 45 c2             	cmovne %edx,%eax
f0101176:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0101179:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010117d:	7e 06                	jle    f0101185 <.L24+0x2e>
f010117f:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101183:	75 0d                	jne    f0101192 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101185:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101188:	89 c3                	mov    %eax,%ebx
f010118a:	03 45 d4             	add    -0x2c(%ebp),%eax
f010118d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101190:	eb 58                	jmp    f01011ea <.L24+0x93>
f0101192:	83 ec 08             	sub    $0x8,%esp
f0101195:	ff 75 d8             	push   -0x28(%ebp)
f0101198:	ff 75 c8             	push   -0x38(%ebp)
f010119b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010119e:	e8 48 04 00 00       	call   f01015eb <strnlen>
f01011a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01011a6:	29 c2                	sub    %eax,%edx
f01011a8:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01011ab:	83 c4 10             	add    $0x10,%esp
f01011ae:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01011b0:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01011b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01011b7:	eb 0f                	jmp    f01011c8 <.L24+0x71>
					putch(padc, putdat);
f01011b9:	83 ec 08             	sub    $0x8,%esp
f01011bc:	57                   	push   %edi
f01011bd:	ff 75 d4             	push   -0x2c(%ebp)
f01011c0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01011c2:	83 eb 01             	sub    $0x1,%ebx
f01011c5:	83 c4 10             	add    $0x10,%esp
f01011c8:	85 db                	test   %ebx,%ebx
f01011ca:	7f ed                	jg     f01011b9 <.L24+0x62>
f01011cc:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01011cf:	85 d2                	test   %edx,%edx
f01011d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d6:	0f 49 c2             	cmovns %edx,%eax
f01011d9:	29 c2                	sub    %eax,%edx
f01011db:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01011de:	eb a5                	jmp    f0101185 <.L24+0x2e>
					putch(ch, putdat);
f01011e0:	83 ec 08             	sub    $0x8,%esp
f01011e3:	57                   	push   %edi
f01011e4:	52                   	push   %edx
f01011e5:	ff d6                	call   *%esi
f01011e7:	83 c4 10             	add    $0x10,%esp
f01011ea:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01011ed:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011ef:	83 c3 01             	add    $0x1,%ebx
f01011f2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01011f6:	0f be d0             	movsbl %al,%edx
f01011f9:	85 d2                	test   %edx,%edx
f01011fb:	74 4b                	je     f0101248 <.L24+0xf1>
f01011fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101201:	78 06                	js     f0101209 <.L24+0xb2>
f0101203:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101207:	78 1e                	js     f0101227 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101209:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010120d:	74 d1                	je     f01011e0 <.L24+0x89>
f010120f:	0f be c0             	movsbl %al,%eax
f0101212:	83 e8 20             	sub    $0x20,%eax
f0101215:	83 f8 5e             	cmp    $0x5e,%eax
f0101218:	76 c6                	jbe    f01011e0 <.L24+0x89>
					putch('?', putdat);
f010121a:	83 ec 08             	sub    $0x8,%esp
f010121d:	57                   	push   %edi
f010121e:	6a 3f                	push   $0x3f
f0101220:	ff d6                	call   *%esi
f0101222:	83 c4 10             	add    $0x10,%esp
f0101225:	eb c3                	jmp    f01011ea <.L24+0x93>
f0101227:	89 cb                	mov    %ecx,%ebx
f0101229:	eb 0e                	jmp    f0101239 <.L24+0xe2>
				putch(' ', putdat);
f010122b:	83 ec 08             	sub    $0x8,%esp
f010122e:	57                   	push   %edi
f010122f:	6a 20                	push   $0x20
f0101231:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101233:	83 eb 01             	sub    $0x1,%ebx
f0101236:	83 c4 10             	add    $0x10,%esp
f0101239:	85 db                	test   %ebx,%ebx
f010123b:	7f ee                	jg     f010122b <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010123d:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0101240:	89 45 14             	mov    %eax,0x14(%ebp)
f0101243:	e9 7c 01 00 00       	jmp    f01013c4 <.L25+0x45>
f0101248:	89 cb                	mov    %ecx,%ebx
f010124a:	eb ed                	jmp    f0101239 <.L24+0xe2>

f010124c <.L29>:
	if (lflag >= 2)
f010124c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010124f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101252:	83 f9 01             	cmp    $0x1,%ecx
f0101255:	7f 1b                	jg     f0101272 <.L29+0x26>
	else if (lflag)
f0101257:	85 c9                	test   %ecx,%ecx
f0101259:	74 63                	je     f01012be <.L29+0x72>
		return va_arg(*ap, long);
f010125b:	8b 45 14             	mov    0x14(%ebp),%eax
f010125e:	8b 00                	mov    (%eax),%eax
f0101260:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101263:	99                   	cltd   
f0101264:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101267:	8b 45 14             	mov    0x14(%ebp),%eax
f010126a:	8d 40 04             	lea    0x4(%eax),%eax
f010126d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101270:	eb 17                	jmp    f0101289 <.L29+0x3d>
		return va_arg(*ap, long long);
f0101272:	8b 45 14             	mov    0x14(%ebp),%eax
f0101275:	8b 50 04             	mov    0x4(%eax),%edx
f0101278:	8b 00                	mov    (%eax),%eax
f010127a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010127d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101280:	8b 45 14             	mov    0x14(%ebp),%eax
f0101283:	8d 40 08             	lea    0x8(%eax),%eax
f0101286:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101289:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010128c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f010128f:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f0101294:	85 db                	test   %ebx,%ebx
f0101296:	0f 89 0e 01 00 00    	jns    f01013aa <.L25+0x2b>
				putch('-', putdat);
f010129c:	83 ec 08             	sub    $0x8,%esp
f010129f:	57                   	push   %edi
f01012a0:	6a 2d                	push   $0x2d
f01012a2:	ff d6                	call   *%esi
				num = -(long long) num;
f01012a4:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01012a7:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01012aa:	f7 d9                	neg    %ecx
f01012ac:	83 d3 00             	adc    $0x0,%ebx
f01012af:	f7 db                	neg    %ebx
f01012b1:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01012b4:	ba 0a 00 00 00       	mov    $0xa,%edx
f01012b9:	e9 ec 00 00 00       	jmp    f01013aa <.L25+0x2b>
		return va_arg(*ap, int);
f01012be:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c1:	8b 00                	mov    (%eax),%eax
f01012c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012c6:	99                   	cltd   
f01012c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01012cd:	8d 40 04             	lea    0x4(%eax),%eax
f01012d0:	89 45 14             	mov    %eax,0x14(%ebp)
f01012d3:	eb b4                	jmp    f0101289 <.L29+0x3d>

f01012d5 <.L23>:
	if (lflag >= 2)
f01012d5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012d8:	8b 75 08             	mov    0x8(%ebp),%esi
f01012db:	83 f9 01             	cmp    $0x1,%ecx
f01012de:	7f 1e                	jg     f01012fe <.L23+0x29>
	else if (lflag)
f01012e0:	85 c9                	test   %ecx,%ecx
f01012e2:	74 32                	je     f0101316 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f01012e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e7:	8b 08                	mov    (%eax),%ecx
f01012e9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012ee:	8d 40 04             	lea    0x4(%eax),%eax
f01012f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012f4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f01012f9:	e9 ac 00 00 00       	jmp    f01013aa <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01012fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101301:	8b 08                	mov    (%eax),%ecx
f0101303:	8b 58 04             	mov    0x4(%eax),%ebx
f0101306:	8d 40 08             	lea    0x8(%eax),%eax
f0101309:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010130c:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0101311:	e9 94 00 00 00       	jmp    f01013aa <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101316:	8b 45 14             	mov    0x14(%ebp),%eax
f0101319:	8b 08                	mov    (%eax),%ecx
f010131b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101320:	8d 40 04             	lea    0x4(%eax),%eax
f0101323:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101326:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f010132b:	eb 7d                	jmp    f01013aa <.L25+0x2b>

f010132d <.L26>:
	if (lflag >= 2)
f010132d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101330:	8b 75 08             	mov    0x8(%ebp),%esi
f0101333:	83 f9 01             	cmp    $0x1,%ecx
f0101336:	7f 1b                	jg     f0101353 <.L26+0x26>
	else if (lflag)
f0101338:	85 c9                	test   %ecx,%ecx
f010133a:	74 2c                	je     f0101368 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f010133c:	8b 45 14             	mov    0x14(%ebp),%eax
f010133f:	8b 08                	mov    (%eax),%ecx
f0101341:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101346:	8d 40 04             	lea    0x4(%eax),%eax
f0101349:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010134c:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f0101351:	eb 57                	jmp    f01013aa <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101353:	8b 45 14             	mov    0x14(%ebp),%eax
f0101356:	8b 08                	mov    (%eax),%ecx
f0101358:	8b 58 04             	mov    0x4(%eax),%ebx
f010135b:	8d 40 08             	lea    0x8(%eax),%eax
f010135e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101361:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f0101366:	eb 42                	jmp    f01013aa <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101368:	8b 45 14             	mov    0x14(%ebp),%eax
f010136b:	8b 08                	mov    (%eax),%ecx
f010136d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101372:	8d 40 04             	lea    0x4(%eax),%eax
f0101375:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101378:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f010137d:	eb 2b                	jmp    f01013aa <.L25+0x2b>

f010137f <.L25>:
			putch('0', putdat);
f010137f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101382:	83 ec 08             	sub    $0x8,%esp
f0101385:	57                   	push   %edi
f0101386:	6a 30                	push   $0x30
f0101388:	ff d6                	call   *%esi
			putch('x', putdat);
f010138a:	83 c4 08             	add    $0x8,%esp
f010138d:	57                   	push   %edi
f010138e:	6a 78                	push   $0x78
f0101390:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101392:	8b 45 14             	mov    0x14(%ebp),%eax
f0101395:	8b 08                	mov    (%eax),%ecx
f0101397:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f010139c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010139f:	8d 40 04             	lea    0x4(%eax),%eax
f01013a2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013a5:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f01013aa:	83 ec 0c             	sub    $0xc,%esp
f01013ad:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01013b1:	50                   	push   %eax
f01013b2:	ff 75 d4             	push   -0x2c(%ebp)
f01013b5:	52                   	push   %edx
f01013b6:	53                   	push   %ebx
f01013b7:	51                   	push   %ecx
f01013b8:	89 fa                	mov    %edi,%edx
f01013ba:	89 f0                	mov    %esi,%eax
f01013bc:	e8 f4 fa ff ff       	call   f0100eb5 <printnum>
			break;
f01013c1:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01013c4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013c7:	e9 15 fc ff ff       	jmp    f0100fe1 <vprintfmt+0x34>

f01013cc <.L21>:
	if (lflag >= 2)
f01013cc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01013cf:	8b 75 08             	mov    0x8(%ebp),%esi
f01013d2:	83 f9 01             	cmp    $0x1,%ecx
f01013d5:	7f 1b                	jg     f01013f2 <.L21+0x26>
	else if (lflag)
f01013d7:	85 c9                	test   %ecx,%ecx
f01013d9:	74 2c                	je     f0101407 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01013db:	8b 45 14             	mov    0x14(%ebp),%eax
f01013de:	8b 08                	mov    (%eax),%ecx
f01013e0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013e5:	8d 40 04             	lea    0x4(%eax),%eax
f01013e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013eb:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f01013f0:	eb b8                	jmp    f01013aa <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01013f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f5:	8b 08                	mov    (%eax),%ecx
f01013f7:	8b 58 04             	mov    0x4(%eax),%ebx
f01013fa:	8d 40 08             	lea    0x8(%eax),%eax
f01013fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101400:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0101405:	eb a3                	jmp    f01013aa <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101407:	8b 45 14             	mov    0x14(%ebp),%eax
f010140a:	8b 08                	mov    (%eax),%ecx
f010140c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101411:	8d 40 04             	lea    0x4(%eax),%eax
f0101414:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101417:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f010141c:	eb 8c                	jmp    f01013aa <.L25+0x2b>

f010141e <.L35>:
			putch(ch, putdat);
f010141e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101421:	83 ec 08             	sub    $0x8,%esp
f0101424:	57                   	push   %edi
f0101425:	6a 25                	push   $0x25
f0101427:	ff d6                	call   *%esi
			break;
f0101429:	83 c4 10             	add    $0x10,%esp
f010142c:	eb 96                	jmp    f01013c4 <.L25+0x45>

f010142e <.L20>:
			putch('%', putdat);
f010142e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101431:	83 ec 08             	sub    $0x8,%esp
f0101434:	57                   	push   %edi
f0101435:	6a 25                	push   $0x25
f0101437:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101439:	83 c4 10             	add    $0x10,%esp
f010143c:	89 d8                	mov    %ebx,%eax
f010143e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101442:	74 05                	je     f0101449 <.L20+0x1b>
f0101444:	83 e8 01             	sub    $0x1,%eax
f0101447:	eb f5                	jmp    f010143e <.L20+0x10>
f0101449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010144c:	e9 73 ff ff ff       	jmp    f01013c4 <.L25+0x45>

f0101451 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101451:	55                   	push   %ebp
f0101452:	89 e5                	mov    %esp,%ebp
f0101454:	53                   	push   %ebx
f0101455:	83 ec 14             	sub    $0x14,%esp
f0101458:	e8 95 ed ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f010145d:	81 c3 ab fe 00 00    	add    $0xfeab,%ebx
f0101463:	8b 45 08             	mov    0x8(%ebp),%eax
f0101466:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101469:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010146c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101470:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101473:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010147a:	85 c0                	test   %eax,%eax
f010147c:	74 2b                	je     f01014a9 <vsnprintf+0x58>
f010147e:	85 d2                	test   %edx,%edx
f0101480:	7e 27                	jle    f01014a9 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101482:	ff 75 14             	push   0x14(%ebp)
f0101485:	ff 75 10             	push   0x10(%ebp)
f0101488:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010148b:	50                   	push   %eax
f010148c:	8d 83 6b fc fe ff    	lea    -0x10395(%ebx),%eax
f0101492:	50                   	push   %eax
f0101493:	e8 15 fb ff ff       	call   f0100fad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101498:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010149b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010149e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01014a1:	83 c4 10             	add    $0x10,%esp
}
f01014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014a7:	c9                   	leave  
f01014a8:	c3                   	ret    
		return -E_INVAL;
f01014a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01014ae:	eb f4                	jmp    f01014a4 <vsnprintf+0x53>

f01014b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014b0:	55                   	push   %ebp
f01014b1:	89 e5                	mov    %esp,%ebp
f01014b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014b9:	50                   	push   %eax
f01014ba:	ff 75 10             	push   0x10(%ebp)
f01014bd:	ff 75 0c             	push   0xc(%ebp)
f01014c0:	ff 75 08             	push   0x8(%ebp)
f01014c3:	e8 89 ff ff ff       	call   f0101451 <vsnprintf>
	va_end(ap);

	return rc;
}
f01014c8:	c9                   	leave  
f01014c9:	c3                   	ret    

f01014ca <__x86.get_pc_thunk.cx>:
f01014ca:	8b 0c 24             	mov    (%esp),%ecx
f01014cd:	c3                   	ret    

f01014ce <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014ce:	55                   	push   %ebp
f01014cf:	89 e5                	mov    %esp,%ebp
f01014d1:	57                   	push   %edi
f01014d2:	56                   	push   %esi
f01014d3:	53                   	push   %ebx
f01014d4:	83 ec 1c             	sub    $0x1c,%esp
f01014d7:	e8 16 ed ff ff       	call   f01001f2 <__x86.get_pc_thunk.bx>
f01014dc:	81 c3 2c fe 00 00    	add    $0xfe2c,%ebx
f01014e2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014e5:	85 c0                	test   %eax,%eax
f01014e7:	74 13                	je     f01014fc <readline+0x2e>
		cprintf("%s", prompt);
f01014e9:	83 ec 08             	sub    $0x8,%esp
f01014ec:	50                   	push   %eax
f01014ed:	8d 83 d5 08 ff ff    	lea    -0xf72b(%ebx),%eax
f01014f3:	50                   	push   %eax
f01014f4:	e8 5f f6 ff ff       	call   f0100b58 <cprintf>
f01014f9:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01014fc:	83 ec 0c             	sub    $0xc,%esp
f01014ff:	6a 00                	push   $0x0
f0101501:	e8 7a f2 ff ff       	call   f0100780 <iscons>
f0101506:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101509:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010150c:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0101511:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0101517:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010151a:	eb 45                	jmp    f0101561 <readline+0x93>
			cprintf("read error: %e\n", c);
f010151c:	83 ec 08             	sub    $0x8,%esp
f010151f:	50                   	push   %eax
f0101520:	8d 83 bc 0f ff ff    	lea    -0xf044(%ebx),%eax
f0101526:	50                   	push   %eax
f0101527:	e8 2c f6 ff ff       	call   f0100b58 <cprintf>
			return NULL;
f010152c:	83 c4 10             	add    $0x10,%esp
f010152f:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101534:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101537:	5b                   	pop    %ebx
f0101538:	5e                   	pop    %esi
f0101539:	5f                   	pop    %edi
f010153a:	5d                   	pop    %ebp
f010153b:	c3                   	ret    
			if (echoing)
f010153c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101540:	75 05                	jne    f0101547 <readline+0x79>
			i--;
f0101542:	83 ef 01             	sub    $0x1,%edi
f0101545:	eb 1a                	jmp    f0101561 <readline+0x93>
				cputchar('\b');
f0101547:	83 ec 0c             	sub    $0xc,%esp
f010154a:	6a 08                	push   $0x8
f010154c:	e8 0e f2 ff ff       	call   f010075f <cputchar>
f0101551:	83 c4 10             	add    $0x10,%esp
f0101554:	eb ec                	jmp    f0101542 <readline+0x74>
			buf[i++] = c;
f0101556:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101559:	89 f0                	mov    %esi,%eax
f010155b:	88 04 39             	mov    %al,(%ecx,%edi,1)
f010155e:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101561:	e8 09 f2 ff ff       	call   f010076f <getchar>
f0101566:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101568:	85 c0                	test   %eax,%eax
f010156a:	78 b0                	js     f010151c <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010156c:	83 f8 08             	cmp    $0x8,%eax
f010156f:	0f 94 c0             	sete   %al
f0101572:	83 fe 7f             	cmp    $0x7f,%esi
f0101575:	0f 94 c2             	sete   %dl
f0101578:	08 d0                	or     %dl,%al
f010157a:	74 04                	je     f0101580 <readline+0xb2>
f010157c:	85 ff                	test   %edi,%edi
f010157e:	7f bc                	jg     f010153c <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101580:	83 fe 1f             	cmp    $0x1f,%esi
f0101583:	7e 1c                	jle    f01015a1 <readline+0xd3>
f0101585:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f010158b:	7f 14                	jg     f01015a1 <readline+0xd3>
			if (echoing)
f010158d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101591:	74 c3                	je     f0101556 <readline+0x88>
				cputchar(c);
f0101593:	83 ec 0c             	sub    $0xc,%esp
f0101596:	56                   	push   %esi
f0101597:	e8 c3 f1 ff ff       	call   f010075f <cputchar>
f010159c:	83 c4 10             	add    $0x10,%esp
f010159f:	eb b5                	jmp    f0101556 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f01015a1:	83 fe 0a             	cmp    $0xa,%esi
f01015a4:	74 05                	je     f01015ab <readline+0xdd>
f01015a6:	83 fe 0d             	cmp    $0xd,%esi
f01015a9:	75 b6                	jne    f0101561 <readline+0x93>
			if (echoing)
f01015ab:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015af:	75 13                	jne    f01015c4 <readline+0xf6>
			buf[i] = 0;
f01015b1:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f01015b8:	00 
			return buf;
f01015b9:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f01015bf:	e9 70 ff ff ff       	jmp    f0101534 <readline+0x66>
				cputchar('\n');
f01015c4:	83 ec 0c             	sub    $0xc,%esp
f01015c7:	6a 0a                	push   $0xa
f01015c9:	e8 91 f1 ff ff       	call   f010075f <cputchar>
f01015ce:	83 c4 10             	add    $0x10,%esp
f01015d1:	eb de                	jmp    f01015b1 <readline+0xe3>

f01015d3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015d3:	55                   	push   %ebp
f01015d4:	89 e5                	mov    %esp,%ebp
f01015d6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01015de:	eb 03                	jmp    f01015e3 <strlen+0x10>
		n++;
f01015e0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015e7:	75 f7                	jne    f01015e0 <strlen+0xd>
	return n;
}
f01015e9:	5d                   	pop    %ebp
f01015ea:	c3                   	ret    

f01015eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015eb:	55                   	push   %ebp
f01015ec:	89 e5                	mov    %esp,%ebp
f01015ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01015f9:	eb 03                	jmp    f01015fe <strnlen+0x13>
		n++;
f01015fb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015fe:	39 d0                	cmp    %edx,%eax
f0101600:	74 08                	je     f010160a <strnlen+0x1f>
f0101602:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101606:	75 f3                	jne    f01015fb <strnlen+0x10>
f0101608:	89 c2                	mov    %eax,%edx
	return n;
}
f010160a:	89 d0                	mov    %edx,%eax
f010160c:	5d                   	pop    %ebp
f010160d:	c3                   	ret    

f010160e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010160e:	55                   	push   %ebp
f010160f:	89 e5                	mov    %esp,%ebp
f0101611:	53                   	push   %ebx
f0101612:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101615:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101618:	b8 00 00 00 00       	mov    $0x0,%eax
f010161d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0101621:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0101624:	83 c0 01             	add    $0x1,%eax
f0101627:	84 d2                	test   %dl,%dl
f0101629:	75 f2                	jne    f010161d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010162b:	89 c8                	mov    %ecx,%eax
f010162d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101630:	c9                   	leave  
f0101631:	c3                   	ret    

f0101632 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101632:	55                   	push   %ebp
f0101633:	89 e5                	mov    %esp,%ebp
f0101635:	53                   	push   %ebx
f0101636:	83 ec 10             	sub    $0x10,%esp
f0101639:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010163c:	53                   	push   %ebx
f010163d:	e8 91 ff ff ff       	call   f01015d3 <strlen>
f0101642:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0101645:	ff 75 0c             	push   0xc(%ebp)
f0101648:	01 d8                	add    %ebx,%eax
f010164a:	50                   	push   %eax
f010164b:	e8 be ff ff ff       	call   f010160e <strcpy>
	return dst;
}
f0101650:	89 d8                	mov    %ebx,%eax
f0101652:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101655:	c9                   	leave  
f0101656:	c3                   	ret    

f0101657 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101657:	55                   	push   %ebp
f0101658:	89 e5                	mov    %esp,%ebp
f010165a:	56                   	push   %esi
f010165b:	53                   	push   %ebx
f010165c:	8b 75 08             	mov    0x8(%ebp),%esi
f010165f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101662:	89 f3                	mov    %esi,%ebx
f0101664:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101667:	89 f0                	mov    %esi,%eax
f0101669:	eb 0f                	jmp    f010167a <strncpy+0x23>
		*dst++ = *src;
f010166b:	83 c0 01             	add    $0x1,%eax
f010166e:	0f b6 0a             	movzbl (%edx),%ecx
f0101671:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101674:	80 f9 01             	cmp    $0x1,%cl
f0101677:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f010167a:	39 d8                	cmp    %ebx,%eax
f010167c:	75 ed                	jne    f010166b <strncpy+0x14>
	}
	return ret;
}
f010167e:	89 f0                	mov    %esi,%eax
f0101680:	5b                   	pop    %ebx
f0101681:	5e                   	pop    %esi
f0101682:	5d                   	pop    %ebp
f0101683:	c3                   	ret    

f0101684 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101684:	55                   	push   %ebp
f0101685:	89 e5                	mov    %esp,%ebp
f0101687:	56                   	push   %esi
f0101688:	53                   	push   %ebx
f0101689:	8b 75 08             	mov    0x8(%ebp),%esi
f010168c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010168f:	8b 55 10             	mov    0x10(%ebp),%edx
f0101692:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101694:	85 d2                	test   %edx,%edx
f0101696:	74 21                	je     f01016b9 <strlcpy+0x35>
f0101698:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010169c:	89 f2                	mov    %esi,%edx
f010169e:	eb 09                	jmp    f01016a9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01016a0:	83 c1 01             	add    $0x1,%ecx
f01016a3:	83 c2 01             	add    $0x1,%edx
f01016a6:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f01016a9:	39 c2                	cmp    %eax,%edx
f01016ab:	74 09                	je     f01016b6 <strlcpy+0x32>
f01016ad:	0f b6 19             	movzbl (%ecx),%ebx
f01016b0:	84 db                	test   %bl,%bl
f01016b2:	75 ec                	jne    f01016a0 <strlcpy+0x1c>
f01016b4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f01016b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01016b9:	29 f0                	sub    %esi,%eax
}
f01016bb:	5b                   	pop    %ebx
f01016bc:	5e                   	pop    %esi
f01016bd:	5d                   	pop    %ebp
f01016be:	c3                   	ret    

f01016bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016bf:	55                   	push   %ebp
f01016c0:	89 e5                	mov    %esp,%ebp
f01016c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016c8:	eb 06                	jmp    f01016d0 <strcmp+0x11>
		p++, q++;
f01016ca:	83 c1 01             	add    $0x1,%ecx
f01016cd:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01016d0:	0f b6 01             	movzbl (%ecx),%eax
f01016d3:	84 c0                	test   %al,%al
f01016d5:	74 04                	je     f01016db <strcmp+0x1c>
f01016d7:	3a 02                	cmp    (%edx),%al
f01016d9:	74 ef                	je     f01016ca <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016db:	0f b6 c0             	movzbl %al,%eax
f01016de:	0f b6 12             	movzbl (%edx),%edx
f01016e1:	29 d0                	sub    %edx,%eax
}
f01016e3:	5d                   	pop    %ebp
f01016e4:	c3                   	ret    

f01016e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016e5:	55                   	push   %ebp
f01016e6:	89 e5                	mov    %esp,%ebp
f01016e8:	53                   	push   %ebx
f01016e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ec:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016ef:	89 c3                	mov    %eax,%ebx
f01016f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016f4:	eb 06                	jmp    f01016fc <strncmp+0x17>
		n--, p++, q++;
f01016f6:	83 c0 01             	add    $0x1,%eax
f01016f9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016fc:	39 d8                	cmp    %ebx,%eax
f01016fe:	74 18                	je     f0101718 <strncmp+0x33>
f0101700:	0f b6 08             	movzbl (%eax),%ecx
f0101703:	84 c9                	test   %cl,%cl
f0101705:	74 04                	je     f010170b <strncmp+0x26>
f0101707:	3a 0a                	cmp    (%edx),%cl
f0101709:	74 eb                	je     f01016f6 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010170b:	0f b6 00             	movzbl (%eax),%eax
f010170e:	0f b6 12             	movzbl (%edx),%edx
f0101711:	29 d0                	sub    %edx,%eax
}
f0101713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101716:	c9                   	leave  
f0101717:	c3                   	ret    
		return 0;
f0101718:	b8 00 00 00 00       	mov    $0x0,%eax
f010171d:	eb f4                	jmp    f0101713 <strncmp+0x2e>

f010171f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010171f:	55                   	push   %ebp
f0101720:	89 e5                	mov    %esp,%ebp
f0101722:	8b 45 08             	mov    0x8(%ebp),%eax
f0101725:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101729:	eb 03                	jmp    f010172e <strchr+0xf>
f010172b:	83 c0 01             	add    $0x1,%eax
f010172e:	0f b6 10             	movzbl (%eax),%edx
f0101731:	84 d2                	test   %dl,%dl
f0101733:	74 06                	je     f010173b <strchr+0x1c>
		if (*s == c)
f0101735:	38 ca                	cmp    %cl,%dl
f0101737:	75 f2                	jne    f010172b <strchr+0xc>
f0101739:	eb 05                	jmp    f0101740 <strchr+0x21>
			return (char *) s;
	return 0;
f010173b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101740:	5d                   	pop    %ebp
f0101741:	c3                   	ret    

f0101742 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101742:	55                   	push   %ebp
f0101743:	89 e5                	mov    %esp,%ebp
f0101745:	8b 45 08             	mov    0x8(%ebp),%eax
f0101748:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010174c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010174f:	38 ca                	cmp    %cl,%dl
f0101751:	74 09                	je     f010175c <strfind+0x1a>
f0101753:	84 d2                	test   %dl,%dl
f0101755:	74 05                	je     f010175c <strfind+0x1a>
	for (; *s; s++)
f0101757:	83 c0 01             	add    $0x1,%eax
f010175a:	eb f0                	jmp    f010174c <strfind+0xa>
			break;
	return (char *) s;
}
f010175c:	5d                   	pop    %ebp
f010175d:	c3                   	ret    

f010175e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010175e:	55                   	push   %ebp
f010175f:	89 e5                	mov    %esp,%ebp
f0101761:	57                   	push   %edi
f0101762:	56                   	push   %esi
f0101763:	53                   	push   %ebx
f0101764:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101767:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010176a:	85 c9                	test   %ecx,%ecx
f010176c:	74 2f                	je     f010179d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010176e:	89 f8                	mov    %edi,%eax
f0101770:	09 c8                	or     %ecx,%eax
f0101772:	a8 03                	test   $0x3,%al
f0101774:	75 21                	jne    f0101797 <memset+0x39>
		c &= 0xFF;
f0101776:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010177a:	89 d0                	mov    %edx,%eax
f010177c:	c1 e0 08             	shl    $0x8,%eax
f010177f:	89 d3                	mov    %edx,%ebx
f0101781:	c1 e3 18             	shl    $0x18,%ebx
f0101784:	89 d6                	mov    %edx,%esi
f0101786:	c1 e6 10             	shl    $0x10,%esi
f0101789:	09 f3                	or     %esi,%ebx
f010178b:	09 da                	or     %ebx,%edx
f010178d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010178f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101792:	fc                   	cld    
f0101793:	f3 ab                	rep stos %eax,%es:(%edi)
f0101795:	eb 06                	jmp    f010179d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101797:	8b 45 0c             	mov    0xc(%ebp),%eax
f010179a:	fc                   	cld    
f010179b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010179d:	89 f8                	mov    %edi,%eax
f010179f:	5b                   	pop    %ebx
f01017a0:	5e                   	pop    %esi
f01017a1:	5f                   	pop    %edi
f01017a2:	5d                   	pop    %ebp
f01017a3:	c3                   	ret    

f01017a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01017a4:	55                   	push   %ebp
f01017a5:	89 e5                	mov    %esp,%ebp
f01017a7:	57                   	push   %edi
f01017a8:	56                   	push   %esi
f01017a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ac:	8b 75 0c             	mov    0xc(%ebp),%esi
f01017af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01017b2:	39 c6                	cmp    %eax,%esi
f01017b4:	73 32                	jae    f01017e8 <memmove+0x44>
f01017b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01017b9:	39 c2                	cmp    %eax,%edx
f01017bb:	76 2b                	jbe    f01017e8 <memmove+0x44>
		s += n;
		d += n;
f01017bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017c0:	89 d6                	mov    %edx,%esi
f01017c2:	09 fe                	or     %edi,%esi
f01017c4:	09 ce                	or     %ecx,%esi
f01017c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017cc:	75 0e                	jne    f01017dc <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017ce:	83 ef 04             	sub    $0x4,%edi
f01017d1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017d4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01017d7:	fd                   	std    
f01017d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017da:	eb 09                	jmp    f01017e5 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017dc:	83 ef 01             	sub    $0x1,%edi
f01017df:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017e2:	fd                   	std    
f01017e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017e5:	fc                   	cld    
f01017e6:	eb 1a                	jmp    f0101802 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017e8:	89 f2                	mov    %esi,%edx
f01017ea:	09 c2                	or     %eax,%edx
f01017ec:	09 ca                	or     %ecx,%edx
f01017ee:	f6 c2 03             	test   $0x3,%dl
f01017f1:	75 0a                	jne    f01017fd <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017f3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017f6:	89 c7                	mov    %eax,%edi
f01017f8:	fc                   	cld    
f01017f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017fb:	eb 05                	jmp    f0101802 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f01017fd:	89 c7                	mov    %eax,%edi
f01017ff:	fc                   	cld    
f0101800:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101802:	5e                   	pop    %esi
f0101803:	5f                   	pop    %edi
f0101804:	5d                   	pop    %ebp
f0101805:	c3                   	ret    

f0101806 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101806:	55                   	push   %ebp
f0101807:	89 e5                	mov    %esp,%ebp
f0101809:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010180c:	ff 75 10             	push   0x10(%ebp)
f010180f:	ff 75 0c             	push   0xc(%ebp)
f0101812:	ff 75 08             	push   0x8(%ebp)
f0101815:	e8 8a ff ff ff       	call   f01017a4 <memmove>
}
f010181a:	c9                   	leave  
f010181b:	c3                   	ret    

f010181c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010181c:	55                   	push   %ebp
f010181d:	89 e5                	mov    %esp,%ebp
f010181f:	56                   	push   %esi
f0101820:	53                   	push   %ebx
f0101821:	8b 45 08             	mov    0x8(%ebp),%eax
f0101824:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101827:	89 c6                	mov    %eax,%esi
f0101829:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010182c:	eb 06                	jmp    f0101834 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010182e:	83 c0 01             	add    $0x1,%eax
f0101831:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0101834:	39 f0                	cmp    %esi,%eax
f0101836:	74 14                	je     f010184c <memcmp+0x30>
		if (*s1 != *s2)
f0101838:	0f b6 08             	movzbl (%eax),%ecx
f010183b:	0f b6 1a             	movzbl (%edx),%ebx
f010183e:	38 d9                	cmp    %bl,%cl
f0101840:	74 ec                	je     f010182e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0101842:	0f b6 c1             	movzbl %cl,%eax
f0101845:	0f b6 db             	movzbl %bl,%ebx
f0101848:	29 d8                	sub    %ebx,%eax
f010184a:	eb 05                	jmp    f0101851 <memcmp+0x35>
	}

	return 0;
f010184c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101851:	5b                   	pop    %ebx
f0101852:	5e                   	pop    %esi
f0101853:	5d                   	pop    %ebp
f0101854:	c3                   	ret    

f0101855 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101855:	55                   	push   %ebp
f0101856:	89 e5                	mov    %esp,%ebp
f0101858:	8b 45 08             	mov    0x8(%ebp),%eax
f010185b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010185e:	89 c2                	mov    %eax,%edx
f0101860:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101863:	eb 03                	jmp    f0101868 <memfind+0x13>
f0101865:	83 c0 01             	add    $0x1,%eax
f0101868:	39 d0                	cmp    %edx,%eax
f010186a:	73 04                	jae    f0101870 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010186c:	38 08                	cmp    %cl,(%eax)
f010186e:	75 f5                	jne    f0101865 <memfind+0x10>
			break;
	return (void *) s;
}
f0101870:	5d                   	pop    %ebp
f0101871:	c3                   	ret    

f0101872 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101872:	55                   	push   %ebp
f0101873:	89 e5                	mov    %esp,%ebp
f0101875:	57                   	push   %edi
f0101876:	56                   	push   %esi
f0101877:	53                   	push   %ebx
f0101878:	8b 55 08             	mov    0x8(%ebp),%edx
f010187b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010187e:	eb 03                	jmp    f0101883 <strtol+0x11>
		s++;
f0101880:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0101883:	0f b6 02             	movzbl (%edx),%eax
f0101886:	3c 20                	cmp    $0x20,%al
f0101888:	74 f6                	je     f0101880 <strtol+0xe>
f010188a:	3c 09                	cmp    $0x9,%al
f010188c:	74 f2                	je     f0101880 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010188e:	3c 2b                	cmp    $0x2b,%al
f0101890:	74 2a                	je     f01018bc <strtol+0x4a>
	int neg = 0;
f0101892:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101897:	3c 2d                	cmp    $0x2d,%al
f0101899:	74 2b                	je     f01018c6 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010189b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01018a1:	75 0f                	jne    f01018b2 <strtol+0x40>
f01018a3:	80 3a 30             	cmpb   $0x30,(%edx)
f01018a6:	74 28                	je     f01018d0 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01018a8:	85 db                	test   %ebx,%ebx
f01018aa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01018af:	0f 44 d8             	cmove  %eax,%ebx
f01018b2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01018b7:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01018ba:	eb 46                	jmp    f0101902 <strtol+0x90>
		s++;
f01018bc:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f01018bf:	bf 00 00 00 00       	mov    $0x0,%edi
f01018c4:	eb d5                	jmp    f010189b <strtol+0x29>
		s++, neg = 1;
f01018c6:	83 c2 01             	add    $0x1,%edx
f01018c9:	bf 01 00 00 00       	mov    $0x1,%edi
f01018ce:	eb cb                	jmp    f010189b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018d0:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01018d4:	74 0e                	je     f01018e4 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f01018d6:	85 db                	test   %ebx,%ebx
f01018d8:	75 d8                	jne    f01018b2 <strtol+0x40>
		s++, base = 8;
f01018da:	83 c2 01             	add    $0x1,%edx
f01018dd:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018e2:	eb ce                	jmp    f01018b2 <strtol+0x40>
		s += 2, base = 16;
f01018e4:	83 c2 02             	add    $0x2,%edx
f01018e7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018ec:	eb c4                	jmp    f01018b2 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01018ee:	0f be c0             	movsbl %al,%eax
f01018f1:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018f4:	3b 45 10             	cmp    0x10(%ebp),%eax
f01018f7:	7d 3a                	jge    f0101933 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f01018f9:	83 c2 01             	add    $0x1,%edx
f01018fc:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0101900:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0101902:	0f b6 02             	movzbl (%edx),%eax
f0101905:	8d 70 d0             	lea    -0x30(%eax),%esi
f0101908:	89 f3                	mov    %esi,%ebx
f010190a:	80 fb 09             	cmp    $0x9,%bl
f010190d:	76 df                	jbe    f01018ee <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f010190f:	8d 70 9f             	lea    -0x61(%eax),%esi
f0101912:	89 f3                	mov    %esi,%ebx
f0101914:	80 fb 19             	cmp    $0x19,%bl
f0101917:	77 08                	ja     f0101921 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0101919:	0f be c0             	movsbl %al,%eax
f010191c:	83 e8 57             	sub    $0x57,%eax
f010191f:	eb d3                	jmp    f01018f4 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0101921:	8d 70 bf             	lea    -0x41(%eax),%esi
f0101924:	89 f3                	mov    %esi,%ebx
f0101926:	80 fb 19             	cmp    $0x19,%bl
f0101929:	77 08                	ja     f0101933 <strtol+0xc1>
			dig = *s - 'A' + 10;
f010192b:	0f be c0             	movsbl %al,%eax
f010192e:	83 e8 37             	sub    $0x37,%eax
f0101931:	eb c1                	jmp    f01018f4 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101933:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101937:	74 05                	je     f010193e <strtol+0xcc>
		*endptr = (char *) s;
f0101939:	8b 45 0c             	mov    0xc(%ebp),%eax
f010193c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f010193e:	89 c8                	mov    %ecx,%eax
f0101940:	f7 d8                	neg    %eax
f0101942:	85 ff                	test   %edi,%edi
f0101944:	0f 45 c8             	cmovne %eax,%ecx
}
f0101947:	89 c8                	mov    %ecx,%eax
f0101949:	5b                   	pop    %ebx
f010194a:	5e                   	pop    %esi
f010194b:	5f                   	pop    %edi
f010194c:	5d                   	pop    %ebp
f010194d:	c3                   	ret    
f010194e:	66 90                	xchg   %ax,%ax

f0101950 <__udivdi3>:
f0101950:	f3 0f 1e fb          	endbr32 
f0101954:	55                   	push   %ebp
f0101955:	57                   	push   %edi
f0101956:	56                   	push   %esi
f0101957:	53                   	push   %ebx
f0101958:	83 ec 1c             	sub    $0x1c,%esp
f010195b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010195f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101963:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101967:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010196b:	85 c0                	test   %eax,%eax
f010196d:	75 19                	jne    f0101988 <__udivdi3+0x38>
f010196f:	39 f3                	cmp    %esi,%ebx
f0101971:	76 4d                	jbe    f01019c0 <__udivdi3+0x70>
f0101973:	31 ff                	xor    %edi,%edi
f0101975:	89 e8                	mov    %ebp,%eax
f0101977:	89 f2                	mov    %esi,%edx
f0101979:	f7 f3                	div    %ebx
f010197b:	89 fa                	mov    %edi,%edx
f010197d:	83 c4 1c             	add    $0x1c,%esp
f0101980:	5b                   	pop    %ebx
f0101981:	5e                   	pop    %esi
f0101982:	5f                   	pop    %edi
f0101983:	5d                   	pop    %ebp
f0101984:	c3                   	ret    
f0101985:	8d 76 00             	lea    0x0(%esi),%esi
f0101988:	39 f0                	cmp    %esi,%eax
f010198a:	76 14                	jbe    f01019a0 <__udivdi3+0x50>
f010198c:	31 ff                	xor    %edi,%edi
f010198e:	31 c0                	xor    %eax,%eax
f0101990:	89 fa                	mov    %edi,%edx
f0101992:	83 c4 1c             	add    $0x1c,%esp
f0101995:	5b                   	pop    %ebx
f0101996:	5e                   	pop    %esi
f0101997:	5f                   	pop    %edi
f0101998:	5d                   	pop    %ebp
f0101999:	c3                   	ret    
f010199a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01019a0:	0f bd f8             	bsr    %eax,%edi
f01019a3:	83 f7 1f             	xor    $0x1f,%edi
f01019a6:	75 48                	jne    f01019f0 <__udivdi3+0xa0>
f01019a8:	39 f0                	cmp    %esi,%eax
f01019aa:	72 06                	jb     f01019b2 <__udivdi3+0x62>
f01019ac:	31 c0                	xor    %eax,%eax
f01019ae:	39 eb                	cmp    %ebp,%ebx
f01019b0:	77 de                	ja     f0101990 <__udivdi3+0x40>
f01019b2:	b8 01 00 00 00       	mov    $0x1,%eax
f01019b7:	eb d7                	jmp    f0101990 <__udivdi3+0x40>
f01019b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019c0:	89 d9                	mov    %ebx,%ecx
f01019c2:	85 db                	test   %ebx,%ebx
f01019c4:	75 0b                	jne    f01019d1 <__udivdi3+0x81>
f01019c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01019cb:	31 d2                	xor    %edx,%edx
f01019cd:	f7 f3                	div    %ebx
f01019cf:	89 c1                	mov    %eax,%ecx
f01019d1:	31 d2                	xor    %edx,%edx
f01019d3:	89 f0                	mov    %esi,%eax
f01019d5:	f7 f1                	div    %ecx
f01019d7:	89 c6                	mov    %eax,%esi
f01019d9:	89 e8                	mov    %ebp,%eax
f01019db:	89 f7                	mov    %esi,%edi
f01019dd:	f7 f1                	div    %ecx
f01019df:	89 fa                	mov    %edi,%edx
f01019e1:	83 c4 1c             	add    $0x1c,%esp
f01019e4:	5b                   	pop    %ebx
f01019e5:	5e                   	pop    %esi
f01019e6:	5f                   	pop    %edi
f01019e7:	5d                   	pop    %ebp
f01019e8:	c3                   	ret    
f01019e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019f0:	89 f9                	mov    %edi,%ecx
f01019f2:	ba 20 00 00 00       	mov    $0x20,%edx
f01019f7:	29 fa                	sub    %edi,%edx
f01019f9:	d3 e0                	shl    %cl,%eax
f01019fb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019ff:	89 d1                	mov    %edx,%ecx
f0101a01:	89 d8                	mov    %ebx,%eax
f0101a03:	d3 e8                	shr    %cl,%eax
f0101a05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101a09:	09 c1                	or     %eax,%ecx
f0101a0b:	89 f0                	mov    %esi,%eax
f0101a0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101a11:	89 f9                	mov    %edi,%ecx
f0101a13:	d3 e3                	shl    %cl,%ebx
f0101a15:	89 d1                	mov    %edx,%ecx
f0101a17:	d3 e8                	shr    %cl,%eax
f0101a19:	89 f9                	mov    %edi,%ecx
f0101a1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101a1f:	89 eb                	mov    %ebp,%ebx
f0101a21:	d3 e6                	shl    %cl,%esi
f0101a23:	89 d1                	mov    %edx,%ecx
f0101a25:	d3 eb                	shr    %cl,%ebx
f0101a27:	09 f3                	or     %esi,%ebx
f0101a29:	89 c6                	mov    %eax,%esi
f0101a2b:	89 f2                	mov    %esi,%edx
f0101a2d:	89 d8                	mov    %ebx,%eax
f0101a2f:	f7 74 24 08          	divl   0x8(%esp)
f0101a33:	89 d6                	mov    %edx,%esi
f0101a35:	89 c3                	mov    %eax,%ebx
f0101a37:	f7 64 24 0c          	mull   0xc(%esp)
f0101a3b:	39 d6                	cmp    %edx,%esi
f0101a3d:	72 19                	jb     f0101a58 <__udivdi3+0x108>
f0101a3f:	89 f9                	mov    %edi,%ecx
f0101a41:	d3 e5                	shl    %cl,%ebp
f0101a43:	39 c5                	cmp    %eax,%ebp
f0101a45:	73 04                	jae    f0101a4b <__udivdi3+0xfb>
f0101a47:	39 d6                	cmp    %edx,%esi
f0101a49:	74 0d                	je     f0101a58 <__udivdi3+0x108>
f0101a4b:	89 d8                	mov    %ebx,%eax
f0101a4d:	31 ff                	xor    %edi,%edi
f0101a4f:	e9 3c ff ff ff       	jmp    f0101990 <__udivdi3+0x40>
f0101a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101a58:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101a5b:	31 ff                	xor    %edi,%edi
f0101a5d:	e9 2e ff ff ff       	jmp    f0101990 <__udivdi3+0x40>
f0101a62:	66 90                	xchg   %ax,%ax
f0101a64:	66 90                	xchg   %ax,%ax
f0101a66:	66 90                	xchg   %ax,%ax
f0101a68:	66 90                	xchg   %ax,%ax
f0101a6a:	66 90                	xchg   %ax,%ax
f0101a6c:	66 90                	xchg   %ax,%ax
f0101a6e:	66 90                	xchg   %ax,%ax

f0101a70 <__umoddi3>:
f0101a70:	f3 0f 1e fb          	endbr32 
f0101a74:	55                   	push   %ebp
f0101a75:	57                   	push   %edi
f0101a76:	56                   	push   %esi
f0101a77:	53                   	push   %ebx
f0101a78:	83 ec 1c             	sub    $0x1c,%esp
f0101a7b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a83:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0101a87:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0101a8b:	89 f0                	mov    %esi,%eax
f0101a8d:	89 da                	mov    %ebx,%edx
f0101a8f:	85 ff                	test   %edi,%edi
f0101a91:	75 15                	jne    f0101aa8 <__umoddi3+0x38>
f0101a93:	39 dd                	cmp    %ebx,%ebp
f0101a95:	76 39                	jbe    f0101ad0 <__umoddi3+0x60>
f0101a97:	f7 f5                	div    %ebp
f0101a99:	89 d0                	mov    %edx,%eax
f0101a9b:	31 d2                	xor    %edx,%edx
f0101a9d:	83 c4 1c             	add    $0x1c,%esp
f0101aa0:	5b                   	pop    %ebx
f0101aa1:	5e                   	pop    %esi
f0101aa2:	5f                   	pop    %edi
f0101aa3:	5d                   	pop    %ebp
f0101aa4:	c3                   	ret    
f0101aa5:	8d 76 00             	lea    0x0(%esi),%esi
f0101aa8:	39 df                	cmp    %ebx,%edi
f0101aaa:	77 f1                	ja     f0101a9d <__umoddi3+0x2d>
f0101aac:	0f bd cf             	bsr    %edi,%ecx
f0101aaf:	83 f1 1f             	xor    $0x1f,%ecx
f0101ab2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101ab6:	75 40                	jne    f0101af8 <__umoddi3+0x88>
f0101ab8:	39 df                	cmp    %ebx,%edi
f0101aba:	72 04                	jb     f0101ac0 <__umoddi3+0x50>
f0101abc:	39 f5                	cmp    %esi,%ebp
f0101abe:	77 dd                	ja     f0101a9d <__umoddi3+0x2d>
f0101ac0:	89 da                	mov    %ebx,%edx
f0101ac2:	89 f0                	mov    %esi,%eax
f0101ac4:	29 e8                	sub    %ebp,%eax
f0101ac6:	19 fa                	sbb    %edi,%edx
f0101ac8:	eb d3                	jmp    f0101a9d <__umoddi3+0x2d>
f0101aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101ad0:	89 e9                	mov    %ebp,%ecx
f0101ad2:	85 ed                	test   %ebp,%ebp
f0101ad4:	75 0b                	jne    f0101ae1 <__umoddi3+0x71>
f0101ad6:	b8 01 00 00 00       	mov    $0x1,%eax
f0101adb:	31 d2                	xor    %edx,%edx
f0101add:	f7 f5                	div    %ebp
f0101adf:	89 c1                	mov    %eax,%ecx
f0101ae1:	89 d8                	mov    %ebx,%eax
f0101ae3:	31 d2                	xor    %edx,%edx
f0101ae5:	f7 f1                	div    %ecx
f0101ae7:	89 f0                	mov    %esi,%eax
f0101ae9:	f7 f1                	div    %ecx
f0101aeb:	89 d0                	mov    %edx,%eax
f0101aed:	31 d2                	xor    %edx,%edx
f0101aef:	eb ac                	jmp    f0101a9d <__umoddi3+0x2d>
f0101af1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101af8:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101afc:	ba 20 00 00 00       	mov    $0x20,%edx
f0101b01:	29 c2                	sub    %eax,%edx
f0101b03:	89 c1                	mov    %eax,%ecx
f0101b05:	89 e8                	mov    %ebp,%eax
f0101b07:	d3 e7                	shl    %cl,%edi
f0101b09:	89 d1                	mov    %edx,%ecx
f0101b0b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101b0f:	d3 e8                	shr    %cl,%eax
f0101b11:	89 c1                	mov    %eax,%ecx
f0101b13:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101b17:	09 f9                	or     %edi,%ecx
f0101b19:	89 df                	mov    %ebx,%edi
f0101b1b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b1f:	89 c1                	mov    %eax,%ecx
f0101b21:	d3 e5                	shl    %cl,%ebp
f0101b23:	89 d1                	mov    %edx,%ecx
f0101b25:	d3 ef                	shr    %cl,%edi
f0101b27:	89 c1                	mov    %eax,%ecx
f0101b29:	89 f0                	mov    %esi,%eax
f0101b2b:	d3 e3                	shl    %cl,%ebx
f0101b2d:	89 d1                	mov    %edx,%ecx
f0101b2f:	89 fa                	mov    %edi,%edx
f0101b31:	d3 e8                	shr    %cl,%eax
f0101b33:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b38:	09 d8                	or     %ebx,%eax
f0101b3a:	f7 74 24 08          	divl   0x8(%esp)
f0101b3e:	89 d3                	mov    %edx,%ebx
f0101b40:	d3 e6                	shl    %cl,%esi
f0101b42:	f7 e5                	mul    %ebp
f0101b44:	89 c7                	mov    %eax,%edi
f0101b46:	89 d1                	mov    %edx,%ecx
f0101b48:	39 d3                	cmp    %edx,%ebx
f0101b4a:	72 06                	jb     f0101b52 <__umoddi3+0xe2>
f0101b4c:	75 0e                	jne    f0101b5c <__umoddi3+0xec>
f0101b4e:	39 c6                	cmp    %eax,%esi
f0101b50:	73 0a                	jae    f0101b5c <__umoddi3+0xec>
f0101b52:	29 e8                	sub    %ebp,%eax
f0101b54:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101b58:	89 d1                	mov    %edx,%ecx
f0101b5a:	89 c7                	mov    %eax,%edi
f0101b5c:	89 f5                	mov    %esi,%ebp
f0101b5e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101b62:	29 fd                	sub    %edi,%ebp
f0101b64:	19 cb                	sbb    %ecx,%ebx
f0101b66:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b6b:	89 d8                	mov    %ebx,%eax
f0101b6d:	d3 e0                	shl    %cl,%eax
f0101b6f:	89 f1                	mov    %esi,%ecx
f0101b71:	d3 ed                	shr    %cl,%ebp
f0101b73:	d3 eb                	shr    %cl,%ebx
f0101b75:	09 e8                	or     %ebp,%eax
f0101b77:	89 da                	mov    %ebx,%edx
f0101b79:	83 c4 1c             	add    $0x1c,%esp
f0101b7c:	5b                   	pop    %ebx
f0101b7d:	5e                   	pop    %esi
f0101b7e:	5f                   	pop    %edi
f0101b7f:	5d                   	pop    %ebp
f0101b80:	c3                   	ret    

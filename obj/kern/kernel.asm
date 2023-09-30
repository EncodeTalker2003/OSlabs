
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <call_l1e8>:
#include <kern/kclock.h>


void 
call_l1e8(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 18             	sub    $0x18,%esp
f0100047:	e8 5f 01 00 00       	call   f01001ab <__x86.get_pc_thunk.bx>
f010004c:	81 c3 c0 72 01 00    	add    $0x172c0,%ebx
	unsigned int i = 0x00646c72;
f0100052:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
    cprintf("H%x Wo%s", 57616, &i);
f0100059:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010005c:	50                   	push   %eax
f010005d:	68 10 e1 00 00       	push   $0xe110
f0100062:	8d 83 b4 cd fe ff    	lea    -0x1324c(%ebx),%eax
f0100068:	50                   	push   %eax
f0100069:	e8 09 30 00 00       	call   f0103077 <cprintf>
}
f010006e:	83 c4 10             	add    $0x10,%esp
f0100071:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100074:	c9                   	leave  
f0100075:	c3                   	ret    

f0100076 <brk>:

void brk() {
f0100076:	55                   	push   %ebp
f0100077:	89 e5                	mov    %esp,%ebp
f0100079:	53                   	push   %ebx
f010007a:	83 ec 10             	sub    $0x10,%esp
f010007d:	e8 29 01 00 00       	call   f01001ab <__x86.get_pc_thunk.bx>
f0100082:	81 c3 8a 72 01 00    	add    $0x1728a,%ebx
	cprintf("brk\n");
f0100088:	8d 83 bd cd fe ff    	lea    -0x13243(%ebx),%eax
f010008e:	50                   	push   %eax
f010008f:	e8 e3 2f 00 00       	call   f0103077 <cprintf>
}
f0100094:	83 c4 10             	add    $0x10,%esp
f0100097:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010009a:	c9                   	leave  
f010009b:	c3                   	ret    

f010009c <i386_init>:

void
i386_init(void)
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 08             	sub    $0x8,%esp
f01000a3:	e8 03 01 00 00       	call   f01001ab <__x86.get_pc_thunk.bx>
f01000a8:	81 c3 64 72 01 00    	add    $0x17264,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000ae:	c7 c2 60 90 11 f0    	mov    $0xf0119060,%edx
f01000b4:	c7 c0 e0 96 11 f0    	mov    $0xf01196e0,%eax
f01000ba:	29 d0                	sub    %edx,%eax
f01000bc:	50                   	push   %eax
f01000bd:	6a 00                	push   $0x0
f01000bf:	52                   	push   %edx
f01000c0:	e8 b2 3b 00 00       	call   f0103c77 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 39 05 00 00       	call   f0100603 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	83 c4 08             	add    $0x8,%esp
f01000cd:	68 ac 1a 00 00       	push   $0x1aac
f01000d2:	8d 83 c2 cd fe ff    	lea    -0x1323e(%ebx),%eax
f01000d8:	50                   	push   %eax
f01000d9:	e8 99 2f 00 00       	call   f0103077 <cprintf>
	//call_l1e8();

	//brk();

	// Lab 2 memory management initialization functions
	mem_init();
f01000de:	e8 39 12 00 00       	call   f010131c <mem_init>
f01000e3:	83 c4 10             	add    $0x10,%esp

	//brk();

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000e6:	83 ec 0c             	sub    $0xc,%esp
f01000e9:	6a 00                	push   $0x0
f01000eb:	e8 5f 08 00 00       	call   f010094f <monitor>
f01000f0:	83 c4 10             	add    $0x10,%esp
f01000f3:	eb f1                	jmp    f01000e6 <i386_init+0x4a>

f01000f5 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f5:	55                   	push   %ebp
f01000f6:	89 e5                	mov    %esp,%ebp
f01000f8:	56                   	push   %esi
f01000f9:	53                   	push   %ebx
f01000fa:	e8 ac 00 00 00       	call   f01001ab <__x86.get_pc_thunk.bx>
f01000ff:	81 c3 0d 72 01 00    	add    $0x1720d,%ebx
	va_list ap;

	if (panicstr)
f0100105:	83 bb 54 1d 00 00 00 	cmpl   $0x0,0x1d54(%ebx)
f010010c:	74 0f                	je     f010011d <_panic+0x28>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010010e:	83 ec 0c             	sub    $0xc,%esp
f0100111:	6a 00                	push   $0x0
f0100113:	e8 37 08 00 00       	call   f010094f <monitor>
f0100118:	83 c4 10             	add    $0x10,%esp
f010011b:	eb f1                	jmp    f010010e <_panic+0x19>
	panicstr = fmt;
f010011d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100120:	89 83 54 1d 00 00    	mov    %eax,0x1d54(%ebx)
	asm volatile("cli; cld");
f0100126:	fa                   	cli    
f0100127:	fc                   	cld    
	va_start(ap, fmt);
f0100128:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010012b:	83 ec 04             	sub    $0x4,%esp
f010012e:	ff 75 0c             	push   0xc(%ebp)
f0100131:	ff 75 08             	push   0x8(%ebp)
f0100134:	8d 83 dd cd fe ff    	lea    -0x13223(%ebx),%eax
f010013a:	50                   	push   %eax
f010013b:	e8 37 2f 00 00       	call   f0103077 <cprintf>
	vcprintf(fmt, ap);
f0100140:	83 c4 08             	add    $0x8,%esp
f0100143:	56                   	push   %esi
f0100144:	ff 75 10             	push   0x10(%ebp)
f0100147:	e8 f4 2e 00 00       	call   f0103040 <vcprintf>
	cprintf("\n");
f010014c:	8d 83 7d d5 fe ff    	lea    -0x12a83(%ebx),%eax
f0100152:	89 04 24             	mov    %eax,(%esp)
f0100155:	e8 1d 2f 00 00       	call   f0103077 <cprintf>
f010015a:	83 c4 10             	add    $0x10,%esp
f010015d:	eb af                	jmp    f010010e <_panic+0x19>

f010015f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010015f:	55                   	push   %ebp
f0100160:	89 e5                	mov    %esp,%ebp
f0100162:	56                   	push   %esi
f0100163:	53                   	push   %ebx
f0100164:	e8 42 00 00 00       	call   f01001ab <__x86.get_pc_thunk.bx>
f0100169:	81 c3 a3 71 01 00    	add    $0x171a3,%ebx
	va_list ap;

	va_start(ap, fmt);
f010016f:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100172:	83 ec 04             	sub    $0x4,%esp
f0100175:	ff 75 0c             	push   0xc(%ebp)
f0100178:	ff 75 08             	push   0x8(%ebp)
f010017b:	8d 83 f5 cd fe ff    	lea    -0x1320b(%ebx),%eax
f0100181:	50                   	push   %eax
f0100182:	e8 f0 2e 00 00       	call   f0103077 <cprintf>
	vcprintf(fmt, ap);
f0100187:	83 c4 08             	add    $0x8,%esp
f010018a:	56                   	push   %esi
f010018b:	ff 75 10             	push   0x10(%ebp)
f010018e:	e8 ad 2e 00 00       	call   f0103040 <vcprintf>
	cprintf("\n");
f0100193:	8d 83 7d d5 fe ff    	lea    -0x12a83(%ebx),%eax
f0100199:	89 04 24             	mov    %eax,(%esp)
f010019c:	e8 d6 2e 00 00       	call   f0103077 <cprintf>
	va_end(ap);
}
f01001a1:	83 c4 10             	add    $0x10,%esp
f01001a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001a7:	5b                   	pop    %ebx
f01001a8:	5e                   	pop    %esi
f01001a9:	5d                   	pop    %ebp
f01001aa:	c3                   	ret    

f01001ab <__x86.get_pc_thunk.bx>:
f01001ab:	8b 1c 24             	mov    (%esp),%ebx
f01001ae:	c3                   	ret    

f01001af <serial_proc_data>:

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001af:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b4:	ec                   	in     (%dx),%al
static int bg_col = 0x0;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b5:	a8 01                	test   $0x1,%al
f01001b7:	74 0a                	je     f01001c3 <serial_proc_data+0x14>
f01001b9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001be:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001bf:	0f b6 c0             	movzbl %al,%eax
f01001c2:	c3                   	ret    
		return -1;
f01001c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001c8:	c3                   	ret    

f01001c9 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001c9:	55                   	push   %ebp
f01001ca:	89 e5                	mov    %esp,%ebp
f01001cc:	57                   	push   %edi
f01001cd:	56                   	push   %esi
f01001ce:	53                   	push   %ebx
f01001cf:	83 ec 1c             	sub    $0x1c,%esp
f01001d2:	e8 6c 05 00 00       	call   f0100743 <__x86.get_pc_thunk.si>
f01001d7:	81 c6 35 71 01 00    	add    $0x17135,%esi
f01001dd:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001df:	8d 1d 94 1d 00 00    	lea    0x1d94,%ebx
f01001e5:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001eb:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001ee:	eb 25                	jmp    f0100215 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f01001f0:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001f7:	8d 51 01             	lea    0x1(%ecx),%edx
f01001fa:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001fd:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100200:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100206:	b8 00 00 00 00       	mov    $0x0,%eax
f010020b:	0f 44 d0             	cmove  %eax,%edx
f010020e:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100215:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100218:	ff d0                	call   *%eax
f010021a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010021d:	74 06                	je     f0100225 <cons_intr+0x5c>
		if (c == 0)
f010021f:	85 c0                	test   %eax,%eax
f0100221:	75 cd                	jne    f01001f0 <cons_intr+0x27>
f0100223:	eb f0                	jmp    f0100215 <cons_intr+0x4c>
	}
}
f0100225:	83 c4 1c             	add    $0x1c,%esp
f0100228:	5b                   	pop    %ebx
f0100229:	5e                   	pop    %esi
f010022a:	5f                   	pop    %edi
f010022b:	5d                   	pop    %ebp
f010022c:	c3                   	ret    

f010022d <kbd_proc_data>:
{
f010022d:	55                   	push   %ebp
f010022e:	89 e5                	mov    %esp,%ebp
f0100230:	56                   	push   %esi
f0100231:	53                   	push   %ebx
f0100232:	e8 74 ff ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0100237:	81 c3 d5 70 01 00    	add    $0x170d5,%ebx
f010023d:	ba 64 00 00 00       	mov    $0x64,%edx
f0100242:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100243:	a8 01                	test   $0x1,%al
f0100245:	0f 84 f7 00 00 00    	je     f0100342 <kbd_proc_data+0x115>
	if (stat & KBS_TERR)
f010024b:	a8 20                	test   $0x20,%al
f010024d:	0f 85 f6 00 00 00    	jne    f0100349 <kbd_proc_data+0x11c>
f0100253:	ba 60 00 00 00       	mov    $0x60,%edx
f0100258:	ec                   	in     (%dx),%al
f0100259:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010025b:	3c e0                	cmp    $0xe0,%al
f010025d:	74 64                	je     f01002c3 <kbd_proc_data+0x96>
	} else if (data & 0x80) {
f010025f:	84 c0                	test   %al,%al
f0100261:	78 75                	js     f01002d8 <kbd_proc_data+0xab>
	} else if (shift & E0ESC) {
f0100263:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f0100269:	f6 c1 40             	test   $0x40,%cl
f010026c:	74 0e                	je     f010027c <kbd_proc_data+0x4f>
		data |= 0x80;
f010026e:	83 c8 80             	or     $0xffffff80,%eax
f0100271:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100273:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100276:	89 8b 74 1d 00 00    	mov    %ecx,0x1d74(%ebx)
	shift |= shiftcode[data];
f010027c:	0f b6 d2             	movzbl %dl,%edx
f010027f:	0f b6 84 13 54 cf fe 	movzbl -0x130ac(%ebx,%edx,1),%eax
f0100286:	ff 
f0100287:	0b 83 74 1d 00 00    	or     0x1d74(%ebx),%eax
	shift ^= togglecode[data];
f010028d:	0f b6 8c 13 54 ce fe 	movzbl -0x131ac(%ebx,%edx,1),%ecx
f0100294:	ff 
f0100295:	31 c8                	xor    %ecx,%eax
f0100297:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010029d:	89 c1                	mov    %eax,%ecx
f010029f:	83 e1 03             	and    $0x3,%ecx
f01002a2:	8b 8c 8b f4 1c 00 00 	mov    0x1cf4(%ebx,%ecx,4),%ecx
f01002a9:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002ad:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b0:	a8 08                	test   $0x8,%al
f01002b2:	74 61                	je     f0100315 <kbd_proc_data+0xe8>
		if ('a' <= c && c <= 'z')
f01002b4:	89 f2                	mov    %esi,%edx
f01002b6:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002b9:	83 f9 19             	cmp    $0x19,%ecx
f01002bc:	77 4b                	ja     f0100309 <kbd_proc_data+0xdc>
			c += 'A' - 'a';
f01002be:	83 ee 20             	sub    $0x20,%esi
f01002c1:	eb 0c                	jmp    f01002cf <kbd_proc_data+0xa2>
		shift |= E0ESC;
f01002c3:	83 8b 74 1d 00 00 40 	orl    $0x40,0x1d74(%ebx)
		return 0;
f01002ca:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002cf:	89 f0                	mov    %esi,%eax
f01002d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002d4:	5b                   	pop    %ebx
f01002d5:	5e                   	pop    %esi
f01002d6:	5d                   	pop    %ebp
f01002d7:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002d8:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f01002de:	83 e0 7f             	and    $0x7f,%eax
f01002e1:	f6 c1 40             	test   $0x40,%cl
f01002e4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002e7:	0f b6 d2             	movzbl %dl,%edx
f01002ea:	0f b6 84 13 54 cf fe 	movzbl -0x130ac(%ebx,%edx,1),%eax
f01002f1:	ff 
f01002f2:	83 c8 40             	or     $0x40,%eax
f01002f5:	0f b6 c0             	movzbl %al,%eax
f01002f8:	f7 d0                	not    %eax
f01002fa:	21 c8                	and    %ecx,%eax
f01002fc:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
		return 0;
f0100302:	be 00 00 00 00       	mov    $0x0,%esi
f0100307:	eb c6                	jmp    f01002cf <kbd_proc_data+0xa2>
		else if ('A' <= c && c <= 'Z')
f0100309:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010030c:	8d 4e 20             	lea    0x20(%esi),%ecx
f010030f:	83 fa 1a             	cmp    $0x1a,%edx
f0100312:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100315:	f7 d0                	not    %eax
f0100317:	a8 06                	test   $0x6,%al
f0100319:	75 b4                	jne    f01002cf <kbd_proc_data+0xa2>
f010031b:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100321:	75 ac                	jne    f01002cf <kbd_proc_data+0xa2>
		cprintf("Rebooting!\n");
f0100323:	83 ec 0c             	sub    $0xc,%esp
f0100326:	8d 83 0f ce fe ff    	lea    -0x131f1(%ebx),%eax
f010032c:	50                   	push   %eax
f010032d:	e8 45 2d 00 00       	call   f0103077 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100332:	b8 03 00 00 00       	mov    $0x3,%eax
f0100337:	ba 92 00 00 00       	mov    $0x92,%edx
f010033c:	ee                   	out    %al,(%dx)
}
f010033d:	83 c4 10             	add    $0x10,%esp
f0100340:	eb 8d                	jmp    f01002cf <kbd_proc_data+0xa2>
		return -1;
f0100342:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100347:	eb 86                	jmp    f01002cf <kbd_proc_data+0xa2>
		return -1;
f0100349:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010034e:	e9 7c ff ff ff       	jmp    f01002cf <kbd_proc_data+0xa2>

f0100353 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100353:	55                   	push   %ebp
f0100354:	89 e5                	mov    %esp,%ebp
f0100356:	57                   	push   %edi
f0100357:	56                   	push   %esi
f0100358:	53                   	push   %ebx
f0100359:	83 ec 1c             	sub    $0x1c,%esp
f010035c:	e8 4a fe ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0100361:	81 c3 ab 6f 01 00    	add    $0x16fab,%ebx
f0100367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010036a:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010036f:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100374:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100379:	89 fa                	mov    %edi,%edx
f010037b:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010037c:	a8 20                	test   $0x20,%al
f010037e:	75 13                	jne    f0100393 <cons_putc+0x40>
f0100380:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100386:	7f 0b                	jg     f0100393 <cons_putc+0x40>
f0100388:	89 ca                	mov    %ecx,%edx
f010038a:	ec                   	in     (%dx),%al
f010038b:	ec                   	in     (%dx),%al
f010038c:	ec                   	in     (%dx),%al
f010038d:	ec                   	in     (%dx),%al
	     i++)
f010038e:	83 c6 01             	add    $0x1,%esi
f0100391:	eb e6                	jmp    f0100379 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f0100393:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100397:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010039f:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a0:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a5:	bf 79 03 00 00       	mov    $0x379,%edi
f01003aa:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003af:	89 fa                	mov    %edi,%edx
f01003b1:	ec                   	in     (%dx),%al
f01003b2:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003b8:	7f 0f                	jg     f01003c9 <cons_putc+0x76>
f01003ba:	84 c0                	test   %al,%al
f01003bc:	78 0b                	js     f01003c9 <cons_putc+0x76>
f01003be:	89 ca                	mov    %ecx,%edx
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	ec                   	in     (%dx),%al
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	ec                   	in     (%dx),%al
f01003c4:	83 c6 01             	add    $0x1,%esi
f01003c7:	eb e6                	jmp    f01003af <cons_putc+0x5c>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c9:	ba 78 03 00 00       	mov    $0x378,%edx
f01003ce:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003d2:	ee                   	out    %al,(%dx)
f01003d3:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003d8:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003dd:	ee                   	out    %al,(%dx)
f01003de:	b8 08 00 00 00       	mov    $0x8,%eax
f01003e3:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003e7:	89 f8                	mov    %edi,%eax
f01003e9:	80 cc 07             	or     $0x7,%ah
f01003ec:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003f2:	0f 45 c7             	cmovne %edi,%eax
f01003f5:	89 c7                	mov    %eax,%edi
f01003f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003fa:	0f b6 c0             	movzbl %al,%eax
f01003fd:	89 f9                	mov    %edi,%ecx
f01003ff:	80 f9 0a             	cmp    $0xa,%cl
f0100402:	0f 84 e4 00 00 00    	je     f01004ec <cons_putc+0x199>
f0100408:	83 f8 0a             	cmp    $0xa,%eax
f010040b:	7f 46                	jg     f0100453 <cons_putc+0x100>
f010040d:	83 f8 08             	cmp    $0x8,%eax
f0100410:	0f 84 a8 00 00 00    	je     f01004be <cons_putc+0x16b>
f0100416:	83 f8 09             	cmp    $0x9,%eax
f0100419:	0f 85 da 00 00 00    	jne    f01004f9 <cons_putc+0x1a6>
		cons_putc(' ');
f010041f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100424:	e8 2a ff ff ff       	call   f0100353 <cons_putc>
		cons_putc(' ');
f0100429:	b8 20 00 00 00       	mov    $0x20,%eax
f010042e:	e8 20 ff ff ff       	call   f0100353 <cons_putc>
		cons_putc(' ');
f0100433:	b8 20 00 00 00       	mov    $0x20,%eax
f0100438:	e8 16 ff ff ff       	call   f0100353 <cons_putc>
		cons_putc(' ');
f010043d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100442:	e8 0c ff ff ff       	call   f0100353 <cons_putc>
		cons_putc(' ');
f0100447:	b8 20 00 00 00       	mov    $0x20,%eax
f010044c:	e8 02 ff ff ff       	call   f0100353 <cons_putc>
		break;
f0100451:	eb 26                	jmp    f0100479 <cons_putc+0x126>
	switch (c & 0xff) {
f0100453:	83 f8 0d             	cmp    $0xd,%eax
f0100456:	0f 85 9d 00 00 00    	jne    f01004f9 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f010045c:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f0100463:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100469:	c1 e8 16             	shr    $0x16,%eax
f010046c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010046f:	c1 e0 04             	shl    $0x4,%eax
f0100472:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100479:	66 81 bb 9c 1f 00 00 	cmpw   $0x7cf,0x1f9c(%ebx)
f0100480:	cf 07 
f0100482:	0f 87 98 00 00 00    	ja     f0100520 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100488:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f010048e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100493:	89 ca                	mov    %ecx,%edx
f0100495:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100496:	0f b7 9b 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%ebx
f010049d:	8d 71 01             	lea    0x1(%ecx),%esi
f01004a0:	89 d8                	mov    %ebx,%eax
f01004a2:	66 c1 e8 08          	shr    $0x8,%ax
f01004a6:	89 f2                	mov    %esi,%edx
f01004a8:	ee                   	out    %al,(%dx)
f01004a9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ae:	89 ca                	mov    %ecx,%edx
f01004b0:	ee                   	out    %al,(%dx)
f01004b1:	89 d8                	mov    %ebx,%eax
f01004b3:	89 f2                	mov    %esi,%edx
f01004b5:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004b9:	5b                   	pop    %ebx
f01004ba:	5e                   	pop    %esi
f01004bb:	5f                   	pop    %edi
f01004bc:	5d                   	pop    %ebp
f01004bd:	c3                   	ret    
		if (crt_pos > 0) {
f01004be:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f01004c5:	66 85 c0             	test   %ax,%ax
f01004c8:	74 be                	je     f0100488 <cons_putc+0x135>
			crt_pos--;
f01004ca:	83 e8 01             	sub    $0x1,%eax
f01004cd:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004d4:	0f b7 c0             	movzwl %ax,%eax
f01004d7:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004db:	b2 00                	mov    $0x0,%dl
f01004dd:	83 ca 20             	or     $0x20,%edx
f01004e0:	8b 8b a0 1f 00 00    	mov    0x1fa0(%ebx),%ecx
f01004e6:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004ea:	eb 8d                	jmp    f0100479 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004ec:	66 83 83 9c 1f 00 00 	addw   $0x50,0x1f9c(%ebx)
f01004f3:	50 
f01004f4:	e9 63 ff ff ff       	jmp    f010045c <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004f9:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f0100500:	8d 50 01             	lea    0x1(%eax),%edx
f0100503:	66 89 93 9c 1f 00 00 	mov    %dx,0x1f9c(%ebx)
f010050a:	0f b7 c0             	movzwl %ax,%eax
f010050d:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f0100513:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100517:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010051b:	e9 59 ff ff ff       	jmp    f0100479 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100520:	8b 83 a0 1f 00 00    	mov    0x1fa0(%ebx),%eax
f0100526:	83 ec 04             	sub    $0x4,%esp
f0100529:	68 00 0f 00 00       	push   $0xf00
f010052e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100534:	52                   	push   %edx
f0100535:	50                   	push   %eax
f0100536:	e8 82 37 00 00       	call   f0103cbd <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010053b:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f0100541:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100547:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010054d:	83 c4 10             	add    $0x10,%esp
f0100550:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100555:	83 c0 02             	add    $0x2,%eax
f0100558:	39 d0                	cmp    %edx,%eax
f010055a:	75 f4                	jne    f0100550 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010055c:	66 83 ab 9c 1f 00 00 	subw   $0x50,0x1f9c(%ebx)
f0100563:	50 
f0100564:	e9 1f ff ff ff       	jmp    f0100488 <cons_putc+0x135>

f0100569 <serial_intr>:
{
f0100569:	e8 d1 01 00 00       	call   f010073f <__x86.get_pc_thunk.ax>
f010056e:	05 9e 6d 01 00       	add    $0x16d9e,%eax
	if (serial_exists)
f0100573:	80 b8 a8 1f 00 00 00 	cmpb   $0x0,0x1fa8(%eax)
f010057a:	75 01                	jne    f010057d <serial_intr+0x14>
f010057c:	c3                   	ret    
{
f010057d:	55                   	push   %ebp
f010057e:	89 e5                	mov    %esp,%ebp
f0100580:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100583:	8d 80 a3 8e fe ff    	lea    -0x1715d(%eax),%eax
f0100589:	e8 3b fc ff ff       	call   f01001c9 <cons_intr>
}
f010058e:	c9                   	leave  
f010058f:	c3                   	ret    

f0100590 <set_fg_col>:
}
f0100590:	c3                   	ret    

f0100591 <set_bg_col>:
}
f0100591:	c3                   	ret    

f0100592 <kbd_intr>:
{
f0100592:	55                   	push   %ebp
f0100593:	89 e5                	mov    %esp,%ebp
f0100595:	83 ec 08             	sub    $0x8,%esp
f0100598:	e8 a2 01 00 00       	call   f010073f <__x86.get_pc_thunk.ax>
f010059d:	05 6f 6d 01 00       	add    $0x16d6f,%eax
	cons_intr(kbd_proc_data);
f01005a2:	8d 80 21 8f fe ff    	lea    -0x170df(%eax),%eax
f01005a8:	e8 1c fc ff ff       	call   f01001c9 <cons_intr>
}
f01005ad:	c9                   	leave  
f01005ae:	c3                   	ret    

f01005af <cons_getc>:
{
f01005af:	55                   	push   %ebp
f01005b0:	89 e5                	mov    %esp,%ebp
f01005b2:	53                   	push   %ebx
f01005b3:	83 ec 04             	sub    $0x4,%esp
f01005b6:	e8 f0 fb ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f01005bb:	81 c3 51 6d 01 00    	add    $0x16d51,%ebx
	serial_intr();
f01005c1:	e8 a3 ff ff ff       	call   f0100569 <serial_intr>
	kbd_intr();
f01005c6:	e8 c7 ff ff ff       	call   f0100592 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005cb:	8b 83 94 1f 00 00    	mov    0x1f94(%ebx),%eax
	return 0;
f01005d1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005d6:	3b 83 98 1f 00 00    	cmp    0x1f98(%ebx),%eax
f01005dc:	74 1e                	je     f01005fc <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005de:	8d 48 01             	lea    0x1(%eax),%ecx
f01005e1:	0f b6 94 03 94 1d 00 	movzbl 0x1d94(%ebx,%eax,1),%edx
f01005e8:	00 
			cons.rpos = 0;
f01005e9:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f3:	0f 45 c1             	cmovne %ecx,%eax
f01005f6:	89 83 94 1f 00 00    	mov    %eax,0x1f94(%ebx)
}
f01005fc:	89 d0                	mov    %edx,%eax
f01005fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100601:	c9                   	leave  
f0100602:	c3                   	ret    

f0100603 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100603:	55                   	push   %ebp
f0100604:	89 e5                	mov    %esp,%ebp
f0100606:	57                   	push   %edi
f0100607:	56                   	push   %esi
f0100608:	53                   	push   %ebx
f0100609:	83 ec 1c             	sub    $0x1c,%esp
f010060c:	e8 9a fb ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0100611:	81 c3 fb 6c 01 00    	add    $0x16cfb,%ebx
	was = *cp;
f0100617:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010061e:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100625:	5a a5 
	if (*cp != 0xA55A) {
f0100627:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010062e:	b9 b4 03 00 00       	mov    $0x3b4,%ecx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100633:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	if (*cp != 0xA55A) {
f0100638:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010063c:	0f 84 ac 00 00 00    	je     f01006ee <cons_init+0xeb>
		addr_6845 = MONO_BASE;
f0100642:	89 8b a4 1f 00 00    	mov    %ecx,0x1fa4(%ebx)
f0100648:	b8 0e 00 00 00       	mov    $0xe,%eax
f010064d:	89 ca                	mov    %ecx,%edx
f010064f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100650:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100653:	89 f2                	mov    %esi,%edx
f0100655:	ec                   	in     (%dx),%al
f0100656:	0f b6 c0             	movzbl %al,%eax
f0100659:	c1 e0 08             	shl    $0x8,%eax
f010065c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010065f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100664:	89 ca                	mov    %ecx,%edx
f0100666:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100667:	89 f2                	mov    %esi,%edx
f0100669:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010066a:	89 bb a0 1f 00 00    	mov    %edi,0x1fa0(%ebx)
	pos |= inb(addr_6845 + 1);
f0100670:	0f b6 c0             	movzbl %al,%eax
f0100673:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100676:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010067d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100682:	89 c8                	mov    %ecx,%eax
f0100684:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100689:	ee                   	out    %al,(%dx)
f010068a:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010068f:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100694:	89 fa                	mov    %edi,%edx
f0100696:	ee                   	out    %al,(%dx)
f0100697:	b8 0c 00 00 00       	mov    $0xc,%eax
f010069c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006a1:	ee                   	out    %al,(%dx)
f01006a2:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006a7:	89 c8                	mov    %ecx,%eax
f01006a9:	89 f2                	mov    %esi,%edx
f01006ab:	ee                   	out    %al,(%dx)
f01006ac:	b8 03 00 00 00       	mov    $0x3,%eax
f01006b1:	89 fa                	mov    %edi,%edx
f01006b3:	ee                   	out    %al,(%dx)
f01006b4:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006b9:	89 c8                	mov    %ecx,%eax
f01006bb:	ee                   	out    %al,(%dx)
f01006bc:	b8 01 00 00 00       	mov    $0x1,%eax
f01006c1:	89 f2                	mov    %esi,%edx
f01006c3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006c9:	ec                   	in     (%dx),%al
f01006ca:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006cc:	3c ff                	cmp    $0xff,%al
f01006ce:	0f 95 83 a8 1f 00 00 	setne  0x1fa8(%ebx)
f01006d5:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006da:	ec                   	in     (%dx),%al
f01006db:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006e0:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006e1:	80 f9 ff             	cmp    $0xff,%cl
f01006e4:	74 1e                	je     f0100704 <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
}
f01006e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006e9:	5b                   	pop    %ebx
f01006ea:	5e                   	pop    %esi
f01006eb:	5f                   	pop    %edi
f01006ec:	5d                   	pop    %ebp
f01006ed:	c3                   	ret    
		*cp = was;
f01006ee:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f01006f5:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006fa:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f01006ff:	e9 3e ff ff ff       	jmp    f0100642 <cons_init+0x3f>
		cprintf("Serial port does not exist!\n");
f0100704:	83 ec 0c             	sub    $0xc,%esp
f0100707:	8d 83 1b ce fe ff    	lea    -0x131e5(%ebx),%eax
f010070d:	50                   	push   %eax
f010070e:	e8 64 29 00 00       	call   f0103077 <cprintf>
f0100713:	83 c4 10             	add    $0x10,%esp
}
f0100716:	eb ce                	jmp    f01006e6 <cons_init+0xe3>

f0100718 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100718:	55                   	push   %ebp
f0100719:	89 e5                	mov    %esp,%ebp
f010071b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010071e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100721:	e8 2d fc ff ff       	call   f0100353 <cons_putc>
}
f0100726:	c9                   	leave  
f0100727:	c3                   	ret    

f0100728 <getchar>:

int
getchar(void)
{
f0100728:	55                   	push   %ebp
f0100729:	89 e5                	mov    %esp,%ebp
f010072b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010072e:	e8 7c fe ff ff       	call   f01005af <cons_getc>
f0100733:	85 c0                	test   %eax,%eax
f0100735:	74 f7                	je     f010072e <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100737:	c9                   	leave  
f0100738:	c3                   	ret    

f0100739 <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f0100739:	b8 01 00 00 00       	mov    $0x1,%eax
f010073e:	c3                   	ret    

f010073f <__x86.get_pc_thunk.ax>:
f010073f:	8b 04 24             	mov    (%esp),%eax
f0100742:	c3                   	ret    

f0100743 <__x86.get_pc_thunk.si>:
f0100743:	8b 34 24             	mov    (%esp),%esi
f0100746:	c3                   	ret    

f0100747 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100747:	55                   	push   %ebp
f0100748:	89 e5                	mov    %esp,%ebp
f010074a:	56                   	push   %esi
f010074b:	53                   	push   %ebx
f010074c:	e8 5a fa ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0100751:	81 c3 bb 6b 01 00    	add    $0x16bbb,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100757:	83 ec 04             	sub    $0x4,%esp
f010075a:	8d 83 54 d0 fe ff    	lea    -0x12fac(%ebx),%eax
f0100760:	50                   	push   %eax
f0100761:	8d 83 72 d0 fe ff    	lea    -0x12f8e(%ebx),%eax
f0100767:	50                   	push   %eax
f0100768:	8d b3 77 d0 fe ff    	lea    -0x12f89(%ebx),%esi
f010076e:	56                   	push   %esi
f010076f:	e8 03 29 00 00       	call   f0103077 <cprintf>
f0100774:	83 c4 0c             	add    $0xc,%esp
f0100777:	8d 83 30 d1 fe ff    	lea    -0x12ed0(%ebx),%eax
f010077d:	50                   	push   %eax
f010077e:	8d 83 80 d0 fe ff    	lea    -0x12f80(%ebx),%eax
f0100784:	50                   	push   %eax
f0100785:	56                   	push   %esi
f0100786:	e8 ec 28 00 00       	call   f0103077 <cprintf>
f010078b:	83 c4 0c             	add    $0xc,%esp
f010078e:	8d 83 58 d1 fe ff    	lea    -0x12ea8(%ebx),%eax
f0100794:	50                   	push   %eax
f0100795:	8d 83 89 d0 fe ff    	lea    -0x12f77(%ebx),%eax
f010079b:	50                   	push   %eax
f010079c:	56                   	push   %esi
f010079d:	e8 d5 28 00 00       	call   f0103077 <cprintf>
	return 0;
}
f01007a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007aa:	5b                   	pop    %ebx
f01007ab:	5e                   	pop    %esi
f01007ac:	5d                   	pop    %ebp
f01007ad:	c3                   	ret    

f01007ae <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007ae:	55                   	push   %ebp
f01007af:	89 e5                	mov    %esp,%ebp
f01007b1:	57                   	push   %edi
f01007b2:	56                   	push   %esi
f01007b3:	53                   	push   %ebx
f01007b4:	83 ec 18             	sub    $0x18,%esp
f01007b7:	e8 ef f9 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f01007bc:	81 c3 50 6b 01 00    	add    $0x16b50,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c2:	8d 83 93 d0 fe ff    	lea    -0x12f6d(%ebx),%eax
f01007c8:	50                   	push   %eax
f01007c9:	e8 a9 28 00 00       	call   f0103077 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ce:	83 c4 08             	add    $0x8,%esp
f01007d1:	ff b3 f4 ff ff ff    	push   -0xc(%ebx)
f01007d7:	8d 83 84 d1 fe ff    	lea    -0x12e7c(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	e8 94 28 00 00       	call   f0103077 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007ec:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f2:	50                   	push   %eax
f01007f3:	57                   	push   %edi
f01007f4:	8d 83 ac d1 fe ff    	lea    -0x12e54(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 77 28 00 00       	call   f0103077 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	c7 c0 a1 40 10 f0    	mov    $0xf01040a1,%eax
f0100809:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010080f:	52                   	push   %edx
f0100810:	50                   	push   %eax
f0100811:	8d 83 d0 d1 fe ff    	lea    -0x12e30(%ebx),%eax
f0100817:	50                   	push   %eax
f0100818:	e8 5a 28 00 00       	call   f0103077 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010081d:	83 c4 0c             	add    $0xc,%esp
f0100820:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f0100826:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010082c:	52                   	push   %edx
f010082d:	50                   	push   %eax
f010082e:	8d 83 f4 d1 fe ff    	lea    -0x12e0c(%ebx),%eax
f0100834:	50                   	push   %eax
f0100835:	e8 3d 28 00 00       	call   f0103077 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083a:	83 c4 0c             	add    $0xc,%esp
f010083d:	c7 c6 e0 96 11 f0    	mov    $0xf01196e0,%esi
f0100843:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100849:	50                   	push   %eax
f010084a:	56                   	push   %esi
f010084b:	8d 83 18 d2 fe ff    	lea    -0x12de8(%ebx),%eax
f0100851:	50                   	push   %eax
f0100852:	e8 20 28 00 00       	call   f0103077 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100857:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085a:	29 fe                	sub    %edi,%esi
f010085c:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100862:	c1 fe 0a             	sar    $0xa,%esi
f0100865:	56                   	push   %esi
f0100866:	8d 83 3c d2 fe ff    	lea    -0x12dc4(%ebx),%eax
f010086c:	50                   	push   %eax
f010086d:	e8 05 28 00 00       	call   f0103077 <cprintf>
	return 0;
}
f0100872:	b8 00 00 00 00       	mov    $0x0,%eax
f0100877:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087a:	5b                   	pop    %ebx
f010087b:	5e                   	pop    %esi
f010087c:	5f                   	pop    %edi
f010087d:	5d                   	pop    %ebp
f010087e:	c3                   	ret    

f010087f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010087f:	55                   	push   %ebp
f0100880:	89 e5                	mov    %esp,%ebp
f0100882:	57                   	push   %edi
f0100883:	56                   	push   %esi
f0100884:	53                   	push   %ebx
f0100885:	83 ec 48             	sub    $0x48,%esp
f0100888:	e8 1e f9 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f010088d:	81 c3 7f 6a 01 00    	add    $0x16a7f,%ebx
	cprintf("Stack backtrace:\n");
f0100893:	8d 83 ac d0 fe ff    	lea    -0x12f54(%ebx),%eax
f0100899:	50                   	push   %eax
f010089a:	e8 d8 27 00 00       	call   f0103077 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010089f:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp, eip;
	struct Eipdebuginfo info;

	ebp = (uint32_t *)read_ebp();
f01008a1:	89 c7                	mov    %eax,%edi
	while (ebp) {
f01008a3:	83 c4 10             	add    $0x10,%esp
		eip = *(ebp + 1);
		debuginfo_eip(eip, &info);
		cprintf("  ebp %08x  eip %08x  args", ebp, eip);
f01008a6:	8d 83 be d0 fe ff    	lea    -0x12f42(%ebx),%eax
f01008ac:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (int i = 0; i < 5; i++) {
			cprintf(" %08x", *(ebp + 2 + i));
f01008af:	8d 83 d9 d0 fe ff    	lea    -0x12f27(%ebx),%eax
f01008b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (ebp) {
f01008b8:	eb 39                	jmp    f01008f3 <mon_backtrace+0x74>
			if (i == 4) {
				cprintf("\n");
f01008ba:	83 ec 0c             	sub    $0xc,%esp
f01008bd:	8d 83 7d d5 fe ff    	lea    -0x12a83(%ebx),%eax
f01008c3:	50                   	push   %eax
f01008c4:	e8 ae 27 00 00       	call   f0103077 <cprintf>
f01008c9:	83 c4 10             	add    $0x10,%esp
			}
		}
		cprintf("		 %s:%d: %.*s+%d\n", info.eip_file, info.eip_line,
f01008cc:	83 ec 08             	sub    $0x8,%esp
f01008cf:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01008d2:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008d5:	50                   	push   %eax
f01008d6:	ff 75 d8             	push   -0x28(%ebp)
f01008d9:	ff 75 dc             	push   -0x24(%ebp)
f01008dc:	ff 75 d4             	push   -0x2c(%ebp)
f01008df:	ff 75 d0             	push   -0x30(%ebp)
f01008e2:	8d 83 df d0 fe ff    	lea    -0x12f21(%ebx),%eax
f01008e8:	50                   	push   %eax
f01008e9:	e8 89 27 00 00       	call   f0103077 <cprintf>
			info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t *)*ebp;
f01008ee:	8b 3f                	mov    (%edi),%edi
f01008f0:	83 c4 20             	add    $0x20,%esp
	while (ebp) {
f01008f3:	85 ff                	test   %edi,%edi
f01008f5:	74 4b                	je     f0100942 <mon_backtrace+0xc3>
		eip = *(ebp + 1);
f01008f7:	8b 47 04             	mov    0x4(%edi),%eax
f01008fa:	89 c6                	mov    %eax,%esi
f01008fc:	89 45 c0             	mov    %eax,-0x40(%ebp)
		debuginfo_eip(eip, &info);
f01008ff:	83 ec 08             	sub    $0x8,%esp
f0100902:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100905:	50                   	push   %eax
f0100906:	56                   	push   %esi
f0100907:	e8 74 28 00 00       	call   f0103180 <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args", ebp, eip);
f010090c:	83 c4 0c             	add    $0xc,%esp
f010090f:	56                   	push   %esi
f0100910:	57                   	push   %edi
f0100911:	ff 75 bc             	push   -0x44(%ebp)
f0100914:	e8 5e 27 00 00       	call   f0103077 <cprintf>
f0100919:	83 c4 10             	add    $0x10,%esp
		for (int i = 0; i < 5; i++) {
f010091c:	be 00 00 00 00       	mov    $0x0,%esi
			cprintf(" %08x", *(ebp + 2 + i));
f0100921:	83 ec 08             	sub    $0x8,%esp
f0100924:	ff 74 b7 08          	push   0x8(%edi,%esi,4)
f0100928:	ff 75 c4             	push   -0x3c(%ebp)
f010092b:	e8 47 27 00 00       	call   f0103077 <cprintf>
			if (i == 4) {
f0100930:	83 c4 10             	add    $0x10,%esp
f0100933:	83 fe 04             	cmp    $0x4,%esi
f0100936:	74 82                	je     f01008ba <mon_backtrace+0x3b>
		for (int i = 0; i < 5; i++) {
f0100938:	83 c6 01             	add    $0x1,%esi
f010093b:	83 fe 05             	cmp    $0x5,%esi
f010093e:	75 e1                	jne    f0100921 <mon_backtrace+0xa2>
f0100940:	eb 8a                	jmp    f01008cc <mon_backtrace+0x4d>
	}
	return 0;
}
f0100942:	b8 00 00 00 00       	mov    $0x0,%eax
f0100947:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010094a:	5b                   	pop    %ebx
f010094b:	5e                   	pop    %esi
f010094c:	5f                   	pop    %edi
f010094d:	5d                   	pop    %ebp
f010094e:	c3                   	ret    

f010094f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010094f:	55                   	push   %ebp
f0100950:	89 e5                	mov    %esp,%ebp
f0100952:	57                   	push   %edi
f0100953:	56                   	push   %esi
f0100954:	53                   	push   %ebx
f0100955:	83 ec 68             	sub    $0x68,%esp
f0100958:	e8 4e f8 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f010095d:	81 c3 af 69 01 00    	add    $0x169af,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100963:	8d 83 68 d2 fe ff    	lea    -0x12d98(%ebx),%eax
f0100969:	50                   	push   %eax
f010096a:	e8 08 27 00 00       	call   f0103077 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010096f:	8d 83 8c d2 fe ff    	lea    -0x12d74(%ebx),%eax
f0100975:	89 04 24             	mov    %eax,(%esp)
f0100978:	e8 fa 26 00 00       	call   f0103077 <cprintf>
f010097d:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100980:	8d bb f6 d0 fe ff    	lea    -0x12f0a(%ebx),%edi
f0100986:	eb 4a                	jmp    f01009d2 <monitor+0x83>
f0100988:	83 ec 08             	sub    $0x8,%esp
f010098b:	0f be c0             	movsbl %al,%eax
f010098e:	50                   	push   %eax
f010098f:	57                   	push   %edi
f0100990:	e8 a3 32 00 00       	call   f0103c38 <strchr>
f0100995:	83 c4 10             	add    $0x10,%esp
f0100998:	85 c0                	test   %eax,%eax
f010099a:	74 08                	je     f01009a4 <monitor+0x55>
			*buf++ = 0;
f010099c:	c6 06 00             	movb   $0x0,(%esi)
f010099f:	8d 76 01             	lea    0x1(%esi),%esi
f01009a2:	eb 76                	jmp    f0100a1a <monitor+0xcb>
		if (*buf == 0)
f01009a4:	80 3e 00             	cmpb   $0x0,(%esi)
f01009a7:	74 7c                	je     f0100a25 <monitor+0xd6>
		if (argc == MAXARGS-1) {
f01009a9:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009ad:	74 0f                	je     f01009be <monitor+0x6f>
		argv[argc++] = buf;
f01009af:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009b2:	8d 48 01             	lea    0x1(%eax),%ecx
f01009b5:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009b8:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009bc:	eb 41                	jmp    f01009ff <monitor+0xb0>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009be:	83 ec 08             	sub    $0x8,%esp
f01009c1:	6a 10                	push   $0x10
f01009c3:	8d 83 fb d0 fe ff    	lea    -0x12f05(%ebx),%eax
f01009c9:	50                   	push   %eax
f01009ca:	e8 a8 26 00 00       	call   f0103077 <cprintf>
			return 0;
f01009cf:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009d2:	8d 83 f2 d0 fe ff    	lea    -0x12f0e(%ebx),%eax
f01009d8:	89 c6                	mov    %eax,%esi
f01009da:	83 ec 0c             	sub    $0xc,%esp
f01009dd:	56                   	push   %esi
f01009de:	e8 04 30 00 00       	call   f01039e7 <readline>
		if (buf != NULL)
f01009e3:	83 c4 10             	add    $0x10,%esp
f01009e6:	85 c0                	test   %eax,%eax
f01009e8:	74 f0                	je     f01009da <monitor+0x8b>
	argv[argc] = 0;
f01009ea:	89 c6                	mov    %eax,%esi
f01009ec:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009f3:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01009fa:	eb 1e                	jmp    f0100a1a <monitor+0xcb>
			buf++;
f01009fc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009ff:	0f b6 06             	movzbl (%esi),%eax
f0100a02:	84 c0                	test   %al,%al
f0100a04:	74 14                	je     f0100a1a <monitor+0xcb>
f0100a06:	83 ec 08             	sub    $0x8,%esp
f0100a09:	0f be c0             	movsbl %al,%eax
f0100a0c:	50                   	push   %eax
f0100a0d:	57                   	push   %edi
f0100a0e:	e8 25 32 00 00       	call   f0103c38 <strchr>
f0100a13:	83 c4 10             	add    $0x10,%esp
f0100a16:	85 c0                	test   %eax,%eax
f0100a18:	74 e2                	je     f01009fc <monitor+0xad>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a1a:	0f b6 06             	movzbl (%esi),%eax
f0100a1d:	84 c0                	test   %al,%al
f0100a1f:	0f 85 63 ff ff ff    	jne    f0100988 <monitor+0x39>
	argv[argc] = 0;
f0100a25:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a28:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a2f:	00 
	if (argc == 0)
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	74 9e                	je     f01009d2 <monitor+0x83>
f0100a34:	8d b3 14 1d 00 00    	lea    0x1d14(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a3f:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a42:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a44:	83 ec 08             	sub    $0x8,%esp
f0100a47:	ff 36                	push   (%esi)
f0100a49:	ff 75 a8             	push   -0x58(%ebp)
f0100a4c:	e8 87 31 00 00       	call   f0103bd8 <strcmp>
f0100a51:	83 c4 10             	add    $0x10,%esp
f0100a54:	85 c0                	test   %eax,%eax
f0100a56:	74 28                	je     f0100a80 <monitor+0x131>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a58:	83 c7 01             	add    $0x1,%edi
f0100a5b:	83 c6 0c             	add    $0xc,%esi
f0100a5e:	83 ff 03             	cmp    $0x3,%edi
f0100a61:	75 e1                	jne    f0100a44 <monitor+0xf5>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a63:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a66:	83 ec 08             	sub    $0x8,%esp
f0100a69:	ff 75 a8             	push   -0x58(%ebp)
f0100a6c:	8d 83 18 d1 fe ff    	lea    -0x12ee8(%ebx),%eax
f0100a72:	50                   	push   %eax
f0100a73:	e8 ff 25 00 00       	call   f0103077 <cprintf>
	return 0;
f0100a78:	83 c4 10             	add    $0x10,%esp
f0100a7b:	e9 52 ff ff ff       	jmp    f01009d2 <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a80:	89 f8                	mov    %edi,%eax
f0100a82:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100a85:	83 ec 04             	sub    $0x4,%esp
f0100a88:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a8b:	ff 75 08             	push   0x8(%ebp)
f0100a8e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a91:	52                   	push   %edx
f0100a92:	ff 75 a4             	push   -0x5c(%ebp)
f0100a95:	ff 94 83 1c 1d 00 00 	call   *0x1d1c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a9c:	83 c4 10             	add    $0x10,%esp
f0100a9f:	85 c0                	test   %eax,%eax
f0100aa1:	0f 89 2b ff ff ff    	jns    f01009d2 <monitor+0x83>
				break;
	}
}
f0100aa7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aaa:	5b                   	pop    %ebx
f0100aab:	5e                   	pop    %esi
f0100aac:	5f                   	pop    %edi
f0100aad:	5d                   	pop    %ebp
f0100aae:	c3                   	ret    

f0100aaf <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100aaf:	55                   	push   %ebp
f0100ab0:	89 e5                	mov    %esp,%ebp
f0100ab2:	57                   	push   %edi
f0100ab3:	56                   	push   %esi
f0100ab4:	53                   	push   %ebx
f0100ab5:	83 ec 18             	sub    $0x18,%esp
f0100ab8:	e8 ee f6 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0100abd:	81 c3 4f 68 01 00    	add    $0x1684f,%ebx
f0100ac3:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac5:	50                   	push   %eax
f0100ac6:	e8 1c 25 00 00       	call   f0102fe7 <mc146818_read>
f0100acb:	89 c7                	mov    %eax,%edi
f0100acd:	83 c6 01             	add    $0x1,%esi
f0100ad0:	89 34 24             	mov    %esi,(%esp)
f0100ad3:	e8 0f 25 00 00       	call   f0102fe7 <mc146818_read>
f0100ad8:	c1 e0 08             	shl    $0x8,%eax
f0100adb:	09 f8                	or     %edi,%eax
}
f0100add:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ae0:	5b                   	pop    %ebx
f0100ae1:	5e                   	pop    %esi
f0100ae2:	5f                   	pop    %edi
f0100ae3:	5d                   	pop    %ebp
f0100ae4:	c3                   	ret    

f0100ae5 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ae5:	e8 f1 24 00 00       	call   f0102fdb <__x86.get_pc_thunk.dx>
f0100aea:	81 c2 22 68 01 00    	add    $0x16822,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100af0:	83 ba b8 1f 00 00 00 	cmpl   $0x0,0x1fb8(%edx)
f0100af7:	74 3c                	je     f0100b35 <boot_alloc+0x50>
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("KERNBASE is %x\n", KERNBASE);
	
	result = nextfree;
f0100af9:	8b 8a b8 1f 00 00    	mov    0x1fb8(%edx),%ecx
	if (n > 0) {
f0100aff:	85 c0                	test   %eax,%eax
f0100b01:	74 66                	je     f0100b69 <boot_alloc+0x84>
{
f0100b03:	55                   	push   %ebp
f0100b04:	89 e5                	mov    %esp,%ebp
f0100b06:	53                   	push   %ebx
f0100b07:	83 ec 04             	sub    $0x4,%esp
		nextfree = (char *)ROUNDUP((uint32_t) nextfree + n, PGSIZE);
f0100b0a:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0100b11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b16:	89 82 b8 1f 00 00    	mov    %eax,0x1fb8(%edx)
		if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE)
f0100b1c:	05 00 00 00 10       	add    $0x10000000,%eax
f0100b21:	8b 9a b4 1f 00 00    	mov    0x1fb4(%edx),%ebx
f0100b27:	c1 e3 0c             	shl    $0xc,%ebx
f0100b2a:	39 d8                	cmp    %ebx,%eax
f0100b2c:	77 21                	ja     f0100b4f <boot_alloc+0x6a>
			panic("boot_alloc: out of memory\n");
	}
	return result;
}
f0100b2e:	89 c8                	mov    %ecx,%eax
f0100b30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b33:	c9                   	leave  
f0100b34:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b35:	c7 c1 e0 96 11 f0    	mov    $0xf01196e0,%ecx
f0100b3b:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100b41:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100b47:	89 8a b8 1f 00 00    	mov    %ecx,0x1fb8(%edx)
f0100b4d:	eb aa                	jmp    f0100af9 <boot_alloc+0x14>
			panic("boot_alloc: out of memory\n");
f0100b4f:	83 ec 04             	sub    $0x4,%esp
f0100b52:	8d 82 b1 d2 fe ff    	lea    -0x12d4f(%edx),%eax
f0100b58:	50                   	push   %eax
f0100b59:	6a 70                	push   $0x70
f0100b5b:	8d 82 cc d2 fe ff    	lea    -0x12d34(%edx),%eax
f0100b61:	50                   	push   %eax
f0100b62:	89 d3                	mov    %edx,%ebx
f0100b64:	e8 8c f5 ff ff       	call   f01000f5 <_panic>
}
f0100b69:	89 c8                	mov    %ecx,%eax
f0100b6b:	c3                   	ret    

f0100b6c <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b6c:	55                   	push   %ebp
f0100b6d:	89 e5                	mov    %esp,%ebp
f0100b6f:	53                   	push   %ebx
f0100b70:	83 ec 04             	sub    $0x4,%esp
f0100b73:	e8 67 24 00 00       	call   f0102fdf <__x86.get_pc_thunk.cx>
f0100b78:	81 c1 94 67 01 00    	add    $0x16794,%ecx
f0100b7e:	89 c3                	mov    %eax,%ebx
f0100b80:	89 d0                	mov    %edx,%eax
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100b82:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P))
f0100b85:	8b 14 93             	mov    (%ebx,%edx,4),%edx
f0100b88:	f6 c2 01             	test   $0x1,%dl
f0100b8b:	74 54                	je     f0100be1 <check_va2pa+0x75>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b8d:	89 d3                	mov    %edx,%ebx
f0100b8f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b95:	c1 ea 0c             	shr    $0xc,%edx
f0100b98:	3b 91 b4 1f 00 00    	cmp    0x1fb4(%ecx),%edx
f0100b9e:	73 26                	jae    f0100bc6 <check_va2pa+0x5a>
	if (!(p[PTX(va)] & PTE_P))
f0100ba0:	c1 e8 0c             	shr    $0xc,%eax
f0100ba3:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100ba8:	8b 94 83 00 00 00 f0 	mov    -0x10000000(%ebx,%eax,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100baf:	89 d0                	mov    %edx,%eax
f0100bb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100bb6:	f6 c2 01             	test   $0x1,%dl
f0100bb9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100bbe:	0f 44 c2             	cmove  %edx,%eax
}
f0100bc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bc4:	c9                   	leave  
f0100bc5:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bc6:	53                   	push   %ebx
f0100bc7:	8d 81 b0 d5 fe ff    	lea    -0x12a50(%ecx),%eax
f0100bcd:	50                   	push   %eax
f0100bce:	68 cf 02 00 00       	push   $0x2cf
f0100bd3:	8d 81 cc d2 fe ff    	lea    -0x12d34(%ecx),%eax
f0100bd9:	50                   	push   %eax
f0100bda:	89 cb                	mov    %ecx,%ebx
f0100bdc:	e8 14 f5 ff ff       	call   f01000f5 <_panic>
		return ~0;
f0100be1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100be6:	eb d9                	jmp    f0100bc1 <check_va2pa+0x55>

f0100be8 <check_page_free_list>:
{
f0100be8:	55                   	push   %ebp
f0100be9:	89 e5                	mov    %esp,%ebp
f0100beb:	57                   	push   %edi
f0100bec:	56                   	push   %esi
f0100bed:	53                   	push   %ebx
f0100bee:	83 ec 2c             	sub    $0x2c,%esp
f0100bf1:	e8 ed 23 00 00       	call   f0102fe3 <__x86.get_pc_thunk.di>
f0100bf6:	81 c7 16 67 01 00    	add    $0x16716,%edi
f0100bfc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bff:	84 c0                	test   %al,%al
f0100c01:	0f 85 dc 02 00 00    	jne    f0100ee3 <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100c07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c0a:	83 b8 bc 1f 00 00 00 	cmpl   $0x0,0x1fbc(%eax)
f0100c11:	74 0a                	je     f0100c1d <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c13:	bf 00 04 00 00       	mov    $0x400,%edi
f0100c18:	e9 29 03 00 00       	jmp    f0100f46 <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100c1d:	83 ec 04             	sub    $0x4,%esp
f0100c20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c23:	8d 83 d4 d5 fe ff    	lea    -0x12a2c(%ebx),%eax
f0100c29:	50                   	push   %eax
f0100c2a:	68 10 02 00 00       	push   $0x210
f0100c2f:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100c35:	50                   	push   %eax
f0100c36:	e8 ba f4 ff ff       	call   f01000f5 <_panic>
f0100c3b:	50                   	push   %eax
f0100c3c:	89 cb                	mov    %ecx,%ebx
f0100c3e:	8d 81 b0 d5 fe ff    	lea    -0x12a50(%ecx),%eax
f0100c44:	50                   	push   %eax
f0100c45:	6a 52                	push   $0x52
f0100c47:	8d 81 d8 d2 fe ff    	lea    -0x12d28(%ecx),%eax
f0100c4d:	50                   	push   %eax
f0100c4e:	e8 a2 f4 ff ff       	call   f01000f5 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c53:	8b 36                	mov    (%esi),%esi
f0100c55:	85 f6                	test   %esi,%esi
f0100c57:	74 47                	je     f0100ca0 <check_page_free_list+0xb8>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c59:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100c5c:	89 f0                	mov    %esi,%eax
f0100c5e:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0100c64:	c1 f8 03             	sar    $0x3,%eax
f0100c67:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c6a:	89 c2                	mov    %eax,%edx
f0100c6c:	c1 ea 16             	shr    $0x16,%edx
f0100c6f:	39 fa                	cmp    %edi,%edx
f0100c71:	73 e0                	jae    f0100c53 <check_page_free_list+0x6b>
	if (PGNUM(pa) >= npages)
f0100c73:	89 c2                	mov    %eax,%edx
f0100c75:	c1 ea 0c             	shr    $0xc,%edx
f0100c78:	3b 91 b4 1f 00 00    	cmp    0x1fb4(%ecx),%edx
f0100c7e:	73 bb                	jae    f0100c3b <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100c80:	83 ec 04             	sub    $0x4,%esp
f0100c83:	68 80 00 00 00       	push   $0x80
f0100c88:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c92:	50                   	push   %eax
f0100c93:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c96:	e8 dc 2f 00 00       	call   f0103c77 <memset>
f0100c9b:	83 c4 10             	add    $0x10,%esp
f0100c9e:	eb b3                	jmp    f0100c53 <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca5:	e8 3b fe ff ff       	call   f0100ae5 <boot_alloc>
f0100caa:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cb0:	8b 90 bc 1f 00 00    	mov    0x1fbc(%eax),%edx
		assert(pp >= pages);
f0100cb6:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
		assert(pp < pages + npages);
f0100cbc:	8b 80 b4 1f 00 00    	mov    0x1fb4(%eax),%eax
f0100cc2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100cc5:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100cc8:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cd2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cd5:	e9 07 01 00 00       	jmp    f0100de1 <check_page_free_list+0x1f9>
		assert(pp >= pages);
f0100cda:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cdd:	8d 83 e6 d2 fe ff    	lea    -0x12d1a(%ebx),%eax
f0100ce3:	50                   	push   %eax
f0100ce4:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100cea:	50                   	push   %eax
f0100ceb:	68 2a 02 00 00       	push   $0x22a
f0100cf0:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100cf6:	50                   	push   %eax
f0100cf7:	e8 f9 f3 ff ff       	call   f01000f5 <_panic>
		assert(pp < pages + npages);
f0100cfc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cff:	8d 83 07 d3 fe ff    	lea    -0x12cf9(%ebx),%eax
f0100d05:	50                   	push   %eax
f0100d06:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100d0c:	50                   	push   %eax
f0100d0d:	68 2b 02 00 00       	push   $0x22b
f0100d12:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100d18:	50                   	push   %eax
f0100d19:	e8 d7 f3 ff ff       	call   f01000f5 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d1e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d21:	8d 83 f8 d5 fe ff    	lea    -0x12a08(%ebx),%eax
f0100d27:	50                   	push   %eax
f0100d28:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100d2e:	50                   	push   %eax
f0100d2f:	68 2c 02 00 00       	push   $0x22c
f0100d34:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100d3a:	50                   	push   %eax
f0100d3b:	e8 b5 f3 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) != 0);
f0100d40:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d43:	8d 83 1b d3 fe ff    	lea    -0x12ce5(%ebx),%eax
f0100d49:	50                   	push   %eax
f0100d4a:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100d50:	50                   	push   %eax
f0100d51:	68 2f 02 00 00       	push   $0x22f
f0100d56:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100d5c:	50                   	push   %eax
f0100d5d:	e8 93 f3 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d65:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f0100d6b:	50                   	push   %eax
f0100d6c:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100d72:	50                   	push   %eax
f0100d73:	68 30 02 00 00       	push   $0x230
f0100d78:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100d7e:	50                   	push   %eax
f0100d7f:	e8 71 f3 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d84:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d87:	8d 83 2c d6 fe ff    	lea    -0x129d4(%ebx),%eax
f0100d8d:	50                   	push   %eax
f0100d8e:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100d94:	50                   	push   %eax
f0100d95:	68 31 02 00 00       	push   $0x231
f0100d9a:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100da0:	50                   	push   %eax
f0100da1:	e8 4f f3 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100da9:	8d 83 45 d3 fe ff    	lea    -0x12cbb(%ebx),%eax
f0100daf:	50                   	push   %eax
f0100db0:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100db6:	50                   	push   %eax
f0100db7:	68 32 02 00 00       	push   $0x232
f0100dbc:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100dc2:	50                   	push   %eax
f0100dc3:	e8 2d f3 ff ff       	call   f01000f5 <_panic>
	if (PGNUM(pa) >= npages)
f0100dc8:	89 c3                	mov    %eax,%ebx
f0100dca:	c1 eb 0c             	shr    $0xc,%ebx
f0100dcd:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0100dd0:	76 6d                	jbe    f0100e3f <check_page_free_list+0x257>
	return (void *)(pa + KERNBASE);
f0100dd2:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dd7:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100dda:	77 7c                	ja     f0100e58 <check_page_free_list+0x270>
			++nfree_extmem;
f0100ddc:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ddf:	8b 12                	mov    (%edx),%edx
f0100de1:	85 d2                	test   %edx,%edx
f0100de3:	0f 84 91 00 00 00    	je     f0100e7a <check_page_free_list+0x292>
		assert(pp >= pages);
f0100de9:	39 d1                	cmp    %edx,%ecx
f0100deb:	0f 87 e9 fe ff ff    	ja     f0100cda <check_page_free_list+0xf2>
		assert(pp < pages + npages);
f0100df1:	39 d6                	cmp    %edx,%esi
f0100df3:	0f 86 03 ff ff ff    	jbe    f0100cfc <check_page_free_list+0x114>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100df9:	89 d0                	mov    %edx,%eax
f0100dfb:	29 c8                	sub    %ecx,%eax
f0100dfd:	a8 07                	test   $0x7,%al
f0100dff:	0f 85 19 ff ff ff    	jne    f0100d1e <check_page_free_list+0x136>
	return (pp - pages) << PGSHIFT;
f0100e05:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100e08:	c1 e0 0c             	shl    $0xc,%eax
f0100e0b:	0f 84 2f ff ff ff    	je     f0100d40 <check_page_free_list+0x158>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e11:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e16:	0f 84 46 ff ff ff    	je     f0100d62 <check_page_free_list+0x17a>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e1c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e21:	0f 84 5d ff ff ff    	je     f0100d84 <check_page_free_list+0x19c>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e27:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e2c:	0f 84 74 ff ff ff    	je     f0100da6 <check_page_free_list+0x1be>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e32:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e37:	77 8f                	ja     f0100dc8 <check_page_free_list+0x1e0>
			++nfree_basemem;
f0100e39:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
f0100e3d:	eb a0                	jmp    f0100ddf <check_page_free_list+0x1f7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e3f:	50                   	push   %eax
f0100e40:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e43:	8d 83 b0 d5 fe ff    	lea    -0x12a50(%ebx),%eax
f0100e49:	50                   	push   %eax
f0100e4a:	6a 52                	push   $0x52
f0100e4c:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f0100e52:	50                   	push   %eax
f0100e53:	e8 9d f2 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e5b:	8d 83 50 d6 fe ff    	lea    -0x129b0(%ebx),%eax
f0100e61:	50                   	push   %eax
f0100e62:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100e68:	50                   	push   %eax
f0100e69:	68 33 02 00 00       	push   $0x233
f0100e6e:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100e74:	50                   	push   %eax
f0100e75:	e8 7b f2 ff ff       	call   f01000f5 <_panic>
	assert(nfree_basemem > 0);
f0100e7a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0100e7d:	85 db                	test   %ebx,%ebx
f0100e7f:	7e 1e                	jle    f0100e9f <check_page_free_list+0x2b7>
	assert(nfree_extmem > 0);
f0100e81:	85 ff                	test   %edi,%edi
f0100e83:	7e 3c                	jle    f0100ec1 <check_page_free_list+0x2d9>
	cprintf("check_page_free_list() succeeded!\n");
f0100e85:	83 ec 0c             	sub    $0xc,%esp
f0100e88:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e8b:	8d 83 98 d6 fe ff    	lea    -0x12968(%ebx),%eax
f0100e91:	50                   	push   %eax
f0100e92:	e8 e0 21 00 00       	call   f0103077 <cprintf>
}
f0100e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e9a:	5b                   	pop    %ebx
f0100e9b:	5e                   	pop    %esi
f0100e9c:	5f                   	pop    %edi
f0100e9d:	5d                   	pop    %ebp
f0100e9e:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e9f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ea2:	8d 83 5f d3 fe ff    	lea    -0x12ca1(%ebx),%eax
f0100ea8:	50                   	push   %eax
f0100ea9:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100eaf:	50                   	push   %eax
f0100eb0:	68 3b 02 00 00       	push   $0x23b
f0100eb5:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100ebb:	50                   	push   %eax
f0100ebc:	e8 34 f2 ff ff       	call   f01000f5 <_panic>
	assert(nfree_extmem > 0);
f0100ec1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ec4:	8d 83 71 d3 fe ff    	lea    -0x12c8f(%ebx),%eax
f0100eca:	50                   	push   %eax
f0100ecb:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0100ed1:	50                   	push   %eax
f0100ed2:	68 3c 02 00 00       	push   $0x23c
f0100ed7:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100edd:	50                   	push   %eax
f0100ede:	e8 12 f2 ff ff       	call   f01000f5 <_panic>
	if (!page_free_list)
f0100ee3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ee6:	8b 80 bc 1f 00 00    	mov    0x1fbc(%eax),%eax
f0100eec:	85 c0                	test   %eax,%eax
f0100eee:	0f 84 29 fd ff ff    	je     f0100c1d <check_page_free_list+0x35>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ef4:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ef7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100efa:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100efd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0100f00:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f03:	89 c2                	mov    %eax,%edx
f0100f05:	2b 97 ac 1f 00 00    	sub    0x1fac(%edi),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f0b:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100f11:	0f 95 c2             	setne  %dl
f0100f14:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100f17:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100f1b:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f1d:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f21:	8b 00                	mov    (%eax),%eax
f0100f23:	85 c0                	test   %eax,%eax
f0100f25:	75 d9                	jne    f0100f00 <check_page_free_list+0x318>
		*tp[1] = 0;
f0100f27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f30:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f33:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f36:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f38:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f3b:	89 87 bc 1f 00 00    	mov    %eax,0x1fbc(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f41:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f49:	8b b0 bc 1f 00 00    	mov    0x1fbc(%eax),%esi
f0100f4f:	e9 01 fd ff ff       	jmp    f0100c55 <check_page_free_list+0x6d>

f0100f54 <page_init>:
{
f0100f54:	55                   	push   %ebp
f0100f55:	89 e5                	mov    %esp,%ebp
f0100f57:	57                   	push   %edi
f0100f58:	56                   	push   %esi
f0100f59:	53                   	push   %ebx
f0100f5a:	83 ec 1c             	sub    $0x1c,%esp
f0100f5d:	e8 49 f2 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0100f62:	81 c3 aa 63 01 00    	add    $0x163aa,%ebx
	size_t kernel_end = PADDR(boot_alloc(0)) / PGSIZE;
f0100f68:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f6d:	e8 73 fb ff ff       	call   f0100ae5 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f72:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f77:	76 1a                	jbe    f0100f93 <page_init+0x3f>
	return (physaddr_t)kva - KERNBASE;
f0100f79:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0100f7f:	c1 ee 0c             	shr    $0xc,%esi
f0100f82:	8b bb bc 1f 00 00    	mov    0x1fbc(%ebx),%edi
	for (i = 0; i < npages; i++) {
f0100f88:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f0100f8c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f91:	eb 22                	jmp    f0100fb5 <page_init+0x61>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f93:	50                   	push   %eax
f0100f94:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f0100f9a:	50                   	push   %eax
f0100f9b:	68 0d 01 00 00       	push   $0x10d
f0100fa0:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0100fa6:	50                   	push   %eax
f0100fa7:	e8 49 f1 ff ff       	call   f01000f5 <_panic>
			pages[i].pp_link = NULL;
f0100fac:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	for (i = 0; i < npages; i++) {
f0100fb2:	83 c0 01             	add    $0x1,%eax
f0100fb5:	39 83 b4 1f 00 00    	cmp    %eax,0x1fb4(%ebx)
f0100fbb:	76 34                	jbe    f0100ff1 <page_init+0x9d>
f0100fbd:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		pages[i].pp_ref = 0;
f0100fc4:	89 ca                	mov    %ecx,%edx
f0100fc6:	03 93 ac 1f 00 00    	add    0x1fac(%ebx),%edx
f0100fcc:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		if ((i == 0) || ((i >= IOPHYSMEM / PGSIZE) && i < kernel_end)) {
f0100fd2:	85 c0                	test   %eax,%eax
f0100fd4:	74 d6                	je     f0100fac <page_init+0x58>
f0100fd6:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100fdb:	76 04                	jbe    f0100fe1 <page_init+0x8d>
f0100fdd:	39 f0                	cmp    %esi,%eax
f0100fdf:	72 cb                	jb     f0100fac <page_init+0x58>
			pages[i].pp_link = page_free_list;
f0100fe1:	89 3a                	mov    %edi,(%edx)
			page_free_list = &pages[i];
f0100fe3:	89 cf                	mov    %ecx,%edi
f0100fe5:	03 bb ac 1f 00 00    	add    0x1fac(%ebx),%edi
f0100feb:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
f0100fef:	eb c1                	jmp    f0100fb2 <page_init+0x5e>
f0100ff1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100ff5:	74 06                	je     f0100ffd <page_init+0xa9>
f0100ff7:	89 bb bc 1f 00 00    	mov    %edi,0x1fbc(%ebx)
}
f0100ffd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101000:	5b                   	pop    %ebx
f0101001:	5e                   	pop    %esi
f0101002:	5f                   	pop    %edi
f0101003:	5d                   	pop    %ebp
f0101004:	c3                   	ret    

f0101005 <page_alloc>:
{
f0101005:	55                   	push   %ebp
f0101006:	89 e5                	mov    %esp,%ebp
f0101008:	56                   	push   %esi
f0101009:	53                   	push   %ebx
f010100a:	e8 9c f1 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f010100f:	81 c3 fd 62 01 00    	add    $0x162fd,%ebx
	if (page_free_list == NULL) {
f0101015:	8b b3 bc 1f 00 00    	mov    0x1fbc(%ebx),%esi
f010101b:	85 f6                	test   %esi,%esi
f010101d:	74 14                	je     f0101033 <page_alloc+0x2e>
	page_free_list = page_free_list -> pp_link;
f010101f:	8b 06                	mov    (%esi),%eax
f0101021:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
	nowpage -> pp_link = NULL;
f0101027:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO) {
f010102d:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101031:	75 09                	jne    f010103c <page_alloc+0x37>
}
f0101033:	89 f0                	mov    %esi,%eax
f0101035:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101038:	5b                   	pop    %ebx
f0101039:	5e                   	pop    %esi
f010103a:	5d                   	pop    %ebp
f010103b:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f010103c:	89 f0                	mov    %esi,%eax
f010103e:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101044:	c1 f8 03             	sar    $0x3,%eax
f0101047:	89 c2                	mov    %eax,%edx
f0101049:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010104c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101051:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0101057:	73 1b                	jae    f0101074 <page_alloc+0x6f>
		memset(page2kva(nowpage), 0, PGSIZE);
f0101059:	83 ec 04             	sub    $0x4,%esp
f010105c:	68 00 10 00 00       	push   $0x1000
f0101061:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101063:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101069:	52                   	push   %edx
f010106a:	e8 08 2c 00 00       	call   f0103c77 <memset>
f010106f:	83 c4 10             	add    $0x10,%esp
f0101072:	eb bf                	jmp    f0101033 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101074:	52                   	push   %edx
f0101075:	8d 83 b0 d5 fe ff    	lea    -0x12a50(%ebx),%eax
f010107b:	50                   	push   %eax
f010107c:	6a 52                	push   $0x52
f010107e:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f0101084:	50                   	push   %eax
f0101085:	e8 6b f0 ff ff       	call   f01000f5 <_panic>

f010108a <page_free>:
{
f010108a:	55                   	push   %ebp
f010108b:	89 e5                	mov    %esp,%ebp
f010108d:	53                   	push   %ebx
f010108e:	83 ec 04             	sub    $0x4,%esp
f0101091:	e8 15 f1 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0101096:	81 c3 76 62 01 00    	add    $0x16276,%ebx
f010109c:	8b 45 08             	mov    0x8(%ebp),%eax
	if ((pp->pp_link != NULL) || (pp->pp_ref != 0)) {
f010109f:	83 38 00             	cmpl   $0x0,(%eax)
f01010a2:	75 1a                	jne    f01010be <page_free+0x34>
f01010a4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010a9:	75 13                	jne    f01010be <page_free+0x34>
	pp->pp_link = page_free_list;
f01010ab:	8b 8b bc 1f 00 00    	mov    0x1fbc(%ebx),%ecx
f01010b1:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010b3:	89 83 bc 1f 00 00    	mov    %eax,0x1fbc(%ebx)
}
f01010b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010bc:	c9                   	leave  
f01010bd:	c3                   	ret    
		panic("page_free: pp->pp_link != NULL or pp->pp_ref != 0");
f01010be:	83 ec 04             	sub    $0x4,%esp
f01010c1:	8d 83 e0 d6 fe ff    	lea    -0x12920(%ebx),%eax
f01010c7:	50                   	push   %eax
f01010c8:	68 44 01 00 00       	push   $0x144
f01010cd:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01010d3:	50                   	push   %eax
f01010d4:	e8 1c f0 ff ff       	call   f01000f5 <_panic>

f01010d9 <page_decref>:
{
f01010d9:	55                   	push   %ebp
f01010da:	89 e5                	mov    %esp,%ebp
f01010dc:	83 ec 08             	sub    $0x8,%esp
f01010df:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01010e2:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01010e6:	83 e8 01             	sub    $0x1,%eax
f01010e9:	66 89 42 04          	mov    %ax,0x4(%edx)
f01010ed:	66 85 c0             	test   %ax,%ax
f01010f0:	74 02                	je     f01010f4 <page_decref+0x1b>
}
f01010f2:	c9                   	leave  
f01010f3:	c3                   	ret    
		page_free(pp);
f01010f4:	83 ec 0c             	sub    $0xc,%esp
f01010f7:	52                   	push   %edx
f01010f8:	e8 8d ff ff ff       	call   f010108a <page_free>
f01010fd:	83 c4 10             	add    $0x10,%esp
}
f0101100:	eb f0                	jmp    f01010f2 <page_decref+0x19>

f0101102 <pgdir_walk>:
{
f0101102:	55                   	push   %ebp
f0101103:	89 e5                	mov    %esp,%ebp
f0101105:	57                   	push   %edi
f0101106:	56                   	push   %esi
f0101107:	53                   	push   %ebx
f0101108:	83 ec 0c             	sub    $0xc,%esp
f010110b:	e8 d3 1e 00 00       	call   f0102fe3 <__x86.get_pc_thunk.di>
f0101110:	81 c7 fc 61 01 00    	add    $0x161fc,%edi
f0101116:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pde = pgdir + PDX(va);
f0101119:	89 f3                	mov    %esi,%ebx
f010111b:	c1 eb 16             	shr    $0x16,%ebx
f010111e:	c1 e3 02             	shl    $0x2,%ebx
f0101121:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!((*pde) & PTE_P)) {
f0101124:	f6 03 01             	testb  $0x1,(%ebx)
f0101127:	75 2f                	jne    f0101158 <pgdir_walk+0x56>
		if (create) {
f0101129:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010112d:	74 71                	je     f01011a0 <pgdir_walk+0x9e>
			struct PageInfo *newpage = page_alloc(1);
f010112f:	83 ec 0c             	sub    $0xc,%esp
f0101132:	6a 01                	push   $0x1
f0101134:	e8 cc fe ff ff       	call   f0101005 <page_alloc>
			if (!newpage) {
f0101139:	83 c4 10             	add    $0x10,%esp
f010113c:	85 c0                	test   %eax,%eax
f010113e:	74 3d                	je     f010117d <pgdir_walk+0x7b>
	return (pp - pages) << PGSHIFT;
f0101140:	89 c2                	mov    %eax,%edx
f0101142:	2b 97 ac 1f 00 00    	sub    0x1fac(%edi),%edx
f0101148:	c1 fa 03             	sar    $0x3,%edx
f010114b:	c1 e2 0c             	shl    $0xc,%edx
			*pde = page2pa(newpage) | PTE_P | PTE_W | PTE_U;
f010114e:	83 ca 07             	or     $0x7,%edx
f0101151:	89 13                	mov    %edx,(%ebx)
			++newpage->pp_ref;
f0101153:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde));
f0101158:	8b 03                	mov    (%ebx),%eax
f010115a:	89 c2                	mov    %eax,%edx
f010115c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101162:	c1 e8 0c             	shr    $0xc,%eax
f0101165:	3b 87 b4 1f 00 00    	cmp    0x1fb4(%edi),%eax
f010116b:	73 18                	jae    f0101185 <pgdir_walk+0x83>
	pte += PTX(va);
f010116d:	c1 ee 0a             	shr    $0xa,%esi
f0101170:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0101176:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f010117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101180:	5b                   	pop    %ebx
f0101181:	5e                   	pop    %esi
f0101182:	5f                   	pop    %edi
f0101183:	5d                   	pop    %ebp
f0101184:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101185:	52                   	push   %edx
f0101186:	8d 87 b0 d5 fe ff    	lea    -0x12a50(%edi),%eax
f010118c:	50                   	push   %eax
f010118d:	68 7b 01 00 00       	push   $0x17b
f0101192:	8d 87 cc d2 fe ff    	lea    -0x12d34(%edi),%eax
f0101198:	50                   	push   %eax
f0101199:	89 fb                	mov    %edi,%ebx
f010119b:	e8 55 ef ff ff       	call   f01000f5 <_panic>
			return NULL;
f01011a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a5:	eb d6                	jmp    f010117d <pgdir_walk+0x7b>

f01011a7 <boot_map_region>:
{
f01011a7:	55                   	push   %ebp
f01011a8:	89 e5                	mov    %esp,%ebp
f01011aa:	57                   	push   %edi
f01011ab:	56                   	push   %esi
f01011ac:	53                   	push   %ebx
f01011ad:	83 ec 1c             	sub    $0x1c,%esp
f01011b0:	89 c7                	mov    %eax,%edi
f01011b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01011b5:	89 ce                	mov    %ecx,%esi
	for (offset = 0; offset < size; offset += PGSIZE) {
f01011b7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011bc:	eb 29                	jmp    f01011e7 <boot_map_region+0x40>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + offset), 1);
f01011be:	83 ec 04             	sub    $0x4,%esp
f01011c1:	6a 01                	push   $0x1
f01011c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011c6:	01 d8                	add    %ebx,%eax
f01011c8:	50                   	push   %eax
f01011c9:	57                   	push   %edi
f01011ca:	e8 33 ff ff ff       	call   f0101102 <pgdir_walk>
f01011cf:	89 c2                	mov    %eax,%edx
		*pte = (pa + offset) | perm | PTE_P;
f01011d1:	89 d8                	mov    %ebx,%eax
f01011d3:	03 45 08             	add    0x8(%ebp),%eax
f01011d6:	0b 45 0c             	or     0xc(%ebp),%eax
f01011d9:	83 c8 01             	or     $0x1,%eax
f01011dc:	89 02                	mov    %eax,(%edx)
	for (offset = 0; offset < size; offset += PGSIZE) {
f01011de:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01011e4:	83 c4 10             	add    $0x10,%esp
f01011e7:	39 f3                	cmp    %esi,%ebx
f01011e9:	72 d3                	jb     f01011be <boot_map_region+0x17>
}
f01011eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011ee:	5b                   	pop    %ebx
f01011ef:	5e                   	pop    %esi
f01011f0:	5f                   	pop    %edi
f01011f1:	5d                   	pop    %ebp
f01011f2:	c3                   	ret    

f01011f3 <page_lookup>:
{
f01011f3:	55                   	push   %ebp
f01011f4:	89 e5                	mov    %esp,%ebp
f01011f6:	56                   	push   %esi
f01011f7:	53                   	push   %ebx
f01011f8:	e8 ae ef ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f01011fd:	81 c3 0f 61 01 00    	add    $0x1610f,%ebx
f0101203:	8b 75 10             	mov    0x10(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101206:	83 ec 04             	sub    $0x4,%esp
f0101209:	6a 00                	push   $0x0
f010120b:	ff 75 0c             	push   0xc(%ebp)
f010120e:	ff 75 08             	push   0x8(%ebp)
f0101211:	e8 ec fe ff ff       	call   f0101102 <pgdir_walk>
	if ((!pte) || (!(*pte & PTE_P))) {
f0101216:	83 c4 10             	add    $0x10,%esp
f0101219:	85 c0                	test   %eax,%eax
f010121b:	74 21                	je     f010123e <page_lookup+0x4b>
f010121d:	f6 00 01             	testb  $0x1,(%eax)
f0101220:	74 3b                	je     f010125d <page_lookup+0x6a>
	if (pte_store) {
f0101222:	85 f6                	test   %esi,%esi
f0101224:	74 02                	je     f0101228 <page_lookup+0x35>
		*pte_store = pte;
f0101226:	89 06                	mov    %eax,(%esi)
f0101228:	8b 00                	mov    (%eax),%eax
f010122a:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010122d:	39 83 b4 1f 00 00    	cmp    %eax,0x1fb4(%ebx)
f0101233:	76 10                	jbe    f0101245 <page_lookup+0x52>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101235:	8b 93 ac 1f 00 00    	mov    0x1fac(%ebx),%edx
f010123b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010123e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101241:	5b                   	pop    %ebx
f0101242:	5e                   	pop    %esi
f0101243:	5d                   	pop    %ebp
f0101244:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101245:	83 ec 04             	sub    $0x4,%esp
f0101248:	8d 83 14 d7 fe ff    	lea    -0x128ec(%ebx),%eax
f010124e:	50                   	push   %eax
f010124f:	6a 4b                	push   $0x4b
f0101251:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f0101257:	50                   	push   %eax
f0101258:	e8 98 ee ff ff       	call   f01000f5 <_panic>
		return NULL;
f010125d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101262:	eb da                	jmp    f010123e <page_lookup+0x4b>

f0101264 <page_remove>:
{
f0101264:	55                   	push   %ebp
f0101265:	89 e5                	mov    %esp,%ebp
f0101267:	53                   	push   %ebx
f0101268:	83 ec 18             	sub    $0x18,%esp
f010126b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte = NULL;
f010126e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f0101275:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101278:	50                   	push   %eax
f0101279:	53                   	push   %ebx
f010127a:	ff 75 08             	push   0x8(%ebp)
f010127d:	e8 71 ff ff ff       	call   f01011f3 <page_lookup>
	if (!pp) {
f0101282:	83 c4 10             	add    $0x10,%esp
f0101285:	85 c0                	test   %eax,%eax
f0101287:	74 1c                	je     f01012a5 <page_remove+0x41>
	page_decref(pp);
f0101289:	83 ec 0c             	sub    $0xc,%esp
f010128c:	50                   	push   %eax
f010128d:	e8 47 fe ff ff       	call   f01010d9 <page_decref>
	if (pte) {
f0101292:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101295:	83 c4 10             	add    $0x10,%esp
f0101298:	85 c0                	test   %eax,%eax
f010129a:	74 09                	je     f01012a5 <page_remove+0x41>
		*pte = 0;
f010129c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01012a2:	0f 01 3b             	invlpg (%ebx)
}
f01012a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012a8:	c9                   	leave  
f01012a9:	c3                   	ret    

f01012aa <page_insert>:
{	
f01012aa:	55                   	push   %ebp
f01012ab:	89 e5                	mov    %esp,%ebp
f01012ad:	57                   	push   %edi
f01012ae:	56                   	push   %esi
f01012af:	53                   	push   %ebx
f01012b0:	83 ec 10             	sub    $0x10,%esp
f01012b3:	e8 2b 1d 00 00       	call   f0102fe3 <__x86.get_pc_thunk.di>
f01012b8:	81 c7 54 60 01 00    	add    $0x16054,%edi
f01012be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f01012c1:	6a 01                	push   $0x1
f01012c3:	ff 75 10             	push   0x10(%ebp)
f01012c6:	ff 75 08             	push   0x8(%ebp)
f01012c9:	e8 34 fe ff ff       	call   f0101102 <pgdir_walk>
	if (!pte) {
f01012ce:	83 c4 10             	add    $0x10,%esp
f01012d1:	85 c0                	test   %eax,%eax
f01012d3:	74 40                	je     f0101315 <page_insert+0x6b>
f01012d5:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01012d7:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) {
f01012dc:	f6 00 01             	testb  $0x1,(%eax)
f01012df:	75 21                	jne    f0101302 <page_insert+0x58>
	return (pp - pages) << PGSHIFT;
f01012e1:	2b 9f ac 1f 00 00    	sub    0x1fac(%edi),%ebx
f01012e7:	c1 fb 03             	sar    $0x3,%ebx
f01012ea:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f01012ed:	0b 5d 14             	or     0x14(%ebp),%ebx
f01012f0:	83 cb 01             	or     $0x1,%ebx
f01012f3:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01012f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012fd:	5b                   	pop    %ebx
f01012fe:	5e                   	pop    %esi
f01012ff:	5f                   	pop    %edi
f0101300:	5d                   	pop    %ebp
f0101301:	c3                   	ret    
		page_remove(pgdir, va);
f0101302:	83 ec 08             	sub    $0x8,%esp
f0101305:	ff 75 10             	push   0x10(%ebp)
f0101308:	ff 75 08             	push   0x8(%ebp)
f010130b:	e8 54 ff ff ff       	call   f0101264 <page_remove>
f0101310:	83 c4 10             	add    $0x10,%esp
f0101313:	eb cc                	jmp    f01012e1 <page_insert+0x37>
		return -E_NO_MEM;
f0101315:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010131a:	eb de                	jmp    f01012fa <page_insert+0x50>

f010131c <mem_init>:
{
f010131c:	55                   	push   %ebp
f010131d:	89 e5                	mov    %esp,%ebp
f010131f:	57                   	push   %edi
f0101320:	56                   	push   %esi
f0101321:	53                   	push   %ebx
f0101322:	83 ec 3c             	sub    $0x3c,%esp
f0101325:	e8 15 f4 ff ff       	call   f010073f <__x86.get_pc_thunk.ax>
f010132a:	05 e2 5f 01 00       	add    $0x15fe2,%eax
f010132f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f0101332:	b8 15 00 00 00       	mov    $0x15,%eax
f0101337:	e8 73 f7 ff ff       	call   f0100aaf <nvram_read>
f010133c:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010133e:	b8 17 00 00 00       	mov    $0x17,%eax
f0101343:	e8 67 f7 ff ff       	call   f0100aaf <nvram_read>
f0101348:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010134a:	b8 34 00 00 00       	mov    $0x34,%eax
f010134f:	e8 5b f7 ff ff       	call   f0100aaf <nvram_read>
	if (ext16mem)
f0101354:	c1 e0 06             	shl    $0x6,%eax
f0101357:	0f 84 c0 00 00 00    	je     f010141d <mem_init+0x101>
		totalmem = 16 * 1024 + ext16mem;
f010135d:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101362:	89 c2                	mov    %eax,%edx
f0101364:	c1 ea 02             	shr    $0x2,%edx
f0101367:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010136a:	89 91 b4 1f 00 00    	mov    %edx,0x1fb4(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101370:	89 c2                	mov    %eax,%edx
f0101372:	29 da                	sub    %ebx,%edx
f0101374:	52                   	push   %edx
f0101375:	53                   	push   %ebx
f0101376:	50                   	push   %eax
f0101377:	8d 81 34 d7 fe ff    	lea    -0x128cc(%ecx),%eax
f010137d:	50                   	push   %eax
f010137e:	89 cb                	mov    %ecx,%ebx
f0101380:	e8 f2 1c 00 00       	call   f0103077 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101385:	b8 00 10 00 00       	mov    $0x1000,%eax
f010138a:	e8 56 f7 ff ff       	call   f0100ae5 <boot_alloc>
f010138f:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f0101395:	83 c4 0c             	add    $0xc,%esp
f0101398:	68 00 10 00 00       	push   $0x1000
f010139d:	6a 00                	push   $0x0
f010139f:	50                   	push   %eax
f01013a0:	e8 d2 28 00 00       	call   f0103c77 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013a5:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01013ab:	83 c4 10             	add    $0x10,%esp
f01013ae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013b3:	76 78                	jbe    f010142d <mem_init+0x111>
	return (physaddr_t)kva - KERNBASE;
f01013b5:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013bb:	83 ca 05             	or     $0x5,%edx
f01013be:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01013c4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01013c7:	8b 87 b4 1f 00 00    	mov    0x1fb4(%edi),%eax
f01013cd:	c1 e0 03             	shl    $0x3,%eax
f01013d0:	e8 10 f7 ff ff       	call   f0100ae5 <boot_alloc>
f01013d5:	89 87 ac 1f 00 00    	mov    %eax,0x1fac(%edi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013db:	83 ec 04             	sub    $0x4,%esp
f01013de:	8b 97 b4 1f 00 00    	mov    0x1fb4(%edi),%edx
f01013e4:	c1 e2 03             	shl    $0x3,%edx
f01013e7:	52                   	push   %edx
f01013e8:	6a 00                	push   $0x0
f01013ea:	50                   	push   %eax
f01013eb:	89 fb                	mov    %edi,%ebx
f01013ed:	e8 85 28 00 00       	call   f0103c77 <memset>
	page_init();
f01013f2:	e8 5d fb ff ff       	call   f0100f54 <page_init>
	check_page_free_list(1);
f01013f7:	b8 01 00 00 00       	mov    $0x1,%eax
f01013fc:	e8 e7 f7 ff ff       	call   f0100be8 <check_page_free_list>
	if (!pages)
f0101401:	83 c4 10             	add    $0x10,%esp
f0101404:	83 bf ac 1f 00 00 00 	cmpl   $0x0,0x1fac(%edi)
f010140b:	74 3c                	je     f0101449 <mem_init+0x12d>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010140d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101410:	8b 80 bc 1f 00 00    	mov    0x1fbc(%eax),%eax
f0101416:	be 00 00 00 00       	mov    $0x0,%esi
f010141b:	eb 4f                	jmp    f010146c <mem_init+0x150>
		totalmem = 1 * 1024 + extmem;
f010141d:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101423:	85 f6                	test   %esi,%esi
f0101425:	0f 44 c3             	cmove  %ebx,%eax
f0101428:	e9 35 ff ff ff       	jmp    f0101362 <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010142d:	50                   	push   %eax
f010142e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101431:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f0101437:	50                   	push   %eax
f0101438:	68 97 00 00 00       	push   $0x97
f010143d:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101443:	50                   	push   %eax
f0101444:	e8 ac ec ff ff       	call   f01000f5 <_panic>
		panic("'pages' is a null pointer!");
f0101449:	83 ec 04             	sub    $0x4,%esp
f010144c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010144f:	8d 83 82 d3 fe ff    	lea    -0x12c7e(%ebx),%eax
f0101455:	50                   	push   %eax
f0101456:	68 4f 02 00 00       	push   $0x24f
f010145b:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101461:	50                   	push   %eax
f0101462:	e8 8e ec ff ff       	call   f01000f5 <_panic>
		++nfree;
f0101467:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010146a:	8b 00                	mov    (%eax),%eax
f010146c:	85 c0                	test   %eax,%eax
f010146e:	75 f7                	jne    f0101467 <mem_init+0x14b>
	assert((pp0 = page_alloc(0)));
f0101470:	83 ec 0c             	sub    $0xc,%esp
f0101473:	6a 00                	push   $0x0
f0101475:	e8 8b fb ff ff       	call   f0101005 <page_alloc>
f010147a:	89 c3                	mov    %eax,%ebx
f010147c:	83 c4 10             	add    $0x10,%esp
f010147f:	85 c0                	test   %eax,%eax
f0101481:	0f 84 3a 02 00 00    	je     f01016c1 <mem_init+0x3a5>
	assert((pp1 = page_alloc(0)));
f0101487:	83 ec 0c             	sub    $0xc,%esp
f010148a:	6a 00                	push   $0x0
f010148c:	e8 74 fb ff ff       	call   f0101005 <page_alloc>
f0101491:	89 c7                	mov    %eax,%edi
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	85 c0                	test   %eax,%eax
f0101498:	0f 84 45 02 00 00    	je     f01016e3 <mem_init+0x3c7>
	assert((pp2 = page_alloc(0)));
f010149e:	83 ec 0c             	sub    $0xc,%esp
f01014a1:	6a 00                	push   $0x0
f01014a3:	e8 5d fb ff ff       	call   f0101005 <page_alloc>
f01014a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01014ab:	83 c4 10             	add    $0x10,%esp
f01014ae:	85 c0                	test   %eax,%eax
f01014b0:	0f 84 4f 02 00 00    	je     f0101705 <mem_init+0x3e9>
	assert(pp1 && pp1 != pp0);
f01014b6:	39 fb                	cmp    %edi,%ebx
f01014b8:	0f 84 69 02 00 00    	je     f0101727 <mem_init+0x40b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014be:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014c1:	39 c3                	cmp    %eax,%ebx
f01014c3:	0f 84 80 02 00 00    	je     f0101749 <mem_init+0x42d>
f01014c9:	39 c7                	cmp    %eax,%edi
f01014cb:	0f 84 78 02 00 00    	je     f0101749 <mem_init+0x42d>
	return (pp - pages) << PGSHIFT;
f01014d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014d4:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014da:	8b 90 b4 1f 00 00    	mov    0x1fb4(%eax),%edx
f01014e0:	c1 e2 0c             	shl    $0xc,%edx
f01014e3:	89 d8                	mov    %ebx,%eax
f01014e5:	29 c8                	sub    %ecx,%eax
f01014e7:	c1 f8 03             	sar    $0x3,%eax
f01014ea:	c1 e0 0c             	shl    $0xc,%eax
f01014ed:	39 d0                	cmp    %edx,%eax
f01014ef:	0f 83 76 02 00 00    	jae    f010176b <mem_init+0x44f>
f01014f5:	89 f8                	mov    %edi,%eax
f01014f7:	29 c8                	sub    %ecx,%eax
f01014f9:	c1 f8 03             	sar    $0x3,%eax
f01014fc:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014ff:	39 c2                	cmp    %eax,%edx
f0101501:	0f 86 86 02 00 00    	jbe    f010178d <mem_init+0x471>
f0101507:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010150a:	29 c8                	sub    %ecx,%eax
f010150c:	c1 f8 03             	sar    $0x3,%eax
f010150f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101512:	39 c2                	cmp    %eax,%edx
f0101514:	0f 86 95 02 00 00    	jbe    f01017af <mem_init+0x493>
	fl = page_free_list;
f010151a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010151d:	8b 88 bc 1f 00 00    	mov    0x1fbc(%eax),%ecx
f0101523:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101526:	c7 80 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%eax)
f010152d:	00 00 00 
	assert(!page_alloc(0));
f0101530:	83 ec 0c             	sub    $0xc,%esp
f0101533:	6a 00                	push   $0x0
f0101535:	e8 cb fa ff ff       	call   f0101005 <page_alloc>
f010153a:	83 c4 10             	add    $0x10,%esp
f010153d:	85 c0                	test   %eax,%eax
f010153f:	0f 85 8c 02 00 00    	jne    f01017d1 <mem_init+0x4b5>
	page_free(pp0);
f0101545:	83 ec 0c             	sub    $0xc,%esp
f0101548:	53                   	push   %ebx
f0101549:	e8 3c fb ff ff       	call   f010108a <page_free>
	page_free(pp1);
f010154e:	89 3c 24             	mov    %edi,(%esp)
f0101551:	e8 34 fb ff ff       	call   f010108a <page_free>
	page_free(pp2);
f0101556:	83 c4 04             	add    $0x4,%esp
f0101559:	ff 75 d0             	push   -0x30(%ebp)
f010155c:	e8 29 fb ff ff       	call   f010108a <page_free>
	assert((pp0 = page_alloc(0)));
f0101561:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101568:	e8 98 fa ff ff       	call   f0101005 <page_alloc>
f010156d:	89 c7                	mov    %eax,%edi
f010156f:	83 c4 10             	add    $0x10,%esp
f0101572:	85 c0                	test   %eax,%eax
f0101574:	0f 84 79 02 00 00    	je     f01017f3 <mem_init+0x4d7>
	assert((pp1 = page_alloc(0)));
f010157a:	83 ec 0c             	sub    $0xc,%esp
f010157d:	6a 00                	push   $0x0
f010157f:	e8 81 fa ff ff       	call   f0101005 <page_alloc>
f0101584:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101587:	83 c4 10             	add    $0x10,%esp
f010158a:	85 c0                	test   %eax,%eax
f010158c:	0f 84 83 02 00 00    	je     f0101815 <mem_init+0x4f9>
	assert((pp2 = page_alloc(0)));
f0101592:	83 ec 0c             	sub    $0xc,%esp
f0101595:	6a 00                	push   $0x0
f0101597:	e8 69 fa ff ff       	call   f0101005 <page_alloc>
f010159c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010159f:	83 c4 10             	add    $0x10,%esp
f01015a2:	85 c0                	test   %eax,%eax
f01015a4:	0f 84 8d 02 00 00    	je     f0101837 <mem_init+0x51b>
	assert(pp1 && pp1 != pp0);
f01015aa:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f01015ad:	0f 84 a6 02 00 00    	je     f0101859 <mem_init+0x53d>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01015b6:	39 c7                	cmp    %eax,%edi
f01015b8:	0f 84 bd 02 00 00    	je     f010187b <mem_init+0x55f>
f01015be:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01015c1:	0f 84 b4 02 00 00    	je     f010187b <mem_init+0x55f>
	assert(!page_alloc(0));
f01015c7:	83 ec 0c             	sub    $0xc,%esp
f01015ca:	6a 00                	push   $0x0
f01015cc:	e8 34 fa ff ff       	call   f0101005 <page_alloc>
f01015d1:	83 c4 10             	add    $0x10,%esp
f01015d4:	85 c0                	test   %eax,%eax
f01015d6:	0f 85 c1 02 00 00    	jne    f010189d <mem_init+0x581>
f01015dc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01015df:	89 f8                	mov    %edi,%eax
f01015e1:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f01015e7:	c1 f8 03             	sar    $0x3,%eax
f01015ea:	89 c2                	mov    %eax,%edx
f01015ec:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015ef:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015f4:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f01015fa:	0f 83 bf 02 00 00    	jae    f01018bf <mem_init+0x5a3>
	memset(page2kva(pp0), 1, PGSIZE);
f0101600:	83 ec 04             	sub    $0x4,%esp
f0101603:	68 00 10 00 00       	push   $0x1000
f0101608:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010160a:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101610:	52                   	push   %edx
f0101611:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101614:	e8 5e 26 00 00       	call   f0103c77 <memset>
	page_free(pp0);
f0101619:	89 3c 24             	mov    %edi,(%esp)
f010161c:	e8 69 fa ff ff       	call   f010108a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101621:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101628:	e8 d8 f9 ff ff       	call   f0101005 <page_alloc>
f010162d:	83 c4 10             	add    $0x10,%esp
f0101630:	85 c0                	test   %eax,%eax
f0101632:	0f 84 9f 02 00 00    	je     f01018d7 <mem_init+0x5bb>
	assert(pp && pp0 == pp);
f0101638:	39 c7                	cmp    %eax,%edi
f010163a:	0f 85 b9 02 00 00    	jne    f01018f9 <mem_init+0x5dd>
	return (pp - pages) << PGSHIFT;
f0101640:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101643:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0101649:	c1 f8 03             	sar    $0x3,%eax
f010164c:	89 c2                	mov    %eax,%edx
f010164e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101651:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101656:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f010165c:	0f 83 b9 02 00 00    	jae    f010191b <mem_init+0x5ff>
	return (void *)(pa + KERNBASE);
f0101662:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101668:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010166e:	80 38 00             	cmpb   $0x0,(%eax)
f0101671:	0f 85 bc 02 00 00    	jne    f0101933 <mem_init+0x617>
	for (i = 0; i < PGSIZE; i++)
f0101677:	83 c0 01             	add    $0x1,%eax
f010167a:	39 c2                	cmp    %eax,%edx
f010167c:	75 f0                	jne    f010166e <mem_init+0x352>
	page_free_list = fl;
f010167e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101681:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101684:	89 8b bc 1f 00 00    	mov    %ecx,0x1fbc(%ebx)
	page_free(pp0);
f010168a:	83 ec 0c             	sub    $0xc,%esp
f010168d:	57                   	push   %edi
f010168e:	e8 f7 f9 ff ff       	call   f010108a <page_free>
	page_free(pp1);
f0101693:	83 c4 04             	add    $0x4,%esp
f0101696:	ff 75 d0             	push   -0x30(%ebp)
f0101699:	e8 ec f9 ff ff       	call   f010108a <page_free>
	page_free(pp2);
f010169e:	83 c4 04             	add    $0x4,%esp
f01016a1:	ff 75 cc             	push   -0x34(%ebp)
f01016a4:	e8 e1 f9 ff ff       	call   f010108a <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016a9:	8b 83 bc 1f 00 00    	mov    0x1fbc(%ebx),%eax
f01016af:	83 c4 10             	add    $0x10,%esp
f01016b2:	85 c0                	test   %eax,%eax
f01016b4:	0f 84 9b 02 00 00    	je     f0101955 <mem_init+0x639>
		--nfree;
f01016ba:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016bd:	8b 00                	mov    (%eax),%eax
f01016bf:	eb f1                	jmp    f01016b2 <mem_init+0x396>
	assert((pp0 = page_alloc(0)));
f01016c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016c4:	8d 83 9d d3 fe ff    	lea    -0x12c63(%ebx),%eax
f01016ca:	50                   	push   %eax
f01016cb:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01016d1:	50                   	push   %eax
f01016d2:	68 57 02 00 00       	push   $0x257
f01016d7:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01016dd:	50                   	push   %eax
f01016de:	e8 12 ea ff ff       	call   f01000f5 <_panic>
	assert((pp1 = page_alloc(0)));
f01016e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016e6:	8d 83 b3 d3 fe ff    	lea    -0x12c4d(%ebx),%eax
f01016ec:	50                   	push   %eax
f01016ed:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01016f3:	50                   	push   %eax
f01016f4:	68 58 02 00 00       	push   $0x258
f01016f9:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01016ff:	50                   	push   %eax
f0101700:	e8 f0 e9 ff ff       	call   f01000f5 <_panic>
	assert((pp2 = page_alloc(0)));
f0101705:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101708:	8d 83 c9 d3 fe ff    	lea    -0x12c37(%ebx),%eax
f010170e:	50                   	push   %eax
f010170f:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101715:	50                   	push   %eax
f0101716:	68 59 02 00 00       	push   $0x259
f010171b:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101721:	50                   	push   %eax
f0101722:	e8 ce e9 ff ff       	call   f01000f5 <_panic>
	assert(pp1 && pp1 != pp0);
f0101727:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010172a:	8d 83 df d3 fe ff    	lea    -0x12c21(%ebx),%eax
f0101730:	50                   	push   %eax
f0101731:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101737:	50                   	push   %eax
f0101738:	68 5c 02 00 00       	push   $0x25c
f010173d:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101743:	50                   	push   %eax
f0101744:	e8 ac e9 ff ff       	call   f01000f5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101749:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010174c:	8d 83 70 d7 fe ff    	lea    -0x12890(%ebx),%eax
f0101752:	50                   	push   %eax
f0101753:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101759:	50                   	push   %eax
f010175a:	68 5d 02 00 00       	push   $0x25d
f010175f:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101765:	50                   	push   %eax
f0101766:	e8 8a e9 ff ff       	call   f01000f5 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f010176b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010176e:	8d 83 f1 d3 fe ff    	lea    -0x12c0f(%ebx),%eax
f0101774:	50                   	push   %eax
f0101775:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010177b:	50                   	push   %eax
f010177c:	68 5e 02 00 00       	push   $0x25e
f0101781:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101787:	50                   	push   %eax
f0101788:	e8 68 e9 ff ff       	call   f01000f5 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010178d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101790:	8d 83 0e d4 fe ff    	lea    -0x12bf2(%ebx),%eax
f0101796:	50                   	push   %eax
f0101797:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010179d:	50                   	push   %eax
f010179e:	68 5f 02 00 00       	push   $0x25f
f01017a3:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01017a9:	50                   	push   %eax
f01017aa:	e8 46 e9 ff ff       	call   f01000f5 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017b2:	8d 83 2b d4 fe ff    	lea    -0x12bd5(%ebx),%eax
f01017b8:	50                   	push   %eax
f01017b9:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01017bf:	50                   	push   %eax
f01017c0:	68 60 02 00 00       	push   $0x260
f01017c5:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01017cb:	50                   	push   %eax
f01017cc:	e8 24 e9 ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f01017d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017d4:	8d 83 48 d4 fe ff    	lea    -0x12bb8(%ebx),%eax
f01017da:	50                   	push   %eax
f01017db:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01017e1:	50                   	push   %eax
f01017e2:	68 67 02 00 00       	push   $0x267
f01017e7:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01017ed:	50                   	push   %eax
f01017ee:	e8 02 e9 ff ff       	call   f01000f5 <_panic>
	assert((pp0 = page_alloc(0)));
f01017f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017f6:	8d 83 9d d3 fe ff    	lea    -0x12c63(%ebx),%eax
f01017fc:	50                   	push   %eax
f01017fd:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101803:	50                   	push   %eax
f0101804:	68 6e 02 00 00       	push   $0x26e
f0101809:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010180f:	50                   	push   %eax
f0101810:	e8 e0 e8 ff ff       	call   f01000f5 <_panic>
	assert((pp1 = page_alloc(0)));
f0101815:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101818:	8d 83 b3 d3 fe ff    	lea    -0x12c4d(%ebx),%eax
f010181e:	50                   	push   %eax
f010181f:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101825:	50                   	push   %eax
f0101826:	68 6f 02 00 00       	push   $0x26f
f010182b:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101831:	50                   	push   %eax
f0101832:	e8 be e8 ff ff       	call   f01000f5 <_panic>
	assert((pp2 = page_alloc(0)));
f0101837:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010183a:	8d 83 c9 d3 fe ff    	lea    -0x12c37(%ebx),%eax
f0101840:	50                   	push   %eax
f0101841:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101847:	50                   	push   %eax
f0101848:	68 70 02 00 00       	push   $0x270
f010184d:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101853:	50                   	push   %eax
f0101854:	e8 9c e8 ff ff       	call   f01000f5 <_panic>
	assert(pp1 && pp1 != pp0);
f0101859:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010185c:	8d 83 df d3 fe ff    	lea    -0x12c21(%ebx),%eax
f0101862:	50                   	push   %eax
f0101863:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101869:	50                   	push   %eax
f010186a:	68 72 02 00 00       	push   $0x272
f010186f:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101875:	50                   	push   %eax
f0101876:	e8 7a e8 ff ff       	call   f01000f5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010187b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010187e:	8d 83 70 d7 fe ff    	lea    -0x12890(%ebx),%eax
f0101884:	50                   	push   %eax
f0101885:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010188b:	50                   	push   %eax
f010188c:	68 73 02 00 00       	push   $0x273
f0101891:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101897:	50                   	push   %eax
f0101898:	e8 58 e8 ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f010189d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018a0:	8d 83 48 d4 fe ff    	lea    -0x12bb8(%ebx),%eax
f01018a6:	50                   	push   %eax
f01018a7:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01018ad:	50                   	push   %eax
f01018ae:	68 74 02 00 00       	push   $0x274
f01018b3:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01018b9:	50                   	push   %eax
f01018ba:	e8 36 e8 ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018bf:	52                   	push   %edx
f01018c0:	89 cb                	mov    %ecx,%ebx
f01018c2:	8d 81 b0 d5 fe ff    	lea    -0x12a50(%ecx),%eax
f01018c8:	50                   	push   %eax
f01018c9:	6a 52                	push   $0x52
f01018cb:	8d 81 d8 d2 fe ff    	lea    -0x12d28(%ecx),%eax
f01018d1:	50                   	push   %eax
f01018d2:	e8 1e e8 ff ff       	call   f01000f5 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018da:	8d 83 57 d4 fe ff    	lea    -0x12ba9(%ebx),%eax
f01018e0:	50                   	push   %eax
f01018e1:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01018e7:	50                   	push   %eax
f01018e8:	68 79 02 00 00       	push   $0x279
f01018ed:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01018f3:	50                   	push   %eax
f01018f4:	e8 fc e7 ff ff       	call   f01000f5 <_panic>
	assert(pp && pp0 == pp);
f01018f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018fc:	8d 83 75 d4 fe ff    	lea    -0x12b8b(%ebx),%eax
f0101902:	50                   	push   %eax
f0101903:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101909:	50                   	push   %eax
f010190a:	68 7a 02 00 00       	push   $0x27a
f010190f:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0101915:	50                   	push   %eax
f0101916:	e8 da e7 ff ff       	call   f01000f5 <_panic>
f010191b:	52                   	push   %edx
f010191c:	89 cb                	mov    %ecx,%ebx
f010191e:	8d 81 b0 d5 fe ff    	lea    -0x12a50(%ecx),%eax
f0101924:	50                   	push   %eax
f0101925:	6a 52                	push   $0x52
f0101927:	8d 81 d8 d2 fe ff    	lea    -0x12d28(%ecx),%eax
f010192d:	50                   	push   %eax
f010192e:	e8 c2 e7 ff ff       	call   f01000f5 <_panic>
		assert(c[i] == 0);
f0101933:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101936:	8d 83 85 d4 fe ff    	lea    -0x12b7b(%ebx),%eax
f010193c:	50                   	push   %eax
f010193d:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0101943:	50                   	push   %eax
f0101944:	68 7d 02 00 00       	push   $0x27d
f0101949:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010194f:	50                   	push   %eax
f0101950:	e8 a0 e7 ff ff       	call   f01000f5 <_panic>
	assert(nfree == 0);
f0101955:	85 f6                	test   %esi,%esi
f0101957:	0f 85 2b 08 00 00    	jne    f0102188 <mem_init+0xe6c>
	cprintf("check_page_alloc() succeeded!\n");
f010195d:	83 ec 0c             	sub    $0xc,%esp
f0101960:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101963:	8d 83 90 d7 fe ff    	lea    -0x12870(%ebx),%eax
f0101969:	50                   	push   %eax
f010196a:	e8 08 17 00 00       	call   f0103077 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010196f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101976:	e8 8a f6 ff ff       	call   f0101005 <page_alloc>
f010197b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010197e:	83 c4 10             	add    $0x10,%esp
f0101981:	85 c0                	test   %eax,%eax
f0101983:	0f 84 21 08 00 00    	je     f01021aa <mem_init+0xe8e>
	assert((pp1 = page_alloc(0)));
f0101989:	83 ec 0c             	sub    $0xc,%esp
f010198c:	6a 00                	push   $0x0
f010198e:	e8 72 f6 ff ff       	call   f0101005 <page_alloc>
f0101993:	89 c7                	mov    %eax,%edi
f0101995:	83 c4 10             	add    $0x10,%esp
f0101998:	85 c0                	test   %eax,%eax
f010199a:	0f 84 2c 08 00 00    	je     f01021cc <mem_init+0xeb0>
	assert((pp2 = page_alloc(0)));
f01019a0:	83 ec 0c             	sub    $0xc,%esp
f01019a3:	6a 00                	push   $0x0
f01019a5:	e8 5b f6 ff ff       	call   f0101005 <page_alloc>
f01019aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01019ad:	83 c4 10             	add    $0x10,%esp
f01019b0:	85 c0                	test   %eax,%eax
f01019b2:	0f 84 36 08 00 00    	je     f01021ee <mem_init+0xed2>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019b8:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01019bb:	0f 84 4f 08 00 00    	je     f0102210 <mem_init+0xef4>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01019c4:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01019c7:	0f 84 65 08 00 00    	je     f0102232 <mem_init+0xf16>
f01019cd:	39 c7                	cmp    %eax,%edi
f01019cf:	0f 84 5d 08 00 00    	je     f0102232 <mem_init+0xf16>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019d5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d8:	8b 88 bc 1f 00 00    	mov    0x1fbc(%eax),%ecx
f01019de:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01019e1:	c7 80 bc 1f 00 00 00 	movl   $0x0,0x1fbc(%eax)
f01019e8:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01019eb:	83 ec 0c             	sub    $0xc,%esp
f01019ee:	6a 00                	push   $0x0
f01019f0:	e8 10 f6 ff ff       	call   f0101005 <page_alloc>
f01019f5:	83 c4 10             	add    $0x10,%esp
f01019f8:	85 c0                	test   %eax,%eax
f01019fa:	0f 85 54 08 00 00    	jne    f0102254 <mem_init+0xf38>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a00:	83 ec 04             	sub    $0x4,%esp
f0101a03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a06:	50                   	push   %eax
f0101a07:	6a 00                	push   $0x0
f0101a09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a0c:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101a12:	e8 dc f7 ff ff       	call   f01011f3 <page_lookup>
f0101a17:	83 c4 10             	add    $0x10,%esp
f0101a1a:	85 c0                	test   %eax,%eax
f0101a1c:	0f 85 54 08 00 00    	jne    f0102276 <mem_init+0xf5a>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a22:	6a 02                	push   $0x2
f0101a24:	6a 00                	push   $0x0
f0101a26:	57                   	push   %edi
f0101a27:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a2a:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101a30:	e8 75 f8 ff ff       	call   f01012aa <page_insert>
f0101a35:	83 c4 10             	add    $0x10,%esp
f0101a38:	85 c0                	test   %eax,%eax
f0101a3a:	0f 89 58 08 00 00    	jns    f0102298 <mem_init+0xf7c>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a40:	83 ec 0c             	sub    $0xc,%esp
f0101a43:	ff 75 cc             	push   -0x34(%ebp)
f0101a46:	e8 3f f6 ff ff       	call   f010108a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a4b:	6a 02                	push   $0x2
f0101a4d:	6a 00                	push   $0x0
f0101a4f:	57                   	push   %edi
f0101a50:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a53:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101a59:	e8 4c f8 ff ff       	call   f01012aa <page_insert>
f0101a5e:	83 c4 20             	add    $0x20,%esp
f0101a61:	85 c0                	test   %eax,%eax
f0101a63:	0f 85 51 08 00 00    	jne    f01022ba <mem_init+0xf9e>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a6c:	8b 98 b0 1f 00 00    	mov    0x1fb0(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101a72:	8b b0 ac 1f 00 00    	mov    0x1fac(%eax),%esi
f0101a78:	8b 13                	mov    (%ebx),%edx
f0101a7a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a80:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a83:	29 f0                	sub    %esi,%eax
f0101a85:	c1 f8 03             	sar    $0x3,%eax
f0101a88:	c1 e0 0c             	shl    $0xc,%eax
f0101a8b:	39 c2                	cmp    %eax,%edx
f0101a8d:	0f 85 49 08 00 00    	jne    f01022dc <mem_init+0xfc0>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a93:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a98:	89 d8                	mov    %ebx,%eax
f0101a9a:	e8 cd f0 ff ff       	call   f0100b6c <check_va2pa>
f0101a9f:	89 c2                	mov    %eax,%edx
f0101aa1:	89 f8                	mov    %edi,%eax
f0101aa3:	29 f0                	sub    %esi,%eax
f0101aa5:	c1 f8 03             	sar    $0x3,%eax
f0101aa8:	c1 e0 0c             	shl    $0xc,%eax
f0101aab:	39 c2                	cmp    %eax,%edx
f0101aad:	0f 85 4b 08 00 00    	jne    f01022fe <mem_init+0xfe2>
	assert(pp1->pp_ref == 1);
f0101ab3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101ab8:	0f 85 62 08 00 00    	jne    f0102320 <mem_init+0x1004>
	assert(pp0->pp_ref == 1);
f0101abe:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ac1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ac6:	0f 85 76 08 00 00    	jne    f0102342 <mem_init+0x1026>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101acc:	6a 02                	push   $0x2
f0101ace:	68 00 10 00 00       	push   $0x1000
f0101ad3:	ff 75 d0             	push   -0x30(%ebp)
f0101ad6:	53                   	push   %ebx
f0101ad7:	e8 ce f7 ff ff       	call   f01012aa <page_insert>
f0101adc:	83 c4 10             	add    $0x10,%esp
f0101adf:	85 c0                	test   %eax,%eax
f0101ae1:	0f 85 7d 08 00 00    	jne    f0102364 <mem_init+0x1048>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101aef:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101af5:	e8 72 f0 ff ff       	call   f0100b6c <check_va2pa>
f0101afa:	89 c2                	mov    %eax,%edx
f0101afc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101aff:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101b05:	c1 f8 03             	sar    $0x3,%eax
f0101b08:	c1 e0 0c             	shl    $0xc,%eax
f0101b0b:	39 c2                	cmp    %eax,%edx
f0101b0d:	0f 85 73 08 00 00    	jne    f0102386 <mem_init+0x106a>
	assert(pp2->pp_ref == 1);
f0101b13:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b16:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b1b:	0f 85 87 08 00 00    	jne    f01023a8 <mem_init+0x108c>

	// should be no free memory
	assert(!page_alloc(0));
f0101b21:	83 ec 0c             	sub    $0xc,%esp
f0101b24:	6a 00                	push   $0x0
f0101b26:	e8 da f4 ff ff       	call   f0101005 <page_alloc>
f0101b2b:	83 c4 10             	add    $0x10,%esp
f0101b2e:	85 c0                	test   %eax,%eax
f0101b30:	0f 85 94 08 00 00    	jne    f01023ca <mem_init+0x10ae>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b36:	6a 02                	push   $0x2
f0101b38:	68 00 10 00 00       	push   $0x1000
f0101b3d:	ff 75 d0             	push   -0x30(%ebp)
f0101b40:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b43:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101b49:	e8 5c f7 ff ff       	call   f01012aa <page_insert>
f0101b4e:	83 c4 10             	add    $0x10,%esp
f0101b51:	85 c0                	test   %eax,%eax
f0101b53:	0f 85 93 08 00 00    	jne    f01023ec <mem_init+0x10d0>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b59:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b5e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b61:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101b67:	e8 00 f0 ff ff       	call   f0100b6c <check_va2pa>
f0101b6c:	89 c2                	mov    %eax,%edx
f0101b6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b71:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101b77:	c1 f8 03             	sar    $0x3,%eax
f0101b7a:	c1 e0 0c             	shl    $0xc,%eax
f0101b7d:	39 c2                	cmp    %eax,%edx
f0101b7f:	0f 85 89 08 00 00    	jne    f010240e <mem_init+0x10f2>
	assert(pp2->pp_ref == 1);
f0101b85:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b88:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b8d:	0f 85 9d 08 00 00    	jne    f0102430 <mem_init+0x1114>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b93:	83 ec 0c             	sub    $0xc,%esp
f0101b96:	6a 00                	push   $0x0
f0101b98:	e8 68 f4 ff ff       	call   f0101005 <page_alloc>
f0101b9d:	83 c4 10             	add    $0x10,%esp
f0101ba0:	85 c0                	test   %eax,%eax
f0101ba2:	0f 85 aa 08 00 00    	jne    f0102452 <mem_init+0x1136>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ba8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bab:	8b 91 b0 1f 00 00    	mov    0x1fb0(%ecx),%edx
f0101bb1:	8b 02                	mov    (%edx),%eax
f0101bb3:	89 c3                	mov    %eax,%ebx
f0101bb5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101bbb:	c1 e8 0c             	shr    $0xc,%eax
f0101bbe:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0101bc4:	0f 83 aa 08 00 00    	jae    f0102474 <mem_init+0x1158>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bca:	83 ec 04             	sub    $0x4,%esp
f0101bcd:	6a 00                	push   $0x0
f0101bcf:	68 00 10 00 00       	push   $0x1000
f0101bd4:	52                   	push   %edx
f0101bd5:	e8 28 f5 ff ff       	call   f0101102 <pgdir_walk>
f0101bda:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101be0:	83 c4 10             	add    $0x10,%esp
f0101be3:	39 d8                	cmp    %ebx,%eax
f0101be5:	0f 85 a4 08 00 00    	jne    f010248f <mem_init+0x1173>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101beb:	6a 06                	push   $0x6
f0101bed:	68 00 10 00 00       	push   $0x1000
f0101bf2:	ff 75 d0             	push   -0x30(%ebp)
f0101bf5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bf8:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101bfe:	e8 a7 f6 ff ff       	call   f01012aa <page_insert>
f0101c03:	83 c4 10             	add    $0x10,%esp
f0101c06:	85 c0                	test   %eax,%eax
f0101c08:	0f 85 a3 08 00 00    	jne    f01024b1 <mem_init+0x1195>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c0e:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101c11:	8b 9e b0 1f 00 00    	mov    0x1fb0(%esi),%ebx
f0101c17:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c1c:	89 d8                	mov    %ebx,%eax
f0101c1e:	e8 49 ef ff ff       	call   f0100b6c <check_va2pa>
f0101c23:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101c25:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c28:	2b 86 ac 1f 00 00    	sub    0x1fac(%esi),%eax
f0101c2e:	c1 f8 03             	sar    $0x3,%eax
f0101c31:	c1 e0 0c             	shl    $0xc,%eax
f0101c34:	39 c2                	cmp    %eax,%edx
f0101c36:	0f 85 97 08 00 00    	jne    f01024d3 <mem_init+0x11b7>
	assert(pp2->pp_ref == 1);
f0101c3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c3f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c44:	0f 85 ab 08 00 00    	jne    f01024f5 <mem_init+0x11d9>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c4a:	83 ec 04             	sub    $0x4,%esp
f0101c4d:	6a 00                	push   $0x0
f0101c4f:	68 00 10 00 00       	push   $0x1000
f0101c54:	53                   	push   %ebx
f0101c55:	e8 a8 f4 ff ff       	call   f0101102 <pgdir_walk>
f0101c5a:	83 c4 10             	add    $0x10,%esp
f0101c5d:	f6 00 04             	testb  $0x4,(%eax)
f0101c60:	0f 84 b1 08 00 00    	je     f0102517 <mem_init+0x11fb>
	assert(kern_pgdir[0] & PTE_U);
f0101c66:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c69:	8b 80 b0 1f 00 00    	mov    0x1fb0(%eax),%eax
f0101c6f:	f6 00 04             	testb  $0x4,(%eax)
f0101c72:	0f 84 c1 08 00 00    	je     f0102539 <mem_init+0x121d>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c78:	6a 02                	push   $0x2
f0101c7a:	68 00 10 00 00       	push   $0x1000
f0101c7f:	ff 75 d0             	push   -0x30(%ebp)
f0101c82:	50                   	push   %eax
f0101c83:	e8 22 f6 ff ff       	call   f01012aa <page_insert>
f0101c88:	83 c4 10             	add    $0x10,%esp
f0101c8b:	85 c0                	test   %eax,%eax
f0101c8d:	0f 85 c8 08 00 00    	jne    f010255b <mem_init+0x123f>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c93:	83 ec 04             	sub    $0x4,%esp
f0101c96:	6a 00                	push   $0x0
f0101c98:	68 00 10 00 00       	push   $0x1000
f0101c9d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ca0:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101ca6:	e8 57 f4 ff ff       	call   f0101102 <pgdir_walk>
f0101cab:	83 c4 10             	add    $0x10,%esp
f0101cae:	f6 00 02             	testb  $0x2,(%eax)
f0101cb1:	0f 84 c6 08 00 00    	je     f010257d <mem_init+0x1261>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101cb7:	83 ec 04             	sub    $0x4,%esp
f0101cba:	6a 00                	push   $0x0
f0101cbc:	68 00 10 00 00       	push   $0x1000
f0101cc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cc4:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101cca:	e8 33 f4 ff ff       	call   f0101102 <pgdir_walk>
f0101ccf:	83 c4 10             	add    $0x10,%esp
f0101cd2:	f6 00 04             	testb  $0x4,(%eax)
f0101cd5:	0f 85 c4 08 00 00    	jne    f010259f <mem_init+0x1283>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101cdb:	6a 02                	push   $0x2
f0101cdd:	68 00 00 40 00       	push   $0x400000
f0101ce2:	ff 75 cc             	push   -0x34(%ebp)
f0101ce5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ce8:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101cee:	e8 b7 f5 ff ff       	call   f01012aa <page_insert>
f0101cf3:	83 c4 10             	add    $0x10,%esp
f0101cf6:	85 c0                	test   %eax,%eax
f0101cf8:	0f 89 c3 08 00 00    	jns    f01025c1 <mem_init+0x12a5>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101cfe:	6a 02                	push   $0x2
f0101d00:	68 00 10 00 00       	push   $0x1000
f0101d05:	57                   	push   %edi
f0101d06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d09:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101d0f:	e8 96 f5 ff ff       	call   f01012aa <page_insert>
f0101d14:	83 c4 10             	add    $0x10,%esp
f0101d17:	85 c0                	test   %eax,%eax
f0101d19:	0f 85 c4 08 00 00    	jne    f01025e3 <mem_init+0x12c7>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d1f:	83 ec 04             	sub    $0x4,%esp
f0101d22:	6a 00                	push   $0x0
f0101d24:	68 00 10 00 00       	push   $0x1000
f0101d29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d2c:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0101d32:	e8 cb f3 ff ff       	call   f0101102 <pgdir_walk>
f0101d37:	83 c4 10             	add    $0x10,%esp
f0101d3a:	f6 00 04             	testb  $0x4,(%eax)
f0101d3d:	0f 85 c2 08 00 00    	jne    f0102605 <mem_init+0x12e9>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d43:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d46:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f0101d4c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d51:	89 f0                	mov    %esi,%eax
f0101d53:	e8 14 ee ff ff       	call   f0100b6c <check_va2pa>
f0101d58:	89 d9                	mov    %ebx,%ecx
f0101d5a:	89 fb                	mov    %edi,%ebx
f0101d5c:	2b 99 ac 1f 00 00    	sub    0x1fac(%ecx),%ebx
f0101d62:	c1 fb 03             	sar    $0x3,%ebx
f0101d65:	c1 e3 0c             	shl    $0xc,%ebx
f0101d68:	39 d8                	cmp    %ebx,%eax
f0101d6a:	0f 85 b7 08 00 00    	jne    f0102627 <mem_init+0x130b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d70:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d75:	89 f0                	mov    %esi,%eax
f0101d77:	e8 f0 ed ff ff       	call   f0100b6c <check_va2pa>
f0101d7c:	39 c3                	cmp    %eax,%ebx
f0101d7e:	0f 85 c5 08 00 00    	jne    f0102649 <mem_init+0x132d>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d84:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101d89:	0f 85 dc 08 00 00    	jne    f010266b <mem_init+0x134f>
	assert(pp2->pp_ref == 0);
f0101d8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d92:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101d97:	0f 85 f0 08 00 00    	jne    f010268d <mem_init+0x1371>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d9d:	83 ec 0c             	sub    $0xc,%esp
f0101da0:	6a 00                	push   $0x0
f0101da2:	e8 5e f2 ff ff       	call   f0101005 <page_alloc>
f0101da7:	83 c4 10             	add    $0x10,%esp
f0101daa:	85 c0                	test   %eax,%eax
f0101dac:	0f 84 fd 08 00 00    	je     f01026af <mem_init+0x1393>
f0101db2:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101db5:	0f 85 f4 08 00 00    	jne    f01026af <mem_init+0x1393>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101dbb:	83 ec 08             	sub    $0x8,%esp
f0101dbe:	6a 00                	push   $0x0
f0101dc0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dc3:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101dc9:	e8 96 f4 ff ff       	call   f0101264 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dce:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0101dd4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dd9:	89 d8                	mov    %ebx,%eax
f0101ddb:	e8 8c ed ff ff       	call   f0100b6c <check_va2pa>
f0101de0:	83 c4 10             	add    $0x10,%esp
f0101de3:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101de6:	0f 85 e5 08 00 00    	jne    f01026d1 <mem_init+0x13b5>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dec:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101df1:	89 d8                	mov    %ebx,%eax
f0101df3:	e8 74 ed ff ff       	call   f0100b6c <check_va2pa>
f0101df8:	89 c2                	mov    %eax,%edx
f0101dfa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101dfd:	89 f8                	mov    %edi,%eax
f0101dff:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0101e05:	c1 f8 03             	sar    $0x3,%eax
f0101e08:	c1 e0 0c             	shl    $0xc,%eax
f0101e0b:	39 c2                	cmp    %eax,%edx
f0101e0d:	0f 85 e0 08 00 00    	jne    f01026f3 <mem_init+0x13d7>
	assert(pp1->pp_ref == 1);
f0101e13:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e18:	0f 85 f6 08 00 00    	jne    f0102714 <mem_init+0x13f8>
	assert(pp2->pp_ref == 0);
f0101e1e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e21:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e26:	0f 85 0a 09 00 00    	jne    f0102736 <mem_init+0x141a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e2c:	6a 00                	push   $0x0
f0101e2e:	68 00 10 00 00       	push   $0x1000
f0101e33:	57                   	push   %edi
f0101e34:	53                   	push   %ebx
f0101e35:	e8 70 f4 ff ff       	call   f01012aa <page_insert>
f0101e3a:	83 c4 10             	add    $0x10,%esp
f0101e3d:	85 c0                	test   %eax,%eax
f0101e3f:	0f 85 13 09 00 00    	jne    f0102758 <mem_init+0x143c>
	assert(pp1->pp_ref);
f0101e45:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e4a:	0f 84 2a 09 00 00    	je     f010277a <mem_init+0x145e>
	assert(pp1->pp_link == NULL);
f0101e50:	83 3f 00             	cmpl   $0x0,(%edi)
f0101e53:	0f 85 43 09 00 00    	jne    f010279c <mem_init+0x1480>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e59:	83 ec 08             	sub    $0x8,%esp
f0101e5c:	68 00 10 00 00       	push   $0x1000
f0101e61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e64:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101e6a:	e8 f5 f3 ff ff       	call   f0101264 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e6f:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0101e75:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e7a:	89 d8                	mov    %ebx,%eax
f0101e7c:	e8 eb ec ff ff       	call   f0100b6c <check_va2pa>
f0101e81:	83 c4 10             	add    $0x10,%esp
f0101e84:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e87:	0f 85 31 09 00 00    	jne    f01027be <mem_init+0x14a2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e8d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e92:	89 d8                	mov    %ebx,%eax
f0101e94:	e8 d3 ec ff ff       	call   f0100b6c <check_va2pa>
f0101e99:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e9c:	0f 85 3e 09 00 00    	jne    f01027e0 <mem_init+0x14c4>
	assert(pp1->pp_ref == 0);
f0101ea2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ea7:	0f 85 55 09 00 00    	jne    f0102802 <mem_init+0x14e6>
	assert(pp2->pp_ref == 0);
f0101ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101eb0:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101eb5:	0f 85 69 09 00 00    	jne    f0102824 <mem_init+0x1508>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ebb:	83 ec 0c             	sub    $0xc,%esp
f0101ebe:	6a 00                	push   $0x0
f0101ec0:	e8 40 f1 ff ff       	call   f0101005 <page_alloc>
f0101ec5:	83 c4 10             	add    $0x10,%esp
f0101ec8:	39 c7                	cmp    %eax,%edi
f0101eca:	0f 85 76 09 00 00    	jne    f0102846 <mem_init+0x152a>
f0101ed0:	85 c0                	test   %eax,%eax
f0101ed2:	0f 84 6e 09 00 00    	je     f0102846 <mem_init+0x152a>

	// should be no free memory
	assert(!page_alloc(0));
f0101ed8:	83 ec 0c             	sub    $0xc,%esp
f0101edb:	6a 00                	push   $0x0
f0101edd:	e8 23 f1 ff ff       	call   f0101005 <page_alloc>
f0101ee2:	83 c4 10             	add    $0x10,%esp
f0101ee5:	85 c0                	test   %eax,%eax
f0101ee7:	0f 85 7b 09 00 00    	jne    f0102868 <mem_init+0x154c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101eed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ef0:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0101ef6:	8b 11                	mov    (%ecx),%edx
f0101ef8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101efe:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101f01:	2b 98 ac 1f 00 00    	sub    0x1fac(%eax),%ebx
f0101f07:	89 d8                	mov    %ebx,%eax
f0101f09:	c1 f8 03             	sar    $0x3,%eax
f0101f0c:	c1 e0 0c             	shl    $0xc,%eax
f0101f0f:	39 c2                	cmp    %eax,%edx
f0101f11:	0f 85 73 09 00 00    	jne    f010288a <mem_init+0x156e>
	kern_pgdir[0] = 0;
f0101f17:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f1d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f20:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f25:	0f 85 81 09 00 00    	jne    f01028ac <mem_init+0x1590>
	pp0->pp_ref = 0;
f0101f2b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f2e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f34:	83 ec 0c             	sub    $0xc,%esp
f0101f37:	50                   	push   %eax
f0101f38:	e8 4d f1 ff ff       	call   f010108a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f3d:	83 c4 0c             	add    $0xc,%esp
f0101f40:	6a 01                	push   $0x1
f0101f42:	68 00 10 40 00       	push   $0x401000
f0101f47:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f4a:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101f50:	e8 ad f1 ff ff       	call   f0101102 <pgdir_walk>
f0101f55:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f57:	89 d9                	mov    %ebx,%ecx
f0101f59:	8b 9b b0 1f 00 00    	mov    0x1fb0(%ebx),%ebx
f0101f5f:	8b 43 04             	mov    0x4(%ebx),%eax
f0101f62:	89 c2                	mov    %eax,%edx
f0101f64:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101f6a:	8b 89 b4 1f 00 00    	mov    0x1fb4(%ecx),%ecx
f0101f70:	c1 e8 0c             	shr    $0xc,%eax
f0101f73:	83 c4 10             	add    $0x10,%esp
f0101f76:	39 c8                	cmp    %ecx,%eax
f0101f78:	0f 83 50 09 00 00    	jae    f01028ce <mem_init+0x15b2>
	assert(ptep == ptep1 + PTX(va));
f0101f7e:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101f84:	39 d6                	cmp    %edx,%esi
f0101f86:	0f 85 5e 09 00 00    	jne    f01028ea <mem_init+0x15ce>
	kern_pgdir[PDX(va)] = 0;
f0101f8c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0101f93:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f96:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101f9c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f9f:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101fa5:	c1 f8 03             	sar    $0x3,%eax
f0101fa8:	89 c2                	mov    %eax,%edx
f0101faa:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101fad:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101fb2:	39 c1                	cmp    %eax,%ecx
f0101fb4:	0f 86 52 09 00 00    	jbe    f010290c <mem_init+0x15f0>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101fba:	83 ec 04             	sub    $0x4,%esp
f0101fbd:	68 00 10 00 00       	push   $0x1000
f0101fc2:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101fc7:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101fcd:	52                   	push   %edx
f0101fce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fd1:	e8 a1 1c 00 00       	call   f0103c77 <memset>
	page_free(pp0);
f0101fd6:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101fd9:	89 34 24             	mov    %esi,(%esp)
f0101fdc:	e8 a9 f0 ff ff       	call   f010108a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101fe1:	83 c4 0c             	add    $0xc,%esp
f0101fe4:	6a 01                	push   $0x1
f0101fe6:	6a 00                	push   $0x0
f0101fe8:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0101fee:	e8 0f f1 ff ff       	call   f0101102 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101ff3:	89 f0                	mov    %esi,%eax
f0101ff5:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0101ffb:	c1 f8 03             	sar    $0x3,%eax
f0101ffe:	89 c2                	mov    %eax,%edx
f0102000:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102003:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102008:	83 c4 10             	add    $0x10,%esp
f010200b:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0102011:	0f 83 0b 09 00 00    	jae    f0102922 <mem_init+0x1606>
	return (void *)(pa + KERNBASE);
f0102017:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010201d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102023:	8b 30                	mov    (%eax),%esi
f0102025:	83 e6 01             	and    $0x1,%esi
f0102028:	0f 85 0d 09 00 00    	jne    f010293b <mem_init+0x161f>
	for(i=0; i<NPTENTRIES; i++)
f010202e:	83 c0 04             	add    $0x4,%eax
f0102031:	39 c2                	cmp    %eax,%edx
f0102033:	75 ee                	jne    f0102023 <mem_init+0xd07>
	kern_pgdir[0] = 0;
f0102035:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102038:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f010203e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102044:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102047:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010204d:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102050:	89 93 bc 1f 00 00    	mov    %edx,0x1fbc(%ebx)

	// free the pages we took
	page_free(pp0);
f0102056:	83 ec 0c             	sub    $0xc,%esp
f0102059:	50                   	push   %eax
f010205a:	e8 2b f0 ff ff       	call   f010108a <page_free>
	page_free(pp1);
f010205f:	89 3c 24             	mov    %edi,(%esp)
f0102062:	e8 23 f0 ff ff       	call   f010108a <page_free>
	page_free(pp2);
f0102067:	83 c4 04             	add    $0x4,%esp
f010206a:	ff 75 d0             	push   -0x30(%ebp)
f010206d:	e8 18 f0 ff ff       	call   f010108a <page_free>

	cprintf("check_page() succeeded!\n");
f0102072:	8d 83 66 d5 fe ff    	lea    -0x12a9a(%ebx),%eax
f0102078:	89 04 24             	mov    %eax,(%esp)
f010207b:	e8 f7 0f 00 00       	call   f0103077 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102080:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102086:	83 c4 10             	add    $0x10,%esp
f0102089:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010208e:	0f 86 c9 08 00 00    	jbe    f010295d <mem_init+0x1641>
f0102094:	83 ec 08             	sub    $0x8,%esp
f0102097:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102099:	05 00 00 00 10       	add    $0x10000000,%eax
f010209e:	50                   	push   %eax
f010209f:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01020a4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020ac:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f01020b2:	e8 f0 f0 ff ff       	call   f01011a7 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020b7:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f01020bd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01020c0:	83 c4 10             	add    $0x10,%esp
f01020c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020c8:	0f 86 ab 08 00 00    	jbe    f0102979 <mem_init+0x165d>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01020ce:	83 ec 08             	sub    $0x8,%esp
f01020d1:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f01020d3:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01020d6:	05 00 00 00 10       	add    $0x10000000,%eax
f01020db:	50                   	push   %eax
f01020dc:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020e1:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020e6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020e9:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f01020ef:	e8 b3 f0 ff ff       	call   f01011a7 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W);
f01020f4:	83 c4 08             	add    $0x8,%esp
f01020f7:	6a 02                	push   $0x2
f01020f9:	6a 00                	push   $0x0
f01020fb:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102100:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102105:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f010210b:	e8 97 f0 ff ff       	call   f01011a7 <boot_map_region>
	pgdir = kern_pgdir;
f0102110:	89 f9                	mov    %edi,%ecx
f0102112:	8b bf b0 1f 00 00    	mov    0x1fb0(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102118:	8b 81 b4 1f 00 00    	mov    0x1fb4(%ecx),%eax
f010211e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102121:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102128:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010212d:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010212f:	8b 81 ac 1f 00 00    	mov    0x1fac(%ecx),%eax
f0102135:	89 45 bc             	mov    %eax,-0x44(%ebp)
f0102138:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f010213e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102141:	83 c4 10             	add    $0x10,%esp
f0102144:	89 f3                	mov    %esi,%ebx
f0102146:	89 75 c0             	mov    %esi,-0x40(%ebp)
f0102149:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010214c:	89 d6                	mov    %edx,%esi
f010214e:	89 c7                	mov    %eax,%edi
f0102150:	39 de                	cmp    %ebx,%esi
f0102152:	0f 86 82 08 00 00    	jbe    f01029da <mem_init+0x16be>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102158:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010215e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102161:	e8 06 ea ff ff       	call   f0100b6c <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102166:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010216c:	0f 86 28 08 00 00    	jbe    f010299a <mem_init+0x167e>
f0102172:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102175:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102178:	39 d0                	cmp    %edx,%eax
f010217a:	0f 85 38 08 00 00    	jne    f01029b8 <mem_init+0x169c>
	for (i = 0; i < n; i += PGSIZE)
f0102180:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102186:	eb c8                	jmp    f0102150 <mem_init+0xe34>
	assert(nfree == 0);
f0102188:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010218b:	8d 83 8f d4 fe ff    	lea    -0x12b71(%ebx),%eax
f0102191:	50                   	push   %eax
f0102192:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102198:	50                   	push   %eax
f0102199:	68 8a 02 00 00       	push   $0x28a
f010219e:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01021a4:	50                   	push   %eax
f01021a5:	e8 4b df ff ff       	call   f01000f5 <_panic>
	assert((pp0 = page_alloc(0)));
f01021aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021ad:	8d 83 9d d3 fe ff    	lea    -0x12c63(%ebx),%eax
f01021b3:	50                   	push   %eax
f01021b4:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01021ba:	50                   	push   %eax
f01021bb:	68 e3 02 00 00       	push   $0x2e3
f01021c0:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01021c6:	50                   	push   %eax
f01021c7:	e8 29 df ff ff       	call   f01000f5 <_panic>
	assert((pp1 = page_alloc(0)));
f01021cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021cf:	8d 83 b3 d3 fe ff    	lea    -0x12c4d(%ebx),%eax
f01021d5:	50                   	push   %eax
f01021d6:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01021dc:	50                   	push   %eax
f01021dd:	68 e4 02 00 00       	push   $0x2e4
f01021e2:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01021e8:	50                   	push   %eax
f01021e9:	e8 07 df ff ff       	call   f01000f5 <_panic>
	assert((pp2 = page_alloc(0)));
f01021ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021f1:	8d 83 c9 d3 fe ff    	lea    -0x12c37(%ebx),%eax
f01021f7:	50                   	push   %eax
f01021f8:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01021fe:	50                   	push   %eax
f01021ff:	68 e5 02 00 00       	push   $0x2e5
f0102204:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010220a:	50                   	push   %eax
f010220b:	e8 e5 de ff ff       	call   f01000f5 <_panic>
	assert(pp1 && pp1 != pp0);
f0102210:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102213:	8d 83 df d3 fe ff    	lea    -0x12c21(%ebx),%eax
f0102219:	50                   	push   %eax
f010221a:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102220:	50                   	push   %eax
f0102221:	68 e8 02 00 00       	push   $0x2e8
f0102226:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010222c:	50                   	push   %eax
f010222d:	e8 c3 de ff ff       	call   f01000f5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102232:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102235:	8d 83 70 d7 fe ff    	lea    -0x12890(%ebx),%eax
f010223b:	50                   	push   %eax
f010223c:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102242:	50                   	push   %eax
f0102243:	68 e9 02 00 00       	push   $0x2e9
f0102248:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010224e:	50                   	push   %eax
f010224f:	e8 a1 de ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f0102254:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102257:	8d 83 48 d4 fe ff    	lea    -0x12bb8(%ebx),%eax
f010225d:	50                   	push   %eax
f010225e:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102264:	50                   	push   %eax
f0102265:	68 f0 02 00 00       	push   $0x2f0
f010226a:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102270:	50                   	push   %eax
f0102271:	e8 7f de ff ff       	call   f01000f5 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102276:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102279:	8d 83 b0 d7 fe ff    	lea    -0x12850(%ebx),%eax
f010227f:	50                   	push   %eax
f0102280:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102286:	50                   	push   %eax
f0102287:	68 f3 02 00 00       	push   $0x2f3
f010228c:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102292:	50                   	push   %eax
f0102293:	e8 5d de ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102298:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010229b:	8d 83 e8 d7 fe ff    	lea    -0x12818(%ebx),%eax
f01022a1:	50                   	push   %eax
f01022a2:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01022a8:	50                   	push   %eax
f01022a9:	68 f6 02 00 00       	push   $0x2f6
f01022ae:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01022b4:	50                   	push   %eax
f01022b5:	e8 3b de ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022bd:	8d 83 18 d8 fe ff    	lea    -0x127e8(%ebx),%eax
f01022c3:	50                   	push   %eax
f01022c4:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01022ca:	50                   	push   %eax
f01022cb:	68 fa 02 00 00       	push   $0x2fa
f01022d0:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01022d6:	50                   	push   %eax
f01022d7:	e8 19 de ff ff       	call   f01000f5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022df:	8d 83 48 d8 fe ff    	lea    -0x127b8(%ebx),%eax
f01022e5:	50                   	push   %eax
f01022e6:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01022ec:	50                   	push   %eax
f01022ed:	68 fb 02 00 00       	push   $0x2fb
f01022f2:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01022f8:	50                   	push   %eax
f01022f9:	e8 f7 dd ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102301:	8d 83 70 d8 fe ff    	lea    -0x12790(%ebx),%eax
f0102307:	50                   	push   %eax
f0102308:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010230e:	50                   	push   %eax
f010230f:	68 fc 02 00 00       	push   $0x2fc
f0102314:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010231a:	50                   	push   %eax
f010231b:	e8 d5 dd ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 1);
f0102320:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102323:	8d 83 9a d4 fe ff    	lea    -0x12b66(%ebx),%eax
f0102329:	50                   	push   %eax
f010232a:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102330:	50                   	push   %eax
f0102331:	68 fd 02 00 00       	push   $0x2fd
f0102336:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010233c:	50                   	push   %eax
f010233d:	e8 b3 dd ff ff       	call   f01000f5 <_panic>
	assert(pp0->pp_ref == 1);
f0102342:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102345:	8d 83 ab d4 fe ff    	lea    -0x12b55(%ebx),%eax
f010234b:	50                   	push   %eax
f010234c:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102352:	50                   	push   %eax
f0102353:	68 fe 02 00 00       	push   $0x2fe
f0102358:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010235e:	50                   	push   %eax
f010235f:	e8 91 dd ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102364:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102367:	8d 83 a0 d8 fe ff    	lea    -0x12760(%ebx),%eax
f010236d:	50                   	push   %eax
f010236e:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102374:	50                   	push   %eax
f0102375:	68 01 03 00 00       	push   $0x301
f010237a:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102380:	50                   	push   %eax
f0102381:	e8 6f dd ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102386:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102389:	8d 83 dc d8 fe ff    	lea    -0x12724(%ebx),%eax
f010238f:	50                   	push   %eax
f0102390:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102396:	50                   	push   %eax
f0102397:	68 02 03 00 00       	push   $0x302
f010239c:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01023a2:	50                   	push   %eax
f01023a3:	e8 4d dd ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 1);
f01023a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ab:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f01023b1:	50                   	push   %eax
f01023b2:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01023b8:	50                   	push   %eax
f01023b9:	68 03 03 00 00       	push   $0x303
f01023be:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01023c4:	50                   	push   %eax
f01023c5:	e8 2b dd ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f01023ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023cd:	8d 83 48 d4 fe ff    	lea    -0x12bb8(%ebx),%eax
f01023d3:	50                   	push   %eax
f01023d4:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01023da:	50                   	push   %eax
f01023db:	68 06 03 00 00       	push   $0x306
f01023e0:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01023e6:	50                   	push   %eax
f01023e7:	e8 09 dd ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ef:	8d 83 a0 d8 fe ff    	lea    -0x12760(%ebx),%eax
f01023f5:	50                   	push   %eax
f01023f6:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01023fc:	50                   	push   %eax
f01023fd:	68 09 03 00 00       	push   $0x309
f0102402:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102408:	50                   	push   %eax
f0102409:	e8 e7 dc ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010240e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102411:	8d 83 dc d8 fe ff    	lea    -0x12724(%ebx),%eax
f0102417:	50                   	push   %eax
f0102418:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010241e:	50                   	push   %eax
f010241f:	68 0a 03 00 00       	push   $0x30a
f0102424:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010242a:	50                   	push   %eax
f010242b:	e8 c5 dc ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 1);
f0102430:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102433:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0102439:	50                   	push   %eax
f010243a:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102440:	50                   	push   %eax
f0102441:	68 0b 03 00 00       	push   $0x30b
f0102446:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010244c:	50                   	push   %eax
f010244d:	e8 a3 dc ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f0102452:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102455:	8d 83 48 d4 fe ff    	lea    -0x12bb8(%ebx),%eax
f010245b:	50                   	push   %eax
f010245c:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102462:	50                   	push   %eax
f0102463:	68 0f 03 00 00       	push   $0x30f
f0102468:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010246e:	50                   	push   %eax
f010246f:	e8 81 dc ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102474:	53                   	push   %ebx
f0102475:	89 cb                	mov    %ecx,%ebx
f0102477:	8d 81 b0 d5 fe ff    	lea    -0x12a50(%ecx),%eax
f010247d:	50                   	push   %eax
f010247e:	68 12 03 00 00       	push   $0x312
f0102483:	8d 81 cc d2 fe ff    	lea    -0x12d34(%ecx),%eax
f0102489:	50                   	push   %eax
f010248a:	e8 66 dc ff ff       	call   f01000f5 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010248f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102492:	8d 83 0c d9 fe ff    	lea    -0x126f4(%ebx),%eax
f0102498:	50                   	push   %eax
f0102499:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010249f:	50                   	push   %eax
f01024a0:	68 13 03 00 00       	push   $0x313
f01024a5:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01024ab:	50                   	push   %eax
f01024ac:	e8 44 dc ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024b4:	8d 83 4c d9 fe ff    	lea    -0x126b4(%ebx),%eax
f01024ba:	50                   	push   %eax
f01024bb:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01024c1:	50                   	push   %eax
f01024c2:	68 16 03 00 00       	push   $0x316
f01024c7:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01024cd:	50                   	push   %eax
f01024ce:	e8 22 dc ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024d3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024d6:	8d 83 dc d8 fe ff    	lea    -0x12724(%ebx),%eax
f01024dc:	50                   	push   %eax
f01024dd:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01024e3:	50                   	push   %eax
f01024e4:	68 17 03 00 00       	push   $0x317
f01024e9:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01024ef:	50                   	push   %eax
f01024f0:	e8 00 dc ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 1);
f01024f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024f8:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f01024fe:	50                   	push   %eax
f01024ff:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102505:	50                   	push   %eax
f0102506:	68 18 03 00 00       	push   $0x318
f010250b:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102511:	50                   	push   %eax
f0102512:	e8 de db ff ff       	call   f01000f5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102517:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010251a:	8d 83 8c d9 fe ff    	lea    -0x12674(%ebx),%eax
f0102520:	50                   	push   %eax
f0102521:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102527:	50                   	push   %eax
f0102528:	68 19 03 00 00       	push   $0x319
f010252d:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102533:	50                   	push   %eax
f0102534:	e8 bc db ff ff       	call   f01000f5 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102539:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010253c:	8d 83 cd d4 fe ff    	lea    -0x12b33(%ebx),%eax
f0102542:	50                   	push   %eax
f0102543:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102549:	50                   	push   %eax
f010254a:	68 1a 03 00 00       	push   $0x31a
f010254f:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102555:	50                   	push   %eax
f0102556:	e8 9a db ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010255b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010255e:	8d 83 a0 d8 fe ff    	lea    -0x12760(%ebx),%eax
f0102564:	50                   	push   %eax
f0102565:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010256b:	50                   	push   %eax
f010256c:	68 1d 03 00 00       	push   $0x31d
f0102571:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102577:	50                   	push   %eax
f0102578:	e8 78 db ff ff       	call   f01000f5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010257d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102580:	8d 83 c0 d9 fe ff    	lea    -0x12640(%ebx),%eax
f0102586:	50                   	push   %eax
f0102587:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010258d:	50                   	push   %eax
f010258e:	68 1e 03 00 00       	push   $0x31e
f0102593:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102599:	50                   	push   %eax
f010259a:	e8 56 db ff ff       	call   f01000f5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010259f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025a2:	8d 83 f4 d9 fe ff    	lea    -0x1260c(%ebx),%eax
f01025a8:	50                   	push   %eax
f01025a9:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01025af:	50                   	push   %eax
f01025b0:	68 1f 03 00 00       	push   $0x31f
f01025b5:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01025bb:	50                   	push   %eax
f01025bc:	e8 34 db ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01025c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025c4:	8d 83 2c da fe ff    	lea    -0x125d4(%ebx),%eax
f01025ca:	50                   	push   %eax
f01025cb:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01025d1:	50                   	push   %eax
f01025d2:	68 22 03 00 00       	push   $0x322
f01025d7:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01025dd:	50                   	push   %eax
f01025de:	e8 12 db ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025e6:	8d 83 64 da fe ff    	lea    -0x1259c(%ebx),%eax
f01025ec:	50                   	push   %eax
f01025ed:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01025f3:	50                   	push   %eax
f01025f4:	68 25 03 00 00       	push   $0x325
f01025f9:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01025ff:	50                   	push   %eax
f0102600:	e8 f0 da ff ff       	call   f01000f5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102605:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102608:	8d 83 f4 d9 fe ff    	lea    -0x1260c(%ebx),%eax
f010260e:	50                   	push   %eax
f010260f:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102615:	50                   	push   %eax
f0102616:	68 26 03 00 00       	push   $0x326
f010261b:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102621:	50                   	push   %eax
f0102622:	e8 ce da ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102627:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010262a:	8d 83 a0 da fe ff    	lea    -0x12560(%ebx),%eax
f0102630:	50                   	push   %eax
f0102631:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102637:	50                   	push   %eax
f0102638:	68 29 03 00 00       	push   $0x329
f010263d:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102643:	50                   	push   %eax
f0102644:	e8 ac da ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102649:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010264c:	8d 83 cc da fe ff    	lea    -0x12534(%ebx),%eax
f0102652:	50                   	push   %eax
f0102653:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102659:	50                   	push   %eax
f010265a:	68 2a 03 00 00       	push   $0x32a
f010265f:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102665:	50                   	push   %eax
f0102666:	e8 8a da ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 2);
f010266b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010266e:	8d 83 e3 d4 fe ff    	lea    -0x12b1d(%ebx),%eax
f0102674:	50                   	push   %eax
f0102675:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010267b:	50                   	push   %eax
f010267c:	68 2c 03 00 00       	push   $0x32c
f0102681:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102687:	50                   	push   %eax
f0102688:	e8 68 da ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 0);
f010268d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102690:	8d 83 f4 d4 fe ff    	lea    -0x12b0c(%ebx),%eax
f0102696:	50                   	push   %eax
f0102697:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010269d:	50                   	push   %eax
f010269e:	68 2d 03 00 00       	push   $0x32d
f01026a3:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01026a9:	50                   	push   %eax
f01026aa:	e8 46 da ff ff       	call   f01000f5 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01026af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026b2:	8d 83 fc da fe ff    	lea    -0x12504(%ebx),%eax
f01026b8:	50                   	push   %eax
f01026b9:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01026bf:	50                   	push   %eax
f01026c0:	68 30 03 00 00       	push   $0x330
f01026c5:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01026cb:	50                   	push   %eax
f01026cc:	e8 24 da ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026d4:	8d 83 20 db fe ff    	lea    -0x124e0(%ebx),%eax
f01026da:	50                   	push   %eax
f01026db:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01026e1:	50                   	push   %eax
f01026e2:	68 34 03 00 00       	push   $0x334
f01026e7:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01026ed:	50                   	push   %eax
f01026ee:	e8 02 da ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01026f3:	89 cb                	mov    %ecx,%ebx
f01026f5:	8d 81 cc da fe ff    	lea    -0x12534(%ecx),%eax
f01026fb:	50                   	push   %eax
f01026fc:	8d 81 f2 d2 fe ff    	lea    -0x12d0e(%ecx),%eax
f0102702:	50                   	push   %eax
f0102703:	68 35 03 00 00       	push   $0x335
f0102708:	8d 81 cc d2 fe ff    	lea    -0x12d34(%ecx),%eax
f010270e:	50                   	push   %eax
f010270f:	e8 e1 d9 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 1);
f0102714:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102717:	8d 83 9a d4 fe ff    	lea    -0x12b66(%ebx),%eax
f010271d:	50                   	push   %eax
f010271e:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102724:	50                   	push   %eax
f0102725:	68 36 03 00 00       	push   $0x336
f010272a:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102730:	50                   	push   %eax
f0102731:	e8 bf d9 ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 0);
f0102736:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102739:	8d 83 f4 d4 fe ff    	lea    -0x12b0c(%ebx),%eax
f010273f:	50                   	push   %eax
f0102740:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102746:	50                   	push   %eax
f0102747:	68 37 03 00 00       	push   $0x337
f010274c:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102752:	50                   	push   %eax
f0102753:	e8 9d d9 ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102758:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010275b:	8d 83 44 db fe ff    	lea    -0x124bc(%ebx),%eax
f0102761:	50                   	push   %eax
f0102762:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102768:	50                   	push   %eax
f0102769:	68 3a 03 00 00       	push   $0x33a
f010276e:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102774:	50                   	push   %eax
f0102775:	e8 7b d9 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref);
f010277a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010277d:	8d 83 05 d5 fe ff    	lea    -0x12afb(%ebx),%eax
f0102783:	50                   	push   %eax
f0102784:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010278a:	50                   	push   %eax
f010278b:	68 3b 03 00 00       	push   $0x33b
f0102790:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102796:	50                   	push   %eax
f0102797:	e8 59 d9 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_link == NULL);
f010279c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010279f:	8d 83 11 d5 fe ff    	lea    -0x12aef(%ebx),%eax
f01027a5:	50                   	push   %eax
f01027a6:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01027ac:	50                   	push   %eax
f01027ad:	68 3c 03 00 00       	push   $0x33c
f01027b2:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01027b8:	50                   	push   %eax
f01027b9:	e8 37 d9 ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c1:	8d 83 20 db fe ff    	lea    -0x124e0(%ebx),%eax
f01027c7:	50                   	push   %eax
f01027c8:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01027ce:	50                   	push   %eax
f01027cf:	68 40 03 00 00       	push   $0x340
f01027d4:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01027da:	50                   	push   %eax
f01027db:	e8 15 d9 ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01027e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e3:	8d 83 7c db fe ff    	lea    -0x12484(%ebx),%eax
f01027e9:	50                   	push   %eax
f01027ea:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01027f0:	50                   	push   %eax
f01027f1:	68 41 03 00 00       	push   $0x341
f01027f6:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01027fc:	50                   	push   %eax
f01027fd:	e8 f3 d8 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 0);
f0102802:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102805:	8d 83 26 d5 fe ff    	lea    -0x12ada(%ebx),%eax
f010280b:	50                   	push   %eax
f010280c:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102812:	50                   	push   %eax
f0102813:	68 42 03 00 00       	push   $0x342
f0102818:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f010281e:	50                   	push   %eax
f010281f:	e8 d1 d8 ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 0);
f0102824:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102827:	8d 83 f4 d4 fe ff    	lea    -0x12b0c(%ebx),%eax
f010282d:	50                   	push   %eax
f010282e:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102834:	50                   	push   %eax
f0102835:	68 43 03 00 00       	push   $0x343
f010283a:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102840:	50                   	push   %eax
f0102841:	e8 af d8 ff ff       	call   f01000f5 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102846:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102849:	8d 83 a4 db fe ff    	lea    -0x1245c(%ebx),%eax
f010284f:	50                   	push   %eax
f0102850:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102856:	50                   	push   %eax
f0102857:	68 46 03 00 00       	push   $0x346
f010285c:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102862:	50                   	push   %eax
f0102863:	e8 8d d8 ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f0102868:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010286b:	8d 83 48 d4 fe ff    	lea    -0x12bb8(%ebx),%eax
f0102871:	50                   	push   %eax
f0102872:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102878:	50                   	push   %eax
f0102879:	68 49 03 00 00       	push   $0x349
f010287e:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102884:	50                   	push   %eax
f0102885:	e8 6b d8 ff ff       	call   f01000f5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010288a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010288d:	8d 83 48 d8 fe ff    	lea    -0x127b8(%ebx),%eax
f0102893:	50                   	push   %eax
f0102894:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010289a:	50                   	push   %eax
f010289b:	68 4c 03 00 00       	push   $0x34c
f01028a0:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01028a6:	50                   	push   %eax
f01028a7:	e8 49 d8 ff ff       	call   f01000f5 <_panic>
	assert(pp0->pp_ref == 1);
f01028ac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028af:	8d 83 ab d4 fe ff    	lea    -0x12b55(%ebx),%eax
f01028b5:	50                   	push   %eax
f01028b6:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01028bc:	50                   	push   %eax
f01028bd:	68 4e 03 00 00       	push   $0x34e
f01028c2:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01028c8:	50                   	push   %eax
f01028c9:	e8 27 d8 ff ff       	call   f01000f5 <_panic>
f01028ce:	52                   	push   %edx
f01028cf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028d2:	8d 83 b0 d5 fe ff    	lea    -0x12a50(%ebx),%eax
f01028d8:	50                   	push   %eax
f01028d9:	68 55 03 00 00       	push   $0x355
f01028de:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01028e4:	50                   	push   %eax
f01028e5:	e8 0b d8 ff ff       	call   f01000f5 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028ed:	8d 83 37 d5 fe ff    	lea    -0x12ac9(%ebx),%eax
f01028f3:	50                   	push   %eax
f01028f4:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01028fa:	50                   	push   %eax
f01028fb:	68 56 03 00 00       	push   $0x356
f0102900:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102906:	50                   	push   %eax
f0102907:	e8 e9 d7 ff ff       	call   f01000f5 <_panic>
f010290c:	52                   	push   %edx
f010290d:	8d 83 b0 d5 fe ff    	lea    -0x12a50(%ebx),%eax
f0102913:	50                   	push   %eax
f0102914:	6a 52                	push   $0x52
f0102916:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f010291c:	50                   	push   %eax
f010291d:	e8 d3 d7 ff ff       	call   f01000f5 <_panic>
f0102922:	52                   	push   %edx
f0102923:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102926:	8d 83 b0 d5 fe ff    	lea    -0x12a50(%ebx),%eax
f010292c:	50                   	push   %eax
f010292d:	6a 52                	push   $0x52
f010292f:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f0102935:	50                   	push   %eax
f0102936:	e8 ba d7 ff ff       	call   f01000f5 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010293b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010293e:	8d 83 4f d5 fe ff    	lea    -0x12ab1(%ebx),%eax
f0102944:	50                   	push   %eax
f0102945:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f010294b:	50                   	push   %eax
f010294c:	68 60 03 00 00       	push   $0x360
f0102951:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102957:	50                   	push   %eax
f0102958:	e8 98 d7 ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010295d:	50                   	push   %eax
f010295e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102961:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f0102967:	50                   	push   %eax
f0102968:	68 cf 00 00 00       	push   $0xcf
f010296d:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102973:	50                   	push   %eax
f0102974:	e8 7c d7 ff ff       	call   f01000f5 <_panic>
f0102979:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010297c:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0102982:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f0102988:	50                   	push   %eax
f0102989:	68 d0 00 00 00       	push   $0xd0
f010298e:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102994:	50                   	push   %eax
f0102995:	e8 5b d7 ff ff       	call   f01000f5 <_panic>
f010299a:	ff 75 bc             	push   -0x44(%ebp)
f010299d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a0:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f01029a6:	50                   	push   %eax
f01029a7:	68 a2 02 00 00       	push   $0x2a2
f01029ac:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01029b2:	50                   	push   %eax
f01029b3:	e8 3d d7 ff ff       	call   f01000f5 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01029b8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029bb:	8d 83 c8 db fe ff    	lea    -0x12438(%ebx),%eax
f01029c1:	50                   	push   %eax
f01029c2:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f01029c8:	50                   	push   %eax
f01029c9:	68 a2 02 00 00       	push   $0x2a2
f01029ce:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f01029d4:	50                   	push   %eax
f01029d5:	e8 1b d7 ff ff       	call   f01000f5 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029da:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01029dd:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01029e0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01029e3:	c1 e0 0c             	shl    $0xc,%eax
f01029e6:	89 f3                	mov    %esi,%ebx
f01029e8:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01029eb:	89 c6                	mov    %eax,%esi
f01029ed:	39 f3                	cmp    %esi,%ebx
f01029ef:	73 3b                	jae    f0102a2c <mem_init+0x1710>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029f1:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01029f7:	89 f8                	mov    %edi,%eax
f01029f9:	e8 6e e1 ff ff       	call   f0100b6c <check_va2pa>
f01029fe:	39 c3                	cmp    %eax,%ebx
f0102a00:	75 08                	jne    f0102a0a <mem_init+0x16ee>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a02:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a08:	eb e3                	jmp    f01029ed <mem_init+0x16d1>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a0d:	8d 83 fc db fe ff    	lea    -0x12404(%ebx),%eax
f0102a13:	50                   	push   %eax
f0102a14:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102a1a:	50                   	push   %eax
f0102a1b:	68 a7 02 00 00       	push   $0x2a7
f0102a20:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102a26:	50                   	push   %eax
f0102a27:	e8 c9 d6 ff ff       	call   f01000f5 <_panic>
f0102a2c:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a31:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102a34:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a39:	89 c6                	mov    %eax,%esi
f0102a3b:	89 da                	mov    %ebx,%edx
f0102a3d:	89 f8                	mov    %edi,%eax
f0102a3f:	e8 28 e1 ff ff       	call   f0100b6c <check_va2pa>
f0102a44:	89 c2                	mov    %eax,%edx
f0102a46:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0102a49:	39 c2                	cmp    %eax,%edx
f0102a4b:	75 44                	jne    f0102a91 <mem_init+0x1775>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a4d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a53:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102a59:	75 e0                	jne    f0102a3b <mem_init+0x171f>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a5b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102a5e:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a63:	89 f8                	mov    %edi,%eax
f0102a65:	e8 02 e1 ff ff       	call   f0100b6c <check_va2pa>
f0102a6a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a6d:	74 71                	je     f0102ae0 <mem_init+0x17c4>
f0102a6f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a72:	8d 83 6c dc fe ff    	lea    -0x12394(%ebx),%eax
f0102a78:	50                   	push   %eax
f0102a79:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102a7f:	50                   	push   %eax
f0102a80:	68 ac 02 00 00       	push   $0x2ac
f0102a85:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102a8b:	50                   	push   %eax
f0102a8c:	e8 64 d6 ff ff       	call   f01000f5 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a91:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a94:	8d 83 24 dc fe ff    	lea    -0x123dc(%ebx),%eax
f0102a9a:	50                   	push   %eax
f0102a9b:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102aa1:	50                   	push   %eax
f0102aa2:	68 ab 02 00 00       	push   $0x2ab
f0102aa7:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102aad:	50                   	push   %eax
f0102aae:	e8 42 d6 ff ff       	call   f01000f5 <_panic>
		switch (i) {
f0102ab3:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102ab9:	75 25                	jne    f0102ae0 <mem_init+0x17c4>
			assert(pgdir[i] & PTE_P);
f0102abb:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102abf:	74 4f                	je     f0102b10 <mem_init+0x17f4>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ac1:	83 c6 01             	add    $0x1,%esi
f0102ac4:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102aca:	0f 87 b1 00 00 00    	ja     f0102b81 <mem_init+0x1865>
		switch (i) {
f0102ad0:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102ad6:	77 db                	ja     f0102ab3 <mem_init+0x1797>
f0102ad8:	81 fe bb 03 00 00    	cmp    $0x3bb,%esi
f0102ade:	77 db                	ja     f0102abb <mem_init+0x179f>
			if (i >= PDX(KERNBASE)) {
f0102ae0:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102ae6:	77 4a                	ja     f0102b32 <mem_init+0x1816>
				assert(pgdir[i] == 0);
f0102ae8:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102aec:	74 d3                	je     f0102ac1 <mem_init+0x17a5>
f0102aee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102af1:	8d 83 a1 d5 fe ff    	lea    -0x12a5f(%ebx),%eax
f0102af7:	50                   	push   %eax
f0102af8:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102afe:	50                   	push   %eax
f0102aff:	68 bb 02 00 00       	push   $0x2bb
f0102b04:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102b0a:	50                   	push   %eax
f0102b0b:	e8 e5 d5 ff ff       	call   f01000f5 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b10:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b13:	8d 83 7f d5 fe ff    	lea    -0x12a81(%ebx),%eax
f0102b19:	50                   	push   %eax
f0102b1a:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102b20:	50                   	push   %eax
f0102b21:	68 b4 02 00 00       	push   $0x2b4
f0102b26:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102b2c:	50                   	push   %eax
f0102b2d:	e8 c3 d5 ff ff       	call   f01000f5 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b32:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102b35:	a8 01                	test   $0x1,%al
f0102b37:	74 26                	je     f0102b5f <mem_init+0x1843>
				assert(pgdir[i] & PTE_W);
f0102b39:	a8 02                	test   $0x2,%al
f0102b3b:	75 84                	jne    f0102ac1 <mem_init+0x17a5>
f0102b3d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b40:	8d 83 90 d5 fe ff    	lea    -0x12a70(%ebx),%eax
f0102b46:	50                   	push   %eax
f0102b47:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102b4d:	50                   	push   %eax
f0102b4e:	68 b9 02 00 00       	push   $0x2b9
f0102b53:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102b59:	50                   	push   %eax
f0102b5a:	e8 96 d5 ff ff       	call   f01000f5 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b5f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b62:	8d 83 7f d5 fe ff    	lea    -0x12a81(%ebx),%eax
f0102b68:	50                   	push   %eax
f0102b69:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102b6f:	50                   	push   %eax
f0102b70:	68 b8 02 00 00       	push   $0x2b8
f0102b75:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102b7b:	50                   	push   %eax
f0102b7c:	e8 74 d5 ff ff       	call   f01000f5 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b81:	83 ec 0c             	sub    $0xc,%esp
f0102b84:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b87:	8d 83 9c dc fe ff    	lea    -0x12364(%ebx),%eax
f0102b8d:	50                   	push   %eax
f0102b8e:	e8 e4 04 00 00       	call   f0103077 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b93:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102b99:	83 c4 10             	add    $0x10,%esp
f0102b9c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ba1:	0f 86 2c 02 00 00    	jbe    f0102dd3 <mem_init+0x1ab7>
	return (physaddr_t)kva - KERNBASE;
f0102ba7:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102bac:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102baf:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bb4:	e8 2f e0 ff ff       	call   f0100be8 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102bb9:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102bbc:	83 e0 f3             	and    $0xfffffff3,%eax
f0102bbf:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102bc4:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102bc7:	83 ec 0c             	sub    $0xc,%esp
f0102bca:	6a 00                	push   $0x0
f0102bcc:	e8 34 e4 ff ff       	call   f0101005 <page_alloc>
f0102bd1:	89 c6                	mov    %eax,%esi
f0102bd3:	83 c4 10             	add    $0x10,%esp
f0102bd6:	85 c0                	test   %eax,%eax
f0102bd8:	0f 84 11 02 00 00    	je     f0102def <mem_init+0x1ad3>
	assert((pp1 = page_alloc(0)));
f0102bde:	83 ec 0c             	sub    $0xc,%esp
f0102be1:	6a 00                	push   $0x0
f0102be3:	e8 1d e4 ff ff       	call   f0101005 <page_alloc>
f0102be8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102beb:	83 c4 10             	add    $0x10,%esp
f0102bee:	85 c0                	test   %eax,%eax
f0102bf0:	0f 84 1b 02 00 00    	je     f0102e11 <mem_init+0x1af5>
	assert((pp2 = page_alloc(0)));
f0102bf6:	83 ec 0c             	sub    $0xc,%esp
f0102bf9:	6a 00                	push   $0x0
f0102bfb:	e8 05 e4 ff ff       	call   f0101005 <page_alloc>
f0102c00:	89 c7                	mov    %eax,%edi
f0102c02:	83 c4 10             	add    $0x10,%esp
f0102c05:	85 c0                	test   %eax,%eax
f0102c07:	0f 84 26 02 00 00    	je     f0102e33 <mem_init+0x1b17>
	page_free(pp0);
f0102c0d:	83 ec 0c             	sub    $0xc,%esp
f0102c10:	56                   	push   %esi
f0102c11:	e8 74 e4 ff ff       	call   f010108a <page_free>
	return (pp - pages) << PGSHIFT;
f0102c16:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c19:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c1c:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0102c22:	c1 f8 03             	sar    $0x3,%eax
f0102c25:	89 c2                	mov    %eax,%edx
f0102c27:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c2a:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c2f:	83 c4 10             	add    $0x10,%esp
f0102c32:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0102c38:	0f 83 17 02 00 00    	jae    f0102e55 <mem_init+0x1b39>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c3e:	83 ec 04             	sub    $0x4,%esp
f0102c41:	68 00 10 00 00       	push   $0x1000
f0102c46:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c48:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c4e:	52                   	push   %edx
f0102c4f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c52:	e8 20 10 00 00       	call   f0103c77 <memset>
	return (pp - pages) << PGSHIFT;
f0102c57:	89 f8                	mov    %edi,%eax
f0102c59:	2b 83 ac 1f 00 00    	sub    0x1fac(%ebx),%eax
f0102c5f:	c1 f8 03             	sar    $0x3,%eax
f0102c62:	89 c2                	mov    %eax,%edx
f0102c64:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c67:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c6c:	83 c4 10             	add    $0x10,%esp
f0102c6f:	3b 83 b4 1f 00 00    	cmp    0x1fb4(%ebx),%eax
f0102c75:	0f 83 f2 01 00 00    	jae    f0102e6d <mem_init+0x1b51>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c7b:	83 ec 04             	sub    $0x4,%esp
f0102c7e:	68 00 10 00 00       	push   $0x1000
f0102c83:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c85:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c8b:	52                   	push   %edx
f0102c8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c8f:	e8 e3 0f 00 00       	call   f0103c77 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c94:	6a 02                	push   $0x2
f0102c96:	68 00 10 00 00       	push   $0x1000
f0102c9b:	ff 75 d0             	push   -0x30(%ebp)
f0102c9e:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f0102ca4:	e8 01 e6 ff ff       	call   f01012aa <page_insert>
	assert(pp1->pp_ref == 1);
f0102ca9:	83 c4 20             	add    $0x20,%esp
f0102cac:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102caf:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102cb4:	0f 85 cc 01 00 00    	jne    f0102e86 <mem_init+0x1b6a>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cba:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cc1:	01 01 01 
f0102cc4:	0f 85 de 01 00 00    	jne    f0102ea8 <mem_init+0x1b8c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cca:	6a 02                	push   $0x2
f0102ccc:	68 00 10 00 00       	push   $0x1000
f0102cd1:	57                   	push   %edi
f0102cd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102cd5:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0102cdb:	e8 ca e5 ff ff       	call   f01012aa <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102ce0:	83 c4 10             	add    $0x10,%esp
f0102ce3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cea:	02 02 02 
f0102ced:	0f 85 d7 01 00 00    	jne    f0102eca <mem_init+0x1bae>
	assert(pp2->pp_ref == 1);
f0102cf3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cf8:	0f 85 ee 01 00 00    	jne    f0102eec <mem_init+0x1bd0>
	assert(pp1->pp_ref == 0);
f0102cfe:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d01:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102d06:	0f 85 02 02 00 00    	jne    f0102f0e <mem_init+0x1bf2>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d0c:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d13:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d16:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102d19:	89 f8                	mov    %edi,%eax
f0102d1b:	2b 81 ac 1f 00 00    	sub    0x1fac(%ecx),%eax
f0102d21:	c1 f8 03             	sar    $0x3,%eax
f0102d24:	89 c2                	mov    %eax,%edx
f0102d26:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d29:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d2e:	3b 81 b4 1f 00 00    	cmp    0x1fb4(%ecx),%eax
f0102d34:	0f 83 f6 01 00 00    	jae    f0102f30 <mem_init+0x1c14>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d3a:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d41:	03 03 03 
f0102d44:	0f 85 fe 01 00 00    	jne    f0102f48 <mem_init+0x1c2c>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d4a:	83 ec 08             	sub    $0x8,%esp
f0102d4d:	68 00 10 00 00       	push   $0x1000
f0102d52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d55:	ff b0 b0 1f 00 00    	push   0x1fb0(%eax)
f0102d5b:	e8 04 e5 ff ff       	call   f0101264 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d60:	83 c4 10             	add    $0x10,%esp
f0102d63:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d68:	0f 85 fc 01 00 00    	jne    f0102f6a <mem_init+0x1c4e>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d71:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0102d77:	8b 11                	mov    (%ecx),%edx
f0102d79:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102d7f:	89 f7                	mov    %esi,%edi
f0102d81:	2b b8 ac 1f 00 00    	sub    0x1fac(%eax),%edi
f0102d87:	89 f8                	mov    %edi,%eax
f0102d89:	c1 f8 03             	sar    $0x3,%eax
f0102d8c:	c1 e0 0c             	shl    $0xc,%eax
f0102d8f:	39 c2                	cmp    %eax,%edx
f0102d91:	0f 85 f5 01 00 00    	jne    f0102f8c <mem_init+0x1c70>
	kern_pgdir[0] = 0;
f0102d97:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d9d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102da2:	0f 85 06 02 00 00    	jne    f0102fae <mem_init+0x1c92>
	pp0->pp_ref = 0;
f0102da8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102dae:	83 ec 0c             	sub    $0xc,%esp
f0102db1:	56                   	push   %esi
f0102db2:	e8 d3 e2 ff ff       	call   f010108a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102db7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dba:	8d 83 30 dd fe ff    	lea    -0x122d0(%ebx),%eax
f0102dc0:	89 04 24             	mov    %eax,(%esp)
f0102dc3:	e8 af 02 00 00       	call   f0103077 <cprintf>
}
f0102dc8:	83 c4 10             	add    $0x10,%esp
f0102dcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dce:	5b                   	pop    %ebx
f0102dcf:	5e                   	pop    %esi
f0102dd0:	5f                   	pop    %edi
f0102dd1:	5d                   	pop    %ebp
f0102dd2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dd3:	50                   	push   %eax
f0102dd4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dd7:	8d 83 bc d6 fe ff    	lea    -0x12944(%ebx),%eax
f0102ddd:	50                   	push   %eax
f0102dde:	68 dd 00 00 00       	push   $0xdd
f0102de3:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102de9:	50                   	push   %eax
f0102dea:	e8 06 d3 ff ff       	call   f01000f5 <_panic>
	assert((pp0 = page_alloc(0)));
f0102def:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df2:	8d 83 9d d3 fe ff    	lea    -0x12c63(%ebx),%eax
f0102df8:	50                   	push   %eax
f0102df9:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102dff:	50                   	push   %eax
f0102e00:	68 7b 03 00 00       	push   $0x37b
f0102e05:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102e0b:	50                   	push   %eax
f0102e0c:	e8 e4 d2 ff ff       	call   f01000f5 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e11:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e14:	8d 83 b3 d3 fe ff    	lea    -0x12c4d(%ebx),%eax
f0102e1a:	50                   	push   %eax
f0102e1b:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102e21:	50                   	push   %eax
f0102e22:	68 7c 03 00 00       	push   $0x37c
f0102e27:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102e2d:	50                   	push   %eax
f0102e2e:	e8 c2 d2 ff ff       	call   f01000f5 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e33:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e36:	8d 83 c9 d3 fe ff    	lea    -0x12c37(%ebx),%eax
f0102e3c:	50                   	push   %eax
f0102e3d:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102e43:	50                   	push   %eax
f0102e44:	68 7d 03 00 00       	push   $0x37d
f0102e49:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102e4f:	50                   	push   %eax
f0102e50:	e8 a0 d2 ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e55:	52                   	push   %edx
f0102e56:	89 cb                	mov    %ecx,%ebx
f0102e58:	8d 81 b0 d5 fe ff    	lea    -0x12a50(%ecx),%eax
f0102e5e:	50                   	push   %eax
f0102e5f:	6a 52                	push   $0x52
f0102e61:	8d 81 d8 d2 fe ff    	lea    -0x12d28(%ecx),%eax
f0102e67:	50                   	push   %eax
f0102e68:	e8 88 d2 ff ff       	call   f01000f5 <_panic>
f0102e6d:	52                   	push   %edx
f0102e6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e71:	8d 83 b0 d5 fe ff    	lea    -0x12a50(%ebx),%eax
f0102e77:	50                   	push   %eax
f0102e78:	6a 52                	push   $0x52
f0102e7a:	8d 83 d8 d2 fe ff    	lea    -0x12d28(%ebx),%eax
f0102e80:	50                   	push   %eax
f0102e81:	e8 6f d2 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 1);
f0102e86:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e89:	8d 83 9a d4 fe ff    	lea    -0x12b66(%ebx),%eax
f0102e8f:	50                   	push   %eax
f0102e90:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102e96:	50                   	push   %eax
f0102e97:	68 82 03 00 00       	push   $0x382
f0102e9c:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102ea2:	50                   	push   %eax
f0102ea3:	e8 4d d2 ff ff       	call   f01000f5 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ea8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eab:	8d 83 bc dc fe ff    	lea    -0x12344(%ebx),%eax
f0102eb1:	50                   	push   %eax
f0102eb2:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102eb8:	50                   	push   %eax
f0102eb9:	68 83 03 00 00       	push   $0x383
f0102ebe:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102ec4:	50                   	push   %eax
f0102ec5:	e8 2b d2 ff ff       	call   f01000f5 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102eca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ecd:	8d 83 e0 dc fe ff    	lea    -0x12320(%ebx),%eax
f0102ed3:	50                   	push   %eax
f0102ed4:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102eda:	50                   	push   %eax
f0102edb:	68 85 03 00 00       	push   $0x385
f0102ee0:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102ee6:	50                   	push   %eax
f0102ee7:	e8 09 d2 ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 1);
f0102eec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eef:	8d 83 bc d4 fe ff    	lea    -0x12b44(%ebx),%eax
f0102ef5:	50                   	push   %eax
f0102ef6:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102efc:	50                   	push   %eax
f0102efd:	68 86 03 00 00       	push   $0x386
f0102f02:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102f08:	50                   	push   %eax
f0102f09:	e8 e7 d1 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 0);
f0102f0e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f11:	8d 83 26 d5 fe ff    	lea    -0x12ada(%ebx),%eax
f0102f17:	50                   	push   %eax
f0102f18:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102f1e:	50                   	push   %eax
f0102f1f:	68 87 03 00 00       	push   $0x387
f0102f24:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102f2a:	50                   	push   %eax
f0102f2b:	e8 c5 d1 ff ff       	call   f01000f5 <_panic>
f0102f30:	52                   	push   %edx
f0102f31:	89 cb                	mov    %ecx,%ebx
f0102f33:	8d 81 b0 d5 fe ff    	lea    -0x12a50(%ecx),%eax
f0102f39:	50                   	push   %eax
f0102f3a:	6a 52                	push   $0x52
f0102f3c:	8d 81 d8 d2 fe ff    	lea    -0x12d28(%ecx),%eax
f0102f42:	50                   	push   %eax
f0102f43:	e8 ad d1 ff ff       	call   f01000f5 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f48:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f4b:	8d 83 04 dd fe ff    	lea    -0x122fc(%ebx),%eax
f0102f51:	50                   	push   %eax
f0102f52:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102f58:	50                   	push   %eax
f0102f59:	68 89 03 00 00       	push   $0x389
f0102f5e:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102f64:	50                   	push   %eax
f0102f65:	e8 8b d1 ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 0);
f0102f6a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f6d:	8d 83 f4 d4 fe ff    	lea    -0x12b0c(%ebx),%eax
f0102f73:	50                   	push   %eax
f0102f74:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102f7a:	50                   	push   %eax
f0102f7b:	68 8b 03 00 00       	push   $0x38b
f0102f80:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102f86:	50                   	push   %eax
f0102f87:	e8 69 d1 ff ff       	call   f01000f5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f8f:	8d 83 48 d8 fe ff    	lea    -0x127b8(%ebx),%eax
f0102f95:	50                   	push   %eax
f0102f96:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102f9c:	50                   	push   %eax
f0102f9d:	68 8e 03 00 00       	push   $0x38e
f0102fa2:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102fa8:	50                   	push   %eax
f0102fa9:	e8 47 d1 ff ff       	call   f01000f5 <_panic>
	assert(pp0->pp_ref == 1);
f0102fae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fb1:	8d 83 ab d4 fe ff    	lea    -0x12b55(%ebx),%eax
f0102fb7:	50                   	push   %eax
f0102fb8:	8d 83 f2 d2 fe ff    	lea    -0x12d0e(%ebx),%eax
f0102fbe:	50                   	push   %eax
f0102fbf:	68 90 03 00 00       	push   $0x390
f0102fc4:	8d 83 cc d2 fe ff    	lea    -0x12d34(%ebx),%eax
f0102fca:	50                   	push   %eax
f0102fcb:	e8 25 d1 ff ff       	call   f01000f5 <_panic>

f0102fd0 <tlb_invalidate>:
{
f0102fd0:	55                   	push   %ebp
f0102fd1:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fd6:	0f 01 38             	invlpg (%eax)
}
f0102fd9:	5d                   	pop    %ebp
f0102fda:	c3                   	ret    

f0102fdb <__x86.get_pc_thunk.dx>:
f0102fdb:	8b 14 24             	mov    (%esp),%edx
f0102fde:	c3                   	ret    

f0102fdf <__x86.get_pc_thunk.cx>:
f0102fdf:	8b 0c 24             	mov    (%esp),%ecx
f0102fe2:	c3                   	ret    

f0102fe3 <__x86.get_pc_thunk.di>:
f0102fe3:	8b 3c 24             	mov    (%esp),%edi
f0102fe6:	c3                   	ret    

f0102fe7 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102fe7:	55                   	push   %ebp
f0102fe8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102fea:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fed:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ff2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102ff3:	ba 71 00 00 00       	mov    $0x71,%edx
f0102ff8:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102ff9:	0f b6 c0             	movzbl %al,%eax
}
f0102ffc:	5d                   	pop    %ebp
f0102ffd:	c3                   	ret    

f0102ffe <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102ffe:	55                   	push   %ebp
f0102fff:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103001:	8b 45 08             	mov    0x8(%ebp),%eax
f0103004:	ba 70 00 00 00       	mov    $0x70,%edx
f0103009:	ee                   	out    %al,(%dx)
f010300a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010300d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103012:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103013:	5d                   	pop    %ebp
f0103014:	c3                   	ret    

f0103015 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103015:	55                   	push   %ebp
f0103016:	89 e5                	mov    %esp,%ebp
f0103018:	56                   	push   %esi
f0103019:	53                   	push   %ebx
f010301a:	e8 8c d1 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f010301f:	81 c3 ed 42 01 00    	add    $0x142ed,%ebx
f0103025:	8b 75 0c             	mov    0xc(%ebp),%esi
	cputchar(ch);
f0103028:	83 ec 0c             	sub    $0xc,%esp
f010302b:	ff 75 08             	push   0x8(%ebp)
f010302e:	e8 e5 d6 ff ff       	call   f0100718 <cputchar>
	(*cnt)++;
f0103033:	83 06 01             	addl   $0x1,(%esi)
}
f0103036:	83 c4 10             	add    $0x10,%esp
f0103039:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010303c:	5b                   	pop    %ebx
f010303d:	5e                   	pop    %esi
f010303e:	5d                   	pop    %ebp
f010303f:	c3                   	ret    

f0103040 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103040:	55                   	push   %ebp
f0103041:	89 e5                	mov    %esp,%ebp
f0103043:	53                   	push   %ebx
f0103044:	83 ec 14             	sub    $0x14,%esp
f0103047:	e8 5f d1 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f010304c:	81 c3 c0 42 01 00    	add    $0x142c0,%ebx
	int cnt = 0;
f0103052:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103059:	ff 75 0c             	push   0xc(%ebp)
f010305c:	ff 75 08             	push   0x8(%ebp)
f010305f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103062:	50                   	push   %eax
f0103063:	8d 83 09 bd fe ff    	lea    -0x142f7(%ebx),%eax
f0103069:	50                   	push   %eax
f010306a:	e8 5b 04 00 00       	call   f01034ca <vprintfmt>
	return cnt;
}
f010306f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103072:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103075:	c9                   	leave  
f0103076:	c3                   	ret    

f0103077 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103077:	55                   	push   %ebp
f0103078:	89 e5                	mov    %esp,%ebp
f010307a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010307d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103080:	50                   	push   %eax
f0103081:	ff 75 08             	push   0x8(%ebp)
f0103084:	e8 b7 ff ff ff       	call   f0103040 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103089:	c9                   	leave  
f010308a:	c3                   	ret    

f010308b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010308b:	55                   	push   %ebp
f010308c:	89 e5                	mov    %esp,%ebp
f010308e:	57                   	push   %edi
f010308f:	56                   	push   %esi
f0103090:	53                   	push   %ebx
f0103091:	83 ec 14             	sub    $0x14,%esp
f0103094:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103097:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010309a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010309d:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01030a0:	8b 1a                	mov    (%edx),%ebx
f01030a2:	8b 01                	mov    (%ecx),%eax
f01030a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01030a7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01030ae:	eb 2f                	jmp    f01030df <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01030b0:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01030b3:	39 c3                	cmp    %eax,%ebx
f01030b5:	7f 4e                	jg     f0103105 <stab_binsearch+0x7a>
f01030b7:	0f b6 0a             	movzbl (%edx),%ecx
f01030ba:	83 ea 0c             	sub    $0xc,%edx
f01030bd:	39 f1                	cmp    %esi,%ecx
f01030bf:	75 ef                	jne    f01030b0 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01030c1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01030c4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01030c7:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01030cb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01030ce:	73 3a                	jae    f010310a <stab_binsearch+0x7f>
			*region_left = m;
f01030d0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01030d3:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01030d5:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f01030d8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01030df:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01030e2:	7f 53                	jg     f0103137 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f01030e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01030e7:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f01030ea:	89 d0                	mov    %edx,%eax
f01030ec:	c1 e8 1f             	shr    $0x1f,%eax
f01030ef:	01 d0                	add    %edx,%eax
f01030f1:	89 c7                	mov    %eax,%edi
f01030f3:	d1 ff                	sar    %edi
f01030f5:	83 e0 fe             	and    $0xfffffffe,%eax
f01030f8:	01 f8                	add    %edi,%eax
f01030fa:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01030fd:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103101:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0103103:	eb ae                	jmp    f01030b3 <stab_binsearch+0x28>
			l = true_m + 1;
f0103105:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103108:	eb d5                	jmp    f01030df <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010310a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010310d:	76 14                	jbe    f0103123 <stab_binsearch+0x98>
			*region_right = m - 1;
f010310f:	83 e8 01             	sub    $0x1,%eax
f0103112:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103115:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103118:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f010311a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103121:	eb bc                	jmp    f01030df <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103123:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103126:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103128:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010312c:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010312e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103135:	eb a8                	jmp    f01030df <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103137:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010313b:	75 15                	jne    f0103152 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010313d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103140:	8b 00                	mov    (%eax),%eax
f0103142:	83 e8 01             	sub    $0x1,%eax
f0103145:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103148:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010314a:	83 c4 14             	add    $0x14,%esp
f010314d:	5b                   	pop    %ebx
f010314e:	5e                   	pop    %esi
f010314f:	5f                   	pop    %edi
f0103150:	5d                   	pop    %ebp
f0103151:	c3                   	ret    
		for (l = *region_right;
f0103152:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103155:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103157:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010315a:	8b 0f                	mov    (%edi),%ecx
f010315c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010315f:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0103162:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0103166:	39 c1                	cmp    %eax,%ecx
f0103168:	7d 0f                	jge    f0103179 <stab_binsearch+0xee>
f010316a:	0f b6 1a             	movzbl (%edx),%ebx
f010316d:	83 ea 0c             	sub    $0xc,%edx
f0103170:	39 f3                	cmp    %esi,%ebx
f0103172:	74 05                	je     f0103179 <stab_binsearch+0xee>
		     l--)
f0103174:	83 e8 01             	sub    $0x1,%eax
f0103177:	eb ed                	jmp    f0103166 <stab_binsearch+0xdb>
		*region_left = l;
f0103179:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010317c:	89 07                	mov    %eax,(%edi)
}
f010317e:	eb ca                	jmp    f010314a <stab_binsearch+0xbf>

f0103180 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103180:	55                   	push   %ebp
f0103181:	89 e5                	mov    %esp,%ebp
f0103183:	57                   	push   %edi
f0103184:	56                   	push   %esi
f0103185:	53                   	push   %ebx
f0103186:	83 ec 3c             	sub    $0x3c,%esp
f0103189:	e8 1d d0 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f010318e:	81 c3 7e 41 01 00    	add    $0x1417e,%ebx
f0103194:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103197:	8d 83 59 dd fe ff    	lea    -0x122a7(%ebx),%eax
f010319d:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f010319f:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01031a6:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f01031a9:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01031b0:	8b 45 08             	mov    0x8(%ebp),%eax
f01031b3:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f01031b6:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01031bd:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01031c2:	0f 86 44 01 00 00    	jbe    f010330c <debuginfo_eip+0x18c>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01031c8:	c7 c0 71 b8 10 f0    	mov    $0xf010b871,%eax
f01031ce:	39 83 f8 ff ff ff    	cmp    %eax,-0x8(%ebx)
f01031d4:	0f 86 d6 01 00 00    	jbe    f01033b0 <debuginfo_eip+0x230>
f01031da:	c7 c0 0a d6 10 f0    	mov    $0xf010d60a,%eax
f01031e0:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01031e4:	0f 85 cd 01 00 00    	jne    f01033b7 <debuginfo_eip+0x237>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01031ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01031f1:	c7 c0 7c 52 10 f0    	mov    $0xf010527c,%eax
f01031f7:	c7 c2 70 b8 10 f0    	mov    $0xf010b870,%edx
f01031fd:	29 c2                	sub    %eax,%edx
f01031ff:	c1 fa 02             	sar    $0x2,%edx
f0103202:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103208:	83 ea 01             	sub    $0x1,%edx
f010320b:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010320e:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103211:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103214:	83 ec 08             	sub    $0x8,%esp
f0103217:	ff 75 08             	push   0x8(%ebp)
f010321a:	6a 64                	push   $0x64
f010321c:	e8 6a fe ff ff       	call   f010308b <stab_binsearch>
	if (lfile == 0)
f0103221:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103224:	83 c4 10             	add    $0x10,%esp
f0103227:	85 ff                	test   %edi,%edi
f0103229:	0f 84 8f 01 00 00    	je     f01033be <debuginfo_eip+0x23e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010322f:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f0103232:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103235:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103238:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010323b:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010323e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103241:	83 ec 08             	sub    $0x8,%esp
f0103244:	ff 75 08             	push   0x8(%ebp)
f0103247:	6a 24                	push   $0x24
f0103249:	c7 c0 7c 52 10 f0    	mov    $0xf010527c,%eax
f010324f:	e8 37 fe ff ff       	call   f010308b <stab_binsearch>

	if (lfun <= rfun) {
f0103254:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103257:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f010325a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010325d:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103260:	83 c4 10             	add    $0x10,%esp
f0103263:	89 f8                	mov    %edi,%eax
f0103265:	39 d1                	cmp    %edx,%ecx
f0103267:	7f 39                	jg     f01032a2 <debuginfo_eip+0x122>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103269:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f010326c:	c7 c2 7c 52 10 f0    	mov    $0xf010527c,%edx
f0103272:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0103275:	8b 11                	mov    (%ecx),%edx
f0103277:	c7 c0 0a d6 10 f0    	mov    $0xf010d60a,%eax
f010327d:	81 e8 71 b8 10 f0    	sub    $0xf010b871,%eax
f0103283:	39 c2                	cmp    %eax,%edx
f0103285:	73 09                	jae    f0103290 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103287:	81 c2 71 b8 10 f0    	add    $0xf010b871,%edx
f010328d:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103290:	8b 41 08             	mov    0x8(%ecx),%eax
f0103293:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f0103296:	29 45 08             	sub    %eax,0x8(%ebp)
f0103299:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010329c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f010329f:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f01032a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01032a5:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01032a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01032ab:	83 ec 08             	sub    $0x8,%esp
f01032ae:	6a 3a                	push   $0x3a
f01032b0:	ff 76 08             	push   0x8(%esi)
f01032b3:	e8 a3 09 00 00       	call   f0103c5b <strfind>
f01032b8:	2b 46 08             	sub    0x8(%esi),%eax
f01032bb:	89 46 0c             	mov    %eax,0xc(%esi)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01032be:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01032c1:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01032c4:	83 c4 08             	add    $0x8,%esp
f01032c7:	ff 75 08             	push   0x8(%ebp)
f01032ca:	6a 44                	push   $0x44
f01032cc:	c7 c0 7c 52 10 f0    	mov    $0xf010527c,%eax
f01032d2:	e8 b4 fd ff ff       	call   f010308b <stab_binsearch>
	if (lline <= rline) {
f01032d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032da:	83 c4 10             	add    $0x10,%esp
		info->eip_line = stabs[lline].n_desc;
	} else {
		info->eip_line = -1;
f01032dd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	if (lline <= rline) {
f01032e2:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01032e5:	7f 0e                	jg     f01032f5 <debuginfo_eip+0x175>
		info->eip_line = stabs[lline].n_desc;
f01032e7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01032ea:	c7 c1 7c 52 10 f0    	mov    $0xf010527c,%ecx
f01032f0:	0f b7 54 91 06       	movzwl 0x6(%ecx,%edx,4),%edx
f01032f5:	89 56 04             	mov    %edx,0x4(%esi)
f01032f8:	89 c2                	mov    %eax,%edx
f01032fa:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01032fd:	c7 c0 7c 52 10 f0    	mov    $0xf010527c,%eax
f0103303:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0103307:	89 75 0c             	mov    %esi,0xc(%ebp)
f010330a:	eb 1e                	jmp    f010332a <debuginfo_eip+0x1aa>
  	        panic("User address");
f010330c:	83 ec 04             	sub    $0x4,%esp
f010330f:	8d 83 63 dd fe ff    	lea    -0x1229d(%ebx),%eax
f0103315:	50                   	push   %eax
f0103316:	6a 7f                	push   $0x7f
f0103318:	8d 83 70 dd fe ff    	lea    -0x12290(%ebx),%eax
f010331e:	50                   	push   %eax
f010331f:	e8 d1 cd ff ff       	call   f01000f5 <_panic>
f0103324:	83 ea 01             	sub    $0x1,%edx
f0103327:	83 e8 0c             	sub    $0xc,%eax
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010332a:	39 d7                	cmp    %edx,%edi
f010332c:	7f 3c                	jg     f010336a <debuginfo_eip+0x1ea>
	       && stabs[lline].n_type != N_SOL
f010332e:	0f b6 08             	movzbl (%eax),%ecx
f0103331:	80 f9 84             	cmp    $0x84,%cl
f0103334:	74 0b                	je     f0103341 <debuginfo_eip+0x1c1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103336:	80 f9 64             	cmp    $0x64,%cl
f0103339:	75 e9                	jne    f0103324 <debuginfo_eip+0x1a4>
f010333b:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f010333f:	74 e3                	je     f0103324 <debuginfo_eip+0x1a4>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103341:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103344:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103347:	c7 c0 7c 52 10 f0    	mov    $0xf010527c,%eax
f010334d:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103350:	c7 c0 0a d6 10 f0    	mov    $0xf010d60a,%eax
f0103356:	81 e8 71 b8 10 f0    	sub    $0xf010b871,%eax
f010335c:	39 c2                	cmp    %eax,%edx
f010335e:	73 0d                	jae    f010336d <debuginfo_eip+0x1ed>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103360:	81 c2 71 b8 10 f0    	add    $0xf010b871,%edx
f0103366:	89 16                	mov    %edx,(%esi)
f0103368:	eb 03                	jmp    f010336d <debuginfo_eip+0x1ed>
f010336a:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010336d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103372:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103375:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103378:	39 cf                	cmp    %ecx,%edi
f010337a:	7d 4e                	jge    f01033ca <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
f010337c:	83 c7 01             	add    $0x1,%edi
f010337f:	89 f8                	mov    %edi,%eax
f0103381:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f0103384:	c7 c2 7c 52 10 f0    	mov    $0xf010527c,%edx
f010338a:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f010338e:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0103391:	eb 04                	jmp    f0103397 <debuginfo_eip+0x217>
			info->eip_fn_narg++;
f0103393:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103397:	39 c3                	cmp    %eax,%ebx
f0103399:	7e 2a                	jle    f01033c5 <debuginfo_eip+0x245>
f010339b:	0f b6 0a             	movzbl (%edx),%ecx
f010339e:	83 c0 01             	add    $0x1,%eax
f01033a1:	83 c2 0c             	add    $0xc,%edx
f01033a4:	80 f9 a0             	cmp    $0xa0,%cl
f01033a7:	74 ea                	je     f0103393 <debuginfo_eip+0x213>
	return 0;
f01033a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01033ae:	eb 1a                	jmp    f01033ca <debuginfo_eip+0x24a>
		return -1;
f01033b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01033b5:	eb 13                	jmp    f01033ca <debuginfo_eip+0x24a>
f01033b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01033bc:	eb 0c                	jmp    f01033ca <debuginfo_eip+0x24a>
		return -1;
f01033be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01033c3:	eb 05                	jmp    f01033ca <debuginfo_eip+0x24a>
	return 0;
f01033c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033cd:	5b                   	pop    %ebx
f01033ce:	5e                   	pop    %esi
f01033cf:	5f                   	pop    %edi
f01033d0:	5d                   	pop    %ebp
f01033d1:	c3                   	ret    

f01033d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01033d2:	55                   	push   %ebp
f01033d3:	89 e5                	mov    %esp,%ebp
f01033d5:	57                   	push   %edi
f01033d6:	56                   	push   %esi
f01033d7:	53                   	push   %ebx
f01033d8:	83 ec 2c             	sub    $0x2c,%esp
f01033db:	e8 ff fb ff ff       	call   f0102fdf <__x86.get_pc_thunk.cx>
f01033e0:	81 c1 2c 3f 01 00    	add    $0x13f2c,%ecx
f01033e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01033e9:	89 c7                	mov    %eax,%edi
f01033eb:	89 d6                	mov    %edx,%esi
f01033ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01033f0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033f3:	89 d1                	mov    %edx,%ecx
f01033f5:	89 c2                	mov    %eax,%edx
f01033f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033fa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01033fd:	8b 45 10             	mov    0x10(%ebp),%eax
f0103400:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103403:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103406:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010340d:	39 c2                	cmp    %eax,%edx
f010340f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103412:	72 41                	jb     f0103455 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103414:	83 ec 0c             	sub    $0xc,%esp
f0103417:	ff 75 18             	push   0x18(%ebp)
f010341a:	83 eb 01             	sub    $0x1,%ebx
f010341d:	53                   	push   %ebx
f010341e:	50                   	push   %eax
f010341f:	83 ec 08             	sub    $0x8,%esp
f0103422:	ff 75 e4             	push   -0x1c(%ebp)
f0103425:	ff 75 e0             	push   -0x20(%ebp)
f0103428:	ff 75 d4             	push   -0x2c(%ebp)
f010342b:	ff 75 d0             	push   -0x30(%ebp)
f010342e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103431:	e8 3a 0a 00 00       	call   f0103e70 <__udivdi3>
f0103436:	83 c4 18             	add    $0x18,%esp
f0103439:	52                   	push   %edx
f010343a:	50                   	push   %eax
f010343b:	89 f2                	mov    %esi,%edx
f010343d:	89 f8                	mov    %edi,%eax
f010343f:	e8 8e ff ff ff       	call   f01033d2 <printnum>
f0103444:	83 c4 20             	add    $0x20,%esp
f0103447:	eb 13                	jmp    f010345c <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103449:	83 ec 08             	sub    $0x8,%esp
f010344c:	56                   	push   %esi
f010344d:	ff 75 18             	push   0x18(%ebp)
f0103450:	ff d7                	call   *%edi
f0103452:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103455:	83 eb 01             	sub    $0x1,%ebx
f0103458:	85 db                	test   %ebx,%ebx
f010345a:	7f ed                	jg     f0103449 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010345c:	83 ec 08             	sub    $0x8,%esp
f010345f:	56                   	push   %esi
f0103460:	83 ec 04             	sub    $0x4,%esp
f0103463:	ff 75 e4             	push   -0x1c(%ebp)
f0103466:	ff 75 e0             	push   -0x20(%ebp)
f0103469:	ff 75 d4             	push   -0x2c(%ebp)
f010346c:	ff 75 d0             	push   -0x30(%ebp)
f010346f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103472:	e8 19 0b 00 00       	call   f0103f90 <__umoddi3>
f0103477:	83 c4 14             	add    $0x14,%esp
f010347a:	0f be 84 03 7e dd fe 	movsbl -0x12282(%ebx,%eax,1),%eax
f0103481:	ff 
f0103482:	50                   	push   %eax
f0103483:	ff d7                	call   *%edi
}
f0103485:	83 c4 10             	add    $0x10,%esp
f0103488:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010348b:	5b                   	pop    %ebx
f010348c:	5e                   	pop    %esi
f010348d:	5f                   	pop    %edi
f010348e:	5d                   	pop    %ebp
f010348f:	c3                   	ret    

f0103490 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103490:	55                   	push   %ebp
f0103491:	89 e5                	mov    %esp,%ebp
f0103493:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103496:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010349a:	8b 10                	mov    (%eax),%edx
f010349c:	3b 50 04             	cmp    0x4(%eax),%edx
f010349f:	73 0a                	jae    f01034ab <sprintputch+0x1b>
		*b->buf++ = ch;
f01034a1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01034a4:	89 08                	mov    %ecx,(%eax)
f01034a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01034a9:	88 02                	mov    %al,(%edx)
}
f01034ab:	5d                   	pop    %ebp
f01034ac:	c3                   	ret    

f01034ad <printfmt>:
{
f01034ad:	55                   	push   %ebp
f01034ae:	89 e5                	mov    %esp,%ebp
f01034b0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01034b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01034b6:	50                   	push   %eax
f01034b7:	ff 75 10             	push   0x10(%ebp)
f01034ba:	ff 75 0c             	push   0xc(%ebp)
f01034bd:	ff 75 08             	push   0x8(%ebp)
f01034c0:	e8 05 00 00 00       	call   f01034ca <vprintfmt>
}
f01034c5:	83 c4 10             	add    $0x10,%esp
f01034c8:	c9                   	leave  
f01034c9:	c3                   	ret    

f01034ca <vprintfmt>:
{
f01034ca:	55                   	push   %ebp
f01034cb:	89 e5                	mov    %esp,%ebp
f01034cd:	57                   	push   %edi
f01034ce:	56                   	push   %esi
f01034cf:	53                   	push   %ebx
f01034d0:	83 ec 3c             	sub    $0x3c,%esp
f01034d3:	e8 67 d2 ff ff       	call   f010073f <__x86.get_pc_thunk.ax>
f01034d8:	05 34 3e 01 00       	add    $0x13e34,%eax
f01034dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01034e0:	8b 75 08             	mov    0x8(%ebp),%esi
f01034e3:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01034e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01034e9:	8d 80 38 1d 00 00    	lea    0x1d38(%eax),%eax
f01034ef:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01034f2:	eb 0a                	jmp    f01034fe <vprintfmt+0x34>
			putch(ch, putdat);
f01034f4:	83 ec 08             	sub    $0x8,%esp
f01034f7:	57                   	push   %edi
f01034f8:	50                   	push   %eax
f01034f9:	ff d6                	call   *%esi
f01034fb:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01034fe:	83 c3 01             	add    $0x1,%ebx
f0103501:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103505:	83 f8 25             	cmp    $0x25,%eax
f0103508:	74 0c                	je     f0103516 <vprintfmt+0x4c>
			if (ch == '\0')
f010350a:	85 c0                	test   %eax,%eax
f010350c:	75 e6                	jne    f01034f4 <vprintfmt+0x2a>
}
f010350e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103511:	5b                   	pop    %ebx
f0103512:	5e                   	pop    %esi
f0103513:	5f                   	pop    %edi
f0103514:	5d                   	pop    %ebp
f0103515:	c3                   	ret    
		padc = ' ';
f0103516:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f010351a:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0103521:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0103528:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f010352f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103534:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103537:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010353a:	8d 43 01             	lea    0x1(%ebx),%eax
f010353d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103540:	0f b6 13             	movzbl (%ebx),%edx
f0103543:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103546:	3c 55                	cmp    $0x55,%al
f0103548:	0f 87 fd 03 00 00    	ja     f010394b <.L20>
f010354e:	0f b6 c0             	movzbl %al,%eax
f0103551:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103554:	89 ce                	mov    %ecx,%esi
f0103556:	03 b4 81 08 de fe ff 	add    -0x121f8(%ecx,%eax,4),%esi
f010355d:	ff e6                	jmp    *%esi

f010355f <.L68>:
f010355f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0103562:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0103566:	eb d2                	jmp    f010353a <vprintfmt+0x70>

f0103568 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0103568:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010356b:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f010356f:	eb c9                	jmp    f010353a <vprintfmt+0x70>

f0103571 <.L31>:
f0103571:	0f b6 d2             	movzbl %dl,%edx
f0103574:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0103577:	b8 00 00 00 00       	mov    $0x0,%eax
f010357c:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f010357f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103582:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103586:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0103589:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010358c:	83 f9 09             	cmp    $0x9,%ecx
f010358f:	77 58                	ja     f01035e9 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0103591:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0103594:	eb e9                	jmp    f010357f <.L31+0xe>

f0103596 <.L34>:
			precision = va_arg(ap, int);
f0103596:	8b 45 14             	mov    0x14(%ebp),%eax
f0103599:	8b 00                	mov    (%eax),%eax
f010359b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010359e:	8b 45 14             	mov    0x14(%ebp),%eax
f01035a1:	8d 40 04             	lea    0x4(%eax),%eax
f01035a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01035a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01035aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01035ae:	79 8a                	jns    f010353a <vprintfmt+0x70>
				width = precision, precision = -1;
f01035b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01035b6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01035bd:	e9 78 ff ff ff       	jmp    f010353a <vprintfmt+0x70>

f01035c2 <.L33>:
f01035c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01035c5:	85 d2                	test   %edx,%edx
f01035c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01035cc:	0f 49 c2             	cmovns %edx,%eax
f01035cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01035d2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01035d5:	e9 60 ff ff ff       	jmp    f010353a <vprintfmt+0x70>

f01035da <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01035da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01035dd:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01035e4:	e9 51 ff ff ff       	jmp    f010353a <vprintfmt+0x70>
f01035e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01035ec:	89 75 08             	mov    %esi,0x8(%ebp)
f01035ef:	eb b9                	jmp    f01035aa <.L34+0x14>

f01035f1 <.L27>:
			lflag++;
f01035f1:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01035f5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01035f8:	e9 3d ff ff ff       	jmp    f010353a <vprintfmt+0x70>

f01035fd <.L30>:
			putch(va_arg(ap, int), putdat);
f01035fd:	8b 75 08             	mov    0x8(%ebp),%esi
f0103600:	8b 45 14             	mov    0x14(%ebp),%eax
f0103603:	8d 58 04             	lea    0x4(%eax),%ebx
f0103606:	83 ec 08             	sub    $0x8,%esp
f0103609:	57                   	push   %edi
f010360a:	ff 30                	push   (%eax)
f010360c:	ff d6                	call   *%esi
			break;
f010360e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103611:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0103614:	e9 c8 02 00 00       	jmp    f01038e1 <.L25+0x45>

f0103619 <.L28>:
			err = va_arg(ap, int);
f0103619:	8b 75 08             	mov    0x8(%ebp),%esi
f010361c:	8b 45 14             	mov    0x14(%ebp),%eax
f010361f:	8d 58 04             	lea    0x4(%eax),%ebx
f0103622:	8b 10                	mov    (%eax),%edx
f0103624:	89 d0                	mov    %edx,%eax
f0103626:	f7 d8                	neg    %eax
f0103628:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010362b:	83 f8 06             	cmp    $0x6,%eax
f010362e:	7f 27                	jg     f0103657 <.L28+0x3e>
f0103630:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103633:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0103636:	85 d2                	test   %edx,%edx
f0103638:	74 1d                	je     f0103657 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f010363a:	52                   	push   %edx
f010363b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010363e:	8d 80 04 d3 fe ff    	lea    -0x12cfc(%eax),%eax
f0103644:	50                   	push   %eax
f0103645:	57                   	push   %edi
f0103646:	56                   	push   %esi
f0103647:	e8 61 fe ff ff       	call   f01034ad <printfmt>
f010364c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010364f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0103652:	e9 8a 02 00 00       	jmp    f01038e1 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0103657:	50                   	push   %eax
f0103658:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010365b:	8d 80 96 dd fe ff    	lea    -0x1226a(%eax),%eax
f0103661:	50                   	push   %eax
f0103662:	57                   	push   %edi
f0103663:	56                   	push   %esi
f0103664:	e8 44 fe ff ff       	call   f01034ad <printfmt>
f0103669:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010366c:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010366f:	e9 6d 02 00 00       	jmp    f01038e1 <.L25+0x45>

f0103674 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f0103674:	8b 75 08             	mov    0x8(%ebp),%esi
f0103677:	8b 45 14             	mov    0x14(%ebp),%eax
f010367a:	83 c0 04             	add    $0x4,%eax
f010367d:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103680:	8b 45 14             	mov    0x14(%ebp),%eax
f0103683:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0103685:	85 d2                	test   %edx,%edx
f0103687:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010368a:	8d 80 8f dd fe ff    	lea    -0x12271(%eax),%eax
f0103690:	0f 45 c2             	cmovne %edx,%eax
f0103693:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f0103696:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010369a:	7e 06                	jle    f01036a2 <.L24+0x2e>
f010369c:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01036a0:	75 0d                	jne    f01036af <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01036a2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01036a5:	89 c3                	mov    %eax,%ebx
f01036a7:	03 45 d4             	add    -0x2c(%ebp),%eax
f01036aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01036ad:	eb 58                	jmp    f0103707 <.L24+0x93>
f01036af:	83 ec 08             	sub    $0x8,%esp
f01036b2:	ff 75 d8             	push   -0x28(%ebp)
f01036b5:	ff 75 c8             	push   -0x38(%ebp)
f01036b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01036bb:	e8 44 04 00 00       	call   f0103b04 <strnlen>
f01036c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01036c3:	29 c2                	sub    %eax,%edx
f01036c5:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01036c8:	83 c4 10             	add    $0x10,%esp
f01036cb:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01036cd:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01036d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01036d4:	eb 0f                	jmp    f01036e5 <.L24+0x71>
					putch(padc, putdat);
f01036d6:	83 ec 08             	sub    $0x8,%esp
f01036d9:	57                   	push   %edi
f01036da:	ff 75 d4             	push   -0x2c(%ebp)
f01036dd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01036df:	83 eb 01             	sub    $0x1,%ebx
f01036e2:	83 c4 10             	add    $0x10,%esp
f01036e5:	85 db                	test   %ebx,%ebx
f01036e7:	7f ed                	jg     f01036d6 <.L24+0x62>
f01036e9:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01036ec:	85 d2                	test   %edx,%edx
f01036ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01036f3:	0f 49 c2             	cmovns %edx,%eax
f01036f6:	29 c2                	sub    %eax,%edx
f01036f8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01036fb:	eb a5                	jmp    f01036a2 <.L24+0x2e>
					putch(ch, putdat);
f01036fd:	83 ec 08             	sub    $0x8,%esp
f0103700:	57                   	push   %edi
f0103701:	52                   	push   %edx
f0103702:	ff d6                	call   *%esi
f0103704:	83 c4 10             	add    $0x10,%esp
f0103707:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010370a:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010370c:	83 c3 01             	add    $0x1,%ebx
f010370f:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0103713:	0f be d0             	movsbl %al,%edx
f0103716:	85 d2                	test   %edx,%edx
f0103718:	74 4b                	je     f0103765 <.L24+0xf1>
f010371a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010371e:	78 06                	js     f0103726 <.L24+0xb2>
f0103720:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0103724:	78 1e                	js     f0103744 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0103726:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010372a:	74 d1                	je     f01036fd <.L24+0x89>
f010372c:	0f be c0             	movsbl %al,%eax
f010372f:	83 e8 20             	sub    $0x20,%eax
f0103732:	83 f8 5e             	cmp    $0x5e,%eax
f0103735:	76 c6                	jbe    f01036fd <.L24+0x89>
					putch('?', putdat);
f0103737:	83 ec 08             	sub    $0x8,%esp
f010373a:	57                   	push   %edi
f010373b:	6a 3f                	push   $0x3f
f010373d:	ff d6                	call   *%esi
f010373f:	83 c4 10             	add    $0x10,%esp
f0103742:	eb c3                	jmp    f0103707 <.L24+0x93>
f0103744:	89 cb                	mov    %ecx,%ebx
f0103746:	eb 0e                	jmp    f0103756 <.L24+0xe2>
				putch(' ', putdat);
f0103748:	83 ec 08             	sub    $0x8,%esp
f010374b:	57                   	push   %edi
f010374c:	6a 20                	push   $0x20
f010374e:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0103750:	83 eb 01             	sub    $0x1,%ebx
f0103753:	83 c4 10             	add    $0x10,%esp
f0103756:	85 db                	test   %ebx,%ebx
f0103758:	7f ee                	jg     f0103748 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010375a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010375d:	89 45 14             	mov    %eax,0x14(%ebp)
f0103760:	e9 7c 01 00 00       	jmp    f01038e1 <.L25+0x45>
f0103765:	89 cb                	mov    %ecx,%ebx
f0103767:	eb ed                	jmp    f0103756 <.L24+0xe2>

f0103769 <.L29>:
	if (lflag >= 2)
f0103769:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010376c:	8b 75 08             	mov    0x8(%ebp),%esi
f010376f:	83 f9 01             	cmp    $0x1,%ecx
f0103772:	7f 1b                	jg     f010378f <.L29+0x26>
	else if (lflag)
f0103774:	85 c9                	test   %ecx,%ecx
f0103776:	74 63                	je     f01037db <.L29+0x72>
		return va_arg(*ap, long);
f0103778:	8b 45 14             	mov    0x14(%ebp),%eax
f010377b:	8b 00                	mov    (%eax),%eax
f010377d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103780:	99                   	cltd   
f0103781:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103784:	8b 45 14             	mov    0x14(%ebp),%eax
f0103787:	8d 40 04             	lea    0x4(%eax),%eax
f010378a:	89 45 14             	mov    %eax,0x14(%ebp)
f010378d:	eb 17                	jmp    f01037a6 <.L29+0x3d>
		return va_arg(*ap, long long);
f010378f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103792:	8b 50 04             	mov    0x4(%eax),%edx
f0103795:	8b 00                	mov    (%eax),%eax
f0103797:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010379a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010379d:	8b 45 14             	mov    0x14(%ebp),%eax
f01037a0:	8d 40 08             	lea    0x8(%eax),%eax
f01037a3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01037a6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01037a9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01037ac:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01037b1:	85 db                	test   %ebx,%ebx
f01037b3:	0f 89 0e 01 00 00    	jns    f01038c7 <.L25+0x2b>
				putch('-', putdat);
f01037b9:	83 ec 08             	sub    $0x8,%esp
f01037bc:	57                   	push   %edi
f01037bd:	6a 2d                	push   $0x2d
f01037bf:	ff d6                	call   *%esi
				num = -(long long) num;
f01037c1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01037c4:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01037c7:	f7 d9                	neg    %ecx
f01037c9:	83 d3 00             	adc    $0x0,%ebx
f01037cc:	f7 db                	neg    %ebx
f01037ce:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01037d1:	ba 0a 00 00 00       	mov    $0xa,%edx
f01037d6:	e9 ec 00 00 00       	jmp    f01038c7 <.L25+0x2b>
		return va_arg(*ap, int);
f01037db:	8b 45 14             	mov    0x14(%ebp),%eax
f01037de:	8b 00                	mov    (%eax),%eax
f01037e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037e3:	99                   	cltd   
f01037e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01037e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01037ea:	8d 40 04             	lea    0x4(%eax),%eax
f01037ed:	89 45 14             	mov    %eax,0x14(%ebp)
f01037f0:	eb b4                	jmp    f01037a6 <.L29+0x3d>

f01037f2 <.L23>:
	if (lflag >= 2)
f01037f2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01037f5:	8b 75 08             	mov    0x8(%ebp),%esi
f01037f8:	83 f9 01             	cmp    $0x1,%ecx
f01037fb:	7f 1e                	jg     f010381b <.L23+0x29>
	else if (lflag)
f01037fd:	85 c9                	test   %ecx,%ecx
f01037ff:	74 32                	je     f0103833 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0103801:	8b 45 14             	mov    0x14(%ebp),%eax
f0103804:	8b 08                	mov    (%eax),%ecx
f0103806:	bb 00 00 00 00       	mov    $0x0,%ebx
f010380b:	8d 40 04             	lea    0x4(%eax),%eax
f010380e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103811:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0103816:	e9 ac 00 00 00       	jmp    f01038c7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010381b:	8b 45 14             	mov    0x14(%ebp),%eax
f010381e:	8b 08                	mov    (%eax),%ecx
f0103820:	8b 58 04             	mov    0x4(%eax),%ebx
f0103823:	8d 40 08             	lea    0x8(%eax),%eax
f0103826:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103829:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f010382e:	e9 94 00 00 00       	jmp    f01038c7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103833:	8b 45 14             	mov    0x14(%ebp),%eax
f0103836:	8b 08                	mov    (%eax),%ecx
f0103838:	bb 00 00 00 00       	mov    $0x0,%ebx
f010383d:	8d 40 04             	lea    0x4(%eax),%eax
f0103840:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103843:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0103848:	eb 7d                	jmp    f01038c7 <.L25+0x2b>

f010384a <.L26>:
	if (lflag >= 2)
f010384a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010384d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103850:	83 f9 01             	cmp    $0x1,%ecx
f0103853:	7f 1b                	jg     f0103870 <.L26+0x26>
	else if (lflag)
f0103855:	85 c9                	test   %ecx,%ecx
f0103857:	74 2c                	je     f0103885 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0103859:	8b 45 14             	mov    0x14(%ebp),%eax
f010385c:	8b 08                	mov    (%eax),%ecx
f010385e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103863:	8d 40 04             	lea    0x4(%eax),%eax
f0103866:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103869:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f010386e:	eb 57                	jmp    f01038c7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0103870:	8b 45 14             	mov    0x14(%ebp),%eax
f0103873:	8b 08                	mov    (%eax),%ecx
f0103875:	8b 58 04             	mov    0x4(%eax),%ebx
f0103878:	8d 40 08             	lea    0x8(%eax),%eax
f010387b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010387e:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f0103883:	eb 42                	jmp    f01038c7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103885:	8b 45 14             	mov    0x14(%ebp),%eax
f0103888:	8b 08                	mov    (%eax),%ecx
f010388a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010388f:	8d 40 04             	lea    0x4(%eax),%eax
f0103892:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103895:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f010389a:	eb 2b                	jmp    f01038c7 <.L25+0x2b>

f010389c <.L25>:
			putch('0', putdat);
f010389c:	8b 75 08             	mov    0x8(%ebp),%esi
f010389f:	83 ec 08             	sub    $0x8,%esp
f01038a2:	57                   	push   %edi
f01038a3:	6a 30                	push   $0x30
f01038a5:	ff d6                	call   *%esi
			putch('x', putdat);
f01038a7:	83 c4 08             	add    $0x8,%esp
f01038aa:	57                   	push   %edi
f01038ab:	6a 78                	push   $0x78
f01038ad:	ff d6                	call   *%esi
			num = (unsigned long long)
f01038af:	8b 45 14             	mov    0x14(%ebp),%eax
f01038b2:	8b 08                	mov    (%eax),%ecx
f01038b4:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f01038b9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01038bc:	8d 40 04             	lea    0x4(%eax),%eax
f01038bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01038c2:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f01038c7:	83 ec 0c             	sub    $0xc,%esp
f01038ca:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01038ce:	50                   	push   %eax
f01038cf:	ff 75 d4             	push   -0x2c(%ebp)
f01038d2:	52                   	push   %edx
f01038d3:	53                   	push   %ebx
f01038d4:	51                   	push   %ecx
f01038d5:	89 fa                	mov    %edi,%edx
f01038d7:	89 f0                	mov    %esi,%eax
f01038d9:	e8 f4 fa ff ff       	call   f01033d2 <printnum>
			break;
f01038de:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01038e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01038e4:	e9 15 fc ff ff       	jmp    f01034fe <vprintfmt+0x34>

f01038e9 <.L21>:
	if (lflag >= 2)
f01038e9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01038ec:	8b 75 08             	mov    0x8(%ebp),%esi
f01038ef:	83 f9 01             	cmp    $0x1,%ecx
f01038f2:	7f 1b                	jg     f010390f <.L21+0x26>
	else if (lflag)
f01038f4:	85 c9                	test   %ecx,%ecx
f01038f6:	74 2c                	je     f0103924 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f01038f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01038fb:	8b 08                	mov    (%eax),%ecx
f01038fd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103902:	8d 40 04             	lea    0x4(%eax),%eax
f0103905:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103908:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f010390d:	eb b8                	jmp    f01038c7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010390f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103912:	8b 08                	mov    (%eax),%ecx
f0103914:	8b 58 04             	mov    0x4(%eax),%ebx
f0103917:	8d 40 08             	lea    0x8(%eax),%eax
f010391a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010391d:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f0103922:	eb a3                	jmp    f01038c7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0103924:	8b 45 14             	mov    0x14(%ebp),%eax
f0103927:	8b 08                	mov    (%eax),%ecx
f0103929:	bb 00 00 00 00       	mov    $0x0,%ebx
f010392e:	8d 40 04             	lea    0x4(%eax),%eax
f0103931:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103934:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0103939:	eb 8c                	jmp    f01038c7 <.L25+0x2b>

f010393b <.L35>:
			putch(ch, putdat);
f010393b:	8b 75 08             	mov    0x8(%ebp),%esi
f010393e:	83 ec 08             	sub    $0x8,%esp
f0103941:	57                   	push   %edi
f0103942:	6a 25                	push   $0x25
f0103944:	ff d6                	call   *%esi
			break;
f0103946:	83 c4 10             	add    $0x10,%esp
f0103949:	eb 96                	jmp    f01038e1 <.L25+0x45>

f010394b <.L20>:
			putch('%', putdat);
f010394b:	8b 75 08             	mov    0x8(%ebp),%esi
f010394e:	83 ec 08             	sub    $0x8,%esp
f0103951:	57                   	push   %edi
f0103952:	6a 25                	push   $0x25
f0103954:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103956:	83 c4 10             	add    $0x10,%esp
f0103959:	89 d8                	mov    %ebx,%eax
f010395b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010395f:	74 05                	je     f0103966 <.L20+0x1b>
f0103961:	83 e8 01             	sub    $0x1,%eax
f0103964:	eb f5                	jmp    f010395b <.L20+0x10>
f0103966:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103969:	e9 73 ff ff ff       	jmp    f01038e1 <.L25+0x45>

f010396e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010396e:	55                   	push   %ebp
f010396f:	89 e5                	mov    %esp,%ebp
f0103971:	53                   	push   %ebx
f0103972:	83 ec 14             	sub    $0x14,%esp
f0103975:	e8 31 c8 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f010397a:	81 c3 92 39 01 00    	add    $0x13992,%ebx
f0103980:	8b 45 08             	mov    0x8(%ebp),%eax
f0103983:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103986:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103989:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010398d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103990:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103997:	85 c0                	test   %eax,%eax
f0103999:	74 2b                	je     f01039c6 <vsnprintf+0x58>
f010399b:	85 d2                	test   %edx,%edx
f010399d:	7e 27                	jle    f01039c6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010399f:	ff 75 14             	push   0x14(%ebp)
f01039a2:	ff 75 10             	push   0x10(%ebp)
f01039a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01039a8:	50                   	push   %eax
f01039a9:	8d 83 84 c1 fe ff    	lea    -0x13e7c(%ebx),%eax
f01039af:	50                   	push   %eax
f01039b0:	e8 15 fb ff ff       	call   f01034ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01039b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01039b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01039bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039be:	83 c4 10             	add    $0x10,%esp
}
f01039c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039c4:	c9                   	leave  
f01039c5:	c3                   	ret    
		return -E_INVAL;
f01039c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01039cb:	eb f4                	jmp    f01039c1 <vsnprintf+0x53>

f01039cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01039cd:	55                   	push   %ebp
f01039ce:	89 e5                	mov    %esp,%ebp
f01039d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01039d3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01039d6:	50                   	push   %eax
f01039d7:	ff 75 10             	push   0x10(%ebp)
f01039da:	ff 75 0c             	push   0xc(%ebp)
f01039dd:	ff 75 08             	push   0x8(%ebp)
f01039e0:	e8 89 ff ff ff       	call   f010396e <vsnprintf>
	va_end(ap);

	return rc;
}
f01039e5:	c9                   	leave  
f01039e6:	c3                   	ret    

f01039e7 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01039e7:	55                   	push   %ebp
f01039e8:	89 e5                	mov    %esp,%ebp
f01039ea:	57                   	push   %edi
f01039eb:	56                   	push   %esi
f01039ec:	53                   	push   %ebx
f01039ed:	83 ec 1c             	sub    $0x1c,%esp
f01039f0:	e8 b6 c7 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f01039f5:	81 c3 17 39 01 00    	add    $0x13917,%ebx
f01039fb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01039fe:	85 c0                	test   %eax,%eax
f0103a00:	74 13                	je     f0103a15 <readline+0x2e>
		cprintf("%s", prompt);
f0103a02:	83 ec 08             	sub    $0x8,%esp
f0103a05:	50                   	push   %eax
f0103a06:	8d 83 04 d3 fe ff    	lea    -0x12cfc(%ebx),%eax
f0103a0c:	50                   	push   %eax
f0103a0d:	e8 65 f6 ff ff       	call   f0103077 <cprintf>
f0103a12:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103a15:	83 ec 0c             	sub    $0xc,%esp
f0103a18:	6a 00                	push   $0x0
f0103a1a:	e8 1a cd ff ff       	call   f0100739 <iscons>
f0103a1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a22:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103a25:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0103a2a:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f0103a30:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103a33:	eb 45                	jmp    f0103a7a <readline+0x93>
			cprintf("read error: %e\n", c);
f0103a35:	83 ec 08             	sub    $0x8,%esp
f0103a38:	50                   	push   %eax
f0103a39:	8d 83 60 df fe ff    	lea    -0x120a0(%ebx),%eax
f0103a3f:	50                   	push   %eax
f0103a40:	e8 32 f6 ff ff       	call   f0103077 <cprintf>
			return NULL;
f0103a45:	83 c4 10             	add    $0x10,%esp
f0103a48:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103a4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a50:	5b                   	pop    %ebx
f0103a51:	5e                   	pop    %esi
f0103a52:	5f                   	pop    %edi
f0103a53:	5d                   	pop    %ebp
f0103a54:	c3                   	ret    
			if (echoing)
f0103a55:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103a59:	75 05                	jne    f0103a60 <readline+0x79>
			i--;
f0103a5b:	83 ef 01             	sub    $0x1,%edi
f0103a5e:	eb 1a                	jmp    f0103a7a <readline+0x93>
				cputchar('\b');
f0103a60:	83 ec 0c             	sub    $0xc,%esp
f0103a63:	6a 08                	push   $0x8
f0103a65:	e8 ae cc ff ff       	call   f0100718 <cputchar>
f0103a6a:	83 c4 10             	add    $0x10,%esp
f0103a6d:	eb ec                	jmp    f0103a5b <readline+0x74>
			buf[i++] = c;
f0103a6f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103a72:	89 f0                	mov    %esi,%eax
f0103a74:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0103a77:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103a7a:	e8 a9 cc ff ff       	call   f0100728 <getchar>
f0103a7f:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103a81:	85 c0                	test   %eax,%eax
f0103a83:	78 b0                	js     f0103a35 <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103a85:	83 f8 08             	cmp    $0x8,%eax
f0103a88:	0f 94 c0             	sete   %al
f0103a8b:	83 fe 7f             	cmp    $0x7f,%esi
f0103a8e:	0f 94 c2             	sete   %dl
f0103a91:	08 d0                	or     %dl,%al
f0103a93:	74 04                	je     f0103a99 <readline+0xb2>
f0103a95:	85 ff                	test   %edi,%edi
f0103a97:	7f bc                	jg     f0103a55 <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103a99:	83 fe 1f             	cmp    $0x1f,%esi
f0103a9c:	7e 1c                	jle    f0103aba <readline+0xd3>
f0103a9e:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103aa4:	7f 14                	jg     f0103aba <readline+0xd3>
			if (echoing)
f0103aa6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103aaa:	74 c3                	je     f0103a6f <readline+0x88>
				cputchar(c);
f0103aac:	83 ec 0c             	sub    $0xc,%esp
f0103aaf:	56                   	push   %esi
f0103ab0:	e8 63 cc ff ff       	call   f0100718 <cputchar>
f0103ab5:	83 c4 10             	add    $0x10,%esp
f0103ab8:	eb b5                	jmp    f0103a6f <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0103aba:	83 fe 0a             	cmp    $0xa,%esi
f0103abd:	74 05                	je     f0103ac4 <readline+0xdd>
f0103abf:	83 fe 0d             	cmp    $0xd,%esi
f0103ac2:	75 b6                	jne    f0103a7a <readline+0x93>
			if (echoing)
f0103ac4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103ac8:	75 13                	jne    f0103add <readline+0xf6>
			buf[i] = 0;
f0103aca:	c6 84 3b d4 1f 00 00 	movb   $0x0,0x1fd4(%ebx,%edi,1)
f0103ad1:	00 
			return buf;
f0103ad2:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f0103ad8:	e9 70 ff ff ff       	jmp    f0103a4d <readline+0x66>
				cputchar('\n');
f0103add:	83 ec 0c             	sub    $0xc,%esp
f0103ae0:	6a 0a                	push   $0xa
f0103ae2:	e8 31 cc ff ff       	call   f0100718 <cputchar>
f0103ae7:	83 c4 10             	add    $0x10,%esp
f0103aea:	eb de                	jmp    f0103aca <readline+0xe3>

f0103aec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103aec:	55                   	push   %ebp
f0103aed:	89 e5                	mov    %esp,%ebp
f0103aef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103af2:	b8 00 00 00 00       	mov    $0x0,%eax
f0103af7:	eb 03                	jmp    f0103afc <strlen+0x10>
		n++;
f0103af9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103afc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103b00:	75 f7                	jne    f0103af9 <strlen+0xd>
	return n;
}
f0103b02:	5d                   	pop    %ebp
f0103b03:	c3                   	ret    

f0103b04 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103b04:	55                   	push   %ebp
f0103b05:	89 e5                	mov    %esp,%ebp
f0103b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103b0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b12:	eb 03                	jmp    f0103b17 <strnlen+0x13>
		n++;
f0103b14:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103b17:	39 d0                	cmp    %edx,%eax
f0103b19:	74 08                	je     f0103b23 <strnlen+0x1f>
f0103b1b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103b1f:	75 f3                	jne    f0103b14 <strnlen+0x10>
f0103b21:	89 c2                	mov    %eax,%edx
	return n;
}
f0103b23:	89 d0                	mov    %edx,%eax
f0103b25:	5d                   	pop    %ebp
f0103b26:	c3                   	ret    

f0103b27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103b27:	55                   	push   %ebp
f0103b28:	89 e5                	mov    %esp,%ebp
f0103b2a:	53                   	push   %ebx
f0103b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103b31:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b36:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0103b3a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0103b3d:	83 c0 01             	add    $0x1,%eax
f0103b40:	84 d2                	test   %dl,%dl
f0103b42:	75 f2                	jne    f0103b36 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103b44:	89 c8                	mov    %ecx,%eax
f0103b46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b49:	c9                   	leave  
f0103b4a:	c3                   	ret    

f0103b4b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103b4b:	55                   	push   %ebp
f0103b4c:	89 e5                	mov    %esp,%ebp
f0103b4e:	53                   	push   %ebx
f0103b4f:	83 ec 10             	sub    $0x10,%esp
f0103b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103b55:	53                   	push   %ebx
f0103b56:	e8 91 ff ff ff       	call   f0103aec <strlen>
f0103b5b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103b5e:	ff 75 0c             	push   0xc(%ebp)
f0103b61:	01 d8                	add    %ebx,%eax
f0103b63:	50                   	push   %eax
f0103b64:	e8 be ff ff ff       	call   f0103b27 <strcpy>
	return dst;
}
f0103b69:	89 d8                	mov    %ebx,%eax
f0103b6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b6e:	c9                   	leave  
f0103b6f:	c3                   	ret    

f0103b70 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103b70:	55                   	push   %ebp
f0103b71:	89 e5                	mov    %esp,%ebp
f0103b73:	56                   	push   %esi
f0103b74:	53                   	push   %ebx
f0103b75:	8b 75 08             	mov    0x8(%ebp),%esi
f0103b78:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103b7b:	89 f3                	mov    %esi,%ebx
f0103b7d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103b80:	89 f0                	mov    %esi,%eax
f0103b82:	eb 0f                	jmp    f0103b93 <strncpy+0x23>
		*dst++ = *src;
f0103b84:	83 c0 01             	add    $0x1,%eax
f0103b87:	0f b6 0a             	movzbl (%edx),%ecx
f0103b8a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103b8d:	80 f9 01             	cmp    $0x1,%cl
f0103b90:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0103b93:	39 d8                	cmp    %ebx,%eax
f0103b95:	75 ed                	jne    f0103b84 <strncpy+0x14>
	}
	return ret;
}
f0103b97:	89 f0                	mov    %esi,%eax
f0103b99:	5b                   	pop    %ebx
f0103b9a:	5e                   	pop    %esi
f0103b9b:	5d                   	pop    %ebp
f0103b9c:	c3                   	ret    

f0103b9d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103b9d:	55                   	push   %ebp
f0103b9e:	89 e5                	mov    %esp,%ebp
f0103ba0:	56                   	push   %esi
f0103ba1:	53                   	push   %ebx
f0103ba2:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103ba8:	8b 55 10             	mov    0x10(%ebp),%edx
f0103bab:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103bad:	85 d2                	test   %edx,%edx
f0103baf:	74 21                	je     f0103bd2 <strlcpy+0x35>
f0103bb1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103bb5:	89 f2                	mov    %esi,%edx
f0103bb7:	eb 09                	jmp    f0103bc2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103bb9:	83 c1 01             	add    $0x1,%ecx
f0103bbc:	83 c2 01             	add    $0x1,%edx
f0103bbf:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0103bc2:	39 c2                	cmp    %eax,%edx
f0103bc4:	74 09                	je     f0103bcf <strlcpy+0x32>
f0103bc6:	0f b6 19             	movzbl (%ecx),%ebx
f0103bc9:	84 db                	test   %bl,%bl
f0103bcb:	75 ec                	jne    f0103bb9 <strlcpy+0x1c>
f0103bcd:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0103bcf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103bd2:	29 f0                	sub    %esi,%eax
}
f0103bd4:	5b                   	pop    %ebx
f0103bd5:	5e                   	pop    %esi
f0103bd6:	5d                   	pop    %ebp
f0103bd7:	c3                   	ret    

f0103bd8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103bd8:	55                   	push   %ebp
f0103bd9:	89 e5                	mov    %esp,%ebp
f0103bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103bde:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103be1:	eb 06                	jmp    f0103be9 <strcmp+0x11>
		p++, q++;
f0103be3:	83 c1 01             	add    $0x1,%ecx
f0103be6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103be9:	0f b6 01             	movzbl (%ecx),%eax
f0103bec:	84 c0                	test   %al,%al
f0103bee:	74 04                	je     f0103bf4 <strcmp+0x1c>
f0103bf0:	3a 02                	cmp    (%edx),%al
f0103bf2:	74 ef                	je     f0103be3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103bf4:	0f b6 c0             	movzbl %al,%eax
f0103bf7:	0f b6 12             	movzbl (%edx),%edx
f0103bfa:	29 d0                	sub    %edx,%eax
}
f0103bfc:	5d                   	pop    %ebp
f0103bfd:	c3                   	ret    

f0103bfe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103bfe:	55                   	push   %ebp
f0103bff:	89 e5                	mov    %esp,%ebp
f0103c01:	53                   	push   %ebx
f0103c02:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c05:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c08:	89 c3                	mov    %eax,%ebx
f0103c0a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103c0d:	eb 06                	jmp    f0103c15 <strncmp+0x17>
		n--, p++, q++;
f0103c0f:	83 c0 01             	add    $0x1,%eax
f0103c12:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103c15:	39 d8                	cmp    %ebx,%eax
f0103c17:	74 18                	je     f0103c31 <strncmp+0x33>
f0103c19:	0f b6 08             	movzbl (%eax),%ecx
f0103c1c:	84 c9                	test   %cl,%cl
f0103c1e:	74 04                	je     f0103c24 <strncmp+0x26>
f0103c20:	3a 0a                	cmp    (%edx),%cl
f0103c22:	74 eb                	je     f0103c0f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103c24:	0f b6 00             	movzbl (%eax),%eax
f0103c27:	0f b6 12             	movzbl (%edx),%edx
f0103c2a:	29 d0                	sub    %edx,%eax
}
f0103c2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c2f:	c9                   	leave  
f0103c30:	c3                   	ret    
		return 0;
f0103c31:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c36:	eb f4                	jmp    f0103c2c <strncmp+0x2e>

f0103c38 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103c38:	55                   	push   %ebp
f0103c39:	89 e5                	mov    %esp,%ebp
f0103c3b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c3e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c42:	eb 03                	jmp    f0103c47 <strchr+0xf>
f0103c44:	83 c0 01             	add    $0x1,%eax
f0103c47:	0f b6 10             	movzbl (%eax),%edx
f0103c4a:	84 d2                	test   %dl,%dl
f0103c4c:	74 06                	je     f0103c54 <strchr+0x1c>
		if (*s == c)
f0103c4e:	38 ca                	cmp    %cl,%dl
f0103c50:	75 f2                	jne    f0103c44 <strchr+0xc>
f0103c52:	eb 05                	jmp    f0103c59 <strchr+0x21>
			return (char *) s;
	return 0;
f0103c54:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103c59:	5d                   	pop    %ebp
f0103c5a:	c3                   	ret    

f0103c5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103c5b:	55                   	push   %ebp
f0103c5c:	89 e5                	mov    %esp,%ebp
f0103c5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c65:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103c68:	38 ca                	cmp    %cl,%dl
f0103c6a:	74 09                	je     f0103c75 <strfind+0x1a>
f0103c6c:	84 d2                	test   %dl,%dl
f0103c6e:	74 05                	je     f0103c75 <strfind+0x1a>
	for (; *s; s++)
f0103c70:	83 c0 01             	add    $0x1,%eax
f0103c73:	eb f0                	jmp    f0103c65 <strfind+0xa>
			break;
	return (char *) s;
}
f0103c75:	5d                   	pop    %ebp
f0103c76:	c3                   	ret    

f0103c77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103c77:	55                   	push   %ebp
f0103c78:	89 e5                	mov    %esp,%ebp
f0103c7a:	57                   	push   %edi
f0103c7b:	56                   	push   %esi
f0103c7c:	53                   	push   %ebx
f0103c7d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103c80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103c83:	85 c9                	test   %ecx,%ecx
f0103c85:	74 2f                	je     f0103cb6 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103c87:	89 f8                	mov    %edi,%eax
f0103c89:	09 c8                	or     %ecx,%eax
f0103c8b:	a8 03                	test   $0x3,%al
f0103c8d:	75 21                	jne    f0103cb0 <memset+0x39>
		c &= 0xFF;
f0103c8f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103c93:	89 d0                	mov    %edx,%eax
f0103c95:	c1 e0 08             	shl    $0x8,%eax
f0103c98:	89 d3                	mov    %edx,%ebx
f0103c9a:	c1 e3 18             	shl    $0x18,%ebx
f0103c9d:	89 d6                	mov    %edx,%esi
f0103c9f:	c1 e6 10             	shl    $0x10,%esi
f0103ca2:	09 f3                	or     %esi,%ebx
f0103ca4:	09 da                	or     %ebx,%edx
f0103ca6:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103ca8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103cab:	fc                   	cld    
f0103cac:	f3 ab                	rep stos %eax,%es:(%edi)
f0103cae:	eb 06                	jmp    f0103cb6 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103cb3:	fc                   	cld    
f0103cb4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103cb6:	89 f8                	mov    %edi,%eax
f0103cb8:	5b                   	pop    %ebx
f0103cb9:	5e                   	pop    %esi
f0103cba:	5f                   	pop    %edi
f0103cbb:	5d                   	pop    %ebp
f0103cbc:	c3                   	ret    

f0103cbd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103cbd:	55                   	push   %ebp
f0103cbe:	89 e5                	mov    %esp,%ebp
f0103cc0:	57                   	push   %edi
f0103cc1:	56                   	push   %esi
f0103cc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cc5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103cc8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103ccb:	39 c6                	cmp    %eax,%esi
f0103ccd:	73 32                	jae    f0103d01 <memmove+0x44>
f0103ccf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103cd2:	39 c2                	cmp    %eax,%edx
f0103cd4:	76 2b                	jbe    f0103d01 <memmove+0x44>
		s += n;
		d += n;
f0103cd6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103cd9:	89 d6                	mov    %edx,%esi
f0103cdb:	09 fe                	or     %edi,%esi
f0103cdd:	09 ce                	or     %ecx,%esi
f0103cdf:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103ce5:	75 0e                	jne    f0103cf5 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103ce7:	83 ef 04             	sub    $0x4,%edi
f0103cea:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103ced:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103cf0:	fd                   	std    
f0103cf1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103cf3:	eb 09                	jmp    f0103cfe <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103cf5:	83 ef 01             	sub    $0x1,%edi
f0103cf8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103cfb:	fd                   	std    
f0103cfc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103cfe:	fc                   	cld    
f0103cff:	eb 1a                	jmp    f0103d1b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103d01:	89 f2                	mov    %esi,%edx
f0103d03:	09 c2                	or     %eax,%edx
f0103d05:	09 ca                	or     %ecx,%edx
f0103d07:	f6 c2 03             	test   $0x3,%dl
f0103d0a:	75 0a                	jne    f0103d16 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103d0c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103d0f:	89 c7                	mov    %eax,%edi
f0103d11:	fc                   	cld    
f0103d12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103d14:	eb 05                	jmp    f0103d1b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0103d16:	89 c7                	mov    %eax,%edi
f0103d18:	fc                   	cld    
f0103d19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103d1b:	5e                   	pop    %esi
f0103d1c:	5f                   	pop    %edi
f0103d1d:	5d                   	pop    %ebp
f0103d1e:	c3                   	ret    

f0103d1f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103d1f:	55                   	push   %ebp
f0103d20:	89 e5                	mov    %esp,%ebp
f0103d22:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103d25:	ff 75 10             	push   0x10(%ebp)
f0103d28:	ff 75 0c             	push   0xc(%ebp)
f0103d2b:	ff 75 08             	push   0x8(%ebp)
f0103d2e:	e8 8a ff ff ff       	call   f0103cbd <memmove>
}
f0103d33:	c9                   	leave  
f0103d34:	c3                   	ret    

f0103d35 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103d35:	55                   	push   %ebp
f0103d36:	89 e5                	mov    %esp,%ebp
f0103d38:	56                   	push   %esi
f0103d39:	53                   	push   %ebx
f0103d3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d3d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d40:	89 c6                	mov    %eax,%esi
f0103d42:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d45:	eb 06                	jmp    f0103d4d <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103d47:	83 c0 01             	add    $0x1,%eax
f0103d4a:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0103d4d:	39 f0                	cmp    %esi,%eax
f0103d4f:	74 14                	je     f0103d65 <memcmp+0x30>
		if (*s1 != *s2)
f0103d51:	0f b6 08             	movzbl (%eax),%ecx
f0103d54:	0f b6 1a             	movzbl (%edx),%ebx
f0103d57:	38 d9                	cmp    %bl,%cl
f0103d59:	74 ec                	je     f0103d47 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0103d5b:	0f b6 c1             	movzbl %cl,%eax
f0103d5e:	0f b6 db             	movzbl %bl,%ebx
f0103d61:	29 d8                	sub    %ebx,%eax
f0103d63:	eb 05                	jmp    f0103d6a <memcmp+0x35>
	}

	return 0;
f0103d65:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d6a:	5b                   	pop    %ebx
f0103d6b:	5e                   	pop    %esi
f0103d6c:	5d                   	pop    %ebp
f0103d6d:	c3                   	ret    

f0103d6e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103d6e:	55                   	push   %ebp
f0103d6f:	89 e5                	mov    %esp,%ebp
f0103d71:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103d77:	89 c2                	mov    %eax,%edx
f0103d79:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103d7c:	eb 03                	jmp    f0103d81 <memfind+0x13>
f0103d7e:	83 c0 01             	add    $0x1,%eax
f0103d81:	39 d0                	cmp    %edx,%eax
f0103d83:	73 04                	jae    f0103d89 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103d85:	38 08                	cmp    %cl,(%eax)
f0103d87:	75 f5                	jne    f0103d7e <memfind+0x10>
			break;
	return (void *) s;
}
f0103d89:	5d                   	pop    %ebp
f0103d8a:	c3                   	ret    

f0103d8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103d8b:	55                   	push   %ebp
f0103d8c:	89 e5                	mov    %esp,%ebp
f0103d8e:	57                   	push   %edi
f0103d8f:	56                   	push   %esi
f0103d90:	53                   	push   %ebx
f0103d91:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103d97:	eb 03                	jmp    f0103d9c <strtol+0x11>
		s++;
f0103d99:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0103d9c:	0f b6 02             	movzbl (%edx),%eax
f0103d9f:	3c 20                	cmp    $0x20,%al
f0103da1:	74 f6                	je     f0103d99 <strtol+0xe>
f0103da3:	3c 09                	cmp    $0x9,%al
f0103da5:	74 f2                	je     f0103d99 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103da7:	3c 2b                	cmp    $0x2b,%al
f0103da9:	74 2a                	je     f0103dd5 <strtol+0x4a>
	int neg = 0;
f0103dab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103db0:	3c 2d                	cmp    $0x2d,%al
f0103db2:	74 2b                	je     f0103ddf <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103db4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103dba:	75 0f                	jne    f0103dcb <strtol+0x40>
f0103dbc:	80 3a 30             	cmpb   $0x30,(%edx)
f0103dbf:	74 28                	je     f0103de9 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103dc1:	85 db                	test   %ebx,%ebx
f0103dc3:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103dc8:	0f 44 d8             	cmove  %eax,%ebx
f0103dcb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103dd0:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103dd3:	eb 46                	jmp    f0103e1b <strtol+0x90>
		s++;
f0103dd5:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0103dd8:	bf 00 00 00 00       	mov    $0x0,%edi
f0103ddd:	eb d5                	jmp    f0103db4 <strtol+0x29>
		s++, neg = 1;
f0103ddf:	83 c2 01             	add    $0x1,%edx
f0103de2:	bf 01 00 00 00       	mov    $0x1,%edi
f0103de7:	eb cb                	jmp    f0103db4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103de9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103ded:	74 0e                	je     f0103dfd <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0103def:	85 db                	test   %ebx,%ebx
f0103df1:	75 d8                	jne    f0103dcb <strtol+0x40>
		s++, base = 8;
f0103df3:	83 c2 01             	add    $0x1,%edx
f0103df6:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103dfb:	eb ce                	jmp    f0103dcb <strtol+0x40>
		s += 2, base = 16;
f0103dfd:	83 c2 02             	add    $0x2,%edx
f0103e00:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103e05:	eb c4                	jmp    f0103dcb <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0103e07:	0f be c0             	movsbl %al,%eax
f0103e0a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103e0d:	3b 45 10             	cmp    0x10(%ebp),%eax
f0103e10:	7d 3a                	jge    f0103e4c <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103e12:	83 c2 01             	add    $0x1,%edx
f0103e15:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0103e19:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0103e1b:	0f b6 02             	movzbl (%edx),%eax
f0103e1e:	8d 70 d0             	lea    -0x30(%eax),%esi
f0103e21:	89 f3                	mov    %esi,%ebx
f0103e23:	80 fb 09             	cmp    $0x9,%bl
f0103e26:	76 df                	jbe    f0103e07 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0103e28:	8d 70 9f             	lea    -0x61(%eax),%esi
f0103e2b:	89 f3                	mov    %esi,%ebx
f0103e2d:	80 fb 19             	cmp    $0x19,%bl
f0103e30:	77 08                	ja     f0103e3a <strtol+0xaf>
			dig = *s - 'a' + 10;
f0103e32:	0f be c0             	movsbl %al,%eax
f0103e35:	83 e8 57             	sub    $0x57,%eax
f0103e38:	eb d3                	jmp    f0103e0d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0103e3a:	8d 70 bf             	lea    -0x41(%eax),%esi
f0103e3d:	89 f3                	mov    %esi,%ebx
f0103e3f:	80 fb 19             	cmp    $0x19,%bl
f0103e42:	77 08                	ja     f0103e4c <strtol+0xc1>
			dig = *s - 'A' + 10;
f0103e44:	0f be c0             	movsbl %al,%eax
f0103e47:	83 e8 37             	sub    $0x37,%eax
f0103e4a:	eb c1                	jmp    f0103e0d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103e4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103e50:	74 05                	je     f0103e57 <strtol+0xcc>
		*endptr = (char *) s;
f0103e52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e55:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0103e57:	89 c8                	mov    %ecx,%eax
f0103e59:	f7 d8                	neg    %eax
f0103e5b:	85 ff                	test   %edi,%edi
f0103e5d:	0f 45 c8             	cmovne %eax,%ecx
}
f0103e60:	89 c8                	mov    %ecx,%eax
f0103e62:	5b                   	pop    %ebx
f0103e63:	5e                   	pop    %esi
f0103e64:	5f                   	pop    %edi
f0103e65:	5d                   	pop    %ebp
f0103e66:	c3                   	ret    
f0103e67:	66 90                	xchg   %ax,%ax
f0103e69:	66 90                	xchg   %ax,%ax
f0103e6b:	66 90                	xchg   %ax,%ax
f0103e6d:	66 90                	xchg   %ax,%ax
f0103e6f:	90                   	nop

f0103e70 <__udivdi3>:
f0103e70:	f3 0f 1e fb          	endbr32 
f0103e74:	55                   	push   %ebp
f0103e75:	57                   	push   %edi
f0103e76:	56                   	push   %esi
f0103e77:	53                   	push   %ebx
f0103e78:	83 ec 1c             	sub    $0x1c,%esp
f0103e7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0103e7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103e83:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103e87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103e8b:	85 c0                	test   %eax,%eax
f0103e8d:	75 19                	jne    f0103ea8 <__udivdi3+0x38>
f0103e8f:	39 f3                	cmp    %esi,%ebx
f0103e91:	76 4d                	jbe    f0103ee0 <__udivdi3+0x70>
f0103e93:	31 ff                	xor    %edi,%edi
f0103e95:	89 e8                	mov    %ebp,%eax
f0103e97:	89 f2                	mov    %esi,%edx
f0103e99:	f7 f3                	div    %ebx
f0103e9b:	89 fa                	mov    %edi,%edx
f0103e9d:	83 c4 1c             	add    $0x1c,%esp
f0103ea0:	5b                   	pop    %ebx
f0103ea1:	5e                   	pop    %esi
f0103ea2:	5f                   	pop    %edi
f0103ea3:	5d                   	pop    %ebp
f0103ea4:	c3                   	ret    
f0103ea5:	8d 76 00             	lea    0x0(%esi),%esi
f0103ea8:	39 f0                	cmp    %esi,%eax
f0103eaa:	76 14                	jbe    f0103ec0 <__udivdi3+0x50>
f0103eac:	31 ff                	xor    %edi,%edi
f0103eae:	31 c0                	xor    %eax,%eax
f0103eb0:	89 fa                	mov    %edi,%edx
f0103eb2:	83 c4 1c             	add    $0x1c,%esp
f0103eb5:	5b                   	pop    %ebx
f0103eb6:	5e                   	pop    %esi
f0103eb7:	5f                   	pop    %edi
f0103eb8:	5d                   	pop    %ebp
f0103eb9:	c3                   	ret    
f0103eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103ec0:	0f bd f8             	bsr    %eax,%edi
f0103ec3:	83 f7 1f             	xor    $0x1f,%edi
f0103ec6:	75 48                	jne    f0103f10 <__udivdi3+0xa0>
f0103ec8:	39 f0                	cmp    %esi,%eax
f0103eca:	72 06                	jb     f0103ed2 <__udivdi3+0x62>
f0103ecc:	31 c0                	xor    %eax,%eax
f0103ece:	39 eb                	cmp    %ebp,%ebx
f0103ed0:	77 de                	ja     f0103eb0 <__udivdi3+0x40>
f0103ed2:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ed7:	eb d7                	jmp    f0103eb0 <__udivdi3+0x40>
f0103ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103ee0:	89 d9                	mov    %ebx,%ecx
f0103ee2:	85 db                	test   %ebx,%ebx
f0103ee4:	75 0b                	jne    f0103ef1 <__udivdi3+0x81>
f0103ee6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103eeb:	31 d2                	xor    %edx,%edx
f0103eed:	f7 f3                	div    %ebx
f0103eef:	89 c1                	mov    %eax,%ecx
f0103ef1:	31 d2                	xor    %edx,%edx
f0103ef3:	89 f0                	mov    %esi,%eax
f0103ef5:	f7 f1                	div    %ecx
f0103ef7:	89 c6                	mov    %eax,%esi
f0103ef9:	89 e8                	mov    %ebp,%eax
f0103efb:	89 f7                	mov    %esi,%edi
f0103efd:	f7 f1                	div    %ecx
f0103eff:	89 fa                	mov    %edi,%edx
f0103f01:	83 c4 1c             	add    $0x1c,%esp
f0103f04:	5b                   	pop    %ebx
f0103f05:	5e                   	pop    %esi
f0103f06:	5f                   	pop    %edi
f0103f07:	5d                   	pop    %ebp
f0103f08:	c3                   	ret    
f0103f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103f10:	89 f9                	mov    %edi,%ecx
f0103f12:	ba 20 00 00 00       	mov    $0x20,%edx
f0103f17:	29 fa                	sub    %edi,%edx
f0103f19:	d3 e0                	shl    %cl,%eax
f0103f1b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f1f:	89 d1                	mov    %edx,%ecx
f0103f21:	89 d8                	mov    %ebx,%eax
f0103f23:	d3 e8                	shr    %cl,%eax
f0103f25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103f29:	09 c1                	or     %eax,%ecx
f0103f2b:	89 f0                	mov    %esi,%eax
f0103f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103f31:	89 f9                	mov    %edi,%ecx
f0103f33:	d3 e3                	shl    %cl,%ebx
f0103f35:	89 d1                	mov    %edx,%ecx
f0103f37:	d3 e8                	shr    %cl,%eax
f0103f39:	89 f9                	mov    %edi,%ecx
f0103f3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103f3f:	89 eb                	mov    %ebp,%ebx
f0103f41:	d3 e6                	shl    %cl,%esi
f0103f43:	89 d1                	mov    %edx,%ecx
f0103f45:	d3 eb                	shr    %cl,%ebx
f0103f47:	09 f3                	or     %esi,%ebx
f0103f49:	89 c6                	mov    %eax,%esi
f0103f4b:	89 f2                	mov    %esi,%edx
f0103f4d:	89 d8                	mov    %ebx,%eax
f0103f4f:	f7 74 24 08          	divl   0x8(%esp)
f0103f53:	89 d6                	mov    %edx,%esi
f0103f55:	89 c3                	mov    %eax,%ebx
f0103f57:	f7 64 24 0c          	mull   0xc(%esp)
f0103f5b:	39 d6                	cmp    %edx,%esi
f0103f5d:	72 19                	jb     f0103f78 <__udivdi3+0x108>
f0103f5f:	89 f9                	mov    %edi,%ecx
f0103f61:	d3 e5                	shl    %cl,%ebp
f0103f63:	39 c5                	cmp    %eax,%ebp
f0103f65:	73 04                	jae    f0103f6b <__udivdi3+0xfb>
f0103f67:	39 d6                	cmp    %edx,%esi
f0103f69:	74 0d                	je     f0103f78 <__udivdi3+0x108>
f0103f6b:	89 d8                	mov    %ebx,%eax
f0103f6d:	31 ff                	xor    %edi,%edi
f0103f6f:	e9 3c ff ff ff       	jmp    f0103eb0 <__udivdi3+0x40>
f0103f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103f78:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103f7b:	31 ff                	xor    %edi,%edi
f0103f7d:	e9 2e ff ff ff       	jmp    f0103eb0 <__udivdi3+0x40>
f0103f82:	66 90                	xchg   %ax,%ax
f0103f84:	66 90                	xchg   %ax,%ax
f0103f86:	66 90                	xchg   %ax,%ax
f0103f88:	66 90                	xchg   %ax,%ax
f0103f8a:	66 90                	xchg   %ax,%ax
f0103f8c:	66 90                	xchg   %ax,%ax
f0103f8e:	66 90                	xchg   %ax,%ax

f0103f90 <__umoddi3>:
f0103f90:	f3 0f 1e fb          	endbr32 
f0103f94:	55                   	push   %ebp
f0103f95:	57                   	push   %edi
f0103f96:	56                   	push   %esi
f0103f97:	53                   	push   %ebx
f0103f98:	83 ec 1c             	sub    $0x1c,%esp
f0103f9b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103f9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103fa3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0103fa7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0103fab:	89 f0                	mov    %esi,%eax
f0103fad:	89 da                	mov    %ebx,%edx
f0103faf:	85 ff                	test   %edi,%edi
f0103fb1:	75 15                	jne    f0103fc8 <__umoddi3+0x38>
f0103fb3:	39 dd                	cmp    %ebx,%ebp
f0103fb5:	76 39                	jbe    f0103ff0 <__umoddi3+0x60>
f0103fb7:	f7 f5                	div    %ebp
f0103fb9:	89 d0                	mov    %edx,%eax
f0103fbb:	31 d2                	xor    %edx,%edx
f0103fbd:	83 c4 1c             	add    $0x1c,%esp
f0103fc0:	5b                   	pop    %ebx
f0103fc1:	5e                   	pop    %esi
f0103fc2:	5f                   	pop    %edi
f0103fc3:	5d                   	pop    %ebp
f0103fc4:	c3                   	ret    
f0103fc5:	8d 76 00             	lea    0x0(%esi),%esi
f0103fc8:	39 df                	cmp    %ebx,%edi
f0103fca:	77 f1                	ja     f0103fbd <__umoddi3+0x2d>
f0103fcc:	0f bd cf             	bsr    %edi,%ecx
f0103fcf:	83 f1 1f             	xor    $0x1f,%ecx
f0103fd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103fd6:	75 40                	jne    f0104018 <__umoddi3+0x88>
f0103fd8:	39 df                	cmp    %ebx,%edi
f0103fda:	72 04                	jb     f0103fe0 <__umoddi3+0x50>
f0103fdc:	39 f5                	cmp    %esi,%ebp
f0103fde:	77 dd                	ja     f0103fbd <__umoddi3+0x2d>
f0103fe0:	89 da                	mov    %ebx,%edx
f0103fe2:	89 f0                	mov    %esi,%eax
f0103fe4:	29 e8                	sub    %ebp,%eax
f0103fe6:	19 fa                	sbb    %edi,%edx
f0103fe8:	eb d3                	jmp    f0103fbd <__umoddi3+0x2d>
f0103fea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103ff0:	89 e9                	mov    %ebp,%ecx
f0103ff2:	85 ed                	test   %ebp,%ebp
f0103ff4:	75 0b                	jne    f0104001 <__umoddi3+0x71>
f0103ff6:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ffb:	31 d2                	xor    %edx,%edx
f0103ffd:	f7 f5                	div    %ebp
f0103fff:	89 c1                	mov    %eax,%ecx
f0104001:	89 d8                	mov    %ebx,%eax
f0104003:	31 d2                	xor    %edx,%edx
f0104005:	f7 f1                	div    %ecx
f0104007:	89 f0                	mov    %esi,%eax
f0104009:	f7 f1                	div    %ecx
f010400b:	89 d0                	mov    %edx,%eax
f010400d:	31 d2                	xor    %edx,%edx
f010400f:	eb ac                	jmp    f0103fbd <__umoddi3+0x2d>
f0104011:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104018:	8b 44 24 04          	mov    0x4(%esp),%eax
f010401c:	ba 20 00 00 00       	mov    $0x20,%edx
f0104021:	29 c2                	sub    %eax,%edx
f0104023:	89 c1                	mov    %eax,%ecx
f0104025:	89 e8                	mov    %ebp,%eax
f0104027:	d3 e7                	shl    %cl,%edi
f0104029:	89 d1                	mov    %edx,%ecx
f010402b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010402f:	d3 e8                	shr    %cl,%eax
f0104031:	89 c1                	mov    %eax,%ecx
f0104033:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104037:	09 f9                	or     %edi,%ecx
f0104039:	89 df                	mov    %ebx,%edi
f010403b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010403f:	89 c1                	mov    %eax,%ecx
f0104041:	d3 e5                	shl    %cl,%ebp
f0104043:	89 d1                	mov    %edx,%ecx
f0104045:	d3 ef                	shr    %cl,%edi
f0104047:	89 c1                	mov    %eax,%ecx
f0104049:	89 f0                	mov    %esi,%eax
f010404b:	d3 e3                	shl    %cl,%ebx
f010404d:	89 d1                	mov    %edx,%ecx
f010404f:	89 fa                	mov    %edi,%edx
f0104051:	d3 e8                	shr    %cl,%eax
f0104053:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0104058:	09 d8                	or     %ebx,%eax
f010405a:	f7 74 24 08          	divl   0x8(%esp)
f010405e:	89 d3                	mov    %edx,%ebx
f0104060:	d3 e6                	shl    %cl,%esi
f0104062:	f7 e5                	mul    %ebp
f0104064:	89 c7                	mov    %eax,%edi
f0104066:	89 d1                	mov    %edx,%ecx
f0104068:	39 d3                	cmp    %edx,%ebx
f010406a:	72 06                	jb     f0104072 <__umoddi3+0xe2>
f010406c:	75 0e                	jne    f010407c <__umoddi3+0xec>
f010406e:	39 c6                	cmp    %eax,%esi
f0104070:	73 0a                	jae    f010407c <__umoddi3+0xec>
f0104072:	29 e8                	sub    %ebp,%eax
f0104074:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0104078:	89 d1                	mov    %edx,%ecx
f010407a:	89 c7                	mov    %eax,%edi
f010407c:	89 f5                	mov    %esi,%ebp
f010407e:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104082:	29 fd                	sub    %edi,%ebp
f0104084:	19 cb                	sbb    %ecx,%ebx
f0104086:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f010408b:	89 d8                	mov    %ebx,%eax
f010408d:	d3 e0                	shl    %cl,%eax
f010408f:	89 f1                	mov    %esi,%ecx
f0104091:	d3 ed                	shr    %cl,%ebp
f0104093:	d3 eb                	shr    %cl,%ebx
f0104095:	09 e8                	or     %ebp,%eax
f0104097:	89 da                	mov    %ebx,%edx
f0104099:	83 c4 1c             	add    $0x1c,%esp
f010409c:	5b                   	pop    %ebx
f010409d:	5e                   	pop    %esi
f010409e:	5f                   	pop    %edi
f010409f:	5d                   	pop    %ebp
f01040a0:	c3                   	ret    

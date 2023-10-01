
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
f010004c:	81 c3 c4 72 01 00    	add    $0x172c4,%ebx
	unsigned int i = 0x00646c72;
f0100052:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
    cprintf("H%x Wo%s", 57616, &i);
f0100059:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010005c:	50                   	push   %eax
f010005d:	68 10 e1 00 00       	push   $0xe110
f0100062:	8d 83 f0 cd fe ff    	lea    -0x13210(%ebx),%eax
f0100068:	50                   	push   %eax
f0100069:	e8 53 30 00 00       	call   f01030c1 <cprintf>
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
f0100082:	81 c3 8e 72 01 00    	add    $0x1728e,%ebx
	cprintf("brk\n");
f0100088:	8d 83 f9 cd fe ff    	lea    -0x13207(%ebx),%eax
f010008e:	50                   	push   %eax
f010008f:	e8 2d 30 00 00       	call   f01030c1 <cprintf>
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
f01000a8:	81 c3 68 72 01 00    	add    $0x17268,%ebx
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
f01000c0:	e8 fc 3b 00 00       	call   f0103cc1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 39 05 00 00       	call   f0100603 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	83 c4 08             	add    $0x8,%esp
f01000cd:	68 ac 1a 00 00       	push   $0x1aac
f01000d2:	8d 83 fe cd fe ff    	lea    -0x13202(%ebx),%eax
f01000d8:	50                   	push   %eax
f01000d9:	e8 e3 2f 00 00       	call   f01030c1 <cprintf>
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
f01000ff:	81 c3 11 72 01 00    	add    $0x17211,%ebx
	va_list ap;

	if (panicstr)
f0100105:	83 bb 50 1d 00 00 00 	cmpl   $0x0,0x1d50(%ebx)
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
f0100120:	89 83 50 1d 00 00    	mov    %eax,0x1d50(%ebx)
	asm volatile("cli; cld");
f0100126:	fa                   	cli    
f0100127:	fc                   	cld    
	va_start(ap, fmt);
f0100128:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010012b:	83 ec 04             	sub    $0x4,%esp
f010012e:	ff 75 0c             	push   0xc(%ebp)
f0100131:	ff 75 08             	push   0x8(%ebp)
f0100134:	8d 83 19 ce fe ff    	lea    -0x131e7(%ebx),%eax
f010013a:	50                   	push   %eax
f010013b:	e8 81 2f 00 00       	call   f01030c1 <cprintf>
	vcprintf(fmt, ap);
f0100140:	83 c4 08             	add    $0x8,%esp
f0100143:	56                   	push   %esi
f0100144:	ff 75 10             	push   0x10(%ebp)
f0100147:	e8 3e 2f 00 00       	call   f010308a <vcprintf>
	cprintf("\n");
f010014c:	8d 83 c6 d5 fe ff    	lea    -0x12a3a(%ebx),%eax
f0100152:	89 04 24             	mov    %eax,(%esp)
f0100155:	e8 67 2f 00 00       	call   f01030c1 <cprintf>
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
f0100169:	81 c3 a7 71 01 00    	add    $0x171a7,%ebx
	va_list ap;

	va_start(ap, fmt);
f010016f:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100172:	83 ec 04             	sub    $0x4,%esp
f0100175:	ff 75 0c             	push   0xc(%ebp)
f0100178:	ff 75 08             	push   0x8(%ebp)
f010017b:	8d 83 31 ce fe ff    	lea    -0x131cf(%ebx),%eax
f0100181:	50                   	push   %eax
f0100182:	e8 3a 2f 00 00       	call   f01030c1 <cprintf>
	vcprintf(fmt, ap);
f0100187:	83 c4 08             	add    $0x8,%esp
f010018a:	56                   	push   %esi
f010018b:	ff 75 10             	push   0x10(%ebp)
f010018e:	e8 f7 2e 00 00       	call   f010308a <vcprintf>
	cprintf("\n");
f0100193:	8d 83 c6 d5 fe ff    	lea    -0x12a3a(%ebx),%eax
f0100199:	89 04 24             	mov    %eax,(%esp)
f010019c:	e8 20 2f 00 00       	call   f01030c1 <cprintf>
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
f01001d7:	81 c6 39 71 01 00    	add    $0x17139,%esi
f01001dd:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001df:	8d 1d 90 1d 00 00    	lea    0x1d90,%ebx
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
f0100237:	81 c3 d9 70 01 00    	add    $0x170d9,%ebx
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
f0100263:	8b 8b 70 1d 00 00    	mov    0x1d70(%ebx),%ecx
f0100269:	f6 c1 40             	test   $0x40,%cl
f010026c:	74 0e                	je     f010027c <kbd_proc_data+0x4f>
		data |= 0x80;
f010026e:	83 c8 80             	or     $0xffffff80,%eax
f0100271:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100273:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100276:	89 8b 70 1d 00 00    	mov    %ecx,0x1d70(%ebx)
	shift |= shiftcode[data];
f010027c:	0f b6 d2             	movzbl %dl,%edx
f010027f:	0f b6 84 13 90 cf fe 	movzbl -0x13070(%ebx,%edx,1),%eax
f0100286:	ff 
f0100287:	0b 83 70 1d 00 00    	or     0x1d70(%ebx),%eax
	shift ^= togglecode[data];
f010028d:	0f b6 8c 13 90 ce fe 	movzbl -0x13170(%ebx,%edx,1),%ecx
f0100294:	ff 
f0100295:	31 c8                	xor    %ecx,%eax
f0100297:	89 83 70 1d 00 00    	mov    %eax,0x1d70(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010029d:	89 c1                	mov    %eax,%ecx
f010029f:	83 e1 03             	and    $0x3,%ecx
f01002a2:	8b 8c 8b f0 1c 00 00 	mov    0x1cf0(%ebx,%ecx,4),%ecx
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
f01002c3:	83 8b 70 1d 00 00 40 	orl    $0x40,0x1d70(%ebx)
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
f01002d8:	8b 8b 70 1d 00 00    	mov    0x1d70(%ebx),%ecx
f01002de:	83 e0 7f             	and    $0x7f,%eax
f01002e1:	f6 c1 40             	test   $0x40,%cl
f01002e4:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002e7:	0f b6 d2             	movzbl %dl,%edx
f01002ea:	0f b6 84 13 90 cf fe 	movzbl -0x13070(%ebx,%edx,1),%eax
f01002f1:	ff 
f01002f2:	83 c8 40             	or     $0x40,%eax
f01002f5:	0f b6 c0             	movzbl %al,%eax
f01002f8:	f7 d0                	not    %eax
f01002fa:	21 c8                	and    %ecx,%eax
f01002fc:	89 83 70 1d 00 00    	mov    %eax,0x1d70(%ebx)
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
f0100326:	8d 83 4b ce fe ff    	lea    -0x131b5(%ebx),%eax
f010032c:	50                   	push   %eax
f010032d:	e8 8f 2d 00 00       	call   f01030c1 <cprintf>
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
f0100361:	81 c3 af 6f 01 00    	add    $0x16faf,%ebx
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
f010045c:	0f b7 83 98 1f 00 00 	movzwl 0x1f98(%ebx),%eax
f0100463:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100469:	c1 e8 16             	shr    $0x16,%eax
f010046c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010046f:	c1 e0 04             	shl    $0x4,%eax
f0100472:	66 89 83 98 1f 00 00 	mov    %ax,0x1f98(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100479:	66 81 bb 98 1f 00 00 	cmpw   $0x7cf,0x1f98(%ebx)
f0100480:	cf 07 
f0100482:	0f 87 98 00 00 00    	ja     f0100520 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100488:	8b 8b a0 1f 00 00    	mov    0x1fa0(%ebx),%ecx
f010048e:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100493:	89 ca                	mov    %ecx,%edx
f0100495:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100496:	0f b7 9b 98 1f 00 00 	movzwl 0x1f98(%ebx),%ebx
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
f01004be:	0f b7 83 98 1f 00 00 	movzwl 0x1f98(%ebx),%eax
f01004c5:	66 85 c0             	test   %ax,%ax
f01004c8:	74 be                	je     f0100488 <cons_putc+0x135>
			crt_pos--;
f01004ca:	83 e8 01             	sub    $0x1,%eax
f01004cd:	66 89 83 98 1f 00 00 	mov    %ax,0x1f98(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004d4:	0f b7 c0             	movzwl %ax,%eax
f01004d7:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004db:	b2 00                	mov    $0x0,%dl
f01004dd:	83 ca 20             	or     $0x20,%edx
f01004e0:	8b 8b 9c 1f 00 00    	mov    0x1f9c(%ebx),%ecx
f01004e6:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004ea:	eb 8d                	jmp    f0100479 <cons_putc+0x126>
		crt_pos += CRT_COLS;
f01004ec:	66 83 83 98 1f 00 00 	addw   $0x50,0x1f98(%ebx)
f01004f3:	50 
f01004f4:	e9 63 ff ff ff       	jmp    f010045c <cons_putc+0x109>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004f9:	0f b7 83 98 1f 00 00 	movzwl 0x1f98(%ebx),%eax
f0100500:	8d 50 01             	lea    0x1(%eax),%edx
f0100503:	66 89 93 98 1f 00 00 	mov    %dx,0x1f98(%ebx)
f010050a:	0f b7 c0             	movzwl %ax,%eax
f010050d:	8b 93 9c 1f 00 00    	mov    0x1f9c(%ebx),%edx
f0100513:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100517:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010051b:	e9 59 ff ff ff       	jmp    f0100479 <cons_putc+0x126>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100520:	8b 83 9c 1f 00 00    	mov    0x1f9c(%ebx),%eax
f0100526:	83 ec 04             	sub    $0x4,%esp
f0100529:	68 00 0f 00 00       	push   $0xf00
f010052e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100534:	52                   	push   %edx
f0100535:	50                   	push   %eax
f0100536:	e8 cc 37 00 00       	call   f0103d07 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010053b:	8b 93 9c 1f 00 00    	mov    0x1f9c(%ebx),%edx
f0100541:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100547:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010054d:	83 c4 10             	add    $0x10,%esp
f0100550:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100555:	83 c0 02             	add    $0x2,%eax
f0100558:	39 d0                	cmp    %edx,%eax
f010055a:	75 f4                	jne    f0100550 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010055c:	66 83 ab 98 1f 00 00 	subw   $0x50,0x1f98(%ebx)
f0100563:	50 
f0100564:	e9 1f ff ff ff       	jmp    f0100488 <cons_putc+0x135>

f0100569 <serial_intr>:
{
f0100569:	e8 d1 01 00 00       	call   f010073f <__x86.get_pc_thunk.ax>
f010056e:	05 a2 6d 01 00       	add    $0x16da2,%eax
	if (serial_exists)
f0100573:	80 b8 a4 1f 00 00 00 	cmpb   $0x0,0x1fa4(%eax)
f010057a:	75 01                	jne    f010057d <serial_intr+0x14>
f010057c:	c3                   	ret    
{
f010057d:	55                   	push   %ebp
f010057e:	89 e5                	mov    %esp,%ebp
f0100580:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100583:	8d 80 9f 8e fe ff    	lea    -0x17161(%eax),%eax
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
f010059d:	05 73 6d 01 00       	add    $0x16d73,%eax
	cons_intr(kbd_proc_data);
f01005a2:	8d 80 1d 8f fe ff    	lea    -0x170e3(%eax),%eax
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
f01005bb:	81 c3 55 6d 01 00    	add    $0x16d55,%ebx
	serial_intr();
f01005c1:	e8 a3 ff ff ff       	call   f0100569 <serial_intr>
	kbd_intr();
f01005c6:	e8 c7 ff ff ff       	call   f0100592 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005cb:	8b 83 90 1f 00 00    	mov    0x1f90(%ebx),%eax
	return 0;
f01005d1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005d6:	3b 83 94 1f 00 00    	cmp    0x1f94(%ebx),%eax
f01005dc:	74 1e                	je     f01005fc <cons_getc+0x4d>
		c = cons.buf[cons.rpos++];
f01005de:	8d 48 01             	lea    0x1(%eax),%ecx
f01005e1:	0f b6 94 03 90 1d 00 	movzbl 0x1d90(%ebx,%eax,1),%edx
f01005e8:	00 
			cons.rpos = 0;
f01005e9:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f01005ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f3:	0f 45 c1             	cmovne %ecx,%eax
f01005f6:	89 83 90 1f 00 00    	mov    %eax,0x1f90(%ebx)
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
f0100611:	81 c3 ff 6c 01 00    	add    $0x16cff,%ebx
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
f0100642:	89 8b a0 1f 00 00    	mov    %ecx,0x1fa0(%ebx)
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
f010066a:	89 bb 9c 1f 00 00    	mov    %edi,0x1f9c(%ebx)
	pos |= inb(addr_6845 + 1);
f0100670:	0f b6 c0             	movzbl %al,%eax
f0100673:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f0100676:	66 89 83 98 1f 00 00 	mov    %ax,0x1f98(%ebx)
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
f01006ce:	0f 95 83 a4 1f 00 00 	setne  0x1fa4(%ebx)
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
f0100707:	8d 83 57 ce fe ff    	lea    -0x131a9(%ebx),%eax
f010070d:	50                   	push   %eax
f010070e:	e8 ae 29 00 00       	call   f01030c1 <cprintf>
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
f0100751:	81 c3 bf 6b 01 00    	add    $0x16bbf,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100757:	83 ec 04             	sub    $0x4,%esp
f010075a:	8d 83 90 d0 fe ff    	lea    -0x12f70(%ebx),%eax
f0100760:	50                   	push   %eax
f0100761:	8d 83 ae d0 fe ff    	lea    -0x12f52(%ebx),%eax
f0100767:	50                   	push   %eax
f0100768:	8d b3 b3 d0 fe ff    	lea    -0x12f4d(%ebx),%esi
f010076e:	56                   	push   %esi
f010076f:	e8 4d 29 00 00       	call   f01030c1 <cprintf>
f0100774:	83 c4 0c             	add    $0xc,%esp
f0100777:	8d 83 6c d1 fe ff    	lea    -0x12e94(%ebx),%eax
f010077d:	50                   	push   %eax
f010077e:	8d 83 bc d0 fe ff    	lea    -0x12f44(%ebx),%eax
f0100784:	50                   	push   %eax
f0100785:	56                   	push   %esi
f0100786:	e8 36 29 00 00       	call   f01030c1 <cprintf>
f010078b:	83 c4 0c             	add    $0xc,%esp
f010078e:	8d 83 94 d1 fe ff    	lea    -0x12e6c(%ebx),%eax
f0100794:	50                   	push   %eax
f0100795:	8d 83 c5 d0 fe ff    	lea    -0x12f3b(%ebx),%eax
f010079b:	50                   	push   %eax
f010079c:	56                   	push   %esi
f010079d:	e8 1f 29 00 00       	call   f01030c1 <cprintf>
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
f01007bc:	81 c3 54 6b 01 00    	add    $0x16b54,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c2:	8d 83 cf d0 fe ff    	lea    -0x12f31(%ebx),%eax
f01007c8:	50                   	push   %eax
f01007c9:	e8 f3 28 00 00       	call   f01030c1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ce:	83 c4 08             	add    $0x8,%esp
f01007d1:	ff b3 f0 ff ff ff    	push   -0x10(%ebx)
f01007d7:	8d 83 c0 d1 fe ff    	lea    -0x12e40(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	e8 de 28 00 00       	call   f01030c1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007ec:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f2:	50                   	push   %eax
f01007f3:	57                   	push   %edi
f01007f4:	8d 83 e8 d1 fe ff    	lea    -0x12e18(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 c1 28 00 00       	call   f01030c1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	c7 c0 f1 40 10 f0    	mov    $0xf01040f1,%eax
f0100809:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010080f:	52                   	push   %edx
f0100810:	50                   	push   %eax
f0100811:	8d 83 0c d2 fe ff    	lea    -0x12df4(%ebx),%eax
f0100817:	50                   	push   %eax
f0100818:	e8 a4 28 00 00       	call   f01030c1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010081d:	83 c4 0c             	add    $0xc,%esp
f0100820:	c7 c0 60 90 11 f0    	mov    $0xf0119060,%eax
f0100826:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010082c:	52                   	push   %edx
f010082d:	50                   	push   %eax
f010082e:	8d 83 30 d2 fe ff    	lea    -0x12dd0(%ebx),%eax
f0100834:	50                   	push   %eax
f0100835:	e8 87 28 00 00       	call   f01030c1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083a:	83 c4 0c             	add    $0xc,%esp
f010083d:	c7 c6 e0 96 11 f0    	mov    $0xf01196e0,%esi
f0100843:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100849:	50                   	push   %eax
f010084a:	56                   	push   %esi
f010084b:	8d 83 54 d2 fe ff    	lea    -0x12dac(%ebx),%eax
f0100851:	50                   	push   %eax
f0100852:	e8 6a 28 00 00       	call   f01030c1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100857:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085a:	29 fe                	sub    %edi,%esi
f010085c:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100862:	c1 fe 0a             	sar    $0xa,%esi
f0100865:	56                   	push   %esi
f0100866:	8d 83 78 d2 fe ff    	lea    -0x12d88(%ebx),%eax
f010086c:	50                   	push   %eax
f010086d:	e8 4f 28 00 00       	call   f01030c1 <cprintf>
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
f010088d:	81 c3 83 6a 01 00    	add    $0x16a83,%ebx
	cprintf("Stack backtrace:\n");
f0100893:	8d 83 e8 d0 fe ff    	lea    -0x12f18(%ebx),%eax
f0100899:	50                   	push   %eax
f010089a:	e8 22 28 00 00       	call   f01030c1 <cprintf>

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
f01008a6:	8d 83 fa d0 fe ff    	lea    -0x12f06(%ebx),%eax
f01008ac:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for (int i = 0; i < 5; i++) {
			cprintf(" %08x", *(ebp + 2 + i));
f01008af:	8d 83 15 d1 fe ff    	lea    -0x12eeb(%ebx),%eax
f01008b5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while (ebp) {
f01008b8:	eb 39                	jmp    f01008f3 <mon_backtrace+0x74>
			if (i == 4) {
				cprintf("\n");
f01008ba:	83 ec 0c             	sub    $0xc,%esp
f01008bd:	8d 83 c6 d5 fe ff    	lea    -0x12a3a(%ebx),%eax
f01008c3:	50                   	push   %eax
f01008c4:	e8 f8 27 00 00       	call   f01030c1 <cprintf>
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
f01008e2:	8d 83 1b d1 fe ff    	lea    -0x12ee5(%ebx),%eax
f01008e8:	50                   	push   %eax
f01008e9:	e8 d3 27 00 00       	call   f01030c1 <cprintf>
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
f0100907:	e8 be 28 00 00       	call   f01031ca <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args", ebp, eip);
f010090c:	83 c4 0c             	add    $0xc,%esp
f010090f:	56                   	push   %esi
f0100910:	57                   	push   %edi
f0100911:	ff 75 bc             	push   -0x44(%ebp)
f0100914:	e8 a8 27 00 00       	call   f01030c1 <cprintf>
f0100919:	83 c4 10             	add    $0x10,%esp
		for (int i = 0; i < 5; i++) {
f010091c:	be 00 00 00 00       	mov    $0x0,%esi
			cprintf(" %08x", *(ebp + 2 + i));
f0100921:	83 ec 08             	sub    $0x8,%esp
f0100924:	ff 74 b7 08          	push   0x8(%edi,%esi,4)
f0100928:	ff 75 c4             	push   -0x3c(%ebp)
f010092b:	e8 91 27 00 00       	call   f01030c1 <cprintf>
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
f010095d:	81 c3 b3 69 01 00    	add    $0x169b3,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100963:	8d 83 a4 d2 fe ff    	lea    -0x12d5c(%ebx),%eax
f0100969:	50                   	push   %eax
f010096a:	e8 52 27 00 00       	call   f01030c1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010096f:	8d 83 c8 d2 fe ff    	lea    -0x12d38(%ebx),%eax
f0100975:	89 04 24             	mov    %eax,(%esp)
f0100978:	e8 44 27 00 00       	call   f01030c1 <cprintf>
f010097d:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100980:	8d bb 32 d1 fe ff    	lea    -0x12ece(%ebx),%edi
f0100986:	eb 4a                	jmp    f01009d2 <monitor+0x83>
f0100988:	83 ec 08             	sub    $0x8,%esp
f010098b:	0f be c0             	movsbl %al,%eax
f010098e:	50                   	push   %eax
f010098f:	57                   	push   %edi
f0100990:	e8 ed 32 00 00       	call   f0103c82 <strchr>
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
f01009c3:	8d 83 37 d1 fe ff    	lea    -0x12ec9(%ebx),%eax
f01009c9:	50                   	push   %eax
f01009ca:	e8 f2 26 00 00       	call   f01030c1 <cprintf>
			return 0;
f01009cf:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009d2:	8d 83 2e d1 fe ff    	lea    -0x12ed2(%ebx),%eax
f01009d8:	89 c6                	mov    %eax,%esi
f01009da:	83 ec 0c             	sub    $0xc,%esp
f01009dd:	56                   	push   %esi
f01009de:	e8 4e 30 00 00       	call   f0103a31 <readline>
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
f0100a0e:	e8 6f 32 00 00       	call   f0103c82 <strchr>
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
f0100a34:	8d b3 10 1d 00 00    	lea    0x1d10(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a3f:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100a42:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a44:	83 ec 08             	sub    $0x8,%esp
f0100a47:	ff 36                	push   (%esi)
f0100a49:	ff 75 a8             	push   -0x58(%ebp)
f0100a4c:	e8 d1 31 00 00       	call   f0103c22 <strcmp>
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
f0100a6c:	8d 83 54 d1 fe ff    	lea    -0x12eac(%ebx),%eax
f0100a72:	50                   	push   %eax
f0100a73:	e8 49 26 00 00       	call   f01030c1 <cprintf>
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
f0100a95:	ff 94 83 18 1d 00 00 	call   *0x1d18(%ebx,%eax,4)
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
f0100abd:	81 c3 53 68 01 00    	add    $0x16853,%ebx
f0100ac3:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac5:	50                   	push   %eax
f0100ac6:	e8 66 25 00 00       	call   f0103031 <mc146818_read>
f0100acb:	89 c7                	mov    %eax,%edi
f0100acd:	83 c6 01             	add    $0x1,%esi
f0100ad0:	89 34 24             	mov    %esi,(%esp)
f0100ad3:	e8 59 25 00 00       	call   f0103031 <mc146818_read>
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
f0100ae5:	e8 3b 25 00 00       	call   f0103025 <__x86.get_pc_thunk.dx>
f0100aea:	81 c2 26 68 01 00    	add    $0x16826,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100af0:	83 ba b4 1f 00 00 00 	cmpl   $0x0,0x1fb4(%edx)
f0100af7:	74 3c                	je     f0100b35 <boot_alloc+0x50>
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("KERNBASE is %x\n", KERNBASE);
	
	result = nextfree;
f0100af9:	8b 8a b4 1f 00 00    	mov    0x1fb4(%edx),%ecx
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
f0100b16:	89 82 b4 1f 00 00    	mov    %eax,0x1fb4(%edx)
		if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE)
f0100b1c:	05 00 00 00 10       	add    $0x10000000,%eax
f0100b21:	8b 9a b0 1f 00 00    	mov    0x1fb0(%edx),%ebx
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
f0100b47:	89 8a b4 1f 00 00    	mov    %ecx,0x1fb4(%edx)
f0100b4d:	eb aa                	jmp    f0100af9 <boot_alloc+0x14>
			panic("boot_alloc: out of memory\n");
f0100b4f:	83 ec 04             	sub    $0x4,%esp
f0100b52:	8d 82 ed d2 fe ff    	lea    -0x12d13(%edx),%eax
f0100b58:	50                   	push   %eax
f0100b59:	6a 72                	push   $0x72
f0100b5b:	8d 82 08 d3 fe ff    	lea    -0x12cf8(%edx),%eax
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
f0100b73:	e8 b1 24 00 00       	call   f0103029 <__x86.get_pc_thunk.cx>
f0100b78:	81 c1 98 67 01 00    	add    $0x16798,%ecx
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
f0100b98:	3b 91 b0 1f 00 00    	cmp    0x1fb0(%ecx),%edx
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
f0100bc7:	8d 81 f8 d5 fe ff    	lea    -0x12a08(%ecx),%eax
f0100bcd:	50                   	push   %eax
f0100bce:	68 d1 02 00 00       	push   $0x2d1
f0100bd3:	8d 81 08 d3 fe ff    	lea    -0x12cf8(%ecx),%eax
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
f0100bf1:	e8 37 24 00 00       	call   f010302d <__x86.get_pc_thunk.di>
f0100bf6:	81 c7 1a 67 01 00    	add    $0x1671a,%edi
f0100bfc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bff:	84 c0                	test   %al,%al
f0100c01:	0f 85 dc 02 00 00    	jne    f0100ee3 <check_page_free_list+0x2fb>
	if (!page_free_list)
f0100c07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c0a:	83 b8 b8 1f 00 00 00 	cmpl   $0x0,0x1fb8(%eax)
f0100c11:	74 0a                	je     f0100c1d <check_page_free_list+0x35>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c13:	bf 00 04 00 00       	mov    $0x400,%edi
f0100c18:	e9 29 03 00 00       	jmp    f0100f46 <check_page_free_list+0x35e>
		panic("'page_free_list' is a null pointer!");
f0100c1d:	83 ec 04             	sub    $0x4,%esp
f0100c20:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c23:	8d 83 1c d6 fe ff    	lea    -0x129e4(%ebx),%eax
f0100c29:	50                   	push   %eax
f0100c2a:	68 12 02 00 00       	push   $0x212
f0100c2f:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100c35:	50                   	push   %eax
f0100c36:	e8 ba f4 ff ff       	call   f01000f5 <_panic>
f0100c3b:	50                   	push   %eax
f0100c3c:	89 cb                	mov    %ecx,%ebx
f0100c3e:	8d 81 f8 d5 fe ff    	lea    -0x12a08(%ecx),%eax
f0100c44:	50                   	push   %eax
f0100c45:	6a 52                	push   $0x52
f0100c47:	8d 81 14 d3 fe ff    	lea    -0x12cec(%ecx),%eax
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
f0100c5e:	2b 81 a8 1f 00 00    	sub    0x1fa8(%ecx),%eax
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
f0100c78:	3b 91 b0 1f 00 00    	cmp    0x1fb0(%ecx),%edx
f0100c7e:	73 bb                	jae    f0100c3b <check_page_free_list+0x53>
			memset(page2kva(pp), 0x97, 128);
f0100c80:	83 ec 04             	sub    $0x4,%esp
f0100c83:	68 80 00 00 00       	push   $0x80
f0100c88:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100c8d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c92:	50                   	push   %eax
f0100c93:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100c96:	e8 26 30 00 00       	call   f0103cc1 <memset>
f0100c9b:	83 c4 10             	add    $0x10,%esp
f0100c9e:	eb b3                	jmp    f0100c53 <check_page_free_list+0x6b>
	first_free_page = (char *) boot_alloc(0);
f0100ca0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca5:	e8 3b fe ff ff       	call   f0100ae5 <boot_alloc>
f0100caa:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cb0:	8b 90 b8 1f 00 00    	mov    0x1fb8(%eax),%edx
		assert(pp >= pages);
f0100cb6:	8b 88 a8 1f 00 00    	mov    0x1fa8(%eax),%ecx
		assert(pp < pages + npages);
f0100cbc:	8b 80 b0 1f 00 00    	mov    0x1fb0(%eax),%eax
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
f0100cdd:	8d 83 22 d3 fe ff    	lea    -0x12cde(%ebx),%eax
f0100ce3:	50                   	push   %eax
f0100ce4:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100cea:	50                   	push   %eax
f0100ceb:	68 2c 02 00 00       	push   $0x22c
f0100cf0:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100cf6:	50                   	push   %eax
f0100cf7:	e8 f9 f3 ff ff       	call   f01000f5 <_panic>
		assert(pp < pages + npages);
f0100cfc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100cff:	8d 83 43 d3 fe ff    	lea    -0x12cbd(%ebx),%eax
f0100d05:	50                   	push   %eax
f0100d06:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100d0c:	50                   	push   %eax
f0100d0d:	68 2d 02 00 00       	push   $0x22d
f0100d12:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100d18:	50                   	push   %eax
f0100d19:	e8 d7 f3 ff ff       	call   f01000f5 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d1e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d21:	8d 83 40 d6 fe ff    	lea    -0x129c0(%ebx),%eax
f0100d27:	50                   	push   %eax
f0100d28:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100d2e:	50                   	push   %eax
f0100d2f:	68 2e 02 00 00       	push   $0x22e
f0100d34:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100d3a:	50                   	push   %eax
f0100d3b:	e8 b5 f3 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) != 0);
f0100d40:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d43:	8d 83 57 d3 fe ff    	lea    -0x12ca9(%ebx),%eax
f0100d49:	50                   	push   %eax
f0100d4a:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100d50:	50                   	push   %eax
f0100d51:	68 31 02 00 00       	push   $0x231
f0100d56:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100d5c:	50                   	push   %eax
f0100d5d:	e8 93 f3 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d65:	8d 83 68 d3 fe ff    	lea    -0x12c98(%ebx),%eax
f0100d6b:	50                   	push   %eax
f0100d6c:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100d72:	50                   	push   %eax
f0100d73:	68 32 02 00 00       	push   $0x232
f0100d78:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100d7e:	50                   	push   %eax
f0100d7f:	e8 71 f3 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d84:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d87:	8d 83 74 d6 fe ff    	lea    -0x1298c(%ebx),%eax
f0100d8d:	50                   	push   %eax
f0100d8e:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100d94:	50                   	push   %eax
f0100d95:	68 33 02 00 00       	push   $0x233
f0100d9a:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100da0:	50                   	push   %eax
f0100da1:	e8 4f f3 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100da9:	8d 83 81 d3 fe ff    	lea    -0x12c7f(%ebx),%eax
f0100daf:	50                   	push   %eax
f0100db0:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100db6:	50                   	push   %eax
f0100db7:	68 34 02 00 00       	push   $0x234
f0100dbc:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
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
f0100e43:	8d 83 f8 d5 fe ff    	lea    -0x12a08(%ebx),%eax
f0100e49:	50                   	push   %eax
f0100e4a:	6a 52                	push   $0x52
f0100e4c:	8d 83 14 d3 fe ff    	lea    -0x12cec(%ebx),%eax
f0100e52:	50                   	push   %eax
f0100e53:	e8 9d f2 ff ff       	call   f01000f5 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100e58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e5b:	8d 83 98 d6 fe ff    	lea    -0x12968(%ebx),%eax
f0100e61:	50                   	push   %eax
f0100e62:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100e68:	50                   	push   %eax
f0100e69:	68 35 02 00 00       	push   $0x235
f0100e6e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
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
f0100e8b:	8d 83 e0 d6 fe ff    	lea    -0x12920(%ebx),%eax
f0100e91:	50                   	push   %eax
f0100e92:	e8 2a 22 00 00       	call   f01030c1 <cprintf>
}
f0100e97:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e9a:	5b                   	pop    %ebx
f0100e9b:	5e                   	pop    %esi
f0100e9c:	5f                   	pop    %edi
f0100e9d:	5d                   	pop    %ebp
f0100e9e:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100e9f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ea2:	8d 83 9b d3 fe ff    	lea    -0x12c65(%ebx),%eax
f0100ea8:	50                   	push   %eax
f0100ea9:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100eaf:	50                   	push   %eax
f0100eb0:	68 3d 02 00 00       	push   $0x23d
f0100eb5:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100ebb:	50                   	push   %eax
f0100ebc:	e8 34 f2 ff ff       	call   f01000f5 <_panic>
	assert(nfree_extmem > 0);
f0100ec1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100ec4:	8d 83 ad d3 fe ff    	lea    -0x12c53(%ebx),%eax
f0100eca:	50                   	push   %eax
f0100ecb:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0100ed1:	50                   	push   %eax
f0100ed2:	68 3e 02 00 00       	push   $0x23e
f0100ed7:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100edd:	50                   	push   %eax
f0100ede:	e8 12 f2 ff ff       	call   f01000f5 <_panic>
	if (!page_free_list)
f0100ee3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ee6:	8b 80 b8 1f 00 00    	mov    0x1fb8(%eax),%eax
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
f0100f05:	2b 97 a8 1f 00 00    	sub    0x1fa8(%edi),%edx
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
f0100f3b:	89 87 b8 1f 00 00    	mov    %eax,0x1fb8(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f41:	bf 01 00 00 00       	mov    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100f49:	8b b0 b8 1f 00 00    	mov    0x1fb8(%eax),%esi
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
f0100f62:	81 c3 ae 63 01 00    	add    $0x163ae,%ebx
	size_t kernel_end = PADDR(boot_alloc(0)) / PGSIZE;
f0100f68:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f6d:	e8 73 fb ff ff       	call   f0100ae5 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100f72:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f77:	76 1a                	jbe    f0100f93 <page_init+0x3f>
	return (physaddr_t)kva - KERNBASE;
f0100f79:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
f0100f7f:	c1 ee 0c             	shr    $0xc,%esi
f0100f82:	8b bb b8 1f 00 00    	mov    0x1fb8(%ebx),%edi
	for (i = 0; i < npages; i++) {
f0100f88:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f0100f8c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f91:	eb 22                	jmp    f0100fb5 <page_init+0x61>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f93:	50                   	push   %eax
f0100f94:	8d 83 04 d7 fe ff    	lea    -0x128fc(%ebx),%eax
f0100f9a:	50                   	push   %eax
f0100f9b:	68 0f 01 00 00       	push   $0x10f
f0100fa0:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0100fa6:	50                   	push   %eax
f0100fa7:	e8 49 f1 ff ff       	call   f01000f5 <_panic>
			pages[i].pp_link = NULL;
f0100fac:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	for (i = 0; i < npages; i++) {
f0100fb2:	83 c0 01             	add    $0x1,%eax
f0100fb5:	39 83 b0 1f 00 00    	cmp    %eax,0x1fb0(%ebx)
f0100fbb:	76 34                	jbe    f0100ff1 <page_init+0x9d>
f0100fbd:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		pages[i].pp_ref = 0;
f0100fc4:	89 ca                	mov    %ecx,%edx
f0100fc6:	03 93 a8 1f 00 00    	add    0x1fa8(%ebx),%edx
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
f0100fe5:	03 bb a8 1f 00 00    	add    0x1fa8(%ebx),%edi
f0100feb:	c6 45 e7 01          	movb   $0x1,-0x19(%ebp)
f0100fef:	eb c1                	jmp    f0100fb2 <page_init+0x5e>
f0100ff1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100ff5:	74 06                	je     f0100ffd <page_init+0xa9>
f0100ff7:	89 bb b8 1f 00 00    	mov    %edi,0x1fb8(%ebx)
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
f010100f:	81 c3 01 63 01 00    	add    $0x16301,%ebx
	if (page_free_list == NULL) {
f0101015:	8b b3 b8 1f 00 00    	mov    0x1fb8(%ebx),%esi
f010101b:	85 f6                	test   %esi,%esi
f010101d:	74 14                	je     f0101033 <page_alloc+0x2e>
	page_free_list = page_free_list -> pp_link;
f010101f:	8b 06                	mov    (%esi),%eax
f0101021:	89 83 b8 1f 00 00    	mov    %eax,0x1fb8(%ebx)
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
f010103e:	2b 83 a8 1f 00 00    	sub    0x1fa8(%ebx),%eax
f0101044:	c1 f8 03             	sar    $0x3,%eax
f0101047:	89 c2                	mov    %eax,%edx
f0101049:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f010104c:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101051:	3b 83 b0 1f 00 00    	cmp    0x1fb0(%ebx),%eax
f0101057:	73 1b                	jae    f0101074 <page_alloc+0x6f>
		memset(page2kva(nowpage), 0, PGSIZE);
f0101059:	83 ec 04             	sub    $0x4,%esp
f010105c:	68 00 10 00 00       	push   $0x1000
f0101061:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101063:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101069:	52                   	push   %edx
f010106a:	e8 52 2c 00 00       	call   f0103cc1 <memset>
f010106f:	83 c4 10             	add    $0x10,%esp
f0101072:	eb bf                	jmp    f0101033 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101074:	52                   	push   %edx
f0101075:	8d 83 f8 d5 fe ff    	lea    -0x12a08(%ebx),%eax
f010107b:	50                   	push   %eax
f010107c:	6a 52                	push   $0x52
f010107e:	8d 83 14 d3 fe ff    	lea    -0x12cec(%ebx),%eax
f0101084:	50                   	push   %eax
f0101085:	e8 6b f0 ff ff       	call   f01000f5 <_panic>

f010108a <page_free>:
{
f010108a:	55                   	push   %ebp
f010108b:	89 e5                	mov    %esp,%ebp
f010108d:	53                   	push   %ebx
f010108e:	83 ec 04             	sub    $0x4,%esp
f0101091:	e8 15 f1 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0101096:	81 c3 7a 62 01 00    	add    $0x1627a,%ebx
f010109c:	8b 45 08             	mov    0x8(%ebp),%eax
	if ((pp->pp_link != NULL) || (pp->pp_ref != 0)) {
f010109f:	83 38 00             	cmpl   $0x0,(%eax)
f01010a2:	75 1a                	jne    f01010be <page_free+0x34>
f01010a4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01010a9:	75 13                	jne    f01010be <page_free+0x34>
	pp->pp_link = page_free_list;
f01010ab:	8b 8b b8 1f 00 00    	mov    0x1fb8(%ebx),%ecx
f01010b1:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01010b3:	89 83 b8 1f 00 00    	mov    %eax,0x1fb8(%ebx)
}
f01010b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010bc:	c9                   	leave  
f01010bd:	c3                   	ret    
		panic("page_free: pp->pp_link != NULL or pp->pp_ref != 0");
f01010be:	83 ec 04             	sub    $0x4,%esp
f01010c1:	8d 83 28 d7 fe ff    	lea    -0x128d8(%ebx),%eax
f01010c7:	50                   	push   %eax
f01010c8:	68 46 01 00 00       	push   $0x146
f01010cd:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
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
f010110b:	e8 1d 1f 00 00       	call   f010302d <__x86.get_pc_thunk.di>
f0101110:	81 c7 00 62 01 00    	add    $0x16200,%edi
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
f0101142:	2b 97 a8 1f 00 00    	sub    0x1fa8(%edi),%edx
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
f0101165:	3b 87 b0 1f 00 00    	cmp    0x1fb0(%edi),%eax
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
f0101186:	8d 87 f8 d5 fe ff    	lea    -0x12a08(%edi),%eax
f010118c:	50                   	push   %eax
f010118d:	68 7d 01 00 00       	push   $0x17d
f0101192:	8d 87 08 d3 fe ff    	lea    -0x12cf8(%edi),%eax
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
f01011fd:	81 c3 13 61 01 00    	add    $0x16113,%ebx
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
f010122d:	39 83 b0 1f 00 00    	cmp    %eax,0x1fb0(%ebx)
f0101233:	76 10                	jbe    f0101245 <page_lookup+0x52>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101235:	8b 93 a8 1f 00 00    	mov    0x1fa8(%ebx),%edx
f010123b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f010123e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101241:	5b                   	pop    %ebx
f0101242:	5e                   	pop    %esi
f0101243:	5d                   	pop    %ebp
f0101244:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101245:	83 ec 04             	sub    $0x4,%esp
f0101248:	8d 83 5c d7 fe ff    	lea    -0x128a4(%ebx),%eax
f010124e:	50                   	push   %eax
f010124f:	6a 4b                	push   $0x4b
f0101251:	8d 83 14 d3 fe ff    	lea    -0x12cec(%ebx),%eax
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
f01012b3:	e8 75 1d 00 00       	call   f010302d <__x86.get_pc_thunk.di>
f01012b8:	81 c7 58 60 01 00    	add    $0x16058,%edi
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
f01012e1:	2b 9f a8 1f 00 00    	sub    0x1fa8(%edi),%ebx
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
f010132a:	05 e6 5f 01 00       	add    $0x15fe6,%eax
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
f0101357:	0f 84 d5 00 00 00    	je     f0101432 <mem_init+0x116>
		totalmem = 16 * 1024 + ext16mem;
f010135d:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101362:	89 c2                	mov    %eax,%edx
f0101364:	c1 ea 02             	shr    $0x2,%edx
f0101367:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010136a:	89 91 b0 1f 00 00    	mov    %edx,0x1fb0(%ecx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101370:	89 c2                	mov    %eax,%edx
f0101372:	29 da                	sub    %ebx,%edx
f0101374:	52                   	push   %edx
f0101375:	53                   	push   %ebx
f0101376:	50                   	push   %eax
f0101377:	8d 81 7c d7 fe ff    	lea    -0x12884(%ecx),%eax
f010137d:	50                   	push   %eax
f010137e:	89 cb                	mov    %ecx,%ebx
f0101380:	e8 3c 1d 00 00       	call   f01030c1 <cprintf>
	cprintf("npages = %u\n", npages);
f0101385:	83 c4 08             	add    $0x8,%esp
f0101388:	ff b3 b0 1f 00 00    	push   0x1fb0(%ebx)
f010138e:	8d 83 be d3 fe ff    	lea    -0x12c42(%ebx),%eax
f0101394:	50                   	push   %eax
f0101395:	e8 27 1d 00 00       	call   f01030c1 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010139a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010139f:	e8 41 f7 ff ff       	call   f0100ae5 <boot_alloc>
f01013a4:	89 83 ac 1f 00 00    	mov    %eax,0x1fac(%ebx)
	memset(kern_pgdir, 0, PGSIZE);
f01013aa:	83 c4 0c             	add    $0xc,%esp
f01013ad:	68 00 10 00 00       	push   $0x1000
f01013b2:	6a 00                	push   $0x0
f01013b4:	50                   	push   %eax
f01013b5:	e8 07 29 00 00       	call   f0103cc1 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013ba:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01013c0:	83 c4 10             	add    $0x10,%esp
f01013c3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013c8:	76 78                	jbe    f0101442 <mem_init+0x126>
	return (physaddr_t)kva - KERNBASE;
f01013ca:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013d0:	83 ca 05             	or     $0x5,%edx
f01013d3:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01013d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01013dc:	8b 87 b0 1f 00 00    	mov    0x1fb0(%edi),%eax
f01013e2:	c1 e0 03             	shl    $0x3,%eax
f01013e5:	e8 fb f6 ff ff       	call   f0100ae5 <boot_alloc>
f01013ea:	89 87 a8 1f 00 00    	mov    %eax,0x1fa8(%edi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01013f0:	83 ec 04             	sub    $0x4,%esp
f01013f3:	8b 97 b0 1f 00 00    	mov    0x1fb0(%edi),%edx
f01013f9:	c1 e2 03             	shl    $0x3,%edx
f01013fc:	52                   	push   %edx
f01013fd:	6a 00                	push   $0x0
f01013ff:	50                   	push   %eax
f0101400:	89 fb                	mov    %edi,%ebx
f0101402:	e8 ba 28 00 00       	call   f0103cc1 <memset>
	page_init();
f0101407:	e8 48 fb ff ff       	call   f0100f54 <page_init>
	check_page_free_list(1);
f010140c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101411:	e8 d2 f7 ff ff       	call   f0100be8 <check_page_free_list>
	if (!pages)
f0101416:	83 c4 10             	add    $0x10,%esp
f0101419:	83 bf a8 1f 00 00 00 	cmpl   $0x0,0x1fa8(%edi)
f0101420:	74 3c                	je     f010145e <mem_init+0x142>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101422:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101425:	8b 80 b8 1f 00 00    	mov    0x1fb8(%eax),%eax
f010142b:	be 00 00 00 00       	mov    $0x0,%esi
f0101430:	eb 4f                	jmp    f0101481 <mem_init+0x165>
		totalmem = 1 * 1024 + extmem;
f0101432:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101438:	85 f6                	test   %esi,%esi
f010143a:	0f 44 c3             	cmove  %ebx,%eax
f010143d:	e9 20 ff ff ff       	jmp    f0101362 <mem_init+0x46>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101442:	50                   	push   %eax
f0101443:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101446:	8d 83 04 d7 fe ff    	lea    -0x128fc(%ebx),%eax
f010144c:	50                   	push   %eax
f010144d:	68 99 00 00 00       	push   $0x99
f0101452:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101458:	50                   	push   %eax
f0101459:	e8 97 ec ff ff       	call   f01000f5 <_panic>
		panic("'pages' is a null pointer!");
f010145e:	83 ec 04             	sub    $0x4,%esp
f0101461:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101464:	8d 83 cb d3 fe ff    	lea    -0x12c35(%ebx),%eax
f010146a:	50                   	push   %eax
f010146b:	68 51 02 00 00       	push   $0x251
f0101470:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101476:	50                   	push   %eax
f0101477:	e8 79 ec ff ff       	call   f01000f5 <_panic>
		++nfree;
f010147c:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010147f:	8b 00                	mov    (%eax),%eax
f0101481:	85 c0                	test   %eax,%eax
f0101483:	75 f7                	jne    f010147c <mem_init+0x160>
	assert((pp0 = page_alloc(0)));
f0101485:	83 ec 0c             	sub    $0xc,%esp
f0101488:	6a 00                	push   $0x0
f010148a:	e8 76 fb ff ff       	call   f0101005 <page_alloc>
f010148f:	89 c3                	mov    %eax,%ebx
f0101491:	83 c4 10             	add    $0x10,%esp
f0101494:	85 c0                	test   %eax,%eax
f0101496:	0f 84 3a 02 00 00    	je     f01016d6 <mem_init+0x3ba>
	assert((pp1 = page_alloc(0)));
f010149c:	83 ec 0c             	sub    $0xc,%esp
f010149f:	6a 00                	push   $0x0
f01014a1:	e8 5f fb ff ff       	call   f0101005 <page_alloc>
f01014a6:	89 c7                	mov    %eax,%edi
f01014a8:	83 c4 10             	add    $0x10,%esp
f01014ab:	85 c0                	test   %eax,%eax
f01014ad:	0f 84 45 02 00 00    	je     f01016f8 <mem_init+0x3dc>
	assert((pp2 = page_alloc(0)));
f01014b3:	83 ec 0c             	sub    $0xc,%esp
f01014b6:	6a 00                	push   $0x0
f01014b8:	e8 48 fb ff ff       	call   f0101005 <page_alloc>
f01014bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01014c0:	83 c4 10             	add    $0x10,%esp
f01014c3:	85 c0                	test   %eax,%eax
f01014c5:	0f 84 4f 02 00 00    	je     f010171a <mem_init+0x3fe>
	assert(pp1 && pp1 != pp0);
f01014cb:	39 fb                	cmp    %edi,%ebx
f01014cd:	0f 84 69 02 00 00    	je     f010173c <mem_init+0x420>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01014d6:	39 c3                	cmp    %eax,%ebx
f01014d8:	0f 84 80 02 00 00    	je     f010175e <mem_init+0x442>
f01014de:	39 c7                	cmp    %eax,%edi
f01014e0:	0f 84 78 02 00 00    	je     f010175e <mem_init+0x442>
	return (pp - pages) << PGSHIFT;
f01014e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014e9:	8b 88 a8 1f 00 00    	mov    0x1fa8(%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014ef:	8b 90 b0 1f 00 00    	mov    0x1fb0(%eax),%edx
f01014f5:	c1 e2 0c             	shl    $0xc,%edx
f01014f8:	89 d8                	mov    %ebx,%eax
f01014fa:	29 c8                	sub    %ecx,%eax
f01014fc:	c1 f8 03             	sar    $0x3,%eax
f01014ff:	c1 e0 0c             	shl    $0xc,%eax
f0101502:	39 d0                	cmp    %edx,%eax
f0101504:	0f 83 76 02 00 00    	jae    f0101780 <mem_init+0x464>
f010150a:	89 f8                	mov    %edi,%eax
f010150c:	29 c8                	sub    %ecx,%eax
f010150e:	c1 f8 03             	sar    $0x3,%eax
f0101511:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101514:	39 c2                	cmp    %eax,%edx
f0101516:	0f 86 86 02 00 00    	jbe    f01017a2 <mem_init+0x486>
f010151c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010151f:	29 c8                	sub    %ecx,%eax
f0101521:	c1 f8 03             	sar    $0x3,%eax
f0101524:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101527:	39 c2                	cmp    %eax,%edx
f0101529:	0f 86 95 02 00 00    	jbe    f01017c4 <mem_init+0x4a8>
	fl = page_free_list;
f010152f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101532:	8b 88 b8 1f 00 00    	mov    0x1fb8(%eax),%ecx
f0101538:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f010153b:	c7 80 b8 1f 00 00 00 	movl   $0x0,0x1fb8(%eax)
f0101542:	00 00 00 
	assert(!page_alloc(0));
f0101545:	83 ec 0c             	sub    $0xc,%esp
f0101548:	6a 00                	push   $0x0
f010154a:	e8 b6 fa ff ff       	call   f0101005 <page_alloc>
f010154f:	83 c4 10             	add    $0x10,%esp
f0101552:	85 c0                	test   %eax,%eax
f0101554:	0f 85 8c 02 00 00    	jne    f01017e6 <mem_init+0x4ca>
	page_free(pp0);
f010155a:	83 ec 0c             	sub    $0xc,%esp
f010155d:	53                   	push   %ebx
f010155e:	e8 27 fb ff ff       	call   f010108a <page_free>
	page_free(pp1);
f0101563:	89 3c 24             	mov    %edi,(%esp)
f0101566:	e8 1f fb ff ff       	call   f010108a <page_free>
	page_free(pp2);
f010156b:	83 c4 04             	add    $0x4,%esp
f010156e:	ff 75 d0             	push   -0x30(%ebp)
f0101571:	e8 14 fb ff ff       	call   f010108a <page_free>
	assert((pp0 = page_alloc(0)));
f0101576:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010157d:	e8 83 fa ff ff       	call   f0101005 <page_alloc>
f0101582:	89 c7                	mov    %eax,%edi
f0101584:	83 c4 10             	add    $0x10,%esp
f0101587:	85 c0                	test   %eax,%eax
f0101589:	0f 84 79 02 00 00    	je     f0101808 <mem_init+0x4ec>
	assert((pp1 = page_alloc(0)));
f010158f:	83 ec 0c             	sub    $0xc,%esp
f0101592:	6a 00                	push   $0x0
f0101594:	e8 6c fa ff ff       	call   f0101005 <page_alloc>
f0101599:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010159c:	83 c4 10             	add    $0x10,%esp
f010159f:	85 c0                	test   %eax,%eax
f01015a1:	0f 84 83 02 00 00    	je     f010182a <mem_init+0x50e>
	assert((pp2 = page_alloc(0)));
f01015a7:	83 ec 0c             	sub    $0xc,%esp
f01015aa:	6a 00                	push   $0x0
f01015ac:	e8 54 fa ff ff       	call   f0101005 <page_alloc>
f01015b1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01015b4:	83 c4 10             	add    $0x10,%esp
f01015b7:	85 c0                	test   %eax,%eax
f01015b9:	0f 84 8d 02 00 00    	je     f010184c <mem_init+0x530>
	assert(pp1 && pp1 != pp0);
f01015bf:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f01015c2:	0f 84 a6 02 00 00    	je     f010186e <mem_init+0x552>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01015cb:	39 c7                	cmp    %eax,%edi
f01015cd:	0f 84 bd 02 00 00    	je     f0101890 <mem_init+0x574>
f01015d3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01015d6:	0f 84 b4 02 00 00    	je     f0101890 <mem_init+0x574>
	assert(!page_alloc(0));
f01015dc:	83 ec 0c             	sub    $0xc,%esp
f01015df:	6a 00                	push   $0x0
f01015e1:	e8 1f fa ff ff       	call   f0101005 <page_alloc>
f01015e6:	83 c4 10             	add    $0x10,%esp
f01015e9:	85 c0                	test   %eax,%eax
f01015eb:	0f 85 c1 02 00 00    	jne    f01018b2 <mem_init+0x596>
f01015f1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01015f4:	89 f8                	mov    %edi,%eax
f01015f6:	2b 81 a8 1f 00 00    	sub    0x1fa8(%ecx),%eax
f01015fc:	c1 f8 03             	sar    $0x3,%eax
f01015ff:	89 c2                	mov    %eax,%edx
f0101601:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101604:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101609:	3b 81 b0 1f 00 00    	cmp    0x1fb0(%ecx),%eax
f010160f:	0f 83 bf 02 00 00    	jae    f01018d4 <mem_init+0x5b8>
	memset(page2kva(pp0), 1, PGSIZE);
f0101615:	83 ec 04             	sub    $0x4,%esp
f0101618:	68 00 10 00 00       	push   $0x1000
f010161d:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010161f:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101625:	52                   	push   %edx
f0101626:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101629:	e8 93 26 00 00       	call   f0103cc1 <memset>
	page_free(pp0);
f010162e:	89 3c 24             	mov    %edi,(%esp)
f0101631:	e8 54 fa ff ff       	call   f010108a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101636:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010163d:	e8 c3 f9 ff ff       	call   f0101005 <page_alloc>
f0101642:	83 c4 10             	add    $0x10,%esp
f0101645:	85 c0                	test   %eax,%eax
f0101647:	0f 84 9f 02 00 00    	je     f01018ec <mem_init+0x5d0>
	assert(pp && pp0 == pp);
f010164d:	39 c7                	cmp    %eax,%edi
f010164f:	0f 85 b9 02 00 00    	jne    f010190e <mem_init+0x5f2>
	return (pp - pages) << PGSHIFT;
f0101655:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101658:	2b 81 a8 1f 00 00    	sub    0x1fa8(%ecx),%eax
f010165e:	c1 f8 03             	sar    $0x3,%eax
f0101661:	89 c2                	mov    %eax,%edx
f0101663:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101666:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010166b:	3b 81 b0 1f 00 00    	cmp    0x1fb0(%ecx),%eax
f0101671:	0f 83 b9 02 00 00    	jae    f0101930 <mem_init+0x614>
	return (void *)(pa + KERNBASE);
f0101677:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010167d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101683:	80 38 00             	cmpb   $0x0,(%eax)
f0101686:	0f 85 bc 02 00 00    	jne    f0101948 <mem_init+0x62c>
	for (i = 0; i < PGSIZE; i++)
f010168c:	83 c0 01             	add    $0x1,%eax
f010168f:	39 d0                	cmp    %edx,%eax
f0101691:	75 f0                	jne    f0101683 <mem_init+0x367>
	page_free_list = fl;
f0101693:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101696:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101699:	89 8b b8 1f 00 00    	mov    %ecx,0x1fb8(%ebx)
	page_free(pp0);
f010169f:	83 ec 0c             	sub    $0xc,%esp
f01016a2:	57                   	push   %edi
f01016a3:	e8 e2 f9 ff ff       	call   f010108a <page_free>
	page_free(pp1);
f01016a8:	83 c4 04             	add    $0x4,%esp
f01016ab:	ff 75 d0             	push   -0x30(%ebp)
f01016ae:	e8 d7 f9 ff ff       	call   f010108a <page_free>
	page_free(pp2);
f01016b3:	83 c4 04             	add    $0x4,%esp
f01016b6:	ff 75 cc             	push   -0x34(%ebp)
f01016b9:	e8 cc f9 ff ff       	call   f010108a <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016be:	8b 83 b8 1f 00 00    	mov    0x1fb8(%ebx),%eax
f01016c4:	83 c4 10             	add    $0x10,%esp
f01016c7:	85 c0                	test   %eax,%eax
f01016c9:	0f 84 9b 02 00 00    	je     f010196a <mem_init+0x64e>
		--nfree;
f01016cf:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016d2:	8b 00                	mov    (%eax),%eax
f01016d4:	eb f1                	jmp    f01016c7 <mem_init+0x3ab>
	assert((pp0 = page_alloc(0)));
f01016d6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016d9:	8d 83 e6 d3 fe ff    	lea    -0x12c1a(%ebx),%eax
f01016df:	50                   	push   %eax
f01016e0:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01016e6:	50                   	push   %eax
f01016e7:	68 59 02 00 00       	push   $0x259
f01016ec:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01016f2:	50                   	push   %eax
f01016f3:	e8 fd e9 ff ff       	call   f01000f5 <_panic>
	assert((pp1 = page_alloc(0)));
f01016f8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016fb:	8d 83 fc d3 fe ff    	lea    -0x12c04(%ebx),%eax
f0101701:	50                   	push   %eax
f0101702:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0101708:	50                   	push   %eax
f0101709:	68 5a 02 00 00       	push   $0x25a
f010170e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101714:	50                   	push   %eax
f0101715:	e8 db e9 ff ff       	call   f01000f5 <_panic>
	assert((pp2 = page_alloc(0)));
f010171a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010171d:	8d 83 12 d4 fe ff    	lea    -0x12bee(%ebx),%eax
f0101723:	50                   	push   %eax
f0101724:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010172a:	50                   	push   %eax
f010172b:	68 5b 02 00 00       	push   $0x25b
f0101730:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101736:	50                   	push   %eax
f0101737:	e8 b9 e9 ff ff       	call   f01000f5 <_panic>
	assert(pp1 && pp1 != pp0);
f010173c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010173f:	8d 83 28 d4 fe ff    	lea    -0x12bd8(%ebx),%eax
f0101745:	50                   	push   %eax
f0101746:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010174c:	50                   	push   %eax
f010174d:	68 5e 02 00 00       	push   $0x25e
f0101752:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101758:	50                   	push   %eax
f0101759:	e8 97 e9 ff ff       	call   f01000f5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010175e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101761:	8d 83 b8 d7 fe ff    	lea    -0x12848(%ebx),%eax
f0101767:	50                   	push   %eax
f0101768:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010176e:	50                   	push   %eax
f010176f:	68 5f 02 00 00       	push   $0x25f
f0101774:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010177a:	50                   	push   %eax
f010177b:	e8 75 e9 ff ff       	call   f01000f5 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101780:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101783:	8d 83 3a d4 fe ff    	lea    -0x12bc6(%ebx),%eax
f0101789:	50                   	push   %eax
f010178a:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0101790:	50                   	push   %eax
f0101791:	68 60 02 00 00       	push   $0x260
f0101796:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010179c:	50                   	push   %eax
f010179d:	e8 53 e9 ff ff       	call   f01000f5 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01017a2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017a5:	8d 83 57 d4 fe ff    	lea    -0x12ba9(%ebx),%eax
f01017ab:	50                   	push   %eax
f01017ac:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01017b2:	50                   	push   %eax
f01017b3:	68 61 02 00 00       	push   $0x261
f01017b8:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01017be:	50                   	push   %eax
f01017bf:	e8 31 e9 ff ff       	call   f01000f5 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01017c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017c7:	8d 83 74 d4 fe ff    	lea    -0x12b8c(%ebx),%eax
f01017cd:	50                   	push   %eax
f01017ce:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01017d4:	50                   	push   %eax
f01017d5:	68 62 02 00 00       	push   $0x262
f01017da:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01017e0:	50                   	push   %eax
f01017e1:	e8 0f e9 ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f01017e6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01017e9:	8d 83 91 d4 fe ff    	lea    -0x12b6f(%ebx),%eax
f01017ef:	50                   	push   %eax
f01017f0:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01017f6:	50                   	push   %eax
f01017f7:	68 69 02 00 00       	push   $0x269
f01017fc:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101802:	50                   	push   %eax
f0101803:	e8 ed e8 ff ff       	call   f01000f5 <_panic>
	assert((pp0 = page_alloc(0)));
f0101808:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010180b:	8d 83 e6 d3 fe ff    	lea    -0x12c1a(%ebx),%eax
f0101811:	50                   	push   %eax
f0101812:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0101818:	50                   	push   %eax
f0101819:	68 70 02 00 00       	push   $0x270
f010181e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101824:	50                   	push   %eax
f0101825:	e8 cb e8 ff ff       	call   f01000f5 <_panic>
	assert((pp1 = page_alloc(0)));
f010182a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010182d:	8d 83 fc d3 fe ff    	lea    -0x12c04(%ebx),%eax
f0101833:	50                   	push   %eax
f0101834:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010183a:	50                   	push   %eax
f010183b:	68 71 02 00 00       	push   $0x271
f0101840:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101846:	50                   	push   %eax
f0101847:	e8 a9 e8 ff ff       	call   f01000f5 <_panic>
	assert((pp2 = page_alloc(0)));
f010184c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010184f:	8d 83 12 d4 fe ff    	lea    -0x12bee(%ebx),%eax
f0101855:	50                   	push   %eax
f0101856:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010185c:	50                   	push   %eax
f010185d:	68 72 02 00 00       	push   $0x272
f0101862:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101868:	50                   	push   %eax
f0101869:	e8 87 e8 ff ff       	call   f01000f5 <_panic>
	assert(pp1 && pp1 != pp0);
f010186e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101871:	8d 83 28 d4 fe ff    	lea    -0x12bd8(%ebx),%eax
f0101877:	50                   	push   %eax
f0101878:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010187e:	50                   	push   %eax
f010187f:	68 74 02 00 00       	push   $0x274
f0101884:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010188a:	50                   	push   %eax
f010188b:	e8 65 e8 ff ff       	call   f01000f5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101890:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101893:	8d 83 b8 d7 fe ff    	lea    -0x12848(%ebx),%eax
f0101899:	50                   	push   %eax
f010189a:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01018a0:	50                   	push   %eax
f01018a1:	68 75 02 00 00       	push   $0x275
f01018a6:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01018ac:	50                   	push   %eax
f01018ad:	e8 43 e8 ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f01018b2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018b5:	8d 83 91 d4 fe ff    	lea    -0x12b6f(%ebx),%eax
f01018bb:	50                   	push   %eax
f01018bc:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01018c2:	50                   	push   %eax
f01018c3:	68 76 02 00 00       	push   $0x276
f01018c8:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01018ce:	50                   	push   %eax
f01018cf:	e8 21 e8 ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018d4:	52                   	push   %edx
f01018d5:	89 cb                	mov    %ecx,%ebx
f01018d7:	8d 81 f8 d5 fe ff    	lea    -0x12a08(%ecx),%eax
f01018dd:	50                   	push   %eax
f01018de:	6a 52                	push   $0x52
f01018e0:	8d 81 14 d3 fe ff    	lea    -0x12cec(%ecx),%eax
f01018e6:	50                   	push   %eax
f01018e7:	e8 09 e8 ff ff       	call   f01000f5 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ef:	8d 83 a0 d4 fe ff    	lea    -0x12b60(%ebx),%eax
f01018f5:	50                   	push   %eax
f01018f6:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01018fc:	50                   	push   %eax
f01018fd:	68 7b 02 00 00       	push   $0x27b
f0101902:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101908:	50                   	push   %eax
f0101909:	e8 e7 e7 ff ff       	call   f01000f5 <_panic>
	assert(pp && pp0 == pp);
f010190e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101911:	8d 83 be d4 fe ff    	lea    -0x12b42(%ebx),%eax
f0101917:	50                   	push   %eax
f0101918:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010191e:	50                   	push   %eax
f010191f:	68 7c 02 00 00       	push   $0x27c
f0101924:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010192a:	50                   	push   %eax
f010192b:	e8 c5 e7 ff ff       	call   f01000f5 <_panic>
f0101930:	52                   	push   %edx
f0101931:	89 cb                	mov    %ecx,%ebx
f0101933:	8d 81 f8 d5 fe ff    	lea    -0x12a08(%ecx),%eax
f0101939:	50                   	push   %eax
f010193a:	6a 52                	push   $0x52
f010193c:	8d 81 14 d3 fe ff    	lea    -0x12cec(%ecx),%eax
f0101942:	50                   	push   %eax
f0101943:	e8 ad e7 ff ff       	call   f01000f5 <_panic>
		assert(c[i] == 0);
f0101948:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010194b:	8d 83 ce d4 fe ff    	lea    -0x12b32(%ebx),%eax
f0101951:	50                   	push   %eax
f0101952:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0101958:	50                   	push   %eax
f0101959:	68 7f 02 00 00       	push   $0x27f
f010195e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0101964:	50                   	push   %eax
f0101965:	e8 8b e7 ff ff       	call   f01000f5 <_panic>
	assert(nfree == 0);
f010196a:	85 f6                	test   %esi,%esi
f010196c:	0f 85 25 08 00 00    	jne    f0102197 <mem_init+0xe7b>
	cprintf("check_page_alloc() succeeded!\n");
f0101972:	83 ec 0c             	sub    $0xc,%esp
f0101975:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101978:	8d 83 d8 d7 fe ff    	lea    -0x12828(%ebx),%eax
f010197e:	50                   	push   %eax
f010197f:	e8 3d 17 00 00       	call   f01030c1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101984:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010198b:	e8 75 f6 ff ff       	call   f0101005 <page_alloc>
f0101990:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101993:	83 c4 10             	add    $0x10,%esp
f0101996:	85 c0                	test   %eax,%eax
f0101998:	0f 84 1b 08 00 00    	je     f01021b9 <mem_init+0xe9d>
	assert((pp1 = page_alloc(0)));
f010199e:	83 ec 0c             	sub    $0xc,%esp
f01019a1:	6a 00                	push   $0x0
f01019a3:	e8 5d f6 ff ff       	call   f0101005 <page_alloc>
f01019a8:	89 c7                	mov    %eax,%edi
f01019aa:	83 c4 10             	add    $0x10,%esp
f01019ad:	85 c0                	test   %eax,%eax
f01019af:	0f 84 26 08 00 00    	je     f01021db <mem_init+0xebf>
	assert((pp2 = page_alloc(0)));
f01019b5:	83 ec 0c             	sub    $0xc,%esp
f01019b8:	6a 00                	push   $0x0
f01019ba:	e8 46 f6 ff ff       	call   f0101005 <page_alloc>
f01019bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01019c2:	83 c4 10             	add    $0x10,%esp
f01019c5:	85 c0                	test   %eax,%eax
f01019c7:	0f 84 30 08 00 00    	je     f01021fd <mem_init+0xee1>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019cd:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f01019d0:	0f 84 49 08 00 00    	je     f010221f <mem_init+0xf03>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019d6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01019d9:	39 c7                	cmp    %eax,%edi
f01019db:	0f 84 60 08 00 00    	je     f0102241 <mem_init+0xf25>
f01019e1:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01019e4:	0f 84 57 08 00 00    	je     f0102241 <mem_init+0xf25>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01019ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ed:	8b 88 b8 1f 00 00    	mov    0x1fb8(%eax),%ecx
f01019f3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01019f6:	c7 80 b8 1f 00 00 00 	movl   $0x0,0x1fb8(%eax)
f01019fd:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a00:	83 ec 0c             	sub    $0xc,%esp
f0101a03:	6a 00                	push   $0x0
f0101a05:	e8 fb f5 ff ff       	call   f0101005 <page_alloc>
f0101a0a:	83 c4 10             	add    $0x10,%esp
f0101a0d:	85 c0                	test   %eax,%eax
f0101a0f:	0f 85 4e 08 00 00    	jne    f0102263 <mem_init+0xf47>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a15:	83 ec 04             	sub    $0x4,%esp
f0101a18:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a1b:	50                   	push   %eax
f0101a1c:	6a 00                	push   $0x0
f0101a1e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a21:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101a27:	e8 c7 f7 ff ff       	call   f01011f3 <page_lookup>
f0101a2c:	83 c4 10             	add    $0x10,%esp
f0101a2f:	85 c0                	test   %eax,%eax
f0101a31:	0f 85 4e 08 00 00    	jne    f0102285 <mem_init+0xf69>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a37:	6a 02                	push   $0x2
f0101a39:	6a 00                	push   $0x0
f0101a3b:	57                   	push   %edi
f0101a3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3f:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101a45:	e8 60 f8 ff ff       	call   f01012aa <page_insert>
f0101a4a:	83 c4 10             	add    $0x10,%esp
f0101a4d:	85 c0                	test   %eax,%eax
f0101a4f:	0f 89 52 08 00 00    	jns    f01022a7 <mem_init+0xf8b>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a55:	83 ec 0c             	sub    $0xc,%esp
f0101a58:	ff 75 cc             	push   -0x34(%ebp)
f0101a5b:	e8 2a f6 ff ff       	call   f010108a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a60:	6a 02                	push   $0x2
f0101a62:	6a 00                	push   $0x0
f0101a64:	57                   	push   %edi
f0101a65:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a68:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101a6e:	e8 37 f8 ff ff       	call   f01012aa <page_insert>
f0101a73:	83 c4 20             	add    $0x20,%esp
f0101a76:	85 c0                	test   %eax,%eax
f0101a78:	0f 85 4b 08 00 00    	jne    f01022c9 <mem_init+0xfad>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a81:	8b 98 ac 1f 00 00    	mov    0x1fac(%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101a87:	8b b0 a8 1f 00 00    	mov    0x1fa8(%eax),%esi
f0101a8d:	8b 13                	mov    (%ebx),%edx
f0101a8f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a95:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a98:	29 f0                	sub    %esi,%eax
f0101a9a:	c1 f8 03             	sar    $0x3,%eax
f0101a9d:	c1 e0 0c             	shl    $0xc,%eax
f0101aa0:	39 c2                	cmp    %eax,%edx
f0101aa2:	0f 85 43 08 00 00    	jne    f01022eb <mem_init+0xfcf>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101aa8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101aad:	89 d8                	mov    %ebx,%eax
f0101aaf:	e8 b8 f0 ff ff       	call   f0100b6c <check_va2pa>
f0101ab4:	89 c2                	mov    %eax,%edx
f0101ab6:	89 f8                	mov    %edi,%eax
f0101ab8:	29 f0                	sub    %esi,%eax
f0101aba:	c1 f8 03             	sar    $0x3,%eax
f0101abd:	c1 e0 0c             	shl    $0xc,%eax
f0101ac0:	39 c2                	cmp    %eax,%edx
f0101ac2:	0f 85 45 08 00 00    	jne    f010230d <mem_init+0xff1>
	assert(pp1->pp_ref == 1);
f0101ac8:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101acd:	0f 85 5c 08 00 00    	jne    f010232f <mem_init+0x1013>
	assert(pp0->pp_ref == 1);
f0101ad3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101ad6:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101adb:	0f 85 70 08 00 00    	jne    f0102351 <mem_init+0x1035>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ae1:	6a 02                	push   $0x2
f0101ae3:	68 00 10 00 00       	push   $0x1000
f0101ae8:	ff 75 d0             	push   -0x30(%ebp)
f0101aeb:	53                   	push   %ebx
f0101aec:	e8 b9 f7 ff ff       	call   f01012aa <page_insert>
f0101af1:	83 c4 10             	add    $0x10,%esp
f0101af4:	85 c0                	test   %eax,%eax
f0101af6:	0f 85 77 08 00 00    	jne    f0102373 <mem_init+0x1057>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101afc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b01:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b04:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
f0101b0a:	e8 5d f0 ff ff       	call   f0100b6c <check_va2pa>
f0101b0f:	89 c2                	mov    %eax,%edx
f0101b11:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b14:	2b 83 a8 1f 00 00    	sub    0x1fa8(%ebx),%eax
f0101b1a:	c1 f8 03             	sar    $0x3,%eax
f0101b1d:	c1 e0 0c             	shl    $0xc,%eax
f0101b20:	39 c2                	cmp    %eax,%edx
f0101b22:	0f 85 6d 08 00 00    	jne    f0102395 <mem_init+0x1079>
	assert(pp2->pp_ref == 1);
f0101b28:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b2b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b30:	0f 85 81 08 00 00    	jne    f01023b7 <mem_init+0x109b>

	// should be no free memory
	assert(!page_alloc(0));
f0101b36:	83 ec 0c             	sub    $0xc,%esp
f0101b39:	6a 00                	push   $0x0
f0101b3b:	e8 c5 f4 ff ff       	call   f0101005 <page_alloc>
f0101b40:	83 c4 10             	add    $0x10,%esp
f0101b43:	85 c0                	test   %eax,%eax
f0101b45:	0f 85 8e 08 00 00    	jne    f01023d9 <mem_init+0x10bd>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b4b:	6a 02                	push   $0x2
f0101b4d:	68 00 10 00 00       	push   $0x1000
f0101b52:	ff 75 d0             	push   -0x30(%ebp)
f0101b55:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b58:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101b5e:	e8 47 f7 ff ff       	call   f01012aa <page_insert>
f0101b63:	83 c4 10             	add    $0x10,%esp
f0101b66:	85 c0                	test   %eax,%eax
f0101b68:	0f 85 8d 08 00 00    	jne    f01023fb <mem_init+0x10df>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b6e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b73:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b76:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
f0101b7c:	e8 eb ef ff ff       	call   f0100b6c <check_va2pa>
f0101b81:	89 c2                	mov    %eax,%edx
f0101b83:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b86:	2b 83 a8 1f 00 00    	sub    0x1fa8(%ebx),%eax
f0101b8c:	c1 f8 03             	sar    $0x3,%eax
f0101b8f:	c1 e0 0c             	shl    $0xc,%eax
f0101b92:	39 c2                	cmp    %eax,%edx
f0101b94:	0f 85 83 08 00 00    	jne    f010241d <mem_init+0x1101>
	assert(pp2->pp_ref == 1);
f0101b9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b9d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101ba2:	0f 85 97 08 00 00    	jne    f010243f <mem_init+0x1123>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ba8:	83 ec 0c             	sub    $0xc,%esp
f0101bab:	6a 00                	push   $0x0
f0101bad:	e8 53 f4 ff ff       	call   f0101005 <page_alloc>
f0101bb2:	83 c4 10             	add    $0x10,%esp
f0101bb5:	85 c0                	test   %eax,%eax
f0101bb7:	0f 85 a4 08 00 00    	jne    f0102461 <mem_init+0x1145>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bbd:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101bc0:	8b 91 ac 1f 00 00    	mov    0x1fac(%ecx),%edx
f0101bc6:	8b 02                	mov    (%edx),%eax
f0101bc8:	89 c3                	mov    %eax,%ebx
f0101bca:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (PGNUM(pa) >= npages)
f0101bd0:	c1 e8 0c             	shr    $0xc,%eax
f0101bd3:	3b 81 b0 1f 00 00    	cmp    0x1fb0(%ecx),%eax
f0101bd9:	0f 83 a4 08 00 00    	jae    f0102483 <mem_init+0x1167>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bdf:	83 ec 04             	sub    $0x4,%esp
f0101be2:	6a 00                	push   $0x0
f0101be4:	68 00 10 00 00       	push   $0x1000
f0101be9:	52                   	push   %edx
f0101bea:	e8 13 f5 ff ff       	call   f0101102 <pgdir_walk>
f0101bef:	81 eb fc ff ff 0f    	sub    $0xffffffc,%ebx
f0101bf5:	83 c4 10             	add    $0x10,%esp
f0101bf8:	39 d8                	cmp    %ebx,%eax
f0101bfa:	0f 85 9e 08 00 00    	jne    f010249e <mem_init+0x1182>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c00:	6a 06                	push   $0x6
f0101c02:	68 00 10 00 00       	push   $0x1000
f0101c07:	ff 75 d0             	push   -0x30(%ebp)
f0101c0a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c0d:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101c13:	e8 92 f6 ff ff       	call   f01012aa <page_insert>
f0101c18:	83 c4 10             	add    $0x10,%esp
f0101c1b:	85 c0                	test   %eax,%eax
f0101c1d:	0f 85 9d 08 00 00    	jne    f01024c0 <mem_init+0x11a4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c23:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101c26:	8b 9e ac 1f 00 00    	mov    0x1fac(%esi),%ebx
f0101c2c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c31:	89 d8                	mov    %ebx,%eax
f0101c33:	e8 34 ef ff ff       	call   f0100b6c <check_va2pa>
f0101c38:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101c3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c3d:	2b 86 a8 1f 00 00    	sub    0x1fa8(%esi),%eax
f0101c43:	c1 f8 03             	sar    $0x3,%eax
f0101c46:	c1 e0 0c             	shl    $0xc,%eax
f0101c49:	39 c2                	cmp    %eax,%edx
f0101c4b:	0f 85 91 08 00 00    	jne    f01024e2 <mem_init+0x11c6>
	assert(pp2->pp_ref == 1);
f0101c51:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c54:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c59:	0f 85 a5 08 00 00    	jne    f0102504 <mem_init+0x11e8>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c5f:	83 ec 04             	sub    $0x4,%esp
f0101c62:	6a 00                	push   $0x0
f0101c64:	68 00 10 00 00       	push   $0x1000
f0101c69:	53                   	push   %ebx
f0101c6a:	e8 93 f4 ff ff       	call   f0101102 <pgdir_walk>
f0101c6f:	83 c4 10             	add    $0x10,%esp
f0101c72:	f6 00 04             	testb  $0x4,(%eax)
f0101c75:	0f 84 ab 08 00 00    	je     f0102526 <mem_init+0x120a>
	assert(kern_pgdir[0] & PTE_U);
f0101c7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c7e:	8b 80 ac 1f 00 00    	mov    0x1fac(%eax),%eax
f0101c84:	f6 00 04             	testb  $0x4,(%eax)
f0101c87:	0f 84 bb 08 00 00    	je     f0102548 <mem_init+0x122c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c8d:	6a 02                	push   $0x2
f0101c8f:	68 00 10 00 00       	push   $0x1000
f0101c94:	ff 75 d0             	push   -0x30(%ebp)
f0101c97:	50                   	push   %eax
f0101c98:	e8 0d f6 ff ff       	call   f01012aa <page_insert>
f0101c9d:	83 c4 10             	add    $0x10,%esp
f0101ca0:	85 c0                	test   %eax,%eax
f0101ca2:	0f 85 c2 08 00 00    	jne    f010256a <mem_init+0x124e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ca8:	83 ec 04             	sub    $0x4,%esp
f0101cab:	6a 00                	push   $0x0
f0101cad:	68 00 10 00 00       	push   $0x1000
f0101cb2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cb5:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101cbb:	e8 42 f4 ff ff       	call   f0101102 <pgdir_walk>
f0101cc0:	83 c4 10             	add    $0x10,%esp
f0101cc3:	f6 00 02             	testb  $0x2,(%eax)
f0101cc6:	0f 84 c0 08 00 00    	je     f010258c <mem_init+0x1270>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ccc:	83 ec 04             	sub    $0x4,%esp
f0101ccf:	6a 00                	push   $0x0
f0101cd1:	68 00 10 00 00       	push   $0x1000
f0101cd6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd9:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101cdf:	e8 1e f4 ff ff       	call   f0101102 <pgdir_walk>
f0101ce4:	83 c4 10             	add    $0x10,%esp
f0101ce7:	f6 00 04             	testb  $0x4,(%eax)
f0101cea:	0f 85 be 08 00 00    	jne    f01025ae <mem_init+0x1292>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101cf0:	6a 02                	push   $0x2
f0101cf2:	68 00 00 40 00       	push   $0x400000
f0101cf7:	ff 75 cc             	push   -0x34(%ebp)
f0101cfa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cfd:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101d03:	e8 a2 f5 ff ff       	call   f01012aa <page_insert>
f0101d08:	83 c4 10             	add    $0x10,%esp
f0101d0b:	85 c0                	test   %eax,%eax
f0101d0d:	0f 89 bd 08 00 00    	jns    f01025d0 <mem_init+0x12b4>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d13:	6a 02                	push   $0x2
f0101d15:	68 00 10 00 00       	push   $0x1000
f0101d1a:	57                   	push   %edi
f0101d1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d1e:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101d24:	e8 81 f5 ff ff       	call   f01012aa <page_insert>
f0101d29:	83 c4 10             	add    $0x10,%esp
f0101d2c:	85 c0                	test   %eax,%eax
f0101d2e:	0f 85 be 08 00 00    	jne    f01025f2 <mem_init+0x12d6>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d34:	83 ec 04             	sub    $0x4,%esp
f0101d37:	6a 00                	push   $0x0
f0101d39:	68 00 10 00 00       	push   $0x1000
f0101d3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d41:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0101d47:	e8 b6 f3 ff ff       	call   f0101102 <pgdir_walk>
f0101d4c:	83 c4 10             	add    $0x10,%esp
f0101d4f:	f6 00 04             	testb  $0x4,(%eax)
f0101d52:	0f 85 bc 08 00 00    	jne    f0102614 <mem_init+0x12f8>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d5b:	8b b3 ac 1f 00 00    	mov    0x1fac(%ebx),%esi
f0101d61:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d66:	89 f0                	mov    %esi,%eax
f0101d68:	e8 ff ed ff ff       	call   f0100b6c <check_va2pa>
f0101d6d:	89 d9                	mov    %ebx,%ecx
f0101d6f:	89 fb                	mov    %edi,%ebx
f0101d71:	2b 99 a8 1f 00 00    	sub    0x1fa8(%ecx),%ebx
f0101d77:	c1 fb 03             	sar    $0x3,%ebx
f0101d7a:	c1 e3 0c             	shl    $0xc,%ebx
f0101d7d:	39 d8                	cmp    %ebx,%eax
f0101d7f:	0f 85 b1 08 00 00    	jne    f0102636 <mem_init+0x131a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d85:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d8a:	89 f0                	mov    %esi,%eax
f0101d8c:	e8 db ed ff ff       	call   f0100b6c <check_va2pa>
f0101d91:	39 c3                	cmp    %eax,%ebx
f0101d93:	0f 85 bf 08 00 00    	jne    f0102658 <mem_init+0x133c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d99:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101d9e:	0f 85 d6 08 00 00    	jne    f010267a <mem_init+0x135e>
	assert(pp2->pp_ref == 0);
f0101da4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101da7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101dac:	0f 85 ea 08 00 00    	jne    f010269c <mem_init+0x1380>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101db2:	83 ec 0c             	sub    $0xc,%esp
f0101db5:	6a 00                	push   $0x0
f0101db7:	e8 49 f2 ff ff       	call   f0101005 <page_alloc>
f0101dbc:	83 c4 10             	add    $0x10,%esp
f0101dbf:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101dc2:	0f 85 f6 08 00 00    	jne    f01026be <mem_init+0x13a2>
f0101dc8:	85 c0                	test   %eax,%eax
f0101dca:	0f 84 ee 08 00 00    	je     f01026be <mem_init+0x13a2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101dd0:	83 ec 08             	sub    $0x8,%esp
f0101dd3:	6a 00                	push   $0x0
f0101dd5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dd8:	ff b3 ac 1f 00 00    	push   0x1fac(%ebx)
f0101dde:	e8 81 f4 ff ff       	call   f0101264 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101de3:	8b 9b ac 1f 00 00    	mov    0x1fac(%ebx),%ebx
f0101de9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dee:	89 d8                	mov    %ebx,%eax
f0101df0:	e8 77 ed ff ff       	call   f0100b6c <check_va2pa>
f0101df5:	83 c4 10             	add    $0x10,%esp
f0101df8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dfb:	0f 85 df 08 00 00    	jne    f01026e0 <mem_init+0x13c4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e01:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e06:	89 d8                	mov    %ebx,%eax
f0101e08:	e8 5f ed ff ff       	call   f0100b6c <check_va2pa>
f0101e0d:	89 c2                	mov    %eax,%edx
f0101e0f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e12:	89 f8                	mov    %edi,%eax
f0101e14:	2b 81 a8 1f 00 00    	sub    0x1fa8(%ecx),%eax
f0101e1a:	c1 f8 03             	sar    $0x3,%eax
f0101e1d:	c1 e0 0c             	shl    $0xc,%eax
f0101e20:	39 c2                	cmp    %eax,%edx
f0101e22:	0f 85 da 08 00 00    	jne    f0102702 <mem_init+0x13e6>
	assert(pp1->pp_ref == 1);
f0101e28:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101e2d:	0f 85 f0 08 00 00    	jne    f0102723 <mem_init+0x1407>
	assert(pp2->pp_ref == 0);
f0101e33:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101e36:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101e3b:	0f 85 04 09 00 00    	jne    f0102745 <mem_init+0x1429>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e41:	6a 00                	push   $0x0
f0101e43:	68 00 10 00 00       	push   $0x1000
f0101e48:	57                   	push   %edi
f0101e49:	53                   	push   %ebx
f0101e4a:	e8 5b f4 ff ff       	call   f01012aa <page_insert>
f0101e4f:	83 c4 10             	add    $0x10,%esp
f0101e52:	85 c0                	test   %eax,%eax
f0101e54:	0f 85 0d 09 00 00    	jne    f0102767 <mem_init+0x144b>
	assert(pp1->pp_ref);
f0101e5a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e5f:	0f 84 24 09 00 00    	je     f0102789 <mem_init+0x146d>
	assert(pp1->pp_link == NULL);
f0101e65:	83 3f 00             	cmpl   $0x0,(%edi)
f0101e68:	0f 85 3d 09 00 00    	jne    f01027ab <mem_init+0x148f>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e6e:	83 ec 08             	sub    $0x8,%esp
f0101e71:	68 00 10 00 00       	push   $0x1000
f0101e76:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e79:	ff b3 ac 1f 00 00    	push   0x1fac(%ebx)
f0101e7f:	e8 e0 f3 ff ff       	call   f0101264 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e84:	8b 9b ac 1f 00 00    	mov    0x1fac(%ebx),%ebx
f0101e8a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e8f:	89 d8                	mov    %ebx,%eax
f0101e91:	e8 d6 ec ff ff       	call   f0100b6c <check_va2pa>
f0101e96:	83 c4 10             	add    $0x10,%esp
f0101e99:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e9c:	0f 85 2b 09 00 00    	jne    f01027cd <mem_init+0x14b1>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ea2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ea7:	89 d8                	mov    %ebx,%eax
f0101ea9:	e8 be ec ff ff       	call   f0100b6c <check_va2pa>
f0101eae:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb1:	0f 85 38 09 00 00    	jne    f01027ef <mem_init+0x14d3>
	assert(pp1->pp_ref == 0);
f0101eb7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101ebc:	0f 85 4f 09 00 00    	jne    f0102811 <mem_init+0x14f5>
	assert(pp2->pp_ref == 0);
f0101ec2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101ec5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101eca:	0f 85 63 09 00 00    	jne    f0102833 <mem_init+0x1517>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ed0:	83 ec 0c             	sub    $0xc,%esp
f0101ed3:	6a 00                	push   $0x0
f0101ed5:	e8 2b f1 ff ff       	call   f0101005 <page_alloc>
f0101eda:	83 c4 10             	add    $0x10,%esp
f0101edd:	85 c0                	test   %eax,%eax
f0101edf:	0f 84 70 09 00 00    	je     f0102855 <mem_init+0x1539>
f0101ee5:	39 c7                	cmp    %eax,%edi
f0101ee7:	0f 85 68 09 00 00    	jne    f0102855 <mem_init+0x1539>

	// should be no free memory
	assert(!page_alloc(0));
f0101eed:	83 ec 0c             	sub    $0xc,%esp
f0101ef0:	6a 00                	push   $0x0
f0101ef2:	e8 0e f1 ff ff       	call   f0101005 <page_alloc>
f0101ef7:	83 c4 10             	add    $0x10,%esp
f0101efa:	85 c0                	test   %eax,%eax
f0101efc:	0f 85 75 09 00 00    	jne    f0102877 <mem_init+0x155b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f05:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
f0101f0b:	8b 11                	mov    (%ecx),%edx
f0101f0d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f13:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0101f16:	2b 98 a8 1f 00 00    	sub    0x1fa8(%eax),%ebx
f0101f1c:	89 d8                	mov    %ebx,%eax
f0101f1e:	c1 f8 03             	sar    $0x3,%eax
f0101f21:	c1 e0 0c             	shl    $0xc,%eax
f0101f24:	39 c2                	cmp    %eax,%edx
f0101f26:	0f 85 6d 09 00 00    	jne    f0102899 <mem_init+0x157d>
	kern_pgdir[0] = 0;
f0101f2c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f32:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f35:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f3a:	0f 85 7b 09 00 00    	jne    f01028bb <mem_init+0x159f>
	pp0->pp_ref = 0;
f0101f40:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f43:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f49:	83 ec 0c             	sub    $0xc,%esp
f0101f4c:	50                   	push   %eax
f0101f4d:	e8 38 f1 ff ff       	call   f010108a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f52:	83 c4 0c             	add    $0xc,%esp
f0101f55:	6a 01                	push   $0x1
f0101f57:	68 00 10 40 00       	push   $0x401000
f0101f5c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f5f:	ff b3 ac 1f 00 00    	push   0x1fac(%ebx)
f0101f65:	e8 98 f1 ff ff       	call   f0101102 <pgdir_walk>
f0101f6a:	89 c6                	mov    %eax,%esi
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f6c:	89 d9                	mov    %ebx,%ecx
f0101f6e:	8b 9b ac 1f 00 00    	mov    0x1fac(%ebx),%ebx
f0101f74:	8b 43 04             	mov    0x4(%ebx),%eax
f0101f77:	89 c2                	mov    %eax,%edx
f0101f79:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101f7f:	8b 89 b0 1f 00 00    	mov    0x1fb0(%ecx),%ecx
f0101f85:	c1 e8 0c             	shr    $0xc,%eax
f0101f88:	83 c4 10             	add    $0x10,%esp
f0101f8b:	39 c8                	cmp    %ecx,%eax
f0101f8d:	0f 83 4a 09 00 00    	jae    f01028dd <mem_init+0x15c1>
	assert(ptep == ptep1 + PTX(va));
f0101f93:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0101f99:	39 d6                	cmp    %edx,%esi
f0101f9b:	0f 85 58 09 00 00    	jne    f01028f9 <mem_init+0x15dd>
	kern_pgdir[PDX(va)] = 0;
f0101fa1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0101fa8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101fab:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101fb1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fb4:	2b 83 a8 1f 00 00    	sub    0x1fa8(%ebx),%eax
f0101fba:	c1 f8 03             	sar    $0x3,%eax
f0101fbd:	89 c2                	mov    %eax,%edx
f0101fbf:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101fc2:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101fc7:	39 c1                	cmp    %eax,%ecx
f0101fc9:	0f 86 4c 09 00 00    	jbe    f010291b <mem_init+0x15ff>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101fcf:	83 ec 04             	sub    $0x4,%esp
f0101fd2:	68 00 10 00 00       	push   $0x1000
f0101fd7:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101fdc:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101fe2:	52                   	push   %edx
f0101fe3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fe6:	e8 d6 1c 00 00       	call   f0103cc1 <memset>
	page_free(pp0);
f0101feb:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0101fee:	89 34 24             	mov    %esi,(%esp)
f0101ff1:	e8 94 f0 ff ff       	call   f010108a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101ff6:	83 c4 0c             	add    $0xc,%esp
f0101ff9:	6a 01                	push   $0x1
f0101ffb:	6a 00                	push   $0x0
f0101ffd:	ff b3 ac 1f 00 00    	push   0x1fac(%ebx)
f0102003:	e8 fa f0 ff ff       	call   f0101102 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102008:	89 f0                	mov    %esi,%eax
f010200a:	2b 83 a8 1f 00 00    	sub    0x1fa8(%ebx),%eax
f0102010:	c1 f8 03             	sar    $0x3,%eax
f0102013:	89 c2                	mov    %eax,%edx
f0102015:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102018:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010201d:	83 c4 10             	add    $0x10,%esp
f0102020:	3b 83 b0 1f 00 00    	cmp    0x1fb0(%ebx),%eax
f0102026:	0f 83 05 09 00 00    	jae    f0102931 <mem_init+0x1615>
	return (void *)(pa + KERNBASE);
f010202c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102032:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102038:	8b 30                	mov    (%eax),%esi
f010203a:	83 e6 01             	and    $0x1,%esi
f010203d:	0f 85 07 09 00 00    	jne    f010294a <mem_init+0x162e>
	for(i=0; i<NPTENTRIES; i++)
f0102043:	83 c0 04             	add    $0x4,%eax
f0102046:	39 c2                	cmp    %eax,%edx
f0102048:	75 ee                	jne    f0102038 <mem_init+0xd1c>
	kern_pgdir[0] = 0;
f010204a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010204d:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
f0102053:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102059:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010205c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102062:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102065:	89 93 b8 1f 00 00    	mov    %edx,0x1fb8(%ebx)

	// free the pages we took
	page_free(pp0);
f010206b:	83 ec 0c             	sub    $0xc,%esp
f010206e:	50                   	push   %eax
f010206f:	e8 16 f0 ff ff       	call   f010108a <page_free>
	page_free(pp1);
f0102074:	89 3c 24             	mov    %edi,(%esp)
f0102077:	e8 0e f0 ff ff       	call   f010108a <page_free>
	page_free(pp2);
f010207c:	83 c4 04             	add    $0x4,%esp
f010207f:	ff 75 d0             	push   -0x30(%ebp)
f0102082:	e8 03 f0 ff ff       	call   f010108a <page_free>

	cprintf("check_page() succeeded!\n");
f0102087:	8d 83 af d5 fe ff    	lea    -0x12a51(%ebx),%eax
f010208d:	89 04 24             	mov    %eax,(%esp)
f0102090:	e8 2c 10 00 00       	call   f01030c1 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102095:	8b 83 a8 1f 00 00    	mov    0x1fa8(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010209b:	83 c4 10             	add    $0x10,%esp
f010209e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020a3:	0f 86 c3 08 00 00    	jbe    f010296c <mem_init+0x1650>
f01020a9:	83 ec 08             	sub    $0x8,%esp
f01020ac:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01020ae:	05 00 00 00 10       	add    $0x10000000,%eax
f01020b3:	50                   	push   %eax
f01020b4:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01020b9:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01020be:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020c1:	8b 87 ac 1f 00 00    	mov    0x1fac(%edi),%eax
f01020c7:	e8 db f0 ff ff       	call   f01011a7 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01020cc:	c7 c0 00 60 11 f0    	mov    $0xf0116000,%eax
f01020d2:	83 c4 10             	add    $0x10,%esp
f01020d5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020da:	0f 86 a8 08 00 00    	jbe    f0102988 <mem_init+0x166c>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstacktop) - KSTKSIZE, PTE_W | PTE_P);
f01020e0:	83 ec 08             	sub    $0x8,%esp
f01020e3:	6a 03                	push   $0x3
f01020e5:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f01020ea:	50                   	push   %eax
f01020eb:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020f0:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020f5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01020f8:	8b 87 ac 1f 00 00    	mov    0x1fac(%edi),%eax
f01020fe:	e8 a4 f0 ff ff       	call   f01011a7 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, ((uint32_t)0xffffffff - KERNBASE), 0, PTE_W | PTE_P);
f0102103:	83 c4 08             	add    $0x8,%esp
f0102106:	6a 03                	push   $0x3
f0102108:	6a 00                	push   $0x0
f010210a:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010210f:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102114:	8b 87 ac 1f 00 00    	mov    0x1fac(%edi),%eax
f010211a:	e8 88 f0 ff ff       	call   f01011a7 <boot_map_region>
	pgdir = kern_pgdir;
f010211f:	89 f9                	mov    %edi,%ecx
f0102121:	8b bf ac 1f 00 00    	mov    0x1fac(%edi),%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102127:	8b 81 b0 1f 00 00    	mov    0x1fb0(%ecx),%eax
f010212d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102130:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102137:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010213c:	89 c2                	mov    %eax,%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010213e:	8b 81 a8 1f 00 00    	mov    0x1fa8(%ecx),%eax
f0102144:	89 45 c0             	mov    %eax,-0x40(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102147:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f010214d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f0102150:	83 c4 10             	add    $0x10,%esp
f0102153:	89 f3                	mov    %esi,%ebx
f0102155:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102158:	89 c7                	mov    %eax,%edi
f010215a:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f010215d:	89 d6                	mov    %edx,%esi
f010215f:	39 de                	cmp    %ebx,%esi
f0102161:	0f 86 82 08 00 00    	jbe    f01029e9 <mem_init+0x16cd>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102167:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010216d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102170:	e8 f7 e9 ff ff       	call   f0100b6c <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102175:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f010217b:	0f 86 28 08 00 00    	jbe    f01029a9 <mem_init+0x168d>
f0102181:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102184:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102187:	39 d0                	cmp    %edx,%eax
f0102189:	0f 85 38 08 00 00    	jne    f01029c7 <mem_init+0x16ab>
	for (i = 0; i < n; i += PGSIZE)
f010218f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102195:	eb c8                	jmp    f010215f <mem_init+0xe43>
	assert(nfree == 0);
f0102197:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010219a:	8d 83 d8 d4 fe ff    	lea    -0x12b28(%ebx),%eax
f01021a0:	50                   	push   %eax
f01021a1:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01021a7:	50                   	push   %eax
f01021a8:	68 8c 02 00 00       	push   $0x28c
f01021ad:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01021b3:	50                   	push   %eax
f01021b4:	e8 3c df ff ff       	call   f01000f5 <_panic>
	assert((pp0 = page_alloc(0)));
f01021b9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021bc:	8d 83 e6 d3 fe ff    	lea    -0x12c1a(%ebx),%eax
f01021c2:	50                   	push   %eax
f01021c3:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01021c9:	50                   	push   %eax
f01021ca:	68 e5 02 00 00       	push   $0x2e5
f01021cf:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01021d5:	50                   	push   %eax
f01021d6:	e8 1a df ff ff       	call   f01000f5 <_panic>
	assert((pp1 = page_alloc(0)));
f01021db:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021de:	8d 83 fc d3 fe ff    	lea    -0x12c04(%ebx),%eax
f01021e4:	50                   	push   %eax
f01021e5:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01021eb:	50                   	push   %eax
f01021ec:	68 e6 02 00 00       	push   $0x2e6
f01021f1:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01021f7:	50                   	push   %eax
f01021f8:	e8 f8 de ff ff       	call   f01000f5 <_panic>
	assert((pp2 = page_alloc(0)));
f01021fd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102200:	8d 83 12 d4 fe ff    	lea    -0x12bee(%ebx),%eax
f0102206:	50                   	push   %eax
f0102207:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010220d:	50                   	push   %eax
f010220e:	68 e7 02 00 00       	push   $0x2e7
f0102213:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102219:	50                   	push   %eax
f010221a:	e8 d6 de ff ff       	call   f01000f5 <_panic>
	assert(pp1 && pp1 != pp0);
f010221f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102222:	8d 83 28 d4 fe ff    	lea    -0x12bd8(%ebx),%eax
f0102228:	50                   	push   %eax
f0102229:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010222f:	50                   	push   %eax
f0102230:	68 ea 02 00 00       	push   $0x2ea
f0102235:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010223b:	50                   	push   %eax
f010223c:	e8 b4 de ff ff       	call   f01000f5 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102241:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102244:	8d 83 b8 d7 fe ff    	lea    -0x12848(%ebx),%eax
f010224a:	50                   	push   %eax
f010224b:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102251:	50                   	push   %eax
f0102252:	68 eb 02 00 00       	push   $0x2eb
f0102257:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010225d:	50                   	push   %eax
f010225e:	e8 92 de ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f0102263:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102266:	8d 83 91 d4 fe ff    	lea    -0x12b6f(%ebx),%eax
f010226c:	50                   	push   %eax
f010226d:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102273:	50                   	push   %eax
f0102274:	68 f2 02 00 00       	push   $0x2f2
f0102279:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010227f:	50                   	push   %eax
f0102280:	e8 70 de ff ff       	call   f01000f5 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102285:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102288:	8d 83 f8 d7 fe ff    	lea    -0x12808(%ebx),%eax
f010228e:	50                   	push   %eax
f010228f:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102295:	50                   	push   %eax
f0102296:	68 f5 02 00 00       	push   $0x2f5
f010229b:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01022a1:	50                   	push   %eax
f01022a2:	e8 4e de ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01022a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022aa:	8d 83 30 d8 fe ff    	lea    -0x127d0(%ebx),%eax
f01022b0:	50                   	push   %eax
f01022b1:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01022b7:	50                   	push   %eax
f01022b8:	68 f8 02 00 00       	push   $0x2f8
f01022bd:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01022c3:	50                   	push   %eax
f01022c4:	e8 2c de ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01022c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022cc:	8d 83 60 d8 fe ff    	lea    -0x127a0(%ebx),%eax
f01022d2:	50                   	push   %eax
f01022d3:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01022d9:	50                   	push   %eax
f01022da:	68 fc 02 00 00       	push   $0x2fc
f01022df:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01022e5:	50                   	push   %eax
f01022e6:	e8 0a de ff ff       	call   f01000f5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022eb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022ee:	8d 83 90 d8 fe ff    	lea    -0x12770(%ebx),%eax
f01022f4:	50                   	push   %eax
f01022f5:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01022fb:	50                   	push   %eax
f01022fc:	68 fd 02 00 00       	push   $0x2fd
f0102301:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102307:	50                   	push   %eax
f0102308:	e8 e8 dd ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010230d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102310:	8d 83 b8 d8 fe ff    	lea    -0x12748(%ebx),%eax
f0102316:	50                   	push   %eax
f0102317:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010231d:	50                   	push   %eax
f010231e:	68 fe 02 00 00       	push   $0x2fe
f0102323:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102329:	50                   	push   %eax
f010232a:	e8 c6 dd ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 1);
f010232f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102332:	8d 83 e3 d4 fe ff    	lea    -0x12b1d(%ebx),%eax
f0102338:	50                   	push   %eax
f0102339:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010233f:	50                   	push   %eax
f0102340:	68 ff 02 00 00       	push   $0x2ff
f0102345:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010234b:	50                   	push   %eax
f010234c:	e8 a4 dd ff ff       	call   f01000f5 <_panic>
	assert(pp0->pp_ref == 1);
f0102351:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102354:	8d 83 f4 d4 fe ff    	lea    -0x12b0c(%ebx),%eax
f010235a:	50                   	push   %eax
f010235b:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102361:	50                   	push   %eax
f0102362:	68 00 03 00 00       	push   $0x300
f0102367:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010236d:	50                   	push   %eax
f010236e:	e8 82 dd ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102373:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102376:	8d 83 e8 d8 fe ff    	lea    -0x12718(%ebx),%eax
f010237c:	50                   	push   %eax
f010237d:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102383:	50                   	push   %eax
f0102384:	68 03 03 00 00       	push   $0x303
f0102389:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010238f:	50                   	push   %eax
f0102390:	e8 60 dd ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102395:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102398:	8d 83 24 d9 fe ff    	lea    -0x126dc(%ebx),%eax
f010239e:	50                   	push   %eax
f010239f:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01023a5:	50                   	push   %eax
f01023a6:	68 04 03 00 00       	push   $0x304
f01023ab:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01023b1:	50                   	push   %eax
f01023b2:	e8 3e dd ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 1);
f01023b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023ba:	8d 83 05 d5 fe ff    	lea    -0x12afb(%ebx),%eax
f01023c0:	50                   	push   %eax
f01023c1:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01023c7:	50                   	push   %eax
f01023c8:	68 05 03 00 00       	push   $0x305
f01023cd:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01023d3:	50                   	push   %eax
f01023d4:	e8 1c dd ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f01023d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023dc:	8d 83 91 d4 fe ff    	lea    -0x12b6f(%ebx),%eax
f01023e2:	50                   	push   %eax
f01023e3:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01023e9:	50                   	push   %eax
f01023ea:	68 08 03 00 00       	push   $0x308
f01023ef:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01023f5:	50                   	push   %eax
f01023f6:	e8 fa dc ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01023fe:	8d 83 e8 d8 fe ff    	lea    -0x12718(%ebx),%eax
f0102404:	50                   	push   %eax
f0102405:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010240b:	50                   	push   %eax
f010240c:	68 0b 03 00 00       	push   $0x30b
f0102411:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102417:	50                   	push   %eax
f0102418:	e8 d8 dc ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010241d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102420:	8d 83 24 d9 fe ff    	lea    -0x126dc(%ebx),%eax
f0102426:	50                   	push   %eax
f0102427:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010242d:	50                   	push   %eax
f010242e:	68 0c 03 00 00       	push   $0x30c
f0102433:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102439:	50                   	push   %eax
f010243a:	e8 b6 dc ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 1);
f010243f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102442:	8d 83 05 d5 fe ff    	lea    -0x12afb(%ebx),%eax
f0102448:	50                   	push   %eax
f0102449:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010244f:	50                   	push   %eax
f0102450:	68 0d 03 00 00       	push   $0x30d
f0102455:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010245b:	50                   	push   %eax
f010245c:	e8 94 dc ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f0102461:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102464:	8d 83 91 d4 fe ff    	lea    -0x12b6f(%ebx),%eax
f010246a:	50                   	push   %eax
f010246b:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102471:	50                   	push   %eax
f0102472:	68 11 03 00 00       	push   $0x311
f0102477:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010247d:	50                   	push   %eax
f010247e:	e8 72 dc ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102483:	53                   	push   %ebx
f0102484:	89 cb                	mov    %ecx,%ebx
f0102486:	8d 81 f8 d5 fe ff    	lea    -0x12a08(%ecx),%eax
f010248c:	50                   	push   %eax
f010248d:	68 14 03 00 00       	push   $0x314
f0102492:	8d 81 08 d3 fe ff    	lea    -0x12cf8(%ecx),%eax
f0102498:	50                   	push   %eax
f0102499:	e8 57 dc ff ff       	call   f01000f5 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010249e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024a1:	8d 83 54 d9 fe ff    	lea    -0x126ac(%ebx),%eax
f01024a7:	50                   	push   %eax
f01024a8:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01024ae:	50                   	push   %eax
f01024af:	68 15 03 00 00       	push   $0x315
f01024b4:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01024ba:	50                   	push   %eax
f01024bb:	e8 35 dc ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024c0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024c3:	8d 83 94 d9 fe ff    	lea    -0x1266c(%ebx),%eax
f01024c9:	50                   	push   %eax
f01024ca:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01024d0:	50                   	push   %eax
f01024d1:	68 18 03 00 00       	push   $0x318
f01024d6:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01024dc:	50                   	push   %eax
f01024dd:	e8 13 dc ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024e2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024e5:	8d 83 24 d9 fe ff    	lea    -0x126dc(%ebx),%eax
f01024eb:	50                   	push   %eax
f01024ec:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01024f2:	50                   	push   %eax
f01024f3:	68 19 03 00 00       	push   $0x319
f01024f8:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01024fe:	50                   	push   %eax
f01024ff:	e8 f1 db ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 1);
f0102504:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102507:	8d 83 05 d5 fe ff    	lea    -0x12afb(%ebx),%eax
f010250d:	50                   	push   %eax
f010250e:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102514:	50                   	push   %eax
f0102515:	68 1a 03 00 00       	push   $0x31a
f010251a:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102520:	50                   	push   %eax
f0102521:	e8 cf db ff ff       	call   f01000f5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102526:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102529:	8d 83 d4 d9 fe ff    	lea    -0x1262c(%ebx),%eax
f010252f:	50                   	push   %eax
f0102530:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102536:	50                   	push   %eax
f0102537:	68 1b 03 00 00       	push   $0x31b
f010253c:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102542:	50                   	push   %eax
f0102543:	e8 ad db ff ff       	call   f01000f5 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102548:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010254b:	8d 83 16 d5 fe ff    	lea    -0x12aea(%ebx),%eax
f0102551:	50                   	push   %eax
f0102552:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102558:	50                   	push   %eax
f0102559:	68 1c 03 00 00       	push   $0x31c
f010255e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102564:	50                   	push   %eax
f0102565:	e8 8b db ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010256a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010256d:	8d 83 e8 d8 fe ff    	lea    -0x12718(%ebx),%eax
f0102573:	50                   	push   %eax
f0102574:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010257a:	50                   	push   %eax
f010257b:	68 1f 03 00 00       	push   $0x31f
f0102580:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102586:	50                   	push   %eax
f0102587:	e8 69 db ff ff       	call   f01000f5 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010258c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010258f:	8d 83 08 da fe ff    	lea    -0x125f8(%ebx),%eax
f0102595:	50                   	push   %eax
f0102596:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010259c:	50                   	push   %eax
f010259d:	68 20 03 00 00       	push   $0x320
f01025a2:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01025a8:	50                   	push   %eax
f01025a9:	e8 47 db ff ff       	call   f01000f5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01025ae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025b1:	8d 83 3c da fe ff    	lea    -0x125c4(%ebx),%eax
f01025b7:	50                   	push   %eax
f01025b8:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01025be:	50                   	push   %eax
f01025bf:	68 21 03 00 00       	push   $0x321
f01025c4:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01025ca:	50                   	push   %eax
f01025cb:	e8 25 db ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01025d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025d3:	8d 83 74 da fe ff    	lea    -0x1258c(%ebx),%eax
f01025d9:	50                   	push   %eax
f01025da:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01025e0:	50                   	push   %eax
f01025e1:	68 24 03 00 00       	push   $0x324
f01025e6:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01025ec:	50                   	push   %eax
f01025ed:	e8 03 db ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01025f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025f5:	8d 83 ac da fe ff    	lea    -0x12554(%ebx),%eax
f01025fb:	50                   	push   %eax
f01025fc:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102602:	50                   	push   %eax
f0102603:	68 27 03 00 00       	push   $0x327
f0102608:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010260e:	50                   	push   %eax
f010260f:	e8 e1 da ff ff       	call   f01000f5 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102614:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102617:	8d 83 3c da fe ff    	lea    -0x125c4(%ebx),%eax
f010261d:	50                   	push   %eax
f010261e:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102624:	50                   	push   %eax
f0102625:	68 28 03 00 00       	push   $0x328
f010262a:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102630:	50                   	push   %eax
f0102631:	e8 bf da ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102636:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102639:	8d 83 e8 da fe ff    	lea    -0x12518(%ebx),%eax
f010263f:	50                   	push   %eax
f0102640:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102646:	50                   	push   %eax
f0102647:	68 2b 03 00 00       	push   $0x32b
f010264c:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102652:	50                   	push   %eax
f0102653:	e8 9d da ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102658:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010265b:	8d 83 14 db fe ff    	lea    -0x124ec(%ebx),%eax
f0102661:	50                   	push   %eax
f0102662:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102668:	50                   	push   %eax
f0102669:	68 2c 03 00 00       	push   $0x32c
f010266e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102674:	50                   	push   %eax
f0102675:	e8 7b da ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 2);
f010267a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010267d:	8d 83 2c d5 fe ff    	lea    -0x12ad4(%ebx),%eax
f0102683:	50                   	push   %eax
f0102684:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010268a:	50                   	push   %eax
f010268b:	68 2e 03 00 00       	push   $0x32e
f0102690:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102696:	50                   	push   %eax
f0102697:	e8 59 da ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 0);
f010269c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010269f:	8d 83 3d d5 fe ff    	lea    -0x12ac3(%ebx),%eax
f01026a5:	50                   	push   %eax
f01026a6:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01026ac:	50                   	push   %eax
f01026ad:	68 2f 03 00 00       	push   $0x32f
f01026b2:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01026b8:	50                   	push   %eax
f01026b9:	e8 37 da ff ff       	call   f01000f5 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f01026be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c1:	8d 83 44 db fe ff    	lea    -0x124bc(%ebx),%eax
f01026c7:	50                   	push   %eax
f01026c8:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01026ce:	50                   	push   %eax
f01026cf:	68 32 03 00 00       	push   $0x332
f01026d4:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01026da:	50                   	push   %eax
f01026db:	e8 15 da ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01026e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026e3:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f01026e9:	50                   	push   %eax
f01026ea:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01026f0:	50                   	push   %eax
f01026f1:	68 36 03 00 00       	push   $0x336
f01026f6:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01026fc:	50                   	push   %eax
f01026fd:	e8 f3 d9 ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102702:	89 cb                	mov    %ecx,%ebx
f0102704:	8d 81 14 db fe ff    	lea    -0x124ec(%ecx),%eax
f010270a:	50                   	push   %eax
f010270b:	8d 81 2e d3 fe ff    	lea    -0x12cd2(%ecx),%eax
f0102711:	50                   	push   %eax
f0102712:	68 37 03 00 00       	push   $0x337
f0102717:	8d 81 08 d3 fe ff    	lea    -0x12cf8(%ecx),%eax
f010271d:	50                   	push   %eax
f010271e:	e8 d2 d9 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 1);
f0102723:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102726:	8d 83 e3 d4 fe ff    	lea    -0x12b1d(%ebx),%eax
f010272c:	50                   	push   %eax
f010272d:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102733:	50                   	push   %eax
f0102734:	68 38 03 00 00       	push   $0x338
f0102739:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010273f:	50                   	push   %eax
f0102740:	e8 b0 d9 ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 0);
f0102745:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102748:	8d 83 3d d5 fe ff    	lea    -0x12ac3(%ebx),%eax
f010274e:	50                   	push   %eax
f010274f:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102755:	50                   	push   %eax
f0102756:	68 39 03 00 00       	push   $0x339
f010275b:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102761:	50                   	push   %eax
f0102762:	e8 8e d9 ff ff       	call   f01000f5 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102767:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010276a:	8d 83 8c db fe ff    	lea    -0x12474(%ebx),%eax
f0102770:	50                   	push   %eax
f0102771:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102777:	50                   	push   %eax
f0102778:	68 3c 03 00 00       	push   $0x33c
f010277d:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102783:	50                   	push   %eax
f0102784:	e8 6c d9 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref);
f0102789:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010278c:	8d 83 4e d5 fe ff    	lea    -0x12ab2(%ebx),%eax
f0102792:	50                   	push   %eax
f0102793:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102799:	50                   	push   %eax
f010279a:	68 3d 03 00 00       	push   $0x33d
f010279f:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01027a5:	50                   	push   %eax
f01027a6:	e8 4a d9 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_link == NULL);
f01027ab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027ae:	8d 83 5a d5 fe ff    	lea    -0x12aa6(%ebx),%eax
f01027b4:	50                   	push   %eax
f01027b5:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01027bb:	50                   	push   %eax
f01027bc:	68 3e 03 00 00       	push   $0x33e
f01027c1:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01027c7:	50                   	push   %eax
f01027c8:	e8 28 d9 ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01027cd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027d0:	8d 83 68 db fe ff    	lea    -0x12498(%ebx),%eax
f01027d6:	50                   	push   %eax
f01027d7:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01027dd:	50                   	push   %eax
f01027de:	68 42 03 00 00       	push   $0x342
f01027e3:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01027e9:	50                   	push   %eax
f01027ea:	e8 06 d9 ff ff       	call   f01000f5 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01027ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027f2:	8d 83 c4 db fe ff    	lea    -0x1243c(%ebx),%eax
f01027f8:	50                   	push   %eax
f01027f9:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01027ff:	50                   	push   %eax
f0102800:	68 43 03 00 00       	push   $0x343
f0102805:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010280b:	50                   	push   %eax
f010280c:	e8 e4 d8 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 0);
f0102811:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102814:	8d 83 6f d5 fe ff    	lea    -0x12a91(%ebx),%eax
f010281a:	50                   	push   %eax
f010281b:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102821:	50                   	push   %eax
f0102822:	68 44 03 00 00       	push   $0x344
f0102827:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010282d:	50                   	push   %eax
f010282e:	e8 c2 d8 ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 0);
f0102833:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102836:	8d 83 3d d5 fe ff    	lea    -0x12ac3(%ebx),%eax
f010283c:	50                   	push   %eax
f010283d:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102843:	50                   	push   %eax
f0102844:	68 45 03 00 00       	push   $0x345
f0102849:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f010284f:	50                   	push   %eax
f0102850:	e8 a0 d8 ff ff       	call   f01000f5 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102855:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102858:	8d 83 ec db fe ff    	lea    -0x12414(%ebx),%eax
f010285e:	50                   	push   %eax
f010285f:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102865:	50                   	push   %eax
f0102866:	68 48 03 00 00       	push   $0x348
f010286b:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102871:	50                   	push   %eax
f0102872:	e8 7e d8 ff ff       	call   f01000f5 <_panic>
	assert(!page_alloc(0));
f0102877:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010287a:	8d 83 91 d4 fe ff    	lea    -0x12b6f(%ebx),%eax
f0102880:	50                   	push   %eax
f0102881:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102887:	50                   	push   %eax
f0102888:	68 4b 03 00 00       	push   $0x34b
f010288d:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102893:	50                   	push   %eax
f0102894:	e8 5c d8 ff ff       	call   f01000f5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102899:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010289c:	8d 83 90 d8 fe ff    	lea    -0x12770(%ebx),%eax
f01028a2:	50                   	push   %eax
f01028a3:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01028a9:	50                   	push   %eax
f01028aa:	68 4e 03 00 00       	push   $0x34e
f01028af:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01028b5:	50                   	push   %eax
f01028b6:	e8 3a d8 ff ff       	call   f01000f5 <_panic>
	assert(pp0->pp_ref == 1);
f01028bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028be:	8d 83 f4 d4 fe ff    	lea    -0x12b0c(%ebx),%eax
f01028c4:	50                   	push   %eax
f01028c5:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01028cb:	50                   	push   %eax
f01028cc:	68 50 03 00 00       	push   $0x350
f01028d1:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01028d7:	50                   	push   %eax
f01028d8:	e8 18 d8 ff ff       	call   f01000f5 <_panic>
f01028dd:	52                   	push   %edx
f01028de:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028e1:	8d 83 f8 d5 fe ff    	lea    -0x12a08(%ebx),%eax
f01028e7:	50                   	push   %eax
f01028e8:	68 57 03 00 00       	push   $0x357
f01028ed:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01028f3:	50                   	push   %eax
f01028f4:	e8 fc d7 ff ff       	call   f01000f5 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01028f9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028fc:	8d 83 80 d5 fe ff    	lea    -0x12a80(%ebx),%eax
f0102902:	50                   	push   %eax
f0102903:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102909:	50                   	push   %eax
f010290a:	68 58 03 00 00       	push   $0x358
f010290f:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102915:	50                   	push   %eax
f0102916:	e8 da d7 ff ff       	call   f01000f5 <_panic>
f010291b:	52                   	push   %edx
f010291c:	8d 83 f8 d5 fe ff    	lea    -0x12a08(%ebx),%eax
f0102922:	50                   	push   %eax
f0102923:	6a 52                	push   $0x52
f0102925:	8d 83 14 d3 fe ff    	lea    -0x12cec(%ebx),%eax
f010292b:	50                   	push   %eax
f010292c:	e8 c4 d7 ff ff       	call   f01000f5 <_panic>
f0102931:	52                   	push   %edx
f0102932:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102935:	8d 83 f8 d5 fe ff    	lea    -0x12a08(%ebx),%eax
f010293b:	50                   	push   %eax
f010293c:	6a 52                	push   $0x52
f010293e:	8d 83 14 d3 fe ff    	lea    -0x12cec(%ebx),%eax
f0102944:	50                   	push   %eax
f0102945:	e8 ab d7 ff ff       	call   f01000f5 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010294a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010294d:	8d 83 98 d5 fe ff    	lea    -0x12a68(%ebx),%eax
f0102953:	50                   	push   %eax
f0102954:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f010295a:	50                   	push   %eax
f010295b:	68 62 03 00 00       	push   $0x362
f0102960:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102966:	50                   	push   %eax
f0102967:	e8 89 d7 ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010296c:	50                   	push   %eax
f010296d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102970:	8d 83 04 d7 fe ff    	lea    -0x128fc(%ebx),%eax
f0102976:	50                   	push   %eax
f0102977:	68 bc 00 00 00       	push   $0xbc
f010297c:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102982:	50                   	push   %eax
f0102983:	e8 6d d7 ff ff       	call   f01000f5 <_panic>
f0102988:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010298b:	ff b3 f8 ff ff ff    	push   -0x8(%ebx)
f0102991:	8d 83 04 d7 fe ff    	lea    -0x128fc(%ebx),%eax
f0102997:	50                   	push   %eax
f0102998:	68 c9 00 00 00       	push   $0xc9
f010299d:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01029a3:	50                   	push   %eax
f01029a4:	e8 4c d7 ff ff       	call   f01000f5 <_panic>
f01029a9:	ff 75 c0             	push   -0x40(%ebp)
f01029ac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029af:	8d 83 04 d7 fe ff    	lea    -0x128fc(%ebx),%eax
f01029b5:	50                   	push   %eax
f01029b6:	68 a4 02 00 00       	push   $0x2a4
f01029bb:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01029c1:	50                   	push   %eax
f01029c2:	e8 2e d7 ff ff       	call   f01000f5 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01029c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029ca:	8d 83 10 dc fe ff    	lea    -0x123f0(%ebx),%eax
f01029d0:	50                   	push   %eax
f01029d1:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f01029d7:	50                   	push   %eax
f01029d8:	68 a4 02 00 00       	push   $0x2a4
f01029dd:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f01029e3:	50                   	push   %eax
f01029e4:	e8 0c d7 ff ff       	call   f01000f5 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029e9:	8b 7d d0             	mov    -0x30(%ebp),%edi
f01029ec:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01029ef:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029f2:	c1 e0 0c             	shl    $0xc,%eax
f01029f5:	89 f3                	mov    %esi,%ebx
f01029f7:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01029fa:	89 c6                	mov    %eax,%esi
f01029fc:	39 f3                	cmp    %esi,%ebx
f01029fe:	73 3b                	jae    f0102a3b <mem_init+0x171f>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a00:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102a06:	89 f8                	mov    %edi,%eax
f0102a08:	e8 5f e1 ff ff       	call   f0100b6c <check_va2pa>
f0102a0d:	39 c3                	cmp    %eax,%ebx
f0102a0f:	75 08                	jne    f0102a19 <mem_init+0x16fd>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a11:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a17:	eb e3                	jmp    f01029fc <mem_init+0x16e0>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a19:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a1c:	8d 83 44 dc fe ff    	lea    -0x123bc(%ebx),%eax
f0102a22:	50                   	push   %eax
f0102a23:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102a29:	50                   	push   %eax
f0102a2a:	68 a9 02 00 00       	push   $0x2a9
f0102a2f:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102a35:	50                   	push   %eax
f0102a36:	e8 ba d6 ff ff       	call   f01000f5 <_panic>
f0102a3b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102a3e:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
	if ((uint32_t)kva < KERNBASE)
f0102a43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a46:	c7 c0 00 e0 10 f0    	mov    $0xf010e000,%eax
f0102a4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102a4f:	05 00 80 00 20       	add    $0x20008000,%eax
f0102a54:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102a57:	89 c6                	mov    %eax,%esi
f0102a59:	89 da                	mov    %ebx,%edx
f0102a5b:	89 f8                	mov    %edi,%eax
f0102a5d:	e8 0a e1 ff ff       	call   f0100b6c <check_va2pa>
f0102a62:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102a69:	76 4f                	jbe    f0102aba <mem_init+0x179e>
f0102a6b:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102a6e:	39 d0                	cmp    %edx,%eax
f0102a70:	75 69                	jne    f0102adb <mem_init+0x17bf>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a72:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a78:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102a7e:	75 d9                	jne    f0102a59 <mem_init+0x173d>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102a80:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102a83:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102a88:	89 f8                	mov    %edi,%eax
f0102a8a:	e8 dd e0 ff ff       	call   f0100b6c <check_va2pa>
f0102a8f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a92:	0f 84 92 00 00 00    	je     f0102b2a <mem_init+0x180e>
f0102a98:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a9b:	8d 83 b4 dc fe ff    	lea    -0x1234c(%ebx),%eax
f0102aa1:	50                   	push   %eax
f0102aa2:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102aa8:	50                   	push   %eax
f0102aa9:	68 ae 02 00 00       	push   $0x2ae
f0102aae:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102ab4:	50                   	push   %eax
f0102ab5:	e8 3b d6 ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102abd:	ff b3 fc ff ff ff    	push   -0x4(%ebx)
f0102ac3:	8d 83 04 d7 fe ff    	lea    -0x128fc(%ebx),%eax
f0102ac9:	50                   	push   %eax
f0102aca:	68 ad 02 00 00       	push   $0x2ad
f0102acf:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102ad5:	50                   	push   %eax
f0102ad6:	e8 1a d6 ff ff       	call   f01000f5 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102adb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ade:	8d 83 6c dc fe ff    	lea    -0x12394(%ebx),%eax
f0102ae4:	50                   	push   %eax
f0102ae5:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102aeb:	50                   	push   %eax
f0102aec:	68 ad 02 00 00       	push   $0x2ad
f0102af1:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102af7:	50                   	push   %eax
f0102af8:	e8 f8 d5 ff ff       	call   f01000f5 <_panic>
		switch (i) {
f0102afd:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102b03:	75 25                	jne    f0102b2a <mem_init+0x180e>
			assert(pgdir[i] & PTE_P);
f0102b05:	f6 04 b7 01          	testb  $0x1,(%edi,%esi,4)
f0102b09:	74 4f                	je     f0102b5a <mem_init+0x183e>
	for (i = 0; i < NPDENTRIES; i++) {
f0102b0b:	83 c6 01             	add    $0x1,%esi
f0102b0e:	81 fe ff 03 00 00    	cmp    $0x3ff,%esi
f0102b14:	0f 87 b1 00 00 00    	ja     f0102bcb <mem_init+0x18af>
		switch (i) {
f0102b1a:	81 fe bd 03 00 00    	cmp    $0x3bd,%esi
f0102b20:	77 db                	ja     f0102afd <mem_init+0x17e1>
f0102b22:	81 fe bb 03 00 00    	cmp    $0x3bb,%esi
f0102b28:	77 db                	ja     f0102b05 <mem_init+0x17e9>
			if (i >= PDX(KERNBASE)) {
f0102b2a:	81 fe bf 03 00 00    	cmp    $0x3bf,%esi
f0102b30:	77 4a                	ja     f0102b7c <mem_init+0x1860>
				assert(pgdir[i] == 0);
f0102b32:	83 3c b7 00          	cmpl   $0x0,(%edi,%esi,4)
f0102b36:	74 d3                	je     f0102b0b <mem_init+0x17ef>
f0102b38:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b3b:	8d 83 ea d5 fe ff    	lea    -0x12a16(%ebx),%eax
f0102b41:	50                   	push   %eax
f0102b42:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102b48:	50                   	push   %eax
f0102b49:	68 bd 02 00 00       	push   $0x2bd
f0102b4e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102b54:	50                   	push   %eax
f0102b55:	e8 9b d5 ff ff       	call   f01000f5 <_panic>
			assert(pgdir[i] & PTE_P);
f0102b5a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b5d:	8d 83 c8 d5 fe ff    	lea    -0x12a38(%ebx),%eax
f0102b63:	50                   	push   %eax
f0102b64:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102b6a:	50                   	push   %eax
f0102b6b:	68 b6 02 00 00       	push   $0x2b6
f0102b70:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102b76:	50                   	push   %eax
f0102b77:	e8 79 d5 ff ff       	call   f01000f5 <_panic>
				assert(pgdir[i] & PTE_P);
f0102b7c:	8b 04 b7             	mov    (%edi,%esi,4),%eax
f0102b7f:	a8 01                	test   $0x1,%al
f0102b81:	74 26                	je     f0102ba9 <mem_init+0x188d>
				assert(pgdir[i] & PTE_W);
f0102b83:	a8 02                	test   $0x2,%al
f0102b85:	75 84                	jne    f0102b0b <mem_init+0x17ef>
f0102b87:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b8a:	8d 83 d9 d5 fe ff    	lea    -0x12a27(%ebx),%eax
f0102b90:	50                   	push   %eax
f0102b91:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102b97:	50                   	push   %eax
f0102b98:	68 bb 02 00 00       	push   $0x2bb
f0102b9d:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102ba3:	50                   	push   %eax
f0102ba4:	e8 4c d5 ff ff       	call   f01000f5 <_panic>
				assert(pgdir[i] & PTE_P);
f0102ba9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bac:	8d 83 c8 d5 fe ff    	lea    -0x12a38(%ebx),%eax
f0102bb2:	50                   	push   %eax
f0102bb3:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102bb9:	50                   	push   %eax
f0102bba:	68 ba 02 00 00       	push   $0x2ba
f0102bbf:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102bc5:	50                   	push   %eax
f0102bc6:	e8 2a d5 ff ff       	call   f01000f5 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102bcb:	83 ec 0c             	sub    $0xc,%esp
f0102bce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bd1:	8d 83 e4 dc fe ff    	lea    -0x1231c(%ebx),%eax
f0102bd7:	50                   	push   %eax
f0102bd8:	e8 e4 04 00 00       	call   f01030c1 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102bdd:	8b 83 ac 1f 00 00    	mov    0x1fac(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f0102be3:	83 c4 10             	add    $0x10,%esp
f0102be6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102beb:	0f 86 2c 02 00 00    	jbe    f0102e1d <mem_init+0x1b01>
	return (physaddr_t)kva - KERNBASE;
f0102bf1:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102bf6:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102bf9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bfe:	e8 e5 df ff ff       	call   f0100be8 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102c03:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102c06:	83 e0 f3             	and    $0xfffffff3,%eax
f0102c09:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102c0e:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102c11:	83 ec 0c             	sub    $0xc,%esp
f0102c14:	6a 00                	push   $0x0
f0102c16:	e8 ea e3 ff ff       	call   f0101005 <page_alloc>
f0102c1b:	89 c6                	mov    %eax,%esi
f0102c1d:	83 c4 10             	add    $0x10,%esp
f0102c20:	85 c0                	test   %eax,%eax
f0102c22:	0f 84 11 02 00 00    	je     f0102e39 <mem_init+0x1b1d>
	assert((pp1 = page_alloc(0)));
f0102c28:	83 ec 0c             	sub    $0xc,%esp
f0102c2b:	6a 00                	push   $0x0
f0102c2d:	e8 d3 e3 ff ff       	call   f0101005 <page_alloc>
f0102c32:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102c35:	83 c4 10             	add    $0x10,%esp
f0102c38:	85 c0                	test   %eax,%eax
f0102c3a:	0f 84 1b 02 00 00    	je     f0102e5b <mem_init+0x1b3f>
	assert((pp2 = page_alloc(0)));
f0102c40:	83 ec 0c             	sub    $0xc,%esp
f0102c43:	6a 00                	push   $0x0
f0102c45:	e8 bb e3 ff ff       	call   f0101005 <page_alloc>
f0102c4a:	89 c7                	mov    %eax,%edi
f0102c4c:	83 c4 10             	add    $0x10,%esp
f0102c4f:	85 c0                	test   %eax,%eax
f0102c51:	0f 84 26 02 00 00    	je     f0102e7d <mem_init+0x1b61>
	page_free(pp0);
f0102c57:	83 ec 0c             	sub    $0xc,%esp
f0102c5a:	56                   	push   %esi
f0102c5b:	e8 2a e4 ff ff       	call   f010108a <page_free>
	return (pp - pages) << PGSHIFT;
f0102c60:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102c63:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c66:	2b 81 a8 1f 00 00    	sub    0x1fa8(%ecx),%eax
f0102c6c:	c1 f8 03             	sar    $0x3,%eax
f0102c6f:	89 c2                	mov    %eax,%edx
f0102c71:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102c74:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102c79:	83 c4 10             	add    $0x10,%esp
f0102c7c:	3b 81 b0 1f 00 00    	cmp    0x1fb0(%ecx),%eax
f0102c82:	0f 83 17 02 00 00    	jae    f0102e9f <mem_init+0x1b83>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c88:	83 ec 04             	sub    $0x4,%esp
f0102c8b:	68 00 10 00 00       	push   $0x1000
f0102c90:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102c92:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c98:	52                   	push   %edx
f0102c99:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c9c:	e8 20 10 00 00       	call   f0103cc1 <memset>
	return (pp - pages) << PGSHIFT;
f0102ca1:	89 f8                	mov    %edi,%eax
f0102ca3:	2b 83 a8 1f 00 00    	sub    0x1fa8(%ebx),%eax
f0102ca9:	c1 f8 03             	sar    $0x3,%eax
f0102cac:	89 c2                	mov    %eax,%edx
f0102cae:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102cb1:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102cb6:	83 c4 10             	add    $0x10,%esp
f0102cb9:	3b 83 b0 1f 00 00    	cmp    0x1fb0(%ebx),%eax
f0102cbf:	0f 83 f2 01 00 00    	jae    f0102eb7 <mem_init+0x1b9b>
	memset(page2kva(pp2), 2, PGSIZE);
f0102cc5:	83 ec 04             	sub    $0x4,%esp
f0102cc8:	68 00 10 00 00       	push   $0x1000
f0102ccd:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102ccf:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102cd5:	52                   	push   %edx
f0102cd6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cd9:	e8 e3 0f 00 00       	call   f0103cc1 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102cde:	6a 02                	push   $0x2
f0102ce0:	68 00 10 00 00       	push   $0x1000
f0102ce5:	ff 75 d0             	push   -0x30(%ebp)
f0102ce8:	ff b3 ac 1f 00 00    	push   0x1fac(%ebx)
f0102cee:	e8 b7 e5 ff ff       	call   f01012aa <page_insert>
	assert(pp1->pp_ref == 1);
f0102cf3:	83 c4 20             	add    $0x20,%esp
f0102cf6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102cf9:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102cfe:	0f 85 cc 01 00 00    	jne    f0102ed0 <mem_init+0x1bb4>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102d04:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102d0b:	01 01 01 
f0102d0e:	0f 85 de 01 00 00    	jne    f0102ef2 <mem_init+0x1bd6>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102d14:	6a 02                	push   $0x2
f0102d16:	68 00 10 00 00       	push   $0x1000
f0102d1b:	57                   	push   %edi
f0102d1c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d1f:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0102d25:	e8 80 e5 ff ff       	call   f01012aa <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d2a:	83 c4 10             	add    $0x10,%esp
f0102d2d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d34:	02 02 02 
f0102d37:	0f 85 d7 01 00 00    	jne    f0102f14 <mem_init+0x1bf8>
	assert(pp2->pp_ref == 1);
f0102d3d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d42:	0f 85 ee 01 00 00    	jne    f0102f36 <mem_init+0x1c1a>
	assert(pp1->pp_ref == 0);
f0102d48:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d4b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0102d50:	0f 85 02 02 00 00    	jne    f0102f58 <mem_init+0x1c3c>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d56:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d5d:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102d60:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102d63:	89 f8                	mov    %edi,%eax
f0102d65:	2b 81 a8 1f 00 00    	sub    0x1fa8(%ecx),%eax
f0102d6b:	c1 f8 03             	sar    $0x3,%eax
f0102d6e:	89 c2                	mov    %eax,%edx
f0102d70:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102d73:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102d78:	3b 81 b0 1f 00 00    	cmp    0x1fb0(%ecx),%eax
f0102d7e:	0f 83 f6 01 00 00    	jae    f0102f7a <mem_init+0x1c5e>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d84:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102d8b:	03 03 03 
f0102d8e:	0f 85 fe 01 00 00    	jne    f0102f92 <mem_init+0x1c76>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d94:	83 ec 08             	sub    $0x8,%esp
f0102d97:	68 00 10 00 00       	push   $0x1000
f0102d9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d9f:	ff b0 ac 1f 00 00    	push   0x1fac(%eax)
f0102da5:	e8 ba e4 ff ff       	call   f0101264 <page_remove>
	assert(pp2->pp_ref == 0);
f0102daa:	83 c4 10             	add    $0x10,%esp
f0102dad:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102db2:	0f 85 fc 01 00 00    	jne    f0102fb4 <mem_init+0x1c98>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102db8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dbb:	8b 88 ac 1f 00 00    	mov    0x1fac(%eax),%ecx
f0102dc1:	8b 11                	mov    (%ecx),%edx
f0102dc3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102dc9:	89 f7                	mov    %esi,%edi
f0102dcb:	2b b8 a8 1f 00 00    	sub    0x1fa8(%eax),%edi
f0102dd1:	89 f8                	mov    %edi,%eax
f0102dd3:	c1 f8 03             	sar    $0x3,%eax
f0102dd6:	c1 e0 0c             	shl    $0xc,%eax
f0102dd9:	39 c2                	cmp    %eax,%edx
f0102ddb:	0f 85 f5 01 00 00    	jne    f0102fd6 <mem_init+0x1cba>
	kern_pgdir[0] = 0;
f0102de1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102de7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dec:	0f 85 06 02 00 00    	jne    f0102ff8 <mem_init+0x1cdc>
	pp0->pp_ref = 0;
f0102df2:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102df8:	83 ec 0c             	sub    $0xc,%esp
f0102dfb:	56                   	push   %esi
f0102dfc:	e8 89 e2 ff ff       	call   f010108a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e01:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e04:	8d 83 78 dd fe ff    	lea    -0x12288(%ebx),%eax
f0102e0a:	89 04 24             	mov    %eax,(%esp)
f0102e0d:	e8 af 02 00 00       	call   f01030c1 <cprintf>
}
f0102e12:	83 c4 10             	add    $0x10,%esp
f0102e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e18:	5b                   	pop    %ebx
f0102e19:	5e                   	pop    %esi
f0102e1a:	5f                   	pop    %edi
f0102e1b:	5d                   	pop    %ebp
f0102e1c:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e1d:	50                   	push   %eax
f0102e1e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e21:	8d 83 04 d7 fe ff    	lea    -0x128fc(%ebx),%eax
f0102e27:	50                   	push   %eax
f0102e28:	68 df 00 00 00       	push   $0xdf
f0102e2d:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102e33:	50                   	push   %eax
f0102e34:	e8 bc d2 ff ff       	call   f01000f5 <_panic>
	assert((pp0 = page_alloc(0)));
f0102e39:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e3c:	8d 83 e6 d3 fe ff    	lea    -0x12c1a(%ebx),%eax
f0102e42:	50                   	push   %eax
f0102e43:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102e49:	50                   	push   %eax
f0102e4a:	68 7d 03 00 00       	push   $0x37d
f0102e4f:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102e55:	50                   	push   %eax
f0102e56:	e8 9a d2 ff ff       	call   f01000f5 <_panic>
	assert((pp1 = page_alloc(0)));
f0102e5b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e5e:	8d 83 fc d3 fe ff    	lea    -0x12c04(%ebx),%eax
f0102e64:	50                   	push   %eax
f0102e65:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102e6b:	50                   	push   %eax
f0102e6c:	68 7e 03 00 00       	push   $0x37e
f0102e71:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102e77:	50                   	push   %eax
f0102e78:	e8 78 d2 ff ff       	call   f01000f5 <_panic>
	assert((pp2 = page_alloc(0)));
f0102e7d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e80:	8d 83 12 d4 fe ff    	lea    -0x12bee(%ebx),%eax
f0102e86:	50                   	push   %eax
f0102e87:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102e8d:	50                   	push   %eax
f0102e8e:	68 7f 03 00 00       	push   $0x37f
f0102e93:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102e99:	50                   	push   %eax
f0102e9a:	e8 56 d2 ff ff       	call   f01000f5 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e9f:	52                   	push   %edx
f0102ea0:	89 cb                	mov    %ecx,%ebx
f0102ea2:	8d 81 f8 d5 fe ff    	lea    -0x12a08(%ecx),%eax
f0102ea8:	50                   	push   %eax
f0102ea9:	6a 52                	push   $0x52
f0102eab:	8d 81 14 d3 fe ff    	lea    -0x12cec(%ecx),%eax
f0102eb1:	50                   	push   %eax
f0102eb2:	e8 3e d2 ff ff       	call   f01000f5 <_panic>
f0102eb7:	52                   	push   %edx
f0102eb8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ebb:	8d 83 f8 d5 fe ff    	lea    -0x12a08(%ebx),%eax
f0102ec1:	50                   	push   %eax
f0102ec2:	6a 52                	push   $0x52
f0102ec4:	8d 83 14 d3 fe ff    	lea    -0x12cec(%ebx),%eax
f0102eca:	50                   	push   %eax
f0102ecb:	e8 25 d2 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 1);
f0102ed0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ed3:	8d 83 e3 d4 fe ff    	lea    -0x12b1d(%ebx),%eax
f0102ed9:	50                   	push   %eax
f0102eda:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102ee0:	50                   	push   %eax
f0102ee1:	68 84 03 00 00       	push   $0x384
f0102ee6:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102eec:	50                   	push   %eax
f0102eed:	e8 03 d2 ff ff       	call   f01000f5 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ef2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ef5:	8d 83 04 dd fe ff    	lea    -0x122fc(%ebx),%eax
f0102efb:	50                   	push   %eax
f0102efc:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102f02:	50                   	push   %eax
f0102f03:	68 85 03 00 00       	push   $0x385
f0102f08:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102f0e:	50                   	push   %eax
f0102f0f:	e8 e1 d1 ff ff       	call   f01000f5 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102f14:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f17:	8d 83 28 dd fe ff    	lea    -0x122d8(%ebx),%eax
f0102f1d:	50                   	push   %eax
f0102f1e:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102f24:	50                   	push   %eax
f0102f25:	68 87 03 00 00       	push   $0x387
f0102f2a:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102f30:	50                   	push   %eax
f0102f31:	e8 bf d1 ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 1);
f0102f36:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f39:	8d 83 05 d5 fe ff    	lea    -0x12afb(%ebx),%eax
f0102f3f:	50                   	push   %eax
f0102f40:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102f46:	50                   	push   %eax
f0102f47:	68 88 03 00 00       	push   $0x388
f0102f4c:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102f52:	50                   	push   %eax
f0102f53:	e8 9d d1 ff ff       	call   f01000f5 <_panic>
	assert(pp1->pp_ref == 0);
f0102f58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f5b:	8d 83 6f d5 fe ff    	lea    -0x12a91(%ebx),%eax
f0102f61:	50                   	push   %eax
f0102f62:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102f68:	50                   	push   %eax
f0102f69:	68 89 03 00 00       	push   $0x389
f0102f6e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102f74:	50                   	push   %eax
f0102f75:	e8 7b d1 ff ff       	call   f01000f5 <_panic>
f0102f7a:	52                   	push   %edx
f0102f7b:	89 cb                	mov    %ecx,%ebx
f0102f7d:	8d 81 f8 d5 fe ff    	lea    -0x12a08(%ecx),%eax
f0102f83:	50                   	push   %eax
f0102f84:	6a 52                	push   $0x52
f0102f86:	8d 81 14 d3 fe ff    	lea    -0x12cec(%ecx),%eax
f0102f8c:	50                   	push   %eax
f0102f8d:	e8 63 d1 ff ff       	call   f01000f5 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102f92:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f95:	8d 83 4c dd fe ff    	lea    -0x122b4(%ebx),%eax
f0102f9b:	50                   	push   %eax
f0102f9c:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102fa2:	50                   	push   %eax
f0102fa3:	68 8b 03 00 00       	push   $0x38b
f0102fa8:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102fae:	50                   	push   %eax
f0102faf:	e8 41 d1 ff ff       	call   f01000f5 <_panic>
	assert(pp2->pp_ref == 0);
f0102fb4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fb7:	8d 83 3d d5 fe ff    	lea    -0x12ac3(%ebx),%eax
f0102fbd:	50                   	push   %eax
f0102fbe:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102fc4:	50                   	push   %eax
f0102fc5:	68 8d 03 00 00       	push   $0x38d
f0102fca:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102fd0:	50                   	push   %eax
f0102fd1:	e8 1f d1 ff ff       	call   f01000f5 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102fd6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fd9:	8d 83 90 d8 fe ff    	lea    -0x12770(%ebx),%eax
f0102fdf:	50                   	push   %eax
f0102fe0:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0102fe6:	50                   	push   %eax
f0102fe7:	68 90 03 00 00       	push   $0x390
f0102fec:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0102ff2:	50                   	push   %eax
f0102ff3:	e8 fd d0 ff ff       	call   f01000f5 <_panic>
	assert(pp0->pp_ref == 1);
f0102ff8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ffb:	8d 83 f4 d4 fe ff    	lea    -0x12b0c(%ebx),%eax
f0103001:	50                   	push   %eax
f0103002:	8d 83 2e d3 fe ff    	lea    -0x12cd2(%ebx),%eax
f0103008:	50                   	push   %eax
f0103009:	68 92 03 00 00       	push   $0x392
f010300e:	8d 83 08 d3 fe ff    	lea    -0x12cf8(%ebx),%eax
f0103014:	50                   	push   %eax
f0103015:	e8 db d0 ff ff       	call   f01000f5 <_panic>

f010301a <tlb_invalidate>:
{
f010301a:	55                   	push   %ebp
f010301b:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010301d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103020:	0f 01 38             	invlpg (%eax)
}
f0103023:	5d                   	pop    %ebp
f0103024:	c3                   	ret    

f0103025 <__x86.get_pc_thunk.dx>:
f0103025:	8b 14 24             	mov    (%esp),%edx
f0103028:	c3                   	ret    

f0103029 <__x86.get_pc_thunk.cx>:
f0103029:	8b 0c 24             	mov    (%esp),%ecx
f010302c:	c3                   	ret    

f010302d <__x86.get_pc_thunk.di>:
f010302d:	8b 3c 24             	mov    (%esp),%edi
f0103030:	c3                   	ret    

f0103031 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103031:	55                   	push   %ebp
f0103032:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103034:	8b 45 08             	mov    0x8(%ebp),%eax
f0103037:	ba 70 00 00 00       	mov    $0x70,%edx
f010303c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010303d:	ba 71 00 00 00       	mov    $0x71,%edx
f0103042:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103043:	0f b6 c0             	movzbl %al,%eax
}
f0103046:	5d                   	pop    %ebp
f0103047:	c3                   	ret    

f0103048 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103048:	55                   	push   %ebp
f0103049:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010304b:	8b 45 08             	mov    0x8(%ebp),%eax
f010304e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103053:	ee                   	out    %al,(%dx)
f0103054:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103057:	ba 71 00 00 00       	mov    $0x71,%edx
f010305c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010305d:	5d                   	pop    %ebp
f010305e:	c3                   	ret    

f010305f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010305f:	55                   	push   %ebp
f0103060:	89 e5                	mov    %esp,%ebp
f0103062:	56                   	push   %esi
f0103063:	53                   	push   %ebx
f0103064:	e8 42 d1 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0103069:	81 c3 a7 42 01 00    	add    $0x142a7,%ebx
f010306f:	8b 75 0c             	mov    0xc(%ebp),%esi
	cputchar(ch);
f0103072:	83 ec 0c             	sub    $0xc,%esp
f0103075:	ff 75 08             	push   0x8(%ebp)
f0103078:	e8 9b d6 ff ff       	call   f0100718 <cputchar>
	(*cnt)++;
f010307d:	83 06 01             	addl   $0x1,(%esi)
}
f0103080:	83 c4 10             	add    $0x10,%esp
f0103083:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103086:	5b                   	pop    %ebx
f0103087:	5e                   	pop    %esi
f0103088:	5d                   	pop    %ebp
f0103089:	c3                   	ret    

f010308a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010308a:	55                   	push   %ebp
f010308b:	89 e5                	mov    %esp,%ebp
f010308d:	53                   	push   %ebx
f010308e:	83 ec 14             	sub    $0x14,%esp
f0103091:	e8 15 d1 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0103096:	81 c3 7a 42 01 00    	add    $0x1427a,%ebx
	int cnt = 0;
f010309c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01030a3:	ff 75 0c             	push   0xc(%ebp)
f01030a6:	ff 75 08             	push   0x8(%ebp)
f01030a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01030ac:	50                   	push   %eax
f01030ad:	8d 83 4f bd fe ff    	lea    -0x142b1(%ebx),%eax
f01030b3:	50                   	push   %eax
f01030b4:	e8 5b 04 00 00       	call   f0103514 <vprintfmt>
	return cnt;
}
f01030b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030bf:	c9                   	leave  
f01030c0:	c3                   	ret    

f01030c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01030c1:	55                   	push   %ebp
f01030c2:	89 e5                	mov    %esp,%ebp
f01030c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01030c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01030ca:	50                   	push   %eax
f01030cb:	ff 75 08             	push   0x8(%ebp)
f01030ce:	e8 b7 ff ff ff       	call   f010308a <vcprintf>
	va_end(ap);

	return cnt;
}
f01030d3:	c9                   	leave  
f01030d4:	c3                   	ret    

f01030d5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01030d5:	55                   	push   %ebp
f01030d6:	89 e5                	mov    %esp,%ebp
f01030d8:	57                   	push   %edi
f01030d9:	56                   	push   %esi
f01030da:	53                   	push   %ebx
f01030db:	83 ec 14             	sub    $0x14,%esp
f01030de:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01030e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01030e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01030e7:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01030ea:	8b 1a                	mov    (%edx),%ebx
f01030ec:	8b 01                	mov    (%ecx),%eax
f01030ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01030f1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01030f8:	eb 2f                	jmp    f0103129 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01030fa:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01030fd:	39 c3                	cmp    %eax,%ebx
f01030ff:	7f 4e                	jg     f010314f <stab_binsearch+0x7a>
f0103101:	0f b6 0a             	movzbl (%edx),%ecx
f0103104:	83 ea 0c             	sub    $0xc,%edx
f0103107:	39 f1                	cmp    %esi,%ecx
f0103109:	75 ef                	jne    f01030fa <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010310b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010310e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103111:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103115:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103118:	73 3a                	jae    f0103154 <stab_binsearch+0x7f>
			*region_left = m;
f010311a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010311d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010311f:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0103122:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103129:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010312c:	7f 53                	jg     f0103181 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f010312e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103131:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0103134:	89 d0                	mov    %edx,%eax
f0103136:	c1 e8 1f             	shr    $0x1f,%eax
f0103139:	01 d0                	add    %edx,%eax
f010313b:	89 c7                	mov    %eax,%edi
f010313d:	d1 ff                	sar    %edi
f010313f:	83 e0 fe             	and    $0xfffffffe,%eax
f0103142:	01 f8                	add    %edi,%eax
f0103144:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103147:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010314b:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f010314d:	eb ae                	jmp    f01030fd <stab_binsearch+0x28>
			l = true_m + 1;
f010314f:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103152:	eb d5                	jmp    f0103129 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103154:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103157:	76 14                	jbe    f010316d <stab_binsearch+0x98>
			*region_right = m - 1;
f0103159:	83 e8 01             	sub    $0x1,%eax
f010315c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010315f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103162:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0103164:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010316b:	eb bc                	jmp    f0103129 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010316d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103170:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0103172:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103176:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0103178:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010317f:	eb a8                	jmp    f0103129 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103181:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103185:	75 15                	jne    f010319c <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0103187:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010318a:	8b 00                	mov    (%eax),%eax
f010318c:	83 e8 01             	sub    $0x1,%eax
f010318f:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103192:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103194:	83 c4 14             	add    $0x14,%esp
f0103197:	5b                   	pop    %ebx
f0103198:	5e                   	pop    %esi
f0103199:	5f                   	pop    %edi
f010319a:	5d                   	pop    %ebp
f010319b:	c3                   	ret    
		for (l = *region_right;
f010319c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010319f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01031a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031a4:	8b 0f                	mov    (%edi),%ecx
f01031a6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01031a9:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01031ac:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01031b0:	39 c1                	cmp    %eax,%ecx
f01031b2:	7d 0f                	jge    f01031c3 <stab_binsearch+0xee>
f01031b4:	0f b6 1a             	movzbl (%edx),%ebx
f01031b7:	83 ea 0c             	sub    $0xc,%edx
f01031ba:	39 f3                	cmp    %esi,%ebx
f01031bc:	74 05                	je     f01031c3 <stab_binsearch+0xee>
		     l--)
f01031be:	83 e8 01             	sub    $0x1,%eax
f01031c1:	eb ed                	jmp    f01031b0 <stab_binsearch+0xdb>
		*region_left = l;
f01031c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01031c6:	89 07                	mov    %eax,(%edi)
}
f01031c8:	eb ca                	jmp    f0103194 <stab_binsearch+0xbf>

f01031ca <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01031ca:	55                   	push   %ebp
f01031cb:	89 e5                	mov    %esp,%ebp
f01031cd:	57                   	push   %edi
f01031ce:	56                   	push   %esi
f01031cf:	53                   	push   %ebx
f01031d0:	83 ec 3c             	sub    $0x3c,%esp
f01031d3:	e8 d3 cf ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f01031d8:	81 c3 38 41 01 00    	add    $0x14138,%ebx
f01031de:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01031e1:	8d 83 a1 dd fe ff    	lea    -0x1225f(%ebx),%eax
f01031e7:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f01031e9:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01031f0:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f01031f3:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01031fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01031fd:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f0103200:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103207:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010320c:	0f 86 44 01 00 00    	jbe    f0103356 <debuginfo_eip+0x18c>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103212:	c7 c0 11 b9 10 f0    	mov    $0xf010b911,%eax
f0103218:	39 83 f4 ff ff ff    	cmp    %eax,-0xc(%ebx)
f010321e:	0f 86 d6 01 00 00    	jbe    f01033fa <debuginfo_eip+0x230>
f0103224:	c7 c0 aa d6 10 f0    	mov    $0xf010d6aa,%eax
f010322a:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010322e:	0f 85 cd 01 00 00    	jne    f0103401 <debuginfo_eip+0x237>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103234:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010323b:	c7 c0 c8 52 10 f0    	mov    $0xf01052c8,%eax
f0103241:	c7 c2 10 b9 10 f0    	mov    $0xf010b910,%edx
f0103247:	29 c2                	sub    %eax,%edx
f0103249:	c1 fa 02             	sar    $0x2,%edx
f010324c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103252:	83 ea 01             	sub    $0x1,%edx
f0103255:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103258:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010325b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010325e:	83 ec 08             	sub    $0x8,%esp
f0103261:	ff 75 08             	push   0x8(%ebp)
f0103264:	6a 64                	push   $0x64
f0103266:	e8 6a fe ff ff       	call   f01030d5 <stab_binsearch>
	if (lfile == 0)
f010326b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010326e:	83 c4 10             	add    $0x10,%esp
f0103271:	85 ff                	test   %edi,%edi
f0103273:	0f 84 8f 01 00 00    	je     f0103408 <debuginfo_eip+0x23e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103279:	89 7d dc             	mov    %edi,-0x24(%ebp)
	rfun = rfile;
f010327c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010327f:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0103282:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103285:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103288:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010328b:	83 ec 08             	sub    $0x8,%esp
f010328e:	ff 75 08             	push   0x8(%ebp)
f0103291:	6a 24                	push   $0x24
f0103293:	c7 c0 c8 52 10 f0    	mov    $0xf01052c8,%eax
f0103299:	e8 37 fe ff ff       	call   f01030d5 <stab_binsearch>

	if (lfun <= rfun) {
f010329e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01032a1:	89 4d bc             	mov    %ecx,-0x44(%ebp)
f01032a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01032a7:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01032aa:	83 c4 10             	add    $0x10,%esp
f01032ad:	89 f8                	mov    %edi,%eax
f01032af:	39 d1                	cmp    %edx,%ecx
f01032b1:	7f 39                	jg     f01032ec <debuginfo_eip+0x122>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01032b3:	8d 04 49             	lea    (%ecx,%ecx,2),%eax
f01032b6:	c7 c2 c8 52 10 f0    	mov    $0xf01052c8,%edx
f01032bc:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f01032bf:	8b 11                	mov    (%ecx),%edx
f01032c1:	c7 c0 aa d6 10 f0    	mov    $0xf010d6aa,%eax
f01032c7:	81 e8 11 b9 10 f0    	sub    $0xf010b911,%eax
f01032cd:	39 c2                	cmp    %eax,%edx
f01032cf:	73 09                	jae    f01032da <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01032d1:	81 c2 11 b9 10 f0    	add    $0xf010b911,%edx
f01032d7:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01032da:	8b 41 08             	mov    0x8(%ecx),%eax
f01032dd:	89 46 10             	mov    %eax,0x10(%esi)
		addr -= info->eip_fn_addr;
f01032e0:	29 45 08             	sub    %eax,0x8(%ebp)
f01032e3:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01032e6:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01032e9:	89 4d c0             	mov    %ecx,-0x40(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f01032ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01032ef:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01032f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01032f5:	83 ec 08             	sub    $0x8,%esp
f01032f8:	6a 3a                	push   $0x3a
f01032fa:	ff 76 08             	push   0x8(%esi)
f01032fd:	e8 a3 09 00 00       	call   f0103ca5 <strfind>
f0103302:	2b 46 08             	sub    0x8(%esi),%eax
f0103305:	89 46 0c             	mov    %eax,0xc(%esi)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103308:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010330b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010330e:	83 c4 08             	add    $0x8,%esp
f0103311:	ff 75 08             	push   0x8(%ebp)
f0103314:	6a 44                	push   $0x44
f0103316:	c7 c0 c8 52 10 f0    	mov    $0xf01052c8,%eax
f010331c:	e8 b4 fd ff ff       	call   f01030d5 <stab_binsearch>
	if (lline <= rline) {
f0103321:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103324:	83 c4 10             	add    $0x10,%esp
		info->eip_line = stabs[lline].n_desc;
	} else {
		info->eip_line = -1;
f0103327:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	if (lline <= rline) {
f010332c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010332f:	7f 0e                	jg     f010333f <debuginfo_eip+0x175>
		info->eip_line = stabs[lline].n_desc;
f0103331:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103334:	c7 c1 c8 52 10 f0    	mov    $0xf01052c8,%ecx
f010333a:	0f b7 54 91 06       	movzwl 0x6(%ecx,%edx,4),%edx
f010333f:	89 56 04             	mov    %edx,0x4(%esi)
f0103342:	89 c2                	mov    %eax,%edx
f0103344:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103347:	c7 c0 c8 52 10 f0    	mov    $0xf01052c8,%eax
f010334d:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0103351:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103354:	eb 1e                	jmp    f0103374 <debuginfo_eip+0x1aa>
  	        panic("User address");
f0103356:	83 ec 04             	sub    $0x4,%esp
f0103359:	8d 83 ab dd fe ff    	lea    -0x12255(%ebx),%eax
f010335f:	50                   	push   %eax
f0103360:	6a 7f                	push   $0x7f
f0103362:	8d 83 b8 dd fe ff    	lea    -0x12248(%ebx),%eax
f0103368:	50                   	push   %eax
f0103369:	e8 87 cd ff ff       	call   f01000f5 <_panic>
f010336e:	83 ea 01             	sub    $0x1,%edx
f0103371:	83 e8 0c             	sub    $0xc,%eax
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103374:	39 d7                	cmp    %edx,%edi
f0103376:	7f 3c                	jg     f01033b4 <debuginfo_eip+0x1ea>
	       && stabs[lline].n_type != N_SOL
f0103378:	0f b6 08             	movzbl (%eax),%ecx
f010337b:	80 f9 84             	cmp    $0x84,%cl
f010337e:	74 0b                	je     f010338b <debuginfo_eip+0x1c1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103380:	80 f9 64             	cmp    $0x64,%cl
f0103383:	75 e9                	jne    f010336e <debuginfo_eip+0x1a4>
f0103385:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0103389:	74 e3                	je     f010336e <debuginfo_eip+0x1a4>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010338b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010338e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103391:	c7 c0 c8 52 10 f0    	mov    $0xf01052c8,%eax
f0103397:	8b 14 90             	mov    (%eax,%edx,4),%edx
f010339a:	c7 c0 aa d6 10 f0    	mov    $0xf010d6aa,%eax
f01033a0:	81 e8 11 b9 10 f0    	sub    $0xf010b911,%eax
f01033a6:	39 c2                	cmp    %eax,%edx
f01033a8:	73 0d                	jae    f01033b7 <debuginfo_eip+0x1ed>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01033aa:	81 c2 11 b9 10 f0    	add    $0xf010b911,%edx
f01033b0:	89 16                	mov    %edx,(%esi)
f01033b2:	eb 03                	jmp    f01033b7 <debuginfo_eip+0x1ed>
f01033b4:	8b 75 0c             	mov    0xc(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01033b7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01033bc:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01033bf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01033c2:	39 cf                	cmp    %ecx,%edi
f01033c4:	7d 4e                	jge    f0103414 <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
f01033c6:	83 c7 01             	add    $0x1,%edi
f01033c9:	89 f8                	mov    %edi,%eax
f01033cb:	8d 0c 7f             	lea    (%edi,%edi,2),%ecx
f01033ce:	c7 c2 c8 52 10 f0    	mov    $0xf01052c8,%edx
f01033d4:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f01033d8:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01033db:	eb 04                	jmp    f01033e1 <debuginfo_eip+0x217>
			info->eip_fn_narg++;
f01033dd:	83 46 14 01          	addl   $0x1,0x14(%esi)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01033e1:	39 c3                	cmp    %eax,%ebx
f01033e3:	7e 2a                	jle    f010340f <debuginfo_eip+0x245>
f01033e5:	0f b6 0a             	movzbl (%edx),%ecx
f01033e8:	83 c0 01             	add    $0x1,%eax
f01033eb:	83 c2 0c             	add    $0xc,%edx
f01033ee:	80 f9 a0             	cmp    $0xa0,%cl
f01033f1:	74 ea                	je     f01033dd <debuginfo_eip+0x213>
	return 0;
f01033f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01033f8:	eb 1a                	jmp    f0103414 <debuginfo_eip+0x24a>
		return -1;
f01033fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01033ff:	eb 13                	jmp    f0103414 <debuginfo_eip+0x24a>
f0103401:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103406:	eb 0c                	jmp    f0103414 <debuginfo_eip+0x24a>
		return -1;
f0103408:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010340d:	eb 05                	jmp    f0103414 <debuginfo_eip+0x24a>
	return 0;
f010340f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103414:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103417:	5b                   	pop    %ebx
f0103418:	5e                   	pop    %esi
f0103419:	5f                   	pop    %edi
f010341a:	5d                   	pop    %ebp
f010341b:	c3                   	ret    

f010341c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010341c:	55                   	push   %ebp
f010341d:	89 e5                	mov    %esp,%ebp
f010341f:	57                   	push   %edi
f0103420:	56                   	push   %esi
f0103421:	53                   	push   %ebx
f0103422:	83 ec 2c             	sub    $0x2c,%esp
f0103425:	e8 ff fb ff ff       	call   f0103029 <__x86.get_pc_thunk.cx>
f010342a:	81 c1 e6 3e 01 00    	add    $0x13ee6,%ecx
f0103430:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103433:	89 c7                	mov    %eax,%edi
f0103435:	89 d6                	mov    %edx,%esi
f0103437:	8b 45 08             	mov    0x8(%ebp),%eax
f010343a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010343d:	89 d1                	mov    %edx,%ecx
f010343f:	89 c2                	mov    %eax,%edx
f0103441:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103444:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103447:	8b 45 10             	mov    0x10(%ebp),%eax
f010344a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010344d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103450:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103457:	39 c2                	cmp    %eax,%edx
f0103459:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f010345c:	72 41                	jb     f010349f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010345e:	83 ec 0c             	sub    $0xc,%esp
f0103461:	ff 75 18             	push   0x18(%ebp)
f0103464:	83 eb 01             	sub    $0x1,%ebx
f0103467:	53                   	push   %ebx
f0103468:	50                   	push   %eax
f0103469:	83 ec 08             	sub    $0x8,%esp
f010346c:	ff 75 e4             	push   -0x1c(%ebp)
f010346f:	ff 75 e0             	push   -0x20(%ebp)
f0103472:	ff 75 d4             	push   -0x2c(%ebp)
f0103475:	ff 75 d0             	push   -0x30(%ebp)
f0103478:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010347b:	e8 40 0a 00 00       	call   f0103ec0 <__udivdi3>
f0103480:	83 c4 18             	add    $0x18,%esp
f0103483:	52                   	push   %edx
f0103484:	50                   	push   %eax
f0103485:	89 f2                	mov    %esi,%edx
f0103487:	89 f8                	mov    %edi,%eax
f0103489:	e8 8e ff ff ff       	call   f010341c <printnum>
f010348e:	83 c4 20             	add    $0x20,%esp
f0103491:	eb 13                	jmp    f01034a6 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103493:	83 ec 08             	sub    $0x8,%esp
f0103496:	56                   	push   %esi
f0103497:	ff 75 18             	push   0x18(%ebp)
f010349a:	ff d7                	call   *%edi
f010349c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010349f:	83 eb 01             	sub    $0x1,%ebx
f01034a2:	85 db                	test   %ebx,%ebx
f01034a4:	7f ed                	jg     f0103493 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01034a6:	83 ec 08             	sub    $0x8,%esp
f01034a9:	56                   	push   %esi
f01034aa:	83 ec 04             	sub    $0x4,%esp
f01034ad:	ff 75 e4             	push   -0x1c(%ebp)
f01034b0:	ff 75 e0             	push   -0x20(%ebp)
f01034b3:	ff 75 d4             	push   -0x2c(%ebp)
f01034b6:	ff 75 d0             	push   -0x30(%ebp)
f01034b9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01034bc:	e8 1f 0b 00 00       	call   f0103fe0 <__umoddi3>
f01034c1:	83 c4 14             	add    $0x14,%esp
f01034c4:	0f be 84 03 c6 dd fe 	movsbl -0x1223a(%ebx,%eax,1),%eax
f01034cb:	ff 
f01034cc:	50                   	push   %eax
f01034cd:	ff d7                	call   *%edi
}
f01034cf:	83 c4 10             	add    $0x10,%esp
f01034d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01034d5:	5b                   	pop    %ebx
f01034d6:	5e                   	pop    %esi
f01034d7:	5f                   	pop    %edi
f01034d8:	5d                   	pop    %ebp
f01034d9:	c3                   	ret    

f01034da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01034da:	55                   	push   %ebp
f01034db:	89 e5                	mov    %esp,%ebp
f01034dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01034e0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01034e4:	8b 10                	mov    (%eax),%edx
f01034e6:	3b 50 04             	cmp    0x4(%eax),%edx
f01034e9:	73 0a                	jae    f01034f5 <sprintputch+0x1b>
		*b->buf++ = ch;
f01034eb:	8d 4a 01             	lea    0x1(%edx),%ecx
f01034ee:	89 08                	mov    %ecx,(%eax)
f01034f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f3:	88 02                	mov    %al,(%edx)
}
f01034f5:	5d                   	pop    %ebp
f01034f6:	c3                   	ret    

f01034f7 <printfmt>:
{
f01034f7:	55                   	push   %ebp
f01034f8:	89 e5                	mov    %esp,%ebp
f01034fa:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01034fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103500:	50                   	push   %eax
f0103501:	ff 75 10             	push   0x10(%ebp)
f0103504:	ff 75 0c             	push   0xc(%ebp)
f0103507:	ff 75 08             	push   0x8(%ebp)
f010350a:	e8 05 00 00 00       	call   f0103514 <vprintfmt>
}
f010350f:	83 c4 10             	add    $0x10,%esp
f0103512:	c9                   	leave  
f0103513:	c3                   	ret    

f0103514 <vprintfmt>:
{
f0103514:	55                   	push   %ebp
f0103515:	89 e5                	mov    %esp,%ebp
f0103517:	57                   	push   %edi
f0103518:	56                   	push   %esi
f0103519:	53                   	push   %ebx
f010351a:	83 ec 3c             	sub    $0x3c,%esp
f010351d:	e8 1d d2 ff ff       	call   f010073f <__x86.get_pc_thunk.ax>
f0103522:	05 ee 3d 01 00       	add    $0x13dee,%eax
f0103527:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010352a:	8b 75 08             	mov    0x8(%ebp),%esi
f010352d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103530:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103533:	8d 80 34 1d 00 00    	lea    0x1d34(%eax),%eax
f0103539:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010353c:	eb 0a                	jmp    f0103548 <vprintfmt+0x34>
			putch(ch, putdat);
f010353e:	83 ec 08             	sub    $0x8,%esp
f0103541:	57                   	push   %edi
f0103542:	50                   	push   %eax
f0103543:	ff d6                	call   *%esi
f0103545:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103548:	83 c3 01             	add    $0x1,%ebx
f010354b:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010354f:	83 f8 25             	cmp    $0x25,%eax
f0103552:	74 0c                	je     f0103560 <vprintfmt+0x4c>
			if (ch == '\0')
f0103554:	85 c0                	test   %eax,%eax
f0103556:	75 e6                	jne    f010353e <vprintfmt+0x2a>
}
f0103558:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010355b:	5b                   	pop    %ebx
f010355c:	5e                   	pop    %esi
f010355d:	5f                   	pop    %edi
f010355e:	5d                   	pop    %ebp
f010355f:	c3                   	ret    
		padc = ' ';
f0103560:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0103564:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f010356b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0103572:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0103579:	b9 00 00 00 00       	mov    $0x0,%ecx
f010357e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103581:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103584:	8d 43 01             	lea    0x1(%ebx),%eax
f0103587:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010358a:	0f b6 13             	movzbl (%ebx),%edx
f010358d:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103590:	3c 55                	cmp    $0x55,%al
f0103592:	0f 87 fd 03 00 00    	ja     f0103995 <.L20>
f0103598:	0f b6 c0             	movzbl %al,%eax
f010359b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010359e:	89 ce                	mov    %ecx,%esi
f01035a0:	03 b4 81 50 de fe ff 	add    -0x121b0(%ecx,%eax,4),%esi
f01035a7:	ff e6                	jmp    *%esi

f01035a9 <.L68>:
f01035a9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01035ac:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01035b0:	eb d2                	jmp    f0103584 <vprintfmt+0x70>

f01035b2 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01035b2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01035b5:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01035b9:	eb c9                	jmp    f0103584 <vprintfmt+0x70>

f01035bb <.L31>:
f01035bb:	0f b6 d2             	movzbl %dl,%edx
f01035be:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01035c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01035c6:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01035c9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01035cc:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01035d0:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01035d3:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01035d6:	83 f9 09             	cmp    $0x9,%ecx
f01035d9:	77 58                	ja     f0103633 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01035db:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01035de:	eb e9                	jmp    f01035c9 <.L31+0xe>

f01035e0 <.L34>:
			precision = va_arg(ap, int);
f01035e0:	8b 45 14             	mov    0x14(%ebp),%eax
f01035e3:	8b 00                	mov    (%eax),%eax
f01035e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01035e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01035eb:	8d 40 04             	lea    0x4(%eax),%eax
f01035ee:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01035f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01035f4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01035f8:	79 8a                	jns    f0103584 <vprintfmt+0x70>
				width = precision, precision = -1;
f01035fa:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103600:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0103607:	e9 78 ff ff ff       	jmp    f0103584 <vprintfmt+0x70>

f010360c <.L33>:
f010360c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010360f:	85 d2                	test   %edx,%edx
f0103611:	b8 00 00 00 00       	mov    $0x0,%eax
f0103616:	0f 49 c2             	cmovns %edx,%eax
f0103619:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010361c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010361f:	e9 60 ff ff ff       	jmp    f0103584 <vprintfmt+0x70>

f0103624 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0103624:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0103627:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f010362e:	e9 51 ff ff ff       	jmp    f0103584 <vprintfmt+0x70>
f0103633:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103636:	89 75 08             	mov    %esi,0x8(%ebp)
f0103639:	eb b9                	jmp    f01035f4 <.L34+0x14>

f010363b <.L27>:
			lflag++;
f010363b:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010363f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0103642:	e9 3d ff ff ff       	jmp    f0103584 <vprintfmt+0x70>

f0103647 <.L30>:
			putch(va_arg(ap, int), putdat);
f0103647:	8b 75 08             	mov    0x8(%ebp),%esi
f010364a:	8b 45 14             	mov    0x14(%ebp),%eax
f010364d:	8d 58 04             	lea    0x4(%eax),%ebx
f0103650:	83 ec 08             	sub    $0x8,%esp
f0103653:	57                   	push   %edi
f0103654:	ff 30                	push   (%eax)
f0103656:	ff d6                	call   *%esi
			break;
f0103658:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010365b:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f010365e:	e9 c8 02 00 00       	jmp    f010392b <.L25+0x45>

f0103663 <.L28>:
			err = va_arg(ap, int);
f0103663:	8b 75 08             	mov    0x8(%ebp),%esi
f0103666:	8b 45 14             	mov    0x14(%ebp),%eax
f0103669:	8d 58 04             	lea    0x4(%eax),%ebx
f010366c:	8b 10                	mov    (%eax),%edx
f010366e:	89 d0                	mov    %edx,%eax
f0103670:	f7 d8                	neg    %eax
f0103672:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103675:	83 f8 06             	cmp    $0x6,%eax
f0103678:	7f 27                	jg     f01036a1 <.L28+0x3e>
f010367a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010367d:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0103680:	85 d2                	test   %edx,%edx
f0103682:	74 1d                	je     f01036a1 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
f0103684:	52                   	push   %edx
f0103685:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103688:	8d 80 40 d3 fe ff    	lea    -0x12cc0(%eax),%eax
f010368e:	50                   	push   %eax
f010368f:	57                   	push   %edi
f0103690:	56                   	push   %esi
f0103691:	e8 61 fe ff ff       	call   f01034f7 <printfmt>
f0103696:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103699:	89 5d 14             	mov    %ebx,0x14(%ebp)
f010369c:	e9 8a 02 00 00       	jmp    f010392b <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01036a1:	50                   	push   %eax
f01036a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036a5:	8d 80 de dd fe ff    	lea    -0x12222(%eax),%eax
f01036ab:	50                   	push   %eax
f01036ac:	57                   	push   %edi
f01036ad:	56                   	push   %esi
f01036ae:	e8 44 fe ff ff       	call   f01034f7 <printfmt>
f01036b3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01036b6:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01036b9:	e9 6d 02 00 00       	jmp    f010392b <.L25+0x45>

f01036be <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01036be:	8b 75 08             	mov    0x8(%ebp),%esi
f01036c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01036c4:	83 c0 04             	add    $0x4,%eax
f01036c7:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01036ca:	8b 45 14             	mov    0x14(%ebp),%eax
f01036cd:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01036cf:	85 d2                	test   %edx,%edx
f01036d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036d4:	8d 80 d7 dd fe ff    	lea    -0x12229(%eax),%eax
f01036da:	0f 45 c2             	cmovne %edx,%eax
f01036dd:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01036e0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01036e4:	7e 06                	jle    f01036ec <.L24+0x2e>
f01036e6:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01036ea:	75 0d                	jne    f01036f9 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01036ec:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01036ef:	89 c3                	mov    %eax,%ebx
f01036f1:	03 45 d4             	add    -0x2c(%ebp),%eax
f01036f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01036f7:	eb 58                	jmp    f0103751 <.L24+0x93>
f01036f9:	83 ec 08             	sub    $0x8,%esp
f01036fc:	ff 75 d8             	push   -0x28(%ebp)
f01036ff:	ff 75 c8             	push   -0x38(%ebp)
f0103702:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103705:	e8 44 04 00 00       	call   f0103b4e <strnlen>
f010370a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010370d:	29 c2                	sub    %eax,%edx
f010370f:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0103712:	83 c4 10             	add    $0x10,%esp
f0103715:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f0103717:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f010371b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010371e:	eb 0f                	jmp    f010372f <.L24+0x71>
					putch(padc, putdat);
f0103720:	83 ec 08             	sub    $0x8,%esp
f0103723:	57                   	push   %edi
f0103724:	ff 75 d4             	push   -0x2c(%ebp)
f0103727:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103729:	83 eb 01             	sub    $0x1,%ebx
f010372c:	83 c4 10             	add    $0x10,%esp
f010372f:	85 db                	test   %ebx,%ebx
f0103731:	7f ed                	jg     f0103720 <.L24+0x62>
f0103733:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103736:	85 d2                	test   %edx,%edx
f0103738:	b8 00 00 00 00       	mov    $0x0,%eax
f010373d:	0f 49 c2             	cmovns %edx,%eax
f0103740:	29 c2                	sub    %eax,%edx
f0103742:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103745:	eb a5                	jmp    f01036ec <.L24+0x2e>
					putch(ch, putdat);
f0103747:	83 ec 08             	sub    $0x8,%esp
f010374a:	57                   	push   %edi
f010374b:	52                   	push   %edx
f010374c:	ff d6                	call   *%esi
f010374e:	83 c4 10             	add    $0x10,%esp
f0103751:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103754:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103756:	83 c3 01             	add    $0x1,%ebx
f0103759:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010375d:	0f be d0             	movsbl %al,%edx
f0103760:	85 d2                	test   %edx,%edx
f0103762:	74 4b                	je     f01037af <.L24+0xf1>
f0103764:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103768:	78 06                	js     f0103770 <.L24+0xb2>
f010376a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010376e:	78 1e                	js     f010378e <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0103770:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0103774:	74 d1                	je     f0103747 <.L24+0x89>
f0103776:	0f be c0             	movsbl %al,%eax
f0103779:	83 e8 20             	sub    $0x20,%eax
f010377c:	83 f8 5e             	cmp    $0x5e,%eax
f010377f:	76 c6                	jbe    f0103747 <.L24+0x89>
					putch('?', putdat);
f0103781:	83 ec 08             	sub    $0x8,%esp
f0103784:	57                   	push   %edi
f0103785:	6a 3f                	push   $0x3f
f0103787:	ff d6                	call   *%esi
f0103789:	83 c4 10             	add    $0x10,%esp
f010378c:	eb c3                	jmp    f0103751 <.L24+0x93>
f010378e:	89 cb                	mov    %ecx,%ebx
f0103790:	eb 0e                	jmp    f01037a0 <.L24+0xe2>
				putch(' ', putdat);
f0103792:	83 ec 08             	sub    $0x8,%esp
f0103795:	57                   	push   %edi
f0103796:	6a 20                	push   $0x20
f0103798:	ff d6                	call   *%esi
			for (; width > 0; width--)
f010379a:	83 eb 01             	sub    $0x1,%ebx
f010379d:	83 c4 10             	add    $0x10,%esp
f01037a0:	85 db                	test   %ebx,%ebx
f01037a2:	7f ee                	jg     f0103792 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01037a4:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01037a7:	89 45 14             	mov    %eax,0x14(%ebp)
f01037aa:	e9 7c 01 00 00       	jmp    f010392b <.L25+0x45>
f01037af:	89 cb                	mov    %ecx,%ebx
f01037b1:	eb ed                	jmp    f01037a0 <.L24+0xe2>

f01037b3 <.L29>:
	if (lflag >= 2)
f01037b3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01037b6:	8b 75 08             	mov    0x8(%ebp),%esi
f01037b9:	83 f9 01             	cmp    $0x1,%ecx
f01037bc:	7f 1b                	jg     f01037d9 <.L29+0x26>
	else if (lflag)
f01037be:	85 c9                	test   %ecx,%ecx
f01037c0:	74 63                	je     f0103825 <.L29+0x72>
		return va_arg(*ap, long);
f01037c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01037c5:	8b 00                	mov    (%eax),%eax
f01037c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037ca:	99                   	cltd   
f01037cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01037ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01037d1:	8d 40 04             	lea    0x4(%eax),%eax
f01037d4:	89 45 14             	mov    %eax,0x14(%ebp)
f01037d7:	eb 17                	jmp    f01037f0 <.L29+0x3d>
		return va_arg(*ap, long long);
f01037d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01037dc:	8b 50 04             	mov    0x4(%eax),%edx
f01037df:	8b 00                	mov    (%eax),%eax
f01037e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01037e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01037e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01037ea:	8d 40 08             	lea    0x8(%eax),%eax
f01037ed:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01037f0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01037f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
f01037f6:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
f01037fb:	85 db                	test   %ebx,%ebx
f01037fd:	0f 89 0e 01 00 00    	jns    f0103911 <.L25+0x2b>
				putch('-', putdat);
f0103803:	83 ec 08             	sub    $0x8,%esp
f0103806:	57                   	push   %edi
f0103807:	6a 2d                	push   $0x2d
f0103809:	ff d6                	call   *%esi
				num = -(long long) num;
f010380b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010380e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103811:	f7 d9                	neg    %ecx
f0103813:	83 d3 00             	adc    $0x0,%ebx
f0103816:	f7 db                	neg    %ebx
f0103818:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010381b:	ba 0a 00 00 00       	mov    $0xa,%edx
f0103820:	e9 ec 00 00 00       	jmp    f0103911 <.L25+0x2b>
		return va_arg(*ap, int);
f0103825:	8b 45 14             	mov    0x14(%ebp),%eax
f0103828:	8b 00                	mov    (%eax),%eax
f010382a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010382d:	99                   	cltd   
f010382e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103831:	8b 45 14             	mov    0x14(%ebp),%eax
f0103834:	8d 40 04             	lea    0x4(%eax),%eax
f0103837:	89 45 14             	mov    %eax,0x14(%ebp)
f010383a:	eb b4                	jmp    f01037f0 <.L29+0x3d>

f010383c <.L23>:
	if (lflag >= 2)
f010383c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010383f:	8b 75 08             	mov    0x8(%ebp),%esi
f0103842:	83 f9 01             	cmp    $0x1,%ecx
f0103845:	7f 1e                	jg     f0103865 <.L23+0x29>
	else if (lflag)
f0103847:	85 c9                	test   %ecx,%ecx
f0103849:	74 32                	je     f010387d <.L23+0x41>
		return va_arg(*ap, unsigned long);
f010384b:	8b 45 14             	mov    0x14(%ebp),%eax
f010384e:	8b 08                	mov    (%eax),%ecx
f0103850:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103855:	8d 40 04             	lea    0x4(%eax),%eax
f0103858:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010385b:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
f0103860:	e9 ac 00 00 00       	jmp    f0103911 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0103865:	8b 45 14             	mov    0x14(%ebp),%eax
f0103868:	8b 08                	mov    (%eax),%ecx
f010386a:	8b 58 04             	mov    0x4(%eax),%ebx
f010386d:	8d 40 08             	lea    0x8(%eax),%eax
f0103870:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103873:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
f0103878:	e9 94 00 00 00       	jmp    f0103911 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010387d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103880:	8b 08                	mov    (%eax),%ecx
f0103882:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103887:	8d 40 04             	lea    0x4(%eax),%eax
f010388a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010388d:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
f0103892:	eb 7d                	jmp    f0103911 <.L25+0x2b>

f0103894 <.L26>:
	if (lflag >= 2)
f0103894:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103897:	8b 75 08             	mov    0x8(%ebp),%esi
f010389a:	83 f9 01             	cmp    $0x1,%ecx
f010389d:	7f 1b                	jg     f01038ba <.L26+0x26>
	else if (lflag)
f010389f:	85 c9                	test   %ecx,%ecx
f01038a1:	74 2c                	je     f01038cf <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f01038a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01038a6:	8b 08                	mov    (%eax),%ecx
f01038a8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01038ad:	8d 40 04             	lea    0x4(%eax),%eax
f01038b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01038b3:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
f01038b8:	eb 57                	jmp    f0103911 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01038ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01038bd:	8b 08                	mov    (%eax),%ecx
f01038bf:	8b 58 04             	mov    0x4(%eax),%ebx
f01038c2:	8d 40 08             	lea    0x8(%eax),%eax
f01038c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01038c8:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
f01038cd:	eb 42                	jmp    f0103911 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01038cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01038d2:	8b 08                	mov    (%eax),%ecx
f01038d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01038d9:	8d 40 04             	lea    0x4(%eax),%eax
f01038dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01038df:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
f01038e4:	eb 2b                	jmp    f0103911 <.L25+0x2b>

f01038e6 <.L25>:
			putch('0', putdat);
f01038e6:	8b 75 08             	mov    0x8(%ebp),%esi
f01038e9:	83 ec 08             	sub    $0x8,%esp
f01038ec:	57                   	push   %edi
f01038ed:	6a 30                	push   $0x30
f01038ef:	ff d6                	call   *%esi
			putch('x', putdat);
f01038f1:	83 c4 08             	add    $0x8,%esp
f01038f4:	57                   	push   %edi
f01038f5:	6a 78                	push   $0x78
f01038f7:	ff d6                	call   *%esi
			num = (unsigned long long)
f01038f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01038fc:	8b 08                	mov    (%eax),%ecx
f01038fe:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
f0103903:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103906:	8d 40 04             	lea    0x4(%eax),%eax
f0103909:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010390c:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
f0103911:	83 ec 0c             	sub    $0xc,%esp
f0103914:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0103918:	50                   	push   %eax
f0103919:	ff 75 d4             	push   -0x2c(%ebp)
f010391c:	52                   	push   %edx
f010391d:	53                   	push   %ebx
f010391e:	51                   	push   %ecx
f010391f:	89 fa                	mov    %edi,%edx
f0103921:	89 f0                	mov    %esi,%eax
f0103923:	e8 f4 fa ff ff       	call   f010341c <printnum>
			break;
f0103928:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f010392b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010392e:	e9 15 fc ff ff       	jmp    f0103548 <vprintfmt+0x34>

f0103933 <.L21>:
	if (lflag >= 2)
f0103933:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103936:	8b 75 08             	mov    0x8(%ebp),%esi
f0103939:	83 f9 01             	cmp    $0x1,%ecx
f010393c:	7f 1b                	jg     f0103959 <.L21+0x26>
	else if (lflag)
f010393e:	85 c9                	test   %ecx,%ecx
f0103940:	74 2c                	je     f010396e <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0103942:	8b 45 14             	mov    0x14(%ebp),%eax
f0103945:	8b 08                	mov    (%eax),%ecx
f0103947:	bb 00 00 00 00       	mov    $0x0,%ebx
f010394c:	8d 40 04             	lea    0x4(%eax),%eax
f010394f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103952:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
f0103957:	eb b8                	jmp    f0103911 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0103959:	8b 45 14             	mov    0x14(%ebp),%eax
f010395c:	8b 08                	mov    (%eax),%ecx
f010395e:	8b 58 04             	mov    0x4(%eax),%ebx
f0103961:	8d 40 08             	lea    0x8(%eax),%eax
f0103964:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103967:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
f010396c:	eb a3                	jmp    f0103911 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010396e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103971:	8b 08                	mov    (%eax),%ecx
f0103973:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103978:	8d 40 04             	lea    0x4(%eax),%eax
f010397b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010397e:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
f0103983:	eb 8c                	jmp    f0103911 <.L25+0x2b>

f0103985 <.L35>:
			putch(ch, putdat);
f0103985:	8b 75 08             	mov    0x8(%ebp),%esi
f0103988:	83 ec 08             	sub    $0x8,%esp
f010398b:	57                   	push   %edi
f010398c:	6a 25                	push   $0x25
f010398e:	ff d6                	call   *%esi
			break;
f0103990:	83 c4 10             	add    $0x10,%esp
f0103993:	eb 96                	jmp    f010392b <.L25+0x45>

f0103995 <.L20>:
			putch('%', putdat);
f0103995:	8b 75 08             	mov    0x8(%ebp),%esi
f0103998:	83 ec 08             	sub    $0x8,%esp
f010399b:	57                   	push   %edi
f010399c:	6a 25                	push   $0x25
f010399e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01039a0:	83 c4 10             	add    $0x10,%esp
f01039a3:	89 d8                	mov    %ebx,%eax
f01039a5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01039a9:	74 05                	je     f01039b0 <.L20+0x1b>
f01039ab:	83 e8 01             	sub    $0x1,%eax
f01039ae:	eb f5                	jmp    f01039a5 <.L20+0x10>
f01039b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01039b3:	e9 73 ff ff ff       	jmp    f010392b <.L25+0x45>

f01039b8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01039b8:	55                   	push   %ebp
f01039b9:	89 e5                	mov    %esp,%ebp
f01039bb:	53                   	push   %ebx
f01039bc:	83 ec 14             	sub    $0x14,%esp
f01039bf:	e8 e7 c7 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f01039c4:	81 c3 4c 39 01 00    	add    $0x1394c,%ebx
f01039ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01039cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01039d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01039d3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01039d7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01039da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01039e1:	85 c0                	test   %eax,%eax
f01039e3:	74 2b                	je     f0103a10 <vsnprintf+0x58>
f01039e5:	85 d2                	test   %edx,%edx
f01039e7:	7e 27                	jle    f0103a10 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01039e9:	ff 75 14             	push   0x14(%ebp)
f01039ec:	ff 75 10             	push   0x10(%ebp)
f01039ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01039f2:	50                   	push   %eax
f01039f3:	8d 83 ca c1 fe ff    	lea    -0x13e36(%ebx),%eax
f01039f9:	50                   	push   %eax
f01039fa:	e8 15 fb ff ff       	call   f0103514 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01039ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103a02:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a08:	83 c4 10             	add    $0x10,%esp
}
f0103a0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a0e:	c9                   	leave  
f0103a0f:	c3                   	ret    
		return -E_INVAL;
f0103a10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103a15:	eb f4                	jmp    f0103a0b <vsnprintf+0x53>

f0103a17 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103a17:	55                   	push   %ebp
f0103a18:	89 e5                	mov    %esp,%ebp
f0103a1a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103a1d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103a20:	50                   	push   %eax
f0103a21:	ff 75 10             	push   0x10(%ebp)
f0103a24:	ff 75 0c             	push   0xc(%ebp)
f0103a27:	ff 75 08             	push   0x8(%ebp)
f0103a2a:	e8 89 ff ff ff       	call   f01039b8 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103a2f:	c9                   	leave  
f0103a30:	c3                   	ret    

f0103a31 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103a31:	55                   	push   %ebp
f0103a32:	89 e5                	mov    %esp,%ebp
f0103a34:	57                   	push   %edi
f0103a35:	56                   	push   %esi
f0103a36:	53                   	push   %ebx
f0103a37:	83 ec 1c             	sub    $0x1c,%esp
f0103a3a:	e8 6c c7 ff ff       	call   f01001ab <__x86.get_pc_thunk.bx>
f0103a3f:	81 c3 d1 38 01 00    	add    $0x138d1,%ebx
f0103a45:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103a48:	85 c0                	test   %eax,%eax
f0103a4a:	74 13                	je     f0103a5f <readline+0x2e>
		cprintf("%s", prompt);
f0103a4c:	83 ec 08             	sub    $0x8,%esp
f0103a4f:	50                   	push   %eax
f0103a50:	8d 83 40 d3 fe ff    	lea    -0x12cc0(%ebx),%eax
f0103a56:	50                   	push   %eax
f0103a57:	e8 65 f6 ff ff       	call   f01030c1 <cprintf>
f0103a5c:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103a5f:	83 ec 0c             	sub    $0xc,%esp
f0103a62:	6a 00                	push   $0x0
f0103a64:	e8 d0 cc ff ff       	call   f0100739 <iscons>
f0103a69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a6c:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103a6f:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0103a74:	8d 83 d0 1f 00 00    	lea    0x1fd0(%ebx),%eax
f0103a7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103a7d:	eb 45                	jmp    f0103ac4 <readline+0x93>
			cprintf("read error: %e\n", c);
f0103a7f:	83 ec 08             	sub    $0x8,%esp
f0103a82:	50                   	push   %eax
f0103a83:	8d 83 a8 df fe ff    	lea    -0x12058(%ebx),%eax
f0103a89:	50                   	push   %eax
f0103a8a:	e8 32 f6 ff ff       	call   f01030c1 <cprintf>
			return NULL;
f0103a8f:	83 c4 10             	add    $0x10,%esp
f0103a92:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a9a:	5b                   	pop    %ebx
f0103a9b:	5e                   	pop    %esi
f0103a9c:	5f                   	pop    %edi
f0103a9d:	5d                   	pop    %ebp
f0103a9e:	c3                   	ret    
			if (echoing)
f0103a9f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103aa3:	75 05                	jne    f0103aaa <readline+0x79>
			i--;
f0103aa5:	83 ef 01             	sub    $0x1,%edi
f0103aa8:	eb 1a                	jmp    f0103ac4 <readline+0x93>
				cputchar('\b');
f0103aaa:	83 ec 0c             	sub    $0xc,%esp
f0103aad:	6a 08                	push   $0x8
f0103aaf:	e8 64 cc ff ff       	call   f0100718 <cputchar>
f0103ab4:	83 c4 10             	add    $0x10,%esp
f0103ab7:	eb ec                	jmp    f0103aa5 <readline+0x74>
			buf[i++] = c;
f0103ab9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103abc:	89 f0                	mov    %esi,%eax
f0103abe:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0103ac1:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103ac4:	e8 5f cc ff ff       	call   f0100728 <getchar>
f0103ac9:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103acb:	85 c0                	test   %eax,%eax
f0103acd:	78 b0                	js     f0103a7f <readline+0x4e>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103acf:	83 f8 08             	cmp    $0x8,%eax
f0103ad2:	0f 94 c0             	sete   %al
f0103ad5:	83 fe 7f             	cmp    $0x7f,%esi
f0103ad8:	0f 94 c2             	sete   %dl
f0103adb:	08 d0                	or     %dl,%al
f0103add:	74 04                	je     f0103ae3 <readline+0xb2>
f0103adf:	85 ff                	test   %edi,%edi
f0103ae1:	7f bc                	jg     f0103a9f <readline+0x6e>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103ae3:	83 fe 1f             	cmp    $0x1f,%esi
f0103ae6:	7e 1c                	jle    f0103b04 <readline+0xd3>
f0103ae8:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103aee:	7f 14                	jg     f0103b04 <readline+0xd3>
			if (echoing)
f0103af0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103af4:	74 c3                	je     f0103ab9 <readline+0x88>
				cputchar(c);
f0103af6:	83 ec 0c             	sub    $0xc,%esp
f0103af9:	56                   	push   %esi
f0103afa:	e8 19 cc ff ff       	call   f0100718 <cputchar>
f0103aff:	83 c4 10             	add    $0x10,%esp
f0103b02:	eb b5                	jmp    f0103ab9 <readline+0x88>
		} else if (c == '\n' || c == '\r') {
f0103b04:	83 fe 0a             	cmp    $0xa,%esi
f0103b07:	74 05                	je     f0103b0e <readline+0xdd>
f0103b09:	83 fe 0d             	cmp    $0xd,%esi
f0103b0c:	75 b6                	jne    f0103ac4 <readline+0x93>
			if (echoing)
f0103b0e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103b12:	75 13                	jne    f0103b27 <readline+0xf6>
			buf[i] = 0;
f0103b14:	c6 84 3b d0 1f 00 00 	movb   $0x0,0x1fd0(%ebx,%edi,1)
f0103b1b:	00 
			return buf;
f0103b1c:	8d 83 d0 1f 00 00    	lea    0x1fd0(%ebx),%eax
f0103b22:	e9 70 ff ff ff       	jmp    f0103a97 <readline+0x66>
				cputchar('\n');
f0103b27:	83 ec 0c             	sub    $0xc,%esp
f0103b2a:	6a 0a                	push   $0xa
f0103b2c:	e8 e7 cb ff ff       	call   f0100718 <cputchar>
f0103b31:	83 c4 10             	add    $0x10,%esp
f0103b34:	eb de                	jmp    f0103b14 <readline+0xe3>

f0103b36 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103b36:	55                   	push   %ebp
f0103b37:	89 e5                	mov    %esp,%ebp
f0103b39:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103b3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b41:	eb 03                	jmp    f0103b46 <strlen+0x10>
		n++;
f0103b43:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103b46:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103b4a:	75 f7                	jne    f0103b43 <strlen+0xd>
	return n;
}
f0103b4c:	5d                   	pop    %ebp
f0103b4d:	c3                   	ret    

f0103b4e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103b4e:	55                   	push   %ebp
f0103b4f:	89 e5                	mov    %esp,%ebp
f0103b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b54:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103b57:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b5c:	eb 03                	jmp    f0103b61 <strnlen+0x13>
		n++;
f0103b5e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103b61:	39 d0                	cmp    %edx,%eax
f0103b63:	74 08                	je     f0103b6d <strnlen+0x1f>
f0103b65:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103b69:	75 f3                	jne    f0103b5e <strnlen+0x10>
f0103b6b:	89 c2                	mov    %eax,%edx
	return n;
}
f0103b6d:	89 d0                	mov    %edx,%eax
f0103b6f:	5d                   	pop    %ebp
f0103b70:	c3                   	ret    

f0103b71 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103b71:	55                   	push   %ebp
f0103b72:	89 e5                	mov    %esp,%ebp
f0103b74:	53                   	push   %ebx
f0103b75:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103b7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b80:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0103b84:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0103b87:	83 c0 01             	add    $0x1,%eax
f0103b8a:	84 d2                	test   %dl,%dl
f0103b8c:	75 f2                	jne    f0103b80 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103b8e:	89 c8                	mov    %ecx,%eax
f0103b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103b93:	c9                   	leave  
f0103b94:	c3                   	ret    

f0103b95 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103b95:	55                   	push   %ebp
f0103b96:	89 e5                	mov    %esp,%ebp
f0103b98:	53                   	push   %ebx
f0103b99:	83 ec 10             	sub    $0x10,%esp
f0103b9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103b9f:	53                   	push   %ebx
f0103ba0:	e8 91 ff ff ff       	call   f0103b36 <strlen>
f0103ba5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0103ba8:	ff 75 0c             	push   0xc(%ebp)
f0103bab:	01 d8                	add    %ebx,%eax
f0103bad:	50                   	push   %eax
f0103bae:	e8 be ff ff ff       	call   f0103b71 <strcpy>
	return dst;
}
f0103bb3:	89 d8                	mov    %ebx,%eax
f0103bb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103bb8:	c9                   	leave  
f0103bb9:	c3                   	ret    

f0103bba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103bba:	55                   	push   %ebp
f0103bbb:	89 e5                	mov    %esp,%ebp
f0103bbd:	56                   	push   %esi
f0103bbe:	53                   	push   %ebx
f0103bbf:	8b 75 08             	mov    0x8(%ebp),%esi
f0103bc2:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103bc5:	89 f3                	mov    %esi,%ebx
f0103bc7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103bca:	89 f0                	mov    %esi,%eax
f0103bcc:	eb 0f                	jmp    f0103bdd <strncpy+0x23>
		*dst++ = *src;
f0103bce:	83 c0 01             	add    $0x1,%eax
f0103bd1:	0f b6 0a             	movzbl (%edx),%ecx
f0103bd4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103bd7:	80 f9 01             	cmp    $0x1,%cl
f0103bda:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0103bdd:	39 d8                	cmp    %ebx,%eax
f0103bdf:	75 ed                	jne    f0103bce <strncpy+0x14>
	}
	return ret;
}
f0103be1:	89 f0                	mov    %esi,%eax
f0103be3:	5b                   	pop    %ebx
f0103be4:	5e                   	pop    %esi
f0103be5:	5d                   	pop    %ebp
f0103be6:	c3                   	ret    

f0103be7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103be7:	55                   	push   %ebp
f0103be8:	89 e5                	mov    %esp,%ebp
f0103bea:	56                   	push   %esi
f0103beb:	53                   	push   %ebx
f0103bec:	8b 75 08             	mov    0x8(%ebp),%esi
f0103bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103bf2:	8b 55 10             	mov    0x10(%ebp),%edx
f0103bf5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103bf7:	85 d2                	test   %edx,%edx
f0103bf9:	74 21                	je     f0103c1c <strlcpy+0x35>
f0103bfb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103bff:	89 f2                	mov    %esi,%edx
f0103c01:	eb 09                	jmp    f0103c0c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103c03:	83 c1 01             	add    $0x1,%ecx
f0103c06:	83 c2 01             	add    $0x1,%edx
f0103c09:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0103c0c:	39 c2                	cmp    %eax,%edx
f0103c0e:	74 09                	je     f0103c19 <strlcpy+0x32>
f0103c10:	0f b6 19             	movzbl (%ecx),%ebx
f0103c13:	84 db                	test   %bl,%bl
f0103c15:	75 ec                	jne    f0103c03 <strlcpy+0x1c>
f0103c17:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0103c19:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103c1c:	29 f0                	sub    %esi,%eax
}
f0103c1e:	5b                   	pop    %ebx
f0103c1f:	5e                   	pop    %esi
f0103c20:	5d                   	pop    %ebp
f0103c21:	c3                   	ret    

f0103c22 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103c22:	55                   	push   %ebp
f0103c23:	89 e5                	mov    %esp,%ebp
f0103c25:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c28:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103c2b:	eb 06                	jmp    f0103c33 <strcmp+0x11>
		p++, q++;
f0103c2d:	83 c1 01             	add    $0x1,%ecx
f0103c30:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103c33:	0f b6 01             	movzbl (%ecx),%eax
f0103c36:	84 c0                	test   %al,%al
f0103c38:	74 04                	je     f0103c3e <strcmp+0x1c>
f0103c3a:	3a 02                	cmp    (%edx),%al
f0103c3c:	74 ef                	je     f0103c2d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103c3e:	0f b6 c0             	movzbl %al,%eax
f0103c41:	0f b6 12             	movzbl (%edx),%edx
f0103c44:	29 d0                	sub    %edx,%eax
}
f0103c46:	5d                   	pop    %ebp
f0103c47:	c3                   	ret    

f0103c48 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103c48:	55                   	push   %ebp
f0103c49:	89 e5                	mov    %esp,%ebp
f0103c4b:	53                   	push   %ebx
f0103c4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c52:	89 c3                	mov    %eax,%ebx
f0103c54:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103c57:	eb 06                	jmp    f0103c5f <strncmp+0x17>
		n--, p++, q++;
f0103c59:	83 c0 01             	add    $0x1,%eax
f0103c5c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103c5f:	39 d8                	cmp    %ebx,%eax
f0103c61:	74 18                	je     f0103c7b <strncmp+0x33>
f0103c63:	0f b6 08             	movzbl (%eax),%ecx
f0103c66:	84 c9                	test   %cl,%cl
f0103c68:	74 04                	je     f0103c6e <strncmp+0x26>
f0103c6a:	3a 0a                	cmp    (%edx),%cl
f0103c6c:	74 eb                	je     f0103c59 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103c6e:	0f b6 00             	movzbl (%eax),%eax
f0103c71:	0f b6 12             	movzbl (%edx),%edx
f0103c74:	29 d0                	sub    %edx,%eax
}
f0103c76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c79:	c9                   	leave  
f0103c7a:	c3                   	ret    
		return 0;
f0103c7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c80:	eb f4                	jmp    f0103c76 <strncmp+0x2e>

f0103c82 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103c82:	55                   	push   %ebp
f0103c83:	89 e5                	mov    %esp,%ebp
f0103c85:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c88:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103c8c:	eb 03                	jmp    f0103c91 <strchr+0xf>
f0103c8e:	83 c0 01             	add    $0x1,%eax
f0103c91:	0f b6 10             	movzbl (%eax),%edx
f0103c94:	84 d2                	test   %dl,%dl
f0103c96:	74 06                	je     f0103c9e <strchr+0x1c>
		if (*s == c)
f0103c98:	38 ca                	cmp    %cl,%dl
f0103c9a:	75 f2                	jne    f0103c8e <strchr+0xc>
f0103c9c:	eb 05                	jmp    f0103ca3 <strchr+0x21>
			return (char *) s;
	return 0;
f0103c9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ca3:	5d                   	pop    %ebp
f0103ca4:	c3                   	ret    

f0103ca5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103ca5:	55                   	push   %ebp
f0103ca6:	89 e5                	mov    %esp,%ebp
f0103ca8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103caf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103cb2:	38 ca                	cmp    %cl,%dl
f0103cb4:	74 09                	je     f0103cbf <strfind+0x1a>
f0103cb6:	84 d2                	test   %dl,%dl
f0103cb8:	74 05                	je     f0103cbf <strfind+0x1a>
	for (; *s; s++)
f0103cba:	83 c0 01             	add    $0x1,%eax
f0103cbd:	eb f0                	jmp    f0103caf <strfind+0xa>
			break;
	return (char *) s;
}
f0103cbf:	5d                   	pop    %ebp
f0103cc0:	c3                   	ret    

f0103cc1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103cc1:	55                   	push   %ebp
f0103cc2:	89 e5                	mov    %esp,%ebp
f0103cc4:	57                   	push   %edi
f0103cc5:	56                   	push   %esi
f0103cc6:	53                   	push   %ebx
f0103cc7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103cca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103ccd:	85 c9                	test   %ecx,%ecx
f0103ccf:	74 2f                	je     f0103d00 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103cd1:	89 f8                	mov    %edi,%eax
f0103cd3:	09 c8                	or     %ecx,%eax
f0103cd5:	a8 03                	test   $0x3,%al
f0103cd7:	75 21                	jne    f0103cfa <memset+0x39>
		c &= 0xFF;
f0103cd9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103cdd:	89 d0                	mov    %edx,%eax
f0103cdf:	c1 e0 08             	shl    $0x8,%eax
f0103ce2:	89 d3                	mov    %edx,%ebx
f0103ce4:	c1 e3 18             	shl    $0x18,%ebx
f0103ce7:	89 d6                	mov    %edx,%esi
f0103ce9:	c1 e6 10             	shl    $0x10,%esi
f0103cec:	09 f3                	or     %esi,%ebx
f0103cee:	09 da                	or     %ebx,%edx
f0103cf0:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103cf2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103cf5:	fc                   	cld    
f0103cf6:	f3 ab                	rep stos %eax,%es:(%edi)
f0103cf8:	eb 06                	jmp    f0103d00 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103cfd:	fc                   	cld    
f0103cfe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103d00:	89 f8                	mov    %edi,%eax
f0103d02:	5b                   	pop    %ebx
f0103d03:	5e                   	pop    %esi
f0103d04:	5f                   	pop    %edi
f0103d05:	5d                   	pop    %ebp
f0103d06:	c3                   	ret    

f0103d07 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103d07:	55                   	push   %ebp
f0103d08:	89 e5                	mov    %esp,%ebp
f0103d0a:	57                   	push   %edi
f0103d0b:	56                   	push   %esi
f0103d0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d0f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103d12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103d15:	39 c6                	cmp    %eax,%esi
f0103d17:	73 32                	jae    f0103d4b <memmove+0x44>
f0103d19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103d1c:	39 c2                	cmp    %eax,%edx
f0103d1e:	76 2b                	jbe    f0103d4b <memmove+0x44>
		s += n;
		d += n;
f0103d20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103d23:	89 d6                	mov    %edx,%esi
f0103d25:	09 fe                	or     %edi,%esi
f0103d27:	09 ce                	or     %ecx,%esi
f0103d29:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103d2f:	75 0e                	jne    f0103d3f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103d31:	83 ef 04             	sub    $0x4,%edi
f0103d34:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103d37:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0103d3a:	fd                   	std    
f0103d3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103d3d:	eb 09                	jmp    f0103d48 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103d3f:	83 ef 01             	sub    $0x1,%edi
f0103d42:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103d45:	fd                   	std    
f0103d46:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103d48:	fc                   	cld    
f0103d49:	eb 1a                	jmp    f0103d65 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103d4b:	89 f2                	mov    %esi,%edx
f0103d4d:	09 c2                	or     %eax,%edx
f0103d4f:	09 ca                	or     %ecx,%edx
f0103d51:	f6 c2 03             	test   $0x3,%dl
f0103d54:	75 0a                	jne    f0103d60 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103d56:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0103d59:	89 c7                	mov    %eax,%edi
f0103d5b:	fc                   	cld    
f0103d5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103d5e:	eb 05                	jmp    f0103d65 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0103d60:	89 c7                	mov    %eax,%edi
f0103d62:	fc                   	cld    
f0103d63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103d65:	5e                   	pop    %esi
f0103d66:	5f                   	pop    %edi
f0103d67:	5d                   	pop    %ebp
f0103d68:	c3                   	ret    

f0103d69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103d69:	55                   	push   %ebp
f0103d6a:	89 e5                	mov    %esp,%ebp
f0103d6c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103d6f:	ff 75 10             	push   0x10(%ebp)
f0103d72:	ff 75 0c             	push   0xc(%ebp)
f0103d75:	ff 75 08             	push   0x8(%ebp)
f0103d78:	e8 8a ff ff ff       	call   f0103d07 <memmove>
}
f0103d7d:	c9                   	leave  
f0103d7e:	c3                   	ret    

f0103d7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103d7f:	55                   	push   %ebp
f0103d80:	89 e5                	mov    %esp,%ebp
f0103d82:	56                   	push   %esi
f0103d83:	53                   	push   %ebx
f0103d84:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d87:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d8a:	89 c6                	mov    %eax,%esi
f0103d8c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103d8f:	eb 06                	jmp    f0103d97 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0103d91:	83 c0 01             	add    $0x1,%eax
f0103d94:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0103d97:	39 f0                	cmp    %esi,%eax
f0103d99:	74 14                	je     f0103daf <memcmp+0x30>
		if (*s1 != *s2)
f0103d9b:	0f b6 08             	movzbl (%eax),%ecx
f0103d9e:	0f b6 1a             	movzbl (%edx),%ebx
f0103da1:	38 d9                	cmp    %bl,%cl
f0103da3:	74 ec                	je     f0103d91 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0103da5:	0f b6 c1             	movzbl %cl,%eax
f0103da8:	0f b6 db             	movzbl %bl,%ebx
f0103dab:	29 d8                	sub    %ebx,%eax
f0103dad:	eb 05                	jmp    f0103db4 <memcmp+0x35>
	}

	return 0;
f0103daf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103db4:	5b                   	pop    %ebx
f0103db5:	5e                   	pop    %esi
f0103db6:	5d                   	pop    %ebp
f0103db7:	c3                   	ret    

f0103db8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103db8:	55                   	push   %ebp
f0103db9:	89 e5                	mov    %esp,%ebp
f0103dbb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103dc1:	89 c2                	mov    %eax,%edx
f0103dc3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103dc6:	eb 03                	jmp    f0103dcb <memfind+0x13>
f0103dc8:	83 c0 01             	add    $0x1,%eax
f0103dcb:	39 d0                	cmp    %edx,%eax
f0103dcd:	73 04                	jae    f0103dd3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103dcf:	38 08                	cmp    %cl,(%eax)
f0103dd1:	75 f5                	jne    f0103dc8 <memfind+0x10>
			break;
	return (void *) s;
}
f0103dd3:	5d                   	pop    %ebp
f0103dd4:	c3                   	ret    

f0103dd5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103dd5:	55                   	push   %ebp
f0103dd6:	89 e5                	mov    %esp,%ebp
f0103dd8:	57                   	push   %edi
f0103dd9:	56                   	push   %esi
f0103dda:	53                   	push   %ebx
f0103ddb:	8b 55 08             	mov    0x8(%ebp),%edx
f0103dde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103de1:	eb 03                	jmp    f0103de6 <strtol+0x11>
		s++;
f0103de3:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0103de6:	0f b6 02             	movzbl (%edx),%eax
f0103de9:	3c 20                	cmp    $0x20,%al
f0103deb:	74 f6                	je     f0103de3 <strtol+0xe>
f0103ded:	3c 09                	cmp    $0x9,%al
f0103def:	74 f2                	je     f0103de3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0103df1:	3c 2b                	cmp    $0x2b,%al
f0103df3:	74 2a                	je     f0103e1f <strtol+0x4a>
	int neg = 0;
f0103df5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0103dfa:	3c 2d                	cmp    $0x2d,%al
f0103dfc:	74 2b                	je     f0103e29 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103dfe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103e04:	75 0f                	jne    f0103e15 <strtol+0x40>
f0103e06:	80 3a 30             	cmpb   $0x30,(%edx)
f0103e09:	74 28                	je     f0103e33 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103e0b:	85 db                	test   %ebx,%ebx
f0103e0d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e12:	0f 44 d8             	cmove  %eax,%ebx
f0103e15:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e1a:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0103e1d:	eb 46                	jmp    f0103e65 <strtol+0x90>
		s++;
f0103e1f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0103e22:	bf 00 00 00 00       	mov    $0x0,%edi
f0103e27:	eb d5                	jmp    f0103dfe <strtol+0x29>
		s++, neg = 1;
f0103e29:	83 c2 01             	add    $0x1,%edx
f0103e2c:	bf 01 00 00 00       	mov    $0x1,%edi
f0103e31:	eb cb                	jmp    f0103dfe <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103e33:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103e37:	74 0e                	je     f0103e47 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0103e39:	85 db                	test   %ebx,%ebx
f0103e3b:	75 d8                	jne    f0103e15 <strtol+0x40>
		s++, base = 8;
f0103e3d:	83 c2 01             	add    $0x1,%edx
f0103e40:	bb 08 00 00 00       	mov    $0x8,%ebx
f0103e45:	eb ce                	jmp    f0103e15 <strtol+0x40>
		s += 2, base = 16;
f0103e47:	83 c2 02             	add    $0x2,%edx
f0103e4a:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103e4f:	eb c4                	jmp    f0103e15 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0103e51:	0f be c0             	movsbl %al,%eax
f0103e54:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0103e57:	3b 45 10             	cmp    0x10(%ebp),%eax
f0103e5a:	7d 3a                	jge    f0103e96 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0103e5c:	83 c2 01             	add    $0x1,%edx
f0103e5f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0103e63:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0103e65:	0f b6 02             	movzbl (%edx),%eax
f0103e68:	8d 70 d0             	lea    -0x30(%eax),%esi
f0103e6b:	89 f3                	mov    %esi,%ebx
f0103e6d:	80 fb 09             	cmp    $0x9,%bl
f0103e70:	76 df                	jbe    f0103e51 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0103e72:	8d 70 9f             	lea    -0x61(%eax),%esi
f0103e75:	89 f3                	mov    %esi,%ebx
f0103e77:	80 fb 19             	cmp    $0x19,%bl
f0103e7a:	77 08                	ja     f0103e84 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0103e7c:	0f be c0             	movsbl %al,%eax
f0103e7f:	83 e8 57             	sub    $0x57,%eax
f0103e82:	eb d3                	jmp    f0103e57 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0103e84:	8d 70 bf             	lea    -0x41(%eax),%esi
f0103e87:	89 f3                	mov    %esi,%ebx
f0103e89:	80 fb 19             	cmp    $0x19,%bl
f0103e8c:	77 08                	ja     f0103e96 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0103e8e:	0f be c0             	movsbl %al,%eax
f0103e91:	83 e8 37             	sub    $0x37,%eax
f0103e94:	eb c1                	jmp    f0103e57 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0103e96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103e9a:	74 05                	je     f0103ea1 <strtol+0xcc>
		*endptr = (char *) s;
f0103e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e9f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0103ea1:	89 c8                	mov    %ecx,%eax
f0103ea3:	f7 d8                	neg    %eax
f0103ea5:	85 ff                	test   %edi,%edi
f0103ea7:	0f 45 c8             	cmovne %eax,%ecx
}
f0103eaa:	89 c8                	mov    %ecx,%eax
f0103eac:	5b                   	pop    %ebx
f0103ead:	5e                   	pop    %esi
f0103eae:	5f                   	pop    %edi
f0103eaf:	5d                   	pop    %ebp
f0103eb0:	c3                   	ret    
f0103eb1:	66 90                	xchg   %ax,%ax
f0103eb3:	66 90                	xchg   %ax,%ax
f0103eb5:	66 90                	xchg   %ax,%ax
f0103eb7:	66 90                	xchg   %ax,%ax
f0103eb9:	66 90                	xchg   %ax,%ax
f0103ebb:	66 90                	xchg   %ax,%ax
f0103ebd:	66 90                	xchg   %ax,%ax
f0103ebf:	90                   	nop

f0103ec0 <__udivdi3>:
f0103ec0:	f3 0f 1e fb          	endbr32 
f0103ec4:	55                   	push   %ebp
f0103ec5:	57                   	push   %edi
f0103ec6:	56                   	push   %esi
f0103ec7:	53                   	push   %ebx
f0103ec8:	83 ec 1c             	sub    $0x1c,%esp
f0103ecb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0103ecf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0103ed3:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103ed7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0103edb:	85 c0                	test   %eax,%eax
f0103edd:	75 19                	jne    f0103ef8 <__udivdi3+0x38>
f0103edf:	39 f3                	cmp    %esi,%ebx
f0103ee1:	76 4d                	jbe    f0103f30 <__udivdi3+0x70>
f0103ee3:	31 ff                	xor    %edi,%edi
f0103ee5:	89 e8                	mov    %ebp,%eax
f0103ee7:	89 f2                	mov    %esi,%edx
f0103ee9:	f7 f3                	div    %ebx
f0103eeb:	89 fa                	mov    %edi,%edx
f0103eed:	83 c4 1c             	add    $0x1c,%esp
f0103ef0:	5b                   	pop    %ebx
f0103ef1:	5e                   	pop    %esi
f0103ef2:	5f                   	pop    %edi
f0103ef3:	5d                   	pop    %ebp
f0103ef4:	c3                   	ret    
f0103ef5:	8d 76 00             	lea    0x0(%esi),%esi
f0103ef8:	39 f0                	cmp    %esi,%eax
f0103efa:	76 14                	jbe    f0103f10 <__udivdi3+0x50>
f0103efc:	31 ff                	xor    %edi,%edi
f0103efe:	31 c0                	xor    %eax,%eax
f0103f00:	89 fa                	mov    %edi,%edx
f0103f02:	83 c4 1c             	add    $0x1c,%esp
f0103f05:	5b                   	pop    %ebx
f0103f06:	5e                   	pop    %esi
f0103f07:	5f                   	pop    %edi
f0103f08:	5d                   	pop    %ebp
f0103f09:	c3                   	ret    
f0103f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103f10:	0f bd f8             	bsr    %eax,%edi
f0103f13:	83 f7 1f             	xor    $0x1f,%edi
f0103f16:	75 48                	jne    f0103f60 <__udivdi3+0xa0>
f0103f18:	39 f0                	cmp    %esi,%eax
f0103f1a:	72 06                	jb     f0103f22 <__udivdi3+0x62>
f0103f1c:	31 c0                	xor    %eax,%eax
f0103f1e:	39 eb                	cmp    %ebp,%ebx
f0103f20:	77 de                	ja     f0103f00 <__udivdi3+0x40>
f0103f22:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f27:	eb d7                	jmp    f0103f00 <__udivdi3+0x40>
f0103f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103f30:	89 d9                	mov    %ebx,%ecx
f0103f32:	85 db                	test   %ebx,%ebx
f0103f34:	75 0b                	jne    f0103f41 <__udivdi3+0x81>
f0103f36:	b8 01 00 00 00       	mov    $0x1,%eax
f0103f3b:	31 d2                	xor    %edx,%edx
f0103f3d:	f7 f3                	div    %ebx
f0103f3f:	89 c1                	mov    %eax,%ecx
f0103f41:	31 d2                	xor    %edx,%edx
f0103f43:	89 f0                	mov    %esi,%eax
f0103f45:	f7 f1                	div    %ecx
f0103f47:	89 c6                	mov    %eax,%esi
f0103f49:	89 e8                	mov    %ebp,%eax
f0103f4b:	89 f7                	mov    %esi,%edi
f0103f4d:	f7 f1                	div    %ecx
f0103f4f:	89 fa                	mov    %edi,%edx
f0103f51:	83 c4 1c             	add    $0x1c,%esp
f0103f54:	5b                   	pop    %ebx
f0103f55:	5e                   	pop    %esi
f0103f56:	5f                   	pop    %edi
f0103f57:	5d                   	pop    %ebp
f0103f58:	c3                   	ret    
f0103f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103f60:	89 f9                	mov    %edi,%ecx
f0103f62:	ba 20 00 00 00       	mov    $0x20,%edx
f0103f67:	29 fa                	sub    %edi,%edx
f0103f69:	d3 e0                	shl    %cl,%eax
f0103f6b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f6f:	89 d1                	mov    %edx,%ecx
f0103f71:	89 d8                	mov    %ebx,%eax
f0103f73:	d3 e8                	shr    %cl,%eax
f0103f75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103f79:	09 c1                	or     %eax,%ecx
f0103f7b:	89 f0                	mov    %esi,%eax
f0103f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103f81:	89 f9                	mov    %edi,%ecx
f0103f83:	d3 e3                	shl    %cl,%ebx
f0103f85:	89 d1                	mov    %edx,%ecx
f0103f87:	d3 e8                	shr    %cl,%eax
f0103f89:	89 f9                	mov    %edi,%ecx
f0103f8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103f8f:	89 eb                	mov    %ebp,%ebx
f0103f91:	d3 e6                	shl    %cl,%esi
f0103f93:	89 d1                	mov    %edx,%ecx
f0103f95:	d3 eb                	shr    %cl,%ebx
f0103f97:	09 f3                	or     %esi,%ebx
f0103f99:	89 c6                	mov    %eax,%esi
f0103f9b:	89 f2                	mov    %esi,%edx
f0103f9d:	89 d8                	mov    %ebx,%eax
f0103f9f:	f7 74 24 08          	divl   0x8(%esp)
f0103fa3:	89 d6                	mov    %edx,%esi
f0103fa5:	89 c3                	mov    %eax,%ebx
f0103fa7:	f7 64 24 0c          	mull   0xc(%esp)
f0103fab:	39 d6                	cmp    %edx,%esi
f0103fad:	72 19                	jb     f0103fc8 <__udivdi3+0x108>
f0103faf:	89 f9                	mov    %edi,%ecx
f0103fb1:	d3 e5                	shl    %cl,%ebp
f0103fb3:	39 c5                	cmp    %eax,%ebp
f0103fb5:	73 04                	jae    f0103fbb <__udivdi3+0xfb>
f0103fb7:	39 d6                	cmp    %edx,%esi
f0103fb9:	74 0d                	je     f0103fc8 <__udivdi3+0x108>
f0103fbb:	89 d8                	mov    %ebx,%eax
f0103fbd:	31 ff                	xor    %edi,%edi
f0103fbf:	e9 3c ff ff ff       	jmp    f0103f00 <__udivdi3+0x40>
f0103fc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103fc8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103fcb:	31 ff                	xor    %edi,%edi
f0103fcd:	e9 2e ff ff ff       	jmp    f0103f00 <__udivdi3+0x40>
f0103fd2:	66 90                	xchg   %ax,%ax
f0103fd4:	66 90                	xchg   %ax,%ax
f0103fd6:	66 90                	xchg   %ax,%ax
f0103fd8:	66 90                	xchg   %ax,%ax
f0103fda:	66 90                	xchg   %ax,%ax
f0103fdc:	66 90                	xchg   %ax,%ax
f0103fde:	66 90                	xchg   %ax,%ax

f0103fe0 <__umoddi3>:
f0103fe0:	f3 0f 1e fb          	endbr32 
f0103fe4:	55                   	push   %ebp
f0103fe5:	57                   	push   %edi
f0103fe6:	56                   	push   %esi
f0103fe7:	53                   	push   %ebx
f0103fe8:	83 ec 1c             	sub    $0x1c,%esp
f0103feb:	8b 74 24 30          	mov    0x30(%esp),%esi
f0103fef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0103ff3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f0103ff7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f0103ffb:	89 f0                	mov    %esi,%eax
f0103ffd:	89 da                	mov    %ebx,%edx
f0103fff:	85 ff                	test   %edi,%edi
f0104001:	75 15                	jne    f0104018 <__umoddi3+0x38>
f0104003:	39 dd                	cmp    %ebx,%ebp
f0104005:	76 39                	jbe    f0104040 <__umoddi3+0x60>
f0104007:	f7 f5                	div    %ebp
f0104009:	89 d0                	mov    %edx,%eax
f010400b:	31 d2                	xor    %edx,%edx
f010400d:	83 c4 1c             	add    $0x1c,%esp
f0104010:	5b                   	pop    %ebx
f0104011:	5e                   	pop    %esi
f0104012:	5f                   	pop    %edi
f0104013:	5d                   	pop    %ebp
f0104014:	c3                   	ret    
f0104015:	8d 76 00             	lea    0x0(%esi),%esi
f0104018:	39 df                	cmp    %ebx,%edi
f010401a:	77 f1                	ja     f010400d <__umoddi3+0x2d>
f010401c:	0f bd cf             	bsr    %edi,%ecx
f010401f:	83 f1 1f             	xor    $0x1f,%ecx
f0104022:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104026:	75 40                	jne    f0104068 <__umoddi3+0x88>
f0104028:	39 df                	cmp    %ebx,%edi
f010402a:	72 04                	jb     f0104030 <__umoddi3+0x50>
f010402c:	39 f5                	cmp    %esi,%ebp
f010402e:	77 dd                	ja     f010400d <__umoddi3+0x2d>
f0104030:	89 da                	mov    %ebx,%edx
f0104032:	89 f0                	mov    %esi,%eax
f0104034:	29 e8                	sub    %ebp,%eax
f0104036:	19 fa                	sbb    %edi,%edx
f0104038:	eb d3                	jmp    f010400d <__umoddi3+0x2d>
f010403a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104040:	89 e9                	mov    %ebp,%ecx
f0104042:	85 ed                	test   %ebp,%ebp
f0104044:	75 0b                	jne    f0104051 <__umoddi3+0x71>
f0104046:	b8 01 00 00 00       	mov    $0x1,%eax
f010404b:	31 d2                	xor    %edx,%edx
f010404d:	f7 f5                	div    %ebp
f010404f:	89 c1                	mov    %eax,%ecx
f0104051:	89 d8                	mov    %ebx,%eax
f0104053:	31 d2                	xor    %edx,%edx
f0104055:	f7 f1                	div    %ecx
f0104057:	89 f0                	mov    %esi,%eax
f0104059:	f7 f1                	div    %ecx
f010405b:	89 d0                	mov    %edx,%eax
f010405d:	31 d2                	xor    %edx,%edx
f010405f:	eb ac                	jmp    f010400d <__umoddi3+0x2d>
f0104061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104068:	8b 44 24 04          	mov    0x4(%esp),%eax
f010406c:	ba 20 00 00 00       	mov    $0x20,%edx
f0104071:	29 c2                	sub    %eax,%edx
f0104073:	89 c1                	mov    %eax,%ecx
f0104075:	89 e8                	mov    %ebp,%eax
f0104077:	d3 e7                	shl    %cl,%edi
f0104079:	89 d1                	mov    %edx,%ecx
f010407b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010407f:	d3 e8                	shr    %cl,%eax
f0104081:	89 c1                	mov    %eax,%ecx
f0104083:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104087:	09 f9                	or     %edi,%ecx
f0104089:	89 df                	mov    %ebx,%edi
f010408b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010408f:	89 c1                	mov    %eax,%ecx
f0104091:	d3 e5                	shl    %cl,%ebp
f0104093:	89 d1                	mov    %edx,%ecx
f0104095:	d3 ef                	shr    %cl,%edi
f0104097:	89 c1                	mov    %eax,%ecx
f0104099:	89 f0                	mov    %esi,%eax
f010409b:	d3 e3                	shl    %cl,%ebx
f010409d:	89 d1                	mov    %edx,%ecx
f010409f:	89 fa                	mov    %edi,%edx
f01040a1:	d3 e8                	shr    %cl,%eax
f01040a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01040a8:	09 d8                	or     %ebx,%eax
f01040aa:	f7 74 24 08          	divl   0x8(%esp)
f01040ae:	89 d3                	mov    %edx,%ebx
f01040b0:	d3 e6                	shl    %cl,%esi
f01040b2:	f7 e5                	mul    %ebp
f01040b4:	89 c7                	mov    %eax,%edi
f01040b6:	89 d1                	mov    %edx,%ecx
f01040b8:	39 d3                	cmp    %edx,%ebx
f01040ba:	72 06                	jb     f01040c2 <__umoddi3+0xe2>
f01040bc:	75 0e                	jne    f01040cc <__umoddi3+0xec>
f01040be:	39 c6                	cmp    %eax,%esi
f01040c0:	73 0a                	jae    f01040cc <__umoddi3+0xec>
f01040c2:	29 e8                	sub    %ebp,%eax
f01040c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01040c8:	89 d1                	mov    %edx,%ecx
f01040ca:	89 c7                	mov    %eax,%edi
f01040cc:	89 f5                	mov    %esi,%ebp
f01040ce:	8b 74 24 04          	mov    0x4(%esp),%esi
f01040d2:	29 fd                	sub    %edi,%ebp
f01040d4:	19 cb                	sbb    %ecx,%ebx
f01040d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01040db:	89 d8                	mov    %ebx,%eax
f01040dd:	d3 e0                	shl    %cl,%eax
f01040df:	89 f1                	mov    %esi,%ecx
f01040e1:	d3 ed                	shr    %cl,%ebp
f01040e3:	d3 eb                	shr    %cl,%ebx
f01040e5:	09 e8                	or     %ebp,%eax
f01040e7:	89 da                	mov    %ebx,%edx
f01040e9:	83 c4 1c             	add    $0x1c,%esp
f01040ec:	5b                   	pop    %ebx
f01040ed:	5e                   	pop    %esi
f01040ee:	5f                   	pop    %edi
f01040ef:	5d                   	pop    %ebp
f01040f0:	c3                   	ret    

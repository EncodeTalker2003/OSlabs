
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
f0100015:	b8 00 40 12 00       	mov    $0x124000,%eax
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
f0100034:	bc 00 40 12 f0       	mov    $0xf0124000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 61 00 00 00       	call   f010009f <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f0100047:	83 3d 00 70 22 f0 00 	cmpl   $0x0,0xf0227000
f010004e:	74 0f                	je     f010005f <_panic+0x1f>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100050:	83 ec 0c             	sub    $0xc,%esp
f0100053:	6a 00                	push   $0x0
f0100055:	e8 69 0c 00 00       	call   f0100cc3 <monitor>
f010005a:	83 c4 10             	add    $0x10,%esp
f010005d:	eb f1                	jmp    f0100050 <_panic+0x10>
	panicstr = fmt;
f010005f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100062:	a3 00 70 22 f0       	mov    %eax,0xf0227000
	asm volatile("cli; cld");
f0100067:	fa                   	cli    
f0100068:	fc                   	cld    
	va_start(ap, fmt);
f0100069:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006c:	e8 2b 61 00 00       	call   f010619c <cpunum>
f0100071:	ff 75 0c             	push   0xc(%ebp)
f0100074:	ff 75 08             	push   0x8(%ebp)
f0100077:	50                   	push   %eax
f0100078:	68 e0 67 10 f0       	push   $0xf01067e0
f010007d:	e8 f0 3b 00 00       	call   f0103c72 <cprintf>
	vcprintf(fmt, ap);
f0100082:	83 c4 08             	add    $0x8,%esp
f0100085:	53                   	push   %ebx
f0100086:	ff 75 10             	push   0x10(%ebp)
f0100089:	e8 be 3b 00 00       	call   f0103c4c <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 e8 73 10 f0 	movl   $0xf01073e8,(%esp)
f0100095:	e8 d8 3b 00 00       	call   f0103c72 <cprintf>
f010009a:	83 c4 10             	add    $0x10,%esp
f010009d:	eb b1                	jmp    f0100050 <_panic+0x10>

f010009f <i386_init>:
{
f010009f:	55                   	push   %ebp
f01000a0:	89 e5                	mov    %esp,%ebp
f01000a2:	53                   	push   %ebx
f01000a3:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a6:	e8 80 05 00 00       	call   f010062b <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ab:	83 ec 08             	sub    $0x8,%esp
f01000ae:	68 ac 1a 00 00       	push   $0x1aac
f01000b3:	68 4c 68 10 f0       	push   $0xf010684c
f01000b8:	e8 b5 3b 00 00       	call   f0103c72 <cprintf>
	mem_init();
f01000bd:	e8 41 15 00 00       	call   f0101603 <mem_init>
	env_init();
f01000c2:	e8 b5 33 00 00       	call   f010347c <env_init>
	trap_init();
f01000c7:	e8 98 3c 00 00       	call   f0103d64 <trap_init>
	mp_init();
f01000cc:	e8 e5 5d 00 00       	call   f0105eb6 <mp_init>
	lapic_init();
f01000d1:	e8 dc 60 00 00       	call   f01061b2 <lapic_init>
	pic_init();
f01000d6:	e8 ae 3a 00 00       	call   f0103b89 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000db:	c7 04 24 c0 63 12 f0 	movl   $0xf01263c0,(%esp)
f01000e2:	e8 25 63 00 00       	call   f010640c <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e7:	83 c4 10             	add    $0x10,%esp
f01000ea:	83 3d 60 72 22 f0 07 	cmpl   $0x7,0xf0227260
f01000f1:	76 27                	jbe    f010011a <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f3:	83 ec 04             	sub    $0x4,%esp
f01000f6:	b8 12 5e 10 f0       	mov    $0xf0105e12,%eax
f01000fb:	2d 98 5d 10 f0       	sub    $0xf0105d98,%eax
f0100100:	50                   	push   %eax
f0100101:	68 98 5d 10 f0       	push   $0xf0105d98
f0100106:	68 00 70 00 f0       	push   $0xf0007000
f010010b:	e8 db 5a 00 00       	call   f0105beb <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100110:	83 c4 10             	add    $0x10,%esp
f0100113:	bb 20 80 26 f0       	mov    $0xf0268020,%ebx
f0100118:	eb 19                	jmp    f0100133 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011a:	68 00 70 00 00       	push   $0x7000
f010011f:	68 04 68 10 f0       	push   $0xf0106804
f0100124:	6a 51                	push   $0x51
f0100126:	68 67 68 10 f0       	push   $0xf0106867
f010012b:	e8 10 ff ff ff       	call   f0100040 <_panic>
f0100130:	83 c3 74             	add    $0x74,%ebx
f0100133:	6b 05 00 80 26 f0 74 	imul   $0x74,0xf0268000,%eax
f010013a:	05 20 80 26 f0       	add    $0xf0268020,%eax
f010013f:	39 c3                	cmp    %eax,%ebx
f0100141:	73 4d                	jae    f0100190 <i386_init+0xf1>
		if (c == cpus + cpunum())  // We've started already.
f0100143:	e8 54 60 00 00       	call   f010619c <cpunum>
f0100148:	6b c0 74             	imul   $0x74,%eax,%eax
f010014b:	05 20 80 26 f0       	add    $0xf0268020,%eax
f0100150:	39 c3                	cmp    %eax,%ebx
f0100152:	74 dc                	je     f0100130 <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100154:	89 d8                	mov    %ebx,%eax
f0100156:	2d 20 80 26 f0       	sub    $0xf0268020,%eax
f010015b:	c1 f8 02             	sar    $0x2,%eax
f010015e:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100164:	c1 e0 0f             	shl    $0xf,%eax
f0100167:	8d 80 00 00 23 f0    	lea    -0xfdd0000(%eax),%eax
f010016d:	a3 04 70 22 f0       	mov    %eax,0xf0227004
		lapic_startap(c->cpu_id, PADDR(code));
f0100172:	83 ec 08             	sub    $0x8,%esp
f0100175:	68 00 70 00 00       	push   $0x7000
f010017a:	0f b6 03             	movzbl (%ebx),%eax
f010017d:	50                   	push   %eax
f010017e:	e8 81 61 00 00       	call   f0106304 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100183:	83 c4 10             	add    $0x10,%esp
f0100186:	8b 43 04             	mov    0x4(%ebx),%eax
f0100189:	83 f8 01             	cmp    $0x1,%eax
f010018c:	75 f8                	jne    f0100186 <i386_init+0xe7>
f010018e:	eb a0                	jmp    f0100130 <i386_init+0x91>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100190:	83 ec 08             	sub    $0x8,%esp
f0100193:	6a 00                	push   $0x0
f0100195:	68 48 d8 21 f0       	push   $0xf021d848
f010019a:	e8 bc 34 00 00       	call   f010365b <env_create>
	sched_yield();
f010019f:	e8 24 47 00 00       	call   f01048c8 <sched_yield>

f01001a4 <mp_main>:
{
f01001a4:	55                   	push   %ebp
f01001a5:	89 e5                	mov    %esp,%ebp
f01001a7:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001aa:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001af:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001b4:	76 52                	jbe    f0100208 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f01001b6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001bb:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001be:	e8 d9 5f 00 00       	call   f010619c <cpunum>
f01001c3:	83 ec 08             	sub    $0x8,%esp
f01001c6:	50                   	push   %eax
f01001c7:	68 73 68 10 f0       	push   $0xf0106873
f01001cc:	e8 a1 3a 00 00       	call   f0103c72 <cprintf>
	lapic_init();
f01001d1:	e8 dc 5f 00 00       	call   f01061b2 <lapic_init>
	env_init_percpu();
f01001d6:	e8 75 32 00 00       	call   f0103450 <env_init_percpu>
	trap_init_percpu();
f01001db:	e8 a6 3a 00 00       	call   f0103c86 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001e0:	e8 b7 5f 00 00       	call   f010619c <cpunum>
f01001e5:	6b d0 74             	imul   $0x74,%eax,%edx
f01001e8:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01001f0:	f0 87 82 20 80 26 f0 	lock xchg %eax,-0xfd97fe0(%edx)
f01001f7:	c7 04 24 c0 63 12 f0 	movl   $0xf01263c0,(%esp)
f01001fe:	e8 09 62 00 00       	call   f010640c <spin_lock>
	sched_yield();
f0100203:	e8 c0 46 00 00       	call   f01048c8 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100208:	50                   	push   %eax
f0100209:	68 28 68 10 f0       	push   $0xf0106828
f010020e:	6a 68                	push   $0x68
f0100210:	68 67 68 10 f0       	push   $0xf0106867
f0100215:	e8 26 fe ff ff       	call   f0100040 <_panic>

f010021a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010021a:	55                   	push   %ebp
f010021b:	89 e5                	mov    %esp,%ebp
f010021d:	53                   	push   %ebx
f010021e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100221:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100224:	ff 75 0c             	push   0xc(%ebp)
f0100227:	ff 75 08             	push   0x8(%ebp)
f010022a:	68 89 68 10 f0       	push   $0xf0106889
f010022f:	e8 3e 3a 00 00       	call   f0103c72 <cprintf>
	vcprintf(fmt, ap);
f0100234:	83 c4 08             	add    $0x8,%esp
f0100237:	53                   	push   %ebx
f0100238:	ff 75 10             	push   0x10(%ebp)
f010023b:	e8 0c 3a 00 00       	call   f0103c4c <vcprintf>
	cprintf("\n");
f0100240:	c7 04 24 e8 73 10 f0 	movl   $0xf01073e8,(%esp)
f0100247:	e8 26 3a 00 00       	call   f0103c72 <cprintf>
	va_end(ap);
}
f010024c:	83 c4 10             	add    $0x10,%esp
f010024f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100252:	c9                   	leave  
f0100253:	c3                   	ret    

f0100254 <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100254:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100259:	ec                   	in     (%dx),%al
static int bg_col = 0x0;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010025a:	a8 01                	test   $0x1,%al
f010025c:	74 0a                	je     f0100268 <serial_proc_data+0x14>
f010025e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100263:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100264:	0f b6 c0             	movzbl %al,%eax
f0100267:	c3                   	ret    
		return -1;
f0100268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010026d:	c3                   	ret    

f010026e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026e:	55                   	push   %ebp
f010026f:	89 e5                	mov    %esp,%ebp
f0100271:	53                   	push   %ebx
f0100272:	83 ec 04             	sub    $0x4,%esp
f0100275:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100277:	eb 23                	jmp    f010029c <cons_intr+0x2e>
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100279:	8b 0d 44 72 22 f0    	mov    0xf0227244,%ecx
f010027f:	8d 51 01             	lea    0x1(%ecx),%edx
f0100282:	88 81 40 70 22 f0    	mov    %al,-0xfdd8fc0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100288:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f010028e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100293:	0f 44 d0             	cmove  %eax,%edx
f0100296:	89 15 44 72 22 f0    	mov    %edx,0xf0227244
	while ((c = (*proc)()) != -1) {
f010029c:	ff d3                	call   *%ebx
f010029e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002a1:	74 06                	je     f01002a9 <cons_intr+0x3b>
		if (c == 0)
f01002a3:	85 c0                	test   %eax,%eax
f01002a5:	75 d2                	jne    f0100279 <cons_intr+0xb>
f01002a7:	eb f3                	jmp    f010029c <cons_intr+0x2e>
	}
}
f01002a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002ac:	c9                   	leave  
f01002ad:	c3                   	ret    

f01002ae <kbd_proc_data>:
{
f01002ae:	55                   	push   %ebp
f01002af:	89 e5                	mov    %esp,%ebp
f01002b1:	53                   	push   %ebx
f01002b2:	83 ec 04             	sub    $0x4,%esp
f01002b5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ba:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002bb:	a8 01                	test   $0x1,%al
f01002bd:	0f 84 ee 00 00 00    	je     f01003b1 <kbd_proc_data+0x103>
	if (stat & KBS_TERR)
f01002c3:	a8 20                	test   $0x20,%al
f01002c5:	0f 85 ed 00 00 00    	jne    f01003b8 <kbd_proc_data+0x10a>
f01002cb:	ba 60 00 00 00       	mov    $0x60,%edx
f01002d0:	ec                   	in     (%dx),%al
f01002d1:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002d3:	3c e0                	cmp    $0xe0,%al
f01002d5:	74 61                	je     f0100338 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f01002d7:	84 c0                	test   %al,%al
f01002d9:	78 70                	js     f010034b <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f01002db:	8b 0d 20 70 22 f0    	mov    0xf0227020,%ecx
f01002e1:	f6 c1 40             	test   $0x40,%cl
f01002e4:	74 0e                	je     f01002f4 <kbd_proc_data+0x46>
		data |= 0x80;
f01002e6:	83 c8 80             	or     $0xffffff80,%eax
f01002e9:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002eb:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002ee:	89 0d 20 70 22 f0    	mov    %ecx,0xf0227020
	shift |= shiftcode[data];
f01002f4:	0f b6 d2             	movzbl %dl,%edx
f01002f7:	0f b6 82 00 6a 10 f0 	movzbl -0xfef9600(%edx),%eax
f01002fe:	0b 05 20 70 22 f0    	or     0xf0227020,%eax
	shift ^= togglecode[data];
f0100304:	0f b6 8a 00 69 10 f0 	movzbl -0xfef9700(%edx),%ecx
f010030b:	31 c8                	xor    %ecx,%eax
f010030d:	a3 20 70 22 f0       	mov    %eax,0xf0227020
	c = charcode[shift & (CTL | SHIFT)][data];
f0100312:	89 c1                	mov    %eax,%ecx
f0100314:	83 e1 03             	and    $0x3,%ecx
f0100317:	8b 0c 8d e0 68 10 f0 	mov    -0xfef9720(,%ecx,4),%ecx
f010031e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100322:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100325:	a8 08                	test   $0x8,%al
f0100327:	74 5d                	je     f0100386 <kbd_proc_data+0xd8>
		if ('a' <= c && c <= 'z')
f0100329:	89 da                	mov    %ebx,%edx
f010032b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010032e:	83 f9 19             	cmp    $0x19,%ecx
f0100331:	77 47                	ja     f010037a <kbd_proc_data+0xcc>
			c += 'A' - 'a';
f0100333:	83 eb 20             	sub    $0x20,%ebx
f0100336:	eb 0c                	jmp    f0100344 <kbd_proc_data+0x96>
		shift |= E0ESC;
f0100338:	83 0d 20 70 22 f0 40 	orl    $0x40,0xf0227020
		return 0;
f010033f:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100344:	89 d8                	mov    %ebx,%eax
f0100346:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100349:	c9                   	leave  
f010034a:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010034b:	8b 0d 20 70 22 f0    	mov    0xf0227020,%ecx
f0100351:	83 e0 7f             	and    $0x7f,%eax
f0100354:	f6 c1 40             	test   $0x40,%cl
f0100357:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010035a:	0f b6 d2             	movzbl %dl,%edx
f010035d:	0f b6 82 00 6a 10 f0 	movzbl -0xfef9600(%edx),%eax
f0100364:	83 c8 40             	or     $0x40,%eax
f0100367:	0f b6 c0             	movzbl %al,%eax
f010036a:	f7 d0                	not    %eax
f010036c:	21 c8                	and    %ecx,%eax
f010036e:	a3 20 70 22 f0       	mov    %eax,0xf0227020
		return 0;
f0100373:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100378:	eb ca                	jmp    f0100344 <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f010037a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010037d:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100380:	83 fa 1a             	cmp    $0x1a,%edx
f0100383:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100386:	f7 d0                	not    %eax
f0100388:	a8 06                	test   $0x6,%al
f010038a:	75 b8                	jne    f0100344 <kbd_proc_data+0x96>
f010038c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100392:	75 b0                	jne    f0100344 <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f0100394:	83 ec 0c             	sub    $0xc,%esp
f0100397:	68 a3 68 10 f0       	push   $0xf01068a3
f010039c:	e8 d1 38 00 00       	call   f0103c72 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a1:	b8 03 00 00 00       	mov    $0x3,%eax
f01003a6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003ab:	ee                   	out    %al,(%dx)
}
f01003ac:	83 c4 10             	add    $0x10,%esp
f01003af:	eb 93                	jmp    f0100344 <kbd_proc_data+0x96>
		return -1;
f01003b1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003b6:	eb 8c                	jmp    f0100344 <kbd_proc_data+0x96>
		return -1;
f01003b8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003bd:	eb 85                	jmp    f0100344 <kbd_proc_data+0x96>

f01003bf <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003bf:	55                   	push   %ebp
f01003c0:	89 e5                	mov    %esp,%ebp
f01003c2:	57                   	push   %edi
f01003c3:	56                   	push   %esi
f01003c4:	53                   	push   %ebx
f01003c5:	83 ec 1c             	sub    $0x1c,%esp
f01003c8:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003ca:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cf:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003d4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d9:	89 f2                	mov    %esi,%edx
f01003db:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003dc:	a8 20                	test   $0x20,%al
f01003de:	75 13                	jne    f01003f3 <cons_putc+0x34>
f01003e0:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01003e6:	7f 0b                	jg     f01003f3 <cons_putc+0x34>
f01003e8:	89 ca                	mov    %ecx,%edx
f01003ea:	ec                   	in     (%dx),%al
f01003eb:	ec                   	in     (%dx),%al
f01003ec:	ec                   	in     (%dx),%al
f01003ed:	ec                   	in     (%dx),%al
	     i++)
f01003ee:	83 c3 01             	add    $0x1,%ebx
f01003f1:	eb e6                	jmp    f01003d9 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f01003f3:	89 f8                	mov    %edi,%eax
f01003f5:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003fd:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003fe:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100403:	be 79 03 00 00       	mov    $0x379,%esi
f0100408:	b9 84 00 00 00       	mov    $0x84,%ecx
f010040d:	89 f2                	mov    %esi,%edx
f010040f:	ec                   	in     (%dx),%al
f0100410:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100416:	7f 0f                	jg     f0100427 <cons_putc+0x68>
f0100418:	84 c0                	test   %al,%al
f010041a:	78 0b                	js     f0100427 <cons_putc+0x68>
f010041c:	89 ca                	mov    %ecx,%edx
f010041e:	ec                   	in     (%dx),%al
f010041f:	ec                   	in     (%dx),%al
f0100420:	ec                   	in     (%dx),%al
f0100421:	ec                   	in     (%dx),%al
f0100422:	83 c3 01             	add    $0x1,%ebx
f0100425:	eb e6                	jmp    f010040d <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100427:	ba 78 03 00 00       	mov    $0x378,%edx
f010042c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100430:	ee                   	out    %al,(%dx)
f0100431:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100436:	b8 0d 00 00 00       	mov    $0xd,%eax
f010043b:	ee                   	out    %al,(%dx)
f010043c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100441:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100442:	89 f8                	mov    %edi,%eax
f0100444:	80 cc 07             	or     $0x7,%ah
f0100447:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010044d:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100450:	89 f8                	mov    %edi,%eax
f0100452:	0f b6 c0             	movzbl %al,%eax
f0100455:	89 fb                	mov    %edi,%ebx
f0100457:	80 fb 0a             	cmp    $0xa,%bl
f010045a:	0f 84 e1 00 00 00    	je     f0100541 <cons_putc+0x182>
f0100460:	83 f8 0a             	cmp    $0xa,%eax
f0100463:	7f 46                	jg     f01004ab <cons_putc+0xec>
f0100465:	83 f8 08             	cmp    $0x8,%eax
f0100468:	0f 84 a7 00 00 00    	je     f0100515 <cons_putc+0x156>
f010046e:	83 f8 09             	cmp    $0x9,%eax
f0100471:	0f 85 d7 00 00 00    	jne    f010054e <cons_putc+0x18f>
		cons_putc(' ');
f0100477:	b8 20 00 00 00       	mov    $0x20,%eax
f010047c:	e8 3e ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f0100481:	b8 20 00 00 00       	mov    $0x20,%eax
f0100486:	e8 34 ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f010048b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100490:	e8 2a ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f0100495:	b8 20 00 00 00       	mov    $0x20,%eax
f010049a:	e8 20 ff ff ff       	call   f01003bf <cons_putc>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 16 ff ff ff       	call   f01003bf <cons_putc>
		break;
f01004a9:	eb 25                	jmp    f01004d0 <cons_putc+0x111>
	switch (c & 0xff) {
f01004ab:	83 f8 0d             	cmp    $0xd,%eax
f01004ae:	0f 85 9a 00 00 00    	jne    f010054e <cons_putc+0x18f>
		crt_pos -= (crt_pos % CRT_COLS);
f01004b4:	0f b7 05 48 72 22 f0 	movzwl 0xf0227248,%eax
f01004bb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c1:	c1 e8 16             	shr    $0x16,%eax
f01004c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004c7:	c1 e0 04             	shl    $0x4,%eax
f01004ca:	66 a3 48 72 22 f0    	mov    %ax,0xf0227248
	if (crt_pos >= CRT_SIZE) {
f01004d0:	66 81 3d 48 72 22 f0 	cmpw   $0x7cf,0xf0227248
f01004d7:	cf 07 
f01004d9:	0f 87 92 00 00 00    	ja     f0100571 <cons_putc+0x1b2>
	outb(addr_6845, 14);
f01004df:	8b 0d 50 72 22 f0    	mov    0xf0227250,%ecx
f01004e5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ea:	89 ca                	mov    %ecx,%edx
f01004ec:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ed:	0f b7 1d 48 72 22 f0 	movzwl 0xf0227248,%ebx
f01004f4:	8d 71 01             	lea    0x1(%ecx),%esi
f01004f7:	89 d8                	mov    %ebx,%eax
f01004f9:	66 c1 e8 08          	shr    $0x8,%ax
f01004fd:	89 f2                	mov    %esi,%edx
f01004ff:	ee                   	out    %al,(%dx)
f0100500:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100505:	89 ca                	mov    %ecx,%edx
f0100507:	ee                   	out    %al,(%dx)
f0100508:	89 d8                	mov    %ebx,%eax
f010050a:	89 f2                	mov    %esi,%edx
f010050c:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010050d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100510:	5b                   	pop    %ebx
f0100511:	5e                   	pop    %esi
f0100512:	5f                   	pop    %edi
f0100513:	5d                   	pop    %ebp
f0100514:	c3                   	ret    
		if (crt_pos > 0) {
f0100515:	0f b7 05 48 72 22 f0 	movzwl 0xf0227248,%eax
f010051c:	66 85 c0             	test   %ax,%ax
f010051f:	74 be                	je     f01004df <cons_putc+0x120>
			crt_pos--;
f0100521:	83 e8 01             	sub    $0x1,%eax
f0100524:	66 a3 48 72 22 f0    	mov    %ax,0xf0227248
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010052a:	0f b7 c0             	movzwl %ax,%eax
f010052d:	66 81 e7 00 ff       	and    $0xff00,%di
f0100532:	83 cf 20             	or     $0x20,%edi
f0100535:	8b 15 4c 72 22 f0    	mov    0xf022724c,%edx
f010053b:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010053f:	eb 8f                	jmp    f01004d0 <cons_putc+0x111>
		crt_pos += CRT_COLS;
f0100541:	66 83 05 48 72 22 f0 	addw   $0x50,0xf0227248
f0100548:	50 
f0100549:	e9 66 ff ff ff       	jmp    f01004b4 <cons_putc+0xf5>
		crt_buf[crt_pos++] = c;		/* write the character */
f010054e:	0f b7 05 48 72 22 f0 	movzwl 0xf0227248,%eax
f0100555:	8d 50 01             	lea    0x1(%eax),%edx
f0100558:	66 89 15 48 72 22 f0 	mov    %dx,0xf0227248
f010055f:	0f b7 c0             	movzwl %ax,%eax
f0100562:	8b 15 4c 72 22 f0    	mov    0xf022724c,%edx
f0100568:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f010056c:	e9 5f ff ff ff       	jmp    f01004d0 <cons_putc+0x111>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100571:	a1 4c 72 22 f0       	mov    0xf022724c,%eax
f0100576:	83 ec 04             	sub    $0x4,%esp
f0100579:	68 00 0f 00 00       	push   $0xf00
f010057e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100584:	52                   	push   %edx
f0100585:	50                   	push   %eax
f0100586:	e8 60 56 00 00       	call   f0105beb <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010058b:	8b 15 4c 72 22 f0    	mov    0xf022724c,%edx
f0100591:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100597:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010059d:	83 c4 10             	add    $0x10,%esp
f01005a0:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005a5:	83 c0 02             	add    $0x2,%eax
f01005a8:	39 d0                	cmp    %edx,%eax
f01005aa:	75 f4                	jne    f01005a0 <cons_putc+0x1e1>
		crt_pos -= CRT_COLS;
f01005ac:	66 83 2d 48 72 22 f0 	subw   $0x50,0xf0227248
f01005b3:	50 
f01005b4:	e9 26 ff ff ff       	jmp    f01004df <cons_putc+0x120>

f01005b9 <serial_intr>:
	if (serial_exists)
f01005b9:	80 3d 54 72 22 f0 00 	cmpb   $0x0,0xf0227254
f01005c0:	75 01                	jne    f01005c3 <serial_intr+0xa>
f01005c2:	c3                   	ret    
{
f01005c3:	55                   	push   %ebp
f01005c4:	89 e5                	mov    %esp,%ebp
f01005c6:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005c9:	b8 54 02 10 f0       	mov    $0xf0100254,%eax
f01005ce:	e8 9b fc ff ff       	call   f010026e <cons_intr>
}
f01005d3:	c9                   	leave  
f01005d4:	c3                   	ret    

f01005d5 <set_fg_col>:
}
f01005d5:	c3                   	ret    

f01005d6 <set_bg_col>:
}
f01005d6:	c3                   	ret    

f01005d7 <kbd_intr>:
{
f01005d7:	55                   	push   %ebp
f01005d8:	89 e5                	mov    %esp,%ebp
f01005da:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005dd:	b8 ae 02 10 f0       	mov    $0xf01002ae,%eax
f01005e2:	e8 87 fc ff ff       	call   f010026e <cons_intr>
}
f01005e7:	c9                   	leave  
f01005e8:	c3                   	ret    

f01005e9 <cons_getc>:
{
f01005e9:	55                   	push   %ebp
f01005ea:	89 e5                	mov    %esp,%ebp
f01005ec:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01005ef:	e8 c5 ff ff ff       	call   f01005b9 <serial_intr>
	kbd_intr();
f01005f4:	e8 de ff ff ff       	call   f01005d7 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005f9:	a1 40 72 22 f0       	mov    0xf0227240,%eax
	return 0;
f01005fe:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100603:	3b 05 44 72 22 f0    	cmp    0xf0227244,%eax
f0100609:	74 1c                	je     f0100627 <cons_getc+0x3e>
		c = cons.buf[cons.rpos++];
f010060b:	8d 48 01             	lea    0x1(%eax),%ecx
f010060e:	0f b6 90 40 70 22 f0 	movzbl -0xfdd8fc0(%eax),%edx
			cons.rpos = 0;
f0100615:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f010061a:	b8 00 00 00 00       	mov    $0x0,%eax
f010061f:	0f 45 c1             	cmovne %ecx,%eax
f0100622:	a3 40 72 22 f0       	mov    %eax,0xf0227240
}
f0100627:	89 d0                	mov    %edx,%eax
f0100629:	c9                   	leave  
f010062a:	c3                   	ret    

f010062b <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	57                   	push   %edi
f010062f:	56                   	push   %esi
f0100630:	53                   	push   %ebx
f0100631:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100634:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010063b:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100642:	5a a5 
	if (*cp != 0xA55A) {
f0100644:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010064b:	bb b4 03 00 00       	mov    $0x3b4,%ebx
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	if (*cp != 0xA55A) {
f0100655:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100659:	0f 84 c3 00 00 00    	je     f0100722 <cons_init+0xf7>
		addr_6845 = MONO_BASE;
f010065f:	89 1d 50 72 22 f0    	mov    %ebx,0xf0227250
f0100665:	b8 0e 00 00 00       	mov    $0xe,%eax
f010066a:	89 da                	mov    %ebx,%edx
f010066c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010066d:	8d 7b 01             	lea    0x1(%ebx),%edi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100670:	89 fa                	mov    %edi,%edx
f0100672:	ec                   	in     (%dx),%al
f0100673:	0f b6 c8             	movzbl %al,%ecx
f0100676:	c1 e1 08             	shl    $0x8,%ecx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100679:	b8 0f 00 00 00       	mov    $0xf,%eax
f010067e:	89 da                	mov    %ebx,%edx
f0100680:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100681:	89 fa                	mov    %edi,%edx
f0100683:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100684:	89 35 4c 72 22 f0    	mov    %esi,0xf022724c
	pos |= inb(addr_6845 + 1);
f010068a:	0f b6 c0             	movzbl %al,%eax
f010068d:	09 c8                	or     %ecx,%eax
	crt_pos = pos;
f010068f:	66 a3 48 72 22 f0    	mov    %ax,0xf0227248
	kbd_intr();
f0100695:	e8 3d ff ff ff       	call   f01005d7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f010069a:	83 ec 0c             	sub    $0xc,%esp
f010069d:	0f b7 05 a8 63 12 f0 	movzwl 0xf01263a8,%eax
f01006a4:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006a9:	50                   	push   %eax
f01006aa:	e8 57 34 00 00       	call   f0103b06 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006af:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b4:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006b9:	89 c8                	mov    %ecx,%eax
f01006bb:	89 da                	mov    %ebx,%edx
f01006bd:	ee                   	out    %al,(%dx)
f01006be:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006c3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c8:	89 fa                	mov    %edi,%edx
f01006ca:	ee                   	out    %al,(%dx)
f01006cb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006d5:	ee                   	out    %al,(%dx)
f01006d6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006db:	89 c8                	mov    %ecx,%eax
f01006dd:	89 f2                	mov    %esi,%edx
f01006df:	ee                   	out    %al,(%dx)
f01006e0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006e5:	89 fa                	mov    %edi,%edx
f01006e7:	ee                   	out    %al,(%dx)
f01006e8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006ed:	89 c8                	mov    %ecx,%eax
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006f5:	89 f2                	mov    %esi,%edx
f01006f7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006fd:	ec                   	in     (%dx),%al
f01006fe:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100700:	83 c4 10             	add    $0x10,%esp
f0100703:	3c ff                	cmp    $0xff,%al
f0100705:	0f 95 05 54 72 22 f0 	setne  0xf0227254
f010070c:	89 da                	mov    %ebx,%edx
f010070e:	ec                   	in     (%dx),%al
f010070f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100714:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100715:	80 f9 ff             	cmp    $0xff,%cl
f0100718:	74 1e                	je     f0100738 <cons_init+0x10d>
		cprintf("Serial port does not exist!\n");
}
f010071a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010071d:	5b                   	pop    %ebx
f010071e:	5e                   	pop    %esi
f010071f:	5f                   	pop    %edi
f0100720:	5d                   	pop    %ebp
f0100721:	c3                   	ret    
		*cp = was;
f0100722:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
f0100729:	bb d4 03 00 00       	mov    $0x3d4,%ebx
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100733:	e9 27 ff ff ff       	jmp    f010065f <cons_init+0x34>
		cprintf("Serial port does not exist!\n");
f0100738:	83 ec 0c             	sub    $0xc,%esp
f010073b:	68 af 68 10 f0       	push   $0xf01068af
f0100740:	e8 2d 35 00 00       	call   f0103c72 <cprintf>
f0100745:	83 c4 10             	add    $0x10,%esp
}
f0100748:	eb d0                	jmp    f010071a <cons_init+0xef>

f010074a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074a:	55                   	push   %ebp
f010074b:	89 e5                	mov    %esp,%ebp
f010074d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100750:	8b 45 08             	mov    0x8(%ebp),%eax
f0100753:	e8 67 fc ff ff       	call   f01003bf <cons_putc>
}
f0100758:	c9                   	leave  
f0100759:	c3                   	ret    

f010075a <getchar>:

int
getchar(void)
{
f010075a:	55                   	push   %ebp
f010075b:	89 e5                	mov    %esp,%ebp
f010075d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100760:	e8 84 fe ff ff       	call   f01005e9 <cons_getc>
f0100765:	85 c0                	test   %eax,%eax
f0100767:	74 f7                	je     f0100760 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100769:	c9                   	leave  
f010076a:	c3                   	ret    

f010076b <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010076b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100770:	c3                   	ret    

f0100771 <mon_continue>:
	}
	return 0;
}

int 
mon_continue(int argc, char **argv, struct Trapframe *tf) {
f0100771:	55                   	push   %ebp
f0100772:	89 e5                	mov    %esp,%ebp
f0100774:	8b 45 10             	mov    0x10(%ebp),%eax
    if (!(tf && (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT) && 
f0100777:	85 c0                	test   %eax,%eax
f0100779:	74 34                	je     f01007af <mon_continue+0x3e>
f010077b:	8b 50 28             	mov    0x28(%eax),%edx
f010077e:	83 e2 fd             	and    $0xfffffffd,%edx
          ((tf->tf_cs & 3) == 3)))
        return 0;
f0100781:	b9 00 00 00 00       	mov    $0x0,%ecx
    if (!(tf && (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT) && 
f0100786:	83 fa 01             	cmp    $0x1,%edx
f0100789:	75 12                	jne    f010079d <mon_continue+0x2c>
f010078b:	0f b7 50 34          	movzwl 0x34(%eax),%edx
f010078f:	83 e2 03             	and    $0x3,%edx
f0100792:	66 83 fa 03          	cmp    $0x3,%dx
f0100796:	74 09                	je     f01007a1 <mon_continue+0x30>
        return 0;
f0100798:	b9 00 00 00 00       	mov    $0x0,%ecx
    tf->tf_eflags &= ~FL_TF;
    return -1;
}
f010079d:	89 c8                	mov    %ecx,%eax
f010079f:	5d                   	pop    %ebp
f01007a0:	c3                   	ret    
    tf->tf_eflags &= ~FL_TF;
f01007a1:	81 60 38 ff fe ff ff 	andl   $0xfffffeff,0x38(%eax)
    return -1;
f01007a8:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f01007ad:	eb ee                	jmp    f010079d <mon_continue+0x2c>
        return 0;
f01007af:	b9 00 00 00 00       	mov    $0x0,%ecx
f01007b4:	eb e7                	jmp    f010079d <mon_continue+0x2c>

f01007b6 <mon_stepi>:

int 
mon_stepi(int argc, char **argv, struct Trapframe *tf) {
f01007b6:	55                   	push   %ebp
f01007b7:	89 e5                	mov    %esp,%ebp
f01007b9:	8b 45 10             	mov    0x10(%ebp),%eax
    if (!(tf && (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT) && 
f01007bc:	85 c0                	test   %eax,%eax
f01007be:	74 34                	je     f01007f4 <mon_stepi+0x3e>
f01007c0:	8b 50 28             	mov    0x28(%eax),%edx
f01007c3:	83 e2 fd             	and    $0xfffffffd,%edx
          ((tf->tf_cs & 3) == 3)))
        return 0;
f01007c6:	b9 00 00 00 00       	mov    $0x0,%ecx
    if (!(tf && (tf->tf_trapno == T_DEBUG || tf->tf_trapno == T_BRKPT) && 
f01007cb:	83 fa 01             	cmp    $0x1,%edx
f01007ce:	75 12                	jne    f01007e2 <mon_stepi+0x2c>
f01007d0:	0f b7 50 34          	movzwl 0x34(%eax),%edx
f01007d4:	83 e2 03             	and    $0x3,%edx
f01007d7:	66 83 fa 03          	cmp    $0x3,%dx
f01007db:	74 09                	je     f01007e6 <mon_stepi+0x30>
        return 0;
f01007dd:	b9 00 00 00 00       	mov    $0x0,%ecx
    tf->tf_eflags |= FL_TF;
    return -1;
}
f01007e2:	89 c8                	mov    %ecx,%eax
f01007e4:	5d                   	pop    %ebp
f01007e5:	c3                   	ret    
    tf->tf_eflags |= FL_TF;
f01007e6:	81 48 38 00 01 00 00 	orl    $0x100,0x38(%eax)
    return -1;
f01007ed:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f01007f2:	eb ee                	jmp    f01007e2 <mon_stepi+0x2c>
        return 0;
f01007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01007f9:	eb e7                	jmp    f01007e2 <mon_stepi+0x2c>

f01007fb <mon_help>:
{
f01007fb:	55                   	push   %ebp
f01007fc:	89 e5                	mov    %esp,%ebp
f01007fe:	56                   	push   %esi
f01007ff:	53                   	push   %ebx
f0100800:	bb 80 70 10 f0       	mov    $0xf0107080,%ebx
f0100805:	be e0 70 10 f0       	mov    $0xf01070e0,%esi
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010080a:	83 ec 04             	sub    $0x4,%esp
f010080d:	ff 73 04             	push   0x4(%ebx)
f0100810:	ff 33                	push   (%ebx)
f0100812:	68 00 6b 10 f0       	push   $0xf0106b00
f0100817:	e8 56 34 00 00       	call   f0103c72 <cprintf>
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f010081c:	83 c3 0c             	add    $0xc,%ebx
f010081f:	83 c4 10             	add    $0x10,%esp
f0100822:	39 f3                	cmp    %esi,%ebx
f0100824:	75 e4                	jne    f010080a <mon_help+0xf>
}
f0100826:	b8 00 00 00 00       	mov    $0x0,%eax
f010082b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010082e:	5b                   	pop    %ebx
f010082f:	5e                   	pop    %esi
f0100830:	5d                   	pop    %ebp
f0100831:	c3                   	ret    

f0100832 <mon_kerninfo>:
{
f0100832:	55                   	push   %ebp
f0100833:	89 e5                	mov    %esp,%ebp
f0100835:	83 ec 14             	sub    $0x14,%esp
	cprintf("Special kernel symbols:\n");
f0100838:	68 09 6b 10 f0       	push   $0xf0106b09
f010083d:	e8 30 34 00 00       	call   f0103c72 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100842:	83 c4 08             	add    $0x8,%esp
f0100845:	68 0c 00 10 00       	push   $0x10000c
f010084a:	68 5c 6c 10 f0       	push   $0xf0106c5c
f010084f:	e8 1e 34 00 00       	call   f0103c72 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100854:	83 c4 0c             	add    $0xc,%esp
f0100857:	68 0c 00 10 00       	push   $0x10000c
f010085c:	68 0c 00 10 f0       	push   $0xf010000c
f0100861:	68 84 6c 10 f0       	push   $0xf0106c84
f0100866:	e8 07 34 00 00       	call   f0103c72 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010086b:	83 c4 0c             	add    $0xc,%esp
f010086e:	68 c1 67 10 00       	push   $0x1067c1
f0100873:	68 c1 67 10 f0       	push   $0xf01067c1
f0100878:	68 a8 6c 10 f0       	push   $0xf0106ca8
f010087d:	e8 f0 33 00 00       	call   f0103c72 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100882:	83 c4 0c             	add    $0xc,%esp
f0100885:	68 00 70 22 00       	push   $0x227000
f010088a:	68 00 70 22 f0       	push   $0xf0227000
f010088f:	68 cc 6c 10 f0       	push   $0xf0106ccc
f0100894:	e8 d9 33 00 00       	call   f0103c72 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100899:	83 c4 0c             	add    $0xc,%esp
f010089c:	68 c8 83 26 00       	push   $0x2683c8
f01008a1:	68 c8 83 26 f0       	push   $0xf02683c8
f01008a6:	68 f0 6c 10 f0       	push   $0xf0106cf0
f01008ab:	e8 c2 33 00 00       	call   f0103c72 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b0:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008b3:	b8 c8 83 26 f0       	mov    $0xf02683c8,%eax
f01008b8:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008bd:	c1 f8 0a             	sar    $0xa,%eax
f01008c0:	50                   	push   %eax
f01008c1:	68 14 6d 10 f0       	push   $0xf0106d14
f01008c6:	e8 a7 33 00 00       	call   f0103c72 <cprintf>
}
f01008cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d0:	c9                   	leave  
f01008d1:	c3                   	ret    

f01008d2 <mon_backtrace>:
{
f01008d2:	55                   	push   %ebp
f01008d3:	89 e5                	mov    %esp,%ebp
f01008d5:	57                   	push   %edi
f01008d6:	56                   	push   %esi
f01008d7:	53                   	push   %ebx
f01008d8:	83 ec 38             	sub    $0x38,%esp
	cprintf("Stack backtrace:\n");
f01008db:	68 22 6b 10 f0       	push   $0xf0106b22
f01008e0:	e8 8d 33 00 00       	call   f0103c72 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008e5:	89 ee                	mov    %ebp,%esi
	while (ebp) {
f01008e7:	83 c4 10             	add    $0x10,%esp
f01008ea:	eb 32                	jmp    f010091e <mon_backtrace+0x4c>
				cprintf("\n");
f01008ec:	83 ec 0c             	sub    $0xc,%esp
f01008ef:	68 e8 73 10 f0       	push   $0xf01073e8
f01008f4:	e8 79 33 00 00       	call   f0103c72 <cprintf>
f01008f9:	83 c4 10             	add    $0x10,%esp
		cprintf("		 %s:%d: %.*s+%d\n", info.eip_file, info.eip_line,
f01008fc:	83 ec 08             	sub    $0x8,%esp
f01008ff:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100902:	57                   	push   %edi
f0100903:	ff 75 d8             	push   -0x28(%ebp)
f0100906:	ff 75 dc             	push   -0x24(%ebp)
f0100909:	ff 75 d4             	push   -0x2c(%ebp)
f010090c:	ff 75 d0             	push   -0x30(%ebp)
f010090f:	68 55 6b 10 f0       	push   $0xf0106b55
f0100914:	e8 59 33 00 00       	call   f0103c72 <cprintf>
		ebp = (uint32_t *)*ebp;
f0100919:	8b 36                	mov    (%esi),%esi
f010091b:	83 c4 20             	add    $0x20,%esp
	while (ebp) {
f010091e:	85 f6                	test   %esi,%esi
f0100920:	74 4a                	je     f010096c <mon_backtrace+0x9a>
		eip = *(ebp + 1);
f0100922:	8b 7e 04             	mov    0x4(%esi),%edi
		debuginfo_eip(eip, &info);
f0100925:	83 ec 08             	sub    $0x8,%esp
f0100928:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010092b:	50                   	push   %eax
f010092c:	57                   	push   %edi
f010092d:	e8 b5 47 00 00       	call   f01050e7 <debuginfo_eip>
		cprintf("  ebp %08x  eip %08x  args", ebp, eip);
f0100932:	83 c4 0c             	add    $0xc,%esp
f0100935:	57                   	push   %edi
f0100936:	56                   	push   %esi
f0100937:	68 34 6b 10 f0       	push   $0xf0106b34
f010093c:	e8 31 33 00 00       	call   f0103c72 <cprintf>
f0100941:	83 c4 10             	add    $0x10,%esp
		for (int i = 0; i < 5; i++) {
f0100944:	bb 00 00 00 00       	mov    $0x0,%ebx
			cprintf(" %08x", *(ebp + 2 + i));
f0100949:	83 ec 08             	sub    $0x8,%esp
f010094c:	ff 74 9e 08          	push   0x8(%esi,%ebx,4)
f0100950:	68 4f 6b 10 f0       	push   $0xf0106b4f
f0100955:	e8 18 33 00 00       	call   f0103c72 <cprintf>
			if (i == 4) {
f010095a:	83 c4 10             	add    $0x10,%esp
f010095d:	83 fb 04             	cmp    $0x4,%ebx
f0100960:	74 8a                	je     f01008ec <mon_backtrace+0x1a>
		for (int i = 0; i < 5; i++) {
f0100962:	83 c3 01             	add    $0x1,%ebx
f0100965:	83 fb 05             	cmp    $0x5,%ebx
f0100968:	75 df                	jne    f0100949 <mon_backtrace+0x77>
f010096a:	eb 90                	jmp    f01008fc <mon_backtrace+0x2a>
}
f010096c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100971:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100974:	5b                   	pop    %ebx
f0100975:	5e                   	pop    %esi
f0100976:	5f                   	pop    %edi
f0100977:	5d                   	pop    %ebp
f0100978:	c3                   	ret    

f0100979 <mon_setperm>:
mon_setperm(int argc, char **argv, struct Trapframe *tf) {
f0100979:	55                   	push   %ebp
f010097a:	89 e5                	mov    %esp,%ebp
f010097c:	56                   	push   %esi
f010097d:	53                   	push   %ebx
f010097e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc != 4) {
f0100981:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100985:	75 36                	jne    f01009bd <mon_setperm+0x44>
	if ((argv[2][0] != 'U' && argv[2][0] != 'W') || (argv[3][0] != '0' && argv[3][0] != '1')) {
f0100987:	8b 43 08             	mov    0x8(%ebx),%eax
f010098a:	0f b6 00             	movzbl (%eax),%eax
f010098d:	83 e0 fd             	and    $0xfffffffd,%eax
f0100990:	3c 55                	cmp    $0x55,%al
f0100992:	75 0d                	jne    f01009a1 <mon_setperm+0x28>
f0100994:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100997:	0f b6 00             	movzbl (%eax),%eax
f010099a:	83 e8 30             	sub    $0x30,%eax
f010099d:	3c 01                	cmp    $0x1,%al
f010099f:	76 2e                	jbe    f01009cf <mon_setperm+0x56>
		cprintf("Usage: setperm [VADDR] [U|W] [0|1]\n");
f01009a1:	83 ec 0c             	sub    $0xc,%esp
f01009a4:	68 40 6d 10 f0       	push   $0xf0106d40
f01009a9:	e8 c4 32 00 00       	call   f0103c72 <cprintf>
		return 0;
f01009ae:	83 c4 10             	add    $0x10,%esp
}
f01009b1:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009b9:	5b                   	pop    %ebx
f01009ba:	5e                   	pop    %esi
f01009bb:	5d                   	pop    %ebp
f01009bc:	c3                   	ret    
		cprintf("Usage: setperm [VADDR] [U|W] [0|1]\n");
f01009bd:	83 ec 0c             	sub    $0xc,%esp
f01009c0:	68 40 6d 10 f0       	push   $0xf0106d40
f01009c5:	e8 a8 32 00 00       	call   f0103c72 <cprintf>
		return 0;
f01009ca:	83 c4 10             	add    $0x10,%esp
f01009cd:	eb e2                	jmp    f01009b1 <mon_setperm+0x38>
	uintptr_t va = (uintptr_t)strtol(argv[1], NULL, 0);
f01009cf:	83 ec 04             	sub    $0x4,%esp
f01009d2:	6a 00                	push   $0x0
f01009d4:	6a 00                	push   $0x0
f01009d6:	ff 73 04             	push   0x4(%ebx)
f01009d9:	e8 db 52 00 00       	call   f0105cb9 <strtol>
f01009de:	89 c6                	mov    %eax,%esi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)va, 0);
f01009e0:	83 c4 0c             	add    $0xc,%esp
f01009e3:	6a 00                	push   $0x0
f01009e5:	50                   	push   %eax
f01009e6:	ff 35 5c 72 22 f0    	push   0xf022725c
f01009ec:	e8 86 09 00 00       	call   f0101377 <pgdir_walk>
	if (!pte) {
f01009f1:	83 c4 10             	add    $0x10,%esp
f01009f4:	85 c0                	test   %eax,%eax
f01009f6:	74 1e                	je     f0100a16 <mon_setperm+0x9d>
	if (argv[2][0] == 'U') {
f01009f8:	8b 53 08             	mov    0x8(%ebx),%edx
		perm_mod = PTE_W;
f01009fb:	80 3a 55             	cmpb   $0x55,(%edx)
f01009fe:	0f 94 c2             	sete   %dl
f0100a01:	0f b6 d2             	movzbl %dl,%edx
f0100a04:	8d 54 12 02          	lea    0x2(%edx,%edx,1),%edx
	if (argv[3][0] == '1') {
f0100a08:	8b 4b 0c             	mov    0xc(%ebx),%ecx
f0100a0b:	80 39 31             	cmpb   $0x31,(%ecx)
f0100a0e:	74 19                	je     f0100a29 <mon_setperm+0xb0>
		*pte &= ~perm_mod;
f0100a10:	f7 d2                	not    %edx
f0100a12:	21 10                	and    %edx,(%eax)
f0100a14:	eb 9b                	jmp    f01009b1 <mon_setperm+0x38>
		cprintf("setperm error: VA:0x%08x is not mapped\n", va);
f0100a16:	83 ec 08             	sub    $0x8,%esp
f0100a19:	56                   	push   %esi
f0100a1a:	68 64 6d 10 f0       	push   $0xf0106d64
f0100a1f:	e8 4e 32 00 00       	call   f0103c72 <cprintf>
		return 0;
f0100a24:	83 c4 10             	add    $0x10,%esp
f0100a27:	eb 88                	jmp    f01009b1 <mon_setperm+0x38>
		*pte |= perm_mod;
f0100a29:	09 10                	or     %edx,(%eax)
f0100a2b:	eb 84                	jmp    f01009b1 <mon_setperm+0x38>

f0100a2d <mon_showmappings>:
{
f0100a2d:	55                   	push   %ebp
f0100a2e:	89 e5                	mov    %esp,%ebp
f0100a30:	57                   	push   %edi
f0100a31:	56                   	push   %esi
f0100a32:	53                   	push   %ebx
f0100a33:	83 ec 0c             	sub    $0xc,%esp
f0100a36:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc != 3) {
f0100a39:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a3d:	74 1d                	je     f0100a5c <mon_showmappings+0x2f>
		cprintf("Usage: showmappings [start] [end]\n");
f0100a3f:	83 ec 0c             	sub    $0xc,%esp
f0100a42:	68 8c 6d 10 f0       	push   $0xf0106d8c
f0100a47:	e8 26 32 00 00       	call   f0103c72 <cprintf>
		return 0;
f0100a4c:	83 c4 10             	add    $0x10,%esp
}
f0100a4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a54:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a57:	5b                   	pop    %ebx
f0100a58:	5e                   	pop    %esi
f0100a59:	5f                   	pop    %edi
f0100a5a:	5d                   	pop    %ebp
f0100a5b:	c3                   	ret    
	uintptr_t start_va = (uintptr_t)strtol(argv[1], NULL, 0);
f0100a5c:	83 ec 04             	sub    $0x4,%esp
f0100a5f:	6a 00                	push   $0x0
f0100a61:	6a 00                	push   $0x0
f0100a63:	ff 76 04             	push   0x4(%esi)
f0100a66:	e8 4e 52 00 00       	call   f0105cb9 <strtol>
f0100a6b:	89 c3                	mov    %eax,%ebx
	uintptr_t end_va = (uintptr_t)strtol(argv[2], NULL, 0);
f0100a6d:	83 c4 0c             	add    $0xc,%esp
f0100a70:	6a 00                	push   $0x0
f0100a72:	6a 00                	push   $0x0
f0100a74:	ff 76 08             	push   0x8(%esi)
f0100a77:	e8 3d 52 00 00       	call   f0105cb9 <strtol>
f0100a7c:	89 c7                	mov    %eax,%edi
	if ((start_va % PGSIZE) || (end_va % PGSIZE)) {
f0100a7e:	89 d8                	mov    %ebx,%eax
f0100a80:	09 f8                	or     %edi,%eax
f0100a82:	83 c4 10             	add    $0x10,%esp
f0100a85:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0100a8a:	75 16                	jne    f0100aa2 <mon_showmappings+0x75>
	if (start_va > end_va) {
f0100a8c:	39 fb                	cmp    %edi,%ebx
f0100a8e:	76 3f                	jbe    f0100acf <mon_showmappings+0xa2>
		cprintf("showmappings error: start must be less than end\n");
f0100a90:	83 ec 0c             	sub    $0xc,%esp
f0100a93:	68 e8 6d 10 f0       	push   $0xf0106de8
f0100a98:	e8 d5 31 00 00       	call   f0103c72 <cprintf>
f0100a9d:	83 c4 10             	add    $0x10,%esp
f0100aa0:	eb ad                	jmp    f0100a4f <mon_showmappings+0x22>
		cprintf("showmappings error: start and end must be page aligned\n");
f0100aa2:	83 ec 0c             	sub    $0xc,%esp
f0100aa5:	68 b0 6d 10 f0       	push   $0xf0106db0
f0100aaa:	e8 c3 31 00 00       	call   f0103c72 <cprintf>
		return 0;
f0100aaf:	83 c4 10             	add    $0x10,%esp
f0100ab2:	eb 9b                	jmp    f0100a4f <mon_showmappings+0x22>
			cprintf("VA:0x%08x: unmapped\n", start_va);
f0100ab4:	83 ec 08             	sub    $0x8,%esp
f0100ab7:	53                   	push   %ebx
f0100ab8:	68 68 6b 10 f0       	push   $0xf0106b68
f0100abd:	e8 b0 31 00 00       	call   f0103c72 <cprintf>
f0100ac2:	83 c4 10             	add    $0x10,%esp
		start_va += PGSIZE;
f0100ac5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	while (start_va <= end_va) {
f0100acb:	39 df                	cmp    %ebx,%edi
f0100acd:	72 80                	jb     f0100a4f <mon_showmappings+0x22>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *)start_va, 0);
f0100acf:	83 ec 04             	sub    $0x4,%esp
f0100ad2:	6a 00                	push   $0x0
f0100ad4:	53                   	push   %ebx
f0100ad5:	ff 35 5c 72 22 f0    	push   0xf022725c
f0100adb:	e8 97 08 00 00       	call   f0101377 <pgdir_walk>
f0100ae0:	89 c6                	mov    %eax,%esi
		if ((!pte) || (!(*pte & PTE_P))) {
f0100ae2:	83 c4 10             	add    $0x10,%esp
f0100ae5:	85 c0                	test   %eax,%eax
f0100ae7:	74 cb                	je     f0100ab4 <mon_showmappings+0x87>
f0100ae9:	8b 00                	mov    (%eax),%eax
f0100aeb:	a8 01                	test   $0x1,%al
f0100aed:	74 c5                	je     f0100ab4 <mon_showmappings+0x87>
			cprintf("VA:0x%08x -> PA:0x%08x ", start_va, PTE_ADDR(*pte));
f0100aef:	83 ec 04             	sub    $0x4,%esp
f0100af2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af7:	50                   	push   %eax
f0100af8:	53                   	push   %ebx
f0100af9:	68 7d 6b 10 f0       	push   $0xf0106b7d
f0100afe:	e8 6f 31 00 00       	call   f0103c72 <cprintf>
			if (*pte & PTE_U) {
f0100b03:	83 c4 10             	add    $0x10,%esp
f0100b06:	f6 06 04             	testb  $0x4,(%esi)
f0100b09:	74 2e                	je     f0100b39 <mon_showmappings+0x10c>
				cputchar('U');
f0100b0b:	83 ec 0c             	sub    $0xc,%esp
f0100b0e:	6a 55                	push   $0x55
f0100b10:	e8 35 fc ff ff       	call   f010074a <cputchar>
f0100b15:	83 c4 10             	add    $0x10,%esp
			if (*pte & PTE_W) {
f0100b18:	f6 06 02             	testb  $0x2,(%esi)
f0100b1b:	74 2b                	je     f0100b48 <mon_showmappings+0x11b>
				cputchar('W');
f0100b1d:	83 ec 0c             	sub    $0xc,%esp
f0100b20:	6a 57                	push   $0x57
f0100b22:	e8 23 fc ff ff       	call   f010074a <cputchar>
f0100b27:	83 c4 10             	add    $0x10,%esp
			cputchar('\n');
f0100b2a:	83 ec 0c             	sub    $0xc,%esp
f0100b2d:	6a 0a                	push   $0xa
f0100b2f:	e8 16 fc ff ff       	call   f010074a <cputchar>
f0100b34:	83 c4 10             	add    $0x10,%esp
f0100b37:	eb 8c                	jmp    f0100ac5 <mon_showmappings+0x98>
				cputchar('-');
f0100b39:	83 ec 0c             	sub    $0xc,%esp
f0100b3c:	6a 2d                	push   $0x2d
f0100b3e:	e8 07 fc ff ff       	call   f010074a <cputchar>
f0100b43:	83 c4 10             	add    $0x10,%esp
f0100b46:	eb d0                	jmp    f0100b18 <mon_showmappings+0xeb>
				cputchar('-');
f0100b48:	83 ec 0c             	sub    $0xc,%esp
f0100b4b:	6a 2d                	push   $0x2d
f0100b4d:	e8 f8 fb ff ff       	call   f010074a <cputchar>
f0100b52:	83 c4 10             	add    $0x10,%esp
f0100b55:	eb d3                	jmp    f0100b2a <mon_showmappings+0xfd>

f0100b57 <mon_dumpmem>:
mon_dumpmem(int argc, char **argv, struct Trapframe *tf) {
f0100b57:	55                   	push   %ebp
f0100b58:	89 e5                	mov    %esp,%ebp
f0100b5a:	57                   	push   %edi
f0100b5b:	56                   	push   %esi
f0100b5c:	53                   	push   %ebx
f0100b5d:	83 ec 1c             	sub    $0x1c,%esp
f0100b60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (argc != 4) {
f0100b63:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100b67:	75 20                	jne    f0100b89 <mon_dumpmem+0x32>
	if ((argv[1][0] != 'V' && argv[1][0] != 'P')) {
f0100b69:	8b 43 04             	mov    0x4(%ebx),%eax
f0100b6c:	0f b6 00             	movzbl (%eax),%eax
f0100b6f:	3c 56                	cmp    $0x56,%al
f0100b71:	74 33                	je     f0100ba6 <mon_dumpmem+0x4f>
f0100b73:	3c 50                	cmp    $0x50,%al
f0100b75:	74 2f                	je     f0100ba6 <mon_dumpmem+0x4f>
		cprintf("Usage: dumpmem [V|P] [Start] [length]\n");
f0100b77:	83 ec 0c             	sub    $0xc,%esp
f0100b7a:	68 1c 6e 10 f0       	push   $0xf0106e1c
f0100b7f:	e8 ee 30 00 00       	call   f0103c72 <cprintf>
		return 0;
f0100b84:	83 c4 10             	add    $0x10,%esp
f0100b87:	eb 10                	jmp    f0100b99 <mon_dumpmem+0x42>
		cprintf("Usage: dumpmem [V|P] [Start] [length]\n");
f0100b89:	83 ec 0c             	sub    $0xc,%esp
f0100b8c:	68 1c 6e 10 f0       	push   $0xf0106e1c
f0100b91:	e8 dc 30 00 00       	call   f0103c72 <cprintf>
		return 0;
f0100b96:	83 c4 10             	add    $0x10,%esp
}
f0100b99:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ba1:	5b                   	pop    %ebx
f0100ba2:	5e                   	pop    %esi
f0100ba3:	5f                   	pop    %edi
f0100ba4:	5d                   	pop    %ebp
f0100ba5:	c3                   	ret    
	uintptr_t start_va = (uintptr_t)strtol(argv[2], NULL, 0);
f0100ba6:	83 ec 04             	sub    $0x4,%esp
f0100ba9:	6a 00                	push   $0x0
f0100bab:	6a 00                	push   $0x0
f0100bad:	ff 73 08             	push   0x8(%ebx)
f0100bb0:	e8 04 51 00 00       	call   f0105cb9 <strtol>
f0100bb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t length = (uint32_t)strtol(argv[3], NULL, 0);
f0100bb8:	83 c4 0c             	add    $0xc,%esp
f0100bbb:	6a 00                	push   $0x0
f0100bbd:	6a 00                	push   $0x0
f0100bbf:	ff 73 0c             	push   0xc(%ebx)
f0100bc2:	e8 f2 50 00 00       	call   f0105cb9 <strtol>
	if (argv[1][0] == 'P') {
f0100bc7:	8b 53 04             	mov    0x4(%ebx),%edx
f0100bca:	83 c4 10             	add    $0x10,%esp
f0100bcd:	80 3a 50             	cmpb   $0x50,(%edx)
f0100bd0:	74 10                	je     f0100be2 <mon_dumpmem+0x8b>
f0100bd2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100bd5:	8d 7a ff             	lea    -0x1(%edx),%edi
f0100bd8:	01 d0                	add    %edx,%eax
f0100bda:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i < length; i++) {
f0100bdd:	e9 b5 00 00 00       	jmp    f0100c97 <mon_dumpmem+0x140>
		if (start_va + length > PGSIZE * npages) {
f0100be2:	8b 15 60 72 22 f0    	mov    0xf0227260,%edx
f0100be8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100beb:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
f0100bee:	89 d1                	mov    %edx,%ecx
f0100bf0:	c1 e1 0c             	shl    $0xc,%ecx
f0100bf3:	39 cb                	cmp    %ecx,%ebx
f0100bf5:	77 13                	ja     f0100c0a <mon_dumpmem+0xb3>
	if (PGNUM(pa) >= npages)
f0100bf7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100bfa:	c1 e9 0c             	shr    $0xc,%ecx
f0100bfd:	39 ca                	cmp    %ecx,%edx
f0100bff:	76 1e                	jbe    f0100c1f <mon_dumpmem+0xc8>
	return (void *)(pa + KERNBASE);
f0100c01:	81 6d e4 00 00 00 10 	subl   $0x10000000,-0x1c(%ebp)
f0100c08:	eb c8                	jmp    f0100bd2 <mon_dumpmem+0x7b>
			cprintf("dumpmem error: address overflow\n");
f0100c0a:	83 ec 0c             	sub    $0xc,%esp
f0100c0d:	68 44 6e 10 f0       	push   $0xf0106e44
f0100c12:	e8 5b 30 00 00       	call   f0103c72 <cprintf>
			return 0;
f0100c17:	83 c4 10             	add    $0x10,%esp
f0100c1a:	e9 7a ff ff ff       	jmp    f0100b99 <mon_dumpmem+0x42>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c1f:	ff 75 e4             	push   -0x1c(%ebp)
f0100c22:	68 04 68 10 f0       	push   $0xf0106804
f0100c27:	68 b0 00 00 00       	push   $0xb0
f0100c2c:	68 95 6b 10 f0       	push   $0xf0106b95
f0100c31:	e8 0a f4 ff ff       	call   f0100040 <_panic>
				cprintf("??");
f0100c36:	83 ec 0c             	sub    $0xc,%esp
f0100c39:	68 b5 6b 10 f0       	push   $0xf0106bb5
f0100c3e:	e8 2f 30 00 00       	call   f0103c72 <cprintf>
f0100c43:	83 c4 10             	add    $0x10,%esp
		for (int j = 3; j >= 0; j--) {
f0100c46:	83 eb 01             	sub    $0x1,%ebx
f0100c49:	39 fb                	cmp    %edi,%ebx
f0100c4b:	74 33                	je     f0100c80 <mon_dumpmem+0x129>
			pte_t *pte = pgdir_walk(kern_pgdir, nowptr, 0);
f0100c4d:	83 ec 04             	sub    $0x4,%esp
f0100c50:	6a 00                	push   $0x0
f0100c52:	56                   	push   %esi
f0100c53:	ff 35 5c 72 22 f0    	push   0xf022725c
f0100c59:	e8 19 07 00 00       	call   f0101377 <pgdir_walk>
			if ((!pte) || (!(*pte & PTE_P))) {
f0100c5e:	83 c4 10             	add    $0x10,%esp
f0100c61:	85 c0                	test   %eax,%eax
f0100c63:	74 d1                	je     f0100c36 <mon_dumpmem+0xdf>
f0100c65:	f6 00 01             	testb  $0x1,(%eax)
f0100c68:	74 cc                	je     f0100c36 <mon_dumpmem+0xdf>
				cprintf("%02x", *((uint8_t *)nowptr + j));
f0100c6a:	83 ec 08             	sub    $0x8,%esp
f0100c6d:	0f b6 03             	movzbl (%ebx),%eax
f0100c70:	50                   	push   %eax
f0100c71:	68 b8 6b 10 f0       	push   $0xf0106bb8
f0100c76:	e8 f7 2f 00 00       	call   f0103c72 <cprintf>
f0100c7b:	83 c4 10             	add    $0x10,%esp
f0100c7e:	eb c6                	jmp    f0100c46 <mon_dumpmem+0xef>
		cprintf("\n");
f0100c80:	83 ec 0c             	sub    $0xc,%esp
f0100c83:	68 e8 73 10 f0       	push   $0xf01073e8
f0100c88:	e8 e5 2f 00 00       	call   f0103c72 <cprintf>
f0100c8d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
f0100c91:	83 c4 10             	add    $0x10,%esp
f0100c94:	8b 7d e0             	mov    -0x20(%ebp),%edi
	for (int i = 0; i < length; i++) {
f0100c97:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100c9a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0100c9d:	0f 84 f6 fe ff ff    	je     f0100b99 <mon_dumpmem+0x42>
		cprintf("VADDR 0x%08x: 0x", start_va + i);
f0100ca3:	83 ec 08             	sub    $0x8,%esp
f0100ca6:	ff 75 e4             	push   -0x1c(%ebp)
f0100ca9:	68 a4 6b 10 f0       	push   $0xf0106ba4
f0100cae:	e8 bf 2f 00 00       	call   f0103c72 <cprintf>
f0100cb3:	8d 77 01             	lea    0x1(%edi),%esi
f0100cb6:	8d 47 04             	lea    0x4(%edi),%eax
f0100cb9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100cbc:	83 c4 10             	add    $0x10,%esp
f0100cbf:	89 c3                	mov    %eax,%ebx
f0100cc1:	eb 8a                	jmp    f0100c4d <mon_dumpmem+0xf6>

f0100cc3 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100cc3:	55                   	push   %ebp
f0100cc4:	89 e5                	mov    %esp,%ebp
f0100cc6:	57                   	push   %edi
f0100cc7:	56                   	push   %esi
f0100cc8:	53                   	push   %ebx
f0100cc9:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ccc:	68 68 6e 10 f0       	push   $0xf0106e68
f0100cd1:	e8 9c 2f 00 00       	call   f0103c72 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100cd6:	c7 04 24 8c 6e 10 f0 	movl   $0xf0106e8c,(%esp)
f0100cdd:	e8 90 2f 00 00       	call   f0103c72 <cprintf>

	if (tf != NULL)
f0100ce2:	83 c4 10             	add    $0x10,%esp
f0100ce5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ce9:	74 57                	je     f0100d42 <monitor+0x7f>
		print_trapframe(tf);
f0100ceb:	83 ec 0c             	sub    $0xc,%esp
f0100cee:	ff 75 08             	push   0x8(%ebp)
f0100cf1:	e8 3c 35 00 00       	call   f0104232 <print_trapframe>
f0100cf6:	83 c4 10             	add    $0x10,%esp
f0100cf9:	eb 47                	jmp    f0100d42 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f0100cfb:	83 ec 08             	sub    $0x8,%esp
f0100cfe:	0f be c0             	movsbl %al,%eax
f0100d01:	50                   	push   %eax
f0100d02:	68 c1 6b 10 f0       	push   $0xf0106bc1
f0100d07:	e8 5a 4e 00 00       	call   f0105b66 <strchr>
f0100d0c:	83 c4 10             	add    $0x10,%esp
f0100d0f:	85 c0                	test   %eax,%eax
f0100d11:	74 0a                	je     f0100d1d <monitor+0x5a>
			*buf++ = 0;
f0100d13:	c6 03 00             	movb   $0x0,(%ebx)
f0100d16:	89 f7                	mov    %esi,%edi
f0100d18:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100d1b:	eb 6b                	jmp    f0100d88 <monitor+0xc5>
		if (*buf == 0)
f0100d1d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100d20:	74 73                	je     f0100d95 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f0100d22:	83 fe 0f             	cmp    $0xf,%esi
f0100d25:	74 09                	je     f0100d30 <monitor+0x6d>
		argv[argc++] = buf;
f0100d27:	8d 7e 01             	lea    0x1(%esi),%edi
f0100d2a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100d2e:	eb 39                	jmp    f0100d69 <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100d30:	83 ec 08             	sub    $0x8,%esp
f0100d33:	6a 10                	push   $0x10
f0100d35:	68 c6 6b 10 f0       	push   $0xf0106bc6
f0100d3a:	e8 33 2f 00 00       	call   f0103c72 <cprintf>
			return 0;
f0100d3f:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100d42:	83 ec 0c             	sub    $0xc,%esp
f0100d45:	68 bd 6b 10 f0       	push   $0xf0106bbd
f0100d4a:	e8 e9 4b 00 00       	call   f0105938 <readline>
f0100d4f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100d51:	83 c4 10             	add    $0x10,%esp
f0100d54:	85 c0                	test   %eax,%eax
f0100d56:	74 ea                	je     f0100d42 <monitor+0x7f>
	argv[argc] = 0;
f0100d58:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100d5f:	be 00 00 00 00       	mov    $0x0,%esi
f0100d64:	eb 24                	jmp    f0100d8a <monitor+0xc7>
			buf++;
f0100d66:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f0100d69:	0f b6 03             	movzbl (%ebx),%eax
f0100d6c:	84 c0                	test   %al,%al
f0100d6e:	74 18                	je     f0100d88 <monitor+0xc5>
f0100d70:	83 ec 08             	sub    $0x8,%esp
f0100d73:	0f be c0             	movsbl %al,%eax
f0100d76:	50                   	push   %eax
f0100d77:	68 c1 6b 10 f0       	push   $0xf0106bc1
f0100d7c:	e8 e5 4d 00 00       	call   f0105b66 <strchr>
f0100d81:	83 c4 10             	add    $0x10,%esp
f0100d84:	85 c0                	test   %eax,%eax
f0100d86:	74 de                	je     f0100d66 <monitor+0xa3>
			*buf++ = 0;
f0100d88:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100d8a:	0f b6 03             	movzbl (%ebx),%eax
f0100d8d:	84 c0                	test   %al,%al
f0100d8f:	0f 85 66 ff ff ff    	jne    f0100cfb <monitor+0x38>
	argv[argc] = 0;
f0100d95:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100d9c:	00 
	if (argc == 0)
f0100d9d:	85 f6                	test   %esi,%esi
f0100d9f:	74 a1                	je     f0100d42 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100da1:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100da6:	83 ec 08             	sub    $0x8,%esp
f0100da9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100dac:	ff 34 85 80 70 10 f0 	push   -0xfef8f80(,%eax,4)
f0100db3:	ff 75 a8             	push   -0x58(%ebp)
f0100db6:	e8 4b 4d 00 00       	call   f0105b06 <strcmp>
f0100dbb:	83 c4 10             	add    $0x10,%esp
f0100dbe:	85 c0                	test   %eax,%eax
f0100dc0:	74 20                	je     f0100de2 <monitor+0x11f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100dc2:	83 c3 01             	add    $0x1,%ebx
f0100dc5:	83 fb 08             	cmp    $0x8,%ebx
f0100dc8:	75 dc                	jne    f0100da6 <monitor+0xe3>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100dca:	83 ec 08             	sub    $0x8,%esp
f0100dcd:	ff 75 a8             	push   -0x58(%ebp)
f0100dd0:	68 e3 6b 10 f0       	push   $0xf0106be3
f0100dd5:	e8 98 2e 00 00       	call   f0103c72 <cprintf>
	return 0;
f0100dda:	83 c4 10             	add    $0x10,%esp
f0100ddd:	e9 60 ff ff ff       	jmp    f0100d42 <monitor+0x7f>
			return commands[i].func(argc, argv, tf);
f0100de2:	83 ec 04             	sub    $0x4,%esp
f0100de5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100de8:	ff 75 08             	push   0x8(%ebp)
f0100deb:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100dee:	52                   	push   %edx
f0100def:	56                   	push   %esi
f0100df0:	ff 14 85 88 70 10 f0 	call   *-0xfef8f78(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100df7:	83 c4 10             	add    $0x10,%esp
f0100dfa:	85 c0                	test   %eax,%eax
f0100dfc:	0f 89 40 ff ff ff    	jns    f0100d42 <monitor+0x7f>
				break;
	}
}
f0100e02:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e05:	5b                   	pop    %ebx
f0100e06:	5e                   	pop    %esi
f0100e07:	5f                   	pop    %edi
f0100e08:	5d                   	pop    %ebp
f0100e09:	c3                   	ret    

f0100e0a <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100e0a:	55                   	push   %ebp
f0100e0b:	89 e5                	mov    %esp,%ebp
f0100e0d:	56                   	push   %esi
f0100e0e:	53                   	push   %ebx
f0100e0f:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100e11:	83 ec 0c             	sub    $0xc,%esp
f0100e14:	50                   	push   %eax
f0100e15:	e8 be 2c 00 00       	call   f0103ad8 <mc146818_read>
f0100e1a:	89 c6                	mov    %eax,%esi
f0100e1c:	83 c3 01             	add    $0x1,%ebx
f0100e1f:	89 1c 24             	mov    %ebx,(%esp)
f0100e22:	e8 b1 2c 00 00       	call   f0103ad8 <mc146818_read>
f0100e27:	c1 e0 08             	shl    $0x8,%eax
f0100e2a:	09 f0                	or     %esi,%eax
}
f0100e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e2f:	5b                   	pop    %ebx
f0100e30:	5e                   	pop    %esi
f0100e31:	5d                   	pop    %ebp
f0100e32:	c3                   	ret    

f0100e33 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e33:	83 3d 64 72 22 f0 00 	cmpl   $0x0,0xf0227264
f0100e3a:	74 30                	je     f0100e6c <boot_alloc+0x39>
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("KERNBASE is %x\n", KERNBASE);
	
	result = nextfree;
f0100e3c:	8b 15 64 72 22 f0    	mov    0xf0227264,%edx
	if (n > 0) {
f0100e42:	85 c0                	test   %eax,%eax
f0100e44:	74 23                	je     f0100e69 <boot_alloc+0x36>
		nextfree = (char *)ROUNDUP((uint32_t) nextfree + n, PGSIZE);
f0100e46:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100e4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e52:	a3 64 72 22 f0       	mov    %eax,0xf0227264
		if ((uint32_t)nextfree - KERNBASE > npages * PGSIZE)
f0100e57:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e5c:	8b 0d 60 72 22 f0    	mov    0xf0227260,%ecx
f0100e62:	c1 e1 0c             	shl    $0xc,%ecx
f0100e65:	39 c8                	cmp    %ecx,%eax
f0100e67:	77 16                	ja     f0100e7f <boot_alloc+0x4c>
			panic("boot_alloc: out of memory\n");
	}
	return result;
}
f0100e69:	89 d0                	mov    %edx,%eax
f0100e6b:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100e6c:	ba c7 93 26 f0       	mov    $0xf02693c7,%edx
f0100e71:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100e77:	89 15 64 72 22 f0    	mov    %edx,0xf0227264
f0100e7d:	eb bd                	jmp    f0100e3c <boot_alloc+0x9>
{
f0100e7f:	55                   	push   %ebp
f0100e80:	89 e5                	mov    %esp,%ebp
f0100e82:	83 ec 0c             	sub    $0xc,%esp
			panic("boot_alloc: out of memory\n");
f0100e85:	68 e0 70 10 f0       	push   $0xf01070e0
f0100e8a:	6a 75                	push   $0x75
f0100e8c:	68 fb 70 10 f0       	push   $0xf01070fb
f0100e91:	e8 aa f1 ff ff       	call   f0100040 <_panic>

f0100e96 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100e96:	89 d1                	mov    %edx,%ecx
f0100e98:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100e9b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e9e:	a8 01                	test   $0x1,%al
f0100ea0:	74 51                	je     f0100ef3 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ea2:	89 c1                	mov    %eax,%ecx
f0100ea4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100eaa:	c1 e8 0c             	shr    $0xc,%eax
f0100ead:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f0100eb3:	73 23                	jae    f0100ed8 <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100eb5:	c1 ea 0c             	shr    $0xc,%edx
f0100eb8:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ebe:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ec5:	89 d0                	mov    %edx,%eax
f0100ec7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ecc:	f6 c2 01             	test   $0x1,%dl
f0100ecf:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ed4:	0f 44 c2             	cmove  %edx,%eax
f0100ed7:	c3                   	ret    
{
f0100ed8:	55                   	push   %ebp
f0100ed9:	89 e5                	mov    %esp,%ebp
f0100edb:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ede:	51                   	push   %ecx
f0100edf:	68 04 68 10 f0       	push   $0xf0106804
f0100ee4:	68 80 03 00 00       	push   $0x380
f0100ee9:	68 fb 70 10 f0       	push   $0xf01070fb
f0100eee:	e8 4d f1 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100ef3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100ef8:	c3                   	ret    

f0100ef9 <check_page_free_list>:
{
f0100ef9:	55                   	push   %ebp
f0100efa:	89 e5                	mov    %esp,%ebp
f0100efc:	57                   	push   %edi
f0100efd:	56                   	push   %esi
f0100efe:	53                   	push   %ebx
f0100eff:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f02:	84 c0                	test   %al,%al
f0100f04:	0f 85 77 02 00 00    	jne    f0101181 <check_page_free_list+0x288>
	if (!page_free_list)
f0100f0a:	83 3d 6c 72 22 f0 00 	cmpl   $0x0,0xf022726c
f0100f11:	74 0a                	je     f0100f1d <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f13:	be 00 04 00 00       	mov    $0x400,%esi
f0100f18:	e9 bf 02 00 00       	jmp    f01011dc <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100f1d:	83 ec 04             	sub    $0x4,%esp
f0100f20:	68 1c 74 10 f0       	push   $0xf010741c
f0100f25:	68 b3 02 00 00       	push   $0x2b3
f0100f2a:	68 fb 70 10 f0       	push   $0xf01070fb
f0100f2f:	e8 0c f1 ff ff       	call   f0100040 <_panic>
f0100f34:	50                   	push   %eax
f0100f35:	68 04 68 10 f0       	push   $0xf0106804
f0100f3a:	6a 58                	push   $0x58
f0100f3c:	68 07 71 10 f0       	push   $0xf0107107
f0100f41:	e8 fa f0 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f46:	8b 1b                	mov    (%ebx),%ebx
f0100f48:	85 db                	test   %ebx,%ebx
f0100f4a:	74 41                	je     f0100f8d <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f4c:	89 d8                	mov    %ebx,%eax
f0100f4e:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0100f54:	c1 f8 03             	sar    $0x3,%eax
f0100f57:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100f5a:	89 c2                	mov    %eax,%edx
f0100f5c:	c1 ea 16             	shr    $0x16,%edx
f0100f5f:	39 f2                	cmp    %esi,%edx
f0100f61:	73 e3                	jae    f0100f46 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100f63:	89 c2                	mov    %eax,%edx
f0100f65:	c1 ea 0c             	shr    $0xc,%edx
f0100f68:	3b 15 60 72 22 f0    	cmp    0xf0227260,%edx
f0100f6e:	73 c4                	jae    f0100f34 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100f70:	83 ec 04             	sub    $0x4,%esp
f0100f73:	68 80 00 00 00       	push   $0x80
f0100f78:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100f7d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f82:	50                   	push   %eax
f0100f83:	e8 1d 4c 00 00       	call   f0105ba5 <memset>
f0100f88:	83 c4 10             	add    $0x10,%esp
f0100f8b:	eb b9                	jmp    f0100f46 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100f8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f92:	e8 9c fe ff ff       	call   f0100e33 <boot_alloc>
f0100f97:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f9a:	8b 15 6c 72 22 f0    	mov    0xf022726c,%edx
		assert(pp >= pages);
f0100fa0:	8b 0d 58 72 22 f0    	mov    0xf0227258,%ecx
		assert(pp < pages + npages);
f0100fa6:	a1 60 72 22 f0       	mov    0xf0227260,%eax
f0100fab:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100fae:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100fb1:	bf 00 00 00 00       	mov    $0x0,%edi
f0100fb6:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fb9:	e9 f9 00 00 00       	jmp    f01010b7 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100fbe:	68 15 71 10 f0       	push   $0xf0107115
f0100fc3:	68 21 71 10 f0       	push   $0xf0107121
f0100fc8:	68 cd 02 00 00       	push   $0x2cd
f0100fcd:	68 fb 70 10 f0       	push   $0xf01070fb
f0100fd2:	e8 69 f0 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100fd7:	68 36 71 10 f0       	push   $0xf0107136
f0100fdc:	68 21 71 10 f0       	push   $0xf0107121
f0100fe1:	68 ce 02 00 00       	push   $0x2ce
f0100fe6:	68 fb 70 10 f0       	push   $0xf01070fb
f0100feb:	e8 50 f0 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ff0:	68 40 74 10 f0       	push   $0xf0107440
f0100ff5:	68 21 71 10 f0       	push   $0xf0107121
f0100ffa:	68 cf 02 00 00       	push   $0x2cf
f0100fff:	68 fb 70 10 f0       	push   $0xf01070fb
f0101004:	e8 37 f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0101009:	68 4a 71 10 f0       	push   $0xf010714a
f010100e:	68 21 71 10 f0       	push   $0xf0107121
f0101013:	68 d2 02 00 00       	push   $0x2d2
f0101018:	68 fb 70 10 f0       	push   $0xf01070fb
f010101d:	e8 1e f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101022:	68 5b 71 10 f0       	push   $0xf010715b
f0101027:	68 21 71 10 f0       	push   $0xf0107121
f010102c:	68 d3 02 00 00       	push   $0x2d3
f0101031:	68 fb 70 10 f0       	push   $0xf01070fb
f0101036:	e8 05 f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010103b:	68 74 74 10 f0       	push   $0xf0107474
f0101040:	68 21 71 10 f0       	push   $0xf0107121
f0101045:	68 d4 02 00 00       	push   $0x2d4
f010104a:	68 fb 70 10 f0       	push   $0xf01070fb
f010104f:	e8 ec ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101054:	68 74 71 10 f0       	push   $0xf0107174
f0101059:	68 21 71 10 f0       	push   $0xf0107121
f010105e:	68 d5 02 00 00       	push   $0x2d5
f0101063:	68 fb 70 10 f0       	push   $0xf01070fb
f0101068:	e8 d3 ef ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f010106d:	89 c3                	mov    %eax,%ebx
f010106f:	c1 eb 0c             	shr    $0xc,%ebx
f0101072:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0101075:	76 0f                	jbe    f0101086 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0101077:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010107c:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010107f:	77 17                	ja     f0101098 <check_page_free_list+0x19f>
			++nfree_extmem;
f0101081:	83 c7 01             	add    $0x1,%edi
f0101084:	eb 2f                	jmp    f01010b5 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101086:	50                   	push   %eax
f0101087:	68 04 68 10 f0       	push   $0xf0106804
f010108c:	6a 58                	push   $0x58
f010108e:	68 07 71 10 f0       	push   $0xf0107107
f0101093:	e8 a8 ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101098:	68 98 74 10 f0       	push   $0xf0107498
f010109d:	68 21 71 10 f0       	push   $0xf0107121
f01010a2:	68 d6 02 00 00       	push   $0x2d6
f01010a7:	68 fb 70 10 f0       	push   $0xf01070fb
f01010ac:	e8 8f ef ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f01010b1:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010b5:	8b 12                	mov    (%edx),%edx
f01010b7:	85 d2                	test   %edx,%edx
f01010b9:	74 74                	je     f010112f <check_page_free_list+0x236>
		assert(pp >= pages);
f01010bb:	39 d1                	cmp    %edx,%ecx
f01010bd:	0f 87 fb fe ff ff    	ja     f0100fbe <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f01010c3:	39 d6                	cmp    %edx,%esi
f01010c5:	0f 86 0c ff ff ff    	jbe    f0100fd7 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010cb:	89 d0                	mov    %edx,%eax
f01010cd:	29 c8                	sub    %ecx,%eax
f01010cf:	a8 07                	test   $0x7,%al
f01010d1:	0f 85 19 ff ff ff    	jne    f0100ff0 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f01010d7:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f01010da:	c1 e0 0c             	shl    $0xc,%eax
f01010dd:	0f 84 26 ff ff ff    	je     f0101009 <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f01010e3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010e8:	0f 84 34 ff ff ff    	je     f0101022 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01010ee:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01010f3:	0f 84 42 ff ff ff    	je     f010103b <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f01010f9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01010fe:	0f 84 50 ff ff ff    	je     f0101054 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101104:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101109:	0f 87 5e ff ff ff    	ja     f010106d <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f010110f:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101114:	75 9b                	jne    f01010b1 <check_page_free_list+0x1b8>
f0101116:	68 8e 71 10 f0       	push   $0xf010718e
f010111b:	68 21 71 10 f0       	push   $0xf0107121
f0101120:	68 d8 02 00 00       	push   $0x2d8
f0101125:	68 fb 70 10 f0       	push   $0xf01070fb
f010112a:	e8 11 ef ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f010112f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101132:	85 db                	test   %ebx,%ebx
f0101134:	7e 19                	jle    f010114f <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0101136:	85 ff                	test   %edi,%edi
f0101138:	7e 2e                	jle    f0101168 <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f010113a:	83 ec 0c             	sub    $0xc,%esp
f010113d:	68 e0 74 10 f0       	push   $0xf01074e0
f0101142:	e8 2b 2b 00 00       	call   f0103c72 <cprintf>
}
f0101147:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010114a:	5b                   	pop    %ebx
f010114b:	5e                   	pop    %esi
f010114c:	5f                   	pop    %edi
f010114d:	5d                   	pop    %ebp
f010114e:	c3                   	ret    
	assert(nfree_basemem > 0);
f010114f:	68 ab 71 10 f0       	push   $0xf01071ab
f0101154:	68 21 71 10 f0       	push   $0xf0107121
f0101159:	68 e0 02 00 00       	push   $0x2e0
f010115e:	68 fb 70 10 f0       	push   $0xf01070fb
f0101163:	e8 d8 ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101168:	68 bd 71 10 f0       	push   $0xf01071bd
f010116d:	68 21 71 10 f0       	push   $0xf0107121
f0101172:	68 e1 02 00 00       	push   $0x2e1
f0101177:	68 fb 70 10 f0       	push   $0xf01070fb
f010117c:	e8 bf ee ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0101181:	a1 6c 72 22 f0       	mov    0xf022726c,%eax
f0101186:	85 c0                	test   %eax,%eax
f0101188:	0f 84 8f fd ff ff    	je     f0100f1d <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010118e:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101191:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101194:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101197:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010119a:	89 c2                	mov    %eax,%edx
f010119c:	2b 15 58 72 22 f0    	sub    0xf0227258,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01011a2:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01011a8:	0f 95 c2             	setne  %dl
f01011ab:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01011ae:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01011b2:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01011b4:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011b8:	8b 00                	mov    (%eax),%eax
f01011ba:	85 c0                	test   %eax,%eax
f01011bc:	75 dc                	jne    f010119a <check_page_free_list+0x2a1>
		*tp[1] = 0;
f01011be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011c1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01011c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011cd:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01011cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011d2:	a3 6c 72 22 f0       	mov    %eax,0xf022726c
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01011d7:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01011dc:	8b 1d 6c 72 22 f0    	mov    0xf022726c,%ebx
f01011e2:	e9 61 fd ff ff       	jmp    f0100f48 <check_page_free_list+0x4f>

f01011e7 <page_init>:
{
f01011e7:	55                   	push   %ebp
f01011e8:	89 e5                	mov    %esp,%ebp
f01011ea:	57                   	push   %edi
f01011eb:	56                   	push   %esi
f01011ec:	53                   	push   %ebx
f01011ed:	83 ec 0c             	sub    $0xc,%esp
	size_t kernel_end = PADDR(boot_alloc(0)) / PGSIZE;
f01011f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01011f5:	e8 39 fc ff ff       	call   f0100e33 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f01011fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011ff:	76 1b                	jbe    f010121c <page_init+0x35>
	return (physaddr_t)kva - KERNBASE;
f0101201:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0101207:	c1 eb 0c             	shr    $0xc,%ebx
f010120a:	8b 35 6c 72 22 f0    	mov    0xf022726c,%esi
	for (i = 0; i < npages; i++) {
f0101210:	bf 00 00 00 00       	mov    $0x0,%edi
f0101215:	b8 00 00 00 00       	mov    $0x0,%eax
f010121a:	eb 2c                	jmp    f0101248 <page_init+0x61>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010121c:	50                   	push   %eax
f010121d:	68 28 68 10 f0       	push   $0xf0106828
f0101222:	68 45 01 00 00       	push   $0x145
f0101227:	68 fb 70 10 f0       	push   $0xf01070fb
f010122c:	e8 0f ee ff ff       	call   f0100040 <_panic>
            pages[i].pp_ref = 1;
f0101231:	8b 15 58 72 22 f0    	mov    0xf0227258,%edx
f0101237:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
            continue;
f010123d:	eb 06                	jmp    f0101245 <page_init+0x5e>
			pages[i].pp_link = NULL;
f010123f:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	for (i = 0; i < npages; i++) {
f0101245:	83 c0 01             	add    $0x1,%eax
f0101248:	39 05 60 72 22 f0    	cmp    %eax,0xf0227260
f010124e:	76 3a                	jbe    f010128a <page_init+0xa3>
		if(i == MPENTRY_PADDR/PGSIZE){
f0101250:	83 f8 07             	cmp    $0x7,%eax
f0101253:	74 dc                	je     f0101231 <page_init+0x4a>
f0101255:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
		pages[i].pp_ref = 0;
f010125c:	89 ca                	mov    %ecx,%edx
f010125e:	03 15 58 72 22 f0    	add    0xf0227258,%edx
f0101264:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		if ((i == 0) || ((i >= IOPHYSMEM / PGSIZE) && i < kernel_end)) {
f010126a:	85 c0                	test   %eax,%eax
f010126c:	74 d1                	je     f010123f <page_init+0x58>
f010126e:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0101273:	76 04                	jbe    f0101279 <page_init+0x92>
f0101275:	39 d8                	cmp    %ebx,%eax
f0101277:	72 c6                	jb     f010123f <page_init+0x58>
			pages[i].pp_link = page_free_list;
f0101279:	89 32                	mov    %esi,(%edx)
			page_free_list = &pages[i];
f010127b:	89 ce                	mov    %ecx,%esi
f010127d:	03 35 58 72 22 f0    	add    0xf0227258,%esi
f0101283:	bf 01 00 00 00       	mov    $0x1,%edi
f0101288:	eb bb                	jmp    f0101245 <page_init+0x5e>
f010128a:	89 f8                	mov    %edi,%eax
f010128c:	84 c0                	test   %al,%al
f010128e:	74 06                	je     f0101296 <page_init+0xaf>
f0101290:	89 35 6c 72 22 f0    	mov    %esi,0xf022726c
}
f0101296:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101299:	5b                   	pop    %ebx
f010129a:	5e                   	pop    %esi
f010129b:	5f                   	pop    %edi
f010129c:	5d                   	pop    %ebp
f010129d:	c3                   	ret    

f010129e <page_alloc>:
{
f010129e:	55                   	push   %ebp
f010129f:	89 e5                	mov    %esp,%ebp
f01012a1:	53                   	push   %ebx
f01012a2:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list == NULL) {
f01012a5:	8b 1d 6c 72 22 f0    	mov    0xf022726c,%ebx
f01012ab:	85 db                	test   %ebx,%ebx
f01012ad:	74 13                	je     f01012c2 <page_alloc+0x24>
	page_free_list = page_free_list -> pp_link;
f01012af:	8b 03                	mov    (%ebx),%eax
f01012b1:	a3 6c 72 22 f0       	mov    %eax,0xf022726c
	nowpage -> pp_link = NULL;
f01012b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f01012bc:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01012c0:	75 07                	jne    f01012c9 <page_alloc+0x2b>
}
f01012c2:	89 d8                	mov    %ebx,%eax
f01012c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012c7:	c9                   	leave  
f01012c8:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f01012c9:	89 d8                	mov    %ebx,%eax
f01012cb:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f01012d1:	c1 f8 03             	sar    $0x3,%eax
f01012d4:	89 c2                	mov    %eax,%edx
f01012d6:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01012d9:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01012de:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f01012e4:	73 1b                	jae    f0101301 <page_alloc+0x63>
		memset(page2kva(nowpage), 0, PGSIZE);
f01012e6:	83 ec 04             	sub    $0x4,%esp
f01012e9:	68 00 10 00 00       	push   $0x1000
f01012ee:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01012f0:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01012f6:	52                   	push   %edx
f01012f7:	e8 a9 48 00 00       	call   f0105ba5 <memset>
f01012fc:	83 c4 10             	add    $0x10,%esp
f01012ff:	eb c1                	jmp    f01012c2 <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101301:	52                   	push   %edx
f0101302:	68 04 68 10 f0       	push   $0xf0106804
f0101307:	6a 58                	push   $0x58
f0101309:	68 07 71 10 f0       	push   $0xf0107107
f010130e:	e8 2d ed ff ff       	call   f0100040 <_panic>

f0101313 <page_free>:
{
f0101313:	55                   	push   %ebp
f0101314:	89 e5                	mov    %esp,%ebp
f0101316:	83 ec 08             	sub    $0x8,%esp
f0101319:	8b 45 08             	mov    0x8(%ebp),%eax
	if ((pp->pp_link != NULL) || (pp->pp_ref != 0)) {
f010131c:	83 38 00             	cmpl   $0x0,(%eax)
f010131f:	75 16                	jne    f0101337 <page_free+0x24>
f0101321:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101326:	75 0f                	jne    f0101337 <page_free+0x24>
	pp->pp_link = page_free_list;
f0101328:	8b 15 6c 72 22 f0    	mov    0xf022726c,%edx
f010132e:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101330:	a3 6c 72 22 f0       	mov    %eax,0xf022726c
}
f0101335:	c9                   	leave  
f0101336:	c3                   	ret    
		panic("page_free: pp->pp_link != NULL or pp->pp_ref != 0");
f0101337:	83 ec 04             	sub    $0x4,%esp
f010133a:	68 04 75 10 f0       	push   $0xf0107504
f010133f:	68 80 01 00 00       	push   $0x180
f0101344:	68 fb 70 10 f0       	push   $0xf01070fb
f0101349:	e8 f2 ec ff ff       	call   f0100040 <_panic>

f010134e <page_decref>:
{
f010134e:	55                   	push   %ebp
f010134f:	89 e5                	mov    %esp,%ebp
f0101351:	83 ec 08             	sub    $0x8,%esp
f0101354:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101357:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010135b:	83 e8 01             	sub    $0x1,%eax
f010135e:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101362:	66 85 c0             	test   %ax,%ax
f0101365:	74 02                	je     f0101369 <page_decref+0x1b>
}
f0101367:	c9                   	leave  
f0101368:	c3                   	ret    
		page_free(pp);
f0101369:	83 ec 0c             	sub    $0xc,%esp
f010136c:	52                   	push   %edx
f010136d:	e8 a1 ff ff ff       	call   f0101313 <page_free>
f0101372:	83 c4 10             	add    $0x10,%esp
}
f0101375:	eb f0                	jmp    f0101367 <page_decref+0x19>

f0101377 <pgdir_walk>:
{
f0101377:	55                   	push   %ebp
f0101378:	89 e5                	mov    %esp,%ebp
f010137a:	56                   	push   %esi
f010137b:	53                   	push   %ebx
f010137c:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pde = pgdir + PDX(va);
f010137f:	89 f3                	mov    %esi,%ebx
f0101381:	c1 eb 16             	shr    $0x16,%ebx
f0101384:	c1 e3 02             	shl    $0x2,%ebx
f0101387:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!((*pde) & PTE_P)) {
f010138a:	f6 03 01             	testb  $0x1,(%ebx)
f010138d:	75 2f                	jne    f01013be <pgdir_walk+0x47>
		if (create) {
f010138f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101393:	74 6a                	je     f01013ff <pgdir_walk+0x88>
			struct PageInfo *newpage = page_alloc(1);
f0101395:	83 ec 0c             	sub    $0xc,%esp
f0101398:	6a 01                	push   $0x1
f010139a:	e8 ff fe ff ff       	call   f010129e <page_alloc>
			if (!newpage) {
f010139f:	83 c4 10             	add    $0x10,%esp
f01013a2:	85 c0                	test   %eax,%eax
f01013a4:	74 3d                	je     f01013e3 <pgdir_walk+0x6c>
	return (pp - pages) << PGSHIFT;
f01013a6:	89 c2                	mov    %eax,%edx
f01013a8:	2b 15 58 72 22 f0    	sub    0xf0227258,%edx
f01013ae:	c1 fa 03             	sar    $0x3,%edx
f01013b1:	c1 e2 0c             	shl    $0xc,%edx
			*pde = page2pa(newpage) | PTE_P | PTE_W | PTE_U;
f01013b4:	83 ca 07             	or     $0x7,%edx
f01013b7:	89 13                	mov    %edx,(%ebx)
			++newpage->pp_ref;
f01013b9:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	pte_t *pte = (pte_t *)KADDR(PTE_ADDR(*pde));
f01013be:	8b 03                	mov    (%ebx),%eax
f01013c0:	89 c2                	mov    %eax,%edx
f01013c2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01013c8:	c1 e8 0c             	shr    $0xc,%eax
f01013cb:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f01013d1:	73 17                	jae    f01013ea <pgdir_walk+0x73>
	pte += PTX(va);
f01013d3:	c1 ee 0a             	shr    $0xa,%esi
f01013d6:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01013dc:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f01013e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013e6:	5b                   	pop    %ebx
f01013e7:	5e                   	pop    %esi
f01013e8:	5d                   	pop    %ebp
f01013e9:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013ea:	52                   	push   %edx
f01013eb:	68 04 68 10 f0       	push   $0xf0106804
f01013f0:	68 b7 01 00 00       	push   $0x1b7
f01013f5:	68 fb 70 10 f0       	push   $0xf01070fb
f01013fa:	e8 41 ec ff ff       	call   f0100040 <_panic>
			return NULL;
f01013ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0101404:	eb dd                	jmp    f01013e3 <pgdir_walk+0x6c>

f0101406 <boot_map_region>:
{
f0101406:	55                   	push   %ebp
f0101407:	89 e5                	mov    %esp,%ebp
f0101409:	57                   	push   %edi
f010140a:	56                   	push   %esi
f010140b:	53                   	push   %ebx
f010140c:	83 ec 1c             	sub    $0x1c,%esp
f010140f:	89 c7                	mov    %eax,%edi
f0101411:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101414:	89 ce                	mov    %ecx,%esi
	for (offset = 0; offset < size; offset += PGSIZE) {
f0101416:	bb 00 00 00 00       	mov    $0x0,%ebx
f010141b:	eb 29                	jmp    f0101446 <boot_map_region+0x40>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + offset), 1);
f010141d:	83 ec 04             	sub    $0x4,%esp
f0101420:	6a 01                	push   $0x1
f0101422:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101425:	01 d8                	add    %ebx,%eax
f0101427:	50                   	push   %eax
f0101428:	57                   	push   %edi
f0101429:	e8 49 ff ff ff       	call   f0101377 <pgdir_walk>
f010142e:	89 c2                	mov    %eax,%edx
		*pte = (pa + offset) | perm | PTE_P;
f0101430:	89 d8                	mov    %ebx,%eax
f0101432:	03 45 08             	add    0x8(%ebp),%eax
f0101435:	0b 45 0c             	or     0xc(%ebp),%eax
f0101438:	83 c8 01             	or     $0x1,%eax
f010143b:	89 02                	mov    %eax,(%edx)
	for (offset = 0; offset < size; offset += PGSIZE) {
f010143d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101443:	83 c4 10             	add    $0x10,%esp
f0101446:	39 f3                	cmp    %esi,%ebx
f0101448:	72 d3                	jb     f010141d <boot_map_region+0x17>
}
f010144a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010144d:	5b                   	pop    %ebx
f010144e:	5e                   	pop    %esi
f010144f:	5f                   	pop    %edi
f0101450:	5d                   	pop    %ebp
f0101451:	c3                   	ret    

f0101452 <page_lookup>:
{
f0101452:	55                   	push   %ebp
f0101453:	89 e5                	mov    %esp,%ebp
f0101455:	53                   	push   %ebx
f0101456:	83 ec 08             	sub    $0x8,%esp
f0101459:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010145c:	6a 00                	push   $0x0
f010145e:	ff 75 0c             	push   0xc(%ebp)
f0101461:	ff 75 08             	push   0x8(%ebp)
f0101464:	e8 0e ff ff ff       	call   f0101377 <pgdir_walk>
	if ((!pte) || (!(*pte & PTE_P))) {
f0101469:	83 c4 10             	add    $0x10,%esp
f010146c:	85 c0                	test   %eax,%eax
f010146e:	74 21                	je     f0101491 <page_lookup+0x3f>
f0101470:	f6 00 01             	testb  $0x1,(%eax)
f0101473:	74 35                	je     f01014aa <page_lookup+0x58>
	if (pte_store) {
f0101475:	85 db                	test   %ebx,%ebx
f0101477:	74 02                	je     f010147b <page_lookup+0x29>
		*pte_store = pte;
f0101479:	89 03                	mov    %eax,(%ebx)
f010147b:	8b 00                	mov    (%eax),%eax
f010147d:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101480:	39 05 60 72 22 f0    	cmp    %eax,0xf0227260
f0101486:	76 0e                	jbe    f0101496 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101488:	8b 15 58 72 22 f0    	mov    0xf0227258,%edx
f010148e:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101494:	c9                   	leave  
f0101495:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101496:	83 ec 04             	sub    $0x4,%esp
f0101499:	68 38 75 10 f0       	push   $0xf0107538
f010149e:	6a 51                	push   $0x51
f01014a0:	68 07 71 10 f0       	push   $0xf0107107
f01014a5:	e8 96 eb ff ff       	call   f0100040 <_panic>
		return NULL;
f01014aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01014af:	eb e0                	jmp    f0101491 <page_lookup+0x3f>

f01014b1 <tlb_invalidate>:
{
f01014b1:	55                   	push   %ebp
f01014b2:	89 e5                	mov    %esp,%ebp
f01014b4:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f01014b7:	e8 e0 4c 00 00       	call   f010619c <cpunum>
f01014bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01014bf:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f01014c6:	74 16                	je     f01014de <tlb_invalidate+0x2d>
f01014c8:	e8 cf 4c 00 00       	call   f010619c <cpunum>
f01014cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01014d0:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01014d6:	8b 55 08             	mov    0x8(%ebp),%edx
f01014d9:	39 50 60             	cmp    %edx,0x60(%eax)
f01014dc:	75 06                	jne    f01014e4 <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01014de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014e1:	0f 01 38             	invlpg (%eax)
}
f01014e4:	c9                   	leave  
f01014e5:	c3                   	ret    

f01014e6 <page_remove>:
{
f01014e6:	55                   	push   %ebp
f01014e7:	89 e5                	mov    %esp,%ebp
f01014e9:	56                   	push   %esi
f01014ea:	53                   	push   %ebx
f01014eb:	83 ec 14             	sub    $0x14,%esp
f01014ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01014f1:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte = NULL;
f01014f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f01014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01014fe:	50                   	push   %eax
f01014ff:	56                   	push   %esi
f0101500:	53                   	push   %ebx
f0101501:	e8 4c ff ff ff       	call   f0101452 <page_lookup>
	if (!pp) {
f0101506:	83 c4 10             	add    $0x10,%esp
f0101509:	85 c0                	test   %eax,%eax
f010150b:	74 26                	je     f0101533 <page_remove+0x4d>
	page_decref(pp);
f010150d:	83 ec 0c             	sub    $0xc,%esp
f0101510:	50                   	push   %eax
f0101511:	e8 38 fe ff ff       	call   f010134e <page_decref>
	if (pte) {
f0101516:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101519:	83 c4 10             	add    $0x10,%esp
f010151c:	85 c0                	test   %eax,%eax
f010151e:	74 13                	je     f0101533 <page_remove+0x4d>
		*pte = 0;
f0101520:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(pgdir, va);
f0101526:	83 ec 08             	sub    $0x8,%esp
f0101529:	56                   	push   %esi
f010152a:	53                   	push   %ebx
f010152b:	e8 81 ff ff ff       	call   f01014b1 <tlb_invalidate>
f0101530:	83 c4 10             	add    $0x10,%esp
}
f0101533:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101536:	5b                   	pop    %ebx
f0101537:	5e                   	pop    %esi
f0101538:	5d                   	pop    %ebp
f0101539:	c3                   	ret    

f010153a <page_insert>:
{	
f010153a:	55                   	push   %ebp
f010153b:	89 e5                	mov    %esp,%ebp
f010153d:	57                   	push   %edi
f010153e:	56                   	push   %esi
f010153f:	53                   	push   %ebx
f0101540:	83 ec 10             	sub    $0x10,%esp
f0101543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101546:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f0101549:	6a 01                	push   $0x1
f010154b:	57                   	push   %edi
f010154c:	ff 75 08             	push   0x8(%ebp)
f010154f:	e8 23 fe ff ff       	call   f0101377 <pgdir_walk>
	if (!pte) {
f0101554:	83 c4 10             	add    $0x10,%esp
f0101557:	85 c0                	test   %eax,%eax
f0101559:	74 3e                	je     f0101599 <page_insert+0x5f>
f010155b:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f010155d:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) {
f0101562:	f6 00 01             	testb  $0x1,(%eax)
f0101565:	75 21                	jne    f0101588 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f0101567:	2b 1d 58 72 22 f0    	sub    0xf0227258,%ebx
f010156d:	c1 fb 03             	sar    $0x3,%ebx
f0101570:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f0101573:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101576:	83 cb 01             	or     $0x1,%ebx
f0101579:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010157b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101580:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101583:	5b                   	pop    %ebx
f0101584:	5e                   	pop    %esi
f0101585:	5f                   	pop    %edi
f0101586:	5d                   	pop    %ebp
f0101587:	c3                   	ret    
		page_remove(pgdir, va);
f0101588:	83 ec 08             	sub    $0x8,%esp
f010158b:	57                   	push   %edi
f010158c:	ff 75 08             	push   0x8(%ebp)
f010158f:	e8 52 ff ff ff       	call   f01014e6 <page_remove>
f0101594:	83 c4 10             	add    $0x10,%esp
f0101597:	eb ce                	jmp    f0101567 <page_insert+0x2d>
		return -E_NO_MEM;
f0101599:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010159e:	eb e0                	jmp    f0101580 <page_insert+0x46>

f01015a0 <mmio_map_region>:
{
f01015a0:	55                   	push   %ebp
f01015a1:	89 e5                	mov    %esp,%ebp
f01015a3:	53                   	push   %ebx
f01015a4:	83 ec 04             	sub    $0x4,%esp
	size = ROUNDUP(size, PGSIZE);
f01015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015aa:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f01015b0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size > MMIOLIM) {
f01015b6:	8b 15 00 63 12 f0    	mov    0xf0126300,%edx
f01015bc:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f01015bf:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01015c4:	77 26                	ja     f01015ec <mmio_map_region+0x4c>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f01015c6:	83 ec 08             	sub    $0x8,%esp
f01015c9:	6a 1a                	push   $0x1a
f01015cb:	ff 75 08             	push   0x8(%ebp)
f01015ce:	89 d9                	mov    %ebx,%ecx
f01015d0:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f01015d5:	e8 2c fe ff ff       	call   f0101406 <boot_map_region>
	void *ret = (void *)base;
f01015da:	a1 00 63 12 f0       	mov    0xf0126300,%eax
	base += size;
f01015df:	01 c3                	add    %eax,%ebx
f01015e1:	89 1d 00 63 12 f0    	mov    %ebx,0xf0126300
}
f01015e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015ea:	c9                   	leave  
f01015eb:	c3                   	ret    
		panic("mmio_map_region: overflow MMIOLIM");
f01015ec:	83 ec 04             	sub    $0x4,%esp
f01015ef:	68 58 75 10 f0       	push   $0xf0107558
f01015f4:	68 5d 02 00 00       	push   $0x25d
f01015f9:	68 fb 70 10 f0       	push   $0xf01070fb
f01015fe:	e8 3d ea ff ff       	call   f0100040 <_panic>

f0101603 <mem_init>:
{
f0101603:	55                   	push   %ebp
f0101604:	89 e5                	mov    %esp,%ebp
f0101606:	57                   	push   %edi
f0101607:	56                   	push   %esi
f0101608:	53                   	push   %ebx
f0101609:	83 ec 4c             	sub    $0x4c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f010160c:	b8 15 00 00 00       	mov    $0x15,%eax
f0101611:	e8 f4 f7 ff ff       	call   f0100e0a <nvram_read>
f0101616:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101618:	b8 17 00 00 00       	mov    $0x17,%eax
f010161d:	e8 e8 f7 ff ff       	call   f0100e0a <nvram_read>
f0101622:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101624:	b8 34 00 00 00       	mov    $0x34,%eax
f0101629:	e8 dc f7 ff ff       	call   f0100e0a <nvram_read>
	if (ext16mem)
f010162e:	c1 e0 06             	shl    $0x6,%eax
f0101631:	0f 84 d6 00 00 00    	je     f010170d <mem_init+0x10a>
		totalmem = 16 * 1024 + ext16mem;
f0101637:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f010163c:	89 c2                	mov    %eax,%edx
f010163e:	c1 ea 02             	shr    $0x2,%edx
f0101641:	89 15 60 72 22 f0    	mov    %edx,0xf0227260
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101647:	89 c2                	mov    %eax,%edx
f0101649:	29 da                	sub    %ebx,%edx
f010164b:	52                   	push   %edx
f010164c:	53                   	push   %ebx
f010164d:	50                   	push   %eax
f010164e:	68 7c 75 10 f0       	push   $0xf010757c
f0101653:	e8 1a 26 00 00       	call   f0103c72 <cprintf>
	cprintf("npages = %u\n", npages);
f0101658:	83 c4 08             	add    $0x8,%esp
f010165b:	ff 35 60 72 22 f0    	push   0xf0227260
f0101661:	68 ce 71 10 f0       	push   $0xf01071ce
f0101666:	e8 07 26 00 00       	call   f0103c72 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010166b:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101670:	e8 be f7 ff ff       	call   f0100e33 <boot_alloc>
f0101675:	a3 5c 72 22 f0       	mov    %eax,0xf022725c
	memset(kern_pgdir, 0, PGSIZE);
f010167a:	83 c4 0c             	add    $0xc,%esp
f010167d:	68 00 10 00 00       	push   $0x1000
f0101682:	6a 00                	push   $0x0
f0101684:	50                   	push   %eax
f0101685:	e8 1b 45 00 00       	call   f0105ba5 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010168a:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
	if ((uint32_t)kva < KERNBASE)
f010168f:	83 c4 10             	add    $0x10,%esp
f0101692:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101697:	0f 86 80 00 00 00    	jbe    f010171d <mem_init+0x11a>
	return (physaddr_t)kva - KERNBASE;
f010169d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01016a3:	83 ca 05             	or     $0x5,%edx
f01016a6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f01016ac:	a1 60 72 22 f0       	mov    0xf0227260,%eax
f01016b1:	c1 e0 03             	shl    $0x3,%eax
f01016b4:	e8 7a f7 ff ff       	call   f0100e33 <boot_alloc>
f01016b9:	a3 58 72 22 f0       	mov    %eax,0xf0227258
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01016be:	83 ec 04             	sub    $0x4,%esp
f01016c1:	8b 0d 60 72 22 f0    	mov    0xf0227260,%ecx
f01016c7:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f01016ce:	52                   	push   %edx
f01016cf:	6a 00                	push   $0x0
f01016d1:	50                   	push   %eax
f01016d2:	e8 ce 44 00 00       	call   f0105ba5 <memset>
	envs = (struct Env*) boot_alloc(NENV * sizeof(struct Env));
f01016d7:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01016dc:	e8 52 f7 ff ff       	call   f0100e33 <boot_alloc>
f01016e1:	a3 70 72 22 f0       	mov    %eax,0xf0227270
	page_init();
f01016e6:	e8 fc fa ff ff       	call   f01011e7 <page_init>
	check_page_free_list(1);
f01016eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01016f0:	e8 04 f8 ff ff       	call   f0100ef9 <check_page_free_list>
	if (!pages)
f01016f5:	83 c4 10             	add    $0x10,%esp
f01016f8:	83 3d 58 72 22 f0 00 	cmpl   $0x0,0xf0227258
f01016ff:	74 31                	je     f0101732 <mem_init+0x12f>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101701:	a1 6c 72 22 f0       	mov    0xf022726c,%eax
f0101706:	bb 00 00 00 00       	mov    $0x0,%ebx
f010170b:	eb 41                	jmp    f010174e <mem_init+0x14b>
		totalmem = 1 * 1024 + extmem;
f010170d:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101713:	85 f6                	test   %esi,%esi
f0101715:	0f 44 c3             	cmove  %ebx,%eax
f0101718:	e9 1f ff ff ff       	jmp    f010163c <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010171d:	50                   	push   %eax
f010171e:	68 28 68 10 f0       	push   $0xf0106828
f0101723:	68 9c 00 00 00       	push   $0x9c
f0101728:	68 fb 70 10 f0       	push   $0xf01070fb
f010172d:	e8 0e e9 ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101732:	83 ec 04             	sub    $0x4,%esp
f0101735:	68 db 71 10 f0       	push   $0xf01071db
f010173a:	68 f4 02 00 00       	push   $0x2f4
f010173f:	68 fb 70 10 f0       	push   $0xf01070fb
f0101744:	e8 f7 e8 ff ff       	call   f0100040 <_panic>
		++nfree;
f0101749:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010174c:	8b 00                	mov    (%eax),%eax
f010174e:	85 c0                	test   %eax,%eax
f0101750:	75 f7                	jne    f0101749 <mem_init+0x146>
	assert((pp0 = page_alloc(0)));
f0101752:	83 ec 0c             	sub    $0xc,%esp
f0101755:	6a 00                	push   $0x0
f0101757:	e8 42 fb ff ff       	call   f010129e <page_alloc>
f010175c:	89 c7                	mov    %eax,%edi
f010175e:	83 c4 10             	add    $0x10,%esp
f0101761:	85 c0                	test   %eax,%eax
f0101763:	0f 84 1f 02 00 00    	je     f0101988 <mem_init+0x385>
	assert((pp1 = page_alloc(0)));
f0101769:	83 ec 0c             	sub    $0xc,%esp
f010176c:	6a 00                	push   $0x0
f010176e:	e8 2b fb ff ff       	call   f010129e <page_alloc>
f0101773:	89 c6                	mov    %eax,%esi
f0101775:	83 c4 10             	add    $0x10,%esp
f0101778:	85 c0                	test   %eax,%eax
f010177a:	0f 84 21 02 00 00    	je     f01019a1 <mem_init+0x39e>
	assert((pp2 = page_alloc(0)));
f0101780:	83 ec 0c             	sub    $0xc,%esp
f0101783:	6a 00                	push   $0x0
f0101785:	e8 14 fb ff ff       	call   f010129e <page_alloc>
f010178a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010178d:	83 c4 10             	add    $0x10,%esp
f0101790:	85 c0                	test   %eax,%eax
f0101792:	0f 84 22 02 00 00    	je     f01019ba <mem_init+0x3b7>
	assert(pp1 && pp1 != pp0);
f0101798:	39 f7                	cmp    %esi,%edi
f010179a:	0f 84 33 02 00 00    	je     f01019d3 <mem_init+0x3d0>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017a3:	39 c7                	cmp    %eax,%edi
f01017a5:	0f 84 41 02 00 00    	je     f01019ec <mem_init+0x3e9>
f01017ab:	39 c6                	cmp    %eax,%esi
f01017ad:	0f 84 39 02 00 00    	je     f01019ec <mem_init+0x3e9>
	return (pp - pages) << PGSHIFT;
f01017b3:	8b 0d 58 72 22 f0    	mov    0xf0227258,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01017b9:	8b 15 60 72 22 f0    	mov    0xf0227260,%edx
f01017bf:	c1 e2 0c             	shl    $0xc,%edx
f01017c2:	89 f8                	mov    %edi,%eax
f01017c4:	29 c8                	sub    %ecx,%eax
f01017c6:	c1 f8 03             	sar    $0x3,%eax
f01017c9:	c1 e0 0c             	shl    $0xc,%eax
f01017cc:	39 d0                	cmp    %edx,%eax
f01017ce:	0f 83 31 02 00 00    	jae    f0101a05 <mem_init+0x402>
f01017d4:	89 f0                	mov    %esi,%eax
f01017d6:	29 c8                	sub    %ecx,%eax
f01017d8:	c1 f8 03             	sar    $0x3,%eax
f01017db:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01017de:	39 c2                	cmp    %eax,%edx
f01017e0:	0f 86 38 02 00 00    	jbe    f0101a1e <mem_init+0x41b>
f01017e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017e9:	29 c8                	sub    %ecx,%eax
f01017eb:	c1 f8 03             	sar    $0x3,%eax
f01017ee:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01017f1:	39 c2                	cmp    %eax,%edx
f01017f3:	0f 86 3e 02 00 00    	jbe    f0101a37 <mem_init+0x434>
	fl = page_free_list;
f01017f9:	a1 6c 72 22 f0       	mov    0xf022726c,%eax
f01017fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101801:	c7 05 6c 72 22 f0 00 	movl   $0x0,0xf022726c
f0101808:	00 00 00 
	assert(!page_alloc(0));
f010180b:	83 ec 0c             	sub    $0xc,%esp
f010180e:	6a 00                	push   $0x0
f0101810:	e8 89 fa ff ff       	call   f010129e <page_alloc>
f0101815:	83 c4 10             	add    $0x10,%esp
f0101818:	85 c0                	test   %eax,%eax
f010181a:	0f 85 30 02 00 00    	jne    f0101a50 <mem_init+0x44d>
	page_free(pp0);
f0101820:	83 ec 0c             	sub    $0xc,%esp
f0101823:	57                   	push   %edi
f0101824:	e8 ea fa ff ff       	call   f0101313 <page_free>
	page_free(pp1);
f0101829:	89 34 24             	mov    %esi,(%esp)
f010182c:	e8 e2 fa ff ff       	call   f0101313 <page_free>
	page_free(pp2);
f0101831:	83 c4 04             	add    $0x4,%esp
f0101834:	ff 75 d4             	push   -0x2c(%ebp)
f0101837:	e8 d7 fa ff ff       	call   f0101313 <page_free>
	assert((pp0 = page_alloc(0)));
f010183c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101843:	e8 56 fa ff ff       	call   f010129e <page_alloc>
f0101848:	89 c6                	mov    %eax,%esi
f010184a:	83 c4 10             	add    $0x10,%esp
f010184d:	85 c0                	test   %eax,%eax
f010184f:	0f 84 14 02 00 00    	je     f0101a69 <mem_init+0x466>
	assert((pp1 = page_alloc(0)));
f0101855:	83 ec 0c             	sub    $0xc,%esp
f0101858:	6a 00                	push   $0x0
f010185a:	e8 3f fa ff ff       	call   f010129e <page_alloc>
f010185f:	89 c7                	mov    %eax,%edi
f0101861:	83 c4 10             	add    $0x10,%esp
f0101864:	85 c0                	test   %eax,%eax
f0101866:	0f 84 16 02 00 00    	je     f0101a82 <mem_init+0x47f>
	assert((pp2 = page_alloc(0)));
f010186c:	83 ec 0c             	sub    $0xc,%esp
f010186f:	6a 00                	push   $0x0
f0101871:	e8 28 fa ff ff       	call   f010129e <page_alloc>
f0101876:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101879:	83 c4 10             	add    $0x10,%esp
f010187c:	85 c0                	test   %eax,%eax
f010187e:	0f 84 17 02 00 00    	je     f0101a9b <mem_init+0x498>
	assert(pp1 && pp1 != pp0);
f0101884:	39 fe                	cmp    %edi,%esi
f0101886:	0f 84 28 02 00 00    	je     f0101ab4 <mem_init+0x4b1>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010188c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010188f:	39 c6                	cmp    %eax,%esi
f0101891:	0f 84 36 02 00 00    	je     f0101acd <mem_init+0x4ca>
f0101897:	39 c7                	cmp    %eax,%edi
f0101899:	0f 84 2e 02 00 00    	je     f0101acd <mem_init+0x4ca>
	assert(!page_alloc(0));
f010189f:	83 ec 0c             	sub    $0xc,%esp
f01018a2:	6a 00                	push   $0x0
f01018a4:	e8 f5 f9 ff ff       	call   f010129e <page_alloc>
f01018a9:	83 c4 10             	add    $0x10,%esp
f01018ac:	85 c0                	test   %eax,%eax
f01018ae:	0f 85 32 02 00 00    	jne    f0101ae6 <mem_init+0x4e3>
f01018b4:	89 f0                	mov    %esi,%eax
f01018b6:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f01018bc:	c1 f8 03             	sar    $0x3,%eax
f01018bf:	89 c2                	mov    %eax,%edx
f01018c1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01018c4:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01018c9:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f01018cf:	0f 83 2a 02 00 00    	jae    f0101aff <mem_init+0x4fc>
	memset(page2kva(pp0), 1, PGSIZE);
f01018d5:	83 ec 04             	sub    $0x4,%esp
f01018d8:	68 00 10 00 00       	push   $0x1000
f01018dd:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01018df:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01018e5:	52                   	push   %edx
f01018e6:	e8 ba 42 00 00       	call   f0105ba5 <memset>
	page_free(pp0);
f01018eb:	89 34 24             	mov    %esi,(%esp)
f01018ee:	e8 20 fa ff ff       	call   f0101313 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018fa:	e8 9f f9 ff ff       	call   f010129e <page_alloc>
f01018ff:	83 c4 10             	add    $0x10,%esp
f0101902:	85 c0                	test   %eax,%eax
f0101904:	0f 84 07 02 00 00    	je     f0101b11 <mem_init+0x50e>
	assert(pp && pp0 == pp);
f010190a:	39 c6                	cmp    %eax,%esi
f010190c:	0f 85 18 02 00 00    	jne    f0101b2a <mem_init+0x527>
	return (pp - pages) << PGSHIFT;
f0101912:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0101918:	c1 f8 03             	sar    $0x3,%eax
f010191b:	89 c2                	mov    %eax,%edx
f010191d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101920:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101925:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f010192b:	0f 83 12 02 00 00    	jae    f0101b43 <mem_init+0x540>
	return (void *)(pa + KERNBASE);
f0101931:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101937:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f010193d:	80 38 00             	cmpb   $0x0,(%eax)
f0101940:	0f 85 0f 02 00 00    	jne    f0101b55 <mem_init+0x552>
	for (i = 0; i < PGSIZE; i++)
f0101946:	83 c0 01             	add    $0x1,%eax
f0101949:	39 d0                	cmp    %edx,%eax
f010194b:	75 f0                	jne    f010193d <mem_init+0x33a>
	page_free_list = fl;
f010194d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101950:	a3 6c 72 22 f0       	mov    %eax,0xf022726c
	page_free(pp0);
f0101955:	83 ec 0c             	sub    $0xc,%esp
f0101958:	56                   	push   %esi
f0101959:	e8 b5 f9 ff ff       	call   f0101313 <page_free>
	page_free(pp1);
f010195e:	89 3c 24             	mov    %edi,(%esp)
f0101961:	e8 ad f9 ff ff       	call   f0101313 <page_free>
	page_free(pp2);
f0101966:	83 c4 04             	add    $0x4,%esp
f0101969:	ff 75 d4             	push   -0x2c(%ebp)
f010196c:	e8 a2 f9 ff ff       	call   f0101313 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101971:	a1 6c 72 22 f0       	mov    0xf022726c,%eax
f0101976:	83 c4 10             	add    $0x10,%esp
f0101979:	85 c0                	test   %eax,%eax
f010197b:	0f 84 ed 01 00 00    	je     f0101b6e <mem_init+0x56b>
		--nfree;
f0101981:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101984:	8b 00                	mov    (%eax),%eax
f0101986:	eb f1                	jmp    f0101979 <mem_init+0x376>
	assert((pp0 = page_alloc(0)));
f0101988:	68 f6 71 10 f0       	push   $0xf01071f6
f010198d:	68 21 71 10 f0       	push   $0xf0107121
f0101992:	68 fc 02 00 00       	push   $0x2fc
f0101997:	68 fb 70 10 f0       	push   $0xf01070fb
f010199c:	e8 9f e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019a1:	68 0c 72 10 f0       	push   $0xf010720c
f01019a6:	68 21 71 10 f0       	push   $0xf0107121
f01019ab:	68 fd 02 00 00       	push   $0x2fd
f01019b0:	68 fb 70 10 f0       	push   $0xf01070fb
f01019b5:	e8 86 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01019ba:	68 22 72 10 f0       	push   $0xf0107222
f01019bf:	68 21 71 10 f0       	push   $0xf0107121
f01019c4:	68 fe 02 00 00       	push   $0x2fe
f01019c9:	68 fb 70 10 f0       	push   $0xf01070fb
f01019ce:	e8 6d e6 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01019d3:	68 38 72 10 f0       	push   $0xf0107238
f01019d8:	68 21 71 10 f0       	push   $0xf0107121
f01019dd:	68 01 03 00 00       	push   $0x301
f01019e2:	68 fb 70 10 f0       	push   $0xf01070fb
f01019e7:	e8 54 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019ec:	68 b8 75 10 f0       	push   $0xf01075b8
f01019f1:	68 21 71 10 f0       	push   $0xf0107121
f01019f6:	68 02 03 00 00       	push   $0x302
f01019fb:	68 fb 70 10 f0       	push   $0xf01070fb
f0101a00:	e8 3b e6 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a05:	68 4a 72 10 f0       	push   $0xf010724a
f0101a0a:	68 21 71 10 f0       	push   $0xf0107121
f0101a0f:	68 03 03 00 00       	push   $0x303
f0101a14:	68 fb 70 10 f0       	push   $0xf01070fb
f0101a19:	e8 22 e6 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a1e:	68 67 72 10 f0       	push   $0xf0107267
f0101a23:	68 21 71 10 f0       	push   $0xf0107121
f0101a28:	68 04 03 00 00       	push   $0x304
f0101a2d:	68 fb 70 10 f0       	push   $0xf01070fb
f0101a32:	e8 09 e6 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101a37:	68 84 72 10 f0       	push   $0xf0107284
f0101a3c:	68 21 71 10 f0       	push   $0xf0107121
f0101a41:	68 05 03 00 00       	push   $0x305
f0101a46:	68 fb 70 10 f0       	push   $0xf01070fb
f0101a4b:	e8 f0 e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101a50:	68 a1 72 10 f0       	push   $0xf01072a1
f0101a55:	68 21 71 10 f0       	push   $0xf0107121
f0101a5a:	68 0c 03 00 00       	push   $0x30c
f0101a5f:	68 fb 70 10 f0       	push   $0xf01070fb
f0101a64:	e8 d7 e5 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101a69:	68 f6 71 10 f0       	push   $0xf01071f6
f0101a6e:	68 21 71 10 f0       	push   $0xf0107121
f0101a73:	68 13 03 00 00       	push   $0x313
f0101a78:	68 fb 70 10 f0       	push   $0xf01070fb
f0101a7d:	e8 be e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a82:	68 0c 72 10 f0       	push   $0xf010720c
f0101a87:	68 21 71 10 f0       	push   $0xf0107121
f0101a8c:	68 14 03 00 00       	push   $0x314
f0101a91:	68 fb 70 10 f0       	push   $0xf01070fb
f0101a96:	e8 a5 e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a9b:	68 22 72 10 f0       	push   $0xf0107222
f0101aa0:	68 21 71 10 f0       	push   $0xf0107121
f0101aa5:	68 15 03 00 00       	push   $0x315
f0101aaa:	68 fb 70 10 f0       	push   $0xf01070fb
f0101aaf:	e8 8c e5 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101ab4:	68 38 72 10 f0       	push   $0xf0107238
f0101ab9:	68 21 71 10 f0       	push   $0xf0107121
f0101abe:	68 17 03 00 00       	push   $0x317
f0101ac3:	68 fb 70 10 f0       	push   $0xf01070fb
f0101ac8:	e8 73 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101acd:	68 b8 75 10 f0       	push   $0xf01075b8
f0101ad2:	68 21 71 10 f0       	push   $0xf0107121
f0101ad7:	68 18 03 00 00       	push   $0x318
f0101adc:	68 fb 70 10 f0       	push   $0xf01070fb
f0101ae1:	e8 5a e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101ae6:	68 a1 72 10 f0       	push   $0xf01072a1
f0101aeb:	68 21 71 10 f0       	push   $0xf0107121
f0101af0:	68 19 03 00 00       	push   $0x319
f0101af5:	68 fb 70 10 f0       	push   $0xf01070fb
f0101afa:	e8 41 e5 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101aff:	52                   	push   %edx
f0101b00:	68 04 68 10 f0       	push   $0xf0106804
f0101b05:	6a 58                	push   $0x58
f0101b07:	68 07 71 10 f0       	push   $0xf0107107
f0101b0c:	e8 2f e5 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b11:	68 b0 72 10 f0       	push   $0xf01072b0
f0101b16:	68 21 71 10 f0       	push   $0xf0107121
f0101b1b:	68 1e 03 00 00       	push   $0x31e
f0101b20:	68 fb 70 10 f0       	push   $0xf01070fb
f0101b25:	e8 16 e5 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101b2a:	68 ce 72 10 f0       	push   $0xf01072ce
f0101b2f:	68 21 71 10 f0       	push   $0xf0107121
f0101b34:	68 1f 03 00 00       	push   $0x31f
f0101b39:	68 fb 70 10 f0       	push   $0xf01070fb
f0101b3e:	e8 fd e4 ff ff       	call   f0100040 <_panic>
f0101b43:	52                   	push   %edx
f0101b44:	68 04 68 10 f0       	push   $0xf0106804
f0101b49:	6a 58                	push   $0x58
f0101b4b:	68 07 71 10 f0       	push   $0xf0107107
f0101b50:	e8 eb e4 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101b55:	68 de 72 10 f0       	push   $0xf01072de
f0101b5a:	68 21 71 10 f0       	push   $0xf0107121
f0101b5f:	68 22 03 00 00       	push   $0x322
f0101b64:	68 fb 70 10 f0       	push   $0xf01070fb
f0101b69:	e8 d2 e4 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101b6e:	85 db                	test   %ebx,%ebx
f0101b70:	0f 85 31 09 00 00    	jne    f01024a7 <mem_init+0xea4>
	cprintf("check_page_alloc() succeeded!\n");
f0101b76:	83 ec 0c             	sub    $0xc,%esp
f0101b79:	68 d8 75 10 f0       	push   $0xf01075d8
f0101b7e:	e8 ef 20 00 00       	call   f0103c72 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101b83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b8a:	e8 0f f7 ff ff       	call   f010129e <page_alloc>
f0101b8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b92:	83 c4 10             	add    $0x10,%esp
f0101b95:	85 c0                	test   %eax,%eax
f0101b97:	0f 84 23 09 00 00    	je     f01024c0 <mem_init+0xebd>
	assert((pp1 = page_alloc(0)));
f0101b9d:	83 ec 0c             	sub    $0xc,%esp
f0101ba0:	6a 00                	push   $0x0
f0101ba2:	e8 f7 f6 ff ff       	call   f010129e <page_alloc>
f0101ba7:	89 c3                	mov    %eax,%ebx
f0101ba9:	83 c4 10             	add    $0x10,%esp
f0101bac:	85 c0                	test   %eax,%eax
f0101bae:	0f 84 25 09 00 00    	je     f01024d9 <mem_init+0xed6>
	assert((pp2 = page_alloc(0)));
f0101bb4:	83 ec 0c             	sub    $0xc,%esp
f0101bb7:	6a 00                	push   $0x0
f0101bb9:	e8 e0 f6 ff ff       	call   f010129e <page_alloc>
f0101bbe:	89 c6                	mov    %eax,%esi
f0101bc0:	83 c4 10             	add    $0x10,%esp
f0101bc3:	85 c0                	test   %eax,%eax
f0101bc5:	0f 84 27 09 00 00    	je     f01024f2 <mem_init+0xeef>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101bcb:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101bce:	0f 84 37 09 00 00    	je     f010250b <mem_init+0xf08>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bd4:	39 c3                	cmp    %eax,%ebx
f0101bd6:	0f 84 48 09 00 00    	je     f0102524 <mem_init+0xf21>
f0101bdc:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101bdf:	0f 84 3f 09 00 00    	je     f0102524 <mem_init+0xf21>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101be5:	a1 6c 72 22 f0       	mov    0xf022726c,%eax
f0101bea:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101bed:	c7 05 6c 72 22 f0 00 	movl   $0x0,0xf022726c
f0101bf4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bf7:	83 ec 0c             	sub    $0xc,%esp
f0101bfa:	6a 00                	push   $0x0
f0101bfc:	e8 9d f6 ff ff       	call   f010129e <page_alloc>
f0101c01:	83 c4 10             	add    $0x10,%esp
f0101c04:	85 c0                	test   %eax,%eax
f0101c06:	0f 85 31 09 00 00    	jne    f010253d <mem_init+0xf3a>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c0c:	83 ec 04             	sub    $0x4,%esp
f0101c0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c12:	50                   	push   %eax
f0101c13:	6a 00                	push   $0x0
f0101c15:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101c1b:	e8 32 f8 ff ff       	call   f0101452 <page_lookup>
f0101c20:	83 c4 10             	add    $0x10,%esp
f0101c23:	85 c0                	test   %eax,%eax
f0101c25:	0f 85 2b 09 00 00    	jne    f0102556 <mem_init+0xf53>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c2b:	6a 02                	push   $0x2
f0101c2d:	6a 00                	push   $0x0
f0101c2f:	53                   	push   %ebx
f0101c30:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101c36:	e8 ff f8 ff ff       	call   f010153a <page_insert>
f0101c3b:	83 c4 10             	add    $0x10,%esp
f0101c3e:	85 c0                	test   %eax,%eax
f0101c40:	0f 89 29 09 00 00    	jns    f010256f <mem_init+0xf6c>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101c46:	83 ec 0c             	sub    $0xc,%esp
f0101c49:	ff 75 d4             	push   -0x2c(%ebp)
f0101c4c:	e8 c2 f6 ff ff       	call   f0101313 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101c51:	6a 02                	push   $0x2
f0101c53:	6a 00                	push   $0x0
f0101c55:	53                   	push   %ebx
f0101c56:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101c5c:	e8 d9 f8 ff ff       	call   f010153a <page_insert>
f0101c61:	83 c4 20             	add    $0x20,%esp
f0101c64:	85 c0                	test   %eax,%eax
f0101c66:	0f 85 1c 09 00 00    	jne    f0102588 <mem_init+0xf85>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101c6c:	8b 3d 5c 72 22 f0    	mov    0xf022725c,%edi
	return (pp - pages) << PGSHIFT;
f0101c72:	8b 0d 58 72 22 f0    	mov    0xf0227258,%ecx
f0101c78:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101c7b:	8b 17                	mov    (%edi),%edx
f0101c7d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101c83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c86:	29 c8                	sub    %ecx,%eax
f0101c88:	c1 f8 03             	sar    $0x3,%eax
f0101c8b:	c1 e0 0c             	shl    $0xc,%eax
f0101c8e:	39 c2                	cmp    %eax,%edx
f0101c90:	0f 85 0b 09 00 00    	jne    f01025a1 <mem_init+0xf9e>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101c96:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c9b:	89 f8                	mov    %edi,%eax
f0101c9d:	e8 f4 f1 ff ff       	call   f0100e96 <check_va2pa>
f0101ca2:	89 c2                	mov    %eax,%edx
f0101ca4:	89 d8                	mov    %ebx,%eax
f0101ca6:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101ca9:	c1 f8 03             	sar    $0x3,%eax
f0101cac:	c1 e0 0c             	shl    $0xc,%eax
f0101caf:	39 c2                	cmp    %eax,%edx
f0101cb1:	0f 85 03 09 00 00    	jne    f01025ba <mem_init+0xfb7>
	assert(pp1->pp_ref == 1);
f0101cb7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cbc:	0f 85 11 09 00 00    	jne    f01025d3 <mem_init+0xfd0>
	assert(pp0->pp_ref == 1);
f0101cc2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cc5:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101cca:	0f 85 1c 09 00 00    	jne    f01025ec <mem_init+0xfe9>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cd0:	6a 02                	push   $0x2
f0101cd2:	68 00 10 00 00       	push   $0x1000
f0101cd7:	56                   	push   %esi
f0101cd8:	57                   	push   %edi
f0101cd9:	e8 5c f8 ff ff       	call   f010153a <page_insert>
f0101cde:	83 c4 10             	add    $0x10,%esp
f0101ce1:	85 c0                	test   %eax,%eax
f0101ce3:	0f 85 1c 09 00 00    	jne    f0102605 <mem_init+0x1002>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ce9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cee:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f0101cf3:	e8 9e f1 ff ff       	call   f0100e96 <check_va2pa>
f0101cf8:	89 c2                	mov    %eax,%edx
f0101cfa:	89 f0                	mov    %esi,%eax
f0101cfc:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0101d02:	c1 f8 03             	sar    $0x3,%eax
f0101d05:	c1 e0 0c             	shl    $0xc,%eax
f0101d08:	39 c2                	cmp    %eax,%edx
f0101d0a:	0f 85 0e 09 00 00    	jne    f010261e <mem_init+0x101b>
	assert(pp2->pp_ref == 1);
f0101d10:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d15:	0f 85 1c 09 00 00    	jne    f0102637 <mem_init+0x1034>

	// should be no free memory
	assert(!page_alloc(0));
f0101d1b:	83 ec 0c             	sub    $0xc,%esp
f0101d1e:	6a 00                	push   $0x0
f0101d20:	e8 79 f5 ff ff       	call   f010129e <page_alloc>
f0101d25:	83 c4 10             	add    $0x10,%esp
f0101d28:	85 c0                	test   %eax,%eax
f0101d2a:	0f 85 20 09 00 00    	jne    f0102650 <mem_init+0x104d>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d30:	6a 02                	push   $0x2
f0101d32:	68 00 10 00 00       	push   $0x1000
f0101d37:	56                   	push   %esi
f0101d38:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101d3e:	e8 f7 f7 ff ff       	call   f010153a <page_insert>
f0101d43:	83 c4 10             	add    $0x10,%esp
f0101d46:	85 c0                	test   %eax,%eax
f0101d48:	0f 85 1b 09 00 00    	jne    f0102669 <mem_init+0x1066>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d4e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d53:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f0101d58:	e8 39 f1 ff ff       	call   f0100e96 <check_va2pa>
f0101d5d:	89 c2                	mov    %eax,%edx
f0101d5f:	89 f0                	mov    %esi,%eax
f0101d61:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0101d67:	c1 f8 03             	sar    $0x3,%eax
f0101d6a:	c1 e0 0c             	shl    $0xc,%eax
f0101d6d:	39 c2                	cmp    %eax,%edx
f0101d6f:	0f 85 0d 09 00 00    	jne    f0102682 <mem_init+0x107f>
	assert(pp2->pp_ref == 1);
f0101d75:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d7a:	0f 85 1b 09 00 00    	jne    f010269b <mem_init+0x1098>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d80:	83 ec 0c             	sub    $0xc,%esp
f0101d83:	6a 00                	push   $0x0
f0101d85:	e8 14 f5 ff ff       	call   f010129e <page_alloc>
f0101d8a:	83 c4 10             	add    $0x10,%esp
f0101d8d:	85 c0                	test   %eax,%eax
f0101d8f:	0f 85 1f 09 00 00    	jne    f01026b4 <mem_init+0x10b1>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d95:	8b 15 5c 72 22 f0    	mov    0xf022725c,%edx
f0101d9b:	8b 02                	mov    (%edx),%eax
f0101d9d:	89 c7                	mov    %eax,%edi
f0101d9f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0101da5:	c1 e8 0c             	shr    $0xc,%eax
f0101da8:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f0101dae:	0f 83 19 09 00 00    	jae    f01026cd <mem_init+0x10ca>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101db4:	83 ec 04             	sub    $0x4,%esp
f0101db7:	6a 00                	push   $0x0
f0101db9:	68 00 10 00 00       	push   $0x1000
f0101dbe:	52                   	push   %edx
f0101dbf:	e8 b3 f5 ff ff       	call   f0101377 <pgdir_walk>
f0101dc4:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0101dca:	83 c4 10             	add    $0x10,%esp
f0101dcd:	39 f8                	cmp    %edi,%eax
f0101dcf:	0f 85 0d 09 00 00    	jne    f01026e2 <mem_init+0x10df>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101dd5:	6a 06                	push   $0x6
f0101dd7:	68 00 10 00 00       	push   $0x1000
f0101ddc:	56                   	push   %esi
f0101ddd:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101de3:	e8 52 f7 ff ff       	call   f010153a <page_insert>
f0101de8:	83 c4 10             	add    $0x10,%esp
f0101deb:	85 c0                	test   %eax,%eax
f0101ded:	0f 85 08 09 00 00    	jne    f01026fb <mem_init+0x10f8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101df3:	8b 3d 5c 72 22 f0    	mov    0xf022725c,%edi
f0101df9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dfe:	89 f8                	mov    %edi,%eax
f0101e00:	e8 91 f0 ff ff       	call   f0100e96 <check_va2pa>
f0101e05:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101e07:	89 f0                	mov    %esi,%eax
f0101e09:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0101e0f:	c1 f8 03             	sar    $0x3,%eax
f0101e12:	c1 e0 0c             	shl    $0xc,%eax
f0101e15:	39 c2                	cmp    %eax,%edx
f0101e17:	0f 85 f7 08 00 00    	jne    f0102714 <mem_init+0x1111>
	assert(pp2->pp_ref == 1);
f0101e1d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e22:	0f 85 05 09 00 00    	jne    f010272d <mem_init+0x112a>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e28:	83 ec 04             	sub    $0x4,%esp
f0101e2b:	6a 00                	push   $0x0
f0101e2d:	68 00 10 00 00       	push   $0x1000
f0101e32:	57                   	push   %edi
f0101e33:	e8 3f f5 ff ff       	call   f0101377 <pgdir_walk>
f0101e38:	83 c4 10             	add    $0x10,%esp
f0101e3b:	f6 00 04             	testb  $0x4,(%eax)
f0101e3e:	0f 84 02 09 00 00    	je     f0102746 <mem_init+0x1143>
	assert(kern_pgdir[0] & PTE_U);
f0101e44:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f0101e49:	f6 00 04             	testb  $0x4,(%eax)
f0101e4c:	0f 84 0d 09 00 00    	je     f010275f <mem_init+0x115c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e52:	6a 02                	push   $0x2
f0101e54:	68 00 10 00 00       	push   $0x1000
f0101e59:	56                   	push   %esi
f0101e5a:	50                   	push   %eax
f0101e5b:	e8 da f6 ff ff       	call   f010153a <page_insert>
f0101e60:	83 c4 10             	add    $0x10,%esp
f0101e63:	85 c0                	test   %eax,%eax
f0101e65:	0f 85 0d 09 00 00    	jne    f0102778 <mem_init+0x1175>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e6b:	83 ec 04             	sub    $0x4,%esp
f0101e6e:	6a 00                	push   $0x0
f0101e70:	68 00 10 00 00       	push   $0x1000
f0101e75:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101e7b:	e8 f7 f4 ff ff       	call   f0101377 <pgdir_walk>
f0101e80:	83 c4 10             	add    $0x10,%esp
f0101e83:	f6 00 02             	testb  $0x2,(%eax)
f0101e86:	0f 84 05 09 00 00    	je     f0102791 <mem_init+0x118e>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e8c:	83 ec 04             	sub    $0x4,%esp
f0101e8f:	6a 00                	push   $0x0
f0101e91:	68 00 10 00 00       	push   $0x1000
f0101e96:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101e9c:	e8 d6 f4 ff ff       	call   f0101377 <pgdir_walk>
f0101ea1:	83 c4 10             	add    $0x10,%esp
f0101ea4:	f6 00 04             	testb  $0x4,(%eax)
f0101ea7:	0f 85 fd 08 00 00    	jne    f01027aa <mem_init+0x11a7>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ead:	6a 02                	push   $0x2
f0101eaf:	68 00 00 40 00       	push   $0x400000
f0101eb4:	ff 75 d4             	push   -0x2c(%ebp)
f0101eb7:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101ebd:	e8 78 f6 ff ff       	call   f010153a <page_insert>
f0101ec2:	83 c4 10             	add    $0x10,%esp
f0101ec5:	85 c0                	test   %eax,%eax
f0101ec7:	0f 89 f6 08 00 00    	jns    f01027c3 <mem_init+0x11c0>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101ecd:	6a 02                	push   $0x2
f0101ecf:	68 00 10 00 00       	push   $0x1000
f0101ed4:	53                   	push   %ebx
f0101ed5:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101edb:	e8 5a f6 ff ff       	call   f010153a <page_insert>
f0101ee0:	83 c4 10             	add    $0x10,%esp
f0101ee3:	85 c0                	test   %eax,%eax
f0101ee5:	0f 85 f1 08 00 00    	jne    f01027dc <mem_init+0x11d9>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101eeb:	83 ec 04             	sub    $0x4,%esp
f0101eee:	6a 00                	push   $0x0
f0101ef0:	68 00 10 00 00       	push   $0x1000
f0101ef5:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101efb:	e8 77 f4 ff ff       	call   f0101377 <pgdir_walk>
f0101f00:	83 c4 10             	add    $0x10,%esp
f0101f03:	f6 00 04             	testb  $0x4,(%eax)
f0101f06:	0f 85 e9 08 00 00    	jne    f01027f5 <mem_init+0x11f2>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f0c:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f0101f11:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101f14:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f19:	e8 78 ef ff ff       	call   f0100e96 <check_va2pa>
f0101f1e:	89 df                	mov    %ebx,%edi
f0101f20:	2b 3d 58 72 22 f0    	sub    0xf0227258,%edi
f0101f26:	c1 ff 03             	sar    $0x3,%edi
f0101f29:	c1 e7 0c             	shl    $0xc,%edi
f0101f2c:	39 f8                	cmp    %edi,%eax
f0101f2e:	0f 85 da 08 00 00    	jne    f010280e <mem_init+0x120b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f34:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f39:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f3c:	e8 55 ef ff ff       	call   f0100e96 <check_va2pa>
f0101f41:	39 c7                	cmp    %eax,%edi
f0101f43:	0f 85 de 08 00 00    	jne    f0102827 <mem_init+0x1224>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f49:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101f4e:	0f 85 ec 08 00 00    	jne    f0102840 <mem_init+0x123d>
	assert(pp2->pp_ref == 0);
f0101f54:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f59:	0f 85 fa 08 00 00    	jne    f0102859 <mem_init+0x1256>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f5f:	83 ec 0c             	sub    $0xc,%esp
f0101f62:	6a 00                	push   $0x0
f0101f64:	e8 35 f3 ff ff       	call   f010129e <page_alloc>
f0101f69:	83 c4 10             	add    $0x10,%esp
f0101f6c:	39 c6                	cmp    %eax,%esi
f0101f6e:	0f 85 fe 08 00 00    	jne    f0102872 <mem_init+0x126f>
f0101f74:	85 c0                	test   %eax,%eax
f0101f76:	0f 84 f6 08 00 00    	je     f0102872 <mem_init+0x126f>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f7c:	83 ec 08             	sub    $0x8,%esp
f0101f7f:	6a 00                	push   $0x0
f0101f81:	ff 35 5c 72 22 f0    	push   0xf022725c
f0101f87:	e8 5a f5 ff ff       	call   f01014e6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f8c:	8b 3d 5c 72 22 f0    	mov    0xf022725c,%edi
f0101f92:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f97:	89 f8                	mov    %edi,%eax
f0101f99:	e8 f8 ee ff ff       	call   f0100e96 <check_va2pa>
f0101f9e:	83 c4 10             	add    $0x10,%esp
f0101fa1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa4:	0f 85 e1 08 00 00    	jne    f010288b <mem_init+0x1288>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101faa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101faf:	89 f8                	mov    %edi,%eax
f0101fb1:	e8 e0 ee ff ff       	call   f0100e96 <check_va2pa>
f0101fb6:	89 c2                	mov    %eax,%edx
f0101fb8:	89 d8                	mov    %ebx,%eax
f0101fba:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0101fc0:	c1 f8 03             	sar    $0x3,%eax
f0101fc3:	c1 e0 0c             	shl    $0xc,%eax
f0101fc6:	39 c2                	cmp    %eax,%edx
f0101fc8:	0f 85 d6 08 00 00    	jne    f01028a4 <mem_init+0x12a1>
	assert(pp1->pp_ref == 1);
f0101fce:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101fd3:	0f 85 e4 08 00 00    	jne    f01028bd <mem_init+0x12ba>
	assert(pp2->pp_ref == 0);
f0101fd9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fde:	0f 85 f2 08 00 00    	jne    f01028d6 <mem_init+0x12d3>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101fe4:	6a 00                	push   $0x0
f0101fe6:	68 00 10 00 00       	push   $0x1000
f0101feb:	53                   	push   %ebx
f0101fec:	57                   	push   %edi
f0101fed:	e8 48 f5 ff ff       	call   f010153a <page_insert>
f0101ff2:	83 c4 10             	add    $0x10,%esp
f0101ff5:	85 c0                	test   %eax,%eax
f0101ff7:	0f 85 f2 08 00 00    	jne    f01028ef <mem_init+0x12ec>
	assert(pp1->pp_ref);
f0101ffd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102002:	0f 84 00 09 00 00    	je     f0102908 <mem_init+0x1305>
	assert(pp1->pp_link == NULL);
f0102008:	83 3b 00             	cmpl   $0x0,(%ebx)
f010200b:	0f 85 10 09 00 00    	jne    f0102921 <mem_init+0x131e>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102011:	83 ec 08             	sub    $0x8,%esp
f0102014:	68 00 10 00 00       	push   $0x1000
f0102019:	ff 35 5c 72 22 f0    	push   0xf022725c
f010201f:	e8 c2 f4 ff ff       	call   f01014e6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102024:	8b 3d 5c 72 22 f0    	mov    0xf022725c,%edi
f010202a:	ba 00 00 00 00       	mov    $0x0,%edx
f010202f:	89 f8                	mov    %edi,%eax
f0102031:	e8 60 ee ff ff       	call   f0100e96 <check_va2pa>
f0102036:	83 c4 10             	add    $0x10,%esp
f0102039:	83 f8 ff             	cmp    $0xffffffff,%eax
f010203c:	0f 85 f8 08 00 00    	jne    f010293a <mem_init+0x1337>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102042:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102047:	89 f8                	mov    %edi,%eax
f0102049:	e8 48 ee ff ff       	call   f0100e96 <check_va2pa>
f010204e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102051:	0f 85 fc 08 00 00    	jne    f0102953 <mem_init+0x1350>
	assert(pp1->pp_ref == 0);
f0102057:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010205c:	0f 85 0a 09 00 00    	jne    f010296c <mem_init+0x1369>
	assert(pp2->pp_ref == 0);
f0102062:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102067:	0f 85 18 09 00 00    	jne    f0102985 <mem_init+0x1382>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010206d:	83 ec 0c             	sub    $0xc,%esp
f0102070:	6a 00                	push   $0x0
f0102072:	e8 27 f2 ff ff       	call   f010129e <page_alloc>
f0102077:	83 c4 10             	add    $0x10,%esp
f010207a:	85 c0                	test   %eax,%eax
f010207c:	0f 84 1c 09 00 00    	je     f010299e <mem_init+0x139b>
f0102082:	39 c3                	cmp    %eax,%ebx
f0102084:	0f 85 14 09 00 00    	jne    f010299e <mem_init+0x139b>

	// should be no free memory
	assert(!page_alloc(0));
f010208a:	83 ec 0c             	sub    $0xc,%esp
f010208d:	6a 00                	push   $0x0
f010208f:	e8 0a f2 ff ff       	call   f010129e <page_alloc>
f0102094:	83 c4 10             	add    $0x10,%esp
f0102097:	85 c0                	test   %eax,%eax
f0102099:	0f 85 18 09 00 00    	jne    f01029b7 <mem_init+0x13b4>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010209f:	8b 0d 5c 72 22 f0    	mov    0xf022725c,%ecx
f01020a5:	8b 11                	mov    (%ecx),%edx
f01020a7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020b0:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f01020b6:	c1 f8 03             	sar    $0x3,%eax
f01020b9:	c1 e0 0c             	shl    $0xc,%eax
f01020bc:	39 c2                	cmp    %eax,%edx
f01020be:	0f 85 0c 09 00 00    	jne    f01029d0 <mem_init+0x13cd>
	kern_pgdir[0] = 0;
f01020c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020cd:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020d2:	0f 85 11 09 00 00    	jne    f01029e9 <mem_init+0x13e6>
	pp0->pp_ref = 0;
f01020d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020db:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01020e1:	83 ec 0c             	sub    $0xc,%esp
f01020e4:	50                   	push   %eax
f01020e5:	e8 29 f2 ff ff       	call   f0101313 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01020ea:	83 c4 0c             	add    $0xc,%esp
f01020ed:	6a 01                	push   $0x1
f01020ef:	68 00 10 40 00       	push   $0x401000
f01020f4:	ff 35 5c 72 22 f0    	push   0xf022725c
f01020fa:	e8 78 f2 ff ff       	call   f0101377 <pgdir_walk>
f01020ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102102:	8b 0d 5c 72 22 f0    	mov    0xf022725c,%ecx
f0102108:	8b 41 04             	mov    0x4(%ecx),%eax
f010210b:	89 c7                	mov    %eax,%edi
f010210d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (PGNUM(pa) >= npages)
f0102113:	8b 15 60 72 22 f0    	mov    0xf0227260,%edx
f0102119:	c1 e8 0c             	shr    $0xc,%eax
f010211c:	83 c4 10             	add    $0x10,%esp
f010211f:	39 d0                	cmp    %edx,%eax
f0102121:	0f 83 db 08 00 00    	jae    f0102a02 <mem_init+0x13ff>
	assert(ptep == ptep1 + PTX(va));
f0102127:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f010212d:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0102130:	0f 85 e1 08 00 00    	jne    f0102a17 <mem_init+0x1414>
	kern_pgdir[PDX(va)] = 0;
f0102136:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f010213d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102140:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0102146:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f010214c:	c1 f8 03             	sar    $0x3,%eax
f010214f:	89 c1                	mov    %eax,%ecx
f0102151:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0102154:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102159:	39 c2                	cmp    %eax,%edx
f010215b:	0f 86 cf 08 00 00    	jbe    f0102a30 <mem_init+0x142d>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102161:	83 ec 04             	sub    $0x4,%esp
f0102164:	68 00 10 00 00       	push   $0x1000
f0102169:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010216e:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0102174:	51                   	push   %ecx
f0102175:	e8 2b 3a 00 00       	call   f0105ba5 <memset>
	page_free(pp0);
f010217a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010217d:	89 3c 24             	mov    %edi,(%esp)
f0102180:	e8 8e f1 ff ff       	call   f0101313 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102185:	83 c4 0c             	add    $0xc,%esp
f0102188:	6a 01                	push   $0x1
f010218a:	6a 00                	push   $0x0
f010218c:	ff 35 5c 72 22 f0    	push   0xf022725c
f0102192:	e8 e0 f1 ff ff       	call   f0101377 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102197:	89 f8                	mov    %edi,%eax
f0102199:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f010219f:	c1 f8 03             	sar    $0x3,%eax
f01021a2:	89 c2                	mov    %eax,%edx
f01021a4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01021a7:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01021ac:	83 c4 10             	add    $0x10,%esp
f01021af:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f01021b5:	0f 83 87 08 00 00    	jae    f0102a42 <mem_init+0x143f>
	return (void *)(pa + KERNBASE);
f01021bb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01021c1:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01021c7:	f6 00 01             	testb  $0x1,(%eax)
f01021ca:	0f 85 84 08 00 00    	jne    f0102a54 <mem_init+0x1451>
	for(i=0; i<NPTENTRIES; i++)
f01021d0:	83 c0 04             	add    $0x4,%eax
f01021d3:	39 d0                	cmp    %edx,%eax
f01021d5:	75 f0                	jne    f01021c7 <mem_init+0xbc4>
	kern_pgdir[0] = 0;
f01021d7:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f01021dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01021e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021e5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01021eb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01021ee:	89 0d 6c 72 22 f0    	mov    %ecx,0xf022726c

	// free the pages we took
	page_free(pp0);
f01021f4:	83 ec 0c             	sub    $0xc,%esp
f01021f7:	50                   	push   %eax
f01021f8:	e8 16 f1 ff ff       	call   f0101313 <page_free>
	page_free(pp1);
f01021fd:	89 1c 24             	mov    %ebx,(%esp)
f0102200:	e8 0e f1 ff ff       	call   f0101313 <page_free>
	page_free(pp2);
f0102205:	89 34 24             	mov    %esi,(%esp)
f0102208:	e8 06 f1 ff ff       	call   f0101313 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010220d:	83 c4 08             	add    $0x8,%esp
f0102210:	68 01 10 00 00       	push   $0x1001
f0102215:	6a 00                	push   $0x0
f0102217:	e8 84 f3 ff ff       	call   f01015a0 <mmio_map_region>
f010221c:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010221e:	83 c4 08             	add    $0x8,%esp
f0102221:	68 00 10 00 00       	push   $0x1000
f0102226:	6a 00                	push   $0x0
f0102228:	e8 73 f3 ff ff       	call   f01015a0 <mmio_map_region>
f010222d:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f010222f:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102235:	83 c4 10             	add    $0x10,%esp
f0102238:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010223e:	0f 86 29 08 00 00    	jbe    f0102a6d <mem_init+0x146a>
f0102244:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102249:	0f 87 1e 08 00 00    	ja     f0102a6d <mem_init+0x146a>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010224f:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102255:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010225b:	0f 87 25 08 00 00    	ja     f0102a86 <mem_init+0x1483>
f0102261:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102267:	0f 86 19 08 00 00    	jbe    f0102a86 <mem_init+0x1483>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010226d:	89 da                	mov    %ebx,%edx
f010226f:	09 f2                	or     %esi,%edx
f0102271:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102277:	0f 85 22 08 00 00    	jne    f0102a9f <mem_init+0x149c>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010227d:	39 c6                	cmp    %eax,%esi
f010227f:	0f 82 33 08 00 00    	jb     f0102ab8 <mem_init+0x14b5>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102285:	8b 3d 5c 72 22 f0    	mov    0xf022725c,%edi
f010228b:	89 da                	mov    %ebx,%edx
f010228d:	89 f8                	mov    %edi,%eax
f010228f:	e8 02 ec ff ff       	call   f0100e96 <check_va2pa>
f0102294:	85 c0                	test   %eax,%eax
f0102296:	0f 85 35 08 00 00    	jne    f0102ad1 <mem_init+0x14ce>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010229c:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01022a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01022a5:	89 c2                	mov    %eax,%edx
f01022a7:	89 f8                	mov    %edi,%eax
f01022a9:	e8 e8 eb ff ff       	call   f0100e96 <check_va2pa>
f01022ae:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01022b3:	0f 85 31 08 00 00    	jne    f0102aea <mem_init+0x14e7>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01022b9:	89 f2                	mov    %esi,%edx
f01022bb:	89 f8                	mov    %edi,%eax
f01022bd:	e8 d4 eb ff ff       	call   f0100e96 <check_va2pa>
f01022c2:	85 c0                	test   %eax,%eax
f01022c4:	0f 85 39 08 00 00    	jne    f0102b03 <mem_init+0x1500>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01022ca:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01022d0:	89 f8                	mov    %edi,%eax
f01022d2:	e8 bf eb ff ff       	call   f0100e96 <check_va2pa>
f01022d7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022da:	0f 85 3c 08 00 00    	jne    f0102b1c <mem_init+0x1519>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01022e0:	83 ec 04             	sub    $0x4,%esp
f01022e3:	6a 00                	push   $0x0
f01022e5:	53                   	push   %ebx
f01022e6:	57                   	push   %edi
f01022e7:	e8 8b f0 ff ff       	call   f0101377 <pgdir_walk>
f01022ec:	83 c4 10             	add    $0x10,%esp
f01022ef:	f6 00 1a             	testb  $0x1a,(%eax)
f01022f2:	0f 84 3d 08 00 00    	je     f0102b35 <mem_init+0x1532>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01022f8:	83 ec 04             	sub    $0x4,%esp
f01022fb:	6a 00                	push   $0x0
f01022fd:	53                   	push   %ebx
f01022fe:	ff 35 5c 72 22 f0    	push   0xf022725c
f0102304:	e8 6e f0 ff ff       	call   f0101377 <pgdir_walk>
f0102309:	8b 00                	mov    (%eax),%eax
f010230b:	83 c4 10             	add    $0x10,%esp
f010230e:	83 e0 04             	and    $0x4,%eax
f0102311:	89 c7                	mov    %eax,%edi
f0102313:	0f 85 35 08 00 00    	jne    f0102b4e <mem_init+0x154b>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102319:	83 ec 04             	sub    $0x4,%esp
f010231c:	6a 00                	push   $0x0
f010231e:	53                   	push   %ebx
f010231f:	ff 35 5c 72 22 f0    	push   0xf022725c
f0102325:	e8 4d f0 ff ff       	call   f0101377 <pgdir_walk>
f010232a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102330:	83 c4 0c             	add    $0xc,%esp
f0102333:	6a 00                	push   $0x0
f0102335:	ff 75 d4             	push   -0x2c(%ebp)
f0102338:	ff 35 5c 72 22 f0    	push   0xf022725c
f010233e:	e8 34 f0 ff ff       	call   f0101377 <pgdir_walk>
f0102343:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102349:	83 c4 0c             	add    $0xc,%esp
f010234c:	6a 00                	push   $0x0
f010234e:	56                   	push   %esi
f010234f:	ff 35 5c 72 22 f0    	push   0xf022725c
f0102355:	e8 1d f0 ff ff       	call   f0101377 <pgdir_walk>
f010235a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102360:	c7 04 24 d1 73 10 f0 	movl   $0xf01073d1,(%esp)
f0102367:	e8 06 19 00 00       	call   f0103c72 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010236c:	a1 58 72 22 f0       	mov    0xf0227258,%eax
	if ((uint32_t)kva < KERNBASE)
f0102371:	83 c4 10             	add    $0x10,%esp
f0102374:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102379:	0f 86 e8 07 00 00    	jbe    f0102b67 <mem_init+0x1564>
f010237f:	83 ec 08             	sub    $0x8,%esp
f0102382:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102384:	05 00 00 00 10       	add    $0x10000000,%eax
f0102389:	50                   	push   %eax
f010238a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010238f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102394:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f0102399:	e8 68 f0 ff ff       	call   f0101406 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f010239e:	a1 70 72 22 f0       	mov    0xf0227270,%eax
	if ((uint32_t)kva < KERNBASE)
f01023a3:	83 c4 10             	add    $0x10,%esp
f01023a6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023ab:	0f 86 cb 07 00 00    	jbe    f0102b7c <mem_init+0x1579>
f01023b1:	83 ec 08             	sub    $0x8,%esp
f01023b4:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01023b6:	05 00 00 00 10       	add    $0x10000000,%eax
f01023bb:	50                   	push   %eax
f01023bc:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01023c1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01023c6:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f01023cb:	e8 36 f0 ff ff       	call   f0101406 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01023d0:	83 c4 10             	add    $0x10,%esp
f01023d3:	b8 00 40 12 f0       	mov    $0xf0124000,%eax
f01023d8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023dd:	0f 86 ae 07 00 00    	jbe    f0102b91 <mem_init+0x158e>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstacktop) - KSTKSIZE, PTE_W | PTE_P);
f01023e3:	83 ec 08             	sub    $0x8,%esp
f01023e6:	6a 03                	push   $0x3
f01023e8:	68 00 c0 11 00       	push   $0x11c000
f01023ed:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01023f2:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01023f7:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f01023fc:	e8 05 f0 ff ff       	call   f0101406 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, ((uint32_t)0xffffffff - KERNBASE), 0, PTE_W | PTE_P);
f0102401:	83 c4 08             	add    $0x8,%esp
f0102404:	6a 03                	push   $0x3
f0102406:	6a 00                	push   $0x0
f0102408:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010240d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102412:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f0102417:	e8 ea ef ff ff       	call   f0101406 <boot_map_region>
f010241c:	c7 45 d0 00 80 22 f0 	movl   $0xf0228000,-0x30(%ebp)
f0102423:	83 c4 10             	add    $0x10,%esp
f0102426:	bb 00 80 22 f0       	mov    $0xf0228000,%ebx
f010242b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102430:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102436:	0f 86 6a 07 00 00    	jbe    f0102ba6 <mem_init+0x15a3>
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f010243c:	83 ec 08             	sub    $0x8,%esp
f010243f:	6a 02                	push   $0x2
f0102441:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102447:	50                   	push   %eax
f0102448:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010244d:	89 f2                	mov    %esi,%edx
f010244f:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f0102454:	e8 ad ef ff ff       	call   f0101406 <boot_map_region>
	for (int i = 0; i < NCPU; i++) {
f0102459:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010245f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102465:	83 c4 10             	add    $0x10,%esp
f0102468:	81 fb 00 80 26 f0    	cmp    $0xf0268000,%ebx
f010246e:	75 c0                	jne    f0102430 <mem_init+0xe2d>
	pgdir = kern_pgdir;
f0102470:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
f0102475:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102478:	a1 60 72 22 f0       	mov    0xf0227260,%eax
f010247d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102480:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102487:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010248c:	8b 35 58 72 22 f0    	mov    0xf0227258,%esi
	return (physaddr_t)kva - KERNBASE;
f0102492:	8d 8e 00 00 00 10    	lea    0x10000000(%esi),%ecx
f0102498:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010249b:	89 fb                	mov    %edi,%ebx
f010249d:	89 7d c8             	mov    %edi,-0x38(%ebp)
f01024a0:	89 c7                	mov    %eax,%edi
f01024a2:	e9 2f 07 00 00       	jmp    f0102bd6 <mem_init+0x15d3>
	assert(nfree == 0);
f01024a7:	68 e8 72 10 f0       	push   $0xf01072e8
f01024ac:	68 21 71 10 f0       	push   $0xf0107121
f01024b1:	68 2f 03 00 00       	push   $0x32f
f01024b6:	68 fb 70 10 f0       	push   $0xf01070fb
f01024bb:	e8 80 db ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01024c0:	68 f6 71 10 f0       	push   $0xf01071f6
f01024c5:	68 21 71 10 f0       	push   $0xf0107121
f01024ca:	68 95 03 00 00       	push   $0x395
f01024cf:	68 fb 70 10 f0       	push   $0xf01070fb
f01024d4:	e8 67 db ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01024d9:	68 0c 72 10 f0       	push   $0xf010720c
f01024de:	68 21 71 10 f0       	push   $0xf0107121
f01024e3:	68 96 03 00 00       	push   $0x396
f01024e8:	68 fb 70 10 f0       	push   $0xf01070fb
f01024ed:	e8 4e db ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01024f2:	68 22 72 10 f0       	push   $0xf0107222
f01024f7:	68 21 71 10 f0       	push   $0xf0107121
f01024fc:	68 97 03 00 00       	push   $0x397
f0102501:	68 fb 70 10 f0       	push   $0xf01070fb
f0102506:	e8 35 db ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010250b:	68 38 72 10 f0       	push   $0xf0107238
f0102510:	68 21 71 10 f0       	push   $0xf0107121
f0102515:	68 9a 03 00 00       	push   $0x39a
f010251a:	68 fb 70 10 f0       	push   $0xf01070fb
f010251f:	e8 1c db ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102524:	68 b8 75 10 f0       	push   $0xf01075b8
f0102529:	68 21 71 10 f0       	push   $0xf0107121
f010252e:	68 9b 03 00 00       	push   $0x39b
f0102533:	68 fb 70 10 f0       	push   $0xf01070fb
f0102538:	e8 03 db ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010253d:	68 a1 72 10 f0       	push   $0xf01072a1
f0102542:	68 21 71 10 f0       	push   $0xf0107121
f0102547:	68 a2 03 00 00       	push   $0x3a2
f010254c:	68 fb 70 10 f0       	push   $0xf01070fb
f0102551:	e8 ea da ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102556:	68 f8 75 10 f0       	push   $0xf01075f8
f010255b:	68 21 71 10 f0       	push   $0xf0107121
f0102560:	68 a5 03 00 00       	push   $0x3a5
f0102565:	68 fb 70 10 f0       	push   $0xf01070fb
f010256a:	e8 d1 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010256f:	68 30 76 10 f0       	push   $0xf0107630
f0102574:	68 21 71 10 f0       	push   $0xf0107121
f0102579:	68 a8 03 00 00       	push   $0x3a8
f010257e:	68 fb 70 10 f0       	push   $0xf01070fb
f0102583:	e8 b8 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102588:	68 60 76 10 f0       	push   $0xf0107660
f010258d:	68 21 71 10 f0       	push   $0xf0107121
f0102592:	68 ac 03 00 00       	push   $0x3ac
f0102597:	68 fb 70 10 f0       	push   $0xf01070fb
f010259c:	e8 9f da ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025a1:	68 90 76 10 f0       	push   $0xf0107690
f01025a6:	68 21 71 10 f0       	push   $0xf0107121
f01025ab:	68 ad 03 00 00       	push   $0x3ad
f01025b0:	68 fb 70 10 f0       	push   $0xf01070fb
f01025b5:	e8 86 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01025ba:	68 b8 76 10 f0       	push   $0xf01076b8
f01025bf:	68 21 71 10 f0       	push   $0xf0107121
f01025c4:	68 ae 03 00 00       	push   $0x3ae
f01025c9:	68 fb 70 10 f0       	push   $0xf01070fb
f01025ce:	e8 6d da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025d3:	68 f3 72 10 f0       	push   $0xf01072f3
f01025d8:	68 21 71 10 f0       	push   $0xf0107121
f01025dd:	68 af 03 00 00       	push   $0x3af
f01025e2:	68 fb 70 10 f0       	push   $0xf01070fb
f01025e7:	e8 54 da ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01025ec:	68 04 73 10 f0       	push   $0xf0107304
f01025f1:	68 21 71 10 f0       	push   $0xf0107121
f01025f6:	68 b0 03 00 00       	push   $0x3b0
f01025fb:	68 fb 70 10 f0       	push   $0xf01070fb
f0102600:	e8 3b da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102605:	68 e8 76 10 f0       	push   $0xf01076e8
f010260a:	68 21 71 10 f0       	push   $0xf0107121
f010260f:	68 b3 03 00 00       	push   $0x3b3
f0102614:	68 fb 70 10 f0       	push   $0xf01070fb
f0102619:	e8 22 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010261e:	68 24 77 10 f0       	push   $0xf0107724
f0102623:	68 21 71 10 f0       	push   $0xf0107121
f0102628:	68 b4 03 00 00       	push   $0x3b4
f010262d:	68 fb 70 10 f0       	push   $0xf01070fb
f0102632:	e8 09 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102637:	68 15 73 10 f0       	push   $0xf0107315
f010263c:	68 21 71 10 f0       	push   $0xf0107121
f0102641:	68 b5 03 00 00       	push   $0x3b5
f0102646:	68 fb 70 10 f0       	push   $0xf01070fb
f010264b:	e8 f0 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102650:	68 a1 72 10 f0       	push   $0xf01072a1
f0102655:	68 21 71 10 f0       	push   $0xf0107121
f010265a:	68 b8 03 00 00       	push   $0x3b8
f010265f:	68 fb 70 10 f0       	push   $0xf01070fb
f0102664:	e8 d7 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102669:	68 e8 76 10 f0       	push   $0xf01076e8
f010266e:	68 21 71 10 f0       	push   $0xf0107121
f0102673:	68 bb 03 00 00       	push   $0x3bb
f0102678:	68 fb 70 10 f0       	push   $0xf01070fb
f010267d:	e8 be d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102682:	68 24 77 10 f0       	push   $0xf0107724
f0102687:	68 21 71 10 f0       	push   $0xf0107121
f010268c:	68 bc 03 00 00       	push   $0x3bc
f0102691:	68 fb 70 10 f0       	push   $0xf01070fb
f0102696:	e8 a5 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010269b:	68 15 73 10 f0       	push   $0xf0107315
f01026a0:	68 21 71 10 f0       	push   $0xf0107121
f01026a5:	68 bd 03 00 00       	push   $0x3bd
f01026aa:	68 fb 70 10 f0       	push   $0xf01070fb
f01026af:	e8 8c d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01026b4:	68 a1 72 10 f0       	push   $0xf01072a1
f01026b9:	68 21 71 10 f0       	push   $0xf0107121
f01026be:	68 c1 03 00 00       	push   $0x3c1
f01026c3:	68 fb 70 10 f0       	push   $0xf01070fb
f01026c8:	e8 73 d9 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026cd:	57                   	push   %edi
f01026ce:	68 04 68 10 f0       	push   $0xf0106804
f01026d3:	68 c4 03 00 00       	push   $0x3c4
f01026d8:	68 fb 70 10 f0       	push   $0xf01070fb
f01026dd:	e8 5e d9 ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01026e2:	68 54 77 10 f0       	push   $0xf0107754
f01026e7:	68 21 71 10 f0       	push   $0xf0107121
f01026ec:	68 c5 03 00 00       	push   $0x3c5
f01026f1:	68 fb 70 10 f0       	push   $0xf01070fb
f01026f6:	e8 45 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01026fb:	68 94 77 10 f0       	push   $0xf0107794
f0102700:	68 21 71 10 f0       	push   $0xf0107121
f0102705:	68 c8 03 00 00       	push   $0x3c8
f010270a:	68 fb 70 10 f0       	push   $0xf01070fb
f010270f:	e8 2c d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102714:	68 24 77 10 f0       	push   $0xf0107724
f0102719:	68 21 71 10 f0       	push   $0xf0107121
f010271e:	68 c9 03 00 00       	push   $0x3c9
f0102723:	68 fb 70 10 f0       	push   $0xf01070fb
f0102728:	e8 13 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010272d:	68 15 73 10 f0       	push   $0xf0107315
f0102732:	68 21 71 10 f0       	push   $0xf0107121
f0102737:	68 ca 03 00 00       	push   $0x3ca
f010273c:	68 fb 70 10 f0       	push   $0xf01070fb
f0102741:	e8 fa d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102746:	68 d4 77 10 f0       	push   $0xf01077d4
f010274b:	68 21 71 10 f0       	push   $0xf0107121
f0102750:	68 cb 03 00 00       	push   $0x3cb
f0102755:	68 fb 70 10 f0       	push   $0xf01070fb
f010275a:	e8 e1 d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010275f:	68 26 73 10 f0       	push   $0xf0107326
f0102764:	68 21 71 10 f0       	push   $0xf0107121
f0102769:	68 cc 03 00 00       	push   $0x3cc
f010276e:	68 fb 70 10 f0       	push   $0xf01070fb
f0102773:	e8 c8 d8 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102778:	68 e8 76 10 f0       	push   $0xf01076e8
f010277d:	68 21 71 10 f0       	push   $0xf0107121
f0102782:	68 cf 03 00 00       	push   $0x3cf
f0102787:	68 fb 70 10 f0       	push   $0xf01070fb
f010278c:	e8 af d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102791:	68 08 78 10 f0       	push   $0xf0107808
f0102796:	68 21 71 10 f0       	push   $0xf0107121
f010279b:	68 d0 03 00 00       	push   $0x3d0
f01027a0:	68 fb 70 10 f0       	push   $0xf01070fb
f01027a5:	e8 96 d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01027aa:	68 3c 78 10 f0       	push   $0xf010783c
f01027af:	68 21 71 10 f0       	push   $0xf0107121
f01027b4:	68 d1 03 00 00       	push   $0x3d1
f01027b9:	68 fb 70 10 f0       	push   $0xf01070fb
f01027be:	e8 7d d8 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01027c3:	68 74 78 10 f0       	push   $0xf0107874
f01027c8:	68 21 71 10 f0       	push   $0xf0107121
f01027cd:	68 d4 03 00 00       	push   $0x3d4
f01027d2:	68 fb 70 10 f0       	push   $0xf01070fb
f01027d7:	e8 64 d8 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01027dc:	68 ac 78 10 f0       	push   $0xf01078ac
f01027e1:	68 21 71 10 f0       	push   $0xf0107121
f01027e6:	68 d7 03 00 00       	push   $0x3d7
f01027eb:	68 fb 70 10 f0       	push   $0xf01070fb
f01027f0:	e8 4b d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01027f5:	68 3c 78 10 f0       	push   $0xf010783c
f01027fa:	68 21 71 10 f0       	push   $0xf0107121
f01027ff:	68 d8 03 00 00       	push   $0x3d8
f0102804:	68 fb 70 10 f0       	push   $0xf01070fb
f0102809:	e8 32 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010280e:	68 e8 78 10 f0       	push   $0xf01078e8
f0102813:	68 21 71 10 f0       	push   $0xf0107121
f0102818:	68 db 03 00 00       	push   $0x3db
f010281d:	68 fb 70 10 f0       	push   $0xf01070fb
f0102822:	e8 19 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102827:	68 14 79 10 f0       	push   $0xf0107914
f010282c:	68 21 71 10 f0       	push   $0xf0107121
f0102831:	68 dc 03 00 00       	push   $0x3dc
f0102836:	68 fb 70 10 f0       	push   $0xf01070fb
f010283b:	e8 00 d8 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102840:	68 3c 73 10 f0       	push   $0xf010733c
f0102845:	68 21 71 10 f0       	push   $0xf0107121
f010284a:	68 de 03 00 00       	push   $0x3de
f010284f:	68 fb 70 10 f0       	push   $0xf01070fb
f0102854:	e8 e7 d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102859:	68 4d 73 10 f0       	push   $0xf010734d
f010285e:	68 21 71 10 f0       	push   $0xf0107121
f0102863:	68 df 03 00 00       	push   $0x3df
f0102868:	68 fb 70 10 f0       	push   $0xf01070fb
f010286d:	e8 ce d7 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102872:	68 44 79 10 f0       	push   $0xf0107944
f0102877:	68 21 71 10 f0       	push   $0xf0107121
f010287c:	68 e2 03 00 00       	push   $0x3e2
f0102881:	68 fb 70 10 f0       	push   $0xf01070fb
f0102886:	e8 b5 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010288b:	68 68 79 10 f0       	push   $0xf0107968
f0102890:	68 21 71 10 f0       	push   $0xf0107121
f0102895:	68 e6 03 00 00       	push   $0x3e6
f010289a:	68 fb 70 10 f0       	push   $0xf01070fb
f010289f:	e8 9c d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01028a4:	68 14 79 10 f0       	push   $0xf0107914
f01028a9:	68 21 71 10 f0       	push   $0xf0107121
f01028ae:	68 e7 03 00 00       	push   $0x3e7
f01028b3:	68 fb 70 10 f0       	push   $0xf01070fb
f01028b8:	e8 83 d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01028bd:	68 f3 72 10 f0       	push   $0xf01072f3
f01028c2:	68 21 71 10 f0       	push   $0xf0107121
f01028c7:	68 e8 03 00 00       	push   $0x3e8
f01028cc:	68 fb 70 10 f0       	push   $0xf01070fb
f01028d1:	e8 6a d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01028d6:	68 4d 73 10 f0       	push   $0xf010734d
f01028db:	68 21 71 10 f0       	push   $0xf0107121
f01028e0:	68 e9 03 00 00       	push   $0x3e9
f01028e5:	68 fb 70 10 f0       	push   $0xf01070fb
f01028ea:	e8 51 d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01028ef:	68 8c 79 10 f0       	push   $0xf010798c
f01028f4:	68 21 71 10 f0       	push   $0xf0107121
f01028f9:	68 ec 03 00 00       	push   $0x3ec
f01028fe:	68 fb 70 10 f0       	push   $0xf01070fb
f0102903:	e8 38 d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0102908:	68 5e 73 10 f0       	push   $0xf010735e
f010290d:	68 21 71 10 f0       	push   $0xf0107121
f0102912:	68 ed 03 00 00       	push   $0x3ed
f0102917:	68 fb 70 10 f0       	push   $0xf01070fb
f010291c:	e8 1f d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102921:	68 6a 73 10 f0       	push   $0xf010736a
f0102926:	68 21 71 10 f0       	push   $0xf0107121
f010292b:	68 ee 03 00 00       	push   $0x3ee
f0102930:	68 fb 70 10 f0       	push   $0xf01070fb
f0102935:	e8 06 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010293a:	68 68 79 10 f0       	push   $0xf0107968
f010293f:	68 21 71 10 f0       	push   $0xf0107121
f0102944:	68 f2 03 00 00       	push   $0x3f2
f0102949:	68 fb 70 10 f0       	push   $0xf01070fb
f010294e:	e8 ed d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102953:	68 c4 79 10 f0       	push   $0xf01079c4
f0102958:	68 21 71 10 f0       	push   $0xf0107121
f010295d:	68 f3 03 00 00       	push   $0x3f3
f0102962:	68 fb 70 10 f0       	push   $0xf01070fb
f0102967:	e8 d4 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010296c:	68 7f 73 10 f0       	push   $0xf010737f
f0102971:	68 21 71 10 f0       	push   $0xf0107121
f0102976:	68 f4 03 00 00       	push   $0x3f4
f010297b:	68 fb 70 10 f0       	push   $0xf01070fb
f0102980:	e8 bb d6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102985:	68 4d 73 10 f0       	push   $0xf010734d
f010298a:	68 21 71 10 f0       	push   $0xf0107121
f010298f:	68 f5 03 00 00       	push   $0x3f5
f0102994:	68 fb 70 10 f0       	push   $0xf01070fb
f0102999:	e8 a2 d6 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010299e:	68 ec 79 10 f0       	push   $0xf01079ec
f01029a3:	68 21 71 10 f0       	push   $0xf0107121
f01029a8:	68 f8 03 00 00       	push   $0x3f8
f01029ad:	68 fb 70 10 f0       	push   $0xf01070fb
f01029b2:	e8 89 d6 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01029b7:	68 a1 72 10 f0       	push   $0xf01072a1
f01029bc:	68 21 71 10 f0       	push   $0xf0107121
f01029c1:	68 fb 03 00 00       	push   $0x3fb
f01029c6:	68 fb 70 10 f0       	push   $0xf01070fb
f01029cb:	e8 70 d6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01029d0:	68 90 76 10 f0       	push   $0xf0107690
f01029d5:	68 21 71 10 f0       	push   $0xf0107121
f01029da:	68 fe 03 00 00       	push   $0x3fe
f01029df:	68 fb 70 10 f0       	push   $0xf01070fb
f01029e4:	e8 57 d6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01029e9:	68 04 73 10 f0       	push   $0xf0107304
f01029ee:	68 21 71 10 f0       	push   $0xf0107121
f01029f3:	68 00 04 00 00       	push   $0x400
f01029f8:	68 fb 70 10 f0       	push   $0xf01070fb
f01029fd:	e8 3e d6 ff ff       	call   f0100040 <_panic>
f0102a02:	57                   	push   %edi
f0102a03:	68 04 68 10 f0       	push   $0xf0106804
f0102a08:	68 07 04 00 00       	push   $0x407
f0102a0d:	68 fb 70 10 f0       	push   $0xf01070fb
f0102a12:	e8 29 d6 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102a17:	68 90 73 10 f0       	push   $0xf0107390
f0102a1c:	68 21 71 10 f0       	push   $0xf0107121
f0102a21:	68 08 04 00 00       	push   $0x408
f0102a26:	68 fb 70 10 f0       	push   $0xf01070fb
f0102a2b:	e8 10 d6 ff ff       	call   f0100040 <_panic>
f0102a30:	51                   	push   %ecx
f0102a31:	68 04 68 10 f0       	push   $0xf0106804
f0102a36:	6a 58                	push   $0x58
f0102a38:	68 07 71 10 f0       	push   $0xf0107107
f0102a3d:	e8 fe d5 ff ff       	call   f0100040 <_panic>
f0102a42:	52                   	push   %edx
f0102a43:	68 04 68 10 f0       	push   $0xf0106804
f0102a48:	6a 58                	push   $0x58
f0102a4a:	68 07 71 10 f0       	push   $0xf0107107
f0102a4f:	e8 ec d5 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102a54:	68 a8 73 10 f0       	push   $0xf01073a8
f0102a59:	68 21 71 10 f0       	push   $0xf0107121
f0102a5e:	68 12 04 00 00       	push   $0x412
f0102a63:	68 fb 70 10 f0       	push   $0xf01070fb
f0102a68:	e8 d3 d5 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102a6d:	68 10 7a 10 f0       	push   $0xf0107a10
f0102a72:	68 21 71 10 f0       	push   $0xf0107121
f0102a77:	68 22 04 00 00       	push   $0x422
f0102a7c:	68 fb 70 10 f0       	push   $0xf01070fb
f0102a81:	e8 ba d5 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102a86:	68 38 7a 10 f0       	push   $0xf0107a38
f0102a8b:	68 21 71 10 f0       	push   $0xf0107121
f0102a90:	68 23 04 00 00       	push   $0x423
f0102a95:	68 fb 70 10 f0       	push   $0xf01070fb
f0102a9a:	e8 a1 d5 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102a9f:	68 60 7a 10 f0       	push   $0xf0107a60
f0102aa4:	68 21 71 10 f0       	push   $0xf0107121
f0102aa9:	68 25 04 00 00       	push   $0x425
f0102aae:	68 fb 70 10 f0       	push   $0xf01070fb
f0102ab3:	e8 88 d5 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102ab8:	68 bf 73 10 f0       	push   $0xf01073bf
f0102abd:	68 21 71 10 f0       	push   $0xf0107121
f0102ac2:	68 27 04 00 00       	push   $0x427
f0102ac7:	68 fb 70 10 f0       	push   $0xf01070fb
f0102acc:	e8 6f d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102ad1:	68 88 7a 10 f0       	push   $0xf0107a88
f0102ad6:	68 21 71 10 f0       	push   $0xf0107121
f0102adb:	68 29 04 00 00       	push   $0x429
f0102ae0:	68 fb 70 10 f0       	push   $0xf01070fb
f0102ae5:	e8 56 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102aea:	68 ac 7a 10 f0       	push   $0xf0107aac
f0102aef:	68 21 71 10 f0       	push   $0xf0107121
f0102af4:	68 2a 04 00 00       	push   $0x42a
f0102af9:	68 fb 70 10 f0       	push   $0xf01070fb
f0102afe:	e8 3d d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102b03:	68 dc 7a 10 f0       	push   $0xf0107adc
f0102b08:	68 21 71 10 f0       	push   $0xf0107121
f0102b0d:	68 2b 04 00 00       	push   $0x42b
f0102b12:	68 fb 70 10 f0       	push   $0xf01070fb
f0102b17:	e8 24 d5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102b1c:	68 00 7b 10 f0       	push   $0xf0107b00
f0102b21:	68 21 71 10 f0       	push   $0xf0107121
f0102b26:	68 2c 04 00 00       	push   $0x42c
f0102b2b:	68 fb 70 10 f0       	push   $0xf01070fb
f0102b30:	e8 0b d5 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102b35:	68 2c 7b 10 f0       	push   $0xf0107b2c
f0102b3a:	68 21 71 10 f0       	push   $0xf0107121
f0102b3f:	68 2e 04 00 00       	push   $0x42e
f0102b44:	68 fb 70 10 f0       	push   $0xf01070fb
f0102b49:	e8 f2 d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102b4e:	68 70 7b 10 f0       	push   $0xf0107b70
f0102b53:	68 21 71 10 f0       	push   $0xf0107121
f0102b58:	68 2f 04 00 00       	push   $0x42f
f0102b5d:	68 fb 70 10 f0       	push   $0xf01070fb
f0102b62:	e8 d9 d4 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b67:	50                   	push   %eax
f0102b68:	68 28 68 10 f0       	push   $0xf0106828
f0102b6d:	68 c5 00 00 00       	push   $0xc5
f0102b72:	68 fb 70 10 f0       	push   $0xf01070fb
f0102b77:	e8 c4 d4 ff ff       	call   f0100040 <_panic>
f0102b7c:	50                   	push   %eax
f0102b7d:	68 28 68 10 f0       	push   $0xf0106828
f0102b82:	68 ce 00 00 00       	push   $0xce
f0102b87:	68 fb 70 10 f0       	push   $0xf01070fb
f0102b8c:	e8 af d4 ff ff       	call   f0100040 <_panic>
f0102b91:	50                   	push   %eax
f0102b92:	68 28 68 10 f0       	push   $0xf0106828
f0102b97:	68 db 00 00 00       	push   $0xdb
f0102b9c:	68 fb 70 10 f0       	push   $0xf01070fb
f0102ba1:	e8 9a d4 ff ff       	call   f0100040 <_panic>
f0102ba6:	53                   	push   %ebx
f0102ba7:	68 28 68 10 f0       	push   $0xf0106828
f0102bac:	68 1b 01 00 00       	push   $0x11b
f0102bb1:	68 fb 70 10 f0       	push   $0xf01070fb
f0102bb6:	e8 85 d4 ff ff       	call   f0100040 <_panic>
f0102bbb:	56                   	push   %esi
f0102bbc:	68 28 68 10 f0       	push   $0xf0106828
f0102bc1:	68 47 03 00 00       	push   $0x347
f0102bc6:	68 fb 70 10 f0       	push   $0xf01070fb
f0102bcb:	e8 70 d4 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f0102bd0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bd6:	39 df                	cmp    %ebx,%edi
f0102bd8:	76 39                	jbe    f0102c13 <mem_init+0x1610>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102bda:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102be0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102be3:	e8 ae e2 ff ff       	call   f0100e96 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102be8:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102bee:	76 cb                	jbe    f0102bbb <mem_init+0x15b8>
f0102bf0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102bf3:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102bf6:	39 d0                	cmp    %edx,%eax
f0102bf8:	74 d6                	je     f0102bd0 <mem_init+0x15cd>
f0102bfa:	68 a4 7b 10 f0       	push   $0xf0107ba4
f0102bff:	68 21 71 10 f0       	push   $0xf0107121
f0102c04:	68 47 03 00 00       	push   $0x347
f0102c09:	68 fb 70 10 f0       	push   $0xf01070fb
f0102c0e:	e8 2d d4 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102c13:	8b 35 70 72 22 f0    	mov    0xf0227270,%esi
f0102c19:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102c1e:	8d 86 00 00 40 21    	lea    0x21400000(%esi),%eax
f0102c24:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102c27:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102c2a:	89 da                	mov    %ebx,%edx
f0102c2c:	89 f8                	mov    %edi,%eax
f0102c2e:	e8 63 e2 ff ff       	call   f0100e96 <check_va2pa>
f0102c33:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102c39:	76 46                	jbe    f0102c81 <mem_init+0x167e>
f0102c3b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102c3e:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102c41:	39 d0                	cmp    %edx,%eax
f0102c43:	75 51                	jne    f0102c96 <mem_init+0x1693>
	for (i = 0; i < n; i += PGSIZE)
f0102c45:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c4b:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102c51:	75 d7                	jne    f0102c2a <mem_init+0x1627>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c53:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102c56:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102c59:	c1 e6 0c             	shl    $0xc,%esi
f0102c5c:	89 fb                	mov    %edi,%ebx
f0102c5e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0102c61:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102c64:	39 f3                	cmp    %esi,%ebx
f0102c66:	73 60                	jae    f0102cc8 <mem_init+0x16c5>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102c68:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102c6e:	89 f8                	mov    %edi,%eax
f0102c70:	e8 21 e2 ff ff       	call   f0100e96 <check_va2pa>
f0102c75:	39 c3                	cmp    %eax,%ebx
f0102c77:	75 36                	jne    f0102caf <mem_init+0x16ac>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102c79:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c7f:	eb e3                	jmp    f0102c64 <mem_init+0x1661>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c81:	56                   	push   %esi
f0102c82:	68 28 68 10 f0       	push   $0xf0106828
f0102c87:	68 4c 03 00 00       	push   $0x34c
f0102c8c:	68 fb 70 10 f0       	push   $0xf01070fb
f0102c91:	e8 aa d3 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102c96:	68 d8 7b 10 f0       	push   $0xf0107bd8
f0102c9b:	68 21 71 10 f0       	push   $0xf0107121
f0102ca0:	68 4c 03 00 00       	push   $0x34c
f0102ca5:	68 fb 70 10 f0       	push   $0xf01070fb
f0102caa:	e8 91 d3 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102caf:	68 0c 7c 10 f0       	push   $0xf0107c0c
f0102cb4:	68 21 71 10 f0       	push   $0xf0107121
f0102cb9:	68 50 03 00 00       	push   $0x350
f0102cbe:	68 fb 70 10 f0       	push   $0xf01070fb
f0102cc3:	e8 78 d3 ff ff       	call   f0100040 <_panic>
f0102cc8:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102ccb:	c7 45 c0 00 80 23 00 	movl   $0x238000,-0x40(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102cd2:	c7 45 c4 00 00 00 f0 	movl   $0xf0000000,-0x3c(%ebp)
f0102cd9:	c7 45 c8 00 80 ff ef 	movl   $0xefff8000,-0x38(%ebp)
f0102ce0:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0102ce3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102ce6:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0102ce9:	8d b3 00 80 ff ff    	lea    -0x8000(%ebx),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102cef:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102cf2:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0102cf5:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0102cf8:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f0102cfd:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102d00:	89 75 bc             	mov    %esi,-0x44(%ebp)
f0102d03:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102d06:	89 da                	mov    %ebx,%edx
f0102d08:	89 f8                	mov    %edi,%eax
f0102d0a:	e8 87 e1 ff ff       	call   f0100e96 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102d0f:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102d16:	76 67                	jbe    f0102d7f <mem_init+0x177c>
f0102d18:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d1b:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102d1e:	39 d0                	cmp    %edx,%eax
f0102d20:	75 74                	jne    f0102d96 <mem_init+0x1793>
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102d22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d28:	39 f3                	cmp    %esi,%ebx
f0102d2a:	75 da                	jne    f0102d06 <mem_init+0x1703>
f0102d2c:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0102d2f:	8b 5d c8             	mov    -0x38(%ebp),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102d32:	89 f2                	mov    %esi,%edx
f0102d34:	89 f8                	mov    %edi,%eax
f0102d36:	e8 5b e1 ff ff       	call   f0100e96 <check_va2pa>
f0102d3b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102d3e:	75 6f                	jne    f0102daf <mem_init+0x17ac>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102d40:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d46:	39 de                	cmp    %ebx,%esi
f0102d48:	75 e8                	jne    f0102d32 <mem_init+0x172f>
	for (n = 0; n < NCPU; n++) {
f0102d4a:	89 d8                	mov    %ebx,%eax
f0102d4c:	2d 00 00 01 00       	sub    $0x10000,%eax
f0102d51:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102d54:	81 6d c4 00 00 01 00 	subl   $0x10000,-0x3c(%ebp)
f0102d5b:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102d62:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102d65:	81 45 c0 00 80 01 00 	addl   $0x18000,-0x40(%ebp)
f0102d6c:	3d 00 80 26 f0       	cmp    $0xf0268000,%eax
f0102d71:	0f 85 6f ff ff ff    	jne    f0102ce6 <mem_init+0x16e3>
f0102d77:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0102d7a:	e9 84 00 00 00       	jmp    f0102e03 <mem_init+0x1800>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d7f:	ff 75 b8             	push   -0x48(%ebp)
f0102d82:	68 28 68 10 f0       	push   $0xf0106828
f0102d87:	68 58 03 00 00       	push   $0x358
f0102d8c:	68 fb 70 10 f0       	push   $0xf01070fb
f0102d91:	e8 aa d2 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102d96:	68 34 7c 10 f0       	push   $0xf0107c34
f0102d9b:	68 21 71 10 f0       	push   $0xf0107121
f0102da0:	68 57 03 00 00       	push   $0x357
f0102da5:	68 fb 70 10 f0       	push   $0xf01070fb
f0102daa:	e8 91 d2 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102daf:	68 7c 7c 10 f0       	push   $0xf0107c7c
f0102db4:	68 21 71 10 f0       	push   $0xf0107121
f0102db9:	68 5a 03 00 00       	push   $0x35a
f0102dbe:	68 fb 70 10 f0       	push   $0xf01070fb
f0102dc3:	e8 78 d2 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102dc8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dcb:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102dcf:	75 4e                	jne    f0102e1f <mem_init+0x181c>
f0102dd1:	68 ea 73 10 f0       	push   $0xf01073ea
f0102dd6:	68 21 71 10 f0       	push   $0xf0107121
f0102ddb:	68 65 03 00 00       	push   $0x365
f0102de0:	68 fb 70 10 f0       	push   $0xf01070fb
f0102de5:	e8 56 d2 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102dea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ded:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102df0:	a8 01                	test   $0x1,%al
f0102df2:	74 30                	je     f0102e24 <mem_init+0x1821>
				assert(pgdir[i] & PTE_W);
f0102df4:	a8 02                	test   $0x2,%al
f0102df6:	74 45                	je     f0102e3d <mem_init+0x183a>
	for (i = 0; i < NPDENTRIES; i++) {
f0102df8:	83 c7 01             	add    $0x1,%edi
f0102dfb:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102e01:	74 6c                	je     f0102e6f <mem_init+0x186c>
		switch (i) {
f0102e03:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102e09:	83 f8 04             	cmp    $0x4,%eax
f0102e0c:	76 ba                	jbe    f0102dc8 <mem_init+0x17c5>
			if (i >= PDX(KERNBASE)) {
f0102e0e:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102e14:	77 d4                	ja     f0102dea <mem_init+0x17e7>
				assert(pgdir[i] == 0);
f0102e16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e19:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102e1d:	75 37                	jne    f0102e56 <mem_init+0x1853>
	for (i = 0; i < NPDENTRIES; i++) {
f0102e1f:	83 c7 01             	add    $0x1,%edi
f0102e22:	eb df                	jmp    f0102e03 <mem_init+0x1800>
				assert(pgdir[i] & PTE_P);
f0102e24:	68 ea 73 10 f0       	push   $0xf01073ea
f0102e29:	68 21 71 10 f0       	push   $0xf0107121
f0102e2e:	68 69 03 00 00       	push   $0x369
f0102e33:	68 fb 70 10 f0       	push   $0xf01070fb
f0102e38:	e8 03 d2 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102e3d:	68 fb 73 10 f0       	push   $0xf01073fb
f0102e42:	68 21 71 10 f0       	push   $0xf0107121
f0102e47:	68 6a 03 00 00       	push   $0x36a
f0102e4c:	68 fb 70 10 f0       	push   $0xf01070fb
f0102e51:	e8 ea d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102e56:	68 0c 74 10 f0       	push   $0xf010740c
f0102e5b:	68 21 71 10 f0       	push   $0xf0107121
f0102e60:	68 6c 03 00 00       	push   $0x36c
f0102e65:	68 fb 70 10 f0       	push   $0xf01070fb
f0102e6a:	e8 d1 d1 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102e6f:	83 ec 0c             	sub    $0xc,%esp
f0102e72:	68 a0 7c 10 f0       	push   $0xf0107ca0
f0102e77:	e8 f6 0d 00 00       	call   f0103c72 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102e7c:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102e81:	83 c4 10             	add    $0x10,%esp
f0102e84:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e89:	0f 86 03 02 00 00    	jbe    f0103092 <mem_init+0x1a8f>
	return (physaddr_t)kva - KERNBASE;
f0102e8f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102e94:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102e97:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e9c:	e8 58 e0 ff ff       	call   f0100ef9 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102ea1:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102ea4:	83 e0 f3             	and    $0xfffffff3,%eax
f0102ea7:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102eac:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102eaf:	83 ec 0c             	sub    $0xc,%esp
f0102eb2:	6a 00                	push   $0x0
f0102eb4:	e8 e5 e3 ff ff       	call   f010129e <page_alloc>
f0102eb9:	89 c3                	mov    %eax,%ebx
f0102ebb:	83 c4 10             	add    $0x10,%esp
f0102ebe:	85 c0                	test   %eax,%eax
f0102ec0:	0f 84 e1 01 00 00    	je     f01030a7 <mem_init+0x1aa4>
	assert((pp1 = page_alloc(0)));
f0102ec6:	83 ec 0c             	sub    $0xc,%esp
f0102ec9:	6a 00                	push   $0x0
f0102ecb:	e8 ce e3 ff ff       	call   f010129e <page_alloc>
f0102ed0:	89 c7                	mov    %eax,%edi
f0102ed2:	83 c4 10             	add    $0x10,%esp
f0102ed5:	85 c0                	test   %eax,%eax
f0102ed7:	0f 84 e3 01 00 00    	je     f01030c0 <mem_init+0x1abd>
	assert((pp2 = page_alloc(0)));
f0102edd:	83 ec 0c             	sub    $0xc,%esp
f0102ee0:	6a 00                	push   $0x0
f0102ee2:	e8 b7 e3 ff ff       	call   f010129e <page_alloc>
f0102ee7:	89 c6                	mov    %eax,%esi
f0102ee9:	83 c4 10             	add    $0x10,%esp
f0102eec:	85 c0                	test   %eax,%eax
f0102eee:	0f 84 e5 01 00 00    	je     f01030d9 <mem_init+0x1ad6>
	page_free(pp0);
f0102ef4:	83 ec 0c             	sub    $0xc,%esp
f0102ef7:	53                   	push   %ebx
f0102ef8:	e8 16 e4 ff ff       	call   f0101313 <page_free>
	return (pp - pages) << PGSHIFT;
f0102efd:	89 f8                	mov    %edi,%eax
f0102eff:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0102f05:	c1 f8 03             	sar    $0x3,%eax
f0102f08:	89 c2                	mov    %eax,%edx
f0102f0a:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102f0d:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102f12:	83 c4 10             	add    $0x10,%esp
f0102f15:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f0102f1b:	0f 83 d1 01 00 00    	jae    f01030f2 <mem_init+0x1aef>
	memset(page2kva(pp1), 1, PGSIZE);
f0102f21:	83 ec 04             	sub    $0x4,%esp
f0102f24:	68 00 10 00 00       	push   $0x1000
f0102f29:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102f2b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102f31:	52                   	push   %edx
f0102f32:	e8 6e 2c 00 00       	call   f0105ba5 <memset>
	return (pp - pages) << PGSHIFT;
f0102f37:	89 f0                	mov    %esi,%eax
f0102f39:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0102f3f:	c1 f8 03             	sar    $0x3,%eax
f0102f42:	89 c2                	mov    %eax,%edx
f0102f44:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102f47:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102f4c:	83 c4 10             	add    $0x10,%esp
f0102f4f:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f0102f55:	0f 83 a9 01 00 00    	jae    f0103104 <mem_init+0x1b01>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f5b:	83 ec 04             	sub    $0x4,%esp
f0102f5e:	68 00 10 00 00       	push   $0x1000
f0102f63:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102f65:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102f6b:	52                   	push   %edx
f0102f6c:	e8 34 2c 00 00       	call   f0105ba5 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102f71:	6a 02                	push   $0x2
f0102f73:	68 00 10 00 00       	push   $0x1000
f0102f78:	57                   	push   %edi
f0102f79:	ff 35 5c 72 22 f0    	push   0xf022725c
f0102f7f:	e8 b6 e5 ff ff       	call   f010153a <page_insert>
	assert(pp1->pp_ref == 1);
f0102f84:	83 c4 20             	add    $0x20,%esp
f0102f87:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102f8c:	0f 85 84 01 00 00    	jne    f0103116 <mem_init+0x1b13>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102f92:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102f99:	01 01 01 
f0102f9c:	0f 85 8d 01 00 00    	jne    f010312f <mem_init+0x1b2c>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102fa2:	6a 02                	push   $0x2
f0102fa4:	68 00 10 00 00       	push   $0x1000
f0102fa9:	56                   	push   %esi
f0102faa:	ff 35 5c 72 22 f0    	push   0xf022725c
f0102fb0:	e8 85 e5 ff ff       	call   f010153a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102fb5:	83 c4 10             	add    $0x10,%esp
f0102fb8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102fbf:	02 02 02 
f0102fc2:	0f 85 80 01 00 00    	jne    f0103148 <mem_init+0x1b45>
	assert(pp2->pp_ref == 1);
f0102fc8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102fcd:	0f 85 8e 01 00 00    	jne    f0103161 <mem_init+0x1b5e>
	assert(pp1->pp_ref == 0);
f0102fd3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102fd8:	0f 85 9c 01 00 00    	jne    f010317a <mem_init+0x1b77>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102fde:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102fe5:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102fe8:	89 f0                	mov    %esi,%eax
f0102fea:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0102ff0:	c1 f8 03             	sar    $0x3,%eax
f0102ff3:	89 c2                	mov    %eax,%edx
f0102ff5:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ff8:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102ffd:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f0103003:	0f 83 8a 01 00 00    	jae    f0103193 <mem_init+0x1b90>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103009:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0103010:	03 03 03 
f0103013:	0f 85 8c 01 00 00    	jne    f01031a5 <mem_init+0x1ba2>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103019:	83 ec 08             	sub    $0x8,%esp
f010301c:	68 00 10 00 00       	push   $0x1000
f0103021:	ff 35 5c 72 22 f0    	push   0xf022725c
f0103027:	e8 ba e4 ff ff       	call   f01014e6 <page_remove>
	assert(pp2->pp_ref == 0);
f010302c:	83 c4 10             	add    $0x10,%esp
f010302f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103034:	0f 85 84 01 00 00    	jne    f01031be <mem_init+0x1bbb>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010303a:	8b 0d 5c 72 22 f0    	mov    0xf022725c,%ecx
f0103040:	8b 11                	mov    (%ecx),%edx
f0103042:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0103048:	89 d8                	mov    %ebx,%eax
f010304a:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f0103050:	c1 f8 03             	sar    $0x3,%eax
f0103053:	c1 e0 0c             	shl    $0xc,%eax
f0103056:	39 c2                	cmp    %eax,%edx
f0103058:	0f 85 79 01 00 00    	jne    f01031d7 <mem_init+0x1bd4>
	kern_pgdir[0] = 0;
f010305e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0103064:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103069:	0f 85 81 01 00 00    	jne    f01031f0 <mem_init+0x1bed>
	pp0->pp_ref = 0;
f010306f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103075:	83 ec 0c             	sub    $0xc,%esp
f0103078:	53                   	push   %ebx
f0103079:	e8 95 e2 ff ff       	call   f0101313 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010307e:	c7 04 24 34 7d 10 f0 	movl   $0xf0107d34,(%esp)
f0103085:	e8 e8 0b 00 00       	call   f0103c72 <cprintf>
}
f010308a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010308d:	5b                   	pop    %ebx
f010308e:	5e                   	pop    %esi
f010308f:	5f                   	pop    %edi
f0103090:	5d                   	pop    %ebp
f0103091:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103092:	50                   	push   %eax
f0103093:	68 28 68 10 f0       	push   $0xf0106828
f0103098:	68 f4 00 00 00       	push   $0xf4
f010309d:	68 fb 70 10 f0       	push   $0xf01070fb
f01030a2:	e8 99 cf ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01030a7:	68 f6 71 10 f0       	push   $0xf01071f6
f01030ac:	68 21 71 10 f0       	push   $0xf0107121
f01030b1:	68 44 04 00 00       	push   $0x444
f01030b6:	68 fb 70 10 f0       	push   $0xf01070fb
f01030bb:	e8 80 cf ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01030c0:	68 0c 72 10 f0       	push   $0xf010720c
f01030c5:	68 21 71 10 f0       	push   $0xf0107121
f01030ca:	68 45 04 00 00       	push   $0x445
f01030cf:	68 fb 70 10 f0       	push   $0xf01070fb
f01030d4:	e8 67 cf ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01030d9:	68 22 72 10 f0       	push   $0xf0107222
f01030de:	68 21 71 10 f0       	push   $0xf0107121
f01030e3:	68 46 04 00 00       	push   $0x446
f01030e8:	68 fb 70 10 f0       	push   $0xf01070fb
f01030ed:	e8 4e cf ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030f2:	52                   	push   %edx
f01030f3:	68 04 68 10 f0       	push   $0xf0106804
f01030f8:	6a 58                	push   $0x58
f01030fa:	68 07 71 10 f0       	push   $0xf0107107
f01030ff:	e8 3c cf ff ff       	call   f0100040 <_panic>
f0103104:	52                   	push   %edx
f0103105:	68 04 68 10 f0       	push   $0xf0106804
f010310a:	6a 58                	push   $0x58
f010310c:	68 07 71 10 f0       	push   $0xf0107107
f0103111:	e8 2a cf ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0103116:	68 f3 72 10 f0       	push   $0xf01072f3
f010311b:	68 21 71 10 f0       	push   $0xf0107121
f0103120:	68 4b 04 00 00       	push   $0x44b
f0103125:	68 fb 70 10 f0       	push   $0xf01070fb
f010312a:	e8 11 cf ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010312f:	68 c0 7c 10 f0       	push   $0xf0107cc0
f0103134:	68 21 71 10 f0       	push   $0xf0107121
f0103139:	68 4c 04 00 00       	push   $0x44c
f010313e:	68 fb 70 10 f0       	push   $0xf01070fb
f0103143:	e8 f8 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103148:	68 e4 7c 10 f0       	push   $0xf0107ce4
f010314d:	68 21 71 10 f0       	push   $0xf0107121
f0103152:	68 4e 04 00 00       	push   $0x44e
f0103157:	68 fb 70 10 f0       	push   $0xf01070fb
f010315c:	e8 df ce ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103161:	68 15 73 10 f0       	push   $0xf0107315
f0103166:	68 21 71 10 f0       	push   $0xf0107121
f010316b:	68 4f 04 00 00       	push   $0x44f
f0103170:	68 fb 70 10 f0       	push   $0xf01070fb
f0103175:	e8 c6 ce ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010317a:	68 7f 73 10 f0       	push   $0xf010737f
f010317f:	68 21 71 10 f0       	push   $0xf0107121
f0103184:	68 50 04 00 00       	push   $0x450
f0103189:	68 fb 70 10 f0       	push   $0xf01070fb
f010318e:	e8 ad ce ff ff       	call   f0100040 <_panic>
f0103193:	52                   	push   %edx
f0103194:	68 04 68 10 f0       	push   $0xf0106804
f0103199:	6a 58                	push   $0x58
f010319b:	68 07 71 10 f0       	push   $0xf0107107
f01031a0:	e8 9b ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01031a5:	68 08 7d 10 f0       	push   $0xf0107d08
f01031aa:	68 21 71 10 f0       	push   $0xf0107121
f01031af:	68 52 04 00 00       	push   $0x452
f01031b4:	68 fb 70 10 f0       	push   $0xf01070fb
f01031b9:	e8 82 ce ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01031be:	68 4d 73 10 f0       	push   $0xf010734d
f01031c3:	68 21 71 10 f0       	push   $0xf0107121
f01031c8:	68 54 04 00 00       	push   $0x454
f01031cd:	68 fb 70 10 f0       	push   $0xf01070fb
f01031d2:	e8 69 ce ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01031d7:	68 90 76 10 f0       	push   $0xf0107690
f01031dc:	68 21 71 10 f0       	push   $0xf0107121
f01031e1:	68 57 04 00 00       	push   $0x457
f01031e6:	68 fb 70 10 f0       	push   $0xf01070fb
f01031eb:	e8 50 ce ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01031f0:	68 04 73 10 f0       	push   $0xf0107304
f01031f5:	68 21 71 10 f0       	push   $0xf0107121
f01031fa:	68 59 04 00 00       	push   $0x459
f01031ff:	68 fb 70 10 f0       	push   $0xf01070fb
f0103204:	e8 37 ce ff ff       	call   f0100040 <_panic>

f0103209 <user_mem_check>:
{
f0103209:	55                   	push   %ebp
f010320a:	89 e5                	mov    %esp,%ebp
f010320c:	57                   	push   %edi
f010320d:	56                   	push   %esi
f010320e:	53                   	push   %ebx
f010320f:	83 ec 0c             	sub    $0xc,%esp
f0103212:	8b 55 10             	mov    0x10(%ebp),%edx
		return 0;
f0103215:	b8 00 00 00 00       	mov    $0x0,%eax
	if (len == 0) {
f010321a:	85 d2                	test   %edx,%edx
f010321c:	74 7c                	je     f010329a <user_mem_check+0x91>
	uintptr_t vstart = ROUNDDOWN((uintptr_t)va, PGSIZE);
f010321e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103221:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t vend = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0103227:	8b 45 0c             	mov    0xc(%ebp),%eax
f010322a:	8d bc 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edi
f0103231:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (vend > ULIM) {
f0103237:	81 ff 00 00 80 ef    	cmp    $0xef800000,%edi
f010323d:	77 32                	ja     f0103271 <user_mem_check+0x68>
	perm |= PTE_P;
f010323f:	8b 75 14             	mov    0x14(%ebp),%esi
f0103242:	83 ce 01             	or     $0x1,%esi
	for (; vstart < vend; vstart += PGSIZE) {
f0103245:	39 fb                	cmp    %edi,%ebx
f0103247:	73 59                	jae    f01032a2 <user_mem_check+0x99>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)vstart, 0);
f0103249:	83 ec 04             	sub    $0x4,%esp
f010324c:	6a 00                	push   $0x0
f010324e:	53                   	push   %ebx
f010324f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103252:	ff 70 60             	push   0x60(%eax)
f0103255:	e8 1d e1 ff ff       	call   f0101377 <pgdir_walk>
		if ((!pte) || (((*pte) & perm) != perm)) {
f010325a:	83 c4 10             	add    $0x10,%esp
f010325d:	85 c0                	test   %eax,%eax
f010325f:	74 26                	je     f0103287 <user_mem_check+0x7e>
f0103261:	89 f1                	mov    %esi,%ecx
f0103263:	23 08                	and    (%eax),%ecx
f0103265:	39 ce                	cmp    %ecx,%esi
f0103267:	75 1e                	jne    f0103287 <user_mem_check+0x7e>
	for (; vstart < vend; vstart += PGSIZE) {
f0103269:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010326f:	eb d4                	jmp    f0103245 <user_mem_check+0x3c>
		user_mem_check_addr = MAX(vstart, ULIM);
f0103271:	b8 00 00 80 ef       	mov    $0xef800000,%eax
f0103276:	39 c3                	cmp    %eax,%ebx
f0103278:	0f 43 c3             	cmovae %ebx,%eax
f010327b:	a3 68 72 22 f0       	mov    %eax,0xf0227268
		return -E_FAULT;
f0103280:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103285:	eb 13                	jmp    f010329a <user_mem_check+0x91>
			user_mem_check_addr = MAX(vstart, (uintptr_t)va);
f0103287:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f010328a:	89 d8                	mov    %ebx,%eax
f010328c:	0f 43 45 0c          	cmovae 0xc(%ebp),%eax
f0103290:	a3 68 72 22 f0       	mov    %eax,0xf0227268
			return -E_FAULT;
f0103295:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f010329a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010329d:	5b                   	pop    %ebx
f010329e:	5e                   	pop    %esi
f010329f:	5f                   	pop    %edi
f01032a0:	5d                   	pop    %ebp
f01032a1:	c3                   	ret    
	return 0;
f01032a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01032a7:	eb f1                	jmp    f010329a <user_mem_check+0x91>

f01032a9 <user_mem_assert>:
{
f01032a9:	55                   	push   %ebp
f01032aa:	89 e5                	mov    %esp,%ebp
f01032ac:	53                   	push   %ebx
f01032ad:	83 ec 04             	sub    $0x4,%esp
f01032b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01032b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01032b6:	83 c8 04             	or     $0x4,%eax
f01032b9:	50                   	push   %eax
f01032ba:	ff 75 10             	push   0x10(%ebp)
f01032bd:	ff 75 0c             	push   0xc(%ebp)
f01032c0:	53                   	push   %ebx
f01032c1:	e8 43 ff ff ff       	call   f0103209 <user_mem_check>
f01032c6:	83 c4 10             	add    $0x10,%esp
f01032c9:	85 c0                	test   %eax,%eax
f01032cb:	78 05                	js     f01032d2 <user_mem_assert+0x29>
}
f01032cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032d0:	c9                   	leave  
f01032d1:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01032d2:	83 ec 04             	sub    $0x4,%esp
f01032d5:	ff 35 68 72 22 f0    	push   0xf0227268
f01032db:	ff 73 48             	push   0x48(%ebx)
f01032de:	68 60 7d 10 f0       	push   $0xf0107d60
f01032e3:	e8 8a 09 00 00       	call   f0103c72 <cprintf>
		env_destroy(env);	// may not return
f01032e8:	89 1c 24             	mov    %ebx,(%esp)
f01032eb:	e8 72 06 00 00       	call   f0103962 <env_destroy>
f01032f0:	83 c4 10             	add    $0x10,%esp
}
f01032f3:	eb d8                	jmp    f01032cd <user_mem_assert+0x24>

f01032f5 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01032f5:	55                   	push   %ebp
f01032f6:	89 e5                	mov    %esp,%ebp
f01032f8:	57                   	push   %edi
f01032f9:	56                   	push   %esi
f01032fa:	53                   	push   %ebx
f01032fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	if (e == NULL) {
f01032fe:	85 c0                	test   %eax,%eax
f0103300:	74 3a                	je     f010333c <region_alloc+0x47>
f0103302:	89 c6                	mov    %eax,%esi
		panic("region_alloc: e is NULL\n");
	}
	if (!len) {
f0103304:	85 c9                	test   %ecx,%ecx
f0103306:	0f 84 a3 00 00 00    	je     f01033af <region_alloc+0xba>
		return;
	}
	uintptr_t vstart = ROUNDDOWN((uintptr_t)va, PGSIZE);
f010330c:	89 d3                	mov    %edx,%ebx
f010330e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t vend = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0103314:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f010331b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	if (vstart > vend) {
f0103321:	39 fb                	cmp    %edi,%ebx
f0103323:	76 4b                	jbe    f0103370 <region_alloc+0x7b>
		panic("region_alloc: invalid va and len");
f0103325:	83 ec 04             	sub    $0x4,%esp
f0103328:	68 00 7e 10 f0       	push   $0xf0107e00
f010332d:	68 2c 01 00 00       	push   $0x12c
f0103332:	68 ae 7d 10 f0       	push   $0xf0107dae
f0103337:	e8 04 cd ff ff       	call   f0100040 <_panic>
		panic("region_alloc: e is NULL\n");
f010333c:	83 ec 04             	sub    $0x4,%esp
f010333f:	68 95 7d 10 f0       	push   $0xf0107d95
f0103344:	68 24 01 00 00       	push   $0x124
f0103349:	68 ae 7d 10 f0       	push   $0xf0107dae
f010334e:	e8 ed cc ff ff       	call   f0100040 <_panic>
	}
	for (; vstart < vend; vstart += PGSIZE) {
		struct PageInfo *pp = page_alloc(ALLOC_ZERO);
		if (!pp) {
			panic("region_alloc: page_alloc failed");
f0103353:	83 ec 04             	sub    $0x4,%esp
f0103356:	68 24 7e 10 f0       	push   $0xf0107e24
f010335b:	68 31 01 00 00       	push   $0x131
f0103360:	68 ae 7d 10 f0       	push   $0xf0107dae
f0103365:	e8 d6 cc ff ff       	call   f0100040 <_panic>
	for (; vstart < vend; vstart += PGSIZE) {
f010336a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103370:	39 fb                	cmp    %edi,%ebx
f0103372:	73 3b                	jae    f01033af <region_alloc+0xba>
		struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0103374:	83 ec 0c             	sub    $0xc,%esp
f0103377:	6a 01                	push   $0x1
f0103379:	e8 20 df ff ff       	call   f010129e <page_alloc>
		if (!pp) {
f010337e:	83 c4 10             	add    $0x10,%esp
f0103381:	85 c0                	test   %eax,%eax
f0103383:	74 ce                	je     f0103353 <region_alloc+0x5e>
		}
		if (page_insert(e->env_pgdir, pp, (void *)vstart, PTE_U | PTE_W) < 0) {
f0103385:	6a 06                	push   $0x6
f0103387:	53                   	push   %ebx
f0103388:	50                   	push   %eax
f0103389:	ff 76 60             	push   0x60(%esi)
f010338c:	e8 a9 e1 ff ff       	call   f010153a <page_insert>
f0103391:	83 c4 10             	add    $0x10,%esp
f0103394:	85 c0                	test   %eax,%eax
f0103396:	79 d2                	jns    f010336a <region_alloc+0x75>
			panic("region_alloc: page_insert failed");
f0103398:	83 ec 04             	sub    $0x4,%esp
f010339b:	68 44 7e 10 f0       	push   $0xf0107e44
f01033a0:	68 34 01 00 00       	push   $0x134
f01033a5:	68 ae 7d 10 f0       	push   $0xf0107dae
f01033aa:	e8 91 cc ff ff       	call   f0100040 <_panic>
		}
	}
}
f01033af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033b2:	5b                   	pop    %ebx
f01033b3:	5e                   	pop    %esi
f01033b4:	5f                   	pop    %edi
f01033b5:	5d                   	pop    %ebp
f01033b6:	c3                   	ret    

f01033b7 <envid2env>:
{
f01033b7:	55                   	push   %ebp
f01033b8:	89 e5                	mov    %esp,%ebp
f01033ba:	56                   	push   %esi
f01033bb:	53                   	push   %ebx
f01033bc:	8b 75 08             	mov    0x8(%ebp),%esi
f01033bf:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f01033c2:	85 f6                	test   %esi,%esi
f01033c4:	74 2e                	je     f01033f4 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f01033c6:	89 f3                	mov    %esi,%ebx
f01033c8:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01033ce:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01033d1:	03 1d 70 72 22 f0    	add    0xf0227270,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01033d7:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01033db:	74 5b                	je     f0103438 <envid2env+0x81>
f01033dd:	39 73 48             	cmp    %esi,0x48(%ebx)
f01033e0:	75 62                	jne    f0103444 <envid2env+0x8d>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01033e2:	84 c0                	test   %al,%al
f01033e4:	75 20                	jne    f0103406 <envid2env+0x4f>
	return 0;
f01033e6:	b8 00 00 00 00       	mov    $0x0,%eax
		*env_store = curenv;
f01033eb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033ee:	89 1a                	mov    %ebx,(%edx)
}
f01033f0:	5b                   	pop    %ebx
f01033f1:	5e                   	pop    %esi
f01033f2:	5d                   	pop    %ebp
f01033f3:	c3                   	ret    
		*env_store = curenv;
f01033f4:	e8 a3 2d 00 00       	call   f010619c <cpunum>
f01033f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01033fc:	8b 98 28 80 26 f0    	mov    -0xfd97fd8(%eax),%ebx
		return 0;
f0103402:	89 f0                	mov    %esi,%eax
f0103404:	eb e5                	jmp    f01033eb <envid2env+0x34>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103406:	e8 91 2d 00 00       	call   f010619c <cpunum>
f010340b:	6b c0 74             	imul   $0x74,%eax,%eax
f010340e:	39 98 28 80 26 f0    	cmp    %ebx,-0xfd97fd8(%eax)
f0103414:	74 d0                	je     f01033e6 <envid2env+0x2f>
f0103416:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103419:	e8 7e 2d 00 00       	call   f010619c <cpunum>
f010341e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103421:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0103427:	3b 70 48             	cmp    0x48(%eax),%esi
f010342a:	74 ba                	je     f01033e6 <envid2env+0x2f>
f010342c:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f0103431:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103436:	eb b3                	jmp    f01033eb <envid2env+0x34>
f0103438:	bb 00 00 00 00       	mov    $0x0,%ebx
		return -E_BAD_ENV;
f010343d:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103442:	eb a7                	jmp    f01033eb <envid2env+0x34>
f0103444:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103449:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010344e:	eb 9b                	jmp    f01033eb <envid2env+0x34>

f0103450 <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f0103450:	b8 20 63 12 f0       	mov    $0xf0126320,%eax
f0103455:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103458:	b8 23 00 00 00       	mov    $0x23,%eax
f010345d:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010345f:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103461:	b8 10 00 00 00       	mov    $0x10,%eax
f0103466:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103468:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f010346a:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010346c:	ea 73 34 10 f0 08 00 	ljmp   $0x8,$0xf0103473
	asm volatile("lldt %0" : : "r" (sel));
f0103473:	b8 00 00 00 00       	mov    $0x0,%eax
f0103478:	0f 00 d0             	lldt   %ax
}
f010347b:	c3                   	ret    

f010347c <env_init>:
{
f010347c:	55                   	push   %ebp
f010347d:	89 e5                	mov    %esp,%ebp
f010347f:	53                   	push   %ebx
f0103480:	83 ec 04             	sub    $0x4,%esp
		envs[i].env_id = 0;
f0103483:	8b 1d 70 72 22 f0    	mov    0xf0227270,%ebx
f0103489:	8b 15 74 72 22 f0    	mov    0xf0227274,%edx
f010348f:	8d 83 84 ef 01 00    	lea    0x1ef84(%ebx),%eax
f0103495:	89 d1                	mov    %edx,%ecx
f0103497:	89 c2                	mov    %eax,%edx
f0103499:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_status = ENV_FREE;
f01034a0:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_link = env_free_list;
f01034a7:	89 48 44             	mov    %ecx,0x44(%eax)
	for (int i = NENV - 1; i >= 0; i--) {
f01034aa:	83 e8 7c             	sub    $0x7c,%eax
f01034ad:	39 da                	cmp    %ebx,%edx
f01034af:	75 e4                	jne    f0103495 <env_init+0x19>
f01034b1:	89 1d 74 72 22 f0    	mov    %ebx,0xf0227274
	env_init_percpu();
f01034b7:	e8 94 ff ff ff       	call   f0103450 <env_init_percpu>
}
f01034bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034bf:	c9                   	leave  
f01034c0:	c3                   	ret    

f01034c1 <env_alloc>:
{
f01034c1:	55                   	push   %ebp
f01034c2:	89 e5                	mov    %esp,%ebp
f01034c4:	53                   	push   %ebx
f01034c5:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f01034c8:	8b 1d 74 72 22 f0    	mov    0xf0227274,%ebx
f01034ce:	85 db                	test   %ebx,%ebx
f01034d0:	0f 84 77 01 00 00    	je     f010364d <env_alloc+0x18c>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01034d6:	83 ec 0c             	sub    $0xc,%esp
f01034d9:	6a 01                	push   $0x1
f01034db:	e8 be dd ff ff       	call   f010129e <page_alloc>
f01034e0:	83 c4 10             	add    $0x10,%esp
f01034e3:	85 c0                	test   %eax,%eax
f01034e5:	0f 84 69 01 00 00    	je     f0103654 <env_alloc+0x193>
	p->pp_ref++;
f01034eb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01034f0:	2b 05 58 72 22 f0    	sub    0xf0227258,%eax
f01034f6:	c1 f8 03             	sar    $0x3,%eax
f01034f9:	89 c2                	mov    %eax,%edx
f01034fb:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01034fe:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0103503:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f0103509:	0f 83 17 01 00 00    	jae    f0103626 <env_alloc+0x165>
	return (void *)(pa + KERNBASE);
f010350f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = (pde_t *)page2kva(p);
f0103515:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103518:	83 ec 04             	sub    $0x4,%esp
f010351b:	68 00 10 00 00       	push   $0x1000
f0103520:	ff 35 5c 72 22 f0    	push   0xf022725c
f0103526:	50                   	push   %eax
f0103527:	e8 21 27 00 00       	call   f0105c4d <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010352c:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010352f:	83 c4 10             	add    $0x10,%esp
f0103532:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103537:	0f 86 fb 00 00 00    	jbe    f0103638 <env_alloc+0x177>
	return (physaddr_t)kva - KERNBASE;
f010353d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103543:	83 ca 05             	or     $0x5,%edx
f0103546:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010354c:	8b 43 48             	mov    0x48(%ebx),%eax
f010354f:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103554:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103559:	ba 00 10 00 00       	mov    $0x1000,%edx
f010355e:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103561:	89 da                	mov    %ebx,%edx
f0103563:	2b 15 70 72 22 f0    	sub    0xf0227270,%edx
f0103569:	c1 fa 02             	sar    $0x2,%edx
f010356c:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103572:	09 d0                	or     %edx,%eax
f0103574:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103577:	8b 45 0c             	mov    0xc(%ebp),%eax
f010357a:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010357d:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103584:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010358b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103592:	83 ec 04             	sub    $0x4,%esp
f0103595:	6a 44                	push   $0x44
f0103597:	6a 00                	push   $0x0
f0103599:	53                   	push   %ebx
f010359a:	e8 06 26 00 00       	call   f0105ba5 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010359f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01035a5:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01035ab:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01035b1:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01035b8:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f01035be:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f01035c5:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f01035cc:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f01035d0:	8b 43 44             	mov    0x44(%ebx),%eax
f01035d3:	a3 74 72 22 f0       	mov    %eax,0xf0227274
	*newenv_store = e;
f01035d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01035db:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01035dd:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01035e0:	e8 b7 2b 00 00       	call   f010619c <cpunum>
f01035e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e8:	83 c4 10             	add    $0x10,%esp
f01035eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01035f0:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f01035f7:	74 11                	je     f010360a <env_alloc+0x149>
f01035f9:	e8 9e 2b 00 00       	call   f010619c <cpunum>
f01035fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103601:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0103607:	8b 50 48             	mov    0x48(%eax),%edx
f010360a:	83 ec 04             	sub    $0x4,%esp
f010360d:	53                   	push   %ebx
f010360e:	52                   	push   %edx
f010360f:	68 b9 7d 10 f0       	push   $0xf0107db9
f0103614:	e8 59 06 00 00       	call   f0103c72 <cprintf>
	return 0;
f0103619:	83 c4 10             	add    $0x10,%esp
f010361c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103621:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103624:	c9                   	leave  
f0103625:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103626:	52                   	push   %edx
f0103627:	68 04 68 10 f0       	push   $0xf0106804
f010362c:	6a 58                	push   $0x58
f010362e:	68 07 71 10 f0       	push   $0xf0107107
f0103633:	e8 08 ca ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103638:	50                   	push   %eax
f0103639:	68 28 68 10 f0       	push   $0xf0106828
f010363e:	68 c4 00 00 00       	push   $0xc4
f0103643:	68 ae 7d 10 f0       	push   $0xf0107dae
f0103648:	e8 f3 c9 ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f010364d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103652:	eb cd                	jmp    f0103621 <env_alloc+0x160>
		return -E_NO_MEM;
f0103654:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103659:	eb c6                	jmp    f0103621 <env_alloc+0x160>

f010365b <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010365b:	55                   	push   %ebp
f010365c:	89 e5                	mov    %esp,%ebp
f010365e:	57                   	push   %edi
f010365f:	56                   	push   %esi
f0103660:	53                   	push   %ebx
f0103661:	83 ec 34             	sub    $0x34,%esp
f0103664:	8b 7d 08             	mov    0x8(%ebp),%edi
	struct Env *e;
	int ret = env_alloc(&e, 0);
f0103667:	6a 00                	push   $0x0
f0103669:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010366c:	50                   	push   %eax
f010366d:	e8 4f fe ff ff       	call   f01034c1 <env_alloc>
	if (ret < 0) {
f0103672:	83 c4 10             	add    $0x10,%esp
f0103675:	85 c0                	test   %eax,%eax
f0103677:	78 33                	js     f01036ac <env_create+0x51>
		panic("env_create: %e", ret);
	}
	load_icode(e, binary);
f0103679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010367c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (elfhdr->e_magic != ELF_MAGIC) {
f010367f:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103685:	75 3a                	jne    f01036c1 <env_create+0x66>
	ph = (struct Proghdr *)((uintptr_t)binary + elfhdr->e_phoff);
f0103687:	89 fb                	mov    %edi,%ebx
f0103689:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elfhdr->e_phnum;
f010368c:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103690:	c1 e6 05             	shl    $0x5,%esi
f0103693:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f0103695:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103698:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010369b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036a0:	76 36                	jbe    f01036d8 <env_create+0x7d>
	return (physaddr_t)kva - KERNBASE;
f01036a2:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01036a7:	0f 22 d8             	mov    %eax,%cr3
}
f01036aa:	eb 44                	jmp    f01036f0 <env_create+0x95>
		panic("env_create: %e", ret);
f01036ac:	50                   	push   %eax
f01036ad:	68 ce 7d 10 f0       	push   $0xf0107dce
f01036b2:	68 93 01 00 00       	push   $0x193
f01036b7:	68 ae 7d 10 f0       	push   $0xf0107dae
f01036bc:	e8 7f c9 ff ff       	call   f0100040 <_panic>
		panic("load_icode: invalid ELF header");
f01036c1:	83 ec 04             	sub    $0x4,%esp
f01036c4:	68 68 7e 10 f0       	push   $0xf0107e68
f01036c9:	68 72 01 00 00       	push   $0x172
f01036ce:	68 ae 7d 10 f0       	push   $0xf0107dae
f01036d3:	e8 68 c9 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036d8:	50                   	push   %eax
f01036d9:	68 28 68 10 f0       	push   $0xf0106828
f01036de:	68 76 01 00 00       	push   $0x176
f01036e3:	68 ae 7d 10 f0       	push   $0xf0107dae
f01036e8:	e8 53 c9 ff ff       	call   f0100040 <_panic>
	for (; ph < eph; ph++) { 
f01036ed:	83 c3 20             	add    $0x20,%ebx
f01036f0:	39 de                	cmp    %ebx,%esi
f01036f2:	76 3c                	jbe    f0103730 <env_create+0xd5>
		if (ph->p_type == ELF_PROG_LOAD) {
f01036f4:	83 3b 01             	cmpl   $0x1,(%ebx)
f01036f7:	75 f4                	jne    f01036ed <env_create+0x92>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f01036f9:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01036fc:	8b 53 08             	mov    0x8(%ebx),%edx
f01036ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103702:	e8 ee fb ff ff       	call   f01032f5 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0103707:	83 ec 04             	sub    $0x4,%esp
f010370a:	ff 73 14             	push   0x14(%ebx)
f010370d:	6a 00                	push   $0x0
f010370f:	ff 73 08             	push   0x8(%ebx)
f0103712:	e8 8e 24 00 00       	call   f0105ba5 <memset>
			memcpy((void *)ph->p_va, (void *)(binary + ph->p_offset), ph->p_filesz);
f0103717:	83 c4 0c             	add    $0xc,%esp
f010371a:	ff 73 10             	push   0x10(%ebx)
f010371d:	89 f8                	mov    %edi,%eax
f010371f:	03 43 04             	add    0x4(%ebx),%eax
f0103722:	50                   	push   %eax
f0103723:	ff 73 08             	push   0x8(%ebx)
f0103726:	e8 22 25 00 00       	call   f0105c4d <memcpy>
f010372b:	83 c4 10             	add    $0x10,%esp
f010372e:	eb bd                	jmp    f01036ed <env_create+0x92>
	e->env_tf.tf_eip = elfhdr->e_entry;
f0103730:	8b 47 18             	mov    0x18(%edi),%eax
f0103733:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103736:	89 41 30             	mov    %eax,0x30(%ecx)
	lcr3(PADDR(kern_pgdir));
f0103739:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
	if ((uint32_t)kva < KERNBASE)
f010373e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103743:	76 2b                	jbe    f0103770 <env_create+0x115>
	return (physaddr_t)kva - KERNBASE;
f0103745:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010374a:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f010374d:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103752:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103757:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010375a:	e8 96 fb ff ff       	call   f01032f5 <region_alloc>
	e->env_type = type;
f010375f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103765:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103768:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010376b:	5b                   	pop    %ebx
f010376c:	5e                   	pop    %esi
f010376d:	5f                   	pop    %edi
f010376e:	5d                   	pop    %ebp
f010376f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103770:	50                   	push   %eax
f0103771:	68 28 68 10 f0       	push   $0xf0106828
f0103776:	68 7f 01 00 00       	push   $0x17f
f010377b:	68 ae 7d 10 f0       	push   $0xf0107dae
f0103780:	e8 bb c8 ff ff       	call   f0100040 <_panic>

f0103785 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103785:	55                   	push   %ebp
f0103786:	89 e5                	mov    %esp,%ebp
f0103788:	57                   	push   %edi
f0103789:	56                   	push   %esi
f010378a:	53                   	push   %ebx
f010378b:	83 ec 1c             	sub    $0x1c,%esp
f010378e:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103791:	e8 06 2a 00 00       	call   f010619c <cpunum>
f0103796:	6b c0 74             	imul   $0x74,%eax,%eax
f0103799:	39 b8 28 80 26 f0    	cmp    %edi,-0xfd97fd8(%eax)
f010379f:	74 48                	je     f01037e9 <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037a1:	8b 5f 48             	mov    0x48(%edi),%ebx
f01037a4:	e8 f3 29 00 00       	call   f010619c <cpunum>
f01037a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01037b1:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f01037b8:	74 11                	je     f01037cb <env_free+0x46>
f01037ba:	e8 dd 29 00 00       	call   f010619c <cpunum>
f01037bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01037c2:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01037c8:	8b 50 48             	mov    0x48(%eax),%edx
f01037cb:	83 ec 04             	sub    $0x4,%esp
f01037ce:	53                   	push   %ebx
f01037cf:	52                   	push   %edx
f01037d0:	68 dd 7d 10 f0       	push   $0xf0107ddd
f01037d5:	e8 98 04 00 00       	call   f0103c72 <cprintf>
f01037da:	83 c4 10             	add    $0x10,%esp
f01037dd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01037e4:	e9 a9 00 00 00       	jmp    f0103892 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f01037e9:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
	if ((uint32_t)kva < KERNBASE)
f01037ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037f3:	76 0a                	jbe    f01037ff <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f01037f5:	05 00 00 00 10       	add    $0x10000000,%eax
f01037fa:	0f 22 d8             	mov    %eax,%cr3
}
f01037fd:	eb a2                	jmp    f01037a1 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037ff:	50                   	push   %eax
f0103800:	68 28 68 10 f0       	push   $0xf0106828
f0103805:	68 a7 01 00 00       	push   $0x1a7
f010380a:	68 ae 7d 10 f0       	push   $0xf0107dae
f010380f:	e8 2c c8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103814:	56                   	push   %esi
f0103815:	68 04 68 10 f0       	push   $0xf0106804
f010381a:	68 b6 01 00 00       	push   $0x1b6
f010381f:	68 ae 7d 10 f0       	push   $0xf0107dae
f0103824:	e8 17 c8 ff ff       	call   f0100040 <_panic>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103829:	83 c6 04             	add    $0x4,%esi
f010382c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103832:	81 fb 00 00 40 00    	cmp    $0x400000,%ebx
f0103838:	74 1b                	je     f0103855 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f010383a:	f6 06 01             	testb  $0x1,(%esi)
f010383d:	74 ea                	je     f0103829 <env_free+0xa4>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010383f:	83 ec 08             	sub    $0x8,%esp
f0103842:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103845:	09 d8                	or     %ebx,%eax
f0103847:	50                   	push   %eax
f0103848:	ff 77 60             	push   0x60(%edi)
f010384b:	e8 96 dc ff ff       	call   f01014e6 <page_remove>
f0103850:	83 c4 10             	add    $0x10,%esp
f0103853:	eb d4                	jmp    f0103829 <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103855:	8b 47 60             	mov    0x60(%edi),%eax
f0103858:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010385b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103862:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103865:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f010386b:	73 65                	jae    f01038d2 <env_free+0x14d>
		page_decref(pa2page(pa));
f010386d:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103870:	a1 58 72 22 f0       	mov    0xf0227258,%eax
f0103875:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103878:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010387b:	50                   	push   %eax
f010387c:	e8 cd da ff ff       	call   f010134e <page_decref>
f0103881:	83 c4 10             	add    $0x10,%esp
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103884:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f0103888:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010388b:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103890:	74 54                	je     f01038e6 <env_free+0x161>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103892:	8b 47 60             	mov    0x60(%edi),%eax
f0103895:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103898:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f010389b:	a8 01                	test   $0x1,%al
f010389d:	74 e5                	je     f0103884 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010389f:	89 c6                	mov    %eax,%esi
f01038a1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f01038a7:	c1 e8 0c             	shr    $0xc,%eax
f01038aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01038ad:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f01038b3:	0f 83 5b ff ff ff    	jae    f0103814 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f01038b9:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f01038bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038c2:	c1 e0 14             	shl    $0x14,%eax
f01038c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01038c8:	bb 00 00 00 00       	mov    $0x0,%ebx
f01038cd:	e9 68 ff ff ff       	jmp    f010383a <env_free+0xb5>
		panic("pa2page called with invalid pa");
f01038d2:	83 ec 04             	sub    $0x4,%esp
f01038d5:	68 38 75 10 f0       	push   $0xf0107538
f01038da:	6a 51                	push   $0x51
f01038dc:	68 07 71 10 f0       	push   $0xf0107107
f01038e1:	e8 5a c7 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01038e6:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f01038e9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038ee:	76 49                	jbe    f0103939 <env_free+0x1b4>
	e->env_pgdir = 0;
f01038f0:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01038f7:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01038fc:	c1 e8 0c             	shr    $0xc,%eax
f01038ff:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f0103905:	73 47                	jae    f010394e <env_free+0x1c9>
	page_decref(pa2page(pa));
f0103907:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010390a:	8b 15 58 72 22 f0    	mov    0xf0227258,%edx
f0103910:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103913:	50                   	push   %eax
f0103914:	e8 35 da ff ff       	call   f010134e <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103919:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103920:	a1 74 72 22 f0       	mov    0xf0227274,%eax
f0103925:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103928:	89 3d 74 72 22 f0    	mov    %edi,0xf0227274
}
f010392e:	83 c4 10             	add    $0x10,%esp
f0103931:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103934:	5b                   	pop    %ebx
f0103935:	5e                   	pop    %esi
f0103936:	5f                   	pop    %edi
f0103937:	5d                   	pop    %ebp
f0103938:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103939:	50                   	push   %eax
f010393a:	68 28 68 10 f0       	push   $0xf0106828
f010393f:	68 c4 01 00 00       	push   $0x1c4
f0103944:	68 ae 7d 10 f0       	push   $0xf0107dae
f0103949:	e8 f2 c6 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f010394e:	83 ec 04             	sub    $0x4,%esp
f0103951:	68 38 75 10 f0       	push   $0xf0107538
f0103956:	6a 51                	push   $0x51
f0103958:	68 07 71 10 f0       	push   $0xf0107107
f010395d:	e8 de c6 ff ff       	call   f0100040 <_panic>

f0103962 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103962:	55                   	push   %ebp
f0103963:	89 e5                	mov    %esp,%ebp
f0103965:	53                   	push   %ebx
f0103966:	83 ec 04             	sub    $0x4,%esp
f0103969:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010396c:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103970:	74 21                	je     f0103993 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f0103972:	83 ec 0c             	sub    $0xc,%esp
f0103975:	53                   	push   %ebx
f0103976:	e8 0a fe ff ff       	call   f0103785 <env_free>

	if (curenv == e) {
f010397b:	e8 1c 28 00 00       	call   f010619c <cpunum>
f0103980:	6b c0 74             	imul   $0x74,%eax,%eax
f0103983:	83 c4 10             	add    $0x10,%esp
f0103986:	39 98 28 80 26 f0    	cmp    %ebx,-0xfd97fd8(%eax)
f010398c:	74 1e                	je     f01039ac <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f010398e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103991:	c9                   	leave  
f0103992:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103993:	e8 04 28 00 00       	call   f010619c <cpunum>
f0103998:	6b c0 74             	imul   $0x74,%eax,%eax
f010399b:	39 98 28 80 26 f0    	cmp    %ebx,-0xfd97fd8(%eax)
f01039a1:	74 cf                	je     f0103972 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f01039a3:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01039aa:	eb e2                	jmp    f010398e <env_destroy+0x2c>
		curenv = NULL;
f01039ac:	e8 eb 27 00 00       	call   f010619c <cpunum>
f01039b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039b4:	c7 80 28 80 26 f0 00 	movl   $0x0,-0xfd97fd8(%eax)
f01039bb:	00 00 00 
		sched_yield();
f01039be:	e8 05 0f 00 00       	call   f01048c8 <sched_yield>

f01039c3 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01039c3:	55                   	push   %ebp
f01039c4:	89 e5                	mov    %esp,%ebp
f01039c6:	53                   	push   %ebx
f01039c7:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01039ca:	e8 cd 27 00 00       	call   f010619c <cpunum>
f01039cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01039d2:	8b 98 28 80 26 f0    	mov    -0xfd97fd8(%eax),%ebx
f01039d8:	e8 bf 27 00 00       	call   f010619c <cpunum>
f01039dd:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01039e0:	8b 65 08             	mov    0x8(%ebp),%esp
f01039e3:	61                   	popa   
f01039e4:	07                   	pop    %es
f01039e5:	1f                   	pop    %ds
f01039e6:	83 c4 08             	add    $0x8,%esp
f01039e9:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01039ea:	83 ec 04             	sub    $0x4,%esp
f01039ed:	68 f3 7d 10 f0       	push   $0xf0107df3
f01039f2:	68 fb 01 00 00       	push   $0x1fb
f01039f7:	68 ae 7d 10 f0       	push   $0xf0107dae
f01039fc:	e8 3f c6 ff ff       	call   f0100040 <_panic>

f0103a01 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103a01:	55                   	push   %ebp
f0103a02:	89 e5                	mov    %esp,%ebp
f0103a04:	83 ec 08             	sub    $0x8,%esp
	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	if ((curenv) && (curenv->env_status == ENV_RUNNING)) {
f0103a07:	e8 90 27 00 00       	call   f010619c <cpunum>
f0103a0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a0f:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f0103a16:	74 14                	je     f0103a2c <env_run+0x2b>
f0103a18:	e8 7f 27 00 00       	call   f010619c <cpunum>
f0103a1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a20:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0103a26:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a2a:	74 7d                	je     f0103aa9 <env_run+0xa8>
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f0103a2c:	e8 6b 27 00 00       	call   f010619c <cpunum>
f0103a31:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a34:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a37:	89 90 28 80 26 f0    	mov    %edx,-0xfd97fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103a3d:	e8 5a 27 00 00       	call   f010619c <cpunum>
f0103a42:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a45:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0103a4b:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103a52:	e8 45 27 00 00       	call   f010619c <cpunum>
f0103a57:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a5a:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0103a60:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0103a64:	e8 33 27 00 00       	call   f010619c <cpunum>
f0103a69:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a6c:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0103a72:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103a75:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a7a:	76 47                	jbe    f0103ac3 <env_run+0xc2>
	return (physaddr_t)kva - KERNBASE;
f0103a7c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103a81:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103a84:	83 ec 0c             	sub    $0xc,%esp
f0103a87:	68 c0 63 12 f0       	push   $0xf01263c0
f0103a8c:	e8 15 2a 00 00       	call   f01064a6 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103a91:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&(curenv->env_tf));
f0103a93:	e8 04 27 00 00       	call   f010619c <cpunum>
f0103a98:	83 c4 04             	add    $0x4,%esp
f0103a9b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a9e:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f0103aa4:	e8 1a ff ff ff       	call   f01039c3 <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f0103aa9:	e8 ee 26 00 00       	call   f010619c <cpunum>
f0103aae:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ab1:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0103ab7:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103abe:	e9 69 ff ff ff       	jmp    f0103a2c <env_run+0x2b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ac3:	50                   	push   %eax
f0103ac4:	68 28 68 10 f0       	push   $0xf0106828
f0103ac9:	68 1e 02 00 00       	push   $0x21e
f0103ace:	68 ae 7d 10 f0       	push   $0xf0107dae
f0103ad3:	e8 68 c5 ff ff       	call   f0100040 <_panic>

f0103ad8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103ad8:	55                   	push   %ebp
f0103ad9:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103adb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ade:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ae3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103ae4:	ba 71 00 00 00       	mov    $0x71,%edx
f0103ae9:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103aea:	0f b6 c0             	movzbl %al,%eax
}
f0103aed:	5d                   	pop    %ebp
f0103aee:	c3                   	ret    

f0103aef <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103aef:	55                   	push   %ebp
f0103af0:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103af2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103af5:	ba 70 00 00 00       	mov    $0x70,%edx
f0103afa:	ee                   	out    %al,(%dx)
f0103afb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103afe:	ba 71 00 00 00       	mov    $0x71,%edx
f0103b03:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103b04:	5d                   	pop    %ebp
f0103b05:	c3                   	ret    

f0103b06 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103b06:	55                   	push   %ebp
f0103b07:	89 e5                	mov    %esp,%ebp
f0103b09:	56                   	push   %esi
f0103b0a:	53                   	push   %ebx
f0103b0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	irq_mask_8259A = mask;
f0103b0e:	66 89 0d a8 63 12 f0 	mov    %cx,0xf01263a8
	if (!didinit)
f0103b15:	80 3d 78 72 22 f0 00 	cmpb   $0x0,0xf0227278
f0103b1c:	75 07                	jne    f0103b25 <irq_setmask_8259A+0x1f>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103b1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103b21:	5b                   	pop    %ebx
f0103b22:	5e                   	pop    %esi
f0103b23:	5d                   	pop    %ebp
f0103b24:	c3                   	ret    
f0103b25:	89 ce                	mov    %ecx,%esi
f0103b27:	ba 21 00 00 00       	mov    $0x21,%edx
f0103b2c:	89 c8                	mov    %ecx,%eax
f0103b2e:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103b2f:	89 c8                	mov    %ecx,%eax
f0103b31:	66 c1 e8 08          	shr    $0x8,%ax
f0103b35:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103b3a:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103b3b:	83 ec 0c             	sub    $0xc,%esp
f0103b3e:	68 87 7e 10 f0       	push   $0xf0107e87
f0103b43:	e8 2a 01 00 00       	call   f0103c72 <cprintf>
f0103b48:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103b4b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103b50:	0f b7 f6             	movzwl %si,%esi
f0103b53:	f7 d6                	not    %esi
f0103b55:	eb 08                	jmp    f0103b5f <irq_setmask_8259A+0x59>
	for (i = 0; i < 16; i++)
f0103b57:	83 c3 01             	add    $0x1,%ebx
f0103b5a:	83 fb 10             	cmp    $0x10,%ebx
f0103b5d:	74 18                	je     f0103b77 <irq_setmask_8259A+0x71>
		if (~mask & (1<<i))
f0103b5f:	0f a3 de             	bt     %ebx,%esi
f0103b62:	73 f3                	jae    f0103b57 <irq_setmask_8259A+0x51>
			cprintf(" %d", i);
f0103b64:	83 ec 08             	sub    $0x8,%esp
f0103b67:	53                   	push   %ebx
f0103b68:	68 6b 83 10 f0       	push   $0xf010836b
f0103b6d:	e8 00 01 00 00       	call   f0103c72 <cprintf>
f0103b72:	83 c4 10             	add    $0x10,%esp
f0103b75:	eb e0                	jmp    f0103b57 <irq_setmask_8259A+0x51>
	cprintf("\n");
f0103b77:	83 ec 0c             	sub    $0xc,%esp
f0103b7a:	68 e8 73 10 f0       	push   $0xf01073e8
f0103b7f:	e8 ee 00 00 00       	call   f0103c72 <cprintf>
f0103b84:	83 c4 10             	add    $0x10,%esp
f0103b87:	eb 95                	jmp    f0103b1e <irq_setmask_8259A+0x18>

f0103b89 <pic_init>:
{
f0103b89:	55                   	push   %ebp
f0103b8a:	89 e5                	mov    %esp,%ebp
f0103b8c:	57                   	push   %edi
f0103b8d:	56                   	push   %esi
f0103b8e:	53                   	push   %ebx
f0103b8f:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103b92:	c6 05 78 72 22 f0 01 	movb   $0x1,0xf0227278
f0103b99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b9e:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103ba3:	89 da                	mov    %ebx,%edx
f0103ba5:	ee                   	out    %al,(%dx)
f0103ba6:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103bab:	89 ca                	mov    %ecx,%edx
f0103bad:	ee                   	out    %al,(%dx)
f0103bae:	bf 11 00 00 00       	mov    $0x11,%edi
f0103bb3:	be 20 00 00 00       	mov    $0x20,%esi
f0103bb8:	89 f8                	mov    %edi,%eax
f0103bba:	89 f2                	mov    %esi,%edx
f0103bbc:	ee                   	out    %al,(%dx)
f0103bbd:	b8 20 00 00 00       	mov    $0x20,%eax
f0103bc2:	89 da                	mov    %ebx,%edx
f0103bc4:	ee                   	out    %al,(%dx)
f0103bc5:	b8 04 00 00 00       	mov    $0x4,%eax
f0103bca:	ee                   	out    %al,(%dx)
f0103bcb:	b8 03 00 00 00       	mov    $0x3,%eax
f0103bd0:	ee                   	out    %al,(%dx)
f0103bd1:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103bd6:	89 f8                	mov    %edi,%eax
f0103bd8:	89 da                	mov    %ebx,%edx
f0103bda:	ee                   	out    %al,(%dx)
f0103bdb:	b8 28 00 00 00       	mov    $0x28,%eax
f0103be0:	89 ca                	mov    %ecx,%edx
f0103be2:	ee                   	out    %al,(%dx)
f0103be3:	b8 02 00 00 00       	mov    $0x2,%eax
f0103be8:	ee                   	out    %al,(%dx)
f0103be9:	b8 01 00 00 00       	mov    $0x1,%eax
f0103bee:	ee                   	out    %al,(%dx)
f0103bef:	bf 68 00 00 00       	mov    $0x68,%edi
f0103bf4:	89 f8                	mov    %edi,%eax
f0103bf6:	89 f2                	mov    %esi,%edx
f0103bf8:	ee                   	out    %al,(%dx)
f0103bf9:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103bfe:	89 c8                	mov    %ecx,%eax
f0103c00:	ee                   	out    %al,(%dx)
f0103c01:	89 f8                	mov    %edi,%eax
f0103c03:	89 da                	mov    %ebx,%edx
f0103c05:	ee                   	out    %al,(%dx)
f0103c06:	89 c8                	mov    %ecx,%eax
f0103c08:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103c09:	0f b7 05 a8 63 12 f0 	movzwl 0xf01263a8,%eax
f0103c10:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103c14:	75 08                	jne    f0103c1e <pic_init+0x95>
}
f0103c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c19:	5b                   	pop    %ebx
f0103c1a:	5e                   	pop    %esi
f0103c1b:	5f                   	pop    %edi
f0103c1c:	5d                   	pop    %ebp
f0103c1d:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103c1e:	83 ec 0c             	sub    $0xc,%esp
f0103c21:	0f b7 c0             	movzwl %ax,%eax
f0103c24:	50                   	push   %eax
f0103c25:	e8 dc fe ff ff       	call   f0103b06 <irq_setmask_8259A>
f0103c2a:	83 c4 10             	add    $0x10,%esp
}
f0103c2d:	eb e7                	jmp    f0103c16 <pic_init+0x8d>

f0103c2f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103c2f:	55                   	push   %ebp
f0103c30:	89 e5                	mov    %esp,%ebp
f0103c32:	53                   	push   %ebx
f0103c33:	83 ec 10             	sub    $0x10,%esp
f0103c36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0103c39:	ff 75 08             	push   0x8(%ebp)
f0103c3c:	e8 09 cb ff ff       	call   f010074a <cputchar>
	(*cnt)++;
f0103c41:	83 03 01             	addl   $0x1,(%ebx)
}
f0103c44:	83 c4 10             	add    $0x10,%esp
f0103c47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103c4a:	c9                   	leave  
f0103c4b:	c3                   	ret    

f0103c4c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103c4c:	55                   	push   %ebp
f0103c4d:	89 e5                	mov    %esp,%ebp
f0103c4f:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103c52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103c59:	ff 75 0c             	push   0xc(%ebp)
f0103c5c:	ff 75 08             	push   0x8(%ebp)
f0103c5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c62:	50                   	push   %eax
f0103c63:	68 2f 3c 10 f0       	push   $0xf0103c2f
f0103c68:	e8 23 18 00 00       	call   f0105490 <vprintfmt>
	return cnt;
}
f0103c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c70:	c9                   	leave  
f0103c71:	c3                   	ret    

f0103c72 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103c72:	55                   	push   %ebp
f0103c73:	89 e5                	mov    %esp,%ebp
f0103c75:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103c78:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103c7b:	50                   	push   %eax
f0103c7c:	ff 75 08             	push   0x8(%ebp)
f0103c7f:	e8 c8 ff ff ff       	call   f0103c4c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103c84:	c9                   	leave  
f0103c85:	c3                   	ret    

f0103c86 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103c86:	55                   	push   %ebp
f0103c87:	89 e5                	mov    %esp,%ebp
f0103c89:	57                   	push   %edi
f0103c8a:	56                   	push   %esi
f0103c8b:	53                   	push   %ebx
f0103c8c:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	uint32_t id = thiscpu->cpu_id;
f0103c8f:	e8 08 25 00 00       	call   f010619c <cpunum>
f0103c94:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c97:	0f b6 b8 20 80 26 f0 	movzbl -0xfd97fe0(%eax),%edi
f0103c9e:	89 f8                	mov    %edi,%eax
f0103ca0:	0f b6 d8             	movzbl %al,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - id * (KSTKSIZE + KSTKGAP);
f0103ca3:	e8 f4 24 00 00       	call   f010619c <cpunum>
f0103ca8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cab:	ba 00 f0 00 00       	mov    $0xf000,%edx
f0103cb0:	29 da                	sub    %ebx,%edx
f0103cb2:	c1 e2 10             	shl    $0x10,%edx
f0103cb5:	89 90 30 80 26 f0    	mov    %edx,-0xfd97fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103cbb:	e8 dc 24 00 00       	call   f010619c <cpunum>
f0103cc0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cc3:	66 c7 80 34 80 26 f0 	movw   $0x10,-0xfd97fcc(%eax)
f0103cca:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103ccc:	e8 cb 24 00 00       	call   f010619c <cpunum>
f0103cd1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd4:	66 c7 80 92 80 26 f0 	movw   $0x68,-0xfd97f6e(%eax)
f0103cdb:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + id] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f0103cdd:	83 c3 05             	add    $0x5,%ebx
f0103ce0:	e8 b7 24 00 00       	call   f010619c <cpunum>
f0103ce5:	89 c6                	mov    %eax,%esi
f0103ce7:	e8 b0 24 00 00       	call   f010619c <cpunum>
f0103cec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103cef:	e8 a8 24 00 00       	call   f010619c <cpunum>
f0103cf4:	66 c7 04 dd 40 63 12 	movw   $0x67,-0xfed9cc0(,%ebx,8)
f0103cfb:	f0 67 00 
f0103cfe:	6b f6 74             	imul   $0x74,%esi,%esi
f0103d01:	81 c6 2c 80 26 f0    	add    $0xf026802c,%esi
f0103d07:	66 89 34 dd 42 63 12 	mov    %si,-0xfed9cbe(,%ebx,8)
f0103d0e:	f0 
f0103d0f:	6b 55 e4 74          	imul   $0x74,-0x1c(%ebp),%edx
f0103d13:	81 c2 2c 80 26 f0    	add    $0xf026802c,%edx
f0103d19:	c1 ea 10             	shr    $0x10,%edx
f0103d1c:	88 14 dd 44 63 12 f0 	mov    %dl,-0xfed9cbc(,%ebx,8)
f0103d23:	c6 04 dd 46 63 12 f0 	movb   $0x40,-0xfed9cba(,%ebx,8)
f0103d2a:	40 
f0103d2b:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d2e:	05 2c 80 26 f0       	add    $0xf026802c,%eax
f0103d33:	c1 e8 18             	shr    $0x18,%eax
f0103d36:	88 04 dd 47 63 12 f0 	mov    %al,-0xfed9cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + id].sd_s = 0;
f0103d3d:	c6 04 dd 45 63 12 f0 	movb   $0x89,-0xfed9cbb(,%ebx,8)
f0103d44:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (id << 3));
f0103d45:	89 f8                	mov    %edi,%eax
f0103d47:	0f b6 f8             	movzbl %al,%edi
f0103d4a:	8d 3c fd 28 00 00 00 	lea    0x28(,%edi,8),%edi
	asm volatile("ltr %0" : : "r" (sel));
f0103d51:	0f 00 df             	ltr    %di
	asm volatile("lidt (%0)" : : "r" (p));
f0103d54:	b8 ac 63 12 f0       	mov    $0xf01263ac,%eax
f0103d59:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103d5c:	83 c4 1c             	add    $0x1c,%esp
f0103d5f:	5b                   	pop    %ebx
f0103d60:	5e                   	pop    %esi
f0103d61:	5f                   	pop    %edi
f0103d62:	5d                   	pop    %ebp
f0103d63:	c3                   	ret    

f0103d64 <trap_init>:
{
f0103d64:	55                   	push   %ebp
f0103d65:	89 e5                	mov    %esp,%ebp
f0103d67:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, handler_divide, 0);
f0103d6a:	b8 58 47 10 f0       	mov    $0xf0104758,%eax
f0103d6f:	66 a3 80 72 22 f0    	mov    %ax,0xf0227280
f0103d75:	66 c7 05 82 72 22 f0 	movw   $0x8,0xf0227282
f0103d7c:	08 00 
f0103d7e:	c6 05 84 72 22 f0 00 	movb   $0x0,0xf0227284
f0103d85:	c6 05 85 72 22 f0 8e 	movb   $0x8e,0xf0227285
f0103d8c:	c1 e8 10             	shr    $0x10,%eax
f0103d8f:	66 a3 86 72 22 f0    	mov    %ax,0xf0227286
	SETGATE(idt[T_DEBUG], 0, GD_KT, handler_debug, 0);
f0103d95:	b8 62 47 10 f0       	mov    $0xf0104762,%eax
f0103d9a:	66 a3 88 72 22 f0    	mov    %ax,0xf0227288
f0103da0:	66 c7 05 8a 72 22 f0 	movw   $0x8,0xf022728a
f0103da7:	08 00 
f0103da9:	c6 05 8c 72 22 f0 00 	movb   $0x0,0xf022728c
f0103db0:	c6 05 8d 72 22 f0 8e 	movb   $0x8e,0xf022728d
f0103db7:	c1 e8 10             	shr    $0x10,%eax
f0103dba:	66 a3 8e 72 22 f0    	mov    %ax,0xf022728e
	SETGATE(idt[T_NMI], 0, GD_KT, handler_nmi, 0);
f0103dc0:	b8 68 47 10 f0       	mov    $0xf0104768,%eax
f0103dc5:	66 a3 90 72 22 f0    	mov    %ax,0xf0227290
f0103dcb:	66 c7 05 92 72 22 f0 	movw   $0x8,0xf0227292
f0103dd2:	08 00 
f0103dd4:	c6 05 94 72 22 f0 00 	movb   $0x0,0xf0227294
f0103ddb:	c6 05 95 72 22 f0 8e 	movb   $0x8e,0xf0227295
f0103de2:	c1 e8 10             	shr    $0x10,%eax
f0103de5:	66 a3 96 72 22 f0    	mov    %ax,0xf0227296
	SETGATE(idt[T_BRKPT], 0, GD_KT, handler_brkpt, 3);
f0103deb:	b8 6e 47 10 f0       	mov    $0xf010476e,%eax
f0103df0:	66 a3 98 72 22 f0    	mov    %ax,0xf0227298
f0103df6:	66 c7 05 9a 72 22 f0 	movw   $0x8,0xf022729a
f0103dfd:	08 00 
f0103dff:	c6 05 9c 72 22 f0 00 	movb   $0x0,0xf022729c
f0103e06:	c6 05 9d 72 22 f0 ee 	movb   $0xee,0xf022729d
f0103e0d:	c1 e8 10             	shr    $0x10,%eax
f0103e10:	66 a3 9e 72 22 f0    	mov    %ax,0xf022729e
	SETGATE(idt[T_OFLOW], 0, GD_KT, handler_oflow, 0);
f0103e16:	b8 74 47 10 f0       	mov    $0xf0104774,%eax
f0103e1b:	66 a3 a0 72 22 f0    	mov    %ax,0xf02272a0
f0103e21:	66 c7 05 a2 72 22 f0 	movw   $0x8,0xf02272a2
f0103e28:	08 00 
f0103e2a:	c6 05 a4 72 22 f0 00 	movb   $0x0,0xf02272a4
f0103e31:	c6 05 a5 72 22 f0 8e 	movb   $0x8e,0xf02272a5
f0103e38:	c1 e8 10             	shr    $0x10,%eax
f0103e3b:	66 a3 a6 72 22 f0    	mov    %ax,0xf02272a6
	SETGATE(idt[T_BOUND], 0, GD_KT, handler_bound, 0);
f0103e41:	b8 7a 47 10 f0       	mov    $0xf010477a,%eax
f0103e46:	66 a3 a8 72 22 f0    	mov    %ax,0xf02272a8
f0103e4c:	66 c7 05 aa 72 22 f0 	movw   $0x8,0xf02272aa
f0103e53:	08 00 
f0103e55:	c6 05 ac 72 22 f0 00 	movb   $0x0,0xf02272ac
f0103e5c:	c6 05 ad 72 22 f0 8e 	movb   $0x8e,0xf02272ad
f0103e63:	c1 e8 10             	shr    $0x10,%eax
f0103e66:	66 a3 ae 72 22 f0    	mov    %ax,0xf02272ae
	SETGATE(idt[T_ILLOP], 0, GD_KT, handler_illop, 0);
f0103e6c:	b8 80 47 10 f0       	mov    $0xf0104780,%eax
f0103e71:	66 a3 b0 72 22 f0    	mov    %ax,0xf02272b0
f0103e77:	66 c7 05 b2 72 22 f0 	movw   $0x8,0xf02272b2
f0103e7e:	08 00 
f0103e80:	c6 05 b4 72 22 f0 00 	movb   $0x0,0xf02272b4
f0103e87:	c6 05 b5 72 22 f0 8e 	movb   $0x8e,0xf02272b5
f0103e8e:	c1 e8 10             	shr    $0x10,%eax
f0103e91:	66 a3 b6 72 22 f0    	mov    %ax,0xf02272b6
	SETGATE(idt[T_DEVICE], 0, GD_KT, handler_device, 0);
f0103e97:	b8 86 47 10 f0       	mov    $0xf0104786,%eax
f0103e9c:	66 a3 b8 72 22 f0    	mov    %ax,0xf02272b8
f0103ea2:	66 c7 05 ba 72 22 f0 	movw   $0x8,0xf02272ba
f0103ea9:	08 00 
f0103eab:	c6 05 bc 72 22 f0 00 	movb   $0x0,0xf02272bc
f0103eb2:	c6 05 bd 72 22 f0 8e 	movb   $0x8e,0xf02272bd
f0103eb9:	c1 e8 10             	shr    $0x10,%eax
f0103ebc:	66 a3 be 72 22 f0    	mov    %ax,0xf02272be
	SETGATE(idt[T_DBLFLT], 0, GD_KT, handler_dblflt, 0);
f0103ec2:	b8 8c 47 10 f0       	mov    $0xf010478c,%eax
f0103ec7:	66 a3 c0 72 22 f0    	mov    %ax,0xf02272c0
f0103ecd:	66 c7 05 c2 72 22 f0 	movw   $0x8,0xf02272c2
f0103ed4:	08 00 
f0103ed6:	c6 05 c4 72 22 f0 00 	movb   $0x0,0xf02272c4
f0103edd:	c6 05 c5 72 22 f0 8e 	movb   $0x8e,0xf02272c5
f0103ee4:	c1 e8 10             	shr    $0x10,%eax
f0103ee7:	66 a3 c6 72 22 f0    	mov    %ax,0xf02272c6
	SETGATE(idt[T_TSS], 0, GD_KT, handler_tss, 0);
f0103eed:	b8 90 47 10 f0       	mov    $0xf0104790,%eax
f0103ef2:	66 a3 d0 72 22 f0    	mov    %ax,0xf02272d0
f0103ef8:	66 c7 05 d2 72 22 f0 	movw   $0x8,0xf02272d2
f0103eff:	08 00 
f0103f01:	c6 05 d4 72 22 f0 00 	movb   $0x0,0xf02272d4
f0103f08:	c6 05 d5 72 22 f0 8e 	movb   $0x8e,0xf02272d5
f0103f0f:	c1 e8 10             	shr    $0x10,%eax
f0103f12:	66 a3 d6 72 22 f0    	mov    %ax,0xf02272d6
	SETGATE(idt[T_SEGNP], 0, GD_KT, handler_segnp, 0);
f0103f18:	b8 94 47 10 f0       	mov    $0xf0104794,%eax
f0103f1d:	66 a3 d8 72 22 f0    	mov    %ax,0xf02272d8
f0103f23:	66 c7 05 da 72 22 f0 	movw   $0x8,0xf02272da
f0103f2a:	08 00 
f0103f2c:	c6 05 dc 72 22 f0 00 	movb   $0x0,0xf02272dc
f0103f33:	c6 05 dd 72 22 f0 8e 	movb   $0x8e,0xf02272dd
f0103f3a:	c1 e8 10             	shr    $0x10,%eax
f0103f3d:	66 a3 de 72 22 f0    	mov    %ax,0xf02272de
	SETGATE(idt[T_STACK], 0, GD_KT, handler_stack, 0);
f0103f43:	b8 98 47 10 f0       	mov    $0xf0104798,%eax
f0103f48:	66 a3 e0 72 22 f0    	mov    %ax,0xf02272e0
f0103f4e:	66 c7 05 e2 72 22 f0 	movw   $0x8,0xf02272e2
f0103f55:	08 00 
f0103f57:	c6 05 e4 72 22 f0 00 	movb   $0x0,0xf02272e4
f0103f5e:	c6 05 e5 72 22 f0 8e 	movb   $0x8e,0xf02272e5
f0103f65:	c1 e8 10             	shr    $0x10,%eax
f0103f68:	66 a3 e6 72 22 f0    	mov    %ax,0xf02272e6
	SETGATE(idt[T_GPFLT], 0, GD_KT, handler_gpflt, 0);
f0103f6e:	b8 9c 47 10 f0       	mov    $0xf010479c,%eax
f0103f73:	66 a3 e8 72 22 f0    	mov    %ax,0xf02272e8
f0103f79:	66 c7 05 ea 72 22 f0 	movw   $0x8,0xf02272ea
f0103f80:	08 00 
f0103f82:	c6 05 ec 72 22 f0 00 	movb   $0x0,0xf02272ec
f0103f89:	c6 05 ed 72 22 f0 8e 	movb   $0x8e,0xf02272ed
f0103f90:	c1 e8 10             	shr    $0x10,%eax
f0103f93:	66 a3 ee 72 22 f0    	mov    %ax,0xf02272ee
	SETGATE(idt[T_PGFLT], 0, GD_KT, handler_pgflt, 0);
f0103f99:	b8 a0 47 10 f0       	mov    $0xf01047a0,%eax
f0103f9e:	66 a3 f0 72 22 f0    	mov    %ax,0xf02272f0
f0103fa4:	66 c7 05 f2 72 22 f0 	movw   $0x8,0xf02272f2
f0103fab:	08 00 
f0103fad:	c6 05 f4 72 22 f0 00 	movb   $0x0,0xf02272f4
f0103fb4:	c6 05 f5 72 22 f0 8e 	movb   $0x8e,0xf02272f5
f0103fbb:	c1 e8 10             	shr    $0x10,%eax
f0103fbe:	66 a3 f6 72 22 f0    	mov    %ax,0xf02272f6
	SETGATE(idt[T_FPERR], 0, GD_KT, handler_fperr, 0);
f0103fc4:	b8 a4 47 10 f0       	mov    $0xf01047a4,%eax
f0103fc9:	66 a3 00 73 22 f0    	mov    %ax,0xf0227300
f0103fcf:	66 c7 05 02 73 22 f0 	movw   $0x8,0xf0227302
f0103fd6:	08 00 
f0103fd8:	c6 05 04 73 22 f0 00 	movb   $0x0,0xf0227304
f0103fdf:	c6 05 05 73 22 f0 8e 	movb   $0x8e,0xf0227305
f0103fe6:	c1 e8 10             	shr    $0x10,%eax
f0103fe9:	66 a3 06 73 22 f0    	mov    %ax,0xf0227306
	SETGATE(idt[T_ALIGN], 0, GD_KT, handler_align, 0);
f0103fef:	b8 aa 47 10 f0       	mov    $0xf01047aa,%eax
f0103ff4:	66 a3 08 73 22 f0    	mov    %ax,0xf0227308
f0103ffa:	66 c7 05 0a 73 22 f0 	movw   $0x8,0xf022730a
f0104001:	08 00 
f0104003:	c6 05 0c 73 22 f0 00 	movb   $0x0,0xf022730c
f010400a:	c6 05 0d 73 22 f0 8e 	movb   $0x8e,0xf022730d
f0104011:	c1 e8 10             	shr    $0x10,%eax
f0104014:	66 a3 0e 73 22 f0    	mov    %ax,0xf022730e
	SETGATE(idt[T_MCHK], 0, GD_KT, handler_mchk, 0);
f010401a:	b8 ae 47 10 f0       	mov    $0xf01047ae,%eax
f010401f:	66 a3 10 73 22 f0    	mov    %ax,0xf0227310
f0104025:	66 c7 05 12 73 22 f0 	movw   $0x8,0xf0227312
f010402c:	08 00 
f010402e:	c6 05 14 73 22 f0 00 	movb   $0x0,0xf0227314
f0104035:	c6 05 15 73 22 f0 8e 	movb   $0x8e,0xf0227315
f010403c:	c1 e8 10             	shr    $0x10,%eax
f010403f:	66 a3 16 73 22 f0    	mov    %ax,0xf0227316
	SETGATE(idt[T_SIMDERR], 0, GD_KT, handler_simderr, 0);
f0104045:	b8 b4 47 10 f0       	mov    $0xf01047b4,%eax
f010404a:	66 a3 18 73 22 f0    	mov    %ax,0xf0227318
f0104050:	66 c7 05 1a 73 22 f0 	movw   $0x8,0xf022731a
f0104057:	08 00 
f0104059:	c6 05 1c 73 22 f0 00 	movb   $0x0,0xf022731c
f0104060:	c6 05 1d 73 22 f0 8e 	movb   $0x8e,0xf022731d
f0104067:	c1 e8 10             	shr    $0x10,%eax
f010406a:	66 a3 1e 73 22 f0    	mov    %ax,0xf022731e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler_syscall, 3);
f0104070:	b8 ba 47 10 f0       	mov    $0xf01047ba,%eax
f0104075:	66 a3 00 74 22 f0    	mov    %ax,0xf0227400
f010407b:	66 c7 05 02 74 22 f0 	movw   $0x8,0xf0227402
f0104082:	08 00 
f0104084:	c6 05 04 74 22 f0 00 	movb   $0x0,0xf0227404
f010408b:	c6 05 05 74 22 f0 ee 	movb   $0xee,0xf0227405
f0104092:	c1 e8 10             	shr    $0x10,%eax
f0104095:	66 a3 06 74 22 f0    	mov    %ax,0xf0227406
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, handler_timer, 0);
f010409b:	b8 c0 47 10 f0       	mov    $0xf01047c0,%eax
f01040a0:	66 a3 80 73 22 f0    	mov    %ax,0xf0227380
f01040a6:	66 c7 05 82 73 22 f0 	movw   $0x8,0xf0227382
f01040ad:	08 00 
f01040af:	c6 05 84 73 22 f0 00 	movb   $0x0,0xf0227384
f01040b6:	c6 05 85 73 22 f0 8e 	movb   $0x8e,0xf0227385
f01040bd:	c1 e8 10             	shr    $0x10,%eax
f01040c0:	66 a3 86 73 22 f0    	mov    %ax,0xf0227386
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, handler_kbd, 0);
f01040c6:	b8 c6 47 10 f0       	mov    $0xf01047c6,%eax
f01040cb:	66 a3 88 73 22 f0    	mov    %ax,0xf0227388
f01040d1:	66 c7 05 8a 73 22 f0 	movw   $0x8,0xf022738a
f01040d8:	08 00 
f01040da:	c6 05 8c 73 22 f0 00 	movb   $0x0,0xf022738c
f01040e1:	c6 05 8d 73 22 f0 8e 	movb   $0x8e,0xf022738d
f01040e8:	c1 e8 10             	shr    $0x10,%eax
f01040eb:	66 a3 8e 73 22 f0    	mov    %ax,0xf022738e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, handler_serial, 0);
f01040f1:	b8 cc 47 10 f0       	mov    $0xf01047cc,%eax
f01040f6:	66 a3 a0 73 22 f0    	mov    %ax,0xf02273a0
f01040fc:	66 c7 05 a2 73 22 f0 	movw   $0x8,0xf02273a2
f0104103:	08 00 
f0104105:	c6 05 a4 73 22 f0 00 	movb   $0x0,0xf02273a4
f010410c:	c6 05 a5 73 22 f0 8e 	movb   $0x8e,0xf02273a5
f0104113:	c1 e8 10             	shr    $0x10,%eax
f0104116:	66 a3 a6 73 22 f0    	mov    %ax,0xf02273a6
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, handler_spurious, 0);
f010411c:	b8 d2 47 10 f0       	mov    $0xf01047d2,%eax
f0104121:	66 a3 b8 73 22 f0    	mov    %ax,0xf02273b8
f0104127:	66 c7 05 ba 73 22 f0 	movw   $0x8,0xf02273ba
f010412e:	08 00 
f0104130:	c6 05 bc 73 22 f0 00 	movb   $0x0,0xf02273bc
f0104137:	c6 05 bd 73 22 f0 8e 	movb   $0x8e,0xf02273bd
f010413e:	c1 e8 10             	shr    $0x10,%eax
f0104141:	66 a3 be 73 22 f0    	mov    %ax,0xf02273be
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, handler_ide, 0);
f0104147:	b8 d8 47 10 f0       	mov    $0xf01047d8,%eax
f010414c:	66 a3 f0 73 22 f0    	mov    %ax,0xf02273f0
f0104152:	66 c7 05 f2 73 22 f0 	movw   $0x8,0xf02273f2
f0104159:	08 00 
f010415b:	c6 05 f4 73 22 f0 00 	movb   $0x0,0xf02273f4
f0104162:	c6 05 f5 73 22 f0 8e 	movb   $0x8e,0xf02273f5
f0104169:	c1 e8 10             	shr    $0x10,%eax
f010416c:	66 a3 f6 73 22 f0    	mov    %ax,0xf02273f6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, handler_error, 0);
f0104172:	b8 de 47 10 f0       	mov    $0xf01047de,%eax
f0104177:	66 a3 18 74 22 f0    	mov    %ax,0xf0227418
f010417d:	66 c7 05 1a 74 22 f0 	movw   $0x8,0xf022741a
f0104184:	08 00 
f0104186:	c6 05 1c 74 22 f0 00 	movb   $0x0,0xf022741c
f010418d:	c6 05 1d 74 22 f0 8e 	movb   $0x8e,0xf022741d
f0104194:	c1 e8 10             	shr    $0x10,%eax
f0104197:	66 a3 1e 74 22 f0    	mov    %ax,0xf022741e
	trap_init_percpu();
f010419d:	e8 e4 fa ff ff       	call   f0103c86 <trap_init_percpu>
}
f01041a2:	c9                   	leave  
f01041a3:	c3                   	ret    

f01041a4 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01041a4:	55                   	push   %ebp
f01041a5:	89 e5                	mov    %esp,%ebp
f01041a7:	53                   	push   %ebx
f01041a8:	83 ec 0c             	sub    $0xc,%esp
f01041ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01041ae:	ff 33                	push   (%ebx)
f01041b0:	68 9b 7e 10 f0       	push   $0xf0107e9b
f01041b5:	e8 b8 fa ff ff       	call   f0103c72 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01041ba:	83 c4 08             	add    $0x8,%esp
f01041bd:	ff 73 04             	push   0x4(%ebx)
f01041c0:	68 aa 7e 10 f0       	push   $0xf0107eaa
f01041c5:	e8 a8 fa ff ff       	call   f0103c72 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01041ca:	83 c4 08             	add    $0x8,%esp
f01041cd:	ff 73 08             	push   0x8(%ebx)
f01041d0:	68 b9 7e 10 f0       	push   $0xf0107eb9
f01041d5:	e8 98 fa ff ff       	call   f0103c72 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01041da:	83 c4 08             	add    $0x8,%esp
f01041dd:	ff 73 0c             	push   0xc(%ebx)
f01041e0:	68 c8 7e 10 f0       	push   $0xf0107ec8
f01041e5:	e8 88 fa ff ff       	call   f0103c72 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01041ea:	83 c4 08             	add    $0x8,%esp
f01041ed:	ff 73 10             	push   0x10(%ebx)
f01041f0:	68 d7 7e 10 f0       	push   $0xf0107ed7
f01041f5:	e8 78 fa ff ff       	call   f0103c72 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01041fa:	83 c4 08             	add    $0x8,%esp
f01041fd:	ff 73 14             	push   0x14(%ebx)
f0104200:	68 e6 7e 10 f0       	push   $0xf0107ee6
f0104205:	e8 68 fa ff ff       	call   f0103c72 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010420a:	83 c4 08             	add    $0x8,%esp
f010420d:	ff 73 18             	push   0x18(%ebx)
f0104210:	68 f5 7e 10 f0       	push   $0xf0107ef5
f0104215:	e8 58 fa ff ff       	call   f0103c72 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010421a:	83 c4 08             	add    $0x8,%esp
f010421d:	ff 73 1c             	push   0x1c(%ebx)
f0104220:	68 04 7f 10 f0       	push   $0xf0107f04
f0104225:	e8 48 fa ff ff       	call   f0103c72 <cprintf>
}
f010422a:	83 c4 10             	add    $0x10,%esp
f010422d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104230:	c9                   	leave  
f0104231:	c3                   	ret    

f0104232 <print_trapframe>:
{
f0104232:	55                   	push   %ebp
f0104233:	89 e5                	mov    %esp,%ebp
f0104235:	56                   	push   %esi
f0104236:	53                   	push   %ebx
f0104237:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010423a:	e8 5d 1f 00 00       	call   f010619c <cpunum>
f010423f:	83 ec 04             	sub    $0x4,%esp
f0104242:	50                   	push   %eax
f0104243:	53                   	push   %ebx
f0104244:	68 68 7f 10 f0       	push   $0xf0107f68
f0104249:	e8 24 fa ff ff       	call   f0103c72 <cprintf>
	print_regs(&tf->tf_regs);
f010424e:	89 1c 24             	mov    %ebx,(%esp)
f0104251:	e8 4e ff ff ff       	call   f01041a4 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104256:	83 c4 08             	add    $0x8,%esp
f0104259:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010425d:	50                   	push   %eax
f010425e:	68 86 7f 10 f0       	push   $0xf0107f86
f0104263:	e8 0a fa ff ff       	call   f0103c72 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104268:	83 c4 08             	add    $0x8,%esp
f010426b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010426f:	50                   	push   %eax
f0104270:	68 99 7f 10 f0       	push   $0xf0107f99
f0104275:	e8 f8 f9 ff ff       	call   f0103c72 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010427a:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f010427d:	83 c4 10             	add    $0x10,%esp
f0104280:	83 f8 13             	cmp    $0x13,%eax
f0104283:	0f 86 da 00 00 00    	jbe    f0104363 <print_trapframe+0x131>
		return "System call";
f0104289:	ba 13 7f 10 f0       	mov    $0xf0107f13,%edx
	if (trapno == T_SYSCALL)
f010428e:	83 f8 30             	cmp    $0x30,%eax
f0104291:	74 13                	je     f01042a6 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104293:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104296:	83 fa 0f             	cmp    $0xf,%edx
f0104299:	ba 1f 7f 10 f0       	mov    $0xf0107f1f,%edx
f010429e:	b9 2e 7f 10 f0       	mov    $0xf0107f2e,%ecx
f01042a3:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01042a6:	83 ec 04             	sub    $0x4,%esp
f01042a9:	52                   	push   %edx
f01042aa:	50                   	push   %eax
f01042ab:	68 ac 7f 10 f0       	push   $0xf0107fac
f01042b0:	e8 bd f9 ff ff       	call   f0103c72 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01042b5:	83 c4 10             	add    $0x10,%esp
f01042b8:	39 1d 80 7a 22 f0    	cmp    %ebx,0xf0227a80
f01042be:	0f 84 ab 00 00 00    	je     f010436f <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f01042c4:	83 ec 08             	sub    $0x8,%esp
f01042c7:	ff 73 2c             	push   0x2c(%ebx)
f01042ca:	68 cd 7f 10 f0       	push   $0xf0107fcd
f01042cf:	e8 9e f9 ff ff       	call   f0103c72 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01042d4:	83 c4 10             	add    $0x10,%esp
f01042d7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01042db:	0f 85 b1 00 00 00    	jne    f0104392 <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f01042e1:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f01042e4:	a8 01                	test   $0x1,%al
f01042e6:	b9 41 7f 10 f0       	mov    $0xf0107f41,%ecx
f01042eb:	ba 4c 7f 10 f0       	mov    $0xf0107f4c,%edx
f01042f0:	0f 44 ca             	cmove  %edx,%ecx
f01042f3:	a8 02                	test   $0x2,%al
f01042f5:	ba 58 7f 10 f0       	mov    $0xf0107f58,%edx
f01042fa:	be 5e 7f 10 f0       	mov    $0xf0107f5e,%esi
f01042ff:	0f 44 d6             	cmove  %esi,%edx
f0104302:	a8 04                	test   $0x4,%al
f0104304:	b8 63 7f 10 f0       	mov    $0xf0107f63,%eax
f0104309:	be 98 80 10 f0       	mov    $0xf0108098,%esi
f010430e:	0f 44 c6             	cmove  %esi,%eax
f0104311:	51                   	push   %ecx
f0104312:	52                   	push   %edx
f0104313:	50                   	push   %eax
f0104314:	68 db 7f 10 f0       	push   $0xf0107fdb
f0104319:	e8 54 f9 ff ff       	call   f0103c72 <cprintf>
f010431e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104321:	83 ec 08             	sub    $0x8,%esp
f0104324:	ff 73 30             	push   0x30(%ebx)
f0104327:	68 ea 7f 10 f0       	push   $0xf0107fea
f010432c:	e8 41 f9 ff ff       	call   f0103c72 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104331:	83 c4 08             	add    $0x8,%esp
f0104334:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104338:	50                   	push   %eax
f0104339:	68 f9 7f 10 f0       	push   $0xf0107ff9
f010433e:	e8 2f f9 ff ff       	call   f0103c72 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104343:	83 c4 08             	add    $0x8,%esp
f0104346:	ff 73 38             	push   0x38(%ebx)
f0104349:	68 0c 80 10 f0       	push   $0xf010800c
f010434e:	e8 1f f9 ff ff       	call   f0103c72 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104353:	83 c4 10             	add    $0x10,%esp
f0104356:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010435a:	75 4b                	jne    f01043a7 <print_trapframe+0x175>
}
f010435c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010435f:	5b                   	pop    %ebx
f0104360:	5e                   	pop    %esi
f0104361:	5d                   	pop    %ebp
f0104362:	c3                   	ret    
		return excnames[trapno];
f0104363:	8b 14 85 40 82 10 f0 	mov    -0xfef7dc0(,%eax,4),%edx
f010436a:	e9 37 ff ff ff       	jmp    f01042a6 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010436f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104373:	0f 85 4b ff ff ff    	jne    f01042c4 <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104379:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010437c:	83 ec 08             	sub    $0x8,%esp
f010437f:	50                   	push   %eax
f0104380:	68 be 7f 10 f0       	push   $0xf0107fbe
f0104385:	e8 e8 f8 ff ff       	call   f0103c72 <cprintf>
f010438a:	83 c4 10             	add    $0x10,%esp
f010438d:	e9 32 ff ff ff       	jmp    f01042c4 <print_trapframe+0x92>
		cprintf("\n");
f0104392:	83 ec 0c             	sub    $0xc,%esp
f0104395:	68 e8 73 10 f0       	push   $0xf01073e8
f010439a:	e8 d3 f8 ff ff       	call   f0103c72 <cprintf>
f010439f:	83 c4 10             	add    $0x10,%esp
f01043a2:	e9 7a ff ff ff       	jmp    f0104321 <print_trapframe+0xef>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01043a7:	83 ec 08             	sub    $0x8,%esp
f01043aa:	ff 73 3c             	push   0x3c(%ebx)
f01043ad:	68 1b 80 10 f0       	push   $0xf010801b
f01043b2:	e8 bb f8 ff ff       	call   f0103c72 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01043b7:	83 c4 08             	add    $0x8,%esp
f01043ba:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01043be:	50                   	push   %eax
f01043bf:	68 2a 80 10 f0       	push   $0xf010802a
f01043c4:	e8 a9 f8 ff ff       	call   f0103c72 <cprintf>
f01043c9:	83 c4 10             	add    $0x10,%esp
}
f01043cc:	eb 8e                	jmp    f010435c <print_trapframe+0x12a>

f01043ce <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01043ce:	55                   	push   %ebp
f01043cf:	89 e5                	mov    %esp,%ebp
f01043d1:	57                   	push   %edi
f01043d2:	56                   	push   %esi
f01043d3:	53                   	push   %ebx
f01043d4:	83 ec 0c             	sub    $0xc,%esp
f01043d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01043da:	0f 20 d6             	mov    %cr2,%esi
	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	if ((tf->tf_cs & 3) == 0) {
f01043dd:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01043e1:	74 5d                	je     f0104440 <page_fault_handler+0x72>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f01043e3:	e8 b4 1d 00 00       	call   f010619c <cpunum>
f01043e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043eb:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01043f1:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01043f5:	75 60                	jne    f0104457 <page_fault_handler+0x89>
		curenv->env_tf.tf_esp = (uintptr_t) utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043f7:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01043fa:	e8 9d 1d 00 00       	call   f010619c <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043ff:	57                   	push   %edi
f0104400:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104401:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104404:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f010440a:	ff 70 48             	push   0x48(%eax)
f010440d:	68 14 82 10 f0       	push   $0xf0108214
f0104412:	e8 5b f8 ff ff       	call   f0103c72 <cprintf>
	print_trapframe(tf);
f0104417:	89 1c 24             	mov    %ebx,(%esp)
f010441a:	e8 13 fe ff ff       	call   f0104232 <print_trapframe>
	env_destroy(curenv);
f010441f:	e8 78 1d 00 00       	call   f010619c <cpunum>
f0104424:	83 c4 04             	add    $0x4,%esp
f0104427:	6b c0 74             	imul   $0x74,%eax,%eax
f010442a:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f0104430:	e8 2d f5 ff ff       	call   f0103962 <env_destroy>
}
f0104435:	83 c4 10             	add    $0x10,%esp
f0104438:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010443b:	5b                   	pop    %ebx
f010443c:	5e                   	pop    %esi
f010443d:	5f                   	pop    %edi
f010443e:	5d                   	pop    %ebp
f010443f:	c3                   	ret    
		panic("page_fault_handler: page fault in kernel mode\n");
f0104440:	83 ec 04             	sub    $0x4,%esp
f0104443:	68 e4 81 10 f0       	push   $0xf01081e4
f0104448:	68 5e 01 00 00       	push   $0x15e
f010444d:	68 3d 80 10 f0       	push   $0xf010803d
f0104452:	e8 e9 bb ff ff       	call   f0100040 <_panic>
		if (ROUNDDOWN(tf->tf_esp, PGSIZE) == UXSTACKTOP - PGSIZE) {
f0104457:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010445a:	89 c2                	mov    %eax,%edx
f010445c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
			utf = (struct UTrapframe *) (UXSTACKTOP - sizeof(struct UTrapframe));
f0104462:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if (ROUNDDOWN(tf->tf_esp, PGSIZE) == UXSTACKTOP - PGSIZE) {
f0104467:	81 fa 00 f0 bf ee    	cmp    $0xeebff000,%edx
f010446d:	0f 84 8b 00 00 00    	je     f01044fe <page_fault_handler+0x130>
		user_mem_assert(curenv, (void *) utf, 1, PTE_W);
f0104473:	e8 24 1d 00 00       	call   f010619c <cpunum>
f0104478:	6a 02                	push   $0x2
f010447a:	6a 01                	push   $0x1
f010447c:	57                   	push   %edi
f010447d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104480:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f0104486:	e8 1e ee ff ff       	call   f01032a9 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f010448b:	89 fa                	mov    %edi,%edx
f010448d:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f010448f:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104492:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0104495:	8d 7f 08             	lea    0x8(%edi),%edi
f0104498:	b9 08 00 00 00       	mov    $0x8,%ecx
f010449d:	89 de                	mov    %ebx,%esi
f010449f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f01044a1:	8b 43 30             	mov    0x30(%ebx),%eax
f01044a4:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f01044a7:	8b 43 38             	mov    0x38(%ebx),%eax
f01044aa:	89 d7                	mov    %edx,%edi
f01044ac:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;	
f01044af:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01044b2:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t) curenv->env_pgfault_upcall;
f01044b5:	e8 e2 1c 00 00       	call   f010619c <cpunum>
f01044ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01044bd:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01044c3:	8b 58 64             	mov    0x64(%eax),%ebx
f01044c6:	e8 d1 1c 00 00       	call   f010619c <cpunum>
f01044cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ce:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01044d4:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp = (uintptr_t) utf;
f01044d7:	e8 c0 1c 00 00       	call   f010619c <cpunum>
f01044dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01044df:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01044e5:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f01044e8:	e8 af 1c 00 00       	call   f010619c <cpunum>
f01044ed:	83 c4 04             	add    $0x4,%esp
f01044f0:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f3:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f01044f9:	e8 03 f5 ff ff       	call   f0103a01 <env_run>
			utf = (struct UTrapframe *) (tf->tf_esp - sizeof(struct UTrapframe) - 4);
f01044fe:	83 e8 38             	sub    $0x38,%eax
f0104501:	89 c7                	mov    %eax,%edi
f0104503:	e9 6b ff ff ff       	jmp    f0104473 <page_fault_handler+0xa5>

f0104508 <trap>:
{
f0104508:	55                   	push   %ebp
f0104509:	89 e5                	mov    %esp,%ebp
f010450b:	57                   	push   %edi
f010450c:	56                   	push   %esi
f010450d:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104510:	fc                   	cld    
	if (panicstr)
f0104511:	83 3d 00 70 22 f0 00 	cmpl   $0x0,0xf0227000
f0104518:	74 01                	je     f010451b <trap+0x13>
		asm volatile("hlt");
f010451a:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010451b:	e8 7c 1c 00 00       	call   f010619c <cpunum>
f0104520:	6b d0 74             	imul   $0x74,%eax,%edx
f0104523:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104526:	b8 01 00 00 00       	mov    $0x1,%eax
f010452b:	f0 87 82 20 80 26 f0 	lock xchg %eax,-0xfd97fe0(%edx)
f0104532:	83 f8 02             	cmp    $0x2,%eax
f0104535:	0f 84 b0 00 00 00    	je     f01045eb <trap+0xe3>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010453b:	9c                   	pushf  
f010453c:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f010453d:	f6 c4 02             	test   $0x2,%ah
f0104540:	0f 85 ba 00 00 00    	jne    f0104600 <trap+0xf8>
	if ((tf->tf_cs & 3) == 3) {
f0104546:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010454a:	83 e0 03             	and    $0x3,%eax
f010454d:	66 83 f8 03          	cmp    $0x3,%ax
f0104551:	0f 84 c2 00 00 00    	je     f0104619 <trap+0x111>
	last_tf = tf;
f0104557:	89 35 80 7a 22 f0    	mov    %esi,0xf0227a80
	if (tf->tf_trapno == T_PGFLT) {
f010455d:	8b 46 28             	mov    0x28(%esi),%eax
f0104560:	83 f8 0e             	cmp    $0xe,%eax
f0104563:	0f 84 55 01 00 00    	je     f01046be <trap+0x1b6>
	} else if (tf->tf_trapno == T_BRKPT) {
f0104569:	83 f8 03             	cmp    $0x3,%eax
f010456c:	0f 84 5d 01 00 00    	je     f01046cf <trap+0x1c7>
	} else if (tf->tf_trapno == T_SYSCALL) {
f0104572:	83 f8 30             	cmp    $0x30,%eax
f0104575:	0f 84 65 01 00 00    	je     f01046e0 <trap+0x1d8>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010457b:	83 f8 27             	cmp    $0x27,%eax
f010457e:	0f 84 80 01 00 00    	je     f0104704 <trap+0x1fc>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104584:	83 f8 20             	cmp    $0x20,%eax
f0104587:	0f 84 94 01 00 00    	je     f0104721 <trap+0x219>
	print_trapframe(tf);
f010458d:	83 ec 0c             	sub    $0xc,%esp
f0104590:	56                   	push   %esi
f0104591:	e8 9c fc ff ff       	call   f0104232 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104596:	83 c4 10             	add    $0x10,%esp
f0104599:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010459e:	0f 84 87 01 00 00    	je     f010472b <trap+0x223>
		env_destroy(curenv);
f01045a4:	e8 f3 1b 00 00       	call   f010619c <cpunum>
f01045a9:	83 ec 0c             	sub    $0xc,%esp
f01045ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01045af:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f01045b5:	e8 a8 f3 ff ff       	call   f0103962 <env_destroy>
		return;
f01045ba:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f01045bd:	e8 da 1b 00 00       	call   f010619c <cpunum>
f01045c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c5:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f01045cc:	74 18                	je     f01045e6 <trap+0xde>
f01045ce:	e8 c9 1b 00 00       	call   f010619c <cpunum>
f01045d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d6:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01045dc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01045e0:	0f 84 5c 01 00 00    	je     f0104742 <trap+0x23a>
		sched_yield();
f01045e6:	e8 dd 02 00 00       	call   f01048c8 <sched_yield>
	spin_lock(&kernel_lock);
f01045eb:	83 ec 0c             	sub    $0xc,%esp
f01045ee:	68 c0 63 12 f0       	push   $0xf01263c0
f01045f3:	e8 14 1e 00 00       	call   f010640c <spin_lock>
}
f01045f8:	83 c4 10             	add    $0x10,%esp
f01045fb:	e9 3b ff ff ff       	jmp    f010453b <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f0104600:	68 49 80 10 f0       	push   $0xf0108049
f0104605:	68 21 71 10 f0       	push   $0xf0107121
f010460a:	68 29 01 00 00       	push   $0x129
f010460f:	68 3d 80 10 f0       	push   $0xf010803d
f0104614:	e8 27 ba ff ff       	call   f0100040 <_panic>
	spin_lock(&kernel_lock);
f0104619:	83 ec 0c             	sub    $0xc,%esp
f010461c:	68 c0 63 12 f0       	push   $0xf01263c0
f0104621:	e8 e6 1d 00 00       	call   f010640c <spin_lock>
		assert(curenv);
f0104626:	e8 71 1b 00 00       	call   f010619c <cpunum>
f010462b:	6b c0 74             	imul   $0x74,%eax,%eax
f010462e:	83 c4 10             	add    $0x10,%esp
f0104631:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f0104638:	74 3e                	je     f0104678 <trap+0x170>
		if (curenv->env_status == ENV_DYING) {
f010463a:	e8 5d 1b 00 00       	call   f010619c <cpunum>
f010463f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104642:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0104648:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010464c:	74 43                	je     f0104691 <trap+0x189>
		curenv->env_tf = *tf;
f010464e:	e8 49 1b 00 00       	call   f010619c <cpunum>
f0104653:	6b c0 74             	imul   $0x74,%eax,%eax
f0104656:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f010465c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104661:	89 c7                	mov    %eax,%edi
f0104663:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104665:	e8 32 1b 00 00       	call   f010619c <cpunum>
f010466a:	6b c0 74             	imul   $0x74,%eax,%eax
f010466d:	8b b0 28 80 26 f0    	mov    -0xfd97fd8(%eax),%esi
f0104673:	e9 df fe ff ff       	jmp    f0104557 <trap+0x4f>
		assert(curenv);
f0104678:	68 62 80 10 f0       	push   $0xf0108062
f010467d:	68 21 71 10 f0       	push   $0xf0107121
f0104682:	68 31 01 00 00       	push   $0x131
f0104687:	68 3d 80 10 f0       	push   $0xf010803d
f010468c:	e8 af b9 ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f0104691:	e8 06 1b 00 00       	call   f010619c <cpunum>
f0104696:	83 ec 0c             	sub    $0xc,%esp
f0104699:	6b c0 74             	imul   $0x74,%eax,%eax
f010469c:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f01046a2:	e8 de f0 ff ff       	call   f0103785 <env_free>
			curenv = NULL;
f01046a7:	e8 f0 1a 00 00       	call   f010619c <cpunum>
f01046ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01046af:	c7 80 28 80 26 f0 00 	movl   $0x0,-0xfd97fd8(%eax)
f01046b6:	00 00 00 
			sched_yield();
f01046b9:	e8 0a 02 00 00       	call   f01048c8 <sched_yield>
		page_fault_handler(tf);
f01046be:	83 ec 0c             	sub    $0xc,%esp
f01046c1:	56                   	push   %esi
f01046c2:	e8 07 fd ff ff       	call   f01043ce <page_fault_handler>
		return;
f01046c7:	83 c4 10             	add    $0x10,%esp
f01046ca:	e9 ee fe ff ff       	jmp    f01045bd <trap+0xb5>
		monitor(tf);
f01046cf:	83 ec 0c             	sub    $0xc,%esp
f01046d2:	56                   	push   %esi
f01046d3:	e8 eb c5 ff ff       	call   f0100cc3 <monitor>
		return;
f01046d8:	83 c4 10             	add    $0x10,%esp
f01046db:	e9 dd fe ff ff       	jmp    f01045bd <trap+0xb5>
		tf->tf_regs.reg_eax = syscall(
f01046e0:	83 ec 08             	sub    $0x8,%esp
f01046e3:	ff 76 04             	push   0x4(%esi)
f01046e6:	ff 36                	push   (%esi)
f01046e8:	ff 76 10             	push   0x10(%esi)
f01046eb:	ff 76 18             	push   0x18(%esi)
f01046ee:	ff 76 14             	push   0x14(%esi)
f01046f1:	ff 76 1c             	push   0x1c(%esi)
f01046f4:	e8 79 02 00 00       	call   f0104972 <syscall>
f01046f9:	89 46 1c             	mov    %eax,0x1c(%esi)
		return;
f01046fc:	83 c4 20             	add    $0x20,%esp
f01046ff:	e9 b9 fe ff ff       	jmp    f01045bd <trap+0xb5>
		cprintf("Spurious interrupt on irq 7\n");
f0104704:	83 ec 0c             	sub    $0xc,%esp
f0104707:	68 69 80 10 f0       	push   $0xf0108069
f010470c:	e8 61 f5 ff ff       	call   f0103c72 <cprintf>
		print_trapframe(tf);
f0104711:	89 34 24             	mov    %esi,(%esp)
f0104714:	e8 19 fb ff ff       	call   f0104232 <print_trapframe>
		return;
f0104719:	83 c4 10             	add    $0x10,%esp
f010471c:	e9 9c fe ff ff       	jmp    f01045bd <trap+0xb5>
		lapic_eoi();
f0104721:	e8 bd 1b 00 00       	call   f01062e3 <lapic_eoi>
		sched_yield();
f0104726:	e8 9d 01 00 00       	call   f01048c8 <sched_yield>
		panic("unhandled trap in kernel");
f010472b:	83 ec 04             	sub    $0x4,%esp
f010472e:	68 86 80 10 f0       	push   $0xf0108086
f0104733:	68 0f 01 00 00       	push   $0x10f
f0104738:	68 3d 80 10 f0       	push   $0xf010803d
f010473d:	e8 fe b8 ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f0104742:	e8 55 1a 00 00       	call   f010619c <cpunum>
f0104747:	83 ec 0c             	sub    $0xc,%esp
f010474a:	6b c0 74             	imul   $0x74,%eax,%eax
f010474d:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f0104753:	e8 a9 f2 ff ff       	call   f0103a01 <env_run>

f0104758 <handler_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(handler_divide, T_DIVIDE)
f0104758:	6a 00                	push   $0x0
f010475a:	6a 00                	push   $0x0
f010475c:	e9 83 00 00 00       	jmp    f01047e4 <_alltraps>
f0104761:	90                   	nop

f0104762 <handler_debug>:
TRAPHANDLER_NOEC(handler_debug, T_DEBUG)
f0104762:	6a 00                	push   $0x0
f0104764:	6a 01                	push   $0x1
f0104766:	eb 7c                	jmp    f01047e4 <_alltraps>

f0104768 <handler_nmi>:
TRAPHANDLER_NOEC(handler_nmi, T_NMI)
f0104768:	6a 00                	push   $0x0
f010476a:	6a 02                	push   $0x2
f010476c:	eb 76                	jmp    f01047e4 <_alltraps>

f010476e <handler_brkpt>:
TRAPHANDLER_NOEC(handler_brkpt, T_BRKPT)
f010476e:	6a 00                	push   $0x0
f0104770:	6a 03                	push   $0x3
f0104772:	eb 70                	jmp    f01047e4 <_alltraps>

f0104774 <handler_oflow>:
TRAPHANDLER_NOEC(handler_oflow, T_OFLOW)
f0104774:	6a 00                	push   $0x0
f0104776:	6a 04                	push   $0x4
f0104778:	eb 6a                	jmp    f01047e4 <_alltraps>

f010477a <handler_bound>:
TRAPHANDLER_NOEC(handler_bound, T_BOUND)
f010477a:	6a 00                	push   $0x0
f010477c:	6a 05                	push   $0x5
f010477e:	eb 64                	jmp    f01047e4 <_alltraps>

f0104780 <handler_illop>:
TRAPHANDLER_NOEC(handler_illop, T_ILLOP)
f0104780:	6a 00                	push   $0x0
f0104782:	6a 06                	push   $0x6
f0104784:	eb 5e                	jmp    f01047e4 <_alltraps>

f0104786 <handler_device>:
TRAPHANDLER_NOEC(handler_device, T_DEVICE)
f0104786:	6a 00                	push   $0x0
f0104788:	6a 07                	push   $0x7
f010478a:	eb 58                	jmp    f01047e4 <_alltraps>

f010478c <handler_dblflt>:
TRAPHANDLER(handler_dblflt, T_DBLFLT)
f010478c:	6a 08                	push   $0x8
f010478e:	eb 54                	jmp    f01047e4 <_alltraps>

f0104790 <handler_tss>:
TRAPHANDLER(handler_tss, T_TSS)
f0104790:	6a 0a                	push   $0xa
f0104792:	eb 50                	jmp    f01047e4 <_alltraps>

f0104794 <handler_segnp>:
TRAPHANDLER(handler_segnp, T_SEGNP)
f0104794:	6a 0b                	push   $0xb
f0104796:	eb 4c                	jmp    f01047e4 <_alltraps>

f0104798 <handler_stack>:
TRAPHANDLER(handler_stack, T_STACK)
f0104798:	6a 0c                	push   $0xc
f010479a:	eb 48                	jmp    f01047e4 <_alltraps>

f010479c <handler_gpflt>:
TRAPHANDLER(handler_gpflt, T_GPFLT)
f010479c:	6a 0d                	push   $0xd
f010479e:	eb 44                	jmp    f01047e4 <_alltraps>

f01047a0 <handler_pgflt>:
TRAPHANDLER(handler_pgflt, T_PGFLT)
f01047a0:	6a 0e                	push   $0xe
f01047a2:	eb 40                	jmp    f01047e4 <_alltraps>

f01047a4 <handler_fperr>:
TRAPHANDLER_NOEC(handler_fperr, T_FPERR)
f01047a4:	6a 00                	push   $0x0
f01047a6:	6a 10                	push   $0x10
f01047a8:	eb 3a                	jmp    f01047e4 <_alltraps>

f01047aa <handler_align>:
TRAPHANDLER(handler_align, T_ALIGN)
f01047aa:	6a 11                	push   $0x11
f01047ac:	eb 36                	jmp    f01047e4 <_alltraps>

f01047ae <handler_mchk>:
TRAPHANDLER_NOEC(handler_mchk, T_MCHK)
f01047ae:	6a 00                	push   $0x0
f01047b0:	6a 12                	push   $0x12
f01047b2:	eb 30                	jmp    f01047e4 <_alltraps>

f01047b4 <handler_simderr>:
TRAPHANDLER_NOEC(handler_simderr, T_SIMDERR)
f01047b4:	6a 00                	push   $0x0
f01047b6:	6a 13                	push   $0x13
f01047b8:	eb 2a                	jmp    f01047e4 <_alltraps>

f01047ba <handler_syscall>:
TRAPHANDLER_NOEC(handler_syscall, T_SYSCALL)
f01047ba:	6a 00                	push   $0x0
f01047bc:	6a 30                	push   $0x30
f01047be:	eb 24                	jmp    f01047e4 <_alltraps>

f01047c0 <handler_timer>:

TRAPHANDLER_NOEC(handler_timer, IRQ_OFFSET + IRQ_TIMER)
f01047c0:	6a 00                	push   $0x0
f01047c2:	6a 20                	push   $0x20
f01047c4:	eb 1e                	jmp    f01047e4 <_alltraps>

f01047c6 <handler_kbd>:
TRAPHANDLER_NOEC(handler_kbd, IRQ_OFFSET + IRQ_KBD)
f01047c6:	6a 00                	push   $0x0
f01047c8:	6a 21                	push   $0x21
f01047ca:	eb 18                	jmp    f01047e4 <_alltraps>

f01047cc <handler_serial>:
TRAPHANDLER_NOEC(handler_serial, IRQ_OFFSET + IRQ_SERIAL)
f01047cc:	6a 00                	push   $0x0
f01047ce:	6a 24                	push   $0x24
f01047d0:	eb 12                	jmp    f01047e4 <_alltraps>

f01047d2 <handler_spurious>:
TRAPHANDLER_NOEC(handler_spurious, IRQ_OFFSET + IRQ_SPURIOUS)
f01047d2:	6a 00                	push   $0x0
f01047d4:	6a 27                	push   $0x27
f01047d6:	eb 0c                	jmp    f01047e4 <_alltraps>

f01047d8 <handler_ide>:
TRAPHANDLER_NOEC(handler_ide, IRQ_OFFSET + IRQ_IDE)
f01047d8:	6a 00                	push   $0x0
f01047da:	6a 2e                	push   $0x2e
f01047dc:	eb 06                	jmp    f01047e4 <_alltraps>

f01047de <handler_error>:
TRAPHANDLER_NOEC(handler_error, IRQ_OFFSET + IRQ_ERROR)
f01047de:	6a 00                	push   $0x0
f01047e0:	6a 33                	push   $0x33
f01047e2:	eb 00                	jmp    f01047e4 <_alltraps>

f01047e4 <_alltraps>:

.global _alltraps
.type _alltraps, @function
.align 2
_alltraps:
	pushw $0
f01047e4:	66 6a 00             	pushw  $0x0
	pushw %ds
f01047e7:	66 1e                	pushw  %ds
	pushw $0
f01047e9:	66 6a 00             	pushw  $0x0
	pushw %es
f01047ec:	66 06                	pushw  %es
	pushal
f01047ee:	60                   	pusha  
	
	movl $GD_KD, %eax
f01047ef:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f01047f4:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01047f6:	8e c0                	mov    %eax,%es
	pushl %esp
f01047f8:	54                   	push   %esp
	call trap
f01047f9:	e8 0a fd ff ff       	call   f0104508 <trap>

f01047fe <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01047fe:	55                   	push   %ebp
f01047ff:	89 e5                	mov    %esp,%ebp
f0104801:	83 ec 08             	sub    $0x8,%esp
f0104804:	a1 70 72 22 f0       	mov    0xf0227270,%eax
f0104809:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010480c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104811:	8b 02                	mov    (%edx),%eax
f0104813:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104816:	83 f8 02             	cmp    $0x2,%eax
f0104819:	76 2d                	jbe    f0104848 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f010481b:	83 c1 01             	add    $0x1,%ecx
f010481e:	83 c2 7c             	add    $0x7c,%edx
f0104821:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104827:	75 e8                	jne    f0104811 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104829:	83 ec 0c             	sub    $0xc,%esp
f010482c:	68 90 82 10 f0       	push   $0xf0108290
f0104831:	e8 3c f4 ff ff       	call   f0103c72 <cprintf>
f0104836:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104839:	83 ec 0c             	sub    $0xc,%esp
f010483c:	6a 00                	push   $0x0
f010483e:	e8 80 c4 ff ff       	call   f0100cc3 <monitor>
f0104843:	83 c4 10             	add    $0x10,%esp
f0104846:	eb f1                	jmp    f0104839 <sched_halt+0x3b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104848:	e8 4f 19 00 00       	call   f010619c <cpunum>
f010484d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104850:	c7 80 28 80 26 f0 00 	movl   $0x0,-0xfd97fd8(%eax)
f0104857:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010485a:	a1 5c 72 22 f0       	mov    0xf022725c,%eax
	if ((uint32_t)kva < KERNBASE)
f010485f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104864:	76 50                	jbe    f01048b6 <sched_halt+0xb8>
	return (physaddr_t)kva - KERNBASE;
f0104866:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010486b:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010486e:	e8 29 19 00 00       	call   f010619c <cpunum>
f0104873:	6b d0 74             	imul   $0x74,%eax,%edx
f0104876:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104879:	b8 02 00 00 00       	mov    $0x2,%eax
f010487e:	f0 87 82 20 80 26 f0 	lock xchg %eax,-0xfd97fe0(%edx)
	spin_unlock(&kernel_lock);
f0104885:	83 ec 0c             	sub    $0xc,%esp
f0104888:	68 c0 63 12 f0       	push   $0xf01263c0
f010488d:	e8 14 1c 00 00       	call   f01064a6 <spin_unlock>
	asm volatile("pause");
f0104892:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104894:	e8 03 19 00 00       	call   f010619c <cpunum>
f0104899:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f010489c:	8b 80 30 80 26 f0    	mov    -0xfd97fd0(%eax),%eax
f01048a2:	bd 00 00 00 00       	mov    $0x0,%ebp
f01048a7:	89 c4                	mov    %eax,%esp
f01048a9:	6a 00                	push   $0x0
f01048ab:	6a 00                	push   $0x0
f01048ad:	fb                   	sti    
f01048ae:	f4                   	hlt    
f01048af:	eb fd                	jmp    f01048ae <sched_halt+0xb0>
}
f01048b1:	83 c4 10             	add    $0x10,%esp
f01048b4:	c9                   	leave  
f01048b5:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01048b6:	50                   	push   %eax
f01048b7:	68 28 68 10 f0       	push   $0xf0106828
f01048bc:	6a 47                	push   $0x47
f01048be:	68 b9 82 10 f0       	push   $0xf01082b9
f01048c3:	e8 78 b7 ff ff       	call   f0100040 <_panic>

f01048c8 <sched_yield>:
{
f01048c8:	55                   	push   %ebp
f01048c9:	89 e5                	mov    %esp,%ebp
f01048cb:	53                   	push   %ebx
f01048cc:	83 ec 04             	sub    $0x4,%esp
	uint32_t st = curenv ? ENVX(curenv->env_id) : 0;
f01048cf:	e8 c8 18 00 00       	call   f010619c <cpunum>
f01048d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01048dc:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f01048e3:	74 17                	je     f01048fc <sched_yield+0x34>
f01048e5:	e8 b2 18 00 00       	call   f010619c <cpunum>
f01048ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ed:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01048f3:	8b 48 48             	mov    0x48(%eax),%ecx
f01048f6:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
		if (envs[j].env_status == ENV_RUNNABLE) {
f01048fc:	8b 1d 70 72 22 f0    	mov    0xf0227270,%ebx
f0104902:	8d 51 01             	lea    0x1(%ecx),%edx
f0104905:	81 c1 01 04 00 00    	add    $0x401,%ecx
		uint32_t j = (st + i) % NENV;
f010490b:	89 d0                	mov    %edx,%eax
f010490d:	25 ff 03 00 00       	and    $0x3ff,%eax
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104912:	6b c0 7c             	imul   $0x7c,%eax,%eax
f0104915:	01 d8                	add    %ebx,%eax
f0104917:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010491b:	74 36                	je     f0104953 <sched_yield+0x8b>
	for (uint32_t i = 1; i <= NENV; i++) {
f010491d:	83 c2 01             	add    $0x1,%edx
f0104920:	39 ca                	cmp    %ecx,%edx
f0104922:	75 e7                	jne    f010490b <sched_yield+0x43>
	if ((curenv) && (curenv->env_status == ENV_RUNNING)) {
f0104924:	e8 73 18 00 00       	call   f010619c <cpunum>
f0104929:	6b c0 74             	imul   $0x74,%eax,%eax
f010492c:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f0104933:	74 14                	je     f0104949 <sched_yield+0x81>
f0104935:	e8 62 18 00 00       	call   f010619c <cpunum>
f010493a:	6b c0 74             	imul   $0x74,%eax,%eax
f010493d:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0104943:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104947:	74 13                	je     f010495c <sched_yield+0x94>
	sched_halt();
f0104949:	e8 b0 fe ff ff       	call   f01047fe <sched_halt>
}
f010494e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104951:	c9                   	leave  
f0104952:	c3                   	ret    
			env_run(&envs[j]);
f0104953:	83 ec 0c             	sub    $0xc,%esp
f0104956:	50                   	push   %eax
f0104957:	e8 a5 f0 ff ff       	call   f0103a01 <env_run>
		env_run(curenv);
f010495c:	e8 3b 18 00 00       	call   f010619c <cpunum>
f0104961:	83 ec 0c             	sub    $0xc,%esp
f0104964:	6b c0 74             	imul   $0x74,%eax,%eax
f0104967:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f010496d:	e8 8f f0 ff ff       	call   f0103a01 <env_run>

f0104972 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104972:	55                   	push   %ebp
f0104973:	89 e5                	mov    %esp,%ebp
f0104975:	57                   	push   %edi
f0104976:	56                   	push   %esi
f0104977:	53                   	push   %ebx
f0104978:	83 ec 1c             	sub    $0x1c,%esp
f010497b:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	

	//panic("syscall not implemented");

	switch (syscallno) {
f010497e:	83 f8 0c             	cmp    $0xc,%eax
f0104981:	0f 87 19 06 00 00    	ja     f0104fa0 <syscall+0x62e>
f0104987:	ff 24 85 10 83 10 f0 	jmp    *-0xfef7cf0(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);
f010498e:	e8 09 18 00 00       	call   f010619c <cpunum>
f0104993:	6a 04                	push   $0x4
f0104995:	ff 75 10             	push   0x10(%ebp)
f0104998:	ff 75 0c             	push   0xc(%ebp)
f010499b:	6b c0 74             	imul   $0x74,%eax,%eax
f010499e:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f01049a4:	e8 00 e9 ff ff       	call   f01032a9 <user_mem_assert>
	cprintf("%.*s", len, s);
f01049a9:	83 c4 0c             	add    $0xc,%esp
f01049ac:	ff 75 0c             	push   0xc(%ebp)
f01049af:	ff 75 10             	push   0x10(%ebp)
f01049b2:	68 c6 82 10 f0       	push   $0xf01082c6
f01049b7:	e8 b6 f2 ff ff       	call   f0103c72 <cprintf>
}
f01049bc:	83 c4 10             	add    $0x10,%esp
		case SYS_cputs:
			sys_cputs((const char *)a1, a2);
			return 0;
f01049bf:	bb 00 00 00 00       	mov    $0x0,%ebx
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		default:
			return -E_INVAL;
	}
}
f01049c4:	89 d8                	mov    %ebx,%eax
f01049c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049c9:	5b                   	pop    %ebx
f01049ca:	5e                   	pop    %esi
f01049cb:	5f                   	pop    %edi
f01049cc:	5d                   	pop    %ebp
f01049cd:	c3                   	ret    
	return cons_getc();
f01049ce:	e8 16 bc ff ff       	call   f01005e9 <cons_getc>
f01049d3:	89 c3                	mov    %eax,%ebx
			return sys_cgetc();
f01049d5:	eb ed                	jmp    f01049c4 <syscall+0x52>
			assert(curenv);
f01049d7:	e8 c0 17 00 00       	call   f010619c <cpunum>
f01049dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049df:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f01049e6:	74 13                	je     f01049fb <syscall+0x89>
	return curenv->env_id;
f01049e8:	e8 af 17 00 00       	call   f010619c <cpunum>
f01049ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01049f0:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f01049f6:	8b 58 48             	mov    0x48(%eax),%ebx
			return sys_getenvid();
f01049f9:	eb c9                	jmp    f01049c4 <syscall+0x52>
			assert(curenv);
f01049fb:	68 62 80 10 f0       	push   $0xf0108062
f0104a00:	68 21 71 10 f0       	push   $0xf0107121
f0104a05:	68 aa 01 00 00       	push   $0x1aa
f0104a0a:	68 cb 82 10 f0       	push   $0xf01082cb
f0104a0f:	e8 2c b6 ff ff       	call   f0100040 <_panic>
			assert(curenv);
f0104a14:	e8 83 17 00 00       	call   f010619c <cpunum>
f0104a19:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a1c:	83 b8 28 80 26 f0 00 	cmpl   $0x0,-0xfd97fd8(%eax)
f0104a23:	74 6a                	je     f0104a8f <syscall+0x11d>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104a25:	83 ec 04             	sub    $0x4,%esp
f0104a28:	6a 01                	push   $0x1
f0104a2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a2d:	50                   	push   %eax
f0104a2e:	ff 75 0c             	push   0xc(%ebp)
f0104a31:	e8 81 e9 ff ff       	call   f01033b7 <envid2env>
f0104a36:	89 c3                	mov    %eax,%ebx
f0104a38:	83 c4 10             	add    $0x10,%esp
f0104a3b:	85 c0                	test   %eax,%eax
f0104a3d:	78 85                	js     f01049c4 <syscall+0x52>
	if (e == curenv)
f0104a3f:	e8 58 17 00 00       	call   f010619c <cpunum>
f0104a44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a47:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a4a:	39 90 28 80 26 f0    	cmp    %edx,-0xfd97fd8(%eax)
f0104a50:	74 56                	je     f0104aa8 <syscall+0x136>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104a52:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104a55:	e8 42 17 00 00       	call   f010619c <cpunum>
f0104a5a:	83 ec 04             	sub    $0x4,%esp
f0104a5d:	53                   	push   %ebx
f0104a5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a61:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0104a67:	ff 70 48             	push   0x48(%eax)
f0104a6a:	68 f5 82 10 f0       	push   $0xf01082f5
f0104a6f:	e8 fe f1 ff ff       	call   f0103c72 <cprintf>
f0104a74:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104a77:	83 ec 0c             	sub    $0xc,%esp
f0104a7a:	ff 75 e4             	push   -0x1c(%ebp)
f0104a7d:	e8 e0 ee ff ff       	call   f0103962 <env_destroy>
	return 0;
f0104a82:	83 c4 10             	add    $0x10,%esp
f0104a85:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_destroy((envid_t)a1);
f0104a8a:	e9 35 ff ff ff       	jmp    f01049c4 <syscall+0x52>
			assert(curenv);
f0104a8f:	68 62 80 10 f0       	push   $0xf0108062
f0104a94:	68 21 71 10 f0       	push   $0xf0107121
f0104a99:	68 ad 01 00 00       	push   $0x1ad
f0104a9e:	68 cb 82 10 f0       	push   $0xf01082cb
f0104aa3:	e8 98 b5 ff ff       	call   f0100040 <_panic>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104aa8:	e8 ef 16 00 00       	call   f010619c <cpunum>
f0104aad:	83 ec 08             	sub    $0x8,%esp
f0104ab0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab3:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0104ab9:	ff 70 48             	push   0x48(%eax)
f0104abc:	68 da 82 10 f0       	push   $0xf01082da
f0104ac1:	e8 ac f1 ff ff       	call   f0103c72 <cprintf>
f0104ac6:	83 c4 10             	add    $0x10,%esp
f0104ac9:	eb ac                	jmp    f0104a77 <syscall+0x105>
	sched_yield();
f0104acb:	e8 f8 fd ff ff       	call   f01048c8 <sched_yield>
	parent = curenv;
f0104ad0:	e8 c7 16 00 00       	call   f010619c <cpunum>
f0104ad5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ad8:	8b b0 28 80 26 f0    	mov    -0xfd97fd8(%eax),%esi
	ret = env_alloc(&child, parent->env_id);
f0104ade:	83 ec 08             	sub    $0x8,%esp
f0104ae1:	ff 76 48             	push   0x48(%esi)
f0104ae4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ae7:	50                   	push   %eax
f0104ae8:	e8 d4 e9 ff ff       	call   f01034c1 <env_alloc>
f0104aed:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104aef:	83 c4 10             	add    $0x10,%esp
f0104af2:	85 c0                	test   %eax,%eax
f0104af4:	0f 88 ca fe ff ff    	js     f01049c4 <syscall+0x52>
	child->env_status = ENV_NOT_RUNNABLE;
f0104afa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104afd:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	child->env_tf = parent->env_tf;
f0104b04:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b09:	89 c7                	mov    %eax,%edi
f0104b0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child->env_tf.tf_regs.reg_eax = 0;
f0104b0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b10:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return child->env_id;
f0104b17:	8b 58 48             	mov    0x48(%eax),%ebx
			return sys_exofork();
f0104b1a:	e9 a5 fe ff ff       	jmp    f01049c4 <syscall+0x52>
	int ret = envid2env(envid, &env, 1);
f0104b1f:	83 ec 04             	sub    $0x4,%esp
f0104b22:	6a 01                	push   $0x1
f0104b24:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b27:	50                   	push   %eax
f0104b28:	ff 75 0c             	push   0xc(%ebp)
f0104b2b:	e8 87 e8 ff ff       	call   f01033b7 <envid2env>
f0104b30:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104b32:	83 c4 10             	add    $0x10,%esp
f0104b35:	85 c0                	test   %eax,%eax
f0104b37:	0f 88 87 fe ff ff    	js     f01049c4 <syscall+0x52>
	if ((status != ENV_RUNNABLE) && (status != ENV_NOT_RUNNABLE)) {
f0104b3d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b40:	83 e8 02             	sub    $0x2,%eax
f0104b43:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104b48:	75 13                	jne    f0104b5d <syscall+0x1eb>
	env->env_status = status;
f0104b4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b4d:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104b50:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104b53:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b58:	e9 67 fe ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104b5d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_env_set_status((envid_t)a1, (int)a2);
f0104b62:	e9 5d fe ff ff       	jmp    f01049c4 <syscall+0x52>
	int ret = envid2env(envid, &env, 1);
f0104b67:	83 ec 04             	sub    $0x4,%esp
f0104b6a:	6a 01                	push   $0x1
f0104b6c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b6f:	50                   	push   %eax
f0104b70:	ff 75 0c             	push   0xc(%ebp)
f0104b73:	e8 3f e8 ff ff       	call   f01033b7 <envid2env>
f0104b78:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104b7a:	83 c4 10             	add    $0x10,%esp
f0104b7d:	85 c0                	test   %eax,%eax
f0104b7f:	0f 88 3f fe ff ff    	js     f01049c4 <syscall+0x52>
	if (((uint32_t)va >= UTOP) || (va != ROUNDUP(va, PGSIZE))) {
f0104b85:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104b8c:	77 6f                	ja     f0104bfd <syscall+0x28b>
f0104b8e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b91:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104b96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104b9b:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104b9e:	75 67                	jne    f0104c07 <syscall+0x295>
	if ((perm & PTE_SYSCALL) != perm) {
f0104ba0:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104ba7:	75 68                	jne    f0104c11 <syscall+0x29f>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) {
f0104ba9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bac:	83 e0 05             	and    $0x5,%eax
f0104baf:	83 f8 05             	cmp    $0x5,%eax
f0104bb2:	75 67                	jne    f0104c1b <syscall+0x2a9>
	struct PageInfo *page = page_alloc(ALLOC_ZERO);
f0104bb4:	83 ec 0c             	sub    $0xc,%esp
f0104bb7:	6a 01                	push   $0x1
f0104bb9:	e8 e0 c6 ff ff       	call   f010129e <page_alloc>
f0104bbe:	89 c6                	mov    %eax,%esi
	if (page == NULL) {
f0104bc0:	83 c4 10             	add    $0x10,%esp
f0104bc3:	85 c0                	test   %eax,%eax
f0104bc5:	74 5e                	je     f0104c25 <syscall+0x2b3>
	ret = page_insert(env->env_pgdir, page, va, perm);
f0104bc7:	ff 75 14             	push   0x14(%ebp)
f0104bca:	ff 75 10             	push   0x10(%ebp)
f0104bcd:	50                   	push   %eax
f0104bce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bd1:	ff 70 60             	push   0x60(%eax)
f0104bd4:	e8 61 c9 ff ff       	call   f010153a <page_insert>
f0104bd9:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104bdb:	83 c4 10             	add    $0x10,%esp
f0104bde:	85 c0                	test   %eax,%eax
f0104be0:	78 0a                	js     f0104bec <syscall+0x27a>
	return 0;
f0104be2:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104be7:	e9 d8 fd ff ff       	jmp    f01049c4 <syscall+0x52>
		page_free(page);
f0104bec:	83 ec 0c             	sub    $0xc,%esp
f0104bef:	56                   	push   %esi
f0104bf0:	e8 1e c7 ff ff       	call   f0101313 <page_free>
		return ret;
f0104bf5:	83 c4 10             	add    $0x10,%esp
f0104bf8:	e9 c7 fd ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104bfd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c02:	e9 bd fd ff ff       	jmp    f01049c4 <syscall+0x52>
f0104c07:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c0c:	e9 b3 fd ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104c11:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c16:	e9 a9 fd ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104c1b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c20:	e9 9f fd ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_NO_MEM;
f0104c25:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104c2a:	e9 95 fd ff ff       	jmp    f01049c4 <syscall+0x52>
	int ret = envid2env(srcenvid, &srcenv, 1);
f0104c2f:	83 ec 04             	sub    $0x4,%esp
f0104c32:	6a 01                	push   $0x1
f0104c34:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104c37:	50                   	push   %eax
f0104c38:	ff 75 0c             	push   0xc(%ebp)
f0104c3b:	e8 77 e7 ff ff       	call   f01033b7 <envid2env>
f0104c40:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104c42:	83 c4 10             	add    $0x10,%esp
f0104c45:	85 c0                	test   %eax,%eax
f0104c47:	0f 88 77 fd ff ff    	js     f01049c4 <syscall+0x52>
	ret = envid2env(dstenvid, &dstenv, 1);
f0104c4d:	83 ec 04             	sub    $0x4,%esp
f0104c50:	6a 01                	push   $0x1
f0104c52:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c55:	50                   	push   %eax
f0104c56:	ff 75 14             	push   0x14(%ebp)
f0104c59:	e8 59 e7 ff ff       	call   f01033b7 <envid2env>
f0104c5e:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104c60:	83 c4 10             	add    $0x10,%esp
f0104c63:	85 c0                	test   %eax,%eax
f0104c65:	0f 88 59 fd ff ff    	js     f01049c4 <syscall+0x52>
	if (((uint32_t)srcva >= UTOP) || (srcva != ROUNDUP(srcva, PGSIZE))) {
f0104c6b:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c72:	0f 87 86 00 00 00    	ja     f0104cfe <syscall+0x38c>
f0104c78:	8b 45 10             	mov    0x10(%ebp),%eax
f0104c7b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104c80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (((uint32_t)dstva >= UTOP) || (dstva != ROUNDUP(dstva, PGSIZE))) {
f0104c85:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104c88:	75 7e                	jne    f0104d08 <syscall+0x396>
f0104c8a:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104c91:	77 75                	ja     f0104d08 <syscall+0x396>
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0104c93:	8b 5d 18             	mov    0x18(%ebp),%ebx
	if (((uint32_t)dstva >= UTOP) || (dstva != ROUNDUP(dstva, PGSIZE))) {
f0104c96:	89 d8                	mov    %ebx,%eax
f0104c98:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104c9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104ca2:	39 c3                	cmp    %eax,%ebx
f0104ca4:	75 6c                	jne    f0104d12 <syscall+0x3a0>
	struct PageInfo *page = page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104ca6:	83 ec 04             	sub    $0x4,%esp
f0104ca9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104cac:	50                   	push   %eax
f0104cad:	ff 75 10             	push   0x10(%ebp)
f0104cb0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104cb3:	ff 70 60             	push   0x60(%eax)
f0104cb6:	e8 97 c7 ff ff       	call   f0101452 <page_lookup>
	if (page == NULL) {
f0104cbb:	83 c4 10             	add    $0x10,%esp
f0104cbe:	85 c0                	test   %eax,%eax
f0104cc0:	74 5a                	je     f0104d1c <syscall+0x3aa>
	if ((perm & PTE_SYSCALL) != perm) {
f0104cc2:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104cc9:	75 5b                	jne    f0104d26 <syscall+0x3b4>
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) {
f0104ccb:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104cce:	83 e2 05             	and    $0x5,%edx
f0104cd1:	83 fa 05             	cmp    $0x5,%edx
f0104cd4:	75 5a                	jne    f0104d30 <syscall+0x3be>
	if ((perm & PTE_W) && !(*pte & PTE_W)) {
f0104cd6:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104cda:	74 08                	je     f0104ce4 <syscall+0x372>
f0104cdc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104cdf:	f6 02 02             	testb  $0x2,(%edx)
f0104ce2:	74 56                	je     f0104d3a <syscall+0x3c8>
	ret = page_insert(dstenv->env_pgdir, page, dstva, perm);
f0104ce4:	ff 75 1c             	push   0x1c(%ebp)
f0104ce7:	53                   	push   %ebx
f0104ce8:	50                   	push   %eax
f0104ce9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104cec:	ff 70 60             	push   0x60(%eax)
f0104cef:	e8 46 c8 ff ff       	call   f010153a <page_insert>
f0104cf4:	89 c3                	mov    %eax,%ebx
	return ret;
f0104cf6:	83 c4 10             	add    $0x10,%esp
f0104cf9:	e9 c6 fc ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104cfe:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d03:	e9 bc fc ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104d08:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d0d:	e9 b2 fc ff ff       	jmp    f01049c4 <syscall+0x52>
f0104d12:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d17:	e9 a8 fc ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104d1c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d21:	e9 9e fc ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104d26:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d2b:	e9 94 fc ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104d30:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d35:	e9 8a fc ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104d3a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
f0104d3f:	e9 80 fc ff ff       	jmp    f01049c4 <syscall+0x52>
	int ret = envid2env(envid, &env, 1);
f0104d44:	83 ec 04             	sub    $0x4,%esp
f0104d47:	6a 01                	push   $0x1
f0104d49:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d4c:	50                   	push   %eax
f0104d4d:	ff 75 0c             	push   0xc(%ebp)
f0104d50:	e8 62 e6 ff ff       	call   f01033b7 <envid2env>
f0104d55:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104d57:	83 c4 10             	add    $0x10,%esp
f0104d5a:	85 c0                	test   %eax,%eax
f0104d5c:	0f 88 62 fc ff ff    	js     f01049c4 <syscall+0x52>
	if (((uint32_t)va >= UTOP) || (va != ROUNDUP(va, PGSIZE))) {
f0104d62:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d69:	77 30                	ja     f0104d9b <syscall+0x429>
f0104d6b:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d6e:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104d73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104d78:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104d7b:	75 28                	jne    f0104da5 <syscall+0x433>
	page_remove(env->env_pgdir, va);
f0104d7d:	83 ec 08             	sub    $0x8,%esp
f0104d80:	ff 75 10             	push   0x10(%ebp)
f0104d83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d86:	ff 70 60             	push   0x60(%eax)
f0104d89:	e8 58 c7 ff ff       	call   f01014e6 <page_remove>
	return 0;
f0104d8e:	83 c4 10             	add    $0x10,%esp
f0104d91:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d96:	e9 29 fc ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_INVAL;
f0104d9b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104da0:	e9 1f fc ff ff       	jmp    f01049c4 <syscall+0x52>
f0104da5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_page_unmap((envid_t)a1, (void *)a2);
f0104daa:	e9 15 fc ff ff       	jmp    f01049c4 <syscall+0x52>
	int ret = envid2env(envid, &env, 1);
f0104daf:	83 ec 04             	sub    $0x4,%esp
f0104db2:	6a 01                	push   $0x1
f0104db4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104db7:	50                   	push   %eax
f0104db8:	ff 75 0c             	push   0xc(%ebp)
f0104dbb:	e8 f7 e5 ff ff       	call   f01033b7 <envid2env>
f0104dc0:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104dc2:	83 c4 10             	add    $0x10,%esp
f0104dc5:	85 c0                	test   %eax,%eax
f0104dc7:	0f 88 f7 fb ff ff    	js     f01049c4 <syscall+0x52>
	env->env_pgfault_upcall = func;
f0104dcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104dd3:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f0104dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104ddb:	e9 e4 fb ff ff       	jmp    f01049c4 <syscall+0x52>
	int ret = envid2env(envid, &dstenv, 0);
f0104de0:	83 ec 04             	sub    $0x4,%esp
f0104de3:	6a 00                	push   $0x0
f0104de5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104de8:	50                   	push   %eax
f0104de9:	ff 75 0c             	push   0xc(%ebp)
f0104dec:	e8 c6 e5 ff ff       	call   f01033b7 <envid2env>
f0104df1:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104df3:	83 c4 10             	add    $0x10,%esp
f0104df6:	85 c0                	test   %eax,%eax
f0104df8:	0f 88 c6 fb ff ff    	js     f01049c4 <syscall+0x52>
	if (!dstenv->env_ipc_recving) {
f0104dfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e01:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104e05:	0f 84 26 01 00 00    	je     f0104f31 <syscall+0x5bf>
	if ((uint32_t)srcva < UTOP) {
f0104e0b:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104e12:	0f 87 92 01 00 00    	ja     f0104faa <syscall+0x638>
		if ((uint32_t)srcva != ROUNDUP((uint32_t)srcva, PGSIZE)) {
f0104e18:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e1b:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104e20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
			return -E_INVAL;
f0104e25:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		if ((uint32_t)srcva != ROUNDUP((uint32_t)srcva, PGSIZE)) {
f0104e2a:	39 45 14             	cmp    %eax,0x14(%ebp)
f0104e2d:	0f 85 91 fb ff ff    	jne    f01049c4 <syscall+0x52>
		if ((perm & PTE_SYSCALL) != perm) {
f0104e33:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104e3a:	0f 85 84 fb ff ff    	jne    f01049c4 <syscall+0x52>
		if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) {
f0104e40:	8b 45 18             	mov    0x18(%ebp),%eax
f0104e43:	83 e0 05             	and    $0x5,%eax
f0104e46:	83 f8 05             	cmp    $0x5,%eax
f0104e49:	0f 85 75 fb ff ff    	jne    f01049c4 <syscall+0x52>
		struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104e4f:	e8 48 13 00 00       	call   f010619c <cpunum>
f0104e54:	83 ec 04             	sub    $0x4,%esp
f0104e57:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e5a:	52                   	push   %edx
f0104e5b:	ff 75 14             	push   0x14(%ebp)
f0104e5e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e61:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0104e67:	ff 70 60             	push   0x60(%eax)
f0104e6a:	e8 e3 c5 ff ff       	call   f0101452 <page_lookup>
		if (page == NULL) {
f0104e6f:	83 c4 10             	add    $0x10,%esp
f0104e72:	85 c0                	test   %eax,%eax
f0104e74:	0f 84 ad 00 00 00    	je     f0104f27 <syscall+0x5b5>
		if ((perm & PTE_W) && !(*pte & PTE_W)) {
f0104e7a:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104e7e:	74 0c                	je     f0104e8c <syscall+0x51a>
f0104e80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e83:	f6 02 02             	testb  $0x2,(%edx)
f0104e86:	0f 84 38 fb ff ff    	je     f01049c4 <syscall+0x52>
		if (((*pte) & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) {
f0104e8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e8f:	8b 12                	mov    (%edx),%edx
f0104e91:	83 e2 05             	and    $0x5,%edx
			return -E_INVAL;
f0104e94:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		if (((*pte) & (PTE_U | PTE_P)) != (PTE_U | PTE_P)) {
f0104e99:	83 fa 05             	cmp    $0x5,%edx
f0104e9c:	0f 85 22 fb ff ff    	jne    f01049c4 <syscall+0x52>
		if ((uint32_t)dstenv->env_ipc_dstva < UTOP) {
f0104ea2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ea5:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104ea8:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104eae:	76 32                	jbe    f0104ee2 <syscall+0x570>
	dstenv->env_ipc_recving = false;
f0104eb0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104eb3:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	dstenv->env_ipc_from = curenv->env_id;
f0104eb7:	e8 e0 12 00 00       	call   f010619c <cpunum>
f0104ebc:	89 c2                	mov    %eax,%edx
f0104ebe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ec1:	6b d2 74             	imul   $0x74,%edx,%edx
f0104ec4:	8b 92 28 80 26 f0    	mov    -0xfd97fd8(%edx),%edx
f0104eca:	8b 52 48             	mov    0x48(%edx),%edx
f0104ecd:	89 50 74             	mov    %edx,0x74(%eax)
	dstenv->env_ipc_value = value;
f0104ed0:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104ed3:	89 48 70             	mov    %ecx,0x70(%eax)
f0104ed6:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
f0104edd:	e9 f2 00 00 00       	jmp    f0104fd4 <syscall+0x662>
			ret = page_insert(dstenv->env_pgdir, page, dstenv->env_ipc_dstva, perm);
f0104ee2:	ff 75 18             	push   0x18(%ebp)
f0104ee5:	51                   	push   %ecx
f0104ee6:	50                   	push   %eax
f0104ee7:	ff 72 60             	push   0x60(%edx)
f0104eea:	e8 4b c6 ff ff       	call   f010153a <page_insert>
f0104eef:	89 c3                	mov    %eax,%ebx
			if (ret < 0) {
f0104ef1:	83 c4 10             	add    $0x10,%esp
f0104ef4:	85 c0                	test   %eax,%eax
f0104ef6:	0f 88 c8 fa ff ff    	js     f01049c4 <syscall+0x52>
	dstenv->env_ipc_recving = false;
f0104efc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104eff:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	dstenv->env_ipc_from = curenv->env_id;
f0104f03:	e8 94 12 00 00       	call   f010619c <cpunum>
f0104f08:	89 c2                	mov    %eax,%edx
f0104f0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f0d:	6b d2 74             	imul   $0x74,%edx,%edx
f0104f10:	8b 92 28 80 26 f0    	mov    -0xfd97fd8(%edx),%edx
f0104f16:	8b 52 48             	mov    0x48(%edx),%edx
f0104f19:	89 50 74             	mov    %edx,0x74(%eax)
	dstenv->env_ipc_value = value;
f0104f1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104f1f:	89 48 70             	mov    %ecx,0x70(%eax)
f0104f22:	e9 ad 00 00 00       	jmp    f0104fd4 <syscall+0x662>
			return -E_INVAL;
f0104f27:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f2c:	e9 93 fa ff ff       	jmp    f01049c4 <syscall+0x52>
		return -E_IPC_NOT_RECV;
f0104f31:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			return sys_ipc_try_send((envid_t)a1, (uint32_t)a2, (void *)a3, (unsigned)a4);
f0104f36:	e9 89 fa ff ff       	jmp    f01049c4 <syscall+0x52>
	if (((uint32_t)dstva < UTOP) && ((uint32_t)dstva != ROUNDUP((uint32_t)dstva, PGSIZE))) {
f0104f3b:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104f42:	77 1c                	ja     f0104f60 <syscall+0x5ee>
f0104f44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104f47:	05 ff 0f 00 00       	add    $0xfff,%eax
f0104f4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0104f51:	39 45 0c             	cmp    %eax,0xc(%ebp)
f0104f54:	74 0a                	je     f0104f60 <syscall+0x5ee>
			return sys_ipc_recv((void *)a1);
f0104f56:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f5b:	e9 64 fa ff ff       	jmp    f01049c4 <syscall+0x52>
	curenv->env_ipc_recving = true;
f0104f60:	e8 37 12 00 00       	call   f010619c <cpunum>
f0104f65:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f68:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0104f6e:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104f72:	e8 25 12 00 00       	call   f010619c <cpunum>
f0104f77:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f7a:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0104f80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104f83:	89 48 6c             	mov    %ecx,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104f86:	e8 11 12 00 00       	call   f010619c <cpunum>
f0104f8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f8e:	8b 80 28 80 26 f0    	mov    -0xfd97fd8(%eax),%eax
f0104f94:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104f9b:	e8 28 f9 ff ff       	call   f01048c8 <sched_yield>
	switch (syscallno) {
f0104fa0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104fa5:	e9 1a fa ff ff       	jmp    f01049c4 <syscall+0x52>
	dstenv->env_ipc_recving = false;
f0104faa:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	dstenv->env_ipc_from = curenv->env_id;
f0104fae:	e8 e9 11 00 00       	call   f010619c <cpunum>
f0104fb3:	89 c2                	mov    %eax,%edx
f0104fb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fb8:	6b d2 74             	imul   $0x74,%edx,%edx
f0104fbb:	8b 92 28 80 26 f0    	mov    -0xfd97fd8(%edx),%edx
f0104fc1:	8b 52 48             	mov    0x48(%edx),%edx
f0104fc4:	89 50 74             	mov    %edx,0x74(%eax)
	dstenv->env_ipc_value = value;
f0104fc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104fca:	89 48 70             	mov    %ecx,0x70(%eax)
f0104fcd:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
f0104fd4:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104fd7:	89 78 78             	mov    %edi,0x78(%eax)
	dstenv->env_status = ENV_RUNNABLE;
f0104fda:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	dstenv->env_tf.tf_regs.reg_eax = 0;
f0104fe1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104fe8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104fed:	e9 d2 f9 ff ff       	jmp    f01049c4 <syscall+0x52>

f0104ff2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104ff2:	55                   	push   %ebp
f0104ff3:	89 e5                	mov    %esp,%ebp
f0104ff5:	57                   	push   %edi
f0104ff6:	56                   	push   %esi
f0104ff7:	53                   	push   %ebx
f0104ff8:	83 ec 14             	sub    $0x14,%esp
f0104ffb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ffe:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105001:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105004:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105007:	8b 1a                	mov    (%edx),%ebx
f0105009:	8b 01                	mov    (%ecx),%eax
f010500b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010500e:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0105015:	eb 2f                	jmp    f0105046 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0105017:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010501a:	39 c3                	cmp    %eax,%ebx
f010501c:	7f 4e                	jg     f010506c <stab_binsearch+0x7a>
f010501e:	0f b6 0a             	movzbl (%edx),%ecx
f0105021:	83 ea 0c             	sub    $0xc,%edx
f0105024:	39 f1                	cmp    %esi,%ecx
f0105026:	75 ef                	jne    f0105017 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105028:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010502b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010502e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105032:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105035:	73 3a                	jae    f0105071 <stab_binsearch+0x7f>
			*region_left = m;
f0105037:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010503a:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010503c:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f010503f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105046:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105049:	7f 53                	jg     f010509e <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f010504b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010504e:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0105051:	89 d0                	mov    %edx,%eax
f0105053:	c1 e8 1f             	shr    $0x1f,%eax
f0105056:	01 d0                	add    %edx,%eax
f0105058:	89 c7                	mov    %eax,%edi
f010505a:	d1 ff                	sar    %edi
f010505c:	83 e0 fe             	and    $0xfffffffe,%eax
f010505f:	01 f8                	add    %edi,%eax
f0105061:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105064:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0105068:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f010506a:	eb ae                	jmp    f010501a <stab_binsearch+0x28>
			l = true_m + 1;
f010506c:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010506f:	eb d5                	jmp    f0105046 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0105071:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105074:	76 14                	jbe    f010508a <stab_binsearch+0x98>
			*region_right = m - 1;
f0105076:	83 e8 01             	sub    $0x1,%eax
f0105079:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010507c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010507f:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105081:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105088:	eb bc                	jmp    f0105046 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010508a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010508d:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f010508f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105093:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0105095:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010509c:	eb a8                	jmp    f0105046 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f010509e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01050a2:	75 15                	jne    f01050b9 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01050a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050a7:	8b 00                	mov    (%eax),%eax
f01050a9:	83 e8 01             	sub    $0x1,%eax
f01050ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01050af:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f01050b1:	83 c4 14             	add    $0x14,%esp
f01050b4:	5b                   	pop    %ebx
f01050b5:	5e                   	pop    %esi
f01050b6:	5f                   	pop    %edi
f01050b7:	5d                   	pop    %ebp
f01050b8:	c3                   	ret    
		for (l = *region_right;
f01050b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050bc:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01050be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050c1:	8b 0f                	mov    (%edi),%ecx
f01050c3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01050c6:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01050c9:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01050cd:	39 c1                	cmp    %eax,%ecx
f01050cf:	7d 0f                	jge    f01050e0 <stab_binsearch+0xee>
f01050d1:	0f b6 1a             	movzbl (%edx),%ebx
f01050d4:	83 ea 0c             	sub    $0xc,%edx
f01050d7:	39 f3                	cmp    %esi,%ebx
f01050d9:	74 05                	je     f01050e0 <stab_binsearch+0xee>
		     l--)
f01050db:	83 e8 01             	sub    $0x1,%eax
f01050de:	eb ed                	jmp    f01050cd <stab_binsearch+0xdb>
		*region_left = l;
f01050e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050e3:	89 07                	mov    %eax,(%edi)
}
f01050e5:	eb ca                	jmp    f01050b1 <stab_binsearch+0xbf>

f01050e7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01050e7:	55                   	push   %ebp
f01050e8:	89 e5                	mov    %esp,%ebp
f01050ea:	57                   	push   %edi
f01050eb:	56                   	push   %esi
f01050ec:	53                   	push   %ebx
f01050ed:	83 ec 4c             	sub    $0x4c,%esp
f01050f0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01050f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01050f6:	c7 03 44 83 10 f0    	movl   $0xf0108344,(%ebx)
	info->eip_line = 0;
f01050fc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105103:	c7 43 08 44 83 10 f0 	movl   $0xf0108344,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010510a:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105111:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105114:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010511b:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0105121:	0f 86 30 01 00 00    	jbe    f0105257 <debuginfo_eip+0x170>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0105127:	c7 45 c0 87 b2 11 f0 	movl   $0xf011b287,-0x40(%ebp)
		stabstr = __STABSTR_BEGIN__;
f010512e:	c7 45 bc c9 47 11 f0 	movl   $0xf01147c9,-0x44(%ebp)
		stab_end = __STAB_END__;
f0105135:	be c8 47 11 f0       	mov    $0xf01147c8,%esi
		stabs = __STAB_BEGIN__;
f010513a:	c7 45 c4 34 88 10 f0 	movl   $0xf0108834,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105141:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105144:	39 4d bc             	cmp    %ecx,-0x44(%ebp)
f0105147:	0f 83 3e 02 00 00    	jae    f010538b <debuginfo_eip+0x2a4>
f010514d:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0105151:	0f 85 3b 02 00 00    	jne    f0105392 <debuginfo_eip+0x2ab>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105157:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010515e:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f0105161:	c1 fe 02             	sar    $0x2,%esi
f0105164:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f010516a:	83 e8 01             	sub    $0x1,%eax
f010516d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105170:	83 ec 08             	sub    $0x8,%esp
f0105173:	57                   	push   %edi
f0105174:	6a 64                	push   $0x64
f0105176:	8d 75 e0             	lea    -0x20(%ebp),%esi
f0105179:	89 f1                	mov    %esi,%ecx
f010517b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010517e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0105181:	e8 6c fe ff ff       	call   f0104ff2 <stab_binsearch>
	if (lfile == 0)
f0105186:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105189:	83 c4 10             	add    $0x10,%esp
f010518c:	85 f6                	test   %esi,%esi
f010518e:	0f 84 05 02 00 00    	je     f0105399 <debuginfo_eip+0x2b2>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105194:	89 75 dc             	mov    %esi,-0x24(%ebp)
	rfun = rfile;
f0105197:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010519a:	89 55 b8             	mov    %edx,-0x48(%ebp)
f010519d:	89 55 d8             	mov    %edx,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01051a0:	83 ec 08             	sub    $0x8,%esp
f01051a3:	57                   	push   %edi
f01051a4:	6a 24                	push   $0x24
f01051a6:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01051a9:	89 d1                	mov    %edx,%ecx
f01051ab:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01051ae:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01051b1:	e8 3c fe ff ff       	call   f0104ff2 <stab_binsearch>

	if (lfun <= rfun) {
f01051b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01051b9:	89 55 b4             	mov    %edx,-0x4c(%ebp)
f01051bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01051bf:	89 45 b0             	mov    %eax,-0x50(%ebp)
f01051c2:	83 c4 10             	add    $0x10,%esp
f01051c5:	39 c2                	cmp    %eax,%edx
f01051c7:	0f 8f 32 01 00 00    	jg     f01052ff <debuginfo_eip+0x218>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01051cd:	8d 04 52             	lea    (%edx,%edx,2),%eax
f01051d0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01051d3:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01051d6:	8b 02                	mov    (%edx),%eax
f01051d8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01051db:	2b 4d bc             	sub    -0x44(%ebp),%ecx
f01051de:	39 c8                	cmp    %ecx,%eax
f01051e0:	73 06                	jae    f01051e8 <debuginfo_eip+0x101>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01051e2:	03 45 bc             	add    -0x44(%ebp),%eax
f01051e5:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01051e8:	8b 42 08             	mov    0x8(%edx),%eax
		addr -= info->eip_fn_addr;
f01051eb:	29 c7                	sub    %eax,%edi
f01051ed:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f01051f0:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f01051f3:	89 4d b8             	mov    %ecx,-0x48(%ebp)
		info->eip_fn_addr = stabs[lfun].n_value;
f01051f6:	89 43 10             	mov    %eax,0x10(%ebx)
		// Search within the function definition for the line number.
		lline = lfun;
f01051f9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f01051fc:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01051ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105202:	83 ec 08             	sub    $0x8,%esp
f0105205:	6a 3a                	push   $0x3a
f0105207:	ff 73 08             	push   0x8(%ebx)
f010520a:	e8 7a 09 00 00       	call   f0105b89 <strfind>
f010520f:	2b 43 08             	sub    0x8(%ebx),%eax
f0105212:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105215:	83 c4 08             	add    $0x8,%esp
f0105218:	57                   	push   %edi
f0105219:	6a 44                	push   $0x44
f010521b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010521e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105221:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0105224:	89 f8                	mov    %edi,%eax
f0105226:	e8 c7 fd ff ff       	call   f0104ff2 <stab_binsearch>
	if (lline <= rline) {
f010522b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010522e:	83 c4 10             	add    $0x10,%esp
		info->eip_line = stabs[lline].n_desc;
	} else {
		info->eip_line = -1;
f0105231:	ba ff ff ff ff       	mov    $0xffffffff,%edx
	if (lline <= rline) {
f0105236:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105239:	7f 08                	jg     f0105243 <debuginfo_eip+0x15c>
		info->eip_line = stabs[lline].n_desc;
f010523b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010523e:	0f b7 54 97 06       	movzwl 0x6(%edi,%edx,4),%edx
f0105243:	89 53 04             	mov    %edx,0x4(%ebx)
f0105246:	89 c2                	mov    %eax,%edx
f0105248:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010524b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010524e:	8d 44 87 04          	lea    0x4(%edi,%eax,4),%eax
f0105252:	e9 b7 00 00 00       	jmp    f010530e <debuginfo_eip+0x227>
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0)
f0105257:	e8 40 0f 00 00       	call   f010619c <cpunum>
f010525c:	6a 04                	push   $0x4
f010525e:	6a 10                	push   $0x10
f0105260:	68 00 00 20 00       	push   $0x200000
f0105265:	6b c0 74             	imul   $0x74,%eax,%eax
f0105268:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f010526e:	e8 96 df ff ff       	call   f0103209 <user_mem_check>
f0105273:	83 c4 10             	add    $0x10,%esp
f0105276:	85 c0                	test   %eax,%eax
f0105278:	0f 88 ff 00 00 00    	js     f010537d <debuginfo_eip+0x296>
		stabs = usd->stabs;
f010527e:	a1 00 00 20 00       	mov    0x200000,%eax
		stab_end = usd->stab_end;
f0105283:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0105289:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f010528f:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0105292:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105298:	89 55 c0             	mov    %edx,-0x40(%ebp)
		if (user_mem_check(curenv, stabs, (uintptr_t)stab_end - (uintptr_t)stabs, PTE_U) < 0)
f010529b:	89 f1                	mov    %esi,%ecx
f010529d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01052a0:	29 c1                	sub    %eax,%ecx
f01052a2:	89 4d b8             	mov    %ecx,-0x48(%ebp)
f01052a5:	e8 f2 0e 00 00       	call   f010619c <cpunum>
f01052aa:	6a 04                	push   $0x4
f01052ac:	ff 75 b8             	push   -0x48(%ebp)
f01052af:	ff 75 c4             	push   -0x3c(%ebp)
f01052b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01052b5:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f01052bb:	e8 49 df ff ff       	call   f0103209 <user_mem_check>
f01052c0:	83 c4 10             	add    $0x10,%esp
f01052c3:	85 c0                	test   %eax,%eax
f01052c5:	0f 88 b9 00 00 00    	js     f0105384 <debuginfo_eip+0x29d>
		if (user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f01052cb:	e8 cc 0e 00 00       	call   f010619c <cpunum>
f01052d0:	6a 04                	push   $0x4
f01052d2:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01052d5:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f01052d8:	29 ca                	sub    %ecx,%edx
f01052da:	52                   	push   %edx
f01052db:	51                   	push   %ecx
f01052dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01052df:	ff b0 28 80 26 f0    	push   -0xfd97fd8(%eax)
f01052e5:	e8 1f df ff ff       	call   f0103209 <user_mem_check>
f01052ea:	83 c4 10             	add    $0x10,%esp
f01052ed:	85 c0                	test   %eax,%eax
f01052ef:	0f 89 4c fe ff ff    	jns    f0105141 <debuginfo_eip+0x5a>
			return -1;
f01052f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052fa:	e9 a6 00 00 00       	jmp    f01053a5 <debuginfo_eip+0x2be>
f01052ff:	89 f8                	mov    %edi,%eax
f0105301:	89 f2                	mov    %esi,%edx
f0105303:	e9 ee fe ff ff       	jmp    f01051f6 <debuginfo_eip+0x10f>
f0105308:	83 ea 01             	sub    $0x1,%edx
f010530b:	83 e8 0c             	sub    $0xc,%eax
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010530e:	39 d6                	cmp    %edx,%esi
f0105310:	7f 2e                	jg     f0105340 <debuginfo_eip+0x259>
	       && stabs[lline].n_type != N_SOL
f0105312:	0f b6 08             	movzbl (%eax),%ecx
f0105315:	80 f9 84             	cmp    $0x84,%cl
f0105318:	74 0b                	je     f0105325 <debuginfo_eip+0x23e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010531a:	80 f9 64             	cmp    $0x64,%cl
f010531d:	75 e9                	jne    f0105308 <debuginfo_eip+0x221>
f010531f:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0105323:	74 e3                	je     f0105308 <debuginfo_eip+0x221>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105325:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0105328:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010532b:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010532e:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105331:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105334:	29 f8                	sub    %edi,%eax
f0105336:	39 c2                	cmp    %eax,%edx
f0105338:	73 06                	jae    f0105340 <debuginfo_eip+0x259>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010533a:	89 f8                	mov    %edi,%eax
f010533c:	01 d0                	add    %edx,%eax
f010533e:	89 03                	mov    %eax,(%ebx)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105340:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0105345:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0105348:	8b 75 b0             	mov    -0x50(%ebp),%esi
f010534b:	39 f7                	cmp    %esi,%edi
f010534d:	7d 56                	jge    f01053a5 <debuginfo_eip+0x2be>
		for (lline = lfun + 1;
f010534f:	83 c7 01             	add    $0x1,%edi
f0105352:	89 f8                	mov    %edi,%eax
f0105354:	8d 14 7f             	lea    (%edi,%edi,2),%edx
f0105357:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010535a:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f010535e:	eb 04                	jmp    f0105364 <debuginfo_eip+0x27d>
			info->eip_fn_narg++;
f0105360:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105364:	39 c6                	cmp    %eax,%esi
f0105366:	7e 38                	jle    f01053a0 <debuginfo_eip+0x2b9>
f0105368:	0f b6 0a             	movzbl (%edx),%ecx
f010536b:	83 c0 01             	add    $0x1,%eax
f010536e:	83 c2 0c             	add    $0xc,%edx
f0105371:	80 f9 a0             	cmp    $0xa0,%cl
f0105374:	74 ea                	je     f0105360 <debuginfo_eip+0x279>
	return 0;
f0105376:	b8 00 00 00 00       	mov    $0x0,%eax
f010537b:	eb 28                	jmp    f01053a5 <debuginfo_eip+0x2be>
			return -1;
f010537d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105382:	eb 21                	jmp    f01053a5 <debuginfo_eip+0x2be>
			return -1;
f0105384:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105389:	eb 1a                	jmp    f01053a5 <debuginfo_eip+0x2be>
		return -1;
f010538b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105390:	eb 13                	jmp    f01053a5 <debuginfo_eip+0x2be>
f0105392:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105397:	eb 0c                	jmp    f01053a5 <debuginfo_eip+0x2be>
		return -1;
f0105399:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010539e:	eb 05                	jmp    f01053a5 <debuginfo_eip+0x2be>
	return 0;
f01053a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01053a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053a8:	5b                   	pop    %ebx
f01053a9:	5e                   	pop    %esi
f01053aa:	5f                   	pop    %edi
f01053ab:	5d                   	pop    %ebp
f01053ac:	c3                   	ret    

f01053ad <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01053ad:	55                   	push   %ebp
f01053ae:	89 e5                	mov    %esp,%ebp
f01053b0:	57                   	push   %edi
f01053b1:	56                   	push   %esi
f01053b2:	53                   	push   %ebx
f01053b3:	83 ec 1c             	sub    $0x1c,%esp
f01053b6:	89 c7                	mov    %eax,%edi
f01053b8:	89 d6                	mov    %edx,%esi
f01053ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01053bd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01053c0:	89 d1                	mov    %edx,%ecx
f01053c2:	89 c2                	mov    %eax,%edx
f01053c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01053ca:	8b 45 10             	mov    0x10(%ebp),%eax
f01053cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01053d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01053d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01053da:	39 c2                	cmp    %eax,%edx
f01053dc:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01053df:	72 3e                	jb     f010541f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01053e1:	83 ec 0c             	sub    $0xc,%esp
f01053e4:	ff 75 18             	push   0x18(%ebp)
f01053e7:	83 eb 01             	sub    $0x1,%ebx
f01053ea:	53                   	push   %ebx
f01053eb:	50                   	push   %eax
f01053ec:	83 ec 08             	sub    $0x8,%esp
f01053ef:	ff 75 e4             	push   -0x1c(%ebp)
f01053f2:	ff 75 e0             	push   -0x20(%ebp)
f01053f5:	ff 75 dc             	push   -0x24(%ebp)
f01053f8:	ff 75 d8             	push   -0x28(%ebp)
f01053fb:	e8 90 11 00 00       	call   f0106590 <__udivdi3>
f0105400:	83 c4 18             	add    $0x18,%esp
f0105403:	52                   	push   %edx
f0105404:	50                   	push   %eax
f0105405:	89 f2                	mov    %esi,%edx
f0105407:	89 f8                	mov    %edi,%eax
f0105409:	e8 9f ff ff ff       	call   f01053ad <printnum>
f010540e:	83 c4 20             	add    $0x20,%esp
f0105411:	eb 13                	jmp    f0105426 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105413:	83 ec 08             	sub    $0x8,%esp
f0105416:	56                   	push   %esi
f0105417:	ff 75 18             	push   0x18(%ebp)
f010541a:	ff d7                	call   *%edi
f010541c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010541f:	83 eb 01             	sub    $0x1,%ebx
f0105422:	85 db                	test   %ebx,%ebx
f0105424:	7f ed                	jg     f0105413 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105426:	83 ec 08             	sub    $0x8,%esp
f0105429:	56                   	push   %esi
f010542a:	83 ec 04             	sub    $0x4,%esp
f010542d:	ff 75 e4             	push   -0x1c(%ebp)
f0105430:	ff 75 e0             	push   -0x20(%ebp)
f0105433:	ff 75 dc             	push   -0x24(%ebp)
f0105436:	ff 75 d8             	push   -0x28(%ebp)
f0105439:	e8 72 12 00 00       	call   f01066b0 <__umoddi3>
f010543e:	83 c4 14             	add    $0x14,%esp
f0105441:	0f be 80 4e 83 10 f0 	movsbl -0xfef7cb2(%eax),%eax
f0105448:	50                   	push   %eax
f0105449:	ff d7                	call   *%edi
}
f010544b:	83 c4 10             	add    $0x10,%esp
f010544e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105451:	5b                   	pop    %ebx
f0105452:	5e                   	pop    %esi
f0105453:	5f                   	pop    %edi
f0105454:	5d                   	pop    %ebp
f0105455:	c3                   	ret    

f0105456 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105456:	55                   	push   %ebp
f0105457:	89 e5                	mov    %esp,%ebp
f0105459:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010545c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0105460:	8b 10                	mov    (%eax),%edx
f0105462:	3b 50 04             	cmp    0x4(%eax),%edx
f0105465:	73 0a                	jae    f0105471 <sprintputch+0x1b>
		*b->buf++ = ch;
f0105467:	8d 4a 01             	lea    0x1(%edx),%ecx
f010546a:	89 08                	mov    %ecx,(%eax)
f010546c:	8b 45 08             	mov    0x8(%ebp),%eax
f010546f:	88 02                	mov    %al,(%edx)
}
f0105471:	5d                   	pop    %ebp
f0105472:	c3                   	ret    

f0105473 <printfmt>:
{
f0105473:	55                   	push   %ebp
f0105474:	89 e5                	mov    %esp,%ebp
f0105476:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0105479:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010547c:	50                   	push   %eax
f010547d:	ff 75 10             	push   0x10(%ebp)
f0105480:	ff 75 0c             	push   0xc(%ebp)
f0105483:	ff 75 08             	push   0x8(%ebp)
f0105486:	e8 05 00 00 00       	call   f0105490 <vprintfmt>
}
f010548b:	83 c4 10             	add    $0x10,%esp
f010548e:	c9                   	leave  
f010548f:	c3                   	ret    

f0105490 <vprintfmt>:
{
f0105490:	55                   	push   %ebp
f0105491:	89 e5                	mov    %esp,%ebp
f0105493:	57                   	push   %edi
f0105494:	56                   	push   %esi
f0105495:	53                   	push   %ebx
f0105496:	83 ec 3c             	sub    $0x3c,%esp
f0105499:	8b 75 08             	mov    0x8(%ebp),%esi
f010549c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010549f:	8b 7d 10             	mov    0x10(%ebp),%edi
f01054a2:	eb 0a                	jmp    f01054ae <vprintfmt+0x1e>
			putch(ch, putdat);
f01054a4:	83 ec 08             	sub    $0x8,%esp
f01054a7:	53                   	push   %ebx
f01054a8:	50                   	push   %eax
f01054a9:	ff d6                	call   *%esi
f01054ab:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01054ae:	83 c7 01             	add    $0x1,%edi
f01054b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01054b5:	83 f8 25             	cmp    $0x25,%eax
f01054b8:	74 0c                	je     f01054c6 <vprintfmt+0x36>
			if (ch == '\0')
f01054ba:	85 c0                	test   %eax,%eax
f01054bc:	75 e6                	jne    f01054a4 <vprintfmt+0x14>
}
f01054be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01054c1:	5b                   	pop    %ebx
f01054c2:	5e                   	pop    %esi
f01054c3:	5f                   	pop    %edi
f01054c4:	5d                   	pop    %ebp
f01054c5:	c3                   	ret    
		padc = ' ';
f01054c6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f01054ca:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01054d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f01054d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01054df:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01054e4:	8d 47 01             	lea    0x1(%edi),%eax
f01054e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054ea:	0f b6 17             	movzbl (%edi),%edx
f01054ed:	8d 42 dd             	lea    -0x23(%edx),%eax
f01054f0:	3c 55                	cmp    $0x55,%al
f01054f2:	0f 87 bb 03 00 00    	ja     f01058b3 <vprintfmt+0x423>
f01054f8:	0f b6 c0             	movzbl %al,%eax
f01054fb:	ff 24 85 20 84 10 f0 	jmp    *-0xfef7be0(,%eax,4)
f0105502:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105505:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0105509:	eb d9                	jmp    f01054e4 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f010550b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010550e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105512:	eb d0                	jmp    f01054e4 <vprintfmt+0x54>
f0105514:	0f b6 d2             	movzbl %dl,%edx
f0105517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010551a:	b8 00 00 00 00       	mov    $0x0,%eax
f010551f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105522:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105525:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105529:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010552c:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010552f:	83 f9 09             	cmp    $0x9,%ecx
f0105532:	77 55                	ja     f0105589 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
f0105534:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105537:	eb e9                	jmp    f0105522 <vprintfmt+0x92>
			precision = va_arg(ap, int);
f0105539:	8b 45 14             	mov    0x14(%ebp),%eax
f010553c:	8b 00                	mov    (%eax),%eax
f010553e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105541:	8b 45 14             	mov    0x14(%ebp),%eax
f0105544:	8d 40 04             	lea    0x4(%eax),%eax
f0105547:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010554a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010554d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105551:	79 91                	jns    f01054e4 <vprintfmt+0x54>
				width = precision, precision = -1;
f0105553:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105556:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105559:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0105560:	eb 82                	jmp    f01054e4 <vprintfmt+0x54>
f0105562:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105565:	85 d2                	test   %edx,%edx
f0105567:	b8 00 00 00 00       	mov    $0x0,%eax
f010556c:	0f 49 c2             	cmovns %edx,%eax
f010556f:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105575:	e9 6a ff ff ff       	jmp    f01054e4 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
f010557a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f010557d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0105584:	e9 5b ff ff ff       	jmp    f01054e4 <vprintfmt+0x54>
f0105589:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010558c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010558f:	eb bc                	jmp    f010554d <vprintfmt+0xbd>
			lflag++;
f0105591:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0105597:	e9 48 ff ff ff       	jmp    f01054e4 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
f010559c:	8b 45 14             	mov    0x14(%ebp),%eax
f010559f:	8d 78 04             	lea    0x4(%eax),%edi
f01055a2:	83 ec 08             	sub    $0x8,%esp
f01055a5:	53                   	push   %ebx
f01055a6:	ff 30                	push   (%eax)
f01055a8:	ff d6                	call   *%esi
			break;
f01055aa:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01055ad:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01055b0:	e9 9d 02 00 00       	jmp    f0105852 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
f01055b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01055b8:	8d 78 04             	lea    0x4(%eax),%edi
f01055bb:	8b 10                	mov    (%eax),%edx
f01055bd:	89 d0                	mov    %edx,%eax
f01055bf:	f7 d8                	neg    %eax
f01055c1:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01055c4:	83 f8 08             	cmp    $0x8,%eax
f01055c7:	7f 23                	jg     f01055ec <vprintfmt+0x15c>
f01055c9:	8b 14 85 80 85 10 f0 	mov    -0xfef7a80(,%eax,4),%edx
f01055d0:	85 d2                	test   %edx,%edx
f01055d2:	74 18                	je     f01055ec <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
f01055d4:	52                   	push   %edx
f01055d5:	68 33 71 10 f0       	push   $0xf0107133
f01055da:	53                   	push   %ebx
f01055db:	56                   	push   %esi
f01055dc:	e8 92 fe ff ff       	call   f0105473 <printfmt>
f01055e1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01055e4:	89 7d 14             	mov    %edi,0x14(%ebp)
f01055e7:	e9 66 02 00 00       	jmp    f0105852 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
f01055ec:	50                   	push   %eax
f01055ed:	68 66 83 10 f0       	push   $0xf0108366
f01055f2:	53                   	push   %ebx
f01055f3:	56                   	push   %esi
f01055f4:	e8 7a fe ff ff       	call   f0105473 <printfmt>
f01055f9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01055fc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01055ff:	e9 4e 02 00 00       	jmp    f0105852 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
f0105604:	8b 45 14             	mov    0x14(%ebp),%eax
f0105607:	83 c0 04             	add    $0x4,%eax
f010560a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010560d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105610:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0105612:	85 d2                	test   %edx,%edx
f0105614:	b8 5f 83 10 f0       	mov    $0xf010835f,%eax
f0105619:	0f 45 c2             	cmovne %edx,%eax
f010561c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010561f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105623:	7e 06                	jle    f010562b <vprintfmt+0x19b>
f0105625:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105629:	75 0d                	jne    f0105638 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
f010562b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010562e:	89 c7                	mov    %eax,%edi
f0105630:	03 45 e0             	add    -0x20(%ebp),%eax
f0105633:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105636:	eb 55                	jmp    f010568d <vprintfmt+0x1fd>
f0105638:	83 ec 08             	sub    $0x8,%esp
f010563b:	ff 75 d8             	push   -0x28(%ebp)
f010563e:	ff 75 cc             	push   -0x34(%ebp)
f0105641:	e8 ec 03 00 00       	call   f0105a32 <strnlen>
f0105646:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105649:	29 c1                	sub    %eax,%ecx
f010564b:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f010564e:	83 c4 10             	add    $0x10,%esp
f0105651:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f0105653:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f0105657:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010565a:	eb 0f                	jmp    f010566b <vprintfmt+0x1db>
					putch(padc, putdat);
f010565c:	83 ec 08             	sub    $0x8,%esp
f010565f:	53                   	push   %ebx
f0105660:	ff 75 e0             	push   -0x20(%ebp)
f0105663:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105665:	83 ef 01             	sub    $0x1,%edi
f0105668:	83 c4 10             	add    $0x10,%esp
f010566b:	85 ff                	test   %edi,%edi
f010566d:	7f ed                	jg     f010565c <vprintfmt+0x1cc>
f010566f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105672:	85 d2                	test   %edx,%edx
f0105674:	b8 00 00 00 00       	mov    $0x0,%eax
f0105679:	0f 49 c2             	cmovns %edx,%eax
f010567c:	29 c2                	sub    %eax,%edx
f010567e:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105681:	eb a8                	jmp    f010562b <vprintfmt+0x19b>
					putch(ch, putdat);
f0105683:	83 ec 08             	sub    $0x8,%esp
f0105686:	53                   	push   %ebx
f0105687:	52                   	push   %edx
f0105688:	ff d6                	call   *%esi
f010568a:	83 c4 10             	add    $0x10,%esp
f010568d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105690:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105692:	83 c7 01             	add    $0x1,%edi
f0105695:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105699:	0f be d0             	movsbl %al,%edx
f010569c:	85 d2                	test   %edx,%edx
f010569e:	74 4b                	je     f01056eb <vprintfmt+0x25b>
f01056a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01056a4:	78 06                	js     f01056ac <vprintfmt+0x21c>
f01056a6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01056aa:	78 1e                	js     f01056ca <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
f01056ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01056b0:	74 d1                	je     f0105683 <vprintfmt+0x1f3>
f01056b2:	0f be c0             	movsbl %al,%eax
f01056b5:	83 e8 20             	sub    $0x20,%eax
f01056b8:	83 f8 5e             	cmp    $0x5e,%eax
f01056bb:	76 c6                	jbe    f0105683 <vprintfmt+0x1f3>
					putch('?', putdat);
f01056bd:	83 ec 08             	sub    $0x8,%esp
f01056c0:	53                   	push   %ebx
f01056c1:	6a 3f                	push   $0x3f
f01056c3:	ff d6                	call   *%esi
f01056c5:	83 c4 10             	add    $0x10,%esp
f01056c8:	eb c3                	jmp    f010568d <vprintfmt+0x1fd>
f01056ca:	89 cf                	mov    %ecx,%edi
f01056cc:	eb 0e                	jmp    f01056dc <vprintfmt+0x24c>
				putch(' ', putdat);
f01056ce:	83 ec 08             	sub    $0x8,%esp
f01056d1:	53                   	push   %ebx
f01056d2:	6a 20                	push   $0x20
f01056d4:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01056d6:	83 ef 01             	sub    $0x1,%edi
f01056d9:	83 c4 10             	add    $0x10,%esp
f01056dc:	85 ff                	test   %edi,%edi
f01056de:	7f ee                	jg     f01056ce <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
f01056e0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01056e3:	89 45 14             	mov    %eax,0x14(%ebp)
f01056e6:	e9 67 01 00 00       	jmp    f0105852 <vprintfmt+0x3c2>
f01056eb:	89 cf                	mov    %ecx,%edi
f01056ed:	eb ed                	jmp    f01056dc <vprintfmt+0x24c>
	if (lflag >= 2)
f01056ef:	83 f9 01             	cmp    $0x1,%ecx
f01056f2:	7f 1b                	jg     f010570f <vprintfmt+0x27f>
	else if (lflag)
f01056f4:	85 c9                	test   %ecx,%ecx
f01056f6:	74 63                	je     f010575b <vprintfmt+0x2cb>
		return va_arg(*ap, long);
f01056f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01056fb:	8b 00                	mov    (%eax),%eax
f01056fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105700:	99                   	cltd   
f0105701:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105704:	8b 45 14             	mov    0x14(%ebp),%eax
f0105707:	8d 40 04             	lea    0x4(%eax),%eax
f010570a:	89 45 14             	mov    %eax,0x14(%ebp)
f010570d:	eb 17                	jmp    f0105726 <vprintfmt+0x296>
		return va_arg(*ap, long long);
f010570f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105712:	8b 50 04             	mov    0x4(%eax),%edx
f0105715:	8b 00                	mov    (%eax),%eax
f0105717:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010571a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010571d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105720:	8d 40 08             	lea    0x8(%eax),%eax
f0105723:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105726:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105729:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010572c:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
f0105731:	85 c9                	test   %ecx,%ecx
f0105733:	0f 89 ff 00 00 00    	jns    f0105838 <vprintfmt+0x3a8>
				putch('-', putdat);
f0105739:	83 ec 08             	sub    $0x8,%esp
f010573c:	53                   	push   %ebx
f010573d:	6a 2d                	push   $0x2d
f010573f:	ff d6                	call   *%esi
				num = -(long long) num;
f0105741:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105744:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105747:	f7 da                	neg    %edx
f0105749:	83 d1 00             	adc    $0x0,%ecx
f010574c:	f7 d9                	neg    %ecx
f010574e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105751:	bf 0a 00 00 00       	mov    $0xa,%edi
f0105756:	e9 dd 00 00 00       	jmp    f0105838 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
f010575b:	8b 45 14             	mov    0x14(%ebp),%eax
f010575e:	8b 00                	mov    (%eax),%eax
f0105760:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105763:	99                   	cltd   
f0105764:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105767:	8b 45 14             	mov    0x14(%ebp),%eax
f010576a:	8d 40 04             	lea    0x4(%eax),%eax
f010576d:	89 45 14             	mov    %eax,0x14(%ebp)
f0105770:	eb b4                	jmp    f0105726 <vprintfmt+0x296>
	if (lflag >= 2)
f0105772:	83 f9 01             	cmp    $0x1,%ecx
f0105775:	7f 1e                	jg     f0105795 <vprintfmt+0x305>
	else if (lflag)
f0105777:	85 c9                	test   %ecx,%ecx
f0105779:	74 32                	je     f01057ad <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
f010577b:	8b 45 14             	mov    0x14(%ebp),%eax
f010577e:	8b 10                	mov    (%eax),%edx
f0105780:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105785:	8d 40 04             	lea    0x4(%eax),%eax
f0105788:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010578b:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
f0105790:	e9 a3 00 00 00       	jmp    f0105838 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f0105795:	8b 45 14             	mov    0x14(%ebp),%eax
f0105798:	8b 10                	mov    (%eax),%edx
f010579a:	8b 48 04             	mov    0x4(%eax),%ecx
f010579d:	8d 40 08             	lea    0x8(%eax),%eax
f01057a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01057a3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
f01057a8:	e9 8b 00 00 00       	jmp    f0105838 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f01057ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01057b0:	8b 10                	mov    (%eax),%edx
f01057b2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057b7:	8d 40 04             	lea    0x4(%eax),%eax
f01057ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01057bd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
f01057c2:	eb 74                	jmp    f0105838 <vprintfmt+0x3a8>
	if (lflag >= 2)
f01057c4:	83 f9 01             	cmp    $0x1,%ecx
f01057c7:	7f 1b                	jg     f01057e4 <vprintfmt+0x354>
	else if (lflag)
f01057c9:	85 c9                	test   %ecx,%ecx
f01057cb:	74 2c                	je     f01057f9 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
f01057cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01057d0:	8b 10                	mov    (%eax),%edx
f01057d2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057d7:	8d 40 04             	lea    0x4(%eax),%eax
f01057da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01057dd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
f01057e2:	eb 54                	jmp    f0105838 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f01057e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01057e7:	8b 10                	mov    (%eax),%edx
f01057e9:	8b 48 04             	mov    0x4(%eax),%ecx
f01057ec:	8d 40 08             	lea    0x8(%eax),%eax
f01057ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01057f2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
f01057f7:	eb 3f                	jmp    f0105838 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f01057f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01057fc:	8b 10                	mov    (%eax),%edx
f01057fe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105803:	8d 40 04             	lea    0x4(%eax),%eax
f0105806:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105809:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
f010580e:	eb 28                	jmp    f0105838 <vprintfmt+0x3a8>
			putch('0', putdat);
f0105810:	83 ec 08             	sub    $0x8,%esp
f0105813:	53                   	push   %ebx
f0105814:	6a 30                	push   $0x30
f0105816:	ff d6                	call   *%esi
			putch('x', putdat);
f0105818:	83 c4 08             	add    $0x8,%esp
f010581b:	53                   	push   %ebx
f010581c:	6a 78                	push   $0x78
f010581e:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105820:	8b 45 14             	mov    0x14(%ebp),%eax
f0105823:	8b 10                	mov    (%eax),%edx
f0105825:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010582a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010582d:	8d 40 04             	lea    0x4(%eax),%eax
f0105830:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105833:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
f0105838:	83 ec 0c             	sub    $0xc,%esp
f010583b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f010583f:	50                   	push   %eax
f0105840:	ff 75 e0             	push   -0x20(%ebp)
f0105843:	57                   	push   %edi
f0105844:	51                   	push   %ecx
f0105845:	52                   	push   %edx
f0105846:	89 da                	mov    %ebx,%edx
f0105848:	89 f0                	mov    %esi,%eax
f010584a:	e8 5e fb ff ff       	call   f01053ad <printnum>
			break;
f010584f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0105852:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105855:	e9 54 fc ff ff       	jmp    f01054ae <vprintfmt+0x1e>
	if (lflag >= 2)
f010585a:	83 f9 01             	cmp    $0x1,%ecx
f010585d:	7f 1b                	jg     f010587a <vprintfmt+0x3ea>
	else if (lflag)
f010585f:	85 c9                	test   %ecx,%ecx
f0105861:	74 2c                	je     f010588f <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
f0105863:	8b 45 14             	mov    0x14(%ebp),%eax
f0105866:	8b 10                	mov    (%eax),%edx
f0105868:	b9 00 00 00 00       	mov    $0x0,%ecx
f010586d:	8d 40 04             	lea    0x4(%eax),%eax
f0105870:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105873:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
f0105878:	eb be                	jmp    f0105838 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
f010587a:	8b 45 14             	mov    0x14(%ebp),%eax
f010587d:	8b 10                	mov    (%eax),%edx
f010587f:	8b 48 04             	mov    0x4(%eax),%ecx
f0105882:	8d 40 08             	lea    0x8(%eax),%eax
f0105885:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105888:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
f010588d:	eb a9                	jmp    f0105838 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
f010588f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105892:	8b 10                	mov    (%eax),%edx
f0105894:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105899:	8d 40 04             	lea    0x4(%eax),%eax
f010589c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010589f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
f01058a4:	eb 92                	jmp    f0105838 <vprintfmt+0x3a8>
			putch(ch, putdat);
f01058a6:	83 ec 08             	sub    $0x8,%esp
f01058a9:	53                   	push   %ebx
f01058aa:	6a 25                	push   $0x25
f01058ac:	ff d6                	call   *%esi
			break;
f01058ae:	83 c4 10             	add    $0x10,%esp
f01058b1:	eb 9f                	jmp    f0105852 <vprintfmt+0x3c2>
			putch('%', putdat);
f01058b3:	83 ec 08             	sub    $0x8,%esp
f01058b6:	53                   	push   %ebx
f01058b7:	6a 25                	push   $0x25
f01058b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01058bb:	83 c4 10             	add    $0x10,%esp
f01058be:	89 f8                	mov    %edi,%eax
f01058c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01058c4:	74 05                	je     f01058cb <vprintfmt+0x43b>
f01058c6:	83 e8 01             	sub    $0x1,%eax
f01058c9:	eb f5                	jmp    f01058c0 <vprintfmt+0x430>
f01058cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058ce:	eb 82                	jmp    f0105852 <vprintfmt+0x3c2>

f01058d0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01058d0:	55                   	push   %ebp
f01058d1:	89 e5                	mov    %esp,%ebp
f01058d3:	83 ec 18             	sub    $0x18,%esp
f01058d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01058d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01058dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01058df:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01058e3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01058e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01058ed:	85 c0                	test   %eax,%eax
f01058ef:	74 26                	je     f0105917 <vsnprintf+0x47>
f01058f1:	85 d2                	test   %edx,%edx
f01058f3:	7e 22                	jle    f0105917 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01058f5:	ff 75 14             	push   0x14(%ebp)
f01058f8:	ff 75 10             	push   0x10(%ebp)
f01058fb:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01058fe:	50                   	push   %eax
f01058ff:	68 56 54 10 f0       	push   $0xf0105456
f0105904:	e8 87 fb ff ff       	call   f0105490 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105909:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010590c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010590f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105912:	83 c4 10             	add    $0x10,%esp
}
f0105915:	c9                   	leave  
f0105916:	c3                   	ret    
		return -E_INVAL;
f0105917:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010591c:	eb f7                	jmp    f0105915 <vsnprintf+0x45>

f010591e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010591e:	55                   	push   %ebp
f010591f:	89 e5                	mov    %esp,%ebp
f0105921:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105924:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105927:	50                   	push   %eax
f0105928:	ff 75 10             	push   0x10(%ebp)
f010592b:	ff 75 0c             	push   0xc(%ebp)
f010592e:	ff 75 08             	push   0x8(%ebp)
f0105931:	e8 9a ff ff ff       	call   f01058d0 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105936:	c9                   	leave  
f0105937:	c3                   	ret    

f0105938 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105938:	55                   	push   %ebp
f0105939:	89 e5                	mov    %esp,%ebp
f010593b:	57                   	push   %edi
f010593c:	56                   	push   %esi
f010593d:	53                   	push   %ebx
f010593e:	83 ec 0c             	sub    $0xc,%esp
f0105941:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105944:	85 c0                	test   %eax,%eax
f0105946:	74 11                	je     f0105959 <readline+0x21>
		cprintf("%s", prompt);
f0105948:	83 ec 08             	sub    $0x8,%esp
f010594b:	50                   	push   %eax
f010594c:	68 33 71 10 f0       	push   $0xf0107133
f0105951:	e8 1c e3 ff ff       	call   f0103c72 <cprintf>
f0105956:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105959:	83 ec 0c             	sub    $0xc,%esp
f010595c:	6a 00                	push   $0x0
f010595e:	e8 08 ae ff ff       	call   f010076b <iscons>
f0105963:	89 c7                	mov    %eax,%edi
f0105965:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105968:	be 00 00 00 00       	mov    $0x0,%esi
f010596d:	eb 3f                	jmp    f01059ae <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010596f:	83 ec 08             	sub    $0x8,%esp
f0105972:	50                   	push   %eax
f0105973:	68 a4 85 10 f0       	push   $0xf01085a4
f0105978:	e8 f5 e2 ff ff       	call   f0103c72 <cprintf>
			return NULL;
f010597d:	83 c4 10             	add    $0x10,%esp
f0105980:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105985:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105988:	5b                   	pop    %ebx
f0105989:	5e                   	pop    %esi
f010598a:	5f                   	pop    %edi
f010598b:	5d                   	pop    %ebp
f010598c:	c3                   	ret    
			if (echoing)
f010598d:	85 ff                	test   %edi,%edi
f010598f:	75 05                	jne    f0105996 <readline+0x5e>
			i--;
f0105991:	83 ee 01             	sub    $0x1,%esi
f0105994:	eb 18                	jmp    f01059ae <readline+0x76>
				cputchar('\b');
f0105996:	83 ec 0c             	sub    $0xc,%esp
f0105999:	6a 08                	push   $0x8
f010599b:	e8 aa ad ff ff       	call   f010074a <cputchar>
f01059a0:	83 c4 10             	add    $0x10,%esp
f01059a3:	eb ec                	jmp    f0105991 <readline+0x59>
			buf[i++] = c;
f01059a5:	88 9e a0 7a 22 f0    	mov    %bl,-0xfdd8560(%esi)
f01059ab:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f01059ae:	e8 a7 ad ff ff       	call   f010075a <getchar>
f01059b3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01059b5:	85 c0                	test   %eax,%eax
f01059b7:	78 b6                	js     f010596f <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01059b9:	83 f8 08             	cmp    $0x8,%eax
f01059bc:	0f 94 c0             	sete   %al
f01059bf:	83 fb 7f             	cmp    $0x7f,%ebx
f01059c2:	0f 94 c2             	sete   %dl
f01059c5:	08 d0                	or     %dl,%al
f01059c7:	74 04                	je     f01059cd <readline+0x95>
f01059c9:	85 f6                	test   %esi,%esi
f01059cb:	7f c0                	jg     f010598d <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01059cd:	83 fb 1f             	cmp    $0x1f,%ebx
f01059d0:	7e 1a                	jle    f01059ec <readline+0xb4>
f01059d2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01059d8:	7f 12                	jg     f01059ec <readline+0xb4>
			if (echoing)
f01059da:	85 ff                	test   %edi,%edi
f01059dc:	74 c7                	je     f01059a5 <readline+0x6d>
				cputchar(c);
f01059de:	83 ec 0c             	sub    $0xc,%esp
f01059e1:	53                   	push   %ebx
f01059e2:	e8 63 ad ff ff       	call   f010074a <cputchar>
f01059e7:	83 c4 10             	add    $0x10,%esp
f01059ea:	eb b9                	jmp    f01059a5 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f01059ec:	83 fb 0a             	cmp    $0xa,%ebx
f01059ef:	74 05                	je     f01059f6 <readline+0xbe>
f01059f1:	83 fb 0d             	cmp    $0xd,%ebx
f01059f4:	75 b8                	jne    f01059ae <readline+0x76>
			if (echoing)
f01059f6:	85 ff                	test   %edi,%edi
f01059f8:	75 11                	jne    f0105a0b <readline+0xd3>
			buf[i] = 0;
f01059fa:	c6 86 a0 7a 22 f0 00 	movb   $0x0,-0xfdd8560(%esi)
			return buf;
f0105a01:	b8 a0 7a 22 f0       	mov    $0xf0227aa0,%eax
f0105a06:	e9 7a ff ff ff       	jmp    f0105985 <readline+0x4d>
				cputchar('\n');
f0105a0b:	83 ec 0c             	sub    $0xc,%esp
f0105a0e:	6a 0a                	push   $0xa
f0105a10:	e8 35 ad ff ff       	call   f010074a <cputchar>
f0105a15:	83 c4 10             	add    $0x10,%esp
f0105a18:	eb e0                	jmp    f01059fa <readline+0xc2>

f0105a1a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105a1a:	55                   	push   %ebp
f0105a1b:	89 e5                	mov    %esp,%ebp
f0105a1d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105a20:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a25:	eb 03                	jmp    f0105a2a <strlen+0x10>
		n++;
f0105a27:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0105a2a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105a2e:	75 f7                	jne    f0105a27 <strlen+0xd>
	return n;
}
f0105a30:	5d                   	pop    %ebp
f0105a31:	c3                   	ret    

f0105a32 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105a32:	55                   	push   %ebp
f0105a33:	89 e5                	mov    %esp,%ebp
f0105a35:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a38:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105a3b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a40:	eb 03                	jmp    f0105a45 <strnlen+0x13>
		n++;
f0105a42:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105a45:	39 d0                	cmp    %edx,%eax
f0105a47:	74 08                	je     f0105a51 <strnlen+0x1f>
f0105a49:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105a4d:	75 f3                	jne    f0105a42 <strnlen+0x10>
f0105a4f:	89 c2                	mov    %eax,%edx
	return n;
}
f0105a51:	89 d0                	mov    %edx,%eax
f0105a53:	5d                   	pop    %ebp
f0105a54:	c3                   	ret    

f0105a55 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105a55:	55                   	push   %ebp
f0105a56:	89 e5                	mov    %esp,%ebp
f0105a58:	53                   	push   %ebx
f0105a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a5c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105a5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a64:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105a68:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105a6b:	83 c0 01             	add    $0x1,%eax
f0105a6e:	84 d2                	test   %dl,%dl
f0105a70:	75 f2                	jne    f0105a64 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105a72:	89 c8                	mov    %ecx,%eax
f0105a74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105a77:	c9                   	leave  
f0105a78:	c3                   	ret    

f0105a79 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105a79:	55                   	push   %ebp
f0105a7a:	89 e5                	mov    %esp,%ebp
f0105a7c:	53                   	push   %ebx
f0105a7d:	83 ec 10             	sub    $0x10,%esp
f0105a80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105a83:	53                   	push   %ebx
f0105a84:	e8 91 ff ff ff       	call   f0105a1a <strlen>
f0105a89:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105a8c:	ff 75 0c             	push   0xc(%ebp)
f0105a8f:	01 d8                	add    %ebx,%eax
f0105a91:	50                   	push   %eax
f0105a92:	e8 be ff ff ff       	call   f0105a55 <strcpy>
	return dst;
}
f0105a97:	89 d8                	mov    %ebx,%eax
f0105a99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105a9c:	c9                   	leave  
f0105a9d:	c3                   	ret    

f0105a9e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105a9e:	55                   	push   %ebp
f0105a9f:	89 e5                	mov    %esp,%ebp
f0105aa1:	56                   	push   %esi
f0105aa2:	53                   	push   %ebx
f0105aa3:	8b 75 08             	mov    0x8(%ebp),%esi
f0105aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105aa9:	89 f3                	mov    %esi,%ebx
f0105aab:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105aae:	89 f0                	mov    %esi,%eax
f0105ab0:	eb 0f                	jmp    f0105ac1 <strncpy+0x23>
		*dst++ = *src;
f0105ab2:	83 c0 01             	add    $0x1,%eax
f0105ab5:	0f b6 0a             	movzbl (%edx),%ecx
f0105ab8:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105abb:	80 f9 01             	cmp    $0x1,%cl
f0105abe:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0105ac1:	39 d8                	cmp    %ebx,%eax
f0105ac3:	75 ed                	jne    f0105ab2 <strncpy+0x14>
	}
	return ret;
}
f0105ac5:	89 f0                	mov    %esi,%eax
f0105ac7:	5b                   	pop    %ebx
f0105ac8:	5e                   	pop    %esi
f0105ac9:	5d                   	pop    %ebp
f0105aca:	c3                   	ret    

f0105acb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105acb:	55                   	push   %ebp
f0105acc:	89 e5                	mov    %esp,%ebp
f0105ace:	56                   	push   %esi
f0105acf:	53                   	push   %ebx
f0105ad0:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ad6:	8b 55 10             	mov    0x10(%ebp),%edx
f0105ad9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105adb:	85 d2                	test   %edx,%edx
f0105add:	74 21                	je     f0105b00 <strlcpy+0x35>
f0105adf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105ae3:	89 f2                	mov    %esi,%edx
f0105ae5:	eb 09                	jmp    f0105af0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105ae7:	83 c1 01             	add    $0x1,%ecx
f0105aea:	83 c2 01             	add    $0x1,%edx
f0105aed:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
f0105af0:	39 c2                	cmp    %eax,%edx
f0105af2:	74 09                	je     f0105afd <strlcpy+0x32>
f0105af4:	0f b6 19             	movzbl (%ecx),%ebx
f0105af7:	84 db                	test   %bl,%bl
f0105af9:	75 ec                	jne    f0105ae7 <strlcpy+0x1c>
f0105afb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105afd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105b00:	29 f0                	sub    %esi,%eax
}
f0105b02:	5b                   	pop    %ebx
f0105b03:	5e                   	pop    %esi
f0105b04:	5d                   	pop    %ebp
f0105b05:	c3                   	ret    

f0105b06 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105b06:	55                   	push   %ebp
f0105b07:	89 e5                	mov    %esp,%ebp
f0105b09:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105b0f:	eb 06                	jmp    f0105b17 <strcmp+0x11>
		p++, q++;
f0105b11:	83 c1 01             	add    $0x1,%ecx
f0105b14:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0105b17:	0f b6 01             	movzbl (%ecx),%eax
f0105b1a:	84 c0                	test   %al,%al
f0105b1c:	74 04                	je     f0105b22 <strcmp+0x1c>
f0105b1e:	3a 02                	cmp    (%edx),%al
f0105b20:	74 ef                	je     f0105b11 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105b22:	0f b6 c0             	movzbl %al,%eax
f0105b25:	0f b6 12             	movzbl (%edx),%edx
f0105b28:	29 d0                	sub    %edx,%eax
}
f0105b2a:	5d                   	pop    %ebp
f0105b2b:	c3                   	ret    

f0105b2c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105b2c:	55                   	push   %ebp
f0105b2d:	89 e5                	mov    %esp,%ebp
f0105b2f:	53                   	push   %ebx
f0105b30:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b33:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b36:	89 c3                	mov    %eax,%ebx
f0105b38:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105b3b:	eb 06                	jmp    f0105b43 <strncmp+0x17>
		n--, p++, q++;
f0105b3d:	83 c0 01             	add    $0x1,%eax
f0105b40:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105b43:	39 d8                	cmp    %ebx,%eax
f0105b45:	74 18                	je     f0105b5f <strncmp+0x33>
f0105b47:	0f b6 08             	movzbl (%eax),%ecx
f0105b4a:	84 c9                	test   %cl,%cl
f0105b4c:	74 04                	je     f0105b52 <strncmp+0x26>
f0105b4e:	3a 0a                	cmp    (%edx),%cl
f0105b50:	74 eb                	je     f0105b3d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105b52:	0f b6 00             	movzbl (%eax),%eax
f0105b55:	0f b6 12             	movzbl (%edx),%edx
f0105b58:	29 d0                	sub    %edx,%eax
}
f0105b5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105b5d:	c9                   	leave  
f0105b5e:	c3                   	ret    
		return 0;
f0105b5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b64:	eb f4                	jmp    f0105b5a <strncmp+0x2e>

f0105b66 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105b66:	55                   	push   %ebp
f0105b67:	89 e5                	mov    %esp,%ebp
f0105b69:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b6c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105b70:	eb 03                	jmp    f0105b75 <strchr+0xf>
f0105b72:	83 c0 01             	add    $0x1,%eax
f0105b75:	0f b6 10             	movzbl (%eax),%edx
f0105b78:	84 d2                	test   %dl,%dl
f0105b7a:	74 06                	je     f0105b82 <strchr+0x1c>
		if (*s == c)
f0105b7c:	38 ca                	cmp    %cl,%dl
f0105b7e:	75 f2                	jne    f0105b72 <strchr+0xc>
f0105b80:	eb 05                	jmp    f0105b87 <strchr+0x21>
			return (char *) s;
	return 0;
f0105b82:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b87:	5d                   	pop    %ebp
f0105b88:	c3                   	ret    

f0105b89 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105b89:	55                   	push   %ebp
f0105b8a:	89 e5                	mov    %esp,%ebp
f0105b8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b8f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105b93:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105b96:	38 ca                	cmp    %cl,%dl
f0105b98:	74 09                	je     f0105ba3 <strfind+0x1a>
f0105b9a:	84 d2                	test   %dl,%dl
f0105b9c:	74 05                	je     f0105ba3 <strfind+0x1a>
	for (; *s; s++)
f0105b9e:	83 c0 01             	add    $0x1,%eax
f0105ba1:	eb f0                	jmp    f0105b93 <strfind+0xa>
			break;
	return (char *) s;
}
f0105ba3:	5d                   	pop    %ebp
f0105ba4:	c3                   	ret    

f0105ba5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105ba5:	55                   	push   %ebp
f0105ba6:	89 e5                	mov    %esp,%ebp
f0105ba8:	57                   	push   %edi
f0105ba9:	56                   	push   %esi
f0105baa:	53                   	push   %ebx
f0105bab:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105bae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105bb1:	85 c9                	test   %ecx,%ecx
f0105bb3:	74 2f                	je     f0105be4 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105bb5:	89 f8                	mov    %edi,%eax
f0105bb7:	09 c8                	or     %ecx,%eax
f0105bb9:	a8 03                	test   $0x3,%al
f0105bbb:	75 21                	jne    f0105bde <memset+0x39>
		c &= 0xFF;
f0105bbd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105bc1:	89 d0                	mov    %edx,%eax
f0105bc3:	c1 e0 08             	shl    $0x8,%eax
f0105bc6:	89 d3                	mov    %edx,%ebx
f0105bc8:	c1 e3 18             	shl    $0x18,%ebx
f0105bcb:	89 d6                	mov    %edx,%esi
f0105bcd:	c1 e6 10             	shl    $0x10,%esi
f0105bd0:	09 f3                	or     %esi,%ebx
f0105bd2:	09 da                	or     %ebx,%edx
f0105bd4:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105bd6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105bd9:	fc                   	cld    
f0105bda:	f3 ab                	rep stos %eax,%es:(%edi)
f0105bdc:	eb 06                	jmp    f0105be4 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105bde:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105be1:	fc                   	cld    
f0105be2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105be4:	89 f8                	mov    %edi,%eax
f0105be6:	5b                   	pop    %ebx
f0105be7:	5e                   	pop    %esi
f0105be8:	5f                   	pop    %edi
f0105be9:	5d                   	pop    %ebp
f0105bea:	c3                   	ret    

f0105beb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105beb:	55                   	push   %ebp
f0105bec:	89 e5                	mov    %esp,%ebp
f0105bee:	57                   	push   %edi
f0105bef:	56                   	push   %esi
f0105bf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bf3:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105bf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105bf9:	39 c6                	cmp    %eax,%esi
f0105bfb:	73 32                	jae    f0105c2f <memmove+0x44>
f0105bfd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105c00:	39 c2                	cmp    %eax,%edx
f0105c02:	76 2b                	jbe    f0105c2f <memmove+0x44>
		s += n;
		d += n;
f0105c04:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105c07:	89 d6                	mov    %edx,%esi
f0105c09:	09 fe                	or     %edi,%esi
f0105c0b:	09 ce                	or     %ecx,%esi
f0105c0d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105c13:	75 0e                	jne    f0105c23 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105c15:	83 ef 04             	sub    $0x4,%edi
f0105c18:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105c1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105c1e:	fd                   	std    
f0105c1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c21:	eb 09                	jmp    f0105c2c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105c23:	83 ef 01             	sub    $0x1,%edi
f0105c26:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105c29:	fd                   	std    
f0105c2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105c2c:	fc                   	cld    
f0105c2d:	eb 1a                	jmp    f0105c49 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105c2f:	89 f2                	mov    %esi,%edx
f0105c31:	09 c2                	or     %eax,%edx
f0105c33:	09 ca                	or     %ecx,%edx
f0105c35:	f6 c2 03             	test   $0x3,%dl
f0105c38:	75 0a                	jne    f0105c44 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105c3a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105c3d:	89 c7                	mov    %eax,%edi
f0105c3f:	fc                   	cld    
f0105c40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c42:	eb 05                	jmp    f0105c49 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0105c44:	89 c7                	mov    %eax,%edi
f0105c46:	fc                   	cld    
f0105c47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105c49:	5e                   	pop    %esi
f0105c4a:	5f                   	pop    %edi
f0105c4b:	5d                   	pop    %ebp
f0105c4c:	c3                   	ret    

f0105c4d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105c4d:	55                   	push   %ebp
f0105c4e:	89 e5                	mov    %esp,%ebp
f0105c50:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105c53:	ff 75 10             	push   0x10(%ebp)
f0105c56:	ff 75 0c             	push   0xc(%ebp)
f0105c59:	ff 75 08             	push   0x8(%ebp)
f0105c5c:	e8 8a ff ff ff       	call   f0105beb <memmove>
}
f0105c61:	c9                   	leave  
f0105c62:	c3                   	ret    

f0105c63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105c63:	55                   	push   %ebp
f0105c64:	89 e5                	mov    %esp,%ebp
f0105c66:	56                   	push   %esi
f0105c67:	53                   	push   %ebx
f0105c68:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c6e:	89 c6                	mov    %eax,%esi
f0105c70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105c73:	eb 06                	jmp    f0105c7b <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105c75:	83 c0 01             	add    $0x1,%eax
f0105c78:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f0105c7b:	39 f0                	cmp    %esi,%eax
f0105c7d:	74 14                	je     f0105c93 <memcmp+0x30>
		if (*s1 != *s2)
f0105c7f:	0f b6 08             	movzbl (%eax),%ecx
f0105c82:	0f b6 1a             	movzbl (%edx),%ebx
f0105c85:	38 d9                	cmp    %bl,%cl
f0105c87:	74 ec                	je     f0105c75 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
f0105c89:	0f b6 c1             	movzbl %cl,%eax
f0105c8c:	0f b6 db             	movzbl %bl,%ebx
f0105c8f:	29 d8                	sub    %ebx,%eax
f0105c91:	eb 05                	jmp    f0105c98 <memcmp+0x35>
	}

	return 0;
f0105c93:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c98:	5b                   	pop    %ebx
f0105c99:	5e                   	pop    %esi
f0105c9a:	5d                   	pop    %ebp
f0105c9b:	c3                   	ret    

f0105c9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105c9c:	55                   	push   %ebp
f0105c9d:	89 e5                	mov    %esp,%ebp
f0105c9f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105ca5:	89 c2                	mov    %eax,%edx
f0105ca7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105caa:	eb 03                	jmp    f0105caf <memfind+0x13>
f0105cac:	83 c0 01             	add    $0x1,%eax
f0105caf:	39 d0                	cmp    %edx,%eax
f0105cb1:	73 04                	jae    f0105cb7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105cb3:	38 08                	cmp    %cl,(%eax)
f0105cb5:	75 f5                	jne    f0105cac <memfind+0x10>
			break;
	return (void *) s;
}
f0105cb7:	5d                   	pop    %ebp
f0105cb8:	c3                   	ret    

f0105cb9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105cb9:	55                   	push   %ebp
f0105cba:	89 e5                	mov    %esp,%ebp
f0105cbc:	57                   	push   %edi
f0105cbd:	56                   	push   %esi
f0105cbe:	53                   	push   %ebx
f0105cbf:	8b 55 08             	mov    0x8(%ebp),%edx
f0105cc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105cc5:	eb 03                	jmp    f0105cca <strtol+0x11>
		s++;
f0105cc7:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0105cca:	0f b6 02             	movzbl (%edx),%eax
f0105ccd:	3c 20                	cmp    $0x20,%al
f0105ccf:	74 f6                	je     f0105cc7 <strtol+0xe>
f0105cd1:	3c 09                	cmp    $0x9,%al
f0105cd3:	74 f2                	je     f0105cc7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105cd5:	3c 2b                	cmp    $0x2b,%al
f0105cd7:	74 2a                	je     f0105d03 <strtol+0x4a>
	int neg = 0;
f0105cd9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105cde:	3c 2d                	cmp    $0x2d,%al
f0105ce0:	74 2b                	je     f0105d0d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105ce2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105ce8:	75 0f                	jne    f0105cf9 <strtol+0x40>
f0105cea:	80 3a 30             	cmpb   $0x30,(%edx)
f0105ced:	74 28                	je     f0105d17 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105cef:	85 db                	test   %ebx,%ebx
f0105cf1:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105cf6:	0f 44 d8             	cmove  %eax,%ebx
f0105cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105cfe:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105d01:	eb 46                	jmp    f0105d49 <strtol+0x90>
		s++;
f0105d03:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f0105d06:	bf 00 00 00 00       	mov    $0x0,%edi
f0105d0b:	eb d5                	jmp    f0105ce2 <strtol+0x29>
		s++, neg = 1;
f0105d0d:	83 c2 01             	add    $0x1,%edx
f0105d10:	bf 01 00 00 00       	mov    $0x1,%edi
f0105d15:	eb cb                	jmp    f0105ce2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105d17:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105d1b:	74 0e                	je     f0105d2b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0105d1d:	85 db                	test   %ebx,%ebx
f0105d1f:	75 d8                	jne    f0105cf9 <strtol+0x40>
		s++, base = 8;
f0105d21:	83 c2 01             	add    $0x1,%edx
f0105d24:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105d29:	eb ce                	jmp    f0105cf9 <strtol+0x40>
		s += 2, base = 16;
f0105d2b:	83 c2 02             	add    $0x2,%edx
f0105d2e:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105d33:	eb c4                	jmp    f0105cf9 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105d35:	0f be c0             	movsbl %al,%eax
f0105d38:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105d3b:	3b 45 10             	cmp    0x10(%ebp),%eax
f0105d3e:	7d 3a                	jge    f0105d7a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105d40:	83 c2 01             	add    $0x1,%edx
f0105d43:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f0105d47:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f0105d49:	0f b6 02             	movzbl (%edx),%eax
f0105d4c:	8d 70 d0             	lea    -0x30(%eax),%esi
f0105d4f:	89 f3                	mov    %esi,%ebx
f0105d51:	80 fb 09             	cmp    $0x9,%bl
f0105d54:	76 df                	jbe    f0105d35 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
f0105d56:	8d 70 9f             	lea    -0x61(%eax),%esi
f0105d59:	89 f3                	mov    %esi,%ebx
f0105d5b:	80 fb 19             	cmp    $0x19,%bl
f0105d5e:	77 08                	ja     f0105d68 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105d60:	0f be c0             	movsbl %al,%eax
f0105d63:	83 e8 57             	sub    $0x57,%eax
f0105d66:	eb d3                	jmp    f0105d3b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
f0105d68:	8d 70 bf             	lea    -0x41(%eax),%esi
f0105d6b:	89 f3                	mov    %esi,%ebx
f0105d6d:	80 fb 19             	cmp    $0x19,%bl
f0105d70:	77 08                	ja     f0105d7a <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105d72:	0f be c0             	movsbl %al,%eax
f0105d75:	83 e8 37             	sub    $0x37,%eax
f0105d78:	eb c1                	jmp    f0105d3b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105d7a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105d7e:	74 05                	je     f0105d85 <strtol+0xcc>
		*endptr = (char *) s;
f0105d80:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d83:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0105d85:	89 c8                	mov    %ecx,%eax
f0105d87:	f7 d8                	neg    %eax
f0105d89:	85 ff                	test   %edi,%edi
f0105d8b:	0f 45 c8             	cmovne %eax,%ecx
}
f0105d8e:	89 c8                	mov    %ecx,%eax
f0105d90:	5b                   	pop    %ebx
f0105d91:	5e                   	pop    %esi
f0105d92:	5f                   	pop    %edi
f0105d93:	5d                   	pop    %ebp
f0105d94:	c3                   	ret    
f0105d95:	66 90                	xchg   %ax,%ax
f0105d97:	90                   	nop

f0105d98 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105d98:	fa                   	cli    

	xorw    %ax, %ax
f0105d99:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105d9b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d9d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d9f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105da1:	0f 01 16             	lgdtl  (%esi)
f0105da4:	74 70                	je     f0105e16 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105da6:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105da9:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105dad:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105db0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105db6:	08 00                	or     %al,(%eax)

f0105db8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105db8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105dbc:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105dbe:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105dc0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105dc2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105dc6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105dc8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105dca:	b8 00 40 12 00       	mov    $0x124000,%eax
	movl    %eax, %cr3
f0105dcf:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105dd2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105dd5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105dda:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105ddd:	8b 25 04 70 22 f0    	mov    0xf0227004,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105de3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105de8:	b8 a4 01 10 f0       	mov    $0xf01001a4,%eax
	call    *%eax
f0105ded:	ff d0                	call   *%eax

f0105def <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105def:	eb fe                	jmp    f0105def <spin>
f0105df1:	8d 76 00             	lea    0x0(%esi),%esi

f0105df4 <gdt>:
	...
f0105dfc:	ff                   	(bad)  
f0105dfd:	ff 00                	incl   (%eax)
f0105dff:	00 00                	add    %al,(%eax)
f0105e01:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105e08:	00                   	.byte 0x0
f0105e09:	92                   	xchg   %eax,%edx
f0105e0a:	cf                   	iret   
	...

f0105e0c <gdtdesc>:
f0105e0c:	17                   	pop    %ss
f0105e0d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105e12 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105e12:	90                   	nop

f0105e13 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105e13:	55                   	push   %ebp
f0105e14:	89 e5                	mov    %esp,%ebp
f0105e16:	57                   	push   %edi
f0105e17:	56                   	push   %esi
f0105e18:	53                   	push   %ebx
f0105e19:	83 ec 1c             	sub    $0x1c,%esp
f0105e1c:	89 c6                	mov    %eax,%esi
	if (PGNUM(pa) >= npages)
f0105e1e:	8b 0d 60 72 22 f0    	mov    0xf0227260,%ecx
f0105e24:	c1 e8 0c             	shr    $0xc,%eax
f0105e27:	39 c8                	cmp    %ecx,%eax
f0105e29:	73 22                	jae    f0105e4d <mpsearch1+0x3a>
	return (void *)(pa + KERNBASE);
f0105e2b:	8d be 00 00 00 f0    	lea    -0x10000000(%esi),%edi
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105e31:	8d 04 32             	lea    (%edx,%esi,1),%eax
	if (PGNUM(pa) >= npages)
f0105e34:	89 c2                	mov    %eax,%edx
f0105e36:	c1 ea 0c             	shr    $0xc,%edx
f0105e39:	39 ca                	cmp    %ecx,%edx
f0105e3b:	73 22                	jae    f0105e5f <mpsearch1+0x4c>
	return (void *)(pa + KERNBASE);
f0105e3d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105e42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e45:	81 ee f0 ff ff 0f    	sub    $0xffffff0,%esi

	for (; mp < end; mp++)
f0105e4b:	eb 2a                	jmp    f0105e77 <mpsearch1+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e4d:	56                   	push   %esi
f0105e4e:	68 04 68 10 f0       	push   $0xf0106804
f0105e53:	6a 57                	push   $0x57
f0105e55:	68 41 87 10 f0       	push   $0xf0108741
f0105e5a:	e8 e1 a1 ff ff       	call   f0100040 <_panic>
f0105e5f:	50                   	push   %eax
f0105e60:	68 04 68 10 f0       	push   $0xf0106804
f0105e65:	6a 57                	push   $0x57
f0105e67:	68 41 87 10 f0       	push   $0xf0108741
f0105e6c:	e8 cf a1 ff ff       	call   f0100040 <_panic>
f0105e71:	83 c7 10             	add    $0x10,%edi
f0105e74:	83 c6 10             	add    $0x10,%esi
f0105e77:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0105e7a:	73 2b                	jae    f0105ea7 <mpsearch1+0x94>
f0105e7c:	89 fb                	mov    %edi,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e7e:	83 ec 04             	sub    $0x4,%esp
f0105e81:	6a 04                	push   $0x4
f0105e83:	68 51 87 10 f0       	push   $0xf0108751
f0105e88:	57                   	push   %edi
f0105e89:	e8 d5 fd ff ff       	call   f0105c63 <memcmp>
f0105e8e:	83 c4 10             	add    $0x10,%esp
f0105e91:	85 c0                	test   %eax,%eax
f0105e93:	75 dc                	jne    f0105e71 <mpsearch1+0x5e>
		sum += ((uint8_t *)addr)[i];
f0105e95:	0f b6 13             	movzbl (%ebx),%edx
f0105e98:	01 d0                	add    %edx,%eax
	for (i = 0; i < len; i++)
f0105e9a:	83 c3 01             	add    $0x1,%ebx
f0105e9d:	39 f3                	cmp    %esi,%ebx
f0105e9f:	75 f4                	jne    f0105e95 <mpsearch1+0x82>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ea1:	84 c0                	test   %al,%al
f0105ea3:	75 cc                	jne    f0105e71 <mpsearch1+0x5e>
f0105ea5:	eb 05                	jmp    f0105eac <mpsearch1+0x99>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105ea7:	bf 00 00 00 00       	mov    $0x0,%edi
}
f0105eac:	89 f8                	mov    %edi,%eax
f0105eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105eb1:	5b                   	pop    %ebx
f0105eb2:	5e                   	pop    %esi
f0105eb3:	5f                   	pop    %edi
f0105eb4:	5d                   	pop    %ebp
f0105eb5:	c3                   	ret    

f0105eb6 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105eb6:	55                   	push   %ebp
f0105eb7:	89 e5                	mov    %esp,%ebp
f0105eb9:	57                   	push   %edi
f0105eba:	56                   	push   %esi
f0105ebb:	53                   	push   %ebx
f0105ebc:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105ebf:	c7 05 08 80 26 f0 20 	movl   $0xf0268020,0xf0268008
f0105ec6:	80 26 f0 
	if (PGNUM(pa) >= npages)
f0105ec9:	83 3d 60 72 22 f0 00 	cmpl   $0x0,0xf0227260
f0105ed0:	0f 84 86 00 00 00    	je     f0105f5c <mp_init+0xa6>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105ed6:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105edd:	85 c0                	test   %eax,%eax
f0105edf:	0f 84 8d 00 00 00    	je     f0105f72 <mp_init+0xbc>
		p <<= 4;	// Translate from segment to PA
f0105ee5:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105ee8:	ba 00 04 00 00       	mov    $0x400,%edx
f0105eed:	e8 21 ff ff ff       	call   f0105e13 <mpsearch1>
f0105ef2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ef5:	85 c0                	test   %eax,%eax
f0105ef7:	75 1a                	jne    f0105f13 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0105ef9:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105efe:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105f03:	e8 0b ff ff ff       	call   f0105e13 <mpsearch1>
f0105f08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105f0b:	85 c0                	test   %eax,%eax
f0105f0d:	0f 84 20 02 00 00    	je     f0106133 <mp_init+0x27d>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105f13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f16:	8b 58 04             	mov    0x4(%eax),%ebx
f0105f19:	85 db                	test   %ebx,%ebx
f0105f1b:	74 7a                	je     f0105f97 <mp_init+0xe1>
f0105f1d:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105f21:	75 74                	jne    f0105f97 <mp_init+0xe1>
f0105f23:	89 d8                	mov    %ebx,%eax
f0105f25:	c1 e8 0c             	shr    $0xc,%eax
f0105f28:	3b 05 60 72 22 f0    	cmp    0xf0227260,%eax
f0105f2e:	73 7c                	jae    f0105fac <mp_init+0xf6>
	return (void *)(pa + KERNBASE);
f0105f30:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105f36:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105f38:	83 ec 04             	sub    $0x4,%esp
f0105f3b:	6a 04                	push   $0x4
f0105f3d:	68 56 87 10 f0       	push   $0xf0108756
f0105f42:	53                   	push   %ebx
f0105f43:	e8 1b fd ff ff       	call   f0105c63 <memcmp>
f0105f48:	83 c4 10             	add    $0x10,%esp
f0105f4b:	85 c0                	test   %eax,%eax
f0105f4d:	75 72                	jne    f0105fc1 <mp_init+0x10b>
f0105f4f:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105f53:	01 df                	add    %ebx,%edi
	sum = 0;
f0105f55:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105f57:	e9 82 00 00 00       	jmp    f0105fde <mp_init+0x128>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f5c:	68 00 04 00 00       	push   $0x400
f0105f61:	68 04 68 10 f0       	push   $0xf0106804
f0105f66:	6a 6f                	push   $0x6f
f0105f68:	68 41 87 10 f0       	push   $0xf0108741
f0105f6d:	e8 ce a0 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105f72:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105f79:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105f7c:	2d 00 04 00 00       	sub    $0x400,%eax
f0105f81:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f86:	e8 88 fe ff ff       	call   f0105e13 <mpsearch1>
f0105f8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f8e:	85 c0                	test   %eax,%eax
f0105f90:	75 81                	jne    f0105f13 <mp_init+0x5d>
f0105f92:	e9 62 ff ff ff       	jmp    f0105ef9 <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0105f97:	83 ec 0c             	sub    $0xc,%esp
f0105f9a:	68 b4 85 10 f0       	push   $0xf01085b4
f0105f9f:	e8 ce dc ff ff       	call   f0103c72 <cprintf>
		return NULL;
f0105fa4:	83 c4 10             	add    $0x10,%esp
f0105fa7:	e9 87 01 00 00       	jmp    f0106133 <mp_init+0x27d>
f0105fac:	53                   	push   %ebx
f0105fad:	68 04 68 10 f0       	push   $0xf0106804
f0105fb2:	68 90 00 00 00       	push   $0x90
f0105fb7:	68 41 87 10 f0       	push   $0xf0108741
f0105fbc:	e8 7f a0 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105fc1:	83 ec 0c             	sub    $0xc,%esp
f0105fc4:	68 e4 85 10 f0       	push   $0xf01085e4
f0105fc9:	e8 a4 dc ff ff       	call   f0103c72 <cprintf>
		return NULL;
f0105fce:	83 c4 10             	add    $0x10,%esp
f0105fd1:	e9 5d 01 00 00       	jmp    f0106133 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f0105fd6:	0f b6 0b             	movzbl (%ebx),%ecx
f0105fd9:	01 ca                	add    %ecx,%edx
f0105fdb:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105fde:	39 fb                	cmp    %edi,%ebx
f0105fe0:	75 f4                	jne    f0105fd6 <mp_init+0x120>
	if (sum(conf, conf->length) != 0) {
f0105fe2:	84 d2                	test   %dl,%dl
f0105fe4:	75 16                	jne    f0105ffc <mp_init+0x146>
	if (conf->version != 1 && conf->version != 4) {
f0105fe6:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105fea:	80 fa 01             	cmp    $0x1,%dl
f0105fed:	74 05                	je     f0105ff4 <mp_init+0x13e>
f0105fef:	80 fa 04             	cmp    $0x4,%dl
f0105ff2:	75 1d                	jne    f0106011 <mp_init+0x15b>
f0105ff4:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105ff8:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0105ffa:	eb 36                	jmp    f0106032 <mp_init+0x17c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105ffc:	83 ec 0c             	sub    $0xc,%esp
f0105fff:	68 18 86 10 f0       	push   $0xf0108618
f0106004:	e8 69 dc ff ff       	call   f0103c72 <cprintf>
		return NULL;
f0106009:	83 c4 10             	add    $0x10,%esp
f010600c:	e9 22 01 00 00       	jmp    f0106133 <mp_init+0x27d>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106011:	83 ec 08             	sub    $0x8,%esp
f0106014:	0f b6 d2             	movzbl %dl,%edx
f0106017:	52                   	push   %edx
f0106018:	68 3c 86 10 f0       	push   $0xf010863c
f010601d:	e8 50 dc ff ff       	call   f0103c72 <cprintf>
		return NULL;
f0106022:	83 c4 10             	add    $0x10,%esp
f0106025:	e9 09 01 00 00       	jmp    f0106133 <mp_init+0x27d>
		sum += ((uint8_t *)addr)[i];
f010602a:	0f b6 13             	movzbl (%ebx),%edx
f010602d:	01 d0                	add    %edx,%eax
f010602f:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0106032:	39 d9                	cmp    %ebx,%ecx
f0106034:	75 f4                	jne    f010602a <mp_init+0x174>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106036:	02 46 2a             	add    0x2a(%esi),%al
f0106039:	75 1c                	jne    f0106057 <mp_init+0x1a1>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f010603b:	c7 05 04 80 26 f0 01 	movl   $0x1,0xf0268004
f0106042:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106045:	8b 46 24             	mov    0x24(%esi),%eax
f0106048:	a3 c4 83 26 f0       	mov    %eax,0xf02683c4

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010604d:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0106050:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106055:	eb 4d                	jmp    f01060a4 <mp_init+0x1ee>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106057:	83 ec 0c             	sub    $0xc,%esp
f010605a:	68 5c 86 10 f0       	push   $0xf010865c
f010605f:	e8 0e dc ff ff       	call   f0103c72 <cprintf>
		return NULL;
f0106064:	83 c4 10             	add    $0x10,%esp
f0106067:	e9 c7 00 00 00       	jmp    f0106133 <mp_init+0x27d>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010606c:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106070:	74 11                	je     f0106083 <mp_init+0x1cd>
				bootcpu = &cpus[ncpu];
f0106072:	6b 05 00 80 26 f0 74 	imul   $0x74,0xf0268000,%eax
f0106079:	05 20 80 26 f0       	add    $0xf0268020,%eax
f010607e:	a3 08 80 26 f0       	mov    %eax,0xf0268008
			if (ncpu < NCPU) {
f0106083:	a1 00 80 26 f0       	mov    0xf0268000,%eax
f0106088:	83 f8 07             	cmp    $0x7,%eax
f010608b:	7f 33                	jg     f01060c0 <mp_init+0x20a>
				cpus[ncpu].cpu_id = ncpu;
f010608d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106090:	88 82 20 80 26 f0    	mov    %al,-0xfd97fe0(%edx)
				ncpu++;
f0106096:	83 c0 01             	add    $0x1,%eax
f0106099:	a3 00 80 26 f0       	mov    %eax,0xf0268000
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010609e:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01060a1:	83 c3 01             	add    $0x1,%ebx
f01060a4:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f01060a8:	39 d8                	cmp    %ebx,%eax
f01060aa:	76 4f                	jbe    f01060fb <mp_init+0x245>
		switch (*p) {
f01060ac:	0f b6 07             	movzbl (%edi),%eax
f01060af:	84 c0                	test   %al,%al
f01060b1:	74 b9                	je     f010606c <mp_init+0x1b6>
f01060b3:	8d 50 ff             	lea    -0x1(%eax),%edx
f01060b6:	80 fa 03             	cmp    $0x3,%dl
f01060b9:	77 1c                	ja     f01060d7 <mp_init+0x221>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01060bb:	83 c7 08             	add    $0x8,%edi
			continue;
f01060be:	eb e1                	jmp    f01060a1 <mp_init+0x1eb>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01060c0:	83 ec 08             	sub    $0x8,%esp
f01060c3:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01060c7:	50                   	push   %eax
f01060c8:	68 8c 86 10 f0       	push   $0xf010868c
f01060cd:	e8 a0 db ff ff       	call   f0103c72 <cprintf>
f01060d2:	83 c4 10             	add    $0x10,%esp
f01060d5:	eb c7                	jmp    f010609e <mp_init+0x1e8>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01060d7:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f01060da:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f01060dd:	50                   	push   %eax
f01060de:	68 b4 86 10 f0       	push   $0xf01086b4
f01060e3:	e8 8a db ff ff       	call   f0103c72 <cprintf>
			ismp = 0;
f01060e8:	c7 05 04 80 26 f0 00 	movl   $0x0,0xf0268004
f01060ef:	00 00 00 
			i = conf->entry;
f01060f2:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01060f6:	83 c4 10             	add    $0x10,%esp
f01060f9:	eb a6                	jmp    f01060a1 <mp_init+0x1eb>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01060fb:	a1 08 80 26 f0       	mov    0xf0268008,%eax
f0106100:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106107:	83 3d 04 80 26 f0 00 	cmpl   $0x0,0xf0268004
f010610e:	74 2b                	je     f010613b <mp_init+0x285>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106110:	83 ec 04             	sub    $0x4,%esp
f0106113:	ff 35 00 80 26 f0    	push   0xf0268000
f0106119:	0f b6 00             	movzbl (%eax),%eax
f010611c:	50                   	push   %eax
f010611d:	68 5b 87 10 f0       	push   $0xf010875b
f0106122:	e8 4b db ff ff       	call   f0103c72 <cprintf>

	if (mp->imcrp) {
f0106127:	83 c4 10             	add    $0x10,%esp
f010612a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010612d:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106131:	75 2e                	jne    f0106161 <mp_init+0x2ab>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106133:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106136:	5b                   	pop    %ebx
f0106137:	5e                   	pop    %esi
f0106138:	5f                   	pop    %edi
f0106139:	5d                   	pop    %ebp
f010613a:	c3                   	ret    
		ncpu = 1;
f010613b:	c7 05 00 80 26 f0 01 	movl   $0x1,0xf0268000
f0106142:	00 00 00 
		lapicaddr = 0;
f0106145:	c7 05 c4 83 26 f0 00 	movl   $0x0,0xf02683c4
f010614c:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010614f:	83 ec 0c             	sub    $0xc,%esp
f0106152:	68 d4 86 10 f0       	push   $0xf01086d4
f0106157:	e8 16 db ff ff       	call   f0103c72 <cprintf>
		return;
f010615c:	83 c4 10             	add    $0x10,%esp
f010615f:	eb d2                	jmp    f0106133 <mp_init+0x27d>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106161:	83 ec 0c             	sub    $0xc,%esp
f0106164:	68 00 87 10 f0       	push   $0xf0108700
f0106169:	e8 04 db ff ff       	call   f0103c72 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010616e:	b8 70 00 00 00       	mov    $0x70,%eax
f0106173:	ba 22 00 00 00       	mov    $0x22,%edx
f0106178:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106179:	ba 23 00 00 00       	mov    $0x23,%edx
f010617e:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010617f:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106182:	ee                   	out    %al,(%dx)
}
f0106183:	83 c4 10             	add    $0x10,%esp
f0106186:	eb ab                	jmp    f0106133 <mp_init+0x27d>

f0106188 <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f0106188:	8b 0d c0 83 26 f0    	mov    0xf02683c0,%ecx
f010618e:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106191:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106193:	a1 c0 83 26 f0       	mov    0xf02683c0,%eax
f0106198:	8b 40 20             	mov    0x20(%eax),%eax
}
f010619b:	c3                   	ret    

f010619c <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f010619c:	8b 15 c0 83 26 f0    	mov    0xf02683c0,%edx
		return lapic[ID] >> 24;
	return 0;
f01061a2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f01061a7:	85 d2                	test   %edx,%edx
f01061a9:	74 06                	je     f01061b1 <cpunum+0x15>
		return lapic[ID] >> 24;
f01061ab:	8b 42 20             	mov    0x20(%edx),%eax
f01061ae:	c1 e8 18             	shr    $0x18,%eax
}
f01061b1:	c3                   	ret    

f01061b2 <lapic_init>:
	if (!lapicaddr)
f01061b2:	a1 c4 83 26 f0       	mov    0xf02683c4,%eax
f01061b7:	85 c0                	test   %eax,%eax
f01061b9:	75 01                	jne    f01061bc <lapic_init+0xa>
f01061bb:	c3                   	ret    
{
f01061bc:	55                   	push   %ebp
f01061bd:	89 e5                	mov    %esp,%ebp
f01061bf:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01061c2:	68 00 10 00 00       	push   $0x1000
f01061c7:	50                   	push   %eax
f01061c8:	e8 d3 b3 ff ff       	call   f01015a0 <mmio_map_region>
f01061cd:	a3 c0 83 26 f0       	mov    %eax,0xf02683c0
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01061d2:	ba 27 01 00 00       	mov    $0x127,%edx
f01061d7:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01061dc:	e8 a7 ff ff ff       	call   f0106188 <lapicw>
	lapicw(TDCR, X1);
f01061e1:	ba 0b 00 00 00       	mov    $0xb,%edx
f01061e6:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01061eb:	e8 98 ff ff ff       	call   f0106188 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01061f0:	ba 20 00 02 00       	mov    $0x20020,%edx
f01061f5:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01061fa:	e8 89 ff ff ff       	call   f0106188 <lapicw>
	lapicw(TICR, 10000000); 
f01061ff:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106204:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106209:	e8 7a ff ff ff       	call   f0106188 <lapicw>
	if (thiscpu != bootcpu)
f010620e:	e8 89 ff ff ff       	call   f010619c <cpunum>
f0106213:	6b c0 74             	imul   $0x74,%eax,%eax
f0106216:	05 20 80 26 f0       	add    $0xf0268020,%eax
f010621b:	83 c4 10             	add    $0x10,%esp
f010621e:	39 05 08 80 26 f0    	cmp    %eax,0xf0268008
f0106224:	74 0f                	je     f0106235 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0106226:	ba 00 00 01 00       	mov    $0x10000,%edx
f010622b:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106230:	e8 53 ff ff ff       	call   f0106188 <lapicw>
	lapicw(LINT1, MASKED);
f0106235:	ba 00 00 01 00       	mov    $0x10000,%edx
f010623a:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010623f:	e8 44 ff ff ff       	call   f0106188 <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106244:	a1 c0 83 26 f0       	mov    0xf02683c0,%eax
f0106249:	8b 40 30             	mov    0x30(%eax),%eax
f010624c:	c1 e8 10             	shr    $0x10,%eax
f010624f:	a8 fc                	test   $0xfc,%al
f0106251:	75 7c                	jne    f01062cf <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106253:	ba 33 00 00 00       	mov    $0x33,%edx
f0106258:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010625d:	e8 26 ff ff ff       	call   f0106188 <lapicw>
	lapicw(ESR, 0);
f0106262:	ba 00 00 00 00       	mov    $0x0,%edx
f0106267:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010626c:	e8 17 ff ff ff       	call   f0106188 <lapicw>
	lapicw(ESR, 0);
f0106271:	ba 00 00 00 00       	mov    $0x0,%edx
f0106276:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010627b:	e8 08 ff ff ff       	call   f0106188 <lapicw>
	lapicw(EOI, 0);
f0106280:	ba 00 00 00 00       	mov    $0x0,%edx
f0106285:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010628a:	e8 f9 fe ff ff       	call   f0106188 <lapicw>
	lapicw(ICRHI, 0);
f010628f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106294:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106299:	e8 ea fe ff ff       	call   f0106188 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010629e:	ba 00 85 08 00       	mov    $0x88500,%edx
f01062a3:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062a8:	e8 db fe ff ff       	call   f0106188 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01062ad:	8b 15 c0 83 26 f0    	mov    0xf02683c0,%edx
f01062b3:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01062b9:	f6 c4 10             	test   $0x10,%ah
f01062bc:	75 f5                	jne    f01062b3 <lapic_init+0x101>
	lapicw(TPR, 0);
f01062be:	ba 00 00 00 00       	mov    $0x0,%edx
f01062c3:	b8 20 00 00 00       	mov    $0x20,%eax
f01062c8:	e8 bb fe ff ff       	call   f0106188 <lapicw>
}
f01062cd:	c9                   	leave  
f01062ce:	c3                   	ret    
		lapicw(PCINT, MASKED);
f01062cf:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062d4:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01062d9:	e8 aa fe ff ff       	call   f0106188 <lapicw>
f01062de:	e9 70 ff ff ff       	jmp    f0106253 <lapic_init+0xa1>

f01062e3 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01062e3:	83 3d c0 83 26 f0 00 	cmpl   $0x0,0xf02683c0
f01062ea:	74 17                	je     f0106303 <lapic_eoi+0x20>
{
f01062ec:	55                   	push   %ebp
f01062ed:	89 e5                	mov    %esp,%ebp
f01062ef:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01062f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01062f7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01062fc:	e8 87 fe ff ff       	call   f0106188 <lapicw>
}
f0106301:	c9                   	leave  
f0106302:	c3                   	ret    
f0106303:	c3                   	ret    

f0106304 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106304:	55                   	push   %ebp
f0106305:	89 e5                	mov    %esp,%ebp
f0106307:	56                   	push   %esi
f0106308:	53                   	push   %ebx
f0106309:	8b 75 08             	mov    0x8(%ebp),%esi
f010630c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010630f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106314:	ba 70 00 00 00       	mov    $0x70,%edx
f0106319:	ee                   	out    %al,(%dx)
f010631a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010631f:	ba 71 00 00 00       	mov    $0x71,%edx
f0106324:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106325:	83 3d 60 72 22 f0 00 	cmpl   $0x0,0xf0227260
f010632c:	74 7e                	je     f01063ac <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010632e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106335:	00 00 
	wrv[1] = addr >> 4;
f0106337:	89 d8                	mov    %ebx,%eax
f0106339:	c1 e8 04             	shr    $0x4,%eax
f010633c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106342:	c1 e6 18             	shl    $0x18,%esi
f0106345:	89 f2                	mov    %esi,%edx
f0106347:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010634c:	e8 37 fe ff ff       	call   f0106188 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106351:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106356:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010635b:	e8 28 fe ff ff       	call   f0106188 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106360:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106365:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010636a:	e8 19 fe ff ff       	call   f0106188 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010636f:	c1 eb 0c             	shr    $0xc,%ebx
f0106372:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106375:	89 f2                	mov    %esi,%edx
f0106377:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010637c:	e8 07 fe ff ff       	call   f0106188 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106381:	89 da                	mov    %ebx,%edx
f0106383:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106388:	e8 fb fd ff ff       	call   f0106188 <lapicw>
		lapicw(ICRHI, apicid << 24);
f010638d:	89 f2                	mov    %esi,%edx
f010638f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106394:	e8 ef fd ff ff       	call   f0106188 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106399:	89 da                	mov    %ebx,%edx
f010639b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063a0:	e8 e3 fd ff ff       	call   f0106188 <lapicw>
		microdelay(200);
	}
}
f01063a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01063a8:	5b                   	pop    %ebx
f01063a9:	5e                   	pop    %esi
f01063aa:	5d                   	pop    %ebp
f01063ab:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063ac:	68 67 04 00 00       	push   $0x467
f01063b1:	68 04 68 10 f0       	push   $0xf0106804
f01063b6:	68 98 00 00 00       	push   $0x98
f01063bb:	68 78 87 10 f0       	push   $0xf0108778
f01063c0:	e8 7b 9c ff ff       	call   f0100040 <_panic>

f01063c5 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01063c5:	55                   	push   %ebp
f01063c6:	89 e5                	mov    %esp,%ebp
f01063c8:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01063cb:	8b 55 08             	mov    0x8(%ebp),%edx
f01063ce:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01063d4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063d9:	e8 aa fd ff ff       	call   f0106188 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01063de:	8b 15 c0 83 26 f0    	mov    0xf02683c0,%edx
f01063e4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01063ea:	f6 c4 10             	test   $0x10,%ah
f01063ed:	75 f5                	jne    f01063e4 <lapic_ipi+0x1f>
		;
}
f01063ef:	c9                   	leave  
f01063f0:	c3                   	ret    

f01063f1 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01063f1:	55                   	push   %ebp
f01063f2:	89 e5                	mov    %esp,%ebp
f01063f4:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01063f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01063fd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106400:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106403:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010640a:	5d                   	pop    %ebp
f010640b:	c3                   	ret    

f010640c <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010640c:	55                   	push   %ebp
f010640d:	89 e5                	mov    %esp,%ebp
f010640f:	56                   	push   %esi
f0106410:	53                   	push   %ebx
f0106411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106414:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106417:	75 07                	jne    f0106420 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0106419:	ba 01 00 00 00       	mov    $0x1,%edx
f010641e:	eb 34                	jmp    f0106454 <spin_lock+0x48>
f0106420:	8b 73 08             	mov    0x8(%ebx),%esi
f0106423:	e8 74 fd ff ff       	call   f010619c <cpunum>
f0106428:	6b c0 74             	imul   $0x74,%eax,%eax
f010642b:	05 20 80 26 f0       	add    $0xf0268020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106430:	39 c6                	cmp    %eax,%esi
f0106432:	75 e5                	jne    f0106419 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106434:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106437:	e8 60 fd ff ff       	call   f010619c <cpunum>
f010643c:	83 ec 0c             	sub    $0xc,%esp
f010643f:	53                   	push   %ebx
f0106440:	50                   	push   %eax
f0106441:	68 88 87 10 f0       	push   $0xf0108788
f0106446:	6a 41                	push   $0x41
f0106448:	68 ea 87 10 f0       	push   $0xf01087ea
f010644d:	e8 ee 9b ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106452:	f3 90                	pause  
f0106454:	89 d0                	mov    %edx,%eax
f0106456:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0106459:	85 c0                	test   %eax,%eax
f010645b:	75 f5                	jne    f0106452 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010645d:	e8 3a fd ff ff       	call   f010619c <cpunum>
f0106462:	6b c0 74             	imul   $0x74,%eax,%eax
f0106465:	05 20 80 26 f0       	add    $0xf0268020,%eax
f010646a:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010646d:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010646f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106474:	83 f8 09             	cmp    $0x9,%eax
f0106477:	7f 21                	jg     f010649a <spin_lock+0x8e>
f0106479:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010647f:	76 19                	jbe    f010649a <spin_lock+0x8e>
		pcs[i] = ebp[1];          // saved %eip
f0106481:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106484:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106488:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f010648a:	83 c0 01             	add    $0x1,%eax
f010648d:	eb e5                	jmp    f0106474 <spin_lock+0x68>
		pcs[i] = 0;
f010648f:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0106496:	00 
	for (; i < 10; i++)
f0106497:	83 c0 01             	add    $0x1,%eax
f010649a:	83 f8 09             	cmp    $0x9,%eax
f010649d:	7e f0                	jle    f010648f <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f010649f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01064a2:	5b                   	pop    %ebx
f01064a3:	5e                   	pop    %esi
f01064a4:	5d                   	pop    %ebp
f01064a5:	c3                   	ret    

f01064a6 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01064a6:	55                   	push   %ebp
f01064a7:	89 e5                	mov    %esp,%ebp
f01064a9:	57                   	push   %edi
f01064aa:	56                   	push   %esi
f01064ab:	53                   	push   %ebx
f01064ac:	83 ec 4c             	sub    $0x4c,%esp
f01064af:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01064b2:	83 3e 00             	cmpl   $0x0,(%esi)
f01064b5:	75 35                	jne    f01064ec <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01064b7:	83 ec 04             	sub    $0x4,%esp
f01064ba:	6a 28                	push   $0x28
f01064bc:	8d 46 0c             	lea    0xc(%esi),%eax
f01064bf:	50                   	push   %eax
f01064c0:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01064c3:	53                   	push   %ebx
f01064c4:	e8 22 f7 ff ff       	call   f0105beb <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01064c9:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01064cc:	0f b6 38             	movzbl (%eax),%edi
f01064cf:	8b 76 04             	mov    0x4(%esi),%esi
f01064d2:	e8 c5 fc ff ff       	call   f010619c <cpunum>
f01064d7:	57                   	push   %edi
f01064d8:	56                   	push   %esi
f01064d9:	50                   	push   %eax
f01064da:	68 b4 87 10 f0       	push   $0xf01087b4
f01064df:	e8 8e d7 ff ff       	call   f0103c72 <cprintf>
f01064e4:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01064e7:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01064ea:	eb 4e                	jmp    f010653a <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f01064ec:	8b 5e 08             	mov    0x8(%esi),%ebx
f01064ef:	e8 a8 fc ff ff       	call   f010619c <cpunum>
f01064f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01064f7:	05 20 80 26 f0       	add    $0xf0268020,%eax
	if (!holding(lk)) {
f01064fc:	39 c3                	cmp    %eax,%ebx
f01064fe:	75 b7                	jne    f01064b7 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106500:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0106507:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f010650e:	b8 00 00 00 00       	mov    $0x0,%eax
f0106513:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106516:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106519:	5b                   	pop    %ebx
f010651a:	5e                   	pop    %esi
f010651b:	5f                   	pop    %edi
f010651c:	5d                   	pop    %ebp
f010651d:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f010651e:	83 ec 08             	sub    $0x8,%esp
f0106521:	ff 36                	push   (%esi)
f0106523:	68 11 88 10 f0       	push   $0xf0108811
f0106528:	e8 45 d7 ff ff       	call   f0103c72 <cprintf>
f010652d:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106530:	83 c3 04             	add    $0x4,%ebx
f0106533:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106536:	39 c3                	cmp    %eax,%ebx
f0106538:	74 40                	je     f010657a <spin_unlock+0xd4>
f010653a:	89 de                	mov    %ebx,%esi
f010653c:	8b 03                	mov    (%ebx),%eax
f010653e:	85 c0                	test   %eax,%eax
f0106540:	74 38                	je     f010657a <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106542:	83 ec 08             	sub    $0x8,%esp
f0106545:	57                   	push   %edi
f0106546:	50                   	push   %eax
f0106547:	e8 9b eb ff ff       	call   f01050e7 <debuginfo_eip>
f010654c:	83 c4 10             	add    $0x10,%esp
f010654f:	85 c0                	test   %eax,%eax
f0106551:	78 cb                	js     f010651e <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f0106553:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106555:	83 ec 04             	sub    $0x4,%esp
f0106558:	89 c2                	mov    %eax,%edx
f010655a:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010655d:	52                   	push   %edx
f010655e:	ff 75 b0             	push   -0x50(%ebp)
f0106561:	ff 75 b4             	push   -0x4c(%ebp)
f0106564:	ff 75 ac             	push   -0x54(%ebp)
f0106567:	ff 75 a8             	push   -0x58(%ebp)
f010656a:	50                   	push   %eax
f010656b:	68 fa 87 10 f0       	push   $0xf01087fa
f0106570:	e8 fd d6 ff ff       	call   f0103c72 <cprintf>
f0106575:	83 c4 20             	add    $0x20,%esp
f0106578:	eb b6                	jmp    f0106530 <spin_unlock+0x8a>
		panic("spin_unlock");
f010657a:	83 ec 04             	sub    $0x4,%esp
f010657d:	68 19 88 10 f0       	push   $0xf0108819
f0106582:	6a 67                	push   $0x67
f0106584:	68 ea 87 10 f0       	push   $0xf01087ea
f0106589:	e8 b2 9a ff ff       	call   f0100040 <_panic>
f010658e:	66 90                	xchg   %ax,%ax

f0106590 <__udivdi3>:
f0106590:	f3 0f 1e fb          	endbr32 
f0106594:	55                   	push   %ebp
f0106595:	57                   	push   %edi
f0106596:	56                   	push   %esi
f0106597:	53                   	push   %ebx
f0106598:	83 ec 1c             	sub    $0x1c,%esp
f010659b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010659f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01065a3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01065a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01065ab:	85 c0                	test   %eax,%eax
f01065ad:	75 19                	jne    f01065c8 <__udivdi3+0x38>
f01065af:	39 f3                	cmp    %esi,%ebx
f01065b1:	76 4d                	jbe    f0106600 <__udivdi3+0x70>
f01065b3:	31 ff                	xor    %edi,%edi
f01065b5:	89 e8                	mov    %ebp,%eax
f01065b7:	89 f2                	mov    %esi,%edx
f01065b9:	f7 f3                	div    %ebx
f01065bb:	89 fa                	mov    %edi,%edx
f01065bd:	83 c4 1c             	add    $0x1c,%esp
f01065c0:	5b                   	pop    %ebx
f01065c1:	5e                   	pop    %esi
f01065c2:	5f                   	pop    %edi
f01065c3:	5d                   	pop    %ebp
f01065c4:	c3                   	ret    
f01065c5:	8d 76 00             	lea    0x0(%esi),%esi
f01065c8:	39 f0                	cmp    %esi,%eax
f01065ca:	76 14                	jbe    f01065e0 <__udivdi3+0x50>
f01065cc:	31 ff                	xor    %edi,%edi
f01065ce:	31 c0                	xor    %eax,%eax
f01065d0:	89 fa                	mov    %edi,%edx
f01065d2:	83 c4 1c             	add    $0x1c,%esp
f01065d5:	5b                   	pop    %ebx
f01065d6:	5e                   	pop    %esi
f01065d7:	5f                   	pop    %edi
f01065d8:	5d                   	pop    %ebp
f01065d9:	c3                   	ret    
f01065da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01065e0:	0f bd f8             	bsr    %eax,%edi
f01065e3:	83 f7 1f             	xor    $0x1f,%edi
f01065e6:	75 48                	jne    f0106630 <__udivdi3+0xa0>
f01065e8:	39 f0                	cmp    %esi,%eax
f01065ea:	72 06                	jb     f01065f2 <__udivdi3+0x62>
f01065ec:	31 c0                	xor    %eax,%eax
f01065ee:	39 eb                	cmp    %ebp,%ebx
f01065f0:	77 de                	ja     f01065d0 <__udivdi3+0x40>
f01065f2:	b8 01 00 00 00       	mov    $0x1,%eax
f01065f7:	eb d7                	jmp    f01065d0 <__udivdi3+0x40>
f01065f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106600:	89 d9                	mov    %ebx,%ecx
f0106602:	85 db                	test   %ebx,%ebx
f0106604:	75 0b                	jne    f0106611 <__udivdi3+0x81>
f0106606:	b8 01 00 00 00       	mov    $0x1,%eax
f010660b:	31 d2                	xor    %edx,%edx
f010660d:	f7 f3                	div    %ebx
f010660f:	89 c1                	mov    %eax,%ecx
f0106611:	31 d2                	xor    %edx,%edx
f0106613:	89 f0                	mov    %esi,%eax
f0106615:	f7 f1                	div    %ecx
f0106617:	89 c6                	mov    %eax,%esi
f0106619:	89 e8                	mov    %ebp,%eax
f010661b:	89 f7                	mov    %esi,%edi
f010661d:	f7 f1                	div    %ecx
f010661f:	89 fa                	mov    %edi,%edx
f0106621:	83 c4 1c             	add    $0x1c,%esp
f0106624:	5b                   	pop    %ebx
f0106625:	5e                   	pop    %esi
f0106626:	5f                   	pop    %edi
f0106627:	5d                   	pop    %ebp
f0106628:	c3                   	ret    
f0106629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106630:	89 f9                	mov    %edi,%ecx
f0106632:	ba 20 00 00 00       	mov    $0x20,%edx
f0106637:	29 fa                	sub    %edi,%edx
f0106639:	d3 e0                	shl    %cl,%eax
f010663b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010663f:	89 d1                	mov    %edx,%ecx
f0106641:	89 d8                	mov    %ebx,%eax
f0106643:	d3 e8                	shr    %cl,%eax
f0106645:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106649:	09 c1                	or     %eax,%ecx
f010664b:	89 f0                	mov    %esi,%eax
f010664d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106651:	89 f9                	mov    %edi,%ecx
f0106653:	d3 e3                	shl    %cl,%ebx
f0106655:	89 d1                	mov    %edx,%ecx
f0106657:	d3 e8                	shr    %cl,%eax
f0106659:	89 f9                	mov    %edi,%ecx
f010665b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010665f:	89 eb                	mov    %ebp,%ebx
f0106661:	d3 e6                	shl    %cl,%esi
f0106663:	89 d1                	mov    %edx,%ecx
f0106665:	d3 eb                	shr    %cl,%ebx
f0106667:	09 f3                	or     %esi,%ebx
f0106669:	89 c6                	mov    %eax,%esi
f010666b:	89 f2                	mov    %esi,%edx
f010666d:	89 d8                	mov    %ebx,%eax
f010666f:	f7 74 24 08          	divl   0x8(%esp)
f0106673:	89 d6                	mov    %edx,%esi
f0106675:	89 c3                	mov    %eax,%ebx
f0106677:	f7 64 24 0c          	mull   0xc(%esp)
f010667b:	39 d6                	cmp    %edx,%esi
f010667d:	72 19                	jb     f0106698 <__udivdi3+0x108>
f010667f:	89 f9                	mov    %edi,%ecx
f0106681:	d3 e5                	shl    %cl,%ebp
f0106683:	39 c5                	cmp    %eax,%ebp
f0106685:	73 04                	jae    f010668b <__udivdi3+0xfb>
f0106687:	39 d6                	cmp    %edx,%esi
f0106689:	74 0d                	je     f0106698 <__udivdi3+0x108>
f010668b:	89 d8                	mov    %ebx,%eax
f010668d:	31 ff                	xor    %edi,%edi
f010668f:	e9 3c ff ff ff       	jmp    f01065d0 <__udivdi3+0x40>
f0106694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106698:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010669b:	31 ff                	xor    %edi,%edi
f010669d:	e9 2e ff ff ff       	jmp    f01065d0 <__udivdi3+0x40>
f01066a2:	66 90                	xchg   %ax,%ax
f01066a4:	66 90                	xchg   %ax,%ax
f01066a6:	66 90                	xchg   %ax,%ax
f01066a8:	66 90                	xchg   %ax,%ax
f01066aa:	66 90                	xchg   %ax,%ax
f01066ac:	66 90                	xchg   %ax,%ax
f01066ae:	66 90                	xchg   %ax,%ax

f01066b0 <__umoddi3>:
f01066b0:	f3 0f 1e fb          	endbr32 
f01066b4:	55                   	push   %ebp
f01066b5:	57                   	push   %edi
f01066b6:	56                   	push   %esi
f01066b7:	53                   	push   %ebx
f01066b8:	83 ec 1c             	sub    $0x1c,%esp
f01066bb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01066bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01066c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
f01066c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
f01066cb:	89 f0                	mov    %esi,%eax
f01066cd:	89 da                	mov    %ebx,%edx
f01066cf:	85 ff                	test   %edi,%edi
f01066d1:	75 15                	jne    f01066e8 <__umoddi3+0x38>
f01066d3:	39 dd                	cmp    %ebx,%ebp
f01066d5:	76 39                	jbe    f0106710 <__umoddi3+0x60>
f01066d7:	f7 f5                	div    %ebp
f01066d9:	89 d0                	mov    %edx,%eax
f01066db:	31 d2                	xor    %edx,%edx
f01066dd:	83 c4 1c             	add    $0x1c,%esp
f01066e0:	5b                   	pop    %ebx
f01066e1:	5e                   	pop    %esi
f01066e2:	5f                   	pop    %edi
f01066e3:	5d                   	pop    %ebp
f01066e4:	c3                   	ret    
f01066e5:	8d 76 00             	lea    0x0(%esi),%esi
f01066e8:	39 df                	cmp    %ebx,%edi
f01066ea:	77 f1                	ja     f01066dd <__umoddi3+0x2d>
f01066ec:	0f bd cf             	bsr    %edi,%ecx
f01066ef:	83 f1 1f             	xor    $0x1f,%ecx
f01066f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01066f6:	75 40                	jne    f0106738 <__umoddi3+0x88>
f01066f8:	39 df                	cmp    %ebx,%edi
f01066fa:	72 04                	jb     f0106700 <__umoddi3+0x50>
f01066fc:	39 f5                	cmp    %esi,%ebp
f01066fe:	77 dd                	ja     f01066dd <__umoddi3+0x2d>
f0106700:	89 da                	mov    %ebx,%edx
f0106702:	89 f0                	mov    %esi,%eax
f0106704:	29 e8                	sub    %ebp,%eax
f0106706:	19 fa                	sbb    %edi,%edx
f0106708:	eb d3                	jmp    f01066dd <__umoddi3+0x2d>
f010670a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106710:	89 e9                	mov    %ebp,%ecx
f0106712:	85 ed                	test   %ebp,%ebp
f0106714:	75 0b                	jne    f0106721 <__umoddi3+0x71>
f0106716:	b8 01 00 00 00       	mov    $0x1,%eax
f010671b:	31 d2                	xor    %edx,%edx
f010671d:	f7 f5                	div    %ebp
f010671f:	89 c1                	mov    %eax,%ecx
f0106721:	89 d8                	mov    %ebx,%eax
f0106723:	31 d2                	xor    %edx,%edx
f0106725:	f7 f1                	div    %ecx
f0106727:	89 f0                	mov    %esi,%eax
f0106729:	f7 f1                	div    %ecx
f010672b:	89 d0                	mov    %edx,%eax
f010672d:	31 d2                	xor    %edx,%edx
f010672f:	eb ac                	jmp    f01066dd <__umoddi3+0x2d>
f0106731:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106738:	8b 44 24 04          	mov    0x4(%esp),%eax
f010673c:	ba 20 00 00 00       	mov    $0x20,%edx
f0106741:	29 c2                	sub    %eax,%edx
f0106743:	89 c1                	mov    %eax,%ecx
f0106745:	89 e8                	mov    %ebp,%eax
f0106747:	d3 e7                	shl    %cl,%edi
f0106749:	89 d1                	mov    %edx,%ecx
f010674b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010674f:	d3 e8                	shr    %cl,%eax
f0106751:	89 c1                	mov    %eax,%ecx
f0106753:	8b 44 24 04          	mov    0x4(%esp),%eax
f0106757:	09 f9                	or     %edi,%ecx
f0106759:	89 df                	mov    %ebx,%edi
f010675b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010675f:	89 c1                	mov    %eax,%ecx
f0106761:	d3 e5                	shl    %cl,%ebp
f0106763:	89 d1                	mov    %edx,%ecx
f0106765:	d3 ef                	shr    %cl,%edi
f0106767:	89 c1                	mov    %eax,%ecx
f0106769:	89 f0                	mov    %esi,%eax
f010676b:	d3 e3                	shl    %cl,%ebx
f010676d:	89 d1                	mov    %edx,%ecx
f010676f:	89 fa                	mov    %edi,%edx
f0106771:	d3 e8                	shr    %cl,%eax
f0106773:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0106778:	09 d8                	or     %ebx,%eax
f010677a:	f7 74 24 08          	divl   0x8(%esp)
f010677e:	89 d3                	mov    %edx,%ebx
f0106780:	d3 e6                	shl    %cl,%esi
f0106782:	f7 e5                	mul    %ebp
f0106784:	89 c7                	mov    %eax,%edi
f0106786:	89 d1                	mov    %edx,%ecx
f0106788:	39 d3                	cmp    %edx,%ebx
f010678a:	72 06                	jb     f0106792 <__umoddi3+0xe2>
f010678c:	75 0e                	jne    f010679c <__umoddi3+0xec>
f010678e:	39 c6                	cmp    %eax,%esi
f0106790:	73 0a                	jae    f010679c <__umoddi3+0xec>
f0106792:	29 e8                	sub    %ebp,%eax
f0106794:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106798:	89 d1                	mov    %edx,%ecx
f010679a:	89 c7                	mov    %eax,%edi
f010679c:	89 f5                	mov    %esi,%ebp
f010679e:	8b 74 24 04          	mov    0x4(%esp),%esi
f01067a2:	29 fd                	sub    %edi,%ebp
f01067a4:	19 cb                	sbb    %ecx,%ebx
f01067a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01067ab:	89 d8                	mov    %ebx,%eax
f01067ad:	d3 e0                	shl    %cl,%eax
f01067af:	89 f1                	mov    %esi,%ecx
f01067b1:	d3 ed                	shr    %cl,%ebp
f01067b3:	d3 eb                	shr    %cl,%ebx
f01067b5:	09 e8                	or     %ebp,%eax
f01067b7:	89 da                	mov    %ebx,%edx
f01067b9:	83 c4 1c             	add    $0x1c,%esp
f01067bc:	5b                   	pop    %ebx
f01067bd:	5e                   	pop    %esi
f01067be:	5f                   	pop    %edi
f01067bf:	5d                   	pop    %ebp
f01067c0:	c3                   	ret    

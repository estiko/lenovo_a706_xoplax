/*
 *  linux/arch/arm/vfp/entry.S
 *
 *  Copyright (C) 2004 ARM Limited.
 *  Written by Deep Blue Solutions Limited.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Basic entry code, called from the kernel's undefined instruction trap.
 *  r0  = faulted instruction
 *  r2  = faulted PC+4
 *  r9  = successful return
 *  r10 = thread_info structure
 *  lr  = failure return
 */
#include <linux/init.h>
#include <linux/linkage.h>
#include <asm/thread_info.h>
#include <asm/vfpmacros.h>
#include <asm/assembler.h>
#include <asm/asm-offsets.h>

ENTRY(do_vfp)
	inc_preempt_count r10, r4
	enable_irq
	str	r2, [sp, #S_PC]		@ update regs->ARM_pc for Thumb 2 case
	ldr	r4, .LCvfp
	ldr	r11, [r10, #TI_CPU]	@ CPU number
	add	r10, r10, #TI_VFPSTATE	@ r10 = workspace
	ldr	pc, [r4]		@ call VFP entry point
ENDPROC(do_vfp)

ENTRY(vfp_null_entry)
	dec_preempt_count_ti r10, r4
	mov	pc, lr
ENDPROC(vfp_null_entry)

	.align	2
.LCvfp:
	.word	vfp_vector

@ This code is called if the VFP does not exist. It needs to flag the
@ failure to the VFP initialisation code.

	__INIT
ENTRY(vfp_testing_entry)
	dec_preempt_count_ti r10, r4
	ldr	r0, VFP_arch_address
	str	r5, [r0]		@ known non-zero value
	mov	pc, r9			@ we have handled the fault
ENDPROC(vfp_testing_entry)

	.align	2
VFP_arch_address:
	.word	VFP_arch

	__FINIT

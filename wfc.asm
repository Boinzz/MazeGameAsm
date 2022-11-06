__WFC_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include wfc.inc

setModule macro _id, _upId, _leftId, _downId, _rightId, _probability
	mov eax, 1
	shl eax, _id
	mov (Module ptr [esi]).id, eax
	mov (Module ptr [esi]).upId, _upId
	mov (Module ptr [esi]).leftId, _leftId
	mov (Module ptr [esi]).downId, _downId
	mov (Module ptr [esi]).rightId, _rightId
	fld _probability
	fstp (Module ptr [esi]).probability
	add esi, sizeof Module
endm

.data
modules Module 16 dup(<>)
PROB1 real8 0.1796875
PROB2 real8 0.0546875
MAX_RAND real8 32767.0
MAX_ENTROPY real8 10000000000000000000000000000.0
public modules
TEST_ZERO real8 1.0

.code
initModules proc uses eax esi
	mov esi, offset modules
	setModule 00h, 0, 0, 0, 0, PROB1
	setModule 01h, 1, 0, 1, 0, PROB2
	setModule 02h, 0, 1, 0, 1, PROB2
	setModule 03h, 1, 1, 0, 0, PROB2
	setModule 04h, 0, 1, 1, 0, PROB2
	setModule 05h, 0, 0, 1, 1, PROB2
	setModule 06h, 1, 0, 0, 1, PROB2
	setModule 07h, 1, 1, 1, 0, PROB2
	setModule 08h, 1, 1, 0, 1, PROB2
	setModule 09h, 1, 0, 1, 1, PROB2
	setModule 0ah, 0, 1, 1, 1, PROB2
	setModule 0bh, 1, 1, 1, 1, PROB2
	setModule 0ch, 0, 0, 0, 1, PROB2
	setModule 0dh, 0, 0, 1, 0, PROB2
	setModule 0eh, 0, 1, 0, 0, PROB2
	setModule 0fh, 1, 0, 0, 0, PROB2
	ret
initModules endp

initBlockMap proc uses ebx ecx edx esi edi
	local   i:dword,
			j:dword,
			_out:dword,
			blocks:dword,
			temp:dword
	new BlockMap
	mov _out, eax
	mov esi, eax
	new Block, 64
	mov temp, eax
	new dword, 8
	mov blocks, eax
	mov (BlockMap ptr [esi]).blocks, eax

	mov i, 0
	.while i < 8
		mov esi, blocks
		mov eax, i
		mov edx, 0
		mov ebx, sizeof dword
		mul ebx
		add esi, eax
		mov eax, i
		mov edx, 0
		mov ebx, sizeof Block
		mul ebx
		mov ebx, 8
		mul ebx
		mov edi, temp
		add edi, eax
		mov dword ptr [esi], edi
		mov j, 0
		.while j < 8
			mov eax, i
			mov edx, 0
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, j
			mov edx, 0
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov (Block ptr [esi]).id, -1
			mov (Block ptr [esi]).availableModules, 0ffffh
			mov (Block ptr [esi]).entropyOutdated, true
			mov eax, j
			inc eax
			mov j, eax
		.endw
		mov eax, i
		inc eax
		mov i, eax
	.endw
	return _out
initBlockMap endp

calculateEntropy proc uses eax ebx ecx esi edi, block: dword
	local   total:real8,
			entropySum:real8
	mov esi, block
	mov al, (Block ptr [esi]).entropyOutdated
	.if al == false
		ret
	.endif
	mov (Block ptr [esi]).entropyOutdated, false

	fldz
	fst total
	fstp entropySum

	mov ecx, 0
	mov esi, offset modules
	mov edi, block
	mov ebx, (Block ptr [edi]).availableModules
	.while ecx < 16
		mov eax, (Module ptr [esi]).id
		and eax, ebx
		.if eax != false
			fld (Module ptr [esi]).probability
			fld total
			fadd
			fstp total
			invoke crt_log, (Module ptr [esi]).probability
			fld (Module ptr [esi]).probability
			fmul
			fld entropySum
			fadd
			fstp entropySum
		.endif
		add esi, sizeof Module
	.endw
	fld1
	fchs
	fld total
	fdiv
	fld entropySum
	fmul
	fstp (Block ptr [edi]).entropy
	invoke crt_log, total
	fld (Block ptr [edi]).entropy
	fadd
	fstp (Block ptr [edi]).entropy
	ret
calculateEntropy endp

collapse proc uses eax ebx ecx edx esi edi, blocks: dword, x: sdword, y: sdword
	local   block:dword,
			__max:real8,
			randResult:dword
	finit
	mov esi, blocks
	mov eax, x
	mov ebx, sizeof dword
	mov edx, 0
	mul ebx
	add esi, eax
	mov esi, dword ptr [esi]
	mov eax, y
	mov ebx, sizeof Block
	mov edx, 0
	mul ebx
	add esi, eax
	mov block, esi
	mov ecx, 0
	fldz
	.while ecx < 16
		mov esi, block
		mov esi, (Block ptr [esi]).availableModules
		mov eax, ecx
		mov edx, 0
		mov ebx, sizeof Module
		mul ebx
		mov edi, offset modules
		add edi, eax
		mov eax, (Module ptr [edi]).id
		and eax, esi
		.if eax != false
			fld (Module ptr [edi]).probability
			fadd
		.endif
		inc ecx
	.endw
	fstp __max
	invoke crt_rand
	mov randResult, eax
	fild randResult
	fld MAX_RAND
	fdiv
	fld __max
	fmul

	mov ecx, 0
	.while ecx < 16
		mov esi, block
		mov esi, (Block ptr [esi]).availableModules
		mov eax, ecx
		mov edx, 0
		mov ebx, sizeof Module
		mul ebx
		mov edi, offset modules
		add edi, eax
		mov eax, (Module ptr [edi]).id
		and eax, esi
		.if eax != false
			fld (Module ptr [edi]).probability
			fsub
			fldz
			fcomp
			fnstsw ax
			sahf
			jb collapse_l1
			mov esi, block
			mov (Block ptr [esi]).id, ecx
			jmp collapse_l2
collapse_l1:
		.endif
		inc ecx
	.endw
collapse_l2:
	mov esi, block
	mov eax, (Block ptr [esi]).id
	.if eax == -1
		mov (Block ptr [esi]).id, 0
	.endif

	.if y > 0
		mov esi, block
		mov eax, (Block ptr [esi]).id
		mov edx, 0
		mov ebx, sizeof Module
		mul ebx
		mov esi, offset modules
		add esi, eax
		mov al, (Module ptr [esi]).upId
		.if al != false
			mov eax, x
			mov edx, 0
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, y
			mov edx, 0
			dec eax
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			mov ebx, 0010111010110010b
			and ebx, eax
			mov (Block ptr [esi]).availableModules, ebx
			.if eax != ebx
				mov (Block ptr [esi]).entropyOutdated, true
			.endif
		.else
			mov eax, x
			mov edx, 0
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, y
			mov edx, 0
			dec eax
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			mov ebx, 1101000101001101b
			and ebx, eax
			mov (Block ptr [esi]).availableModules, ebx
			.if eax != ebx
				mov (Block ptr [esi]).entropyOutdated, true
			.endif
		.endif
	.endif
	.if x > 0
		mov esi, block
		mov eax, (Block ptr [esi]).id
		mov edx, 0
		mov ebx, sizeof Module
		mul ebx
		mov esi, offset modules
		add esi, eax
		mov al, (Module ptr [esi]).leftId
		.if al != false
			mov eax, x
			mov edx, 0
			dec eax
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, y
			mov edx, 0
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			mov ebx, 0001111101100100b
			and ebx, eax
			mov (Block ptr [esi]).availableModules, ebx
			.if eax != ebx
				mov (Block ptr [esi]).entropyOutdated, true
			.endif
		.else
			mov eax, x
			mov edx, 0
			dec eax
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, y
			mov edx, 0
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			mov ebx, 1110000010011011b
			and ebx, eax
			mov (Block ptr [esi]).availableModules, ebx
			.if eax != ebx
				mov (Block ptr [esi]).entropyOutdated, true
			.endif
		.endif
	.endif
	.if y < 7
		mov esi, block
		mov eax, (Block ptr [esi]).id
		mov edx, 0
		mov ebx, sizeof Module
		mul ebx
		mov esi, offset modules
		add esi, eax
		mov al, (Module ptr [esi]).downId
		.if al != false
			mov eax, x
			mov edx, 0
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, y
			mov edx, 0
			inc eax
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			mov ebx, 1000101111001010b
			and ebx, eax
			mov (Block ptr [esi]).availableModules, ebx
			.if eax != ebx
				mov (Block ptr [esi]).entropyOutdated, true
			.endif
		.else
			mov eax, x
			mov edx, 0
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, y
			mov edx, 0
			inc eax
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			mov ebx, 0111010000110101b
			and ebx, eax
			mov (Block ptr [esi]).availableModules, ebx
			.if eax != ebx
				mov (Block ptr [esi]).entropyOutdated, true
			.endif
		.endif
	.endif
	.if x < 7
		mov esi, block
		mov eax, (Block ptr [esi]).id
		mov edx, 0
		mov ebx, sizeof Module
		mul ebx
		mov esi, offset modules
		add esi, eax
		mov al, (Module ptr [esi]).rightId
		.if al != false
			mov eax, x
			mov edx, 0
			inc eax
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, y
			mov edx, 0
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			mov ebx, 0100110110011100b
			and ebx, eax
			mov (Block ptr [esi]).availableModules, ebx
			.if eax != ebx
				mov (Block ptr [esi]).entropyOutdated, true
			.endif
		.else
			mov eax, x
			mov edx, 0
			inc eax
			mov ebx, sizeof dword
			mul ebx
			mov esi, blocks
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, y
			mov edx, 0
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			mov ebx, 1011001001100011b
			and ebx, eax
			mov (Block ptr [esi]).availableModules, ebx
			.if eax != ebx
				mov (Block ptr [esi]).entropyOutdated, true
			.endif
		.endif
	.endif
	ret
collapse endp

collapseAll proc uses eax ebx ecx edx esi edi, blocks: dword
	local   i:dword,
			j:dword
	mov edi, 0
	mov i, 0
	.while i < 64
		finit
		fld MAX_ENTROPY
		mov j, 0
		.while j < 64
			mov eax, j
			mov edx, 0
			mov ebx, sizeof Block
			mul ebx
			mov esi, blocks
			mov esi, dword ptr [esi]
			add esi, eax
			invoke calculateEntropy, esi
			fld (Block ptr [esi]).entropy
			fcomp
			fnstsw ax
			sahf
			jnb collapseAll_l1
			mov ebx, (Block ptr [esi]).id

			.if ebx > 16
				fld (Block ptr [esi]).entropy
				mov edi, j
			.endif
collapseAll_l1:
			mov eax, j
			inc eax
			mov j, eax
		.endw
		mov eax, edi
		shr eax, 3
		mov ebx, edi
		and ebx, 111b
		invoke collapse, blocks, eax, ebx
		mov eax, i
		inc eax
		mov i, eax
	.endw
	ret
collapseAll endp

end
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
	fst (Module ptr [esi]).probability
	add esi, sizeof Module
endm

.data
modules Module 16 dup(<>)
PROB1 real8 0.1796875
PROB2 real8 0.0546875
public modules

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
	fst entropySum

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
			fst total
			invoke crt_log, (Module ptr [esi]).probability
			fld (Module ptr [esi]).probability
			fmul
			fld entropySum
			fadd
			fst entropySum
		.endif
		add esi, sizeof Module
	.endw
	fld1
	fchs
	fld total
	fdiv
	fld entropySum
	fmul
	fst (Block ptr [edi]).entropy
	invoke crt_log, total
	fld (Block ptr [edi]).entropy
	fadd
	fst (Block ptr [edi]).entropy
	ret
calculateEntropy endp

collapse proc uses eax ebx ecx edx esi edi, blocks: dword, x: sdword, y: sdword
	mov esi, blocks
	mov eax, x
	mov ebx, sizeof dword
	mov edx, 0
	mul ebx
	add esi, 
collapse endp

collapseAll proc, blocks: dword
collapseAll endp

end
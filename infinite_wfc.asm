__INFINITE_WFC_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include infinite_wfc.inc
include game_logic_top.inc

genConstraintUnit macro idType, fromX, fromY, toX, toY, trueNum, falseNum
	mov ecx, 0
	.while ecx < 8
		mov esi, from
		mov esi, (BlockMap ptr [esi]).blocks
		mov eax, fromX
		mov edx, 0
		mov ebx, sizeof dword
		mul ebx
		add esi, eax
		mov esi, dword ptr [esi]
		mov eax, fromY
		mov edx, 0
		mov ebx, sizeof Block
		mul ebx
		add esi, ebx
		mov eax, (Block ptr [esi]).id
		mov edx, 0
		mov ebx, sizeof Module
		mul ebx
		mov esi, offset modules
		add esi, eax
		mov al, idType
		.if al != false
			mov esi, to
			mov esi, (BlockMap ptr [esi]).blocks
			mov eax, toX
			mov edx, 0
			mov ebx, sizeof dword
			mul ebx
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, toY
			mov edx, 0
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			and eax, trueNum
			mov (Block ptr [esi]).availableModules, eax
			.else
			mov esi, to
			mov esi, (BlockMap ptr [esi]).blocks
			mov eax, toX
			mov edx, 0
			mov ebx, sizeof dword
			mul ebx
			add esi, eax
			mov esi, dword ptr [esi]
			mov eax, toY
			mov edx, 0
			mov ebx, sizeof Block
			mul ebx
			add esi, eax
			mov eax, (Block ptr [esi]).availableModules
			and eax, falseNum
			mov (Block ptr [esi]).availableModules, eax
		.endif
	.endw
endm

getIndex macro ___x:=<eax>, ___y:=<ebx>
	and ___x, 0ffffh
	shl ___y, 16
	or ___x, ___y
endm

genMapUnit macro createX, createY, insertX, insertY, isWall
	mov eax, actualX
	mov ebx, actualY
	add eax, createX
	add ebx, createY
	invoke createTile, eax, ebx, isWall
	mov esi, eax
	mov eax, actualX
	cdq
	mov ebx, 64
	idiv ebx
	mov tempX, eax
	mov eax, actualY
	cdq
	idiv ebx
	mov tempY, eax
	mov eax, tempX
	mov ebx, tempY
	add eax, insertX
	add ebx, insertY
	getIndex
	invoke insert, GAME_INSTANCE.underground.tilesMap, eax, esi
	invoke addToMap, addr GAME_INSTANCE.underground, esi, T_TILE
endm

.data
allBlocks dword ?
public allBlocks

.code
genConstraint proc uses eax ebx ecx edx esi edi, from: dword, to: dword, direction: dword
	.if direction == C_UP
		genConstraintUnit (Module ptr [esi]).upId, ecx, 0, ecx, 7, 0010111010110010b, 1101000101001101b
	.elseif direction == C_LEFT
		genConstraintUnit (Module ptr [esi]).leftId, 0, ecx, 7, ecx, 0001111101100100b, 1110000010011011b
	.elseif direction == C_DOWN
		genConstraintUnit (Module ptr [esi]).downId, ecx, 7, ecx, 0, 1000101111001010b, 0111010000110101b
	.elseif direction == C_RIGHT
		genConstraintUnit (Module ptr [esi]).rightId, 7, ecx, 0, ecx, 0100110110011100b, 1011001001100011b
	.endif
	ret
genConstraint endp

genBlock proc uses eax ebx esi, x: sdword, y: sdword, isFirst: _bool
	mov eax, x
	mov ebx, y
	getIndex
	invoke search, allBlocks, eax
	.if eax != nullptr
		ret
	.endif

	invoke initBlockMap
	mov esi, eax

	mov eax, x
	mov ebx, y
	dec eax
	getIndex
	invoke search, allBlocks, eax
	.if eax != nullptr
		invoke genConstraint, (AVLTreeNode ptr [eax]).value, esi, C_RIGHT
	.endif
	mov eax, x
	mov ebx, y
	dec ebx
	getIndex
	invoke search, allBlocks, eax
	.if eax != nullptr
		invoke genConstraint, (AVLTreeNode ptr [eax]).value, esi, C_RIGHT
	.endif
	mov eax, x
	mov ebx, y
	inc eax
	getIndex
	invoke search, allBlocks, eax
	.if eax != nullptr
		invoke genConstraint, (AVLTreeNode ptr [eax]).value, esi, C_RIGHT
	.endif
	mov eax, x
	mov ebx, y
	inc ebx
	getIndex
	invoke search, allBlocks, eax
	.if eax != nullptr
		invoke genConstraint, (AVLTreeNode ptr [eax]).value, esi, C_RIGHT
	.endif

	invoke collapseAll, (BlockMap ptr [esi]).blocks
	mov eax, x
	mov ebx, y
	getIndex
	invoke insert, allBlocks, eax, esi
	invoke genMap, x, y, esi, isFirst
	ret
genBlock endp

genMap proc uses eax ebx edx esi, x: sdword, y: sdword, blockMap: dword, isFirst: _bool
	local   actualX:sdword,
			actualY:sdword,
			i:dword,
			j:dword,
			tempX:sdword,
			tempY:sdword
	mov i, 0
	.while i < 8
		.while j < 8
			mov eax, x
			cdq
			mov ebx, 8
			imul ebx
			add eax, i
			cdq
			mov ebx, 192
			imul ebx
			mov actualX, eax
			mov eax, y
			cdq
			mov ebx, 8
			imul ebx
			add eax, j
			cdq
			mov ebx, 192
			imul ebx
			mov actualY, eax
			.if (isFirst != false) && (i == 0) && (j == 0)
					mov eax, actualX
					mov ebx, actualY
					invoke createGate
					mov esi, eax
					mov eax, actualX
					cdq
					mov ebx, 64
					idiv ebx
					mov tempX, eax
					mov eax, actualY
					cdq
					idiv ebx
					mov tempY, eax
					mov eax, tempX
					mov ebx, tempY
					getIndex
					invoke insert, GAME_INSTANCE.underground.tilesMap, eax, esi
					invoke addToMap, addr GAME_INSTANCE.underground, esi, T_TILE

					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, false
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
			.else
				mov esi, blockMap
				mov esi, (BlockMap ptr [esi]).blocks
				mov eax, i
				mov edx, 0
				mov ebx, sizeof dword
				mul ebx
				add esi, eax
				mov esi, dword ptr [esi]
				mov eax, j
				mov edx, 0
				mov ebx, sizeof Block
				mul ebx
				add esi, eax
				mov esi, (Block ptr [esi]).id
				.if esi == 00h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, false
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
					invoke crt_rand
					mov edx, 0
					mov ebx, 6
					div ebx
					.if edx < 2
						mov eax, actualX
						mov ebx, actualY
						add eax, 64
						add ebx, 64
						invoke createEnemy, eax, ebx, 5000, 1
						invoke addToMap, addr GAME_INSTANCE.underground, eax, T_DESTROYABLE
					.endif
					invoke crt_rand
					mov edx, 0
					mov ebx, 6
					div ebx
					.if edx < 1
						mov eax, actualX
						mov ebx, actualY
						add eax, 64
						add ebx, 64
						invoke createCoin, eax, ebx
						invoke addToMap, addr GAME_INSTANCE.underground, eax, T_DESTROYABLE
					.endif
				.elseif esi == 01h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, true
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, true
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 02h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, true
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, true
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 03h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, true
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, true
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 04h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, true
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, true
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 05h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, true
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, true
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 06h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, true
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, true
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 07h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, true
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, true
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, true
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 08h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, true
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, true
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, true
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 09h
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, true
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, true
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, true
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 0ah
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, true
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, true
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, true
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 0bh
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, true
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, true
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, true
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, true
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 0ch
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, true
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 0dh
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, true
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 0eh
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, true
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, false
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
				.elseif esi == 0fh
					genMapUnit 0, 0, 0, 0, false
					genMapUnit 0, 64, 0, 1, false
					genMapUnit 0, 128, 0, 2, false
					genMapUnit 64, 0, 1, 0, true
					genMapUnit 64, 64, 1, 1, true
					genMapUnit 64, 128, 1, 2, false
					genMapUnit 128, 0, 2, 0, false
					genMapUnit 128, 64, 2, 1, false
					genMapUnit 128, 128, 2, 2, false
				.endif
			.endif
			mov eax, j
			inc eax
			mov j, eax
		.endw
		mov eax, i
		inc eax
		mov i, eax
	.endw
	ret
genMap endp
end
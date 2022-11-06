__AVL_TREE_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include avl_tree.inc
include windef.inc

.code
createNode proc uses esi, key: dword, value: dword, l: dword, r: dword
	new AVLTreeNode
	mov esi, eax

	mov eax, key
	mov (AVLTreeNode ptr [esi]).key, eax
	mov eax, value
	mov (AVLTreeNode ptr [esi]).value, eax
	mov eax, l
	mov (AVLTreeNode ptr [esi]).left, eax
	mov eax, r
	mov (AVLTreeNode ptr [esi]).right, eax

	return esi
createNode endp

createTree proc uses esi
	new AVLTree
	mov esi, eax
	mov (AVLTree ptr [esi]).mRoot, nullptr

	return esi
createTree endp

_height proc uses esi, tree: dword
	mov esi, tree
	.if esi != nullptr
		mov eax, (AVLTreeNode ptr [esi]).height
		ret
	.endif

	return 0
_height endp

height proc uses esi, self: dword
	mov esi, self
	invoke _height, (AVLTree ptr [esi]).mRoot
	ret
height endp

_max proc, a: dword, b: dword
	mov eax, a
	mov ebx, b
	.if eax < ebx
		mov eax, ebx
	.endif
	ret
_max endp

_search proc uses esi, x: dword, key: dword
	mov esi, x
	.if esi == nullptr
		return esi
	.endif
	mov eax, (AVLTreeNode ptr [esi]).key
	.if eax == key
		return esi
	.endif

	.if key < eax
		mov eax, (AVLTreeNode ptr [esi]).left
		invoke _search, eax, key
		ret
	.else
		mov eax, (AVLTreeNode ptr [esi]).right
		invoke _search, eax, key
		ret
	.endif
_search endp

search proc uses esi, self: dword, key: dword
	mov esi, self
	invoke _search, (AVLTree ptr [esi]).mRoot, key
	ret
search endp

_maximum proc uses esi, tree: dword
	mov esi, tree
	.if esi == nullptr
		return nullptr
	.endif

	.while 1
		mov eax, (AVLTreeNode ptr [esi]).right
		.if eax == nullptr
			jmp _maximum_end
		.endif
		mov esi, eax
	.endw
_maximum_end:
	return esi
_maximum endp

leftLeftRotation proc uses esi edi ebx, _k2: dword
	mov edi, _k2

	mov esi, (AVLTreeNode ptr [edi]).left
	mov eax, (AVLTreeNode ptr [esi]).right
	mov (AVLTreeNode ptr [edi]).left, eax
	mov (AVLTreeNode ptr [esi]).right, edi

	invoke _height, (AVLTreeNode ptr [edi]).right
	mov ebx, eax
	invoke _height, (AVLTreeNode ptr [edi]).left
	invoke _max, eax, ebx
	inc eax
	mov (AVLTreeNode ptr [edi]).height, eax
	invoke _height, (AVLTreeNode ptr [esi]).left
	invoke _max, eax, (AVLTreeNode ptr [edi]).height
	inc eax
	mov (AVLTreeNode ptr [esi]).height, eax

	return esi
leftLeftRotation endp

rightRightRotation proc uses esi edi ebx, _k1: dword
	mov esi, _k1
	mov edi, (AVLTreeNode ptr [esi]).right
	mov eax, (AVLTreeNode ptr [edi]).left
	mov (AVLTreeNode ptr [esi]).right, eax
	mov (AVLTreeNode ptr [edi]).left, esi

	invoke _height, (AVLTreeNode ptr [esi]).right
	mov ebx, eax
	invoke _height, (AVLTreeNode ptr [esi]).left
	invoke _max, eax, ebx
	inc eax
	mov (AVLTreeNode ptr [esi]).height, eax
	invoke _height, (AVLTreeNode ptr [edi]).right
	invoke _max, eax, (AVLTreeNode ptr [esi]).height
	inc eax
	mov (AVLTreeNode ptr [edi]).height, eax

	return edi
rightRightRotation endp

leftRightRotation proc uses esi, _k3: dword
	mov esi, _k3
	invoke rightRightRotation, (AVLTreeNode ptr [esi]).left
	mov (AVLTreeNode ptr [esi]).left, eax
	invoke leftLeftRotation, esi
	ret
leftRightRotation endp

rightLeftRotation proc uses esi, _k1: dword
	mov esi, _k1
	invoke leftLeftRotation, (AVLTreeNode ptr [esi]).right
	mov (AVLTreeNode ptr [esi]).right, eax
	invoke rightRightRotation, esi
	ret
rightLeftRotation endp

_insert proc uses esi ebx edi, tree: dword, key: dword, value: dword
	mov esi, tree
	.if esi == nullptr
		invoke createNode, key, value, nullptr, nullptr
		mov esi, eax
	.else
		mov eax, (AVLTreeNode ptr [esi]).key
		.if key < eax
			invoke _insert, (AVLTreeNode ptr [esi]).left, key, value
			invoke _height, (AVLTreeNode ptr [esi]).right
			mov ebx, eax
			invoke _height, (AVLTreeNode ptr [esi]).left
			sub eax, ebx
			.if eax == 2
				mov edi, (AVLTreeNode ptr [esi]).left
				mov eax, (AVLTreeNode ptr [edi]).key
				.if key < eax
					invoke leftLeftRotation, esi
					mov esi, eax
				.else
					invoke leftRightRotation, esi
					mov esi, eax
				.endif
			.endif
		.elseif key > eax
			invoke _insert, (AVLTreeNode ptr [esi]).right, key, value
			invoke _height, (AVLTreeNode ptr [esi]).left
			mov ebx, eax
			invoke _height, (AVLTreeNode ptr [esi]).right
			sub eax, ebx
			.if eax == 2
				mov edi, (AVLTreeNode ptr [esi]).right
				mov eax, (AVLTreeNode ptr [edi]).key
				.if key < eax
					invoke rightRightRotation, esi
					mov esi, eax
				.else
					invoke rightLeftRotation, esi
					mov esi, eax
				.endif
			.endif
		.else
			mov eax, value
			mov (AVLTreeNode ptr [esi]).value, eax
		.endif
	.endif

	invoke _height, (AVLTreeNode ptr [esi]).right
	mov ebx, eax
	invoke _height, (AVLTreeNode ptr [esi]).left
	invoke _max, eax, ebx
	inc eax
	mov (AVLTreeNode ptr [esi]).height, eax
	return esi
_insert endp

insert proc uses eax esi, self: dword, key: dword, value: dword
	mov esi, self
	invoke _insert, (AVLTree ptr [esi]).mRoot, key, value
	mov (AVLTree ptr [esi]).mRoot, eax
	ret
insert endp

_remove proc uses esi edi ebx, tree: dword, _z: dword
	mov esi, tree
	mov edi, _z
	.if (esi == nullptr) || (edi == nullptr)
		return nullptr
	.endif

	mov eax, (AVLTreeNode ptr [esi]).key
	mov ebx, (AVLTreeNode ptr [edi]).key
	.if ebx < eax
		invoke remove, (AVLTreeNode ptr [esi]).left, edi
		mov (AVLTreeNode ptr [esi]).left, eax

		invoke _height, (AVLTreeNode ptr [esi]).left
		mov ebx, eax
		invoke _height, (AVLTreeNode ptr [esi]).right
		sub eax, ebx
		.if eax == 2
			mov edi, (AVLTreeNode ptr [esi]).right
			invoke height, (AVLTreeNode ptr [edi]).right
			mov ebx, eax
			invoke height, (AVLTreeNode ptr [edi]).left
			.if eax > ebx
				invoke rightLeftRotation, esi
				mov esi, eax
			.else
				invoke rightRightRotation, esi
				mov esi, eax
			.endif
		.endif
	.elseif ebx > eax
		invoke remove, (AVLTreeNode ptr [esi]).right, edi
		mov (AVLTreeNode ptr [esi]).right, eax

		invoke _height, (AVLTreeNode ptr [esi]).right
		mov ebx, eax
		invoke _height, (AVLTreeNode ptr [esi]).left
		sub eax, ebx
		.if eax == 2
			mov edi, (AVLTreeNode ptr [esi]).left
			invoke height, (AVLTreeNode ptr [edi]).left
			mov ebx, eax
			invoke height, (AVLTreeNode ptr [edi]).right
			.if eax > ebx
				invoke leftRightRotation, esi
				mov esi, eax
			.else
				invoke leftLeftRotation, esi
				mov esi, eax
			.endif
		.endif
	.else
		mov eax, (AVLTreeNode ptr [esi]).left
		mov ebx, (AVLTreeNode ptr [esi]).right
		.if (eax != nullptr) && (ebx != nullptr)
			invoke _height, ebx
			mov ebx, eax
			mov eax, (AVLTreeNode ptr [esi]).left
			invoke _height, eax
			.if eax > ebx
				invoke _maximum, (AVLTreeNode ptr [esi]).left
				mov edi, eax
				mov eax, (AVLTreeNode ptr [edi]).key
				mov (AVLTreeNode ptr [esi]).key, eax
				invoke _remove, (AVLTreeNode ptr [esi]).left, edi
				mov (AVLTreeNode ptr [esi]).left, eax
			.else
				invoke _maximum, (AVLTreeNode ptr [esi]).right
				mov edi, eax
				mov eax, (AVLTreeNode ptr [edi]).key
				mov (AVLTreeNode ptr [esi]).key, eax
				invoke _remove, (AVLTreeNode ptr [esi]).right, edi
				mov (AVLTreeNode ptr [esi]).right, eax
			.endif
		.else
			mov edi, esi
			mov eax, (AVLTreeNode ptr [esi]).left
			.if eax != nullptr
				mov esi, eax
			.else
				mov esi, (AVLTreeNode ptr [esi]).right
			.endif
			delete edi
		.endif
	.endif

	return esi
_remove endp

remove proc uses eax esi, self: dword, key: dword
	mov esi, self
	invoke _search, (AVLTree ptr [esi]).mRoot, key
	.if eax != nullptr
		invoke _remove, (AVLTree ptr [esi]).mRoot, eax
		mov (AVLTree ptr [esi]).mRoot, eax
	.endif
	ret
remove endp

end
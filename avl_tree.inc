ifndef __AVL_TREE_INC__
__AVL_TREE_INC__ macro
endm

AVLTreeNode struct
	key dword ?
	value dword ?
	height sdword ?
	left dword ?
	right dword ?
AVLTreeNode ends

AVLTree struct
	mRoot dword ?
AVLTree ends

createNode proto, key: dword, value: dword, l: dword, r: dword
createTree proto
_height proto, tree: dword
height proto, self: dword
_max proto, a: dword, b: dword
_search proto, x: dword, key: dword
search proto, self: dword, key: dword
_maximum proto, tree: dword
leftLeftRotation proto, _k2: dword
rightRightRotation proto, _k1: dword
leftRightRotation proto, _k3: dword
rightLeftRotation proto, _k1: dword
_insert proto, tree: dword, key: dword, value: dword
insert proto, self: dword, key: dword, value: dword
_remove proto, tree: dword, _z: dword
remove proto, self: dword, key: dword

endif
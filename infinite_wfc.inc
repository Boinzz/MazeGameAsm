ifndef __INFINITE_WFC_INC__
__INFINITE_WFC_INC__ macro
endm

include wfc.inc
include avl_tree.inc

C_UP textequ <0>
C_LEFT textequ <1>
C_DOWN textequ <2>
C_RIGHT textequ <3>

genConstraint proto, from: dword, to: dword, direction: dword
genBlock proto, x: sdword, y: sdword, isFirst: bool
genMap proto, x: sdword, y: sdword, blockMap: dword, isFirst: bool

ifndef __INFINITE_WFC_ASM__
.data
extern allBlocks:dword
endif

endif
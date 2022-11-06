__INFINITE_WFC_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include infinite_wfc.inc
include game_logic_top.inc

.data
allBlocks dword ?
public allBlocks
.code
genConstraint proc, from: dword, to: dword, direction: dword
genConstraint endp

genBlock proc, x: sdword, y: sdword, isFirst: bool
genBlock endp

genMap proc, x: sdword, y: sdword, blockMap: dword, isFirst: bool
genMap endp
end
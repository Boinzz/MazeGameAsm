ifndef __WFC_INC__
__WFC_INC__ macro
endm

include windef.inc

Module struct
	id dword ?
	upId _bool ?
	leftId _bool ?
	downId _bool ?
	rightId _bool ?
	probability real8 ?
Module ends

Block struct
	id dword ?
	availableModules dword ?
	entropyOutdated _bool ?
	entropy real8 ?
Block ends

BlockMap struct
	blocks dword ?
BlockMap ends

initModules proto
initBlockMap proto
calculateEntropy proto, block: dword
collapse proto, blocks: dword, x: sdword, y: sdword
collapseAll proto, blocks: dword

ifndef __WFC_ASM__
.data
extern modules:Module
endif

endif
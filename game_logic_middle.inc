ifndef __GAME_LOGIC_MIDDLE_INC__
__GAME_LOGIC_MIDDLE_INC__ macro
endm

include game_objects.inc

ObjDefList struct
	player GameObjectDef <>
	enemy GameObjectDef <>
	tower GameObjectDef <>
	wall GameObjectDef <>
	ground GameObjectDef <>
	bullet GameObjectDef <>
	gate GameObjectDef <>
	coin GameObjectDef <>
ObjDefList ends

loadGame proto
renderGameObjects proto, canvas: PaintDevice
renderGameObject proto, obj: dword, canvas: PaintDevice
gameLogic proto
mapLogic proto, map: dword

ifndef __GAME_LOGIC_MIDDLE_ASM__
.data
extern objDefList:ObjDefList
endif

endif
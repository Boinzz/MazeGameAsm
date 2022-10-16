ifndef __GAME_OBJECTS_INC__
__GAME_OBJECTS_INC__ macro
endm

include windef.inc

MoveStatus textequ <sdword>

MV_STILL textequ <0>
MV_UP textequ <1>
MV_DOWN textequ <2>
MV_LEFT textequ <3>
MV_RIGHT textequ <4>

EXTENDS macro super
	super
endm

M_GAME_OBJECT_DEF macro
	id sdword ?
	frameWidth sdword ?
	frameHeight sdword ?
	frameCount sdword ?
	frameLengths Pointer ?
	frames Pointer ?
endm

GameObjectDef struct
	M_GAME_OBJECT_DEF
GameObjectDef ends

M_GAME_OBJECT macro
	id sdword ?
	posX sdword ?
	posY sdword ?
	objDef Pointer ?
	currentFrame sdword ?
	toBeDestroyed bool ?
endm

GameObject struct
	M_GAME_OBJECT
GameObject ends

M_DESTROYABLE macro
	EXTENDS M_GAME_OBJECT
	hp sdword ?
	mapId sdword ?
endm

Destroyable struct
	M_DESTROYABLE
Destroyable ends

M_LIVING macro
	EXTENDS M_DESTROYABLE
	moveStatus MoveStatus ?
	speed sdword ?
endm

Living struct
	M_LIVING
Living ends

M_PLAYER macro
	EXTENDS M_LIVING
	attacking bool ?
	coins sdword ?
	level sdword ?
endm

Player struct
	M_PLAYER
Player ends

M_ENEMY macro
	EXTENDS M_LIVING
	targetId sdword ?
endm

Enemy struct
	M_ENEMY
Enemy ends

M_BULLET macro
	EXTENDS M_GAME_OBJECT
	velX real4 ?
	velY real4 ?
	damage sdword ?
endm

Bullet struct
	M_BULLET
Bullet ends

M_TOWER macro
	EXTENDS M_DESTROYABLE
	level sdword ?
	targetId sdword ?
endm

Tower struct
	M_TOWER
Tower ends

ListNode struct
	value Pointer ?
	next Pointer ?
ListNode ends

List textequ Pointer

Map struct
	tiles List ?
	destroyables List ?
	bullets List ?
Map ends

Game struct
	ground Map <>
	underground Map <>
	playerOnGround bool ?
	
	player Pointer ?
Game ends

ifndef __GAME_OBJECTS_ASM__
.data
	extern GAME_INSTANCE: Game
endif

endif
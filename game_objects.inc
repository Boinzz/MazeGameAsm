ifndef __GAME_OBJECTS_INC__
__GAME_OBJECTS_INC__ macro
endm

include windef.inc
include avl_tree.inc

MoveStatus textequ <sdword>
MV_STILL textequ <0>
MV_UP textequ <1>
MV_DOWN textequ <2>
MV_LEFT textequ <3>
MV_RIGHT textequ <4>

extends macro param:REQ
	param
endm

GAME_OBJECT_DEF macro
	id sdword ?
	_width sdword ?
	__height sdword ?
	frameCount sdword ?
	frameLengths dword ?
	frames dword ?
endm

GameObjectDef struct
	GAME_OBJECT_DEF
GameObjectDef ends

GAME_OBJECT macro
	id sdword ?
	posX sdword ?
	posY sdword ?
	def dword ?
	currentFrame sdword ?
	nextFrame sdword ?
	tick sdword ?
	toBeDestroyed bool ?
endm

GameObject struct
	GAME_OBJECT
GameObject ends

MAP_TILE macro
	extends GAME_OBJECT
	walkable bool ?
endm

MapTile struct
	MAP_TILE
MapTile ends

DESTROYABLE macro
	extends GAME_OBJECT
	hp sdword ?
	mapId sdword ?
endm

Destroyable struct
	DESTROYABLE
Destroyable ends

LIVING macro
	extends DESTROYABLE
	moveStatus MoveStatus ?
	speed sdword ?
endm

Living struct
	LIVING
Living ends

PLAYER macro
	extends LIVING
	coins sdword ?
	level sdword ?
endm

Player struct
	PLAYER
Player ends

ENEMY macro
	extends LIVING
	targetId sdword ?
endm

Enemy struct
	ENEMY
Enemy ends

BULLET macro
	extends GAME_OBJECT
	velX real8 ?
	velY real8 ?
	damage sdword ?
endm

Bullet struct
	BULLET
Bullet ends

TOWER macro
	extends DESTROYABLE
	level sdword ?
endm

Tower struct
	TOWER
Tower ends

ListNode struct
	value dword ?
	next dword ?
ListNode ends

List textequ <dword>

Map struct
	tilesHead List ?
	destroyablesHead List ?
	bulletsHead List ?
	tilesEnd List ?
	destroyablesEnd List ?
	bulletsEnd List ?
	tilesMap dword ?
Map ends

Game struct
	ground Map <>
	underground Map <>
	playerOnGround bool ?
	player dword ?
	towers dword ?
	globalTick sdword ?
	score sdword ?
Game ends

ifndef __GAME_OBJECTS_ASM__
.data
extern GAME_INSTANCE:Game
endif

endif
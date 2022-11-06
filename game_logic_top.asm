__GAME_LOGIC_TOP_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include game_logic_top.inc
include game_logic_base.inc
include game_logic_middle.inc
include avl_tree.inc
include infinite_wfc.inc

.data
_out GameObjectDef <>
currentDefId dword 0
currentObjId dword 0
P_PLAYER0 byte "./player/player0.bmp", 0
P_PLAYER1 byte "./player/player1.bmp", 0
P_PLAYER2 byte "./player/player2.bmp", 0
P_PLAYER3 byte "./player/player3.bmp", 0
P_PLAYER4 byte "./player/player4.bmp", 0
P_PLAYER5 byte "./player/player5.bmp", 0
P_PLAYER6 byte "./player/player6.bmp", 0
P_PLAYER7 byte "./player/player7.bmp", 0
P_PLAYER8 byte "./player/player8.bmp", 0
P_PLAYER9 byte "./player/player9.bmp", 0
P_PLAYERa byte "./player/playerA.bmp", 0
P_PLAYERb byte "./player/playerB.bmp", 0
P_ENEMY0 byte "./enemy/enemy0.bmp", 0
P_ENEMY1 byte "./enemy/enemy1.bmp", 0
P_ENEMY2 byte "./enemy/enemy2.bmp", 0
P_ENEMY3 byte "./enemy/enemy3.bmp", 0
P_ENEMY4 byte "./enemy/enemy4.bmp", 0
P_ENEMY5 byte "./enemy/enemy5.bmp", 0
P_ENEMY6 byte "./enemy/enemy6.bmp", 0
P_ENEMY7 byte "./enemy/enemy7.bmp", 0
P_WALL byte "./map/wall.bmp", 0
P_GROUND byte "./map/ground.bmp", 0
P_TOWER0 byte "./tower/tower0.bmp", 0
P_TOWER1 byte "./tower/tower1.bmp", 0
P_BULLET byte "./map/bullet.bmp", 0
P_GATE byte "./map/gate.bmp", 0
P_COIN byte "./map/coin.bmp", 0

.code
initPlayer proc uses esi ecx
	mov eax, currentDefId
	mov _out.id, eax
	inc eax
	mov currentDefId, eax

	mov _out._width, 64
	mov _out.__height, 64
	mov _out.frameCount, 12
	new dword, 12
	mov _out.frameLengths, eax
	mov ecx, 0
	.while ecx < 12
		mov dword ptr [eax], 5
		add eax, sizeof dword
		inc ecx
	.endw
	new Bitmap, 12
	mov _out.frames, eax
	mov esi, eax

	invoke loadBitmap, addr P_PLAYER0, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER1, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER2, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER3, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER4, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER5, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER6, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER7, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER8, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYER9, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYERa, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_PLAYERb, 64, 64
	mov Bitmap ptr [esi], eax

	mov esi, offset _out
	return esi
initPlayer endp

initEnemy proc uses esi ecx
	mov eax, currentDefId
	mov _out.id, eax
	inc eax
	mov currentDefId, eax

	mov _out._width, 64
	mov _out.__height, 64
	mov _out.frameCount, 8
	new dword, 8
	mov _out.frameLengths, eax
	mov ecx, 0
	.while ecx < 8
		mov dword ptr [eax], 10
		add eax, sizeof dword
		inc ecx
	.endw
	new Bitmap, 8
	mov _out.frames, eax
	mov esi, eax

	invoke loadBitmap, addr P_ENEMY0, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_ENEMY1, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_ENEMY2, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_ENEMY3, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_ENEMY4, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_ENEMY5, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_ENEMY6, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_ENEMY7, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap

	mov esi, offset _out
	return esi
initEnemy endp

initWall proc uses esi
	mov eax, currentDefId
	mov _out.id, eax
	inc eax
	mov currentDefId, eax

	mov _out._width, 64
	mov _out.__height, 64
	mov _out.frameCount, 1
	new dword, 1
	mov _out.frameLengths, eax
	mov dword ptr [eax], 0
	new Bitmap, 1
	mov _out.frames, eax
	mov esi, eax

	invoke loadBitmap, addr P_WALL, 64, 64
	mov Bitmap ptr [esi], eax

	mov esi, offset _out
	return esi
initWall endp

initGround proc uses esi
	mov eax, currentDefId
	mov _out.id, eax
	inc eax
	mov currentDefId, eax

	mov _out._width, 64
	mov _out.__height, 64
	mov _out.frameCount, 1
	new dword, 1
	mov _out.frameLengths, eax
	mov dword ptr [eax], 0
	new Bitmap, 1
	mov _out.frames, eax
	mov esi, eax

	invoke loadBitmap, addr P_GROUND, 64, 64
	mov Bitmap ptr [esi], eax

	mov esi, offset _out
	return esi
initGround endp

initTower proc uses esi
	mov eax, currentDefId
	mov _out.id, eax
	inc eax
	mov currentDefId, eax

	mov _out._width, 64
	mov _out.__height, 64
	mov _out.frameCount, 2
	new dword, 2
	mov _out.frameLengths, eax

	mov dword ptr [eax], 0
	add eax, sizeof dword
	mov dword ptr [eax], 0

	new Bitmap, 2
	mov _out.frames, eax
	mov esi, eax

	invoke loadBitmap, addr P_TOWER0, 64, 64
	mov Bitmap ptr [esi], eax
	add esi, sizeof Bitmap
	invoke loadBitmap, addr P_TOWER1, 64, 64
	mov Bitmap ptr [esi], eax

	mov esi, offset _out
	return esi
initTower endp

initBullet proc uses esi
	mov eax, currentDefId
	mov _out.id, eax
	inc eax
	mov currentDefId, eax

	mov _out._width, 16
	mov _out.__height, 16
	mov _out.frameCount, 1
	new dword, 1
	mov _out.frameLengths, eax
	mov dword ptr [eax], 0
	new Bitmap, 1
	mov _out.frames, eax
	mov esi, eax

	invoke loadBitmap, addr P_BULLET, 16, 16
	mov Bitmap ptr [esi], eax

	mov esi, offset _out
	return esi
initBullet endp

initGate proc uses esi
	mov eax, currentDefId
	mov _out.id, eax
	inc eax
	mov currentDefId, eax

	mov _out._width, 64
	mov _out.__height, 64
	mov _out.frameCount, 1
	new dword, 1
	mov _out.frameLengths, eax
	mov dword ptr [eax], 0
	new Bitmap, 1
	mov _out.frames, eax
	mov esi, eax

	invoke loadBitmap, addr P_GATE, 64, 64
	mov Bitmap ptr [esi], eax

	mov esi, offset _out
	return esi
initGate endp

initCoin proc uses esi
	mov eax, currentDefId
	mov _out.id, eax
	inc eax
	mov currentDefId, eax

	mov _out._width, 64
	mov _out.__height, 64
	mov _out.frameCount, 1
	new dword, 1
	mov _out.frameLengths, eax
	mov dword ptr [eax], 0
	new Bitmap, 1
	mov _out.frames, eax
	mov esi, eax

	invoke loadBitmap, addr P_COIN, 64, 64
	mov Bitmap ptr [esi], eax

	mov esi, offset _out
	return esi
initCoin endp

createPlayer proc
createPlayer endp

createEnemy proc, posX: sdword, posY: sdword, hp: sdword, mapId: sdword
createEnemy endp

createTile proc, posX: sdword, posY: sdword, isWall: bool
createTile endp

createTower proc, posX: sdword, posY: sdword
createTower endp

createBullet proc, posX: sdword, posY: sdword, velX: real8, velY: real8, damage: sdword
createBullet endp

createGate proc
createGate endp

createCoin proc, posX: sdword, posY: sdword
createCoin endp

initMap proc
initMap endp

createGround proc
createGround endp

createUnderground proc
createUnderground endp

infiniteGenMap proc, x: sdword, y: sdword
infiniteGenMap endp

addToMap proc, map: dword, obj: dword, _type: ObjType
addToMap endp

removeFromMap proc, obj: dword
removeFromMap endp

moveLogic proc, obj: dword, velX: sdword, velY: sdword
moveLogic endp

playerLogic proc
playerLogic endp

enemyLogic proc, enemy: dword
enemyLogic endp

playerAttackLogic proc
playerAttackLogic endp

towerLogic proc, tower: dword
towerLogic endp

bulletLogic proc, mapId: sdword, bullet: dword
bulletLogic endp

coinLogic proc, coin: dword
coinLogic endp

upgradeLogic proc
upgradeLogic endp

genEnemy proc
genEnemy endp

changeMap proc
changeMap endp

end
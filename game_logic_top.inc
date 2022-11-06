ifndef __GAME_LOGIC_TOP_INC__
__GAME_LOGIC_TOP_INC__ macro
endm

include game_objects.inc

T_BULLET textequ <0>
T_DESTROYABLE textequ <1>
T_TILE textequ <2>
ObjType textequ <dword>

initPlayer proto
initEnemy proto
initWall proto
initGround proto
initTower proto
initBullet proto
initGate proto
initCoin proto
createPlayer proto
createEnemy proto, posX: sdword, posY: sdword, hp: sdword, mapId: sdword
createTile proto, posX: sdword, posY: sdword, isWall: _bool
createTower proto, posX: sdword, posY: sdword
createBullet proto, posX: sdword, posY: sdword, velX: real8, velY: real8, damage: sdword
createGate proto
createCoin proto, posX: sdword, posY: sdword
initMap proto
createGround proto
createUnderground proto
infiniteGenMap proto, x: sdword, y: sdword
addToMap proto, map: dword, obj: dword, _type: ObjType
moveLogic proto, obj: dword, velX: sdword, velY: sdword
playerLogic proto
enemyLogic proto, enemy: dword
playerAttackLogic proto
towerLogic proto, tower: dword
bulletLogic proto, mapId: sdword, bullet: dword
coinLogic proto, coin: dword
upgradeLogic proto
genEnemy proto
changeMap proto

endif
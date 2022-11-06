__GAME_LOGIC_MIDDLE_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include game_logic_middle.inc
include game_logic_base.inc
include game_logic_top.inc
include wfc.inc

.data
objDefList ObjDefList <>
ftn BLENDFUNCTION <AC_SRC_OVER, 0, 0ffh, AC_SRC_ALPHA>
public objDefList

.code
loadGame proc uses eax ebx ecx edx esi edi
	invoke initModules

	invoke initPlayer
	mov esi, eax
	mov edi, offset objDefList.player
	mov ecx, 0
	mov ebx, sizeof GameObjectDef
	.while ecx < ebx
		mov dl, byte ptr [esi]
		mov byte ptr [edi], dl
		inc ecx
		inc esi
		inc edi
	.endw

	invoke initEnemy
	mov esi, eax
	mov edi, offset objDefList.enemy
	mov ecx, 0
	mov ebx, sizeof GameObjectDef
	.while ecx < ebx
		mov dl, byte ptr [esi]
		mov byte ptr [edi], dl
		inc ecx
		inc esi
		inc edi
	.endw

	invoke initWall
	mov esi, eax
	mov edi, offset objDefList.wall
	mov ecx, 0
	mov ebx, sizeof GameObjectDef
	.while ecx < ebx
		mov dl, byte ptr [esi]
		mov byte ptr [edi], dl
		inc ecx
		inc esi
		inc edi
	.endw

	invoke initGround
	mov esi, eax
	mov edi, offset objDefList.ground
	mov ecx, 0
	mov ebx, sizeof GameObjectDef
	.while ecx < ebx
		mov dl, byte ptr [esi]
		mov byte ptr [edi], dl
		inc ecx
		inc esi
		inc edi
	.endw

	invoke initTower
	mov esi, eax
	mov edi, offset objDefList.tower
	mov ecx, 0
	mov ebx, sizeof GameObjectDef
	.while ecx < ebx
		mov dl, byte ptr [esi]
		mov byte ptr [edi], dl
		inc ecx
		inc esi
		inc edi
	.endw

	invoke initBullet
	mov esi, eax
	mov edi, offset objDefList.bullet
	mov ecx, 0
	mov ebx, sizeof GameObjectDef
	.while ecx < ebx
		mov dl, byte ptr [esi]
		mov byte ptr [edi], dl
		inc ecx
		inc esi
		inc edi
	.endw

	invoke initGate
	mov esi, eax
	mov edi, offset objDefList.gate
	mov ecx, 0
	mov ebx, sizeof GameObjectDef
	.while ecx < ebx
		mov dl, byte ptr [esi]
		mov byte ptr [edi], dl
		inc ecx
		inc esi
		inc edi
	.endw

	invoke initCoin
	mov esi, eax
	mov edi, offset objDefList.coin
	mov ecx, 0
	mov ebx, sizeof GameObjectDef
	.while ecx < ebx
		mov dl, byte ptr [esi]
		mov byte ptr [edi], dl
		inc ecx
		inc esi
		inc edi
	.endw

	invoke createPlayer
	mov GAME_INSTANCE.player, eax
	mov esi, eax
	mov (Player ptr [esi]).mapId, 0
	mov GAME_INSTANCE.playerOnGround, true
	mov GAME_INSTANCE.score, 0

	invoke initMap
	invoke addToMap, addr GAME_INSTANCE.ground, GAME_INSTANCE.player, T_DESTROYABLE

	new dword, 4
	mov esi, eax
	mov GAME_INSTANCE.towers, eax
	invoke createTower, 128, 128
	mov dword ptr [esi], eax
	invoke addToMap, addr GAME_INSTANCE.ground, eax, T_DESTROYABLE
	add esi, sizeof dword
	invoke createTower, 128, -128
	mov dword ptr [esi], eax
	invoke addToMap, addr GAME_INSTANCE.ground, eax, T_DESTROYABLE
	add esi, sizeof dword
	invoke createTower, -128, 128
	mov dword ptr [esi], eax
	invoke addToMap, addr GAME_INSTANCE.ground, eax, T_DESTROYABLE
	add esi, sizeof dword
	invoke createTower, -128, -128
	mov dword ptr [esi], eax
	invoke addToMap, addr GAME_INSTANCE.ground, eax, T_DESTROYABLE

	invoke createGround
	invoke createUnderground
	mov GAME_INSTANCE.globalTick, 0
	mov esi, GAME_INSTANCE.player
	mov (Player ptr [esi]).level, 0
	mov esi, GAME_INSTANCE.towers
	mov edi, dword ptr [esi]
	mov (Tower ptr [edi]).level, 0
	add esi, sizeof dword
	mov edi, dword ptr [esi]
	mov (Tower ptr [edi]).level, 0
	add esi, sizeof dword
	mov edi, dword ptr [esi]
	mov (Tower ptr [edi]).level, 0
	add esi, sizeof dword
	mov edi, dword ptr [esi]
	mov (Tower ptr [edi]).level, 0
	ret
loadGame endp

renderGameObjects proc uses eax esi edi ebx, canvas: PaintDevice
	.if GAME_INSTANCE.playerOnGround != 0
		mov esi, GAME_INSTANCE.ground.tilesHead
		mov edi, GAME_INSTANCE.ground.destroyablesHead
		mov ebx, GAME_INSTANCE.ground.bulletsHead
	.else
		mov esi, GAME_INSTANCE.underground.tilesHead
		mov edi, GAME_INSTANCE.underground.destroyablesHead
		mov ebx, GAME_INSTANCE.underground.bulletsHead
	.endif

	.while esi != nullptr
		invoke renderGameObject, (ListNode ptr [esi]).value, canvas
		mov esi, (ListNode ptr [esi]).next
	.endw

	.while edi != nullptr
		invoke renderGameObject, (ListNode ptr [edi]).value, canvas
		mov edi, (ListNode ptr [edi]).next
	.endw

	.while ebx != nullptr
		invoke renderGameObject, (ListNode ptr [ebx]).value, canvas
		mov ebx, (ListNode ptr [ebx]).next
	.endw
	ret
renderGameObjects endp

renderGameObject proc uses eax ebx edx esi, obj: dword, canvas: PaintDevice
	local   actualX:sdword,
			actualY:sdword,
			objW:sdword,
			objH:sdword

	mov esi, obj
	mov eax, (GameObject ptr [obj]).posX
	mov ebx, (GameObject ptr [obj]).posY
	mov esi, GAME_INSTANCE.player
	sub eax, (GameObject ptr [obj]).posX
	sub ebx, (GameObject ptr [obj]).posY
	add eax, 640
	sub eax, 32
	add ebx, 384
	sub ebx, 32
	mov actualX, eax
	mov actualY, ebx

	mov esi, obj
	mov esi, (GameObject ptr [obj]).def
	mov eax, (GameObjectDef ptr [esi])._width
	mov ebx, (GameObjectDef ptr [esi]).__height
	mov objW, eax
	mov objH, ebx

	.if (actualX < -64) || (actualY < -64) || (actualX) > 1344 || (actualY) > 832
		ret
	.endif

	invoke CreateCompatibleDC, canvas
	mov ebx, eax
	mov eax, obj
	mov eax, (GameObject ptr [eax]).currentFrame
	mov edx, sizeof Bitmap
	mul edx
	mov esi, (GameObjectDef ptr [esi]).frames
	add esi, eax
	invoke SelectObject, ebx, Bitmap ptr [esi]
	mov esi, offset ftn
	invoke AlphaBlend, canvas, actualX, actualY, objW, objH, ebx, 0, 0, objW, objH, dword ptr [esi]
	invoke DeleteDC, ebx
	ret
renderGameObject endp

gameLogic proc uses eax edx esi edi
	local   temp:dword
	mov eax, GAME_INSTANCE.globalTick
	inc eax
	mov GAME_INSTANCE.globalTick, eax

	mov esi, GAME_INSTANCE.player
	mov eax, (Player ptr [esi]).hp
	.if eax <= 0
		invoke PostQuitMessage, 0
		ret
	.endif

	mov esi, GAME_INSTANCE.towers
	mov edi, dword ptr [esi]
	mov eax, (Tower ptr [edi]).hp
	.if eax <= 0
		invoke PostQuitMessage, 0
		ret
	.endif
	add esi, sizeof dword
	mov edi, dword ptr [esi]
	mov eax, (Tower ptr [edi]).hp
	.if eax <= 0
		invoke PostQuitMessage, 0
		ret
	.endif
	add esi, sizeof dword
	mov edi, dword ptr [esi]
	mov eax, (Tower ptr [edi]).hp
	.if eax <= 0
		invoke PostQuitMessage, 0
		ret
	.endif
	add esi, sizeof dword
	mov edi, dword ptr [esi]
	mov eax, (Tower ptr [edi]).hp
	.if eax <= 0
		invoke PostQuitMessage, 0
		ret
	.endif

	invoke mapLogic, addr GAME_INSTANCE.ground
	invoke mapLogic, addr GAME_INSTANCE.underground

	invoke playerLogic

	mov esi, GAME_INSTANCE.towers
	invoke towerLogic, dword ptr [esi]
	add esi, sizeof dword
	invoke towerLogic, dword ptr [esi]
	add esi, sizeof dword
	invoke towerLogic, dword ptr [esi]
	add esi, sizeof dword
	invoke towerLogic, dword ptr [esi]

	mov temp, 180
	mov eax, GAME_INSTANCE.globalTick
	mov edx, 0
	div temp
	.if edx == 0
		invoke genEnemy
	.endif

	ret
gameLogic endp

mapLogic proc uses eax ebx esi edi, map: dword
	local   currentTile:List,
			currentDestroyable:List,
			currentBullet:List,
			temp:List

	mov esi, map
	mov eax, (Map ptr [esi]).tilesHead
	mov currentTile, eax
	mov eax, (Map ptr [esi]).destroyablesHead
	mov currentDestroyable, eax
	mov eax, (Map ptr [esi]).bulletsHead
	mov currentBullet, eax

	.while true
		.if currentBullet == nullptr
			jmp mapLogic_l1
		.endif
		mov esi, currentBullet
		mov esi, (ListNode ptr [esi]).value
		mov al, (GameObject ptr [esi]).toBeDestroyed
		.if al == false
			jmp mapLogic_l1
		.endif

		mov esi, currentBullet
		mov edi, (ListNode ptr [esi]).next
		mov eax, (ListNode ptr [esi]).value
		mov currentBullet, edi
		delete esi
		delete eax
	.endw
mapLogic_l1:
	mov esi, map
	mov eax, currentBullet
	mov (Map ptr [esi]).bulletsHead, eax
	mov temp, eax
	.while temp != nullptr
		.while true
			mov esi, temp
			mov esi, (ListNode ptr [esi]).next
			.if esi == nullptr
				jmp mapLogic_l2
			.endif
			mov esi, (ListNode ptr [esi]).value
			mov al, (GameObject ptr [esi]).toBeDestroyed
			.if al == false
				jmp mapLogic_l2
			.endif

			mov esi, temp
			mov edi, (ListNode ptr [esi]).next
			mov eax, (ListNode ptr [esi]).value
			mov ebx, map
			mov ebx, (Map ptr [ebx]).bulletsEnd
			.if ebx == edi
				mov ebx, map
				mov (Map ptr [ebx]).bulletsEnd, edi
			.endif
			mov ebx, (ListNode ptr [edi]).next
			mov (ListNode ptr [esi]).next, ebx
			delete edi
			delete eax
		.endw
mapLogic_l2:
		mov esi, temp
		mov eax, (ListNode ptr [esi]).next
		mov temp, eax
	.endw

	.while true
		.if currentDestroyable == nullptr
			jmp mapLogic_l3
		.endif
		mov esi, currentDestroyable
		mov esi, (ListNode ptr [esi]).value
		mov al, (GameObject ptr [esi]).toBeDestroyed
		.if al == false
			jmp mapLogic_l3
		.endif

		mov esi, currentDestroyable
		mov edi, (ListNode ptr [esi]).next
		mov eax, (ListNode ptr [esi]).value
		mov currentDestroyable, edi
		delete esi
		delete eax
	.endw
mapLogic_l3:
	mov esi, map
	mov eax, currentDestroyable
	mov (Map ptr [esi]).destroyablesHead, eax
	mov temp, eax
	.while temp != nullptr
		.while true
			mov esi, temp
			mov esi, (ListNode ptr [esi]).next
			.if esi == nullptr
				jmp mapLogic_l4
			.endif
			mov esi, (ListNode ptr [esi]).value
			mov al, (GameObject ptr [esi]).toBeDestroyed
			.if al == false
				jmp mapLogic_l4
			.endif

			mov esi, temp
			mov edi, (ListNode ptr [esi]).next
			mov eax, (ListNode ptr [esi]).value
			mov ebx, map
			mov ebx, (Map ptr [ebx]).destroyablesEnd
			.if ebx == edi
				mov ebx, map
				mov (Map ptr [ebx]).destroyablesEnd, edi
			.endif
			mov ebx, (ListNode ptr [edi]).next
			mov (ListNode ptr [esi]).next, ebx
			delete edi
			delete eax
		.endw
mapLogic_l4:
		mov esi, temp
		mov eax, (ListNode ptr [esi]).next
		mov temp, eax
	.endw

	.while currentTile != nullptr
		mov esi, currentTile
		mov esi, (ListNode ptr [esi]).value
		mov eax, (GameObject ptr [esi]).tick
		inc eax
		mov (GameObject ptr [esi]).tick, eax
		mov esi, currentTile
		mov esi, (ListNode ptr [esi]).next
		mov currentTile, esi
	.endw

	.while currentDestroyable != nullptr
		mov esi, currentDestroyable
		mov esi, (ListNode ptr [esi]).value
		mov eax, (GameObject ptr [esi]).tick
		inc eax
		mov (GameObject ptr [esi]).tick, eax
		mov edi, (GameObject ptr [esi]).def
		mov edi, (GameObjectDef ptr [edi]).id
		.if edi == objDefList.enemy.id
			invoke enemyLogic, esi
		.elseif edi == objDefList.coin.id
			invoke coinLogic, esi
		.endif
		mov esi, currentDestroyable
		mov esi, (ListNode ptr [esi]).next
		mov currentDestroyable, esi
	.endw

	.while currentBullet != nullptr
		mov esi, currentBullet
		mov esi, (ListNode ptr [esi]).value
		mov eax, (GameObject ptr [esi]).tick
		inc eax
		mov (GameObject ptr [esi]).tick, eax
		mov eax, map
		mov ebx, offset GAME_INSTANCE.ground
		.if eax == ebx
			mov eax, 0
		.else
			mov eax, 1
		.endif
		invoke bulletLogic, eax, esi
		mov esi, currentBullet
		mov esi, (ListNode ptr [esi]).next
		mov currentBullet, esi
	.endw
	ret
mapLogic endp

end
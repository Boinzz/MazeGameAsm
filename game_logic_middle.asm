include game_logic_middle.inc
include game_logic_base.inc

new macro type
	invoke HeapAlloc, processHeap, HEAP_ZERO_MEMORY, sizeof type
endm

.data
	processHeap dword ?

.code
loadGame PROC uses esi
	.data
	lG_tempBmp Bitmap ?
	lG_playerDef Pointer ?
	lG_tempPtr Pointer ?
	lG_testFileName String "testPlayer.bmp", 0

	.code
	invoke loadBitmap, offset lG_testFileName, 64, 64
	mov lG_tempBmp, eax
	invoke GetProcessHeap
	mov processHeap, eax
	new GameObjectDef
	mov lG_playerDef, eax
	mov esi, eax
	mov eax, 1
	mov (GameObjectDef ptr [esi]).frameCount, eax
	new Bitmap
	mov esi, lG_playerDef
	mov (GameObjectDef ptr [esi]).frames, eax
	mov esi, eax
	mov eax, lG_tempBmp
	mov Bitmap ptr [esi], eax
	new Player
	mov GAME_INSTANCE.player, eax
	mov esi, eax
	mov eax, lG_playerDef
	mov (GameObject ptr [esi]).objDef, eax
	mov (GameObject ptr [esi]).currentFrame, 0
	new ListNode
	mov GAME_INSTANCE.ground.destroyables, eax
	mov esi, eax
	mov eax, GAME_INSTANCE.player
	mov (ListNode ptr [esi]).value, eax
	mov GAME_INSTANCE.playerOnGround, 1
	mov eax, 0
	ret
loadGame ENDP

renderGameObjects PROC uses ecx esi,
	rGOs_canvas: PaintDevice
	.data
	rGOs_currentTile List ?
	rGOs_currentDestroyable List ?
	rGOs_currentBullet List ?
	.code
	mov cl, GAME_INSTANCE.playerOnGround
	.IF cl != 0
		mov eax, GAME_INSTANCE.ground.tiles
		mov rGOs_currentTile, eax
		mov eax, GAME_INSTANCE.ground.destroyables
		mov rGOs_currentDestroyable, eax
		mov eax, GAME_INSTANCE.ground.bullets
		mov rGOs_currentBullet, eax
	.ELSE
		mov eax, GAME_INSTANCE.underground.tiles
		mov rGOs_currentTile, eax
		mov eax, GAME_INSTANCE.underground.destroyables
		mov rGOs_currentDestroyable, eax
		mov eax, GAME_INSTANCE.underground.bullets
		mov rGOs_currentBullet, eax
	.ENDIF
	rGOs_renderTiles:
		mov esi, rGOs_currentTile
		.IF esi != NULL
			invoke renderGameObject, (ListNode ptr [esi]).value, rGOs_canvas
			mov esi, (ListNode ptr [esi]).next
		.ELSE
			jmp rGOs_renderTiles
		.ENDIF
	rGOs_renderDestroyables:
		mov esi, rGOs_currentDestroyable
		.IF esi != NULL
			invoke renderGameObject, (ListNode ptr [esi]).value, rGOs_canvas
			mov esi, (ListNode ptr [esi]).next
		.ELSE
			jmp rGOs_renderDestroyables
		.ENDIF
	rGOs_renderBullets:
		mov esi, rGOs_currentBullet
		.IF esi != NULL
			invoke renderGameObject, (ListNode ptr [esi]).value, rGOs_canvas
			mov esi, (ListNode ptr [esi]).next
		.ELSE
			jmp rGOs_renderBullets
		.ENDIF

		mov eax, 0
		ret
renderGameObjects ENDP

renderGameObject PROC uses esi,
	rGO_obj: Pointer, rGO_canvas: PaintDevice
	.data
	rGO_actualX sdword ?
	rGO_actualY sdword ?
	rGO_bmpCanvas PaintDevice ?
	rGO_frame Bitmap ?
	.code
	mov esi, rGO_obj
	mov eax, (GameObject ptr [esi]).posX
	mov esi, GAME_INSTANCE.player
	sub	eax, (GameObject ptr [esi]).posX
	add eax, 640
	sub eax, 32
	mov rGO_actualX, eax

	.IF eax < -64
		jmp rGO_end
	.ELSEIF eax > 1344
		jmp rGO_end
	.ENDIF

	mov esi, rGO_obj
	mov eax, (GameObject ptr [esi]).posY
	mov esi, GAME_INSTANCE.player
	sub	eax, (GameObject ptr [esi]).posY
	add eax, 640
	sub eax, 32
	mov rGO_actualY, eax

	.IF eax < -64
		jmp rGO_end
	.ELSEIF eax > 832
		jmp rGO_end
	.ENDIF

	invoke CreateCompatibleDC, rGO_canvas
	mov rGO_bmpCanvas, eax
	mov esi, rGO_obj
	mov eax, (GameObject ptr [esi]).currentFrame
	mov ebx, sizeof Bitmap
	mul ebx
	mov esi, (GameObject ptr [esi]).objDef
	mov esi, (GameObjectDef ptr [esi]).frames
	add esi, eax
	mov eax, Bitmap ptr [esi]
	mov rGO_frame, eax
	invoke SelectObject, rGO_bmpCanvas, rGO_frame
	invoke BitBlt, rGO_canvas, rGO_actualX, rGO_actualY, 64, 64, rGO_bmpCanvas, 0, 0, SRCCOPY
	invoke DeleteDC, rGO_bmpCanvas
	ret

	rGO_end:
		ret
renderGameObject ENDP

end
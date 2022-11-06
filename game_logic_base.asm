__GAME_LOGIC_BASE_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include game_logic_base.inc
include game_logic_middle.inc
include game_logic_top.inc

WINDOW_WIDTH textequ <1280>
WINDOW_HEIGHT textequ <768>

.data
controller Controller <>
instance Instance ?
COINS_TEXT_RECT RECT <10,678,170,758>
COINS_NUM_RECT RECT <170,678,330,758>
SCORES_TEXT_RECT RECT <950,678,1110,758>
SCORES_NUM_RECT RECT <1110,678,1270,758>
COINS_TEXT byte "Coins:", 0
coinsValue byte 32 dup(?)
SCORES_TEXT byte "Scores:", 0
scoresValue byte 32 dup(?)
WHOLE_RECT RECT <0,0,WINDOW_WIDTH,WINDOW_HEIGHT>
public controller

.code
onMain proc uses eax, hInstance: Instance
	mov eax, hInstance
	mov instance, eax
	ret
onMain endp

onWindowCreate proc uses eax, window: Window
	invoke loadGame
	invoke SetTimer, window, 1, 16, NULL
	ret
onWindowCreate endp

onTimer proc uses eax, window: Window
	invoke gameLogic
	invoke InvalidateRect, window, addr WHOLE_RECT, true
	ret
onTimer endp

onPaint proc uses eax ebx ecx, window: Window, device: PaintDevice
	invoke CreateCompatibleDC, device
	mov ebx, eax
	invoke CreateCompatibleBitmap, device, WINDOW_WIDTH, WINDOW_HEIGHT
	mov ecx, eax
	invoke SelectObject, ebx, eax
	invoke CreateSolidBrush, 0f0b080h
	invoke FillRect, ebx, addr WHOLE_RECT, eax
	invoke renderGameObjects, ebx
	invoke paintText, ebx
	invoke BitBlt, device, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, ebx, 0, 0, SRCCOPY
	invoke DeleteDC, ebx
	invoke DeleteObject, ecx
	ret
onPaint endp

loadBitmap proc, fileName: String, _width: sdword, __height: sdword
	mov eax, LR_LOADFROMFILE
	or eax, LR_CREATEDIBSECTION
	invoke LoadImage, instance, fileName, IMAGE_BITMAP, _width, __height, eax
	ret
loadBitmap endp

unloadBitmap proc uses eax, bitmap: Bitmap
	invoke DeleteObject, bitmap
	ret
unloadBitmap endp

onKeyDown proc uses eax, key: Key
	mov eax, key
	.if eax == "W"
		mov al, true
		mov controller.wDown, al
	.elseif eax == "A"
		mov al, true
		mov controller.aDown, al
	.elseif eax == "S"
		mov al, true
		mov controller.sDown, al
	.elseif eax == "D"
		mov al, true
		mov controller.dDown, al
	.endif
	ret
onKeyDown endp

onKeyUp proc, key: Key
	mov eax, key
	.if eax == "W"
		mov al, false
		mov controller.wDown, al
	.elseif eax == "A"
		mov al, false
		mov controller.aDown, al
	.elseif eax == "S"
		mov al, false
		mov controller.sDown, al
	.elseif eax == "D"
		mov al, false
		mov controller.dDown, al
	.endif
	ret
onKeyUp endp

onMouseDown proc uses eax, isLeft: _bool
	mov al, true
	.if isLeft != 0
		mov controller.leftDown, al
	.else
		mov controller.rightDown, al
	.endif
	ret
onMouseDown endp

onMouseUp proc uses eax, isLeft: _bool
	mov al, false
	.if isLeft != 0
		mov controller.leftDown, al
	.else
		mov controller.rightDown, al
		invoke upgradeLogic
	.endif
	ret
onMouseUp endp

onMouseMove proc uses eax, lParam: dword
	mov eax, lParam
	mov controller.mouseX, ax
	shr eax, 16
	mov controller.mouseY, ax
	ret
onMouseMove endp

paintText proc uses eax ecx esi edi, device: PaintDevice
	mov ecx, 0
	mov al, 0
	mov esi, offset coinsValue
	mov edi, offset scoresValue
	.while ecx < 32
		mov byte ptr [esi], al
		mov byte ptr [edi], al
		inc esi
		inc edi
		inc ecx
	.endw
	mov esi, GAME_INSTANCE.player
	invoke crt__itoa, (Player ptr [esi]).coins, offset coinsValue, 10
	invoke crt__itoa, GAME_INSTANCE.score, offset scoresValue, 10
	mov ecx, DT_BOTTOM
	or ecx, DT_LEFT
	invoke DrawText, device, ADDR COINS_TEXT, -1, addr COINS_TEXT_RECT, ecx
	invoke DrawText, device, ADDR coinsValue, -1, addr COINS_NUM_RECT, ecx
	invoke DrawText, device, ADDR SCORES_TEXT, -1, addr SCORES_TEXT_RECT, ecx
	invoke DrawText, device, ADDR scoresValue, -1, addr COINS_NUM_RECT, ecx
	ret
paintText endp

end
include game_logic_base.inc
include game_logic_middle.inc

TIMER_ID textequ <1>
FPS textequ <60>
SPF textequ <17>
WINDOW_WIDTH textequ <1280>
WINDOW_HEIGHT textequ <768>

.data
d_instance Instance ?

.code
onMain PROC,
	oM_instance: Instance
	mov eax, oM_instance
	mov d_instance, eax
	mov eax, 0
	ret
onMain ENDP

onWindowCreate PROC,
	oWC_window: Window
	invoke loadGame
	invoke SetTimer, oWC_window, TIMER_ID, SPF, NULL
	mov eax, 0
	ret
onWindowCreate ENDP

onTimer PROC,
	oT_window: Window
	.data
	oT_rect RECT <0,0,WINDOW_WIDTH,WINDOW_HEIGHT>
	.code
	invoke InvalidateRect, oT_window, offset oT_rect, 1
	mov eax, 0
	ret
onTimer ENDP

onPaint PROC,
	oP_window: Window, oP_device: PaintDevice
	.data
	oP_canvas PaintDevice ?
	oP_bmp Bitmap ?
	oP_rect RECT <0,0,WINDOW_WIDTH,WINDOW_HEIGHT>
	.code
	invoke CreateCompatibleDC, oP_device
	mov oP_canvas, eax
	invoke CreateCompatibleBitmap, oP_device, WINDOW_WIDTH, WINDOW_HEIGHT
	mov oP_bmp, eax
	invoke SelectObject, oP_canvas, oP_bmp
	invoke CreateSolidBrush, 808080h
	mov ebx, eax
	invoke FillRect, oP_canvas, offset oP_rect, ebx
	invoke renderGameObjects, oP_canvas
	invoke BitBlt, oP_device, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, oP_canvas, 0, 0, SRCCOPY
	invoke DeleteDC, oP_canvas
	mov eax, 0
	ret
onPaint ENDP

loadBitmap PROC,
	lB_fileName: Pointer, lB_width: sdword, lB_height: sdword
	invoke LoadImage, d_instance, lB_fileName, IMAGE_BITMAP, lB_width, lB_height, LR_LOADFROMFILE
	ret
loadBitmap ENDP

unloadBitmap PROC,
	uB_bitmap: Bitmap
	invoke DeleteObject, uB_bitmap
	ret
unloadBitmap ENDP

end
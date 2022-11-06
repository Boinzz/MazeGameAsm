ifndef __GAME_LOGIC_BASE_INC__
__GAME_LOGIC_BASE_INC__ macro
endm

include windef.inc

Controller struct
	wDown _bool ?
	aDown _bool ?
	sDown _bool ?
	dDown _bool ?
	leftDown _bool ?
	rightDown _bool ?
	mouseX word ?
	mouseY word ?
Controller ends

onMain proto, hInstance: Instance
onWindowCreate proto, window: Window
onTimer proto, window: Window
onPaint proto, window: Window, device: PaintDevice
loadBitmap proto, fileName: String, _width: sdword, __height: sdword
unloadBitmap proto, bitmap: Bitmap
onKeyDown proto, key: Key
onKeyUp proto, key: Key
onMouseDown proto, isLeft: _bool
onMouseUp proto, isLeft: _bool
onMouseMove proto, lParam: dword
paintText proto, device: PaintDevice

ifndef __GAME_LOGIC_BASE_ASM__
.data
extern controller:Controller
endif

endif
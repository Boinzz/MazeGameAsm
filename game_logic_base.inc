ifndef __GAME_LOGIC_BASE_INC__
__GAME_LOGIC_BASE_INCLL macro
endm

include windef.inc

onMain proto,
	oM_instance: Instance

onWindowCreate proto,
	oWC_window: Window

onTimer proto,
	oT_window: Window

onPaint proto,
	oP_window: Window, oP_device: PaintDevice

loadBitmap proto,
	lB_fileName: Pointer, lB_width: sdword, lB_height: sdword

unloadBitmap proto,
	uB_bitmap: Bitmap

endif
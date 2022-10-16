ifndef __GAME_LOGIC_MIDDLE_INC__
__GAME_LOGIC_MIDDLE_INC__ macro
endm

include game_objects.inc

loadGame proto

renderGameObjects proto,
	rGOs_canvas: PaintDevice

renderGameObject proto,
	rGO_obj: Pointer, rGO_canvas: PaintDevice

endif
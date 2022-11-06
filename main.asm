__MAIN_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include windef.inc
include game_logic_base.inc

WindowProc proto, window: dword, uMsg: dword, wParam: dword, lParam: dword

.data
CLASS_NAME byte "MazeGame", 0
WINDOW_TITLE byte "Maze Game", 0
WC WNDCLASS <>

.code
WinMain proc
	local   hInstance: dword, 
	        window: dword,
			msg: MSG

	invoke crt_time, 0
	invoke crt_srand, eax

	invoke GetModuleHandle, null
	mov hInstance, eax
	invoke onMain, hInstance

	mov eax, WindowProc
	mov WC.lpfnWndProc, eax
	mov eax, hInstance
	mov WC.hInstance, eax
	mov eax, offset CLASS_NAME
	mov WC.lpszClassName, eax
	invoke RegisterClass, addr WC

	invoke CreateWindowEx, 
		0,
		offset CLASS_NAME, 
		offset WINDOW_TITLE,
		WS_OVERLAPPEDWINDOW,
		20, 20, 1280, 768,
		NULL,
		NULL,
		hInstance,
		NULL
	mov window, eax

	.if eax == NULL
		ret
	.endif

	invoke ShowWindow, window, SW_SHOW


	.while 1
		invoke GetMessage, addr msg, NULL, 0, 0
		.if eax <= 0
			return 0
		.endif
		invoke TranslateMessage, addr msg
		invoke DispatchMessage, addr msg
	.endw
WinMain endp

WindowProc proc,
	window: dword, uMsg: dword, wParam: dword, lParam: dword
	local   ps: PAINTSTRUCT,
	        hdc: PaintDevice
	mov eax, uMsg
	.if eax == WM_CREATE
		invoke onWindowCreate, window
		jmp wp_default
	.elseif	eax == WM_TIMER
		invoke onTimer, window
		jmp wp_default
	.elseif eax == WM_DESTROY
		invoke PostQuitMessage, 0
		return 0
	.elseif eax == WM_KEYDOWN
		invoke onKeyDown, wParam
		return 0
	.elseif eax == WM_KEYUP
		invoke onKeyUp, wParam
		return 0
	.elseif eax == WM_LBUTTONDOWN
		invoke onMouseDown, true
		return 0
	.elseif eax == WM_LBUTTONUP
		invoke onMouseUp, true
		return 0
	.elseif eax == WM_RBUTTONDOWN
		invoke onMouseDown, false
		return 0
	.elseif eax == WM_RBUTTONUP
		invoke onMouseUp, false
		return 0
	.elseif eax == WM_MOUSEMOVE
		invoke onMouseMove, lParam
		return 0
	.elseif eax == WM_PAINT
		invoke BeginPaint, window, addr ps
		mov hdc, eax
		invoke onPaint, window, hdc
		invoke EndPaint, window, addr hdc
		return 0
	.endif

wp_default:
	invoke DefWindowProc, window, uMsg, wParam, lParam
	ret
WindowProc endp

end WinMain
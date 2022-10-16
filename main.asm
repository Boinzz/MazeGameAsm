include windef.inc
include game_logic_base.inc

WindowProc proto,
	wp_hwnd: DWORD, wp_uMsg: DWORD, wp_wParam: DWORD, wp_lParam: DWORD

ErrorHandler proto

.data
	className byte "MazeGame", 0
	windowTitle byte "Maze Game", 0
	errorTitle byte "Error", 0
	
	hInstance DWORD ?
	wc WNDCLASS <>
	wm_hwnd DWORD ?
	wm_msg MSG <>

.code
WinMain PROC
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	mov wc.hInstance, eax

	mov eax, WindowProc
	mov wc.lpfnWndProc, eax
	mov eax, offset className
	mov wc.lpszClassName, eax

	invoke onMain, hInstance

	invoke RegisterClass, offset wc

	.IF eax == NULL
		invoke ErrorHandler
		jmp wm_end
	.ENDIF

	invoke CreateWindowEx,\
		0,\
		offset className,\
		offset windowTitle,\
		WS_OVERLAPPEDWINDOW,\
		20, 20, 1280, 768,\
		NULL, NULL, hInstance, NULL

	.IF eax == NULL
		invoke ErrorHandler
		jmp wm_end
	.ENDIF

	mov wm_hwnd, eax

	invoke ShowWindow, wm_hwnd, SW_SHOW

	wm_messageLoop:
		invoke GetMessage, offset wm_msg, NULL, 0, 0
		.IF eax > 0
			invoke TranslateMessage, offset wm_msg
			invoke DispatchMessage, offset wm_msg
			jmp wm_messageLoop
		.ENDIF

	wm_end:
		mov eax, 0
		ret
WinMain ENDP

WindowProc PROC,
	wp_hwnd: DWORD, wp_uMsg: DWORD, wp_wParam: DWORD, wp_lParam: DWORD
	.data
	wp_ps PAINTSTRUCT <>
	wp_hdc HDC ?
	.code
	mov eax, wp_uMsg
	.IF eax == WM_CREATE
		invoke onWindowCreate, wp_hwnd
	.ELSEIF eax == WM_TIMER
		invoke onTimer, wp_hwnd
	.ELSEIF eax == WM_DESTROY
		invoke PostQuitMessage, 0
		mov eax, 0
		jmp wp_end
	.ELSEIF eax == WM_PAINT
		invoke BeginPaint, wp_hwnd, offset wp_ps
		mov wp_hdc, eax
		invoke onPaint, wp_hwnd, wp_hdc
		invoke EndPaint, wp_hwnd, offset wp_ps
	.ELSE
		invoke DefWindowProc, wp_hwnd, wp_uMsg, wp_wParam, wp_lParam
	.ENDIF
	wp_end:
		ret
WindowProc ENDP


ErrorHandler PROC
.data
eh_errorMsg DWORD ?
messageID DWORD ?
.code
	invoke GetLastError
	mov messageID, eax

	invoke FormatMessage, FORMAT_MESSAGE_ALLOCATE_BUFFER + \
	  FORMAT_MESSAGE_FROM_SYSTEM,NULL,messageID,NULL,
	  ADDR eh_errorMsg,NULL,NULL

	invoke MessageBox,NULL, eh_errorMsg, offset errorTitle,
	  MB_ICONERROR+MB_OK

	invoke LocalFree, eh_errorMsg
	ret
ErrorHandler ENDP

END WinMain
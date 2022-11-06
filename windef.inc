ifndef __WINDEF_INC__
__WINDEF_INC__ macro
endm

include         windows.inc
include         gdi32.inc
includelib      gdi32.lib
include         user32.inc
includelib      user32.lib
include         kernel32.inc
includelib      kernel32.lib
include         masm32.inc
includelib      masm32.lib
include         msvcrt.inc
includelib      msvcrt.lib
include         shell32.inc
includelib      shell32.lib
include         msimg32.inc
includelib      msimg32.lib

Window textequ <HWND>
PaintDevice textequ <HDC>
Instance textequ <DWORD>
Bitmap textequ <DWORD>
String textequ <LPCTSTR>
Key textequ <DWORD>
null textequ <NULL>
nullptr textequ <NULL>

new macro objType:REQ, objCount:=<1>
	push edx
	push ecx
	mov eax, sizeof objType
	mov ecx, objCount
	mul ecx
	mov edx, eax
	invoke GetProcessHeap
	invoke HeapAlloc, eax, HEAP_ZERO_MEMORY, edx
	pop ecx
	pop edx
endm

delete macro obj:REQ
	invoke GetProcessHeap
	invoke HeapFree, eax, 0, obj
endm

return macro num:=<eax>
	mov eax, num
	ret
endm

_bool textequ <byte>
true textequ <1>
false textequ <0>

endif
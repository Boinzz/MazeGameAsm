ifndef __WINDEF_INC__
__WINDEF_INC__ macro
endm

.386
.model flat, stdcall
option casemap:none

include windows.inc
include gdi32.inc
includelib gdi32.lib
include user32.inc
includelib user32.lib
include kernel32.inc
includelib kernel32.lib
include masm32.inc
includelib masm32.lib
include msvcrt.inc
includelib msvcrt.lib
include shell32.inc
includelib shell32.lib

Window textequ <DWORD>
PaintDevice textequ <DWORD>
Instance textequ <DWORD>
Bitmap textequ <DWORD>
String textequ <BYTE>
Pointer textequ <DWORD>

endif
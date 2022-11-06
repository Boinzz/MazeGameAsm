__GAME_OBJECTS_ASM__ macro
endm

.386
.model flat, stdcall
option casemap: none

include game_objects.inc

.data
GAME_INSTANCE Game <>
public GAME_INSTANCE
end
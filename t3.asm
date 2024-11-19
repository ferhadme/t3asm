;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (c) 2024, Farhad Mehdizada (@ferhadme) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; A lightweight, terminal-based implementation of the classic Tic Tac Toe game written in Netwide Assembler

section .data
  board_len: equ 9
  p_turn_msg_len: equ 15
  row: db '-'
  col: db '|'
  p_turn_msg_prefix: db 'Player '
  p_turn_msg_prefix_len: equ 7
  p_turn_msg_suffix: db ' turn:', 10
  p_turn_msg_suffix_len: equ 7
  px: db 'X'
  py: db 'Y'

section .bss
  p_turn resb 1
  board resb board_len
  p_turn_msg resb p_turn_msg_len

section .text
global _start
_start:

  mov al, [px]

change_turn:
  mov [p_turn], al

print_turn:

  mov rsi, p_turn_msg_prefix
  mov rdi, p_turn_msg
  mov rcx, p_turn_msg_prefix_len
  rep movsb

  mov al, [p_turn]
  mov [p_turn_msg + p_turn_msg_prefix_len], al

  mov rsi, p_turn_msg_suffix
  mov rdi, p_turn_msg + p_turn_msg_prefix_len + 1
  mov rcx, p_turn_msg_suffix_len
  rep movsb

  mov rax, 0x01
  mov rdi, 0x00
  mov rsi, p_turn_msg
  mov rdx, p_turn_msg_len
  syscall

exit:
  mov rax, 0x3c
  mov rdi, 0
  syscall

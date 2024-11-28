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

  board_templ_row_len: equ 6
  board_templ_col_len: equ 7 ; 7 + 1(\n)
  board_templ_len: equ 8 * 6

section .bss
  p_turn resb 1

  ; -------\n
  ; |X|X|X|\n
  ; -------\n
  ; |X|X|X|\n
  ; -------\n
  ; |X|X|X|\n
  ; -------\n
  board_templ resb board_templ_len
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

print_board_templ: ;; 0 .. 3
  mov rdi, board_templ
  mov rcx, 0
print_row: ;; 0 .. 6
  mov r8, 0
print_bars:
  mov al, [row]
  mov [rdi + r8], al
  inc r8
  cmp r8, board_templ_col_len
  jl print_bars
  mov al, 10
  mov [rdi + r8], al
print_templ:
  add rdi, board_templ_col_len
  inc rdi ; +1(\n)
  inc rcx
  cmp rcx, 3
  jl print_row
  mov rax, 0x01
  mov rdi, 0x00
  mov rsi, board_templ
  mov rdx, board_templ_len
  syscall

check_winner:

exit:
  mov rax, 0x3c
  mov rdi, 0
  syscall

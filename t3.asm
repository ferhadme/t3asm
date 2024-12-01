;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (c) 2024, Farhad Mehdizada (@ferhadme) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; A lightweight, terminal-based implementation of the classic Tic Tac Toe game written in Netwide Assembler

section .data
  board_len: equ 9

  bar: db '-'
  sep: db '|'

  p_turn_msg_len: equ 15
  p_turn_msg_prefix: db 'Player '
  p_turn_msg_prefix_len: equ 7
  p_turn_msg_suffix: db ' turn:', 10
  p_turn_msg_suffix_len: equ 7

  px: db 'X'
  py: db 'Y'

  out_row_len: equ 6 ; +1(tail)
  out_col_len: equ 7 ; +1(\n)
  board_out_len: equ 7 * 8

section .bss
  p_turn resb 1

  ; 01234567
  ; -------\n 0
  ; |X|X|X|\n 1
  ; -------\n 2
  ; |X|X|X|\n 3
  ; -------\n 4
  ; |X|X|X|\n 5
  ; -------\n 6
  board_templ resb board_out_len
  board resb board_len
  p_turn_msg resb p_turn_msg_len

section .text
global _start
_start:
  mov rcx, 0
  mov rdi, board
init_game:
  mov al, 32
  mov [rdi], al
  inc rdi
  inc rcx
  cmp rcx, board_len
  jl init_game

change_turn:
  mov al, [px]
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


print_game: ; 0..3
  mov rsi, board
  mov rdi, board_templ
  mov rcx, 0
print_row:
  mov r8, 0
print_bars:
  mov al, [bar]
  mov [rdi], al
  inc rdi
  inc r8
  cmp r8, out_col_len
  jl print_bars
  mov al, 10
  mov [rdi], al
  inc rdi
print_data:
  mov r9, 0
print_sep_and_data:
  mov al, [sep]
  mov [rdi], al
  inc rdi
  mov al, [board + r9]
  mov [rdi], al
  inc rdi
  inc r9
  cmp r9, 3
  je print_sep_and_data_end
  jmp print_sep_and_data
print_sep_and_data_end:
  mov al, [sep]
  mov [rdi], al
  inc rdi
  mov al, 10
  mov [rdi], al
  inc rdi

  inc rcx
  cmp rcx, 3
  jl print_row

  mov r8, 0
print_tail_bar:
  mov al, [bar]
  mov [rdi], al
  inc rdi
  inc r8
  cmp r8, out_col_len
  jl print_tail_bar
  mov al, 10
  mov [rdi], al
  inc rdi
stdout:
  mov rax, 0x01
  mov rdi, 0x00
  mov rsi, board_templ
  mov rdx, board_out_len
  syscall

game_stdin:


check_winner:

exit:
  mov rax, 0x3c
  mov rdi, 0
  syscall

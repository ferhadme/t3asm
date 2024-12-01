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

  wrong_coords_fatal_msg: db 'Bad coordinates. Input in following format: [0..2] [0..2]', 10, 10
  wrong_coords_fatal_msg_len: equ 59

  px: db 'X'
  py: db 'Y'

  user_inp_len: equ 3

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

  user_inp resb user_inp_len

section .text
global _start
_start:
  mov rcx, 0
  mov rsi, board
init_game:
  mov al, 32
  mov [rsi], al
  inc rsi
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
  mov rdi, board
  mov rsi, board_templ
  mov rcx, 0
print_row:
  mov r8, 0
print_bars:
  mov al, [bar]
  mov [rsi], al
  inc rsi
  inc r8
  cmp r8, out_col_len
  jl print_bars
  mov al, 10
  mov [rsi], al
  inc rsi
print_data:
  mov r9, 0
print_sep_and_data:
  mov al, [sep]
  mov [rsi], al
  inc rsi
  mov al, [board + r9]
  mov [rsi], al
  inc rsi
  inc r9
  cmp r9, 3
  je print_sep_and_data_end
  jmp print_sep_and_data
print_sep_and_data_end:
  mov al, [sep]
  mov [rsi], al
  inc rsi
  mov al, 10
  mov [rsi], al
  inc rsi

  inc rcx
  cmp rcx, 3
  jl print_row

  mov r8, 0
print_tail_bar:
  mov al, [bar]
  mov [rsi], al
  inc rsi
  inc r8
  cmp r8, out_col_len
  jl print_tail_bar
  mov al, 10
  mov [rsi], al
  inc rsi
stdout:
  mov rax, 0x01
  mov rdi, 0x00
  mov rsi, board_templ
  mov rdx, board_out_len
  syscall

game_stdin:
  mov rax, 0x00
  mov rdi, 0
  mov rsi, user_inp
  mov rdx, user_inp_len
  syscall

  ; eax = row, ebx = col
  mov eax, [user_inp]
  mov ebx, [user_inp + 2]
validate_input:
  cmp eax, 0
  jl fatal_input
  cmp eax, 2
  jg fatal_input
  cmp ebx, 0
  jl fatal_input
  cmp ebx, 2
  jg fatal_input
fatal_input:
  mov rax, 0x01
  mov rdi, 1
  mov rsi, wrong_coords_fatal_msg
  mov rdx, wrong_coords_fatal_msg_len
  syscall
  jmp print_turn

check_winner:

exit:
  mov rax, 0x3c
  mov rdi, 0
  syscall

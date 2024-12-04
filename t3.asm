;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (c) 2024, Farhad Mehdizada (@ferhadme) ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; A lightweight, terminal-based implementation of the classic Tic Tac Toe game written in 64-bit Netwide Assembler

section .data
  board_len: equ 9

  bar: db '-'
  sep: db '|'

  p_turn_msg_len: equ 15
  p_turn_msg_prefix: db 'Player '
  p_turn_msg_prefix_len: equ 7
  p_turn_msg_suffix: db ' turn:', 10
  p_turn_msg_suffix_len: equ 7

  p_won_msg_suffix: db ' won!', 10
  p_won_msg_suffix_len: equ 6
  p_won_msg_len: equ 7

  wrong_coords_fatal_msg: db 'Bad coordinates. Input in following format: [0..2] [0..2]', 10, 10
  wrong_coords_fatal_msg_len: equ 59

  px: db 'X'
  py: db 'Y'

  user_inp_len: equ 100

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
  p_won_msg resb p_won_msg_len

  user_inp resb user_inp_len

  is_game_finished resb 1

section .text
global _start
_start:
  mov rcx, 0
  mov rsi, board
  mov al, 'X'
  mov [p_turn], al

init_board:
  mov al, 32
  mov [rsi], al
  inc rsi
  inc rcx
  cmp rcx, board_len
  jl init_board

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
  mov al, [rdi]
  inc rdi
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

  mov al, [is_game_finished]
  cmp al, 1
  je winner

game_stdin:
  mov rax, 0x00
  mov rdi, 0
  mov rsi, user_inp
  mov rdx, user_inp_len
  syscall

  ; al = row, bl = col
  mov al, [user_inp]
  mov bl, [user_inp + 2]
  sub al, '0'
  sub bl, '0'

validate_input:
  cmp al, 0
  jl fatal_input
  cmp al, 2
  jg fatal_input
  cmp bl, 0
  jl fatal_input
  cmp bl, 2
  jg fatal_input

board_update:

  ; board_coord = al * 3 + bl
  mov rcx, 3
  mul rcx; rax
  add rax, rbx

  mov rdi, board
  add rdi, rax
  mov al, [p_turn]
  mov [rdi], al

check_winner:
  ; horizontal scan
  call hor_linear_scan
  cmp rax, 1
  je completed_board

  ; vertical scan
  call ver_linear_scan
  cmp rax, 1
  je completed_board

  ; diagonal scan
  call diagonal_scan
  cmp rax, 1
  je completed_board

  mov al, [p_turn]
  cmp al, 'X'
  je y_turn
  cmp al, 'Y'
  je x_turn

x_turn:
  mov al, 'X'
  mov [p_turn], al
  jmp print_game
y_turn:
  mov al, 'Y'
  mov [p_turn], al
  jmp print_game

completed_board:
  mov rdi, is_game_finished
  mov al, 1
  mov [rdi], al
  jmp print_game

winner:
  mov al, [p_turn]
  mov [p_won_msg], al

  mov rsi, p_won_msg_suffix
  mov rdi, p_won_msg + 1
  mov rcx, p_won_msg_suffix_len
  rep movsb

  mov rax, 0x01
  mov rdi, 0x00
  mov rsi, p_won_msg
  mov rdx, p_won_msg_len
  syscall

exit:
  mov rdi, 0
  mov rax, 0x3c
  syscall

fatal_input:
  mov rax, 0x01
  mov rdi, 1
  mov rsi, wrong_coords_fatal_msg
  mov rdx, wrong_coords_fatal_msg_len
  syscall
  jmp print_turn

; function
; horizontal linear scan
; rax: 1 if [p_turn] wins, otherwise 0
;   0 1 2
;   3 4 5
;   6 7 8
hor_linear_scan:
  mov rcx, 0
hscan_start:
  cmp rcx, 6
  jg hscan_fail
  mov rsi, board
  add rsi, rcx
  mov dl, [rsi]

  mov r8, 1
hscan_iter:
  cmp r8, 3
  je hscan_success

  mov rsi, board
  add rsi, rcx
  add rsi, r8
  mov al, [rsi]

  cmp al, 32
  je hscan_line_end

  cmp al, dl
  jne hscan_line_end
  inc r8
  jmp hscan_iter
hscan_line_end:
  add rcx, 3
  jmp hscan_start
hscan_fail:
  mov rax, 0
  ret
hscan_success:
  mov rax, 1
  ret

; function
; vertical linear scan
; rax: 1 if [p_turn] wins, otherwise 0
;   0 1 2
;   3 4 5
;   6 7 8
ver_linear_scan:
  mov rcx, 0
vscan_start:
  cmp rcx, 2
  jg vscan_fail
  mov rsi, board
  add rsi, rcx
  mov dl, [rsi]

  mov r8, 3
vscan_iter:
  cmp r8, 6
  jg vscan_success

  mov rsi, board
  add rsi, rcx
  add rsi, r8
  mov al, [rsi]

  cmp al, 32
  je vscan_line_end

  cmp al, dl
  jne vscan_line_end
  add r8, 3
  jmp vscan_iter
vscan_line_end:
  add rcx, 1
  jmp vscan_start
vscan_fail:
  mov rax, 0
  ret
vscan_success:
  mov rax, 1
  ret

; function
; diagonal scan
; rax: 1 if [p_turn] wins, otherwise 0
;   0 1 2
;   3 4 5
;   6 7 8
diagonal_scan:
  mov rcx, 0
  mov rsi, board
  add rsi, rcx
  mov dl, [rsi]
  mov r8, 4 ; +=4
dscan_1:
  cmp r8, 8
  jg dscan_success
  mov rsi, board
  add rsi, rcx
  add rsi, r8
  mov al, [rsi]

  cmp al, 32
  je dscan_continue

  cmp al, dl
  jne dscan_continue
  add r8, 4
  jmp dscan_1
dscan_continue:
  mov rcx, 2
  mov rsi, board
  add rsi, rcx
  mov dl, [rsi]
  mov r8, 2 ; +=2
dscan_2:
  cmp r8, 4
  jg dscan_success
  mov rsi, board
  add rsi, rcx
  add rsi, r8
  mov al, [rsi]

  cmp al, 32
  je dscan_fail

  cmp al, dl
  jne dscan_fail
  add r8, 2
  jmp dscan_2
dscan_fail:
  mov rax, 0
  ret
dscan_success:
  mov rax, 1
  ret

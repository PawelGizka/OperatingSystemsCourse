section .data
  SYS_EXIT	equ 60
  SYS_OPEN_FILE equ 2
  SYS_ERROR_EXIT	equ 1
  SYS_READ_FILE equ 0
  READ_ONLY_FLAG equ 0
  SYS_NORMAL_EXIT	equ 0
  BUFFER_SIZE equ 4096

section .bss
  buffer resb 4096 ;buffer for file read
  fd_in  resb 8 ;file descriptor number
  array  resb 2048 ;256 elements array
                  ;used for checking permutation correctness

section .text
	global	_start

_start:
	pop	rcx
	cmp	rcx, 2
	jne	error ;incorrect arguments

  ;reset table
  xor r9, r9
  xor r10, r10
zero_array:
  mov [array + r9], r10
  add r9, 8
  cmp r9, 2048
  jne zero_array

  pop rdi ;skip program name
  pop rdi ;set file to read
  mov rax, SYS_OPEN_FILE ;open file
  mov rsi, READ_ONLY_FLAG ;only to read
  syscall

  mov [fd_in], rax ;copy descriptor

  xor r8, r8 ;flag - load at least once incorrect file
  xor r9, r9 ;current value
  xor rbx, rbx ;flag - first permutation
  xor r12, r12 ;permutation
  xor r13, r13 ;length of first permutation
  xor r14, r14 ;lenght of current permutation

read_file:
  mov rax, SYS_READ_FILE ;read file
  mov rdi, [fd_in] ; set file descriptor
  mov rsi, buffer ; and buffer
  mov rdx, 4096 ; and buffer size
  syscall

  cmp rax, 0 ; 0 bytes read, end of file or file not exists
  je end

  mov r8, 1 ;ustaw pierwsze przeczytanie
  xor r10, r10 ;counter for buffer
  mov rsi, rax ;number of bytes read

loop_over:
  xor rax, rax
  mov al, byte [buffer + r10]
  mov r9, rax ;set current value

  cmp rbx, 0
  jne after_first_zero ;

  ;we have first permutation
  cmp r9, 0
  jne not_zero

  ;mamy obecnie 0
  mov rbx, 1 ;set flag - after first permutation
  mov r12, 2 ;set expected loop counter
  jmp continue_loop

not_zero:
  mov r15, [array + r9*8]
  cmp r15, 1 ;same value again
  je error

  mov r15, 1
  mov [array + r9*8], r15
  inc r13 ;increase length of first permutation
  jmp continue_loop

after_first_zero:
  cmp r9, 0
  jne not_zero_after

  ;mamy zero
  cmp r13, r14 ;length of first and current permutation don't match
  jne error

  inc r12; increase loop counter
  xor r14, r14 ;set lenght of new permutation to 0
  jmp continue_loop

not_zero_after:
  mov r15, [array + r9*8]
  inc r15
  cmp r15, r12 ;compare first and current pass
  jne error

  mov [array + r9*8], r15 ;set new pass value
  inc r14 ;increase current permutation length
  jmp continue_loop

continue_loop:
  inc r10
  cmp r10, rsi ;check end of buffer
  jne loop_over

  jmp read_file

end:
  ;end of file processing
  cmp r8, 0 ;check that at least one byte was read
  je error

  cmp r9, 0 ;check if last number is 0
  jne error ;

  mov rdi, SYS_NORMAL_EXIT
  mov	rax, SYS_EXIT
  syscall

error:
  mov	rax, SYS_EXIT
  mov	rdi, SYS_ERROR_EXIT
  syscall

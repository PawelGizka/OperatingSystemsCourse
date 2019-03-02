extern get_os_time

global proberen
global verhogen
global proberen_time

section .text

add_err:
  lock add     [rdi], esi
proberen:
  cmp     esi, [rdi]
  jg      proberen
  xor     rax, rax
  sub     eax, esi
  lock xadd [rdi], eax

  cmp     esi, eax
  jg      add_err
  ret

verhogen:
  lock add  [rdi], esi
  ret

proberen_time:
  push    rdi
  push    rsi
  call    get_os_time
  mov     r11, rax

  pop     rsi
  pop     rdi
  call    proberen

  call    get_os_time
  sub     rax, r11
  ret


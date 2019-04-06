format MS64 COFF

include 'win64ax.inc'

public  do_Random_EAX as 'do_Random_EAX'
public  do_fake_instr as 'do_fake_instr'


section '.text' code readable executable

regw1   dq 0h, 30h ;add BYTE PTR [rax],dh
regw2   dq 0B0h, 0C0h ;mov al,0xc0
regw3   dq 0h, 0DDh ;add ch,bl
regw4   dq 0h, 0DCh ;div rcx
regw5   dq 0d0h, 0c0h ;rol al,1
regw6   dq 0B0h, 0C1h ;mov al,0xc0
regw7   dq 0f7h, 0d0h  ;not eax
regw8   db 031h, 0c0h  ;xor eax,eax

extrn debug_print ;Для дебага, обычный std_out в си, меняет регистры, не забывайте сохранять и восстанавливать их.)))
;Пример использования ccall _debug_print,38 (Напечатает "Debug 38" в консоле)

;---------------------------------------------
; Интерфейсная функция, для получения случайного числа в нужном интервале
; stdcall do_Random_EAX,min,max
; на выходе EAX - случайное число    
;---------------------------------------------
proc    do_Random_EAX rmin:qword,rmax:qword

        ;Сохранение регистров (На всякий случай)
       push rbx
       push rcx

       mov   [value_min2],eax

       mov   [value_min2],eax

       ;Инициализация генератора
       stdcall  WRandomInit

       mov   [value_min],rcx
        mov   [value_max],rdx

        ;ccall _debug_print,[value_min]

        ;Получить случайное число
        stdcall WIRandom,[value_min],[value_max]

        ;Восстановление регистров
       pop rcx
       pop rbx

       ret
endp

;---------------------------------------------
; Инициализация генератора случайных чисел
; stdcall WRandomInit 
;---------------------------------------------
proc    WRandomInit
        push    rax rdx
        rdtsc
        xor     rax,rdx
        mov     [random_seed],rax
        pop     rdx rax
        ret
endp

;---------------------------------------------
; Park Miller random number algorithm
; Получить случайное число 0 ... 99999
; stdcall Random_EAX
; на выходе EAX - случайное число 
;---------------------------------------------
Random_EAX:
        push    rdx rcx
        mov     rax,[random_seed]
        xor     rdx,rdx
        mov     rcx,127773
        div     rcx
        mov     rcx,rax
        mov     rax,16807
        mul     rdx
        mov     rdx,rcx
        mov     rcx,rax
        mov     rax,2836
        mul     rdx
        sub     rcx,rax
        xor     rdx,rdx
        mov     rax,rcx
        mov     [random_seed],rcx
        mov     rcx,100000
        div     rcx
        mov     rax,rdx
        pop     rcx rdx
        ret

proc    WIRandom rmin:dword,rmax:dword
        push    rdx rcx
        mov   [value_min],rcx
        mov   [value_max],rdx
        mov     rcx,[value_max]
        sub     rcx,[value_min]
        inc     rcx
        stdcall Random_EAX
        xor     rdx,rdx
        div     rcx
        mov     rax,rdx
        add     rax,[value_min]
        pop     rcx rdx
        ret
endp

;________________________________________________________
;Генерация фейковых инструкций
;________________________________________________________

proc do_fake_instr

        push rsi
        push rdi
        push rdx
        push rbp
        push rcx

        mov rsi, regw1
        lodsw
        stosw

        ;mov   [value_min],rax
        ;ccall _debug_print,[value_min]

        ;ccall _debug_print,[value_min]

        ;ccall _debug_print,0

        ; Инициализация генератора
        ;stdcall  WRandomInit

       ; ccall _debug_print,0

        ;Получить случайное число от 0 до19
        ;stdcall WIRandom,0,19

       ; ccall _debug_print,0

       ; mov rax, 0

       ;.if rax=0
       ;     mov rsi, regw1
        ;    lodsw
         ;   xor rbx, rbx
          ;  mov rbx, rcx
           ; shl rbx, 3
           ; or rbx, rdx
           ; add ah, bl
           ; stosw
        ;.elseif rax=1
        ;     mov rsi, regw1
        ;     lodsw
        ;     xor rbx, rbx
        ;     mov rbx, rcx
        ;     shl rbx, 3
        ;     or rbx, rdx
       ;      add ah, bl
       ;      stosw
      ;  .endif

        pop rcx
        pop rbp
        pop rdx
        pop rdi
        pop rsi
        ret
endp

;---------------------------------------------
;Функции для генерации инструкций
;---------------------------------------------
proc make_addreg
        mov rsi, regw1
        lodsw
        xor rbx, rbx
        mov rbx, rcx
        shl rbx, 3
        or rbx, rdx
        add ah, bl
        stosw
        Ret
endp
proc make_subreg
        mov rsi,regw2
        lodsw
        xor rbx, rbx
        mov rbx, rcx
        shl rbx, 3
        or rbx, rdx
        add ah, bl
        stosw
        Ret
endp
proc make_xorreg
        mov rsi,regw3
        lodsw
        xor rbx, rbx
        mov rbx, rcx
        shl rbx, 3
        or rbx, rdx
        add ah, bl
        stosw
        Ret
endp
proc make_movreg
        mov rsi,regw4
        lodsw
        xor rbx, rbx
        mov rbx, rcx
        shl rbx, 3
        or rbx, rdx
        add ah, bl
        stosw
        Ret
endp
proc make_xchgreg
        mov rsi,regw5
        lodsw
        xor rbx, rbx
        mov rbx, rcx
        shl rbx, 3
        or rbx, rdx
        add ah, bl
        stosw
        Ret
endp
proc make_orreg
        mov rsi,regw6
        lodsw
        xor rbx, rbx
        mov rbx, rcx
        shl rbx, 3
        or rbx, rdx
        add ah, bl
        stosw
        Ret
endp
proc make_andreg
        mov rsi,regw7
        lodsw
        xor rbx, rbx
        mov rbx, rcx
        shl rbx, 3
        or rbx, rdx
        add ah, bl
        stosw
        Ret
endp
proc make_notreg
        mov rsi,regw8
        lodsw
        add ah, cl
        stosw
        Ret
endp
proc make_shlreg
        mov rsi,regw9
        lodsw
        add ah, dl
        stosw
        Ret
endp
proc make_shrreg
        mov rsi,regw10
        lodsw
        add ah, cl
        stosw
        Ret
endp
proc make_subrnd
        mov rsi,regw11
        lodsw
        add ah, dl
        stosw
        mov rax, -1
        stosd
        Ret
endp
proc make_addrnd
        or rdx, rdx
        mov al, 05h
        stosb
        mov rax, -1
        stosd
        Ret
endp
proc make_xorrnd
        or rdx, rdx
        mov al, 35h
        stosb
        mov rax, -1
        stosd
        Ret
endp
proc make_orrnd
        mov rsi,regw14
        lodsw
        add ah, cl
        stosw
        mov rax, -1
        stosd
        Ret
endp
proc make_andrnd
        or rdx, rdx
        mov al, 25h
        stosb
        mov rax, -1
        stosd
        Ret
endp
proc make_negreg
        mov rsi,regw16
        lodsw
        add ah, cl
        stosw
        Ret
endp
proc make_rolreg
        mov rsi,regw17
        lodsw
        add ah, cl
        stosw
        Ret
endp
proc make_rorreg
        mov rsi,regw18
        lodsw
        add ah, cl
        stosw
        Ret
endp
proc make_leareg
        mov rsi, regw19
        lodsw
        xor rbx, rbx
        mov rbx, rcx
        shl rbx, 3
        or rbx, rdx
        add ah, bl
        stosw
        Ret
endp
proc make_movrnd
        mov rsi, regd1
        lodsb
        add al, cl
        stosb
        mov rax, -1
        stosd
        Ret
endp

section '.data' data readable writeable
random_seed     dq 0
value_min       dq 0
value_max       dq 0
value_min2       dd 0
format MS64 COFF

include 'win64ax.inc'

public  do_Random_EAX as '_do_Random_EAX'
public  do_fake_instr as '_do_fake_instr'


section '.text' code readable executable

extrn _debug_print ;Для дебага, обычный std_out в си, меняет регистры, не забывайте сохранять и восстанавливать их.)))
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
       ccall _debug_print,[value_min2]

       mov   [value_min2],eax
       ccall _debug_print,[value_min2]

       ;Инициализация генератора
       stdcall  WRandomInit

       mov   [value_min],rcx
       mov   [value_max],rdx

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

       ;Инициализация генератора
        stdcall  WRandomInit

       ;Получить случайное число от 0 до19
       stdcall WIRandom,0,19
	   
	    .if eax=0
                db 03h, 0C0h ;add reg1, reg2
        .elseif eax=1
                db 2Bh, 0C0h ;sub reg1, reg2
        .elseif eax=2
                db 33h, 0C0h ;xor reg1, reg2
        .elseif eax=3
                db 8Bh, 0C0h ;mov reg1, reg2 
        .elseif eax=4
                db 87h, 0C0h ;xchg reg1, reg2 
        .elseif eax=5
                db 0Bh, 0C0h ;or reg1, reg2
        .elseif eax=6
                db 23h, 0C0h ;and reg1, reg2
        .elseif eax=7
                db 0F7h, 0D0h ;not reg1
        .elseif eax=8
                db 0D1h, 0E0h ;shl reg1, 1
        .elseif eax=9
                db 0D1h, 0E8h ;shr reg1, 1
        .elseif eax=10
                db 081h, 0E8h ;sub reg1, rnd
        .elseif eax=11
                db 081h, 0C0h ;add reg1, rnd
        .elseif eax=12
                db 081h, 0F0h ;xor reg1, rnd
        .elseif eax=14
                db 081h, 0C8h ;or reg1, rnd
        .elseif eax=15
                db 081h, 0E0h ;and reg1, rnd
        .elseif eax=16
                db 0F7h, 0D8h ;neg reg1
        .elseif eax=17
                db 0D1h, 0C0h ;rol reg1, 1
        .elseif eax=18
                db 0D1h, 0C8h ;ror reg1, 1
        .elseif eax=19
                db 08Dh, 00h  ;lea reg1, [reg2]
        .endif


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
Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik
start:
        mov     ax, dane
        mov     ds, ax
        mov     ax, stosik
        mov     ss, ax
        mov     sp, offset szczyt

petla_wejscia:
        mov     ah, 9
        mov     dx, offset komunikat
        int     21h
        xor     bx, bx
        mov     cx, 10
        xor     si, si
        xor     dx, dx
        mov     ah, 1
        int     21h
        cmp     al, '-'
        jne     sprawdz_cyfre
        mov     si, 1
        jmp     nastepna_cyfra

sprawdz_cyfre:
        cmp     al, '0'
        jb      nieprawidlowe_dane
        cmp     al, '9'
        ja      nieprawidlowe_dane
        sub     al, 48
        xor     ah, ah
        mov     bx, ax

nastepna_cyfra:
        mov     ah, 1
        int     21h
        cmp     al, 13
        je      koniec_wejscia
        cmp     al, '0'
        jb      nieprawidlowe_dane
        cmp     al, '9'
        ja      nieprawidlowe_dane
        sub     al, 48
        xor     ah, ah
        push    ax
        mov     ax, bx
        cmp     ax, 3276    
        ja      przepelnienie
        mul     cx
        ;jo      przepelnienie
        mov     bx, ax
        pop     ax
        add     bx, ax
        ;jo      przepelnienie
        cmp     si, 1       
        jne     sprawdz_dodatnia
        cmp     bx, 8000h   
        ja      przepelnienie
        jmp     nastepna_cyfra

sprawdz_dodatnia:
        cmp     bx, 7FFFh   
        ja      przepelnienie
        jmp     nastepna_cyfra

przepelnienie:
        mov     ah, 9
        mov     dx, offset komunikat_przepelnienia
        int     21h
        jmp     petla_wejscia

nieprawidlowe_dane:
        mov     ah, 9
        mov     dx, offset komunikat_bledu
        int     21h
        jmp     petla_wejscia

koniec_wejscia:
        cmp     si, 1
	
        jne     drukuj_wyniki
        neg     bx

drukuj_wyniki:
        push    bx
        mov     ah, 9
        mov     dx, offset komunikat_hex
        int     21h
        mov     ax, bx
        mov     cx, 4
drukuj_hex:
        push    cx
        mov     cx, 4
        rol     ax, cl
        push    ax
        and     al, 0Fh
        add     al, 30h
        cmp     al, 39h
        jle     drukuj_znak_hex
        add     al, 7
drukuj_znak_hex:
        mov     dl, al
        mov     ah, 2
        int     21h
        pop     ax
        pop     cx
        loop    drukuj_hex

        mov     ah, 9
        mov     dx, offset nowa_linia
        int     21h
        mov     dx, offset komunikat_bin
        int     21h
        pop     bx
        mov     ax, bx
        mov     cx, 16

drukuj_binarnie:
        shl     ax, 1
        jc      drukuj_jedynke
drukuj_zero:
        mov     dl, '0'
        jmp     drukuj_bit
drukuj_jedynke:
        mov     dl, '1'
drukuj_bit:
        push    ax
        mov     ah, 2
        int     21h
        pop     ax
        loop    drukuj_binarnie

        mov     ah, 9
        mov     dx, offset nowa_linia
        int     21h
        
        mov     ax, 4C00h
        int     21h

dane            segment
komunikat       db      'Podaj liczbe (-32768 do 32767): $'
nowa_linia      db      13,10,'$'
komunikat_hex   db      'Hex: $'
komunikat_bin   db      'Binarnie: $'
komunikat_przepelnienia db 'Przepelnienie! Liczba za duza.$'
komunikat_bledu db      'Nieprawidlowe dane. Podaj poprawna liczbe.$'
dane            ends

stosik          segment stack
                dw      100h dup(0)
szczyt          label   word
stosik          ends

end start
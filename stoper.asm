org 100h
start:
	call ent
	call wyswTekst
	
	call ent
	call pobierzCzas
	call wysCzas
petla:
	mov ah,0
	int 16h ;pobrany znak -> al
	mov [wybranyZnak],al
	mov bl,[znakZak]
	cmp al,bl 
	je koniec
	call ent
	call pobierzCzas
	call wysCzas
	call spacja
	
	mov al,[wybranyZnak]
	mov bl,[znakSt]
	cmp al,bl
	jne pomin
	call zdarzenieStoper
pomin:
	jmp petla
	
koniec:
	mov ax,4c00h
	int 21h


tekst1		db " - konczy program$"
teskt2		db " - wlacza/wylacza stoper$"
czyStoper 	db 0 ;czy aktywny stoper
stoperSt 	db "uruchomiono stoper$"
stoperKon 	db "zakonczono stoper$"
wybranyZnak	db 0
znakZak		db "b" ;można dostosować
znakSt		db "v"
aktGodz db 0 ;aktualna godzina
aktMin 	db 0
aktSek 	db 0
stGodz 	db 0 ;godzina uruchomienia stopera
stMin 	db 0
stSek 	db 0
zmGodz	db 0 ;zmierzony czas
zmMin	db 0
zmSek	db 0


wyswTekst: ;wyświetla początkowy tekst
	mov ah,2
	mov dl,[znakZak]
	int 21h
	mov ah,9
	mov dx,tekst1
	int 21h
	call ent
	
	mov ah,2
	mov dl,[znakSt]
	int 21h
	mov ah,9
	mov dx,teskt2
	int 21h
	ret

pobierzCzas: ;zapisuje aktualny czas do pamięci
	mov ah,02ch
	int 21h ;zwraca akt. godz->ch, min->cl, sek->dh
	mov [aktGodz],ch
	mov [aktMin],cl
	mov [aktSek],dh
	ret

zdarzenieStoper: ;obsługuje włączenie i wyłączenie stopera
	mov ah,[czyStoper]
	cmp ah,0
	je uruchomSt
	jmp zakonczSt
uruchomSt:
	mov ah,9
	mov dx,stoperSt
	int 21h
	mov bx,czyStoper
	mov [bx],byte 1 ;włączamy stoper
	call pobierzCzasSt
	jmp pominSt	
zakonczSt:
	mov ah,9
	mov dx,stoperKon
	int 21h
	mov bx,czyStoper
	mov [bx],byte 0 ;wyłączamy stoper
	call obliczCzas
	call spacja
	call wysZmCzas
	jmp pominSt
pominSt:
	ret

obliczCzas: ;oblicza zmierzony czas i zapisuje do pamięci
	call sprDodajMin
	call sprDodajSek
	mov cx,3
	mov bx,aktSek
petlaObl:
	mov al,[bx]
	mov dl,[bx+3] 
	sub al,dl ;al = akt-stoper
	mov [bx+6],al ; 'bx+6' = zmierzony
	dec bx ;iterujemy przez kolejno: sek,min,godz
	loop petlaObl
	ret

sprDodajMin: ;sprawdza czy trzeba dodać minuty i ewentualnie dodaje (aby poprawnie odjąć)
	mov al,[aktMin]
	mov ah,[stMin]
	cmp al,ah
	jl e_dodMin ; aktMin<stMin
	jmp e_pominMin
e_dodMin:
	call dodajMin
	jmp e_pominMin
e_pominMin:
	ret

sprDodajSek:
	mov al,[aktSek]
	mov ah,[stSek]
	cmp al,ah
	jl e_dodSek ;aktSek < stSek -> trzeba dodać sekundy do aktSek, aby poprawnie odjąć
	jmp e_pominSek
e_dodSek:
	mov al,[aktMin]
	cmp al,0
	je e_szczeg ;szczególny przypadek kiedy trzeba dodać sekundy, ale jest 0 minut
	jmp e_pominSzczeg
e_szczeg:
	call dodajMin ;dodajemy potrzebną minutę (60min) co umożliwia poprawne odjęcie minut przy 'dodajSek'
	jmp e_pominSzczeg
e_pominSzczeg:
	call dodajSek
	jmp e_pominSek
e_pominSek:
	ret


dodajSek: ;dodaje 60sek i odejmuje 1min dla 'aktSek' aby poprawnie odjąć czas
	mov bx,aktSek
	mov al,[bx]
	add al,60
	mov [bx],al
	
	mov bx,aktMin
	mov al,[bx]
	sub al,1
	mov [bx],al
	
	ret
	
dodajMin: 
	mov bx,aktMin
	mov al,[bx]
	add al,60
	mov [bx],al
	
	mov bx,aktGodz
	mov al,[bx]
	sub al,1
	mov [bx],al
	ret
	
wysZmCzas: ;wyświetla zmierzony czas z pamięci
	pusha
	
	mov al,[zmGodz]
	call wyswZn
	mov ah,2
	mov dl,103 ;g
	int 21h
	
	mov al,[zmMin]
	call wyswZn
	mov ah,2
	mov dl,109 ;m
	int 21h
	
	mov al,[zmSek]
	call wyswZn
	mov ah,2
	mov dl,115 ;s
	int 21h
	popa
	ret

pobierzCzasSt: ;ustawia początkowy czas stopera na aktualny czas
	mov al,[aktGodz]
	mov [stGodz],al
	mov al,[aktMin]
	mov [stMin],al
	mov al,[aktSek]
	mov [stSek],al
	ret
	
wysCzas: ;wyświetla czas z pamięci
	pusha
	
	mov al,[aktGodz]
	call wyswZn
	call dwuk
	
	mov al,[aktMin]
	call wyswZn
	call dwuk
	
	mov al,[aktSek]
	call wyswZn
	popa
	ret
	
dwuk:
	pusha
	mov ah,2
	mov dl,58 ;':'=58
	int 21h
	popa
	ret
	
wyswZn: ;wyświetla 2-cyfrową liczbę z al
	pusha
	xor ah,ah
	mov bl,10
	div bl ;al=wyn, ah=reszta
	mov cl,ah ; reszta
	mov dl,al
	mov ah,2
	add dl,48
	int 21h
	mov dl,cl
	add dl,48
	int 21h
	popa
	ret
		
ent:
	pusha
	mov ah,2
	mov dl,13
	int 21h
	mov dl,10
	int 21h
	popa
	ret

spacja:
	pusha
	mov ah,2
	mov dl,32
	int 21h
	popa
	ret
	

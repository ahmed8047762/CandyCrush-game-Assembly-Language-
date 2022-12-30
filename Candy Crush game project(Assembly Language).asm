; Project Coal Lab
;Group Members: 
;             Muhammad Shehzad (20I-1756)	       Ahmed (20I-1893)
;Project Level_1
;INCLUDE GAME.INC
.MODEL SMALL
.STACK 100h
.DATA

FALSE equ 0
TRUE  equ 1
;********Variables for Inputs*******
UName db 10 dup('$')
Array1 db 49 dup('$')
Array2 db 39 dup('$')
Array3 db 36 dup('$')


RandNum db 10 dup(0)
count db 0
var1 dw 0
i dw 0
j dw 0
k dw 0
x dw 0
y dw 0
z dw 0
a db 0
b db 0
endl db 0Dh,0Ah
file db "game.txt",'0'

prevClickX dw 117 ; previous x-cordinate of click
prevClickY	dw 51 ; previous y-cordinate of click
CurrClickX dw 117 ; current x-cordinate of click
CurrClickY dw 51 ;  current y-cordinate of click
PrevClickIndex dw 60; previous index of array when clicked on the grid
CurrClickIndex dw 200; current index of array when clicked on the grid
color db  14         ; default color of box boundary is yellow


;Variables for crushing
vac db 0 ; vertical crush
vdc db 0 ; vertical down crush
hrc db 0 ; horizontal right crush
hlc db 0 ; horizonta left crush
lac db 0 ; left above diagonal crush
ldc db 0 ; left down diagonal crush
rac db 0 ; right above diagonal crush
rdc db 0  ; right down diagonal crush

Score dw 0
Moves dw 15 
;*******Strings to Display*********
NameP db "Name : $"
GameName db "Welcome to Saga Candy Crush! $"
Rule db "Rules for Candy Crush!$"
Rule1 db "1. The initial objective game is to earn a certain number of points within a certain number of moves.$"
Rule2 db "2. If you match at least 3 candies in any direction, it will be crushed and you will get points.$" 
Rule3 db "3. The game is played by swaping candies, in any direction to create sets of 3 or more matching candies.$"
Rule4 db "4. If you match 4 candies, a special candy will be created which will burst an entire row.$"
Str1 db "Good Luck!$"
Str2 db "Name: $"
Str3 db "Score: $"
Str4 db "Moves: $"		
Str5 db "Candies Info!$"
Str6 db "1.Wraped      2.Gum Diamond      3.Striped Candy $"
str7 db "4.House       5.Bomb $"
EnterName db "Enter your Name: $"
welcome db "Welcome to Candy Crush Presented by Shehzad and Ahmed $"
Level1 db "Press 1--->Level 1$"
Level2 db "Press 2--->Level 2$"
Level3 db "Press 3--->Level 3$"
LevelStr db "Level No: $"
WellPlayedP db "Well Played! $"
GameEndp db "------Game Ended-------- $"

LevelNo db 0
.CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Macros ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-----------------First Window-------------------
displayInitialScreen macro
	mov ah, 0		; Set video mode 640x480
	mov al, 12h
	int 10h
	mov AH, 06h
	mov AL, 0
	mov CX, 0
	mov DH, 80
	mov DL, 80
	mov BH, 08h
	int 10h
endm
drawSquare macro
	;-------Change Background---------
	mov AH, 06h
	mov AL, 10 ; scroll line
	mov Cx,19
	mov DH, 18 ;move up
	mov DL, 60
	mov BH, 00h
	int 10h
	;--------Draw Square---------------
	mov si,152
	mov di,144
	.while si<489
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc si
	.endw
	.while di<305
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc di
	.endw
	.while si>152
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		;mov bh,0
		int 10h
		dec si
	.endw
	.while di>144
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		dec di
	.endw
endm
GetName macro


	mov si,150
	mov di,102
	mov i,00
	.while i<=25
		.while si<=480
			mov ah,0Ch
			mov al,00h  ; Color
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc i
		mov si,150
		inc di
	.endw
	


	mov dh, 7 ; rows
	mov dl, 25 ; columns
	mov si, 0
	displaystring1:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, GameName[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp GameName[si], "$"
	jne displaystring1
	mov dh, 13
	mov dl, 20
	mov si, 0
	displaystring:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, EnterName[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		
		inc dl
		inc si
		cmp ENterName[si], "$"
	jne displaystring	
endm
inputPlayerName macro
	mov dl, 37  ; columns 
	mov dh, 13  ; rows
	mov ah, 02
	int 10h
		
	mov ch, 0
	mov cl, 7
	mov ah, 1
	int 10h
	mov SI, offset UName
	inputChar:
		int 21h
		mov [si], al
		inc si
		cmp al, 13
	jne inputChar
	mov al,"$"
	mov [si],al
endm
EnterLevelNo macro
   mov ax,0
   mov ah,08h
   int 21h
   SUB AL,48
   mov LevelNo,al
endm
displayLevels macro
	mov AH, 06h ; Set Full Background Grey 
	mov AL, 0
	mov CX, 0
	mov DH, 80
	mov DL, 80
	mov BH, 08h
	int 10h

	mov AH, 06h ; change to black background to display rules
	mov AL, 21; move up
	mov Cx,8
	mov DH, 25 ;move down
	mov DL, 70 ; move right
	mov BH, 00h
	int 10h
	;-----------Yellow Border----------
	mov si,64
	mov di,80
	.while si<568
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc si
	.endw
	.while di<415
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc di
	.endw
	.while si>64
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		;mov bh,0
		int 10h
		dec si
	.endw
	.while di>80
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		dec di
	.endw
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Displaying the levels	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov dh,6; rows
	mov dl,10 ; columns
	mov si, 0
	WelcomeStr:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Welcome[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Welcome[si], "$"
	jne WelcomeStr

	mov dh,8; rows
	mov dl,10 ; columns
	mov si, 0
	Level1Str:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Level1[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Level1[si], "$"
	jne Level1Str

	mov dh,10; rows
	mov dl,10 ; columns
	mov si, 0
	Level2Str:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Level2[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Level2[si], "$"
	jne Level2Str


	mov dh,12; rows
	mov dl,10 ; columns
	mov si, 0
	Level3Str:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Level3[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Level3[si], "$"
	jne Level3Str



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Displaying Candies Info ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov dh,16; rows
	mov dl,10 ; columns
	mov si, 0
	displayCandies:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Str5[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Str5[si], "$"
	jne displayCandies

	mov dh,18 ; rows
	mov dl,10 ; columns
	mov si, 0
	displayCandiesInfo:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Str6[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Str6[si], "$"
	jne displayCandiesInfo


	mov dh,22 ; rows
	mov dl,10 ; columns
	mov si, 0
	displayCandiesInfo2:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Str7[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Str7[si], "$"
	jne displayCandiesInfo2

	mov i,100
	mov j,320
	DrawRectangle
	mov i,250
	mov j,320
	DrawDiamond
	mov i,400
	mov j,320
	DrawTriangle
	mov i,120
	mov j,385
	DrawHouse
	mov i,250
	mov j,390
	DrawBomb
endm
;-----------------Second Window------------------------
displayRules macro
	mov AH, 06h ; Set Full Background Grey 
	mov AL, 0
	mov CX, 0
	mov DH, 80
	mov DL, 80
	mov BH, 08h
	int 10h

	mov AH, 06h ; change to black background to display rules
	mov AL, 21; move up
	mov Cx,8
	mov DH, 25 ;move down
	mov DL, 70 ; move right
	mov BH, 00h
	int 10h
	;-----------Yellow Border----------
	mov si,64
	mov di,80
	.while si<568
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc si
	.endw
	.while di<415
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc di
	.endw
	.while si>64
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		;mov bh,0
		int 10h
		dec si
	.endw
	.while di>80
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		dec di
	.endw

	;------------Display Rules-------------

	mov dh, 6; rows
	mov dl, 10;columns
	mov si, 0
	displayRule:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Rule[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Rule[si], "$"
	jne displayRule

	mov dh, 8; rows
	mov dl, 10 ; columns
	mov si, 0
	displayRule1:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Rule1[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		.if dl==70
			mov dl,11
			inc dh

		.endif
		inc dl
		inc si
		cmp Rule1[si], "$"
	jne displayRule1

	mov dh,11
	mov dl, 10 ; columns
	mov si, 0
	displayRule2:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Rule2[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		.if dl==70
			mov dl,11
			inc dh

		.endif
		inc dl
		inc si
		cmp Rule2[si], "$"
	jne displayRule2

	mov dh,14
	mov dl, 10 ; columns
	mov si, 0
	displayRule3:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Rule3[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		.if dl==70
			mov dl,11
			inc dh
		.endif
		inc dl
		inc si
		cmp Rule3[si], "$"
	jne displayRule3

	mov dh,17
	mov dl, 10 ; columns
	mov si, 0
	displayRule4:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Rule4[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		.if dl==70
			mov dl,11
			inc dh
		.endif
		inc dl
		inc si
		cmp Rule4[si], "$"
	jne displayRule4

	mov dh,20 ; rows
	mov dl, 33 ; columns
	mov si, 0
	displayGoodLuck:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Str1[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Str1[si], "$"
	jne displayGoodLuck

	



	mov ah,08h
	int 21h
endm
;-----------------Third Window------------------------
displayLevel1 macro
	mov AH, 06h ; Set Full Background Grey 
	mov AL, 0
	mov CX, 0
	mov DH, 80
	mov DL, 80
	mov BH, 08h
	int 10h
	;------------Draw Black Square for Game---------
	mov si,117
	mov di,51
	.while di<450
		.while si<516
			mov ah,0Ch
			mov al,00h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,117
	.endw
	;>
	;-------------Draw Yellow Border----------------
	
	mov si,117
	mov di,51
	.while si<516
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc si
	.endw
	.while di<450
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc di
	.endw
	.while si>117
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		;mov bh,0
		int 10h
		dec si
	.endw
	.while di>51
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		dec di
	.endw
	
	
	;---------- Setting the table----------
	mov si,117
	mov di,51
	.while si<516
		.while di<450
			mov ah,0Ch
			mov al,0eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc di
		.endw
		add si,57
		mov di,51
	.endw
	mov si,117
	mov di,51
	.while di<450
		.while si<516
			mov ah,0Ch
			mov al,0eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		add di,57
		mov si,117
	.endw
	;><
endm
displayLevel2 macro
	mov AH, 06h ; Set Full Background Grey 
	mov AL, 0
	mov CX, 0
	mov DH, 80
	mov DL, 80
	mov BH, 08h
	int 10h
	;------------Draw Black Square for Game---------
	mov si,117
	mov di,51
	.while di<450
		.while si<516
			mov ah,0Ch
			mov al,00h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,117
	.endw
	;>
	;-------------Draw Yellow Border----------------
	
	mov si,117
	mov di,51
	.while si<516
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc si
	.endw
	.while di<450
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc di
	.endw
	.while si>117
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		;mov bh,0
		int 10h
		dec si
	.endw
	.while di>51
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		dec di
	.endw
	
	
	;---------- Setting the table----------
	mov si,117
	mov di,51
	.while si<516
		.while di<450
			mov ah,0Ch
			mov al,0eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc di
		.endw
		add si,57
		mov di,51
	.endw
	mov si,174
	mov di,51
	mov i,0
	mov j,459
	.while di<450
		.while si<j
			mov ah,0Ch
			mov al,0eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc i
		.if((i==2) || (i==3) || (i==4) || (i==5))
			mov si,117
			mov j,516
		.else
			mov si,174
			mov j,459
		.endif
		add di,57
		
	.endw
	;>

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Making the background of some boxes in grid with grey color;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;Left Side of Grid ;;;;;;;;;;;;;;;;;
	
	mov i,118
	mov si,118
	mov di,52
	

	
	.while di<=164
		push k
		mov ax,i
		mov k,ax
		add k,55
		.while si<=k
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw

	mov i,118
	mov si,118
	mov di,223
	
	.while di<=278
		push k
		mov ax,i
		mov k,ax
		add k,55
		.while si<=k
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw


	mov i,118
	mov si,118
	mov di,337
	
	.while di<=449
		push k
		mov ax,i
		mov k,ax
		add k,55
		.while si<=k
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw
	;;;;;;;;;;;;;;;;;;Right Side of grid ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov i,460
	mov si,460
	mov di,52
	
	.while di<=164
		push k
		mov ax,i
		mov k,ax
		add k,55
		.while si<=k
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw


	mov i,460
	mov si,460
	mov di,223
	
	.while di<=278
		push k
		mov ax,i
		mov k,ax
		add k,55
		.while si<=k
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw


	mov i,460
	mov si,460
	mov di,337
	
	.while di<=449
		push k
		mov ax,i
		mov k,ax
		add k,55
		.while si<=k
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw
endm
displayLevel3 macro
	
	
	mov AH, 06h ; Set Full Background Grey 
	mov AL, 0
	mov CX, 0
	mov DH, 80
	mov DL, 80
	mov BH, 08h
	int 10h
	;------------Draw Black Square for Game---------
	mov si,117
	mov di,51
	.while di<450
		.while si<516
			mov ah,0Ch
			mov al,00h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,117
	.endw
	;>
	;-------------Draw Yellow Border----------------
	
	mov si,117
	mov di,51
	.while si<516
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc si
	.endw
	.while di<450
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		inc di
	.endw
	.while si>117
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		;mov bh,0
		int 10h
		dec si
	.endw
	.while di>51
		mov ah,0Ch
		mov al,0eh
		mov cx,si
		mov dx,di
		mov bh,0
		int 10h
		dec di
	.endw
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Setting the grid of level 3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov si,117
	mov di,51
	.while si<516
		.while di<450
			mov ah,0Ch
			mov al,0eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc di
		.endw
		add si,57
		mov di,51
	.endw
	mov si,117
	mov di,51
	.while di<450
		.while si<516
			mov ah,0Ch
			mov al,0eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		add di,57
		mov si,117
	.endw
	;><
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Making the background of some boxes in grid with grey color;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;Vertical Side of Grid ;;;;;;;;;;;;;;;;;
	
	mov i,289
	mov si,289
	mov di,52
	
	.while di<=449
		push k
		mov ax,i
		mov k,ax
		add k,55
		.while si<=k
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw


	;;;;;;;;;;;;;;;;Horizontal Side of Grid ;;;;;;;;;;;;;;;;;
	
	mov i,118
	mov si,118
	mov di,223
	
	.while di<=278
		.while si<=515
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
	.endw
endm

ClearBackground macro

	mov ax,i
	mov x,ax
	add x,10
	mov ax,j
	mov y,ax
	add y,5

	mov si,x ; 13 differnece from wall on left
	mov di,y ; 19 differnece from wall on top
	mov k,di
	add k,40
	.while di<=k
		push k
		mov ax,x
		mov k,ax
		add k,40
		.while si<=k
			mov ah,0Ch
			mov al,00h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,x
		pop k
	.endw
endm
DrawShapes1 macro
   mov count,1
   mov si,0
   mov i,117 ; x-axis		; will move with the differnce of 57 on each side
   mov j,51  ; y-axis
   Assign:
		push si
		mov dl,Array1[si]
		.if(dl==0)
			jmp rectangle
		.endif
		.if(dl==1)
			jmp triangle
		.endif
		.if(dl==2)
			jmp Diamond
		.endif
		.if(dl==3)
			jmp House
		.endif
		.if (dl==4)
			jmp Bomb
		.endif
		jmp return
		rectangle:
		
			ClearBackground
			push i
			push j			
			add i,13
			add j,19
			DrawRectangle
			pop j
			pop i
			add i,57
			.if(i>=516)
				mov i,117
				add j,57
			.endif		
			jmp return
		triangle:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawTriangle
			pop j
			pop i 
			add i,57
			.if(i>=516)
				mov i,117
				add j,57
			.endif		
			jmp return
		Diamond:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawDiamond
			pop j
			pop i 
			add i,57
			.if(i>=516)
				mov i,117
				add j,57
			.endif		
			jmp return
		House:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawHouse
			pop j
			pop i 
			add i,57
			.if(i>=516)
				mov i,117
				add j,57
			.endif		
			jmp return
		Bomb:
			ClearBackground	
			push i 
			push j
			add i,26
			add j,13
			DrawBomb
			pop j
			pop i 
			add i,57
			.if(i>=516)
				mov i,117
				add j,57
			.endif		
			jmp return
		return:
		pop si
		inc si
		cmp count,49
		je exe
		inc count
	jmp Assign

	exe:
endm
DrawShapes2 macro
   mov count,1
   mov si,0
   mov i,174 ; x-axis		; will move with the differnce of 57 on each side
   mov j,51  ; y-axis
   Assign2:
		push si
		mov dl,Array2[si]
		.if(dl==0)
			jmp rectangle2
		.endif
		.if(dl==1)
			jmp triangle2
		.endif
		.if(dl==2)
			jmp Diamond2
		.endif
		.if(dl==3)
			jmp House2
		.endif
		.if (dl==4)
			jmp Bomb2
		.endif
		jmp return2
		rectangle2:
		
			ClearBackground
			push i
			push j			
			add i,13
			add j,19
			DrawRectangle
			pop j
			pop i
			add i,57
			.if(i>=459)
				.if((i==459) && (j==108))
					mov i,117
					mov j,165
				.elseif((i==459) && (j==222))
					mov i,117
					mov j,279
				.elseif((i==459) && (j==165))
					;add i,57
				.elseif((i==459) && (j==279))
				.else
					mov i,174
					add j,57
				.endif	
			.endif
			jmp return2
		triangle2:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawTriangle
			pop j
			pop i 
			add i,57
			.if(i>=459)
				.if((i==459) && (j==108))
					mov i,117
					mov j,165
				.elseif((i==459) && (j==222))
					mov i,117
					mov j,279
				.elseif((i==459) && (j==165))
					;add i,57
				.elseif((i==459) && (j==279))
				.else
					mov i,174
					add j,57
				.endif	
			.endif
			jmp return2
		Diamond2:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawDiamond
			pop j
			pop i 
			add i,57
			.if(i>=459)
				.if((i==459) && (j==108))
					mov i,117
					mov j,165
				.elseif((i==459) && (j==222))
					mov i,117
					mov j,279
				.elseif((i==459) && (j==165))
					;add i,57
				.elseif((i==459) && (j==279))
				.else
					mov i,174
					add j,57
				.endif	
			.endif
			jmp return2
		House2:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawHouse
			pop j
			pop i 
			add i,57
			.if(i>=459)
				.if((i==459) && (j==108))
					mov i,117
					mov j,165
				.elseif((i==459) && (j==222))
					mov i,117
					mov j,279
				.elseif((i==459) && (j==165))
				.elseif((i==459) && (j==279))
			
				.else
					mov i,174
					add j,57
				.endif	
			.endif
			jmp return2
		Bomb2:
			ClearBackground	
			push i 
			push j
			add i,26
			add j,13
			DrawBomb
			pop j
			pop i 
			add i,57
			.if(i>=459)
				.if((i==459) && (j==108))
					mov i,117
					mov j,165
				.elseif((i==459) && (j==222))
					mov i,117
					mov j,279
				.elseif((i==459) && (j==165))
					;add i,57
				.elseif((i==459) && (j==279))
					;add i,57
				.else
					mov i,174
					add j,57
				.endif	
			.endif
			jmp return2
		return2:
		pop si
		inc si
		cmp count,39
		je exe2
		inc count
	jmp Assign2

	exe2:
endm
DrawShapes3 macro
   mov count,1
   mov si,0
   mov i,117 ; x-axis		; will move with the differnce of 57 on each side
   mov j,51  ; y-axis
   Assign3:
		push si
		mov dl,Array3[si]
		.if(dl==0)
			jmp rectangle3
		.endif
		.if(dl==1)
			jmp triangle3
		.endif
		.if(dl==2)
			jmp Diamond3
		.endif
		.if(dl==3)
			jmp House3
		.endif
		.if (dl==4)
			jmp Bomb3
		.endif
		jmp return3
		rectangle3:
		
			ClearBackground
			push i
			push j			
			add i,13
			add j,19
			DrawRectangle
			pop j
			pop i
			add i,57
			.if(i==288)
				mov i,345
			.endif
			.if(i>=516)
				.if(i==288)
					mov i,345
				.elseif((i==516) && (j==165))
					mov i,117
					add j,114
				.else
					mov i,117
					add j,57
				.endif
			.endif		
			jmp return3
		triangle3:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawTriangle
			pop j
			pop i 
			add i,57
			.if(i==288)
				mov i,345
			.endif
			.if(i>=516)
				
				.if((i==516) && (j==165))
					mov i,117
					add j,114
				.else
					mov i,117
					add j,57
				.endif
			.endif			
			jmp return3
		Diamond3:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawDiamond
			pop j
			pop i 
			add i,57
			.if(i==288)
				mov i,345
			.endif
			.if(i>=516)
				.if(i==288)
					mov i,345
				.elseif((i==516) && (j==165))
					mov i,117
					add j,114
				.else
					mov i,117
					add j,57
				.endif
			.endif		
			jmp return3
		House3:
			ClearBackground
			push i 
			push j
			add i,26
			add j,13
			DrawHouse
			pop j
			pop i 
			add i,57
			.if(i==288)
				mov i,345
			.endif
			.if(i>=516)
				.if(i==288)
					mov i,345
				.elseif((i==516) && (j==165))
					mov i,117
					add j,114
				.else
					mov i,117
					add j,57
				.endif
			.endif		
			jmp return3
		Bomb3:
			ClearBackground	
			push i 
			push j
			add i,26
			add j,13
			DrawBomb
			pop j
			pop i 
			add i,57
			.if(i==288)
				mov i,345
			.endif
			.if(i>=516)
				.if(i==288)
					mov i,345
				.elseif((i==516) && (j==165))
					mov i,117
					add j,114
				.else
					mov i,117
					add j,57
				.endif
			.endif			
			jmp return3
		return3:
		pop si
		inc si
		cmp count,36
		je exe3
		inc count
	jmp Assign3

	exe3:
endm
DrawRectangle macro

	push SI
	push di
	push ax
	push bx 
	push CX
	push DX

	; rectangle
	mov si,i ; 13 differnece from wall on left
	mov di,j ; 19 differnece from wall on top
	mov k,di
	add k,20
	.while di<=k
		push k
		mov ax,i
		mov k,ax
		add k,25
		.while si<=k
			mov ah,0Ch
			mov al,05h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw

	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
endm
DrawTriangle macro
	; triangle

	push SI
	push di
	push ax
	push bx 
	push CX
	push DX

	mov si,i; 26 differnece
	mov di,j ; 19 differnece
	mov x,0
	mov y,si
	mov k,si
	mov z,di
	add z,25

	.while di<=z
		.while si<=y
			mov ah,0Ch
			mov al,0fh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		add di,2
		inc y
		dec k
		mov si,k
	.endw

	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
endm
DrawDiamond macro
	;Diamond
	push SI
	push di
	push ax
	push bx 
	push CX
	push DX

	mov si,i  ;26 differnece
	mov di,j  ;19 differnece
	mov x,0
	mov y,si
	mov z,si
	mov x,di
	add x,12
	.while di<=x
		.while si<=y
			mov ah,0Ch
			mov al,0Ah
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		add di,1
		inc y
		dec z
		mov si,z
	.endw
	add x,13
	.while di<=x
		.while si<=y
			mov ah,0Ch
			mov al,0Ah
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		add di,1
		dec y
		inc z
		mov si,z
	.endw

	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
endm
DrawHouse macro
	
	push SI
	push di
	push ax
	push bx 
	push CX
	push DX

	mov si,i;26 differnece
	mov di,j ;19 differnece
	mov x,si
	mov y,si
	mov z,di
	add z,10
	.while di<=z
		.while si<=x
			mov ah,0Ch
			mov al,0Fh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		add di,1
		inc x
		dec y
		mov si,y
	.endw
	inc si
	mov z,si
	dec x
	mov y,di
	add y,15
	.while di<=y
		.while si<=x
			mov ah,0Ch
			mov al,09h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		add di,1
		mov si,z
	.endw

	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
endm
DrawBomb macro	
	push SI
	push di
	push ax
	push bx 
	push CX
	push DX
				; rectangle 1
	sub i,10
	mov si,i
	push si
	mov di,j 
	mov k,di
	push di
	add k,22
	.while di<=k
		push k
		mov ax,i
		mov k,ax
		add k,7
		.while si<=k
			mov ah,0Ch
			mov al,04h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw


	; rectangle 2
	pop di
	pop si
	push SI
	push di
	push si
	push di
	add si,15
	mov i,si
	mov k,di
	add k,22
	.while di<=k
		push k
		mov ax,i
		mov k,ax
		add k,7
		.while si<=k
			mov ah,0Ch
			mov al,04h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw
	
	; making small strips on rectangle
	pop di
	pop si
	sub di,5
	add si,1
	mov i,si
	mov k,0
	mov j,0
	.while j<=3
		.while k<=5
			mov ah,0Ch
			mov al,0Eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
			inc k		
		.endw
		inc di
		inc j
		mov k,0
		mov si,i
	.endw


	pop di
	pop si
	push SI
	push di
	sub di,5
	add si,9
	mov i,si
	mov k,0
	mov j,0
	.while j<=3
		.while k<=5
			mov ah,0Ch
			mov al,0Eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
			inc k		
		.endw
		inc di
		inc j
		mov k,0
		mov si,i
	.endw


	pop di
	pop si
	sub di,5
	add si,16
	mov i,si
	mov k,0
	mov j,0
	.while j<=3
		.while k<=5
			mov ah,0Ch
			mov al,0Eh
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
			inc k		
		.endw
		inc di
		inc j
		mov k,0
		mov si,i
	.endw


	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
endm
DrawBoxAroundClick macro 
	
	
	mov ax,CurrclickX
	mov i,ax
	add ax,57
	mov j,ax
	mov ax,CurrclickY
	mov k,ax
	add ax,57
	mov z,ax

	mov si,z
	mov di,j
	mov ax,i
	mov x,ax
	mov ax,k 
	mov y,ax


	.while i<=di
			mov ah,0Ch
			mov al,Color
			mov cx,i
			mov dx,k
			mov bh,0
			int 10h
			inc i
	.endw
	dec i
	.while k<=si
			mov ah,0Ch
			mov al,Color
			mov cx,i
			mov dx,k
			mov bh,0
			int 10h
			inc k
	.endw
	dec k
	mov si,x
	.while j>=si
			mov ah,0Ch
			mov al,color
			mov cx,j
			mov dx,k
			mov bh,0
			int 10h
			dec j
	.endw
	inc j
	mov si,y
	.while z>=si
			mov ah,0Ch
			mov al,color
			mov cx,j
			mov dx,z
			mov bh,0
			int 10h
			dec z
	.endw

	.if(LevelNo==2)
	mov i,118
	mov si,118
	mov di,52
	.while di<=164
		push k
		mov ax,i
		mov k,ax
		add k,55
		.while si<=k
			mov ah,0Ch
			mov al,08h
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc di
		mov si,i
		pop k
	.endw
	.endif
endm	


checkVerticalAboveCrush macro

		pushA
		mov vac,6
		mov i,si  ; i and j for vertical above crush
		mov j,si
		sub i,14
		sub j,7
		mov di,i
		mov al,Array1[di]
		mov di,j
		mov ah,Array1[di]


		.if(ah==al)
			mov vac,al
		.else 
			mov vac,6
		.endif
		popA		
endm
CheckVerticalDownCrush macro

		pushA
		mov vdc,6
		mov i,si  ;  for vertical down crush
		mov j,si
		add i,14
		add j,7
		mov di,i
		mov al,Array1[di]
		mov di,j
		mov ah,Array1[di]
			
		.if(ah==al)
			mov vdc,al
		.else 
			mov vdc,6
		.endif	
		popA
endm
checkHorizontalRightCrush macro
		pushA
		mov hrc,6
		mov i,si  ;  for horizontal right crush
		mov j,si
		add i,2
		add j,1
		mov di,i
		mov al,Array1[di]
		mov di,j
		mov ah,Array1[di]
		
			
		.if ((al==ah))
			mov hrc,al
		.else
			mov hrc,6
		.endif
		popA
endm
checkHorizontalLeftCrush macro
		pushA
		mov hlc,6
		mov i, si  ; for horizontal left diagonal crush
		mov j,si
		sub i,2
		sub j,1
		mov di,i
		mov al,Array1[di]
		mov di,j
		mov ah,Array1[di]
		
		mov dl,Array1[si]		
		.if ((al==ah))
			mov hlc,al
		.else
			mov hlc,6
		.endif
		
		popA
endm
checkLeftAboveDiagonalCrush macro
	
		pushA
		mov lac,6
		mov i,si  
		mov j,si  ;  for left above diagonal crush
		sub i,16
		sub j,8
		mov di,i
		mov al,Array1[di]
		mov di,j
		mov ah,Array1[di]
			
		.if ((al==ah))
			mov lac,al
		.else
			mov lac,6
		.endif
		popA
endm
checkLeftDownDiagonalCrush macro
		pushA
		mov ldc,6
		mov i,si  ;  for left down diagonal crush
		mov j,si
		add i,12
		add j,6
		mov di,i
		mov al,Array1[di]
		mov di,j
		mov ah,Array1[di]
				
		.if ((al==ah))
			mov ldc,al
		.else
			mov ldc,6
		.endif
		popA
endm
checkRightAboveDiagonalCrush macro
		pushA
		mov rac,6
	    mov i,si  ;	 for right above diagonal crush
		mov j,si
		sub i,12
		sub j,6
		mov di,i
		mov al,Array1[di]
		mov di,j
		mov ah,Array1[di]
			
		.if ((al==ah))
			mov rac,al
		.else
			mov rac,6
		.endif
		popA
endm
checkRightDownDiagonalCrush macro
		pushA
		mov rdc,6
		mov i,si  ;  for right down diagonal crush
		mov j,si
		add i,16
		add j,8
		mov di,i
		mov al,Array1[di]
		mov di,j
		mov dh,Array1[di]
				
		.if ((al==ah))
			mov rdc,al
		.else
			mov rdc,6
		.endif
		
		popA
endm 
checker macro
	pushA
		push si
		MOV a,0
		
			
			checkVerticalAboveCrush
			checkVerticalDownCrush
			checkHorizontalRightCrush
			checkHorizontalLeftCrush
			;checkRightDownDiagonalCrush
			;checkLeftDownDiagonalCrush
			;checkRightAboveDiagonalCrush
			;checkRightAboveDiagonalCrush
			.if((vac!=6) || (vdc!=6) || (hrc!=6) || (hlc!=6))
				iterate:
						mov a,1
						generateRandomNumber
						.if((dl==vac) || (dl==vdc) || (dl==hrc) || (dl==hlc))
							
							jmp iterate
						.else
							jmp exit
						.endif
			.else 
				jmp exit
			.endif
			
		exit:
			pop si
			.if(a==1)
				mov Array1[si],dl	
			.endif
	popA
endm
checkCrush1 macro
	mov si,0
	mov cx,49
	crush:
		mov dl,Array1[si]
		MOV dh,0
		pushA
		checker
		popA 
		dec cx
		.if(cx==0)
			jmp re
		.endif
		inc si
	jmp crush
	 re: 
endm
generateRandomNumber macro			; generate a rand no using the system time
   
   MOV AH, 00h						; interrupts to get system time        
   INT 1AH							; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 5    
   div  cx							; here dx contains the remainder of the division - from 0 to 9
endm
Generate1 macro
		pushA
		mov cx,49
		mov di,0
		mov si,0
		L:
			push cx
			generateRandomNumber
			mov Array1[si],dl
			Call delay
			inc si
			pop cx
			.if(cx==0)
				jmp chk
			.endif
			dec cx
		jmp L
		chK:	
		popA
endm
Generate2 macro
		pushA
		mov cx,39
		mov di,0
		mov si,0
		L2:
			push cx
			generateRandomNumber
			mov Array2[si],dl
			Call delay
			inc si
			pop cx
			.if(cx==0)
				jmp chk2
			.endif
			dec cx
		jmp L2
		chK2:	
		popA
endm
Generate3 macro
		pushA
		mov cx,36
		mov di,0
		mov si,0
		L3:
			push cx
			generateRandomNumber
			mov Array3[si],dl
			Call delay
			inc si
			pop cx
			.if(cx==0)
				jmp chk3
			.endif
			dec cx
		jmp L3
		chK3:	
		popA
endm


checkVerticalCrush macro

		pushA	
		mov vac,6
		mov vdc,6
		mov i,si  ; i and j for vertical above crush
		mov j,si
		sub i,14
		sub j,7
		.if(i>=0)
			mov di,i
			mov al,Array1[di]
			mov di,j
			mov ah,Array1[di]
			mov bh,Array1[si]

			.if((ah==al) && (ah==bh))
				mov vac,al
				.if(al==0)
					add score,5
				.elseif(al==1)
					add score,10
				.elseif(al==2)
					add score,15
				.elseif(al==3)
					add score,20
				.endif
			.elseif(bh==4)
			   .if((vac!=6))
					add score,50
				.endif
			.else
				mov vac,6
			.endif
		.endif
	


		mov x,si  ;  x and y for vertical down crush
		mov y,si
		add x,14
		add y,7

		.if(x<=48)
			mov di,x
			mov al,Array1[di]
			mov di,y
			mov ah,Array1[di]
			mov bh,Array1[si]
		
			.if((ah==al) && (ah==bh))
				mov vdc,al
				.if(al==0)
					add score,5
				.elseif(al==1)
					add score,10
				.elseif(al==2)
					add score,15
				.elseif(al==3)
					add score,20
				.endif
			.elseif(bh==4)
				.if((vac!=6) && (vdc!=6))
					add score,30
				.endif
			.else
				mov vdc,6
			.endif
		.endif

		
		.if(vdc!=6)
			;mov si,x
		.endif

		mov di,si               ; di is the top index of the that particular column
		.while((di>6))
			sub di,7	
		.endw

		


		popA		
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;File Wirting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteInFile macro

	mov dx, offset file ; Load address of String “file”
	mov al,2			; Open file (read-only)
	mov ah, 3dh			; Load File Handler and store in ax
	int 21h
	
	mov di,ax  ; di is a handler

	MOV AH,42H       ; move file pointer function
	MOV BX,di        ; Bx holds the handle which tells in which file we have to write
	XOR CX,CX        ; Movig 0 bytes to CX
	XOR DX,DX        ; Movig 0 bytes to DX
	MOV AL, 2        ; Movement Code: 0 means move relative to beginning of file
	INT 21H          ; 1 means move relative to the current Pointer location
	                 ;2 means move relative to the end of file; 
	
	



	mov cx,2					; moving to Next Line
	mov bx,di
	lea dx,endl
	mov ah,40h
	int 21h

	;;;;;;;;;;;;;;;;;;;;;;Name;;;;;;;;;;;;;;;;;;;;;;
	mov cx,lengthof NameP			
	dec cx
	mov bx,di
	mov dx,offset NameP
	mov ah,40h
	int 21h


	mov cx,10
	mov si,0
	llll:
		mov dl,UName[si]
		.if(dl=='$')
			jmp reee
		.endif
		inc si
	Loop llll
	reee:
		dec si
   

	mov cx,si					
	mov bx,di
	mov dx,offset UName
	mov ah,40h
	int 21h

	;;;;;;;;;;;;;;;;;;;;;;;;;;;NextLine;;;;;;;;;;;;;;;;;;;

	mov cx,2					; moving to Next Line
	mov bx,di
	lea dx,endl
	mov ah,40h
	int 21h

	;;;;;;;;;;;;;;;;;;;;;;;;;Level ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov cx,lengthof levelStr				; saving the Level 
	dec cx
	mov bx,di
	mov dx,offset levelStr
	mov ah,40h
	int 21h

	
	mov cx,1								; Storing the Score
	mov bx,di
	mov dh,0
	mov dl,LevelNo
	add dx,48
	mov i,dx
	mov dx,offset i
	mov ah,40h
	int 21h




	mov cx,2					; moving to Next Line
	mov bx,di
	lea dx,endl
	mov ah,40h
	int 21h


	;;;;;;;;;;;;;;;;;;;;;;;Score ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov cx,lengthof Str3				; saving the Level 
	dec cx
	mov bx,di
	mov dx,offset Str3
	mov ah,40h
	int 21h


	mov ax,Score
	mov var1,ax
	mov count,0
	output1111:                          ; it is moving the result on stack to display
			mov ax,var1
			mov dx, 0
			mov bx,10
			div bx
			mov cx,0h
			mov cx,dx
			push cx
			mov var1, ax
			add count,1
			cmp var1,0
		jne output1111

		disp5555:                         ; it will display the result by poping one by one
			cmp count,0
			je retrn1111
			pop dx

			mov cx,1								; Storing the Score
			mov bx,di
			add dx,48
			mov i,dx
			mov dx,offset i
			mov ah,40h
			int 21h
			sub count,1
			jmp disp5555
	retrn1111:
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
endm


ResetMouse macro
	pushA
	mov ax,0
	int 33h
	popA
endm
showMouse macro
	pushA
		mov ax,1
		int 33h	
	popA
endm
HideMouse macro
	pushA
		mov ax,2
		int 33h
	popA
endm

SetMousePosition macro
	pushA
		mov ax,4
		; cx will contain the x-cordinate
		; dx will contain the y-cordinate
		int 33h
	popA
endm
RestrictMouse macro
	pushA
	
		; Horizontaly Restriction
		mov ax,7
		mov cx,117
		mov dx,516
		int 33h	
		; Vertically Resrtriction
		mov ax,8
		mov cx,51
		mov dx,450
		int 33h		
	popA	
endm
space macro
	mov dl,' '
	mov ah,02h
	int 21h
endm
nextline macro
	mov dl,10
	mov ah,02h
	int 21h
	mov dl,13
	mov ah,02h
	int 21h
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Calls from Main  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main proc
  
    mov AX, @data
    mov DS, AX
				
   displayInitialScreen
   drawSquare   		;Call to Intial Square
   GetName				; Call to display the string of Name
   inputPlayerName            ;Call to for Input of Name
   displaylevels
   EnterLevelNo 
   .if(levelNO==1)
		displayRules			;Call to display rules
		displayLevel1				;Call to display Third Window
		Call DrawStrip
		Call printName					; Print Name on top
		Call printMoves					; Print Moves on top
		Call printScore					; Print Score on top
		Call printLevelNo				; print level No on top
		Generate1
		CheckCrush1
		DrawShapes1					    ; Print to draw random shapes on screen
		showMouse
		RestrictMouse
		Call CheckMousePressed
		Call GameEnd
		
	.elseif(levelNo==2)
	
		; level 2
		displaylevel2				; print the grid on top
		Call DrawStrip
		CALL printName					; Print Name on top
		Call printMoves					; Print Moves on top
		Call printScore					; Print Score on top
		Call printLevelNo				; print level No on top
		Generate2					    ; Generate the random values and store in Array2
		;checkCrush2					; check for the possibility of crush, if so, replace the number with some unique number
		DrawShapes2
		showMouse
		RestrictMouse
		Call CheckMousePressed
		Call delay
		Call GameEnd
		
	.elseif(LevelNo==3)
		displayLevel3
		Call DrawStrip
		Call printName					; Print Name on top
		Call printMoves					; Print Moves on top
		Call printScore					; Print Score on top
		Call printLevelNo				; print level No on top
		Generate3					    ; Generate the random values and store in Array2
		;checkCrush3					; check for the possibility of crush, if so, replace the number with some unique number
		DrawShapes3
		showMouse
		RestrictMouse
		Call CheckMousePressed
		Call delay
		Call GameEnd
   .endif
   
WriteInFile  
mov ah,4ch
int 21h
main endp
DrawStrip proc
	mov si,00h
	mov di,10
	mov i,00
	.while i<=25
		.while si<=640
			mov ah,0Ch
			mov al,00h  ; Color
			mov cx,si
			mov dx,di
			mov bh,0
			int 10h
			inc si
		.endw
		inc i
		mov si,00
		inc di
	.endw
	ret
DrawStrip endp
printLevelNo proc
	;------------Print Moves --------
	mov dh, 1; rows
	mov dl, 40; columns
	mov si, 0
	levelStrr:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, LevelStr[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp LevelStr[si], "$"
	jne LevelStrr
	;-----------Print Number------------
	mov dl,LevelNo
	add dl,48
	mov ah,02
	int 21h

	ret
printLevelNo endp
printname proc
	;------------Printing Name --------
	
	mov dh, 1; rows
	mov dl, 1; columns
	mov si, 0
	disp:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Str2[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Str2[si], "$"
	jne disp
	mov dh, 1; rows
	mov si, 0
	;mov cx, lengthof UName
	disp1:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, UName[si]
		mov bl, 0Fh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp UName[si+1],"$"
	jne disp1
	ret
printname endp
printMoves proc
	;------------Print Moves --------
	mov dh, 1; rows
	mov dl, 20; columns
	mov si, 0
	disp4:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Str4[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Str4[si], "$"
	jne disp4
	
	;-----------Print Number------------
	mov ax,Moves
	mov var1,ax
	mov count,0
	output1:                          ; it is moving the result on stack to display
			mov ax,var1
			;cmp ax,0
			;je disp3
			mov dx, 0
			mov bx,10
			div bx
			mov cx,0h
			mov cx,dx
			push cx
			mov var1, ax
			add count,1
			cmp var1,0
		jne output1
	
		disp5:                         ; it will display the result by poping one by one
			cmp count,0
			je retrn1
			pop dx
			add dx,48
			mov ah,02
			int 21h
			sub count,1
			jmp disp5
	retrn1:
	ret
printMoves endp
printScore proc
	;------------Print Score --------
	mov dh, 1; rows
	mov dl, 65; columns
	mov si, 0
	disp2:
		mov ah, 02
		int 10h
		mov ah, 09 
		mov al, Str3[si]
		mov bl, 0Eh
		mov cx, 1
		mov bh, 0
		int 10h	
		inc dl
		inc si
		cmp Str3[si], "$"
	jne disp2
	
	;-----------Print Number------------
	mov ax,Score
	mov var1,ax
	mov count,0
	output:                          ; it is moving the result on stack to display
			mov ax,var1
			;cmp ax,0
			;je disp3
			mov dx, 0
			mov bx,10
			div bx
			mov cx,0h
			mov cx,dx
			push cx
			mov var1, ax
			add count,1
			cmp var1,0
		jne output
	
		disp3:                         ; it will display the result by poping one by one
			cmp count,0
			je retrn
			pop dx
			add dx,48
			mov ah,02
			int 21h
			sub count,1
			jmp disp3
	retrn:
	ret
printScore endp

delay proc
	push ax
	push bx
	push cx
	push dx
	mov cx,100
	startLoop:
		mov ax,00h
		push CX
		mov cx,100
		innerloop:
			mov ax,00h
			mov dx,5344
			mov bx,5000
			
		Loop innerloop
		pop cx
	Loop startLoop
	pop dx
	pop cx
	pop bx
	pop ax
	ret
delay endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; mouse Interfacing ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetButtonPressedInformation proc
	
		mov ax,5
		int 33h
		; if ax =2, it is right pressed
		; if ax =1 it  is left pressed	
		ret	
GetButtonPressedInformation endp
GetMouseReleaseInformatiom proc

		mov ax,6
		mov bx,0 ; left buttion
		int 33h
		
		;CX = horizontal position at last release
		;DX = vertical position at last release
		ret
GetMouseReleaseInformatiom endp
GetMouseCurrentPosition proc
	
		mov ax,3
		int 33h
		; cx will contain the x-cordinate
		; dx will contain the y-cordinate
		ret
GetMouseCurrentPosition endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Checking the Left Click for All Levels ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckLeftClick proc

	mov ax,CurrClickX		; changing Previous click cordinates to current Click Co-ordinates
	mov prevClickX,ax
	mov ax, CurrClickY
	mov prevClickY,ax
		
	mov color,14
	HideMouse
	DrawBoxAroundClick
	ShowMouse
	mov ax,CurrClickIndex		; changing the previous index of Array 
	mov PrevClickIndex,ax
	mov x,0
	mov y,0
	.if(LevelNo==1)
		pop ax	; pop ret address
		pop dx
		pop cx
		push ax	; push ret address
		mov si,cx	; storing the x-cordinate of left click
		mov di,dx	; storing the y-cordinate of left click
		mov cx,7
		mov ax,117
		mov bx,174
		forX:		; loop for getting nearest x-cordinates of click
					
				.if((si>=ax) && (si<=bx))
					mov CurrClickX,ax	; left boundary along x-cordinate
					jmp r1
				.else
					inc x		; traversing along the x-axis
					mov ax,bx
					add bx,57
				.endif
		loop forX
		r1:
		mov cx,7
		mov ax,51
		mov bx,108
		forY:		; loop for getting nearest 	y-cordinates of click
			
				.if((di>=ax) && (di<=bx))
					mov CurrClickY,ax ; uper boundary of y-cordinate
					jmp r2
				.else
					inc y		; traversing along the y-axis
					mov ax,bx
					add bx,57
				.endif
		loop forY
				
		r2:
		
			mov ax,y
			mov bx,7
			mul bx
			add ax,x
			mov CurrClickIndex,ax ; updating the curent click index 
			mov color,02
			HideMouse
			DrawBoxAroundClick ; It will create a green box around the click
			ShowMouse
		ret
	.elseif(levelNO==2)
		pop ax	; pop ret address
		pop dx
		pop cx
		push ax	; push ret address
		mov si,cx	; storing the x-cordinate of left click
		mov di,dx	; storing the y-cordinate of left click
		
		
		.if(((di>=165) && (di<=222)) || ((di>=279) && (di<=336)))
			mov cx,7
			mov ax,117
			mov bx,174
		.else
			mov cx,5
			mov ax,174
			mov bx,231
		.endif
		
		forXC:		; loop for getting nearest x-cordinates of click
					
				.if((si>=ax) && (si<=bx))
					mov CurrClickX,ax	; left boundary along x-cordinate
					jmp r11
				.else
					inc x		; traversing along the x-axis
					mov ax,bx
					add bx,57
				.endif
		dec cx
	   .if(cx==0)
			jmp  r11
		.else
			jmp forXC
		.endif
		r11:
		mov cx,7
		mov ax,51
		mov bx,108
		forYC:		; loop for getting nearest 	y-cordinates of click
			
				.if((di>=ax) && (di<=bx))
					mov CurrClickY,ax ; uper boundary of y-cordinate
					jmp r22
				.else
					inc y		; traversing along the y-axis
					mov ax,bx
					add bx,57
				.endif
		loop forYC
				
		r22:
			.if(y>=3 && y<5)
				add x,2
			.elseif(y>=5)
				add x,4
			.endif
			mov ax,y
			mov bx,5
			mul bx
			add ax,x
			mov CurrClickIndex,ax ; updating the curent click index of Array 
			
			mov color,02
			HideMouse
			DrawBoxAroundClick ; It will create a green box around the click
			ShowMouse
		ret
		.elseif(LevelNo==3)
		pop ax	; pop ret address
		pop dx
		pop cx
		push ax	; push ret address
		mov si,cx	; storing the x-cordinate of left click
		mov di,dx	; storing the y-cordinate of left click
		mov cx,7
		mov ax,117
		mov bx,174
		.if(((si>=288)&&(si<=345)) || ((di>=222)&&(di<=279)))
			ret
		.endif
		
		forXX:		; loop for getting nearest x-cordinates of click
					
				.if((si>=ax) && (si<=bx))
					mov CurrClickX,ax	; left boundary along x-cordinate
					jmp r111
				.else
					.if(ax==288)
						mov ax,bx
						add bx,57
					.else
						inc x		; traversing along the x-axis
						mov ax,bx
						add bx,57
					.endif
					
				.endif
		dec cx
	   .if(cx==0)
			jmp  r111
		.else
			jmp forXX
		.endif
		
		r111:
		mov cx,7
		mov ax,51
		mov bx,108
		forYY:		; loop for getting nearest 	y-cordinates of click
			
				.if((di>=ax) && (di<=bx))
					mov CurrClickY,ax ; uper boundary of y-cordinate
					jmp r222
				.else
					.if(ax==222)
						mov ax,bx
						add bx,57
					.else
						inc y		; traversing along the y-axis
						mov ax,bx
						add bx,57
					.endif
					
				.endif
		loop forYY
				
		r222:
			
			mov ax,y
			mov bx,6
			mul bx
			add ax,x
			mov CurrClickIndex,ax ; updating the curent click index of Array
			mov color,02
			HideMouse
			DrawBoxAroundClick ; It will create a green box around the click
			ShowMouse
		ret
		
	.endif
	
CheckLeftClick endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Check for the swap for All levels ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
callChecker proc
	
	checkCrush1
ret
CallChecker endp

CheckSwap proc
	
	mov ax,PrevClickIndex
	mov si,PrevClickIndex
	mov bx,CurrClickIndex
	mov di,CurrClickIndex
	mov i,0
	sub ax,bx				    ; if previous index is larger than current index 
	.if(LevelNo==1)
		.if((ax==1)||(ax==-1)||(ax==7)||ax==-7)
			
			mov al,Array1[si]    ; swaping the values in the Array 
			mov bl,Array1[di]
			mov Array1[si],bl
			mov Array1[di],al	
			
			.if(al==bl)
				mov i,0
			.else
				push di
				checkVerticalCrush
				pop di
				mov si,di
				checkVerticalCrush
				;Call CallChecker
				mov i,1	
			.endif			
		.endif
		.if(i==1)
			HideMouse
			dec moves
			Call DrawStrip
			Call printName
			Call printScore
			Call printMoves
			Call printLevelNo
			DrawShapes1
			ShowMouse
		
		.endif
		ret
	.elseif(LevelNo==2)
		.if((ax==1)||(ax==-1)||(ax==5)||(ax==-5)|| (ax==6) || (ax==-6)) 
			
			mov al,Array2[si]    ; swaping the values in the Array 
			mov bl,Array2[di]
			mov Array2[si],bl
			mov Array2[di],al	
			.if(al==bl)
				mov i,0
			.else
				mov i,1
				
			.endif
			
		.endif
		.if(i==1)
			HideMouse
			dec moves
			Call DrawStrip
			Call printName
			Call printScore
			Call printMoves
			Call printLevelNo
			DrawShapes2
			ShowMouse
		
		.endif
		ret
		.elseif(LevelNo==3)
			.if((ax==1)||(ax==-1)||(ax==6) ||(ax==-6)) 
			
			mov al,Array3[si]    ; swaping the values in the Array 
			mov bl,Array3[di]
			mov Array3[si],bl
			mov Array3[di],al	
			.if(al==bl)
				mov i,0
			.else
				mov i,1
				
			.endif
			
		.endif
		.if(i==1)
			HideMouse
			dec moves
			Call DrawStrip
			Call printName
			Call printScore
			Call printMoves
			Call printLevelNo
			DrawShapes3
			ShowMouse
		
		.endif
		ret
			
	.endif
	
CheckSwap endp
CheckMousePressed proc
		mov moves,15
		ppp:
		
			Call GetButtonPressedInformation
			.if(ax==1)
				showMouse
				Call GetMouseCurrentPosition
				push cx
				push dx
				Call CheckLeftClick
				Call CheckSwap
			.endif
			.if(moves>=1)
				jmp ppp
			.endif
		ret 
CheckMousePressed endp

GameEnd proc
		;displayInitialScreen
		drawSquare
		mov dh, 13 ; rows
		mov dl, 30 ; columns
		mov si, 0
		displaystring111:
			mov ah, 02
			int 10h
			mov ah, 09 
			mov al, GameEndP[si]
			mov bl, 0Eh
			mov cx, 1
			mov bh, 0
			int 10h	
			inc dl
			inc si
			cmp GameEndP[si], "$"
		jne displaystring111
		
		
		mov dh, 14 ; rows
		mov dl, 35 ; columns
		mov si, 0
		displaystring1111:
			mov ah, 02
			int 10h
			mov ah, 09 
			mov al, WellPlayedP[si]
			mov bl, 0Eh
			mov cx, 1
			mov bh, 0
			int 10h	
			inc dl
			inc si
			cmp WellPlayedP[si], "$"
		jne displaystring1111
		ret
GameEnd endp
end main
	
	


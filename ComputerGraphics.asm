bits 16
org 0x7C00
	cli
	;WRITE YOUR CODE HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

mov ah ,0x02
mov al ,8
mov dl ,0x80
mov dh ,0
mov ch ,0
mov cl ,2
mov bx ,BeginEveryThing
int 0x13
jmp BeginEveryThing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
times (510 - ($ - $$)) db 0
db 0x55, 0xAA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BeginEveryThing:
	
	theBigLoop:
	
	 xor eax , eax 
	 mov edi, 0xB8000
	 mov esi, 0xB8000
	 xor ebx,ebx
	 mov edx, WelcomString
	 loop0:
	 mov al, [edx];
	 mov byte [edi], al;
	 inc edi;
	 inc edi;
	 inc edx;
	 inc bx;
	 call cursor
	 cmp byte[edx],0;
	 jne loop0;
	 
check_key:
	in  al , 0x64;
	and al, 1;
	jz check_key
	in al, 0x60;
	mov bl , al 
	cmp bl , 0x82
	je _activateMouse
	cmp al , 0x83
	je _activeKeyboard
	call _clearScreen
	jmp theBigLoop
	;jmp check_key
	
cursor :
pushad
mov al,0x0f
mov dx,0x03D4
out dx,al

mov al,bl
mov dx,0x03D5
out dx,al

xor eax,eax

mov al,0x0e
mov dx,0x03D4
out dx,al

mov al,bh
mov dx ,0x03D5
out dx,al

popad
ret

_clearScreen :
	cmp edi,0xB8000
	je l4
	loop3:
	mov al,0x20
	mov [edi],al
	sub edi,2
	cmp edi,0xB8000
	jg loop3
	
l4:
	xor ebx,ebx
	call cursor
	ret

_exit :
		cli
		mov ah , 0
		mov al , 3h
		int 0x10

	call _clearScreen
	jmp theBigLoop
	
_activateMouse :
jmp mouse	

_activeKeyboard:
	call _clearScreen
	mov edx, keyboardString;
	loop4:
	mov al, [edx];
	mov byte [edi], al;
	inc edi;
	inc edi;
	inc edx;
	inc ebx
	call cursor
	cmp byte[edx],0;
	jne loop4;
	
check_key1:
	in al, 0x64;
	and al, 1;
	jz check_key1
	;If pressed get key
	in al, 0x60;
	cmp al,0x1C
	jne l2

l2:
	cmp al,0x01
	je _exit
	cmp al,0x36
	jg _activeKeyboard
	cmp al , 0xBA
	je _activeKeyboard
	cmp al , 0x0E
	je _activeKeyboard
	cmp al , 0x0F
	je _activeKeyboard
	cmp al , 0x39
	je _activeKeyboard
	cmp al , 0x36
	je _activeKeyboard
	cmp al , 0x2A
	 je _activeKeyboard
	
	cmp al, 0x02
	je _lines
	cmp al, 0x03
	je _triangle
	cmp al, 0x04
	je colorFul_rectangles
	cmp al, 0x05
	je _circle
	call _clearScreen
	jmp _activeKeyboard	

	keyboardString : db "press 1 for diagonal line , 2 for triangles , 3 for rectangles , 4 for circle   press ESC anywhere  in Shapes mode to return to main menu",0
	WelcomString: db "press 1 for mouse free drawing , 2 to choose between Shapes ",0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
mouse:	

	  cli
	  mov ax,13h 	; mode = 13h 
     int 10h 	    ; call bios service
	;enable mouse
		xor        eax, eax
      call        WriteMouseWait
      mov         al, 0xa8
      out         0x64, al
	   
	  ;restore default settings
	   mov         al, 0xf6
      call        MouseWrite


	   ;enable mouse
	   mov         al, 0xf4
      call        MouseWrite
	   
	   
	   
	  ;Main
	  
	  xor         ecx, ecx
     xor         eax, eax
	   
	  waitkey: 
	   in          al, 0x64
      and         al, 0x20
      jz          waitkey
	 
	 
	   cmp        byte[LEFTbutton],0x00
	   jne        hom
	   mov ah,0Ch 	; function 0Ch
	   mov al,0 	; color 4 - black
	   mov cx,[xmouse] 	; x position 
	   mov dx,[ymouse] 	; y position 
	   int 10h 	;    call BIOS service
   
       hom:
	   call        MouseRead
       mov         byte [k], al    ;get k
	   and         al,0x01
	   mov         [LEFTbutton],al
	  
	  ;get delta x
	  xor         ax,ax
	  xor         dx,dx
	  call        MouseRead
	  movsx       dx,al
	  mov         ax,dx
      add         [xmouse], ax
	  
	  
	  cmp         word[xmouse],0  ;borders
	  jg          here
	  mov         word[xmouse],0
	  
	  here:
	  cmp         word[xmouse],319 ;borders
	  jl          here2
	  mov         word[xmouse],319

	  here2:
	  
	  ;get delta y
	  xor         ax,ax 
	  xor         dx,dx
      call        MouseRead
	  movsx       dx,al
	  mov         ax,dx
      sub         [ymouse], ax  
      
	  
	  cmp         word [ymouse],199  ;borders
	  jl          here3
	  mov         word[ymouse],199
       
	  here3:
	  cmp         word [ymouse],0   ;borders
	  jg          here4
	  mov         word [ymouse],0
	  
	  here4:
	  call        MouseRead      ;get z
      mov         byte [z], al
	
       cmp        byte[LEFTbutton],0x00
	   je         her
	   mov        al,14	; color 5 - purple
	   jmp        no
	   
	   her:
	   mov       al,10 	; color 10 - green
	   no:
	   mov       ah,0Ch 	; function 0Ch
	   mov       cx, [xmouse]	; x position 
	   mov       dx, [ymouse]	; y position 
	   int       10h 	    ; call BIOS service
    
	   jmp waitkey
	  
			
WriteMouseWait:
	  mov        ecx, 1000
	strt1:  
      in         al, 0x64
      and        al, 0x02
      jz         fin1    
      dec        ecx
	  cmp        ecx,0
	  jnz        strt1
	  
    fin1:
	  ret
	  
ReadMouseWait:
	  mov        ecx, 1000
	strt2:  
      in         al, 0x64
      and        al, 0x01
      jnz        fin2    
      dec        ecx 
	  cmp        ecx,0
	  jnz        strt2
	 
    fin2:
	  ret
	
	MouseRead:
      call         ReadMouseWait
      in           al, 0x60
      ret
	
	MouseWrite:
      mov         dh, al
      call         WriteMouseWait
      mov         al, 0xd4
      out         0x64, al
      call         WriteMouseWait
      mov         al, dh
      out         0x60, al
      call         ReadMouseWait
      in         al, 0x60
      ret	  
	  	
xmouse: dw 0      
ymouse: dw 0
z: dw 0
k: dw 0
LEFTbutton: db 0
  	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

_circle:
	mode13h:
	mov ah, 0
	mov al , 0x13
	int 0x10
	;jmp drawCircle
	
	
	mov word [circolor],1
	mov word [x2Circle], 160
	mov word [y2Circle] , 100
	mov word [radius] ,75
	mov word [errCircle ],  0
	mov word [xCircle], 0
	mov word [yCircle], 0
	mov word [tempxCircle], 0
	mov word [tempyCircle], 0
	
	
	jmp beginDrawingCircles
	
	delay:
	mov eax , 1000
	delayLoop:
	dec eax 
	cmp eax , 0
	jge delayLoop
	ret
	
	
	myCirclePixel:
	
				mov ah , 0Ch
				mov al ,  byte [circolor]
				mov cx ,  [tempxCircle]
				mov dx ,  [tempyCircle]
				int 10h
				ret

	drawCircle:
	mov ax , [radius]
	mov word [xCircle] , ax 
	mov word [yCircle] ,   0
	mov word [errCircle] ,	0
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	drawLoop:
	mov ax , [x2Circle]
	add ax , [xCircle]
	mov [tempxCircle], ax
	mov bx , [y2Circle]
	add bx , [yCircle]
	mov [tempyCircle] , bx
	call myCirclePixel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax , [x2Circle]
	add ax , [yCircle]
	mov [tempxCircle], ax
	mov bx , [y2Circle]
	add bx , [xCircle]
	mov [tempyCircle] , bx
	call myCirclePixel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax , [x2Circle]
	sub ax , [yCircle]
	mov [tempxCircle], ax
	mov bx , [y2Circle]
	add bx , [xCircle]
	mov [tempyCircle] , bx
	call myCirclePixel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax , [x2Circle]
	sub ax , [xCircle]
	mov [tempxCircle], ax
	mov bx , [y2Circle]
	add bx , [yCircle]
	mov [tempyCircle] , bx
	call myCirclePixel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax , [x2Circle]
	sub ax , [xCircle]
	mov [tempxCircle], ax
	mov bx , [y2Circle]
	sub bx , [yCircle]
	mov [tempyCircle] , bx
	call myCirclePixel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax , [x2Circle]
	sub ax , [yCircle]
	mov [tempxCircle], ax
	mov bx , [y2Circle]
	sub bx , [xCircle]
	mov [tempyCircle] , bx
	call myCirclePixel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax , [x2Circle]
	add ax , [yCircle]
	mov [tempxCircle], ax
	mov bx , [y2Circle]
	sub bx , [xCircle]
	mov [tempyCircle] , bx
	call myCirclePixel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov eax , [x2Circle]
	add eax , [xCircle]
	mov [tempxCircle], eax
	mov ebx , [y2Circle]
	sub ebx , [yCircle]
	mov [tempyCircle] , ebx
	call myCirclePixel
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	cmp word [errCircle], 0
	jge errBigger
	inc word [yCircle]
	mov ax ,[yCircle]
	shl ax , 1
	inc ax
	add [errCircle] , ax
	jmp done
	errBigger:
	dec word [xCircle]
	mov ax , [xCircle]
	shl ax ,1
	inc ax
	sub [errCircle],ax	
	done:
		mov ax , [xCircle]
		cmp ax , [yCircle]
		jg drawLoop
 ret  
 
 beginDrawingCircles: 
 xor esi ,esi 
 loop1:
 dec word [radius]
 inc word [circolor]
 xor eax, eax 
 loopDelay:
 inc eax 
 cmp eax ,10000000
 jl loopDelay
 call drawCircle
 add esi ,1
 cmp esi ,75
jl loop1

cli
				circleCheckKey:
					in al, 0x64;
					and al, 1;
					jz circleCheckKey
					in al , 0x60
					cmp al , 0x81
					jz _exit
					jmp circleCheckKey		

 
	circolor : dw 1
	x2Circle : dw 160
	y2Circle : dw 100
	radius : dw 75
	errCircle : dw 0
	xCircle : dw 0
	yCircle : dw 0
	tempxCircle : dw 0
	tempyCircle : dw 0
 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_triangle:
cli
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	ah, 0
	mov al, 0x13
	int 0x10
	
 mov cx , 25
 mov dx , 100
 VerticalLineLoop:
 mov ah , 0Ch
 mov al , 11
 pusha
 int 10h
 popa
 inc dx
 cmp dx , 175
 jl VerticalLineLoop

 mov cx , 25
 mov dx , 175
  HorizontalLineLoop:
  mov ah , 0Ch
  mov al , 11
  pusha
  int 10h
  popa
  inc cx
  cmp cx, 300
  jl HorizontalLineLoop

jmp begin
myTrianglePixel:
				mov ah , 0Ch
				mov al , byte [colorTriangle]
				mov cx ,  [xTriangle]
				mov dx ,  [yTriangle]
				int 10h
				ret 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		begin:	
			mov ax, word[x1Triangle]
			sub ax, word[x0Triangle]
			mov word [deltaxTriangle], ax

			mov bx, word [y1Triangle]
			sub bx, word [y0Triangle]
			mov word [deltayTriangle], bx

			mov ax, word[x0Triangle]
			mov [xTriangle] , ax

			mov ax, word [y0Triangle]
			mov [yTriangle], ax

			mov ax, word [deltayTriangle]
			shl ax ,1
			sub ax, word [deltaxTriangle]
			mov [pTriangle], ax		

		theLOOP:
				cmp word[pTriangle],0
				jl elseClause
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				call myTrianglePixel
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;						
				inc word [yTriangle] 	
				mov ax, [deltayTriangle]
				shl ax ,1
				mov bx, [deltaxTriangle]
				shl bx , 1
				sub ax ,bx
				add ax, [pTriangle]
				mov [pTriangle], ax
				jmp doneIf

elseClause:
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				call myTrianglePixel
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				mov ax , [deltayTriangle]
				add ax , ax 
				add ax, [pTriangle]
				mov [pTriangle] , ax			

				doneIf:		
				inc word [xTriangle]				
				mov ax , [xTriangle]
				cmp ax, [x1Triangle]
				jle theLOOP
				

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	mov cx , 150
	mov dx , 25
	negativeSlopeLine:
	mov ah , 0Ch
	mov al , 14
	pusha
	int 10h
	popa
	inc cx
	inc dx
	cmp dx , 75
	jl negativeSlopeLine
	
	mov cx , 150
	mov dx , 25
	positiveSlopeLine:
	mov ah , 0Ch
	mov al , 14
	pusha
	int 10h
	popa
	dec cx
	inc dx
	cmp dx , 75
	jl positiveSlopeLine

	 mov cx , 100
	 mov dx , 75
	 
  secondTriangleHorizontalLineLoop:
	mov ah , 0Ch
	mov al , 14
	pusha
   int 10h
   popa
   inc cx
   cmp cx, 200
  jl secondTriangleHorizontalLineLoop


  
  cli
				triangleCheckKey:
					in al, 0x64;
					and al, 1;
					jz triangleCheckKey
					in al , 0x60
					cmp al , 0x81
					jz _exit
					jmp triangleCheckKey
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
x0Triangle : dw 25
y0Triangle : dw 100
x1Triangle : dw 300
y1Triangle : dw 175

deltaxTriangle : dw 0
deltayTriangle : dw 0
pTriangle : dw 0
xTriangle : dw 0
yTriangle : dw 0
colorTriangle : dw 11
;color : dw 11
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_lines:
xor eax, eax 
			cli
			mov ah , 0
			mov ax,13h 	; mode = 13h 
			int 0x10	    ; call bios service
	 
	 jmp beginLines


myLinePixel:
				mov ah , 0Ch
				mov al , byte [lineColor]
				mov cx ,  [xLine]
				mov dx ,  [yLine]
				int 10h
				ret 

	beginLines:	
	
			mov ax, word[x1Line]
			sub ax, word[x0Line]
			mov word [deltaxLine], ax

			mov bx, word [y1Line]
			sub bx, word [y0Line]
			mov word [deltayLine], bx

			mov ax, word[x0Line]
			mov [xLine] , ax

			mov ax, word [y0Line]
			mov [yLine], ax

			mov ax, word [deltayLine]
			shl ax ,1
			sub ax, word [deltaxLine]
			mov [pLine], ax		

		theLOOPforLines:
				cmp word[pLine],0
				jl elseClauseforLines
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				call myLinePixel
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;						
				inc word [yLine] 	
				mov ax, [deltayLine]
				shl ax ,1
				mov bx, [deltaxLine]
				shl bx , 1
				sub ax ,bx
				add ax, [pLine]
				mov [pLine], ax
				jmp doneIfforLines

elseClauseforLines:
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				call myLinePixel
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				mov ax , [deltayLine]
				add ax , ax 
				add ax, [pLine]
				mov [pLine] , ax			

				doneIfforLines:		
				inc word [xLine]				
				mov ax , [xLine]
				cmp ax, [x1Line]
				jle theLOOPforLines
				
				cli
				LineCheckKey:
					in al, 0x64;
					and al, 1;
					jz LineCheckKey
					in al , 0x60
					cmp al , 0x81
					jz _exit
					jmp LineCheckKey
					
				x0Line  : dw 0
				y0Line	 : dw 0
				x1Line : dw 320
				y1Line : dw 200
				
				xLine : dw 0
				yLine : dw 0
				pLine : dw 0
				deltaxLine : dw 0
				deltayLine : dw 0
				
				lineColor : db 40
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
colorFul_rectangles:

cli
			mov ah , 0
			mov ax,13h 	; mode = 13h 
			int 0x10	    ; call bios service

			mov word [x],0
			mov word [y],0
			mov word [beginX],25
			mov word [beginY],25
			mov word [endX],50
			mov word [endy],100
			mov byte [Rectcolor],10
			
jmp beginRectangles 

		timeFunction:
		xor eax, eax
		timeLoopreturn:
		inc eax 
		cmp eax , 100000000
		jl timeLoopreturn
		ret

	rectanglePixel:
				mov ah , 0Ch
				mov al ,  byte [Rectcolor]
				mov cx ,  [x]
				mov dx ,  [y]
				int 10h
				ret
	
	drawRectangle	:			
	beginTheCode:
	mov ax , word [beginX]
	mov word[x] , ax
	mov ax , word [beginY]
	mov word[y] , ax
	
	RectangleLoop:
	horizontalLine:
	call rectanglePixel
	inc word [x]
	mov ax , word [endX]
	cmp word [x],ax
	jl horizontalLine
	mov ax , word [beginX]
	mov word [x],ax
	inc word[y]
	mov ax , word [endy]
	cmp word [y], ax
	jl RectangleLoop
	ret
			

beginRectangles:
call drawRectangle

call timeFunction

mov  word [Rectcolor] , 15
mov word [beginX] , 50
mov word [endX] , 75
call drawRectangle

call timeFunction

mov  word [Rectcolor] , 4
mov word [beginX] , 75
mov word [endX] , 100
call drawRectangle

call timeFunction

mov word [beginY] , 100
mov word [endy]   , 175

call timeFunction

mov  word [Rectcolor] , 1
mov word [beginX] , 150
mov word [endX] , 175
call drawRectangle

call timeFunction

mov  word [Rectcolor] , 15
mov word [beginX] , 175
mov word [endX] , 200
call drawRectangle

call timeFunction

mov  word [Rectcolor] , 4
mov word [beginX] , 200
mov word [endX] , 225
call drawRectangle


cli
				RectCheckKey:
					in al, 0x64;
					and al, 1;
					jz RectCheckKey
					in al , 0x60
					cmp al , 0x81
					jz _exit
					jmp RectCheckKey


x : dw 0
y : dw 0	
beginX : dw 25
beginY : dw 25
endX : dw 50
endy : dw 100
Rectcolor : db 10
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

times (0x400000 - 512) db 0

db 0x63, 0x6F, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x78, 0x00, 0x00, 0x00, 0x02
db	0x00, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
db	0x20, 0x72, 0x5D, 0x33, 0x76, 0x62, 0x6F, 0x78, 0x00, 0x05, 0x00, 0x00
db	0x57, 0x69, 0x32, 0x6B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x78, 0x04, 0x11
db	0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xE6, 0xB9, 0x49, 0x44, 0x4E, 0x1C
db	0x50, 0xC9, 0xBD, 0x45, 0x83, 0xC5, 0xCE, 0xC1, 0xB7, 0x2A, 0xE0, 0xF2
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
;==============================================================
;Simple Black jack
;Brandon Wells
;==============================================================
.model small
.386
.stack 100h
.data
		 
	menu_select db ?
	;sys prompt001
	lb db ',','$'
	prompt_arr db 0ah,0dh,'>','$'
	newline db 10,13,'$'
	dealer_val db 0ah,0dh,'Dealers Hand Value:','$'
	player_val db 0ah,0dh,'Your Hand:','$'
	line db 0ah,0dh,'=======================================','$'
	;menu dialog
	prompt001 db 0ah,0dh,'Welcome to blackjack.. ','$'
	prompt002 db 0ah,0dh,'Please select from the following  1.Play game,  2.exit game','$'
	prompt004 db 0ah,0dh,'Please select from the following  1.Hit,  2.Stay','$'
	prompt003 db 0ah,0dh,'Invalid Instruction','$'
	;Dealer dialog
	promptA db 0ah,0dh,'Setting up Dealers hand:','$'
	promptP db 0ah,0dh,'Setting up Players hand:','$'
	promptDS db 0ah,0dh,'The dealers starting hand is: ','$'
	promptPS db 0ah,0dh,'Your starting hand is: ','$'
	promptB db 0ah,0dh,'Press any button to continue:','$'
	promptC db 0ah,0dh,'You draw a card with a value of: ','$'
	promptD db 0ah,0dh,'The dealer draws a card with a value of: ','$'
	promptN db 0ah,0dh,'You now have a hand of: ','$'
	promptW db 0ah,0dh,'You have won this hand: ','$'
	promptL db 0ah,0dh,'You have lost this hand: ','$'
	promptF db 0ah,0dh,'CPUs Turn: ','$'
	promptBU db 0ah,0dh,'Its a bust: ','$'
	promptTW db 0ah,0dh,'Its a BlackJack: ','$'
	promptH db 0ah,0dh,'Dealer has the higher hand: ','$'
	color  db 2eh
	;game variables
	count dw 0
	delay_inc dw ?
	random_val dw ?
	player dw 0
	dealer dw 0
	player_response db ?
	
.code
	extrn outdec: proc
	include myMacros.asm

main proc
	mov ax,@data ;load ax with address where the data segment begins.
	mov ds,ax ;load datasegment pointer with address stored in ax
	
	
	L1:
	call refresh
	prtStr line
	prtStr prompt001
	prtStr line
	prtStr newline
	prtStr newline
	prtStr newline
	prtStr prompt002
	prtStr prompt_arr
	readCh menu_select
	mov cl, 1 ;move a 1 to the c low reg
	cmp cl,menu_select ;jump to game if cl  == 1
	je start; 
	mov cl,2 ;move a 2 to the c low reg
	cmp cl,menu_select ; jump to exit if cl == 2
	je exit
	prtStr prompt003 
	jmp L1
	
	start:
		call reset
		call game
		jmp L1
	exit:
		mov ax,3
		int 16
		mov ah,4ch	; load the high order byte of the ax with 4ch (return to DOS)
		int 21h
main endp		

;================
;Press to continue proc
;================
continue proc
	prtStr newline
	prtStr promptB ;print = "press any button to continue"
	readCh player_response ;read any response and store it somewhere
	ret
continue endp

;================
;Delay proc
;================	
delay proc
	mov delay_inc,0
	delayL:
	inc delay_inc
	cmp delay_inc,30000
	jle delayL
	ret
delay endp

;=================
;Reset game proc
;=================

reset proc
	mov player,0
	mov dealer,0
	mov count,0
ret
reset endp

;=================
;screen refresh
;=================
refresh proc
	clrScr
	chgColor color
	ret
refresh endp

;=================
;Draw Card
;=================

draw proc
	call refresh
	prtStr line
	prtStr promptC ;print = "You draw a card with a value of:"
	
	rndNum random_val,1,10 
	mov ax,random_val
	call outdec
	add player,ax
	xor ax,ax
	prtStr line
	prtStr newline
	prtStr promptN
	mov ax,player
	call outdec
	
	call continue
	call refresh
draw endp

;=================
;Draw Score
;=================

draw_score proc
	prtStr line
	prtStr dealer_val
	mov ax,dealer
	call outdec
	xor ax,ax
	prtStr line
	prtStr newline
	prtStr newline
	prtStr newline
	prtStr line
	prtStr player_val
	mov ax,player
	call outdec
	xor ax,ax
	prtStr line
	prtStr newline
	ret
draw_score endp

;=================
;Play Game
;=================

game proc

	;=============
	;Setup Dealers hand
	;=============
	call refresh ;clear screen
	prtStr line
	prtStr promptA ;print = "setting up dealers hand"
	prtStr line
	prtStr newline
	call delay
	rndNum random_val,1,10
	mov ax,random_val
	mov dealer,ax
	prtStr newline
	prtStr promptDS
	mov ax,dealer
	call outdec
	call continue
	
	;=============
	;Setup Players hand
	;=============
	call refresh ;clear screen
	prtStr line
	prtStr promptP 
	prtStr line
	L4:
		;=============
		; When setting up the hand, this will draw 2 random numbers and add them to the players running total
		; it will do this twice as the player starts with 2 cards.
		;=============
		inc count
		call delay
		prtStr newline
		prtStr promptC
		rndNum random_val,1,10 
		mov ax,random_val
		call outdec
		add player,ax
		xor ax,ax
		call continue
		cmp count,2
		jl L4
	call refresh ;clear screen
	prtStr line
	prtStr promptP 
	prtStr line	
	prtStr newline
	prtstr promptPS
	mov ax,player
	call outdec
	call continue
	call refresh ;clear screen

	L2:
		call refresh
		call draw_score
		prtStr prompt004
		prtStr prompt_arr
		readCh menu_select
		mov cl, 1 ;Hit
		cmp cl,menu_select ;The player decides to hit/draw a card
		je hit
		mov cl,2 ;Stay
		cmp cl,menu_select ; player decides to keep hand
		je stay
		prtStr prompt003 
		jmp L2
	
	hit:
		;=============
		; Calls a draw card proc and then compares the players total card count, jumps to losing message 
		; if greater than 21, and winning if equal, else it jumps back to the hit/stay menu.
		;=============
		call draw
		cmp player,21
		jg lose
		je win 
		jmp L2 
	stay:
		L3:
		call refresh
		prtStr promptF
		call draw_score
		call delay
		prtStr promptD 
		rndNum random_val,1,10 
		mov ax,random_val
		call outdec
		add dealer,ax
		xor ax,ax
		call continue
		cmp dealer,21
		jg win
		je lose
		mov ax,player
		cmp dealer,ax
		jg lose
		jmp L3 
		
	lose:
		call refresh
		call draw_score
		prtStr newline
		prtStr promptL
		call continue
		call refresh
		ret
	win:
		call refresh
		call draw_score
		prtStr newline
		prtStr promptW
		call continue
		call refresh
		ret
game endp
end main
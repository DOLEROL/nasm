section .data
	clean_terminal db 0x1B, "[H", 0x1B, "[J", 0x1B, "[0;1;95m"
	.len equ $-clean_terminal
	arr db 57, 48, 12, 98, 67, 34
	arr_len equ $ - arr - 1
	len equ arr_len + 1
	i equ 0
	j equ 0
	count equ 0
	print db "** "
	nl db '', 10

section .bss
	sz RESW 4

section .text
	global _start
_start:
	xor ecx, ecx
	xor eax, eax
	xor edx, edx
	xor ebx, ebx

	mov eax, 4		
	mov ebx, 1
	mov ecx, clean_terminal
	mov edx, clean_terminal.len
	int 0x80

	push len 		; +20
	push print		; +16
	push count		; +12
	push arr		; +8

	call numToAsci ; +4

	push j 			; +20
	push i			; +16
	push arr_len	; +12
	push arr		; +8

	call sort		; call +4

	mov eax, 4		
	mov ebx, 1
	mov ecx, nl
	mov edx, 2
	int 0x80

	push len 		; +20
	push print		; +16
	push count		; +12
	push arr		; +8

	call numToAsci ; +4

	mov eax, 4		
	mov ebx, 1
	mov ecx, nl
	mov edx, 2
	int 0x80

	mov eax, 1		; sys_call( exit )
	xor ebx, ebx
	int 0x80

sort:
	push ebp		; +4
	mov ebp, esp

i_loop:
	mov eax, [ebp + 8]	; adres arr
	mov edx, [ebp + 20]	; adres j
	add eax, edx		; arr[j]
	mov ecx, eax		; adres arr
j_loop:
	inc ecx
	mov dl, [eax]
	cmp dl, [ecx]		; ( arr[i] < arr[i + 1] )

	jl isLower			; skok jeżeli ( arr[i] < arr[i + 1] )
	mov bl, [ecx]		; swap( arr[i], arr[i + 1] )
	mov [eax], bl
	mov [ecx], dl

isLower:
	mov dl, [ebp + 20]	; j++
	inc dl
	mov [ebp + 20], dl

	mov bl, [ebp + 12]	; skok jeżeli (j < arr_len-1)
	cmp dl, bl
	jl j_loop

	mov dl, [ebp + 16]	; i++
	inc dl
	mov [ebp + 16], dl
	mov [ebp + 20], dl	; j = i
	mov bl, [ebp + 12]
	cmp dl, bl			; skok jeżeli (i < arr_len)
	jl i_loop

	mov esp, ebp		; koniec proc( sort )
	pop ebp

	ret

numToAsci:
	push ebp		; +4
	mov ebp, esp

	mov ebx, [ebp + 8]

is_not_eq:
	mov cl, 10
	mov edx, [ebp + 16]
	xor eax, eax
	mov al, [ebx]
	inc edx

	l1:
	xor ah, ah		; usuwanie reszty z dzielenia, żeby nie przeszkadzała przy kolejnej operacji
	div cl			; ah <- reszta z dzielenia
	
	add ah, 48
	mov [edx], ah
	sub ah, 48

	dec edx
	cmp al, 0		
	jnz l1

	mov dl, [ebp + 12]
	inc dl
	mov [ebp + 12], dl

	mov eax, 4
	mov ebx, 1
	mov ecx, [ebp + 16]
	mov edx, 3
	int 0x80

	mov ebx, [ebp + 8]
	inc ebx
	mov [ebp + 8], ebx

	mov dl, [ebp + 12]
	mov cl, [ebp + 20]
	cmp dl, cl
	jne is_not_eq

	mov esp, ebp		; koniec proc( sort )
	pop ebp

	ret
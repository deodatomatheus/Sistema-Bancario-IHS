;Cada cadastro deverá conter os seguintes campos:

;Nome do proprietário (até 20 caracteres + /0) 21 bytes	, base + 0
;CPF	(11 digitos + /0) 12 bytes 						, base + 21
;Código da agência	2bytes  							, base + 33
;Número da conta	2bytes  							, base + 35
;total 37 bytes

org 0x7e00
jmp 0x0000:start

;------AREA DE STRINGS MENU
	informacoes_menu db '---->>> ESCOLHA UMA DAS OPCOES <<<----', 13, 10, 0
	cadastrar_conta db  '1 - CADASTRAR CONTA', 13, 10, 0
	buscar_conta db '2 - BUSCAR CONTA', 13, 10, 0
	editar_conta db '3 - EDITAR CONTA', 13, 10, 0 
	deletar_conta db '4 - DELETAR CONTA', 13, 10, 0
	listar_agencias db '5 - LISTAR AGENCIAS', 13, 10, 0
	listar_contas_de_uma_agencia db '6 - LISTAR CONTAS DE UMA AGENCIA', 13, 10, 0
	comando_invalido db '!!COMANDO INVALIDO!!', 13, 10, 0

;-------AREA DE STRINGS CADASTRO
	informacoes_cadastro db '--->>> Digite os dados a seguir <<<---', 13, 10, 0
	digitar_nome db 'Nome do proprietario (max 20 char):', 13, 10, 0
	digitar_cpf db 'Digite o CPF:', 13, 10, 0
	digitar_cod_agencia db 'Codigo da agencia', 13, 10, 0
	digitar_num_conta db 'Numero da conta',  13, 10, 0
	banco_cheio db 'O banco de dados esta cheio', 13, 10, 0
;-------BANCO DE DADOS
	dados times 370 db 0 ;banco de dados suficiente para 10 pessoas
	numero dw 0
	
	 ;gerencia o espaco de dados, funciona como um mapa de posicoes alocadas ou nao
							;SE MUDAR O TAMNAHO PRECISA MUDAR TAMBEM EM 'alocar' E EM 'cadastro'							
							;usado no loop da funcao busca
	aux dw 0				;usado em cadastro para guardar o valor do lugar que foi alocado
	aux2 dw 0
;------- BUSCA
	digitar_cpf_busca db 'Digite o CPF para buscar', 13, 10, 0
	conta_nao_encontrada db 'Conta nao encontrada', 13, 10, 0
	conta_busca dw 0
	aux_busca dw 0
	aux_busca_ger dw 0
	aux_busca_dados dw 0
;-----------------------------------------------------------------------------------------------------------

ger_dados times 10 db 0
cadastro:
	call setVideoMode ;apagar o menu

	call alocar
	mov word[aux], cx
	call debugMEM2
	call endl
												
	cmp cx, 10 									;TAMANHO DO BANCO DE DADOS
	jle .valido
		mov si, banco_cheio
		call printStr
		call getchar
		jmp .done
	.valido:
		mov si, informacoes_cadastro
		call printStr

		;-------------------------------LEITURA NOME-------------------------------------------
		mov si, digitar_nome
		call printStr	

		call seta_base

		mov bx, 20 	;tamanho maximo do NOME
		call gets 	;pega uma string de tamanho bx + \0

		mov bx, 20	
		call completa_com_0	;poe cl - bl * 0 na area apontada por di		
	
		;--------------------------LEITURA CPF-------------------------------------------------
		mov si, digitar_cpf	
		call printStr
			
		call seta_base
		call debugMEM2
		call endl
		add di, 21				;setando a posicao correta na estrutura

		mov bx, 11 				;tamanho do CPF
		call gets 				;pega uma string de tamanho bx + \0	

		mov bx, 11				;setando a posicao correta da estrutura
		call completa_com_0 	;poe cl - bl * 0 na area apontada por di
		

		;------------------------------LIUTURA CODIGO DA CONTA----------------------------------
		; pegando os valores como 'inteiro' pra ser mais facil de procurar
		mov si, digitar_cod_agencia
		call printStr	
		call getinteger; ler numero de 2 bytes ***O RESULTADO FICA EM AX, CUIDADO COM ESSA PORRA, QUASE QUE ME MATO POR ISSO**
						;porem, tambem fica numa variavel chamada 'numero'
		
		call seta_base

		add di, 33		;setando a posicao correta na estrutura

		mov ax, [numero] 	;valor lido em getinteger

		stosw 
		
		;------------------------------LIUTURA NUMERO DA CONTA----------------------------------
		; pegando os valores como 'inteiro' pra ser mais facil de procurar
		mov si, digitar_num_conta
		call printStr

		call getinteger; ler numero de 2 bytes ***O RESULTADO FICA EM AX, CUIDADO COM ESSA PORRA, QUASE QUE ME MATO POR ISSO**
						;porem, tambem fica numa variavel chamada 'numero'
		
		call seta_base
		add di, 35		;setando a posicao correta na estrutura

		mov ax, [numero]	;valor lido em getinteger	
		stosw 
		;	------------------------DEBUG-----------------------
		;printa os dados dos usuarios
		mov si,dados
		;call showAcc

		
		call debugMEM
	
	.done:
ret

  
busca:
	call setVideoMode  ;limpar a tela
	;------------------------------LEITURA DO CONTA PARA BUSCA---------------------------------
	mov si, digitar_num_conta
	call printStr

	call getinteger
	mov ax, [numero]
	mov word[conta_busca], ax
	
	;call debugMEM2
	
	;----------------------------BUSCA---------------------------------------- [WIP]
	;CHECANDO A INTEGRIDADE DO CAMPO
	mov si, ger_dados
	mov word[aux_busca_ger], si

	mov cx, 0

	.parser:
		mov word[aux_busca], cx
		mov si, word[aux_busca_ger]
		lodsb
		mov word[aux_busca_ger] ,si

		cmp al, 1
		jne .espaco_n_alocado
			mov si, dados			 	
			mov cx, word[aux_busca]
			mov ax, 37
			mul cx
			add si, ax			
			add si, 35
			lodsw			
			cmp ax, word[conta_busca]
			jne .conta_diferente
			sub si, 37
			call showAcc
			.conta_diferente:		
		.espaco_n_alocado:
	
	mov cx, [aux_busca]
	inc cx
	cmp cx, 10	
	jne .parser

	call getchar	
ret

editar:
ret

deletar:
ret

listar_agencia:
ret

listar_contas:
ret

seta_base:
	mov di, dados 	
	mov cx, word[aux]
	mov ax, 37
	mul cx
	add di, ax
ret

printMenu:
	mov si, informacoes_menu
	call printStr
	mov si, cadastrar_conta
	call printStr
	mov si, buscar_conta
	call printStr
	mov si, editar_conta
	call printStr
	mov si, deletar_conta
	call printStr
	mov si, listar_agencias
	call printStr
	mov si, listar_contas_de_uma_agencia
	call printStr

	opcao_leitura:
	call getchar

	cmp al, '1'			;while(opcao invalida)
	jl opcao_invalida  	;	scanf (opcao)
	cmp al, '6'			;
	jg opcao_invalida 	;return al
	jmp opcao_valida
	
	opcao_invalida:
	mov si, comando_invalido
	call printStr
	jmp opcao_leitura

	opcao_valida:
ret

alocar: ;retorna a primeira posicao livre do ger_dados em cx
	mov si, ger_dados

	mov cx, 0
	jmp .teste
	.inicio:
		inc cx
		.teste:
		cmp cx, 10								;TAMANHO DO BANCO DE DADOS
		je .fim
		lodsb
		cmp al, 0
		jne .inicio	;se a posicao esta ocupada, olha a proxima	
		mov di, si
		dec di
		mov al, 1	;se a posicao ta livre, entao aloca
		stosb															
	.fim:

ret

printlen:
	mov bl, 10
	mov ax, cx
	div bl
	push ax	
	add al, 48
	call putchar
	pop ax
	mov al, ah
	add al, 48
	call putchar
	call endl
ret

getchar:
	mov ah, 0x00
	int 16h
ret

putchar:
	mov bh, 0
	mov bl, 0xf
	mov ah, 0x0e		; 
	int 10h			; interrupção de vídeo
ret

printStr:	
	lodsb
	cmp al, 0
	je endStr
	mov ah, 0xe
	mov bh, 0
	mov bl, 4
	int 10h
	jmp printStr
	endStr:	
ret

getinteger:
	xor ax, ax	
	mov [numero], ax	
	.inicio:			
		call getchar
		call putchar
		cmp al, 13
		je .end
		mov bx, 10
		mov ah, 0
		mov cx, ax
		sub cx, 48
		mov ax, [numero]
		mul bx 
		add ax, cx		
		mov [numero], ax
		jmp .inicio
	.end:
	call endl
	mov ax, [numero]
ret

setVideoMode:
	mov ah, 00h
	mov al, 0
	int 10h
ret

tostring:
	push di
	.loop1:
		cmp ax, 0
		je .endloop1
		xor dx, dx
		mov bx, 10
		   	 	div bx		; ax = 999, dx = 9
		   	 	xchg ax, dx	; swap ax, dx
		   	 	add ax, 48		; 9 + '0' = '9'
		   	 	stosb
		   	 	xchg ax, dx
		   	 	jmp .loop1
	.endloop1:
	;to string:
	pop si
	cmp si, di
	jne .done
	mov al, 48
	stosb
	.done:
	mov al, 0
	stosb
	call reverse
ret

reverse:
	mov di, si
	xor cx, cx		; zerar contador
	.loop1:
		lodsb
		cmp al, 0
		je .endloop1
		inc cl
		push ax
		jmp .loop1
	.endloop1:
	;reverse:
	.loop2:
		cmp cl, 0
		je .endloop2
		dec cl
		pop ax
		stosb
		jmp .loop2
	.endloop2:
ret

gets:
	xor cx, cx			; zerar contador
	
	.loop1:
		call getchar
		cmp al, 0x08	; backspace
		je .backspace
		cmp al, 0x0d	; return carriage
		je .done
		cmp cx, bx		; limite string
		je .loop1
		   	 
		stosb
		inc cl
		call putchar

		jmp .loop1
	;gets:
	;.loop1:
		.backspace:
			cmp cl, 0		; is empty?
			je .loop1
			dec di
			dec cl
			mov byte[di], 0
			call delchar
		jmp .loop1
	.done:
	mov al, 0
	stosb
	call endl
ret

endl:
	mov al, 10		; line feed
	call putchar
	mov al, 13		; carriage return
	call putchar
ret

delchar:
	mov al, 0x08
	call putchar
	mov al, ' '
	call putchar
	mov al, 0x08
	call putchar
ret

completa_com_0:
	mov al, 0
	.teste:
	cmp cl, bl
	je .done
	stosb
	inc bl
	jmp .teste
	.done:
ret

debugMEM:
	mov si, dados
	mov cx, 37
	mov [aux2], cx

	mov cx, 8
	mov [aux], cx

	.inicio:
		mov [aux], cx
		mov cx, [aux2]
		.interno:
			lodsb
			cmp al, 0
			jne .normal
			mov al, '-'
			.normal:
			call putchar
		loop .interno
		
		mov al, 13
		call putchar
		mov al, 10
		call putchar
		mov cx, [aux]
	loop .inicio
	call getchar; programa para, pra vc ver...
ret

debugMEM2:
	mov si, ger_dados
	mov cx, 10
	.inicio:
		lodsb
		cmp al, 0
		jne .normal
		mov al, '0'
		jmp .prox
		.normal:
		mov al, '1'		
		.prox:
		call putchar
	loop .inicio
	call getchar; programa para, pra vc ver...
ret

seletor:

	cmp al, '1'
	je set_cadastro
	
	cmp al, '2' 
	je set_busca
	
	cmp al, '3'
	je set_editar
	
	cmp al, '4'
	je set_deletar
	
	cmp al, '5'
	je set_listar_agencia
	
	cmp al, '6'
	je set_listar_contas

	jmp fim

	set_cadastro:
	call cadastro ; opcao 1
	jmp fim
	
	set_busca:
	call busca ;opcao 2
	jmp fim
	
	set_editar:
	call editar;opcao 3
	jmp fim
	
	set_deletar:
	call deletar ;opcao 4
	jmp fim

	set_listar_agencia:
	call listar_agencia ;opcao 5
	jmp fim

	set_listar_contas:
	call listar_contas ;opcao 6

ret

printInt: ;; printa o numero de 4 digitos apontados por si
	lodsw
	mov cx, 4
	mov bl, 10
	.continuar2:
		div bl
        add ah, '0'
        push ax
        xor ah,ah
	loop .continuar2

    mov cx, 4
    .continuar:
		pop ax
        mov al, ah
        call putchar
	loop .continuar
	call endl
ret

showAcc:                ;Mostra acc apontada por si
	mov cx, 33
	pularLinha:
		call endl
		jmp .continua
	.inicio:
		cmp cx, 33-21
	 	je pularLinha
		
		.continua:
		lodsb
		cmp al, 0
		jne .normal
		mov al, '-'
		.normal:
		call putchar
		
	loop .inicio
	call endl
	


	call printInt
	call printInt
	call getchar; programa para, pra vc ver...
	;mov al, 'K'
	;call putchar
ret

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	exibe_menu:
	call setVideoMode

	call printMenu ;opcao selecionada fica em al
	
	call seletor
	
	jmp fim

fim:
	jmp exibe_menu
	jmp $

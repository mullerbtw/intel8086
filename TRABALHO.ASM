.MODEL SMALL
.STACK

    CR                  EQU     0DH
    LF                  EQU     0AH

.DATA
    SRC_NAME            DB      "MAT.TXT"
    DST_NAME            DB      30 DUP (?)
    SRC_HANDLE          DW      0
    DST_HANDLE          DW      0
    BUFFER              DB      10 DUP (?)

    OPEN_ERROR_MSG      DB      "ERRO NA ABERTURA", CR, LF, 0
    READ_ERROR_MSG      DB      "ERRO NA LEITURA", CR, LF, 0
    SPEC_ERROR_MSG      DB      "ARQUIVO INVALIDO.", CR, LF, 0
    DST_NAME_MSG        DB      "ARQUIVO DESTINO: ", 0
    CRLF_MSG            DB      CR, LF, 0

    CUR_MAT             DB      56 DUP (?)
    PREV_MAT            DB      56 DUP (?)

    SEMICOLON_COUNT     DB      0
    CRLF_COUNT          DB      0

.CODE
.STARTUP
    ; LIDAR COM ERRO DE ABERTURA NA OPEN_FILE
    CALL                OPEN_FILE
    

NO_OPEN_ERROR:
    ; CHECK READ ERROR (OPTIONAL)
    CALL                GET_MAT
    CALL                IS_MAT_VALID






PRINT_STR               PROC NEAR
    MOV		            DL, [BX]
	CMP		            DL, 0
	JE		            STR_END
	PUSH	            BX
	MOV		            AH, 2
	INT		            21H
	POP		            BX
	INC		            BX
	JMP		            PRINT_STR
STR_END:
	RET
PRINT_STR               ENDP

OPEN_FILE               PROC NEAR
    MOV		            AL, 0
	MOV                 AH, 3DH
	INT		            21H
	MOV		            BX, AX
    MOV                 SRC_HANDLE, BX
    JNC                 NO_OPEN_ERROR
    LEA		            BX, OPEN_ERROR_MSG
	CALL	            PRINT_STR
	.EXIT	            1
NO_OPEN_ERROR:
    RET
OPEN_FILE ENDP

CLOSE_FILE              PROC NEAR
    MOV                 BX, SRC_HANDLE
	MOV                 AH, 3EH
	INT                 21H
    RET
CLOSE_FILE              ENDP
GET_MAT                 PROC NEAR
    MOV		            BX, FILEHANDLE
	MOV		            AH, 3FH
    ; EVERY ONE BYTE READ
	MOV		            CX, 1
	LEA                 DX, BUFFER
	INT                 21H
    ; GOT A BYTE FROM FILE
    JNC                 NO_READ_ERROR
	LEA                 BX, READ_ERROR_MSG
	CALL                PRINT_STR
    MOV                 AL, 1
	CALL                CLOSE_FILE
    .EXIT
	; TO BE FINISHED
    RET
GET_MAT                 ENDP

END
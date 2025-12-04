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

    CUR_MAT             DW      56 DUP (?)
    PREV_MAT            DE      56 DUP (?)

    SEMICOLON_COUNT     DB      0
    CRLF_COUNT          DB      0

.CODE
.STARTUP
    CALL                OPEN_FILE
    MOV                 SRC_HANDLE, BX
    JNC                 NO_OPEN_ERROR
    LEA                 BX, OPEN_ERROR_MSG
    CALL                PRINT_STR
    .EXIT               1

NO_OPEN_ERROR:
    MOV                 BX, SRC_HANDLE
    CALL                GET_MAT
    CALL                IS_MAT_VALID
END:
    .EXIT

PRINT_STR               PROC NEAR
    MOV                 DL, [BX]
    CMP                 DL, 0
    JE                  STR_END
    PUSH                BX
    MOV                 AH, 2
    INT                 21H
    POP                 BX
    INC                 BX
    JMP                 PRINT_STR
STR_END:
    RET
PRINT_STR               ENDP

OPEN_FILE               PROC NEAR
    MOV                 AL, 0
    MOV                 AH, 3DH
    INT                 21H
    MOV                 BX, AX
    RET
OPEN_FILE               ENDP

CLOSE_FILE              PROC NEAR
    ; MOVE HANDLE TO BX BEFORE CALLING
    MOV                 AH, 3EH
    INT                 21H
    RET
CLOSE_FILE              ENDP

; PASS THE WHOLE MATRIX TO ARRAY ALREADY CONVERTED FROM ASCII
GET_MAT                 PROC NEAR
    ; CALL              GET_BYTE (WITH READ ERROR HANDLING)
    ; CALL              ASCII_TO_BIN

    
    ; CHECK IF NUMBER IN ASCII
    ; ELSE, CHECK SEMICOLON
    ; ELSE, CHECK CRLF
    ; ELSE, CHECK SPACE (IF SO, END)

    RET
GET_MAT                 ENDP

IS_MAT_VALID            PROC NEAR
IS_MAT_VALID            ENDP

GET_BYTE                PROC NEAR
    MOV                 AH, 3FH
    ; EVERY ONE BYTE READ
    MOV                 CX, 1
    LEA                 DX, BUFFER
    INT                 21H
    ; GOT A BYTE FROM FILE
    JNC                 NO_READ_ERROR
    LEA                 BX, READ_ERROR_MSG
    CALL                PRINT_STR
    MOV                 AL, 1
    CALL                CLOSE_FILE
    .EXIT
NO_READ_ERROR:
    RET
GET_BYTE                ENDP

END
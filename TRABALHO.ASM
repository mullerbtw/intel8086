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

    OPEN_ERROR_MSG      DB      "ERRO NA ABERTURA.", CR, LF, 0
    READ_ERROR_MSG      DB      "ERRO NA LEITURA.", CR, LF, 0
    SPEC_ERROR_MSG      DB      "ARQUIVO INVALIDO.", CR, LF, 0
    DST_NAME_MSG        DB      "ARQUIVO DESTINO: ", 0
    CRLF_MSG            DB      CR, LF, 0

    CUR_MAT             DW      56 DUP (?)
    PREV_MAT            DW      56 DUP (?)

    CUR_ASCII_MAT       DB      120 DUP (?)
    PREV_ASCII_MAT      DB      120 DUP (?)

    ROW_COUNT           DB      0
    COLUMN_COUNT        DB      0

.CODE
.STARTUP
    MOV                 DX, SRC_NAME                            ; MOVE FILE NAME BEFORE CALLING
    CALL                OPEN_FILE
    MOV                 SRC_HANDLE, AX
    JNC                 NO_OPEN_ERROR
    LEA                 BX, OPEN_ERROR_MSG                      ; MOVE STRING BEFORE CALLING
    CALL                PRINT_STR
    .EXIT               1

NO_OPEN_ERROR:
    MOV                 BX, SRC_HANDLE                          ; MOVE FILE HANDLE BEFORE CALLING (FOR GET_BYTE)
    LEA                 BP, CUR_ASCII_MAT                       ; MOVE STRING ADDRESS BEFORE CALLING (FOR GET_ASCII_MAT)
    CLR                 DI                                      ; CLEARING DESTINATION INDEX (FOR GET_ASCII_MAT)
    CALL                GET_ASCII_MAT
    
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
    RET
OPEN_FILE               ENDP

CLOSE_FILE              PROC NEAR
    MOV                 AH, 3EH                                 ; MOVE HANDLE TO BX BEFORE CALLING
    INT                 21H
    RET
CLOSE_FILE              ENDP

GET_ASCII_MAT           PROC NEAR                               ; PASS THE WHOLE ASCII MATRIX TO CUR_ASCII_MAT
    CALL                GET_BYTE
    CMP                 AX, 0
    JE                  END_OF_MAT
    MOV                 [BP + DI], BUFFER                       ; PASS BUFFER TO CUR_ASCII_MAT STRING
    INC                 DI
    JMP                 GET_ASCII_MAT
END_OF_MAT:
    RET
GET_MAT                 ENDP

IS_MAT_VALID            PROC NEAR
    ; CHECK SEMICOLON / LINE
    ; IF DIFFERENCE, STOP
IS_MAT_VALID            ENDP

GET_BYTE                PROC NEAR
    MOV                 AH, 3FH
    MOV                 CX, 1                                   ; EVERY ONE BYTE READ
    LEA                 DX, BUFFER
    INT                 21H                                     ; GOT A BYTE FROM FILE
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
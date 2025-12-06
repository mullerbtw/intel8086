.MODEL SMALL
.STACK

    TAB                 EQU     09H
    LF                  EQU     0AH
    CR                  EQU     0DH
    SPACE               EQU     20H
    SEMICOLON           EQU     3BH


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
    ASCII_MAT           DB      345 DUP (0)                         ; MAXIMUM POSSIBLE ASCII MATRIX
    ROW_COUNT           DB      0
    COLUMN_COUNT        DB      0
    PREV_ASCII          DB      0


.CODE
.STARTUP
    MOV                 DX, SRC_NAME                                ; MOVE FILE NAME BEFORE CALLING
    CALL                OPEN_FILE
    MOV                 SRC_HANDLE, AX
    JNC                 NO_OPEN_ERROR
    LEA                 BX, OPEN_ERROR_MSG                          ; MOVE STRING BEFORE CALLING
    CALL                PRINT_STR
    .EXIT               1

NO_OPEN_ERROR:
    MOV                 BX, SRC_HANDLE                              ; MOVE FILE HANDLE BEFORE CALLING -> GET_BYTE
    LEA                 BP, ASCII_MAT                               ; MOVE STRING ADDRESS BEFORE CALLING -> GET_ASCII_MAT
    CLR                 DI                                          ; CLEAR DESTINATION INDEX -> GET_ASCII_MAT
    CALL                GET_ASCII_MAT
    ->
    LEA                 BX, ASCII_MAT                               ; MOVE STRING BEFORE CALLING
    CALL                IS_MAT_VALID

END:
    .EXIT

OPEN_FILE               PROC NEAR
    MOV                 AL, 0
    MOV                 AH, 3DH
    INT                 21H
    RET
OPEN_FILE               ENDP

CLOSE_FILE              PROC NEAR
    MOV                 AH, 3EH                                     ; MOVE HANDLE TO BX BEFORE CALLING
    INT                 21H
    RET
CLOSE_FILE              ENDP

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

GET_ASCII_MAT           PROC NEAR                                   ; PASS THE WHOLE ASCII MATRIX TO ASCII_MAT
    MOV                 PREV_ASCII, BUFFER
    CALL                GET_BYTE
    CMP                 AX, 0                                       ; IF END OF FILE
    JE                  END_OF_MAT
    CMP                 BUFFER, SPACE                               ; IF SPACE FOUND
    JE                  END_OF_MAT
    CMP                 BUFFER, TAB                                 ; IF TAB FOUND
    JE                  END_OF_MAT
    CMP                 PREV_ASCII, BUFFER                          ; IF BUFFER == CR && PREV_ASCII == LF
                                                                    ; THIS IDENTIFIES AN EMPTY LINE
    JB                  END_OF_MAT
    MOV                 [BP + DI], BUFFER                           ; PASS BUFFER TO ASCII_MAT STRING
    INC                 DI
    JMP                 GET_ASCII_MAT
END_OF_MAT:
    RET
GET_MAT                 ENDP

GET_BYTE                PROC NEAR
    MOV                 AH, 3FH
    MOV                 CX, 1                                       ; EVERY ONE BYTE READ
    LEA                 DX, BUFFER
    INT                 21H                                         ; GOT A BYTE FROM FILE
    JNC                 NO_READ_ERROR
    CALL                CLOSE_FILE                                  ; BX SHOULD STILL HAVE HANDLE
    LEA                 BX, READ_ERROR_MSG
    CALL                PRINT_STR
    .EXIT
NO_READ_ERROR:
    RET
GET_BYTE                ENDP

; TO BE FINISHED
IS_MAT_VALID            PROC NEAR
    MOV                 DL, [DX]
    CMP                 DL, SEMICOLON
    INC
    CMP                 DL, LF
    CMP                 DL, SPACE
    CMP                 DL, TAB
IS_MAT_VALID            ENDP

END
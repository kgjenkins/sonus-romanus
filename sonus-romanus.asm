; SONUS-ROMANUS (251 BYTES)
; PLAYS ROMAN NUMERALS AS MUSIC
; BY KEITH JENKINS (KGJENKINS)
; FOR LOVEBYTE 2024, 256 BYTE OLDSCHOOL INTRO COMPETITION
;
; THIS CODE PLAYS NUMBERS 1-65536,
; ALTHOUGH ONLY 1-3999 ARE LEGIT ROMAN NUMERALS (ABOUT 1 HOUR)
; ONE MINUTE DEMO VIDEO ONLY COVERS 1-118

TEMPN               EQU  $00                     ; LO,HI
TEMPX               EQU  $02
PITCH               EQU  $03
SIREN               EQU  $1D
NUMBER              EQU  $1E                     ; LO,HI
WINDOWLEFT          EQU  $20
WINDOWWIDTH         EQU  $21
SPEAKER             EQU  $C030
TABV                EQU  $FB5B
HOME                EQU  $FC58
WAIT                EQU  $FCA8
COUT                EQU  $FDED

                    ORG  $1000

MAIN                JSR  HOME
                    LDA  #4
                    TAX
                    JSR  TABV
:DEFAULTS           LDA  DEFAULTS,X
                    STA  SIREN,X
                    DEX
                    BPL  :DEFAULTS
                    LDX  #$0C
:TITLE              LDA  TITLE,X
                    JSR  PRINT
                    LDA  #$D0
                    JSR  WAIT
                    DEX
                    BPL  :TITLE
                    LDY  #8
:LONGWAIT           JSR  WAIT
                    DEY
                    BNE  :LONGWAIT

LOOP                LDA  NUMBER
                    STA  TEMPN
                    LDA  NUMBER+1
                    STA  TEMPN+1

                    LDX  #12
:LOOP               LDA  TEMPN
                    SEC
                    SBC  ROMAN2VALUELO,X
                    TAY                          ; STASH RESULT LO
                    LDA  TEMPN+1
                    SBC  ROMAN2VALUEHI,X
                    BCC  :NEXTVAL
                    STA  TEMPN+1
                    STY  TEMPN
                    LDA  ROMAN2CHAR,X
                    JSR  PRINT
                    TXA
                    LSR                          ; 2ND LETTER IF ODD
                    BCC  :LOOP
                    LDA  ROMAN2CHAR+1,X
                    JSR  PRINT
                    INX
:NEXTVAL            DEX
                    BPL  :LOOP
                    LDA  #$8D
                    JSR  PRINT
                    INC  NUMBER
                    BNE  LOOP
                    INC  NUMBER+1
                    BNE  LOOP
                    RTS

PRINT               STX  TEMPX
                    JSR  COUT
                    CMP  #$8D
                    BNE  :NOTCR
                    LDA  #7
:NOTCR              CMP  #$C4
                    BNE  :SKIP
                    LSR
:SKIP               AND  #$07
                    TAX
                    LDA  NOTEPITCH,X
:P                  STA  PITCH
                    BEQ  :SIREN

                    LDA  NOTEDURATION,X
                    TAX
:T1                 BIT  SPEAKER
                    LDY  #$1C
:T2                 DEY
                    BNE  :T2
                    BIT  SPEAKER
                    LDA  PITCH
                    TAY
:T3                 PHA
                    PLA
                    DEY
                    BNE  :T3
                    DEX
                    BNE  :T1

                    LDA  #$48                    ; GAP
:WAIT               JSR  WAIT
                    LDX  TEMPX
                    RTS

:SIREN              LDY  SIREN
                    BEQ  :NOSIREN
                    DEY
                    STY  SIREN
                    BEQ  :NOSIREN
                    TYA
                    BNE  :P
:NOSIREN            LDA  #$A0
                    BNE  :WAIT

;                        X  I  D  C  L  M  V  0
NOTEDURATION        HEX  25,1D,30,2C,27,35,1F,90
NOTEPITCH           HEX  A9,D7,82,8C,9F,74,CB    ; ,00


; 1,4,5,9,10,40,50,90,100,400,500,900,1000
ROMAN2VALUEHI       HEX  00,00,00,00,00,00,00,00,00,01,01,03,03
ROMAN2VALUELO       HEX  01,04,05,09,0A,28,32,5A,64,90,F4,84,E8
ROMAN2CHAR          ASC  "IIVIXXLXCCDCM"

; SIREN, NUMBER(LO,HI), WINLEFT, WINWIDTH
DEFAULTS            HEX  2A,00,00,10,18

TITLE               ASC  "SUNAMOR SUNOS"


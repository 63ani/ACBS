
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;ACB_2.c,50 :: 		void interrupt(void) {
;ACB_2.c,51 :: 		if (INTCON & 0x01) {      // PORTB Change interrupt
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt0
;ACB_2.c,52 :: 		if (PORTB & 0x10)       // X_Limit = 1
	BTFSS      PORTB+0, 4
	GOTO       L_interrupt1
;ACB_2.c,53 :: 		PORTE = PORTE | 0x01; // Turn off X axis motor
	BSF        PORTE+0, 0
	GOTO       L_interrupt2
L_interrupt1:
;ACB_2.c,54 :: 		else if (PORTB & 0x20)  // Y_Limit = 1
	BTFSS      PORTB+0, 5
	GOTO       L_interrupt3
;ACB_2.c,55 :: 		PORTE = PORTE | 0x02; // Turn off Y axis motor
	BSF        PORTE+0, 1
L_interrupt3:
L_interrupt2:
;ACB_2.c,57 :: 		INTCON = INTCON & 0xFE; // Clear RBIF
	MOVLW      254
	ANDWF      INTCON+0, 1
;ACB_2.c,58 :: 		} else if (PIR1 & 0x20) { // Received data
	GOTO       L_interrupt4
L_interrupt0:
	BTFSS      PIR1+0, 5
	GOTO       L_interrupt5
;ACB_2.c,59 :: 		myRxBuffer[Rx_count] = RCREG;
	MOVF       _Rx_count+0, 0
	ADDLW      _myRxBuffer+0
	MOVWF      FSR
	MOVF       RCREG+0, 0
	MOVWF      INDF+0
;ACB_2.c,60 :: 		Rx_count++;
	INCF       _Rx_count+0, 1
;ACB_2.c,61 :: 		PIR1 = PIR1 & 0xDF;       // Clear RCIF
	MOVLW      223
	ANDWF      PIR1+0, 1
;ACB_2.c,62 :: 		} else if (INTCON & 0x04) { // TMRO overflow
	GOTO       L_interrupt6
L_interrupt5:
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt7
;ACB_2.c,63 :: 		TMR0 = 248;
	MOVLW      248
	MOVWF      TMR0+0
;ACB_2.c,64 :: 		tick++;
	INCF       _tick+0, 1
	BTFSC      STATUS+0, 2
	INCF       _tick+1, 1
;ACB_2.c,65 :: 		INTCON = INTCON & 0xFB;
	MOVLW      251
	ANDWF      INTCON+0, 1
;ACB_2.c,66 :: 		}
L_interrupt7:
L_interrupt6:
L_interrupt4:
;ACB_2.c,67 :: 		}
L_end_interrupt:
L__interrupt117:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;ACB_2.c,69 :: 		void main() {
;ACB_2.c,70 :: 		ADCON0 = 0x41;// ATD ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;ACB_2.c,71 :: 		ADCON1 = 0x4E;// A0  Analog, 500 KHz, left justified
	MOVLW      78
	MOVWF      ADCON1+0
;ACB_2.c,72 :: 		TRISA = 0x01;  // RA2 = D1 (LCD), RA0 = Analog input (Potentiometer)
	MOVLW      1
	MOVWF      TRISA+0
;ACB_2.c,73 :: 		TRISB = 0x30;  // RB1-RB3 = D2-D4, RB4 = Switch_X, RB5 = Switch_Y, RB6 and RB7
	MOVLW      48
	MOVWF      TRISB+0
;ACB_2.c,75 :: 		TRISC = 0x80;  // RC0 = Step_X, RC1 = Dir_X, RC2 = Step_Y, RC3 = Dir_Y, RC4 =
	MOVLW      128
	MOVWF      TRISC+0
;ACB_2.c,77 :: 		TRISD = 0x01; // RD0 = Push button
	MOVLW      1
	MOVWF      TRISD+0
;ACB_2.c,78 :: 		TRISE = 0x00; // RE0 = EN_X, RE1 = EN_Y (active low), RE2 = Magnet
	CLRF       TRISE+0
;ACB_2.c,80 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;ACB_2.c,81 :: 		PORTE = 0x03;  // Motors OFF
	MOVLW      3
	MOVWF      PORTE+0
;ACB_2.c,82 :: 		INTCON = 0xE8; // GIE, RBIE, PEIE, and TMR0IE
	MOVLW      232
	MOVWF      INTCON+0
;ACB_2.c,83 :: 		OPTION_REG = 0x87;
	MOVLW      135
	MOVWF      OPTION_REG+0
;ACB_2.c,84 :: 		TMR0 = 248;
	MOVLW      248
	MOVWF      TMR0+0
;ACB_2.c,87 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;ACB_2.c,88 :: 		USART_Init();
	CALL       _USART_Init+0
;ACB_2.c,89 :: 		Lcd_Cmd(_LCD_CLEAR);      // Clear display
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,90 :: 		Lcd_Cmd(_LCD_CURSOR_OFF); // Cursor off
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,91 :: 		Move_Home();
	CALL       _Move_Home+0
;ACB_2.c,92 :: 		Rx_count = 0;
	CLRF       _Rx_count+0
;ACB_2.c,93 :: 		while (1) {
L_main8:
;ACB_2.c,94 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,95 :: 		Lcd_Out(1, 1, "Welcome to ACBS");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,96 :: 		Lcd_Out(2, 1, "Start?");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr2_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,98 :: 		while (!(PORTD & 0x01));
L_main10:
	BTFSC      PORTD+0, 0
	GOTO       L_main11
	GOTO       L_main10
L_main11:
;ACB_2.c,99 :: 		USART_Tx('S');
	MOVLW      83
	MOVWF      FARG_USART_Tx_trans+0
	CALL       _USART_Tx+0
;ACB_2.c,101 :: 		msDelay(200);
	MOVLW      200
	MOVWF      FARG_msDelay_ms+0
	CLRF       FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,102 :: 		level = read_level();
	CALL       _read_level+0
	MOVF       R0+0, 0
	MOVWF      _level+0
;ACB_2.c,103 :: 		USART_TX(level+'0');
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      FARG_USART_Tx_trans+0
	CALL       _USART_Tx+0
;ACB_2.c,105 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,106 :: 		Lcd_Out(1, 1, "Game On");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr3_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,107 :: 		game = 1;
	MOVLW      1
	MOVWF      _game+0
;ACB_2.c,110 :: 		do { // Game is on
L_main12:
;ACB_2.c,111 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,112 :: 		Lcd_Out(1, 1, "Enter Move...");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr4_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,113 :: 		Rx_Count = 0;
	CLRF       _Rx_count+0
;ACB_2.c,114 :: 		while (Rx_count != 6);           // Wait for recieval of the Move
L_main15:
	MOVF       _Rx_count+0, 0
	XORLW      6
	BTFSC      STATUS+0, 2
	GOTO       L_main16
	GOTO       L_main15
L_main16:
;ACB_2.c,115 :: 		Rx_count = 0; // Reset rx counter
	CLRF       _Rx_count+0
;ACB_2.c,116 :: 		Move_Valid = myRXBuffer[0];
	MOVF       _myRxBuffer+0, 0
	MOVWF      _Move_Valid+0
;ACB_2.c,117 :: 		startx = myRxBuffer[1];
	MOVF       _myRxBuffer+1, 0
	MOVWF      _startx+0
;ACB_2.c,118 :: 		starty = myRxBuffer[2];
	MOVF       _myRxBuffer+2, 0
	MOVWF      _starty+0
;ACB_2.c,119 :: 		Move_Type = myRxBuffer[3];
	MOVF       _myRxBuffer+3, 0
	MOVWF      _Move_Type+0
;ACB_2.c,120 :: 		endx = myRxBuffer[4];
	MOVF       _myRxBuffer+4, 0
	MOVWF      _endx+0
;ACB_2.c,121 :: 		endy = myRxbuffer[5];
	MOVF       _myRxBuffer+5, 0
	MOVWF      _endy+0
;ACB_2.c,123 :: 		if (Move_Valid == 'L') { // Move is legal
	MOVF       _myRxBuffer+0, 0
	XORLW      76
	BTFSS      STATUS+0, 2
	GOTO       L_main17
;ACB_2.c,124 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,125 :: 		Lcd_Out(1, 1, "Player Moving...");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr5_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,126 :: 		Move_motors();
	CALL       _Move_motors+0
;ACB_2.c,127 :: 		USART_Tx('D');
	MOVLW      68
	MOVWF      FARG_USART_Tx_trans+0
	CALL       _USART_Tx+0
;ACB_2.c,128 :: 		}
	GOTO       L_main18
L_main17:
;ACB_2.c,130 :: 		else if (Move_Valid == 'M') {
	MOVF       _Move_Valid+0, 0
	XORLW      77
	BTFSS      STATUS+0, 2
	GOTO       L_main19
;ACB_2.c,132 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,133 :: 		Lcd_Out(1, 1, "Game ended");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr6_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,134 :: 		Lcd_Out(2, 1, "Player wins");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr7_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,135 :: 		game = 0;
	CLRF       _game+0
;ACB_2.c,136 :: 		break;
	GOTO       L_main13
;ACB_2.c,137 :: 		}
L_main19:
L_main18:
;ACB_2.c,138 :: 		Rx_Count = 0;
	CLRF       _Rx_count+0
;ACB_2.c,139 :: 		while (Rx_count != 6);           // Wait to recieve engine move
L_main20:
	MOVF       _Rx_count+0, 0
	XORLW      6
	BTFSC      STATUS+0, 2
	GOTO       L_main21
	GOTO       L_main20
L_main21:
;ACB_2.c,140 :: 		Rx_count = 0; // reset counter
	CLRF       _Rx_count+0
;ACB_2.c,141 :: 		Move_Valid = myRXBuffer[0];
	MOVF       _myRxBuffer+0, 0
	MOVWF      _Move_Valid+0
;ACB_2.c,142 :: 		startx = myRxBuffer[1];
	MOVF       _myRxBuffer+1, 0
	MOVWF      _startx+0
;ACB_2.c,143 :: 		starty = myRxBuffer[2];
	MOVF       _myRxBuffer+2, 0
	MOVWF      _starty+0
;ACB_2.c,144 :: 		Move_Type = myRxBuffer[3];
	MOVF       _myRxBuffer+3, 0
	MOVWF      _Move_Type+0
;ACB_2.c,145 :: 		endx = myRxBuffer[4];
	MOVF       _myRxBuffer+4, 0
	MOVWF      _endx+0
;ACB_2.c,146 :: 		endy = myRxbuffer[5];
	MOVF       _myRxBuffer+5, 0
	MOVWF      _endy+0
;ACB_2.c,148 :: 		if (Move_Valid == 'E'){
	MOVF       _myRxBuffer+0, 0
	XORLW      69
	BTFSS      STATUS+0, 2
	GOTO       L_main22
;ACB_2.c,149 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,150 :: 		Lcd_Out(1, 1, "Engine Moving...");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr8_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,151 :: 		Move_motors();
	CALL       _Move_motors+0
;ACB_2.c,152 :: 		USART_Tx('D');
	MOVLW      68
	MOVWF      FARG_USART_Tx_trans+0
	CALL       _USART_Tx+0
;ACB_2.c,153 :: 		}
	GOTO       L_main23
L_main22:
;ACB_2.c,155 :: 		else if (Move_Valid == 'M') {
	MOVF       _Move_Valid+0, 0
	XORLW      77
	BTFSS      STATUS+0, 2
	GOTO       L_main24
;ACB_2.c,157 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,158 :: 		Lcd_Out(1, 1, "Game ended");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr9_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,159 :: 		Lcd_Out(2, 1, "Engine wins");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr10_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,160 :: 		game = 0;
	CLRF       _game+0
;ACB_2.c,161 :: 		break;
	GOTO       L_main13
;ACB_2.c,162 :: 		}
L_main24:
L_main23:
;ACB_2.c,163 :: 		} while (game);
	MOVF       _game+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_main12
L_main13:
;ACB_2.c,164 :: 		msDelay(60000); // Wait one minute
	MOVLW      96
	MOVWF      FARG_msDelay_ms+0
	MOVLW      234
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,165 :: 		}
	GOTO       L_main8
;ACB_2.c,166 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_msDelay:

;ACB_2.c,168 :: 		void msDelay(unsigned int ms) {
;ACB_2.c,169 :: 		tick = 0;
	CLRF       _tick+0
	CLRF       _tick+1
;ACB_2.c,170 :: 		while (tick < ms)
L_msDelay25:
	MOVF       FARG_msDelay_ms+1, 0
	SUBWF      _tick+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__msDelay120
	MOVF       FARG_msDelay_ms+0, 0
	SUBWF      _tick+0, 0
L__msDelay120:
	BTFSC      STATUS+0, 0
	GOTO       L_msDelay26
;ACB_2.c,171 :: 		;
	GOTO       L_msDelay25
L_msDelay26:
;ACB_2.c,172 :: 		}
L_end_msDelay:
	RETURN
; end of _msDelay

_MotorDelay:

;ACB_2.c,174 :: 		void MotorDelay() {
;ACB_2.c,175 :: 		for (a = 0; a < 200; a++)
	CLRF       _a+0
L_MotorDelay27:
	MOVLW      200
	SUBWF      _a+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_MotorDelay28
	INCF       _a+0, 1
;ACB_2.c,176 :: 		;
	GOTO       L_MotorDelay27
L_MotorDelay28:
;ACB_2.c,177 :: 		}
L_end_MotorDelay:
	RETURN
; end of _MotorDelay

_Move_X:

;ACB_2.c,180 :: 		void Move_X(unsigned char dir, unsigned int steps) {
;ACB_2.c,182 :: 		if (dir)
	MOVF       FARG_Move_X_dir+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_Move_X30
;ACB_2.c,183 :: 		PORTC = 0x02; // Dir_X (RC1) = 1 (right)
	MOVLW      2
	MOVWF      PORTC+0
	GOTO       L_Move_X31
L_Move_X30:
;ACB_2.c,185 :: 		PORTC = 0x00; // Dir_X (RC1) = 0 (left)
	CLRF       PORTC+0
L_Move_X31:
;ACB_2.c,187 :: 		PORTE = PORTE & 0xFE; // EN_X (RE0) = 0 (Enable X motor)
	MOVLW      254
	ANDWF      PORTE+0, 1
;ACB_2.c,189 :: 		for (j = 0; j < steps; j++) {
	CLRF       Move_X_j_L0+0
	CLRF       Move_X_j_L0+1
L_Move_X32:
	MOVF       FARG_Move_X_steps+1, 0
	SUBWF      Move_X_j_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Move_X123
	MOVF       FARG_Move_X_steps+0, 0
	SUBWF      Move_X_j_L0+0, 0
L__Move_X123:
	BTFSC      STATUS+0, 0
	GOTO       L_Move_X33
;ACB_2.c,190 :: 		PORTC = PORTC & 0xFE; // Step_X (RC0) = 0
	MOVLW      254
	ANDWF      PORTC+0, 1
;ACB_2.c,191 :: 		MotorDelay();
	CALL       _MotorDelay+0
;ACB_2.c,192 :: 		PORTC = PORTC | 0x01; // Step_X (RC0) = 1
	BSF        PORTC+0, 0
;ACB_2.c,193 :: 		MotorDelay();
	CALL       _MotorDelay+0
;ACB_2.c,189 :: 		for (j = 0; j < steps; j++) {
	INCF       Move_X_j_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Move_X_j_L0+1, 1
;ACB_2.c,194 :: 		}
	GOTO       L_Move_X32
L_Move_X33:
;ACB_2.c,196 :: 		PORTE = PORTE | 0x03; // Disable all motors
	MOVLW      3
	IORWF      PORTE+0, 1
;ACB_2.c,197 :: 		}
L_end_Move_X:
	RETURN
; end of _Move_X

_Move_Y:

;ACB_2.c,199 :: 		void Move_Y(unsigned char dir, unsigned int steps) {
;ACB_2.c,201 :: 		if (dir)
	MOVF       FARG_Move_Y_dir+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_Move_Y35
;ACB_2.c,202 :: 		PORTC = 0x08; // Dir_Y (RC3) = 1 (up)
	MOVLW      8
	MOVWF      PORTC+0
	GOTO       L_Move_Y36
L_Move_Y35:
;ACB_2.c,204 :: 		PORTC = 0x00; // Dir_Y (RC3) = 0 (down)
	CLRF       PORTC+0
L_Move_Y36:
;ACB_2.c,206 :: 		PORTE = PORTE & 0xFD; // EN_Y (RE1) = 0 (Enable Y motor)
	MOVLW      253
	ANDWF      PORTE+0, 1
;ACB_2.c,208 :: 		for (j = 0; j < steps; j++) {
	CLRF       Move_Y_j_L0+0
	CLRF       Move_Y_j_L0+1
L_Move_Y37:
	MOVF       FARG_Move_Y_steps+1, 0
	SUBWF      Move_Y_j_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Move_Y125
	MOVF       FARG_Move_Y_steps+0, 0
	SUBWF      Move_Y_j_L0+0, 0
L__Move_Y125:
	BTFSC      STATUS+0, 0
	GOTO       L_Move_Y38
;ACB_2.c,209 :: 		PORTC = PORTC & 0xFB; // Step_Y (RC2) = 0
	MOVLW      251
	ANDWF      PORTC+0, 1
;ACB_2.c,210 :: 		MotorDelay();
	CALL       _MotorDelay+0
;ACB_2.c,211 :: 		PORTC = PORTC | 0x04; // Step_Y (RC2) = 1
	BSF        PORTC+0, 2
;ACB_2.c,212 :: 		MotorDelay();
	CALL       _MotorDelay+0
;ACB_2.c,208 :: 		for (j = 0; j < steps; j++) {
	INCF       Move_Y_j_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Move_Y_j_L0+1, 1
;ACB_2.c,213 :: 		}
	GOTO       L_Move_Y37
L_Move_Y38:
;ACB_2.c,215 :: 		PORTE = PORTE | 0x03; // Disable all motors
	MOVLW      3
	IORWF      PORTE+0, 1
;ACB_2.c,216 :: 		}
L_end_Move_Y:
	RETURN
; end of _Move_Y

_Move_D:

;ACB_2.c,218 :: 		void Move_D(unsigned char dir, unsigned int steps) {
;ACB_2.c,220 :: 		if (dir == 0)
	MOVF       FARG_Move_D_dir+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_Move_D40
;ACB_2.c,221 :: 		PORTC = 0x00; // Dir_Y (RC3) = 0, Dir_X (RC1) = 0 (bottom left)
	CLRF       PORTC+0
	GOTO       L_Move_D41
L_Move_D40:
;ACB_2.c,222 :: 		else if (dir == 1)
	MOVF       FARG_Move_D_dir+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_Move_D42
;ACB_2.c,223 :: 		PORTC = 0x02; // Dir_Y (RC3) = 0, Dir_X (RC1) = 1 (bottom right)
	MOVLW      2
	MOVWF      PORTC+0
	GOTO       L_Move_D43
L_Move_D42:
;ACB_2.c,224 :: 		else if (dir == 2)
	MOVF       FARG_Move_D_dir+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_Move_D44
;ACB_2.c,225 :: 		PORTC = 0x08; // Dir_Y (RC3) = 1, Dir_X (RC1) = 0 (top left)
	MOVLW      8
	MOVWF      PORTC+0
	GOTO       L_Move_D45
L_Move_D44:
;ACB_2.c,226 :: 		else if (dir == 3)
	MOVF       FARG_Move_D_dir+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_Move_D46
;ACB_2.c,227 :: 		PORTC = 0x0A; // Dir_Y (RC3) = 1, Dir_X (RC1) = 1 (top right)
	MOVLW      10
	MOVWF      PORTC+0
L_Move_D46:
L_Move_D45:
L_Move_D43:
L_Move_D41:
;ACB_2.c,229 :: 		PORTE = PORTE & 0xFC; // EN_X (RE0) = 0, EN_Y (RE1) = 0 (Enable X & Y motors)
	MOVLW      252
	ANDWF      PORTE+0, 1
;ACB_2.c,231 :: 		for (j = 0; j < steps; j++) {
	CLRF       Move_D_j_L0+0
	CLRF       Move_D_j_L0+1
L_Move_D47:
	MOVF       FARG_Move_D_steps+1, 0
	SUBWF      Move_D_j_L0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Move_D127
	MOVF       FARG_Move_D_steps+0, 0
	SUBWF      Move_D_j_L0+0, 0
L__Move_D127:
	BTFSC      STATUS+0, 0
	GOTO       L_Move_D48
;ACB_2.c,232 :: 		PORTC = PORTC & 0xFA; // Step_X (RC0) = 0, Step_Y (RC2) = 0
	MOVLW      250
	ANDWF      PORTC+0, 1
;ACB_2.c,233 :: 		MotorDelay();
	CALL       _MotorDelay+0
;ACB_2.c,234 :: 		PORTC = PORTC | 0x05; // Step_X (RC0) = 1, Step_Y (RC2) = 1
	MOVLW      5
	IORWF      PORTC+0, 1
;ACB_2.c,235 :: 		MotorDelay();
	CALL       _MotorDelay+0
;ACB_2.c,231 :: 		for (j = 0; j < steps; j++) {
	INCF       Move_D_j_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Move_D_j_L0+1, 1
;ACB_2.c,236 :: 		}
	GOTO       L_Move_D47
L_Move_D48:
;ACB_2.c,238 :: 		PORTE = PORTE | 0x03; // Disable all motors
	MOVLW      3
	IORWF      PORTE+0, 1
;ACB_2.c,239 :: 		}
L_end_Move_D:
	RETURN
; end of _Move_D

_Move_Home:

;ACB_2.c,243 :: 		void Move_Home() {
;ACB_2.c,244 :: 		while (1) {
L_Move_Home50:
;ACB_2.c,245 :: 		if (!(PORTB & 0x10) && !(PORTB & 0X20)) { // Both Switches not hit
	BTFSC      PORTB+0, 4
	GOTO       L_Move_Home54
	BTFSC      PORTB+0, 5
	GOTO       L_Move_Home54
L__Move_Home111:
;ACB_2.c,246 :: 		Move_D(0, 300);
	CLRF       FARG_Move_D_dir+0
	MOVLW      44
	MOVWF      FARG_Move_D_steps+0
	MOVLW      1
	MOVWF      FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,247 :: 		} else if (!(PORTB & 0x10)) // RB4 == 0
	GOTO       L_Move_Home55
L_Move_Home54:
	BTFSC      PORTB+0, 4
	GOTO       L_Move_Home56
;ACB_2.c,248 :: 		Move_X(0, 300);
	CLRF       FARG_Move_X_dir+0
	MOVLW      44
	MOVWF      FARG_Move_X_steps+0
	MOVLW      1
	MOVWF      FARG_Move_X_steps+1
	CALL       _Move_X+0
	GOTO       L_Move_Home57
L_Move_Home56:
;ACB_2.c,249 :: 		else if (!(PORTB & 0X20)) // RB5 == 0
	BTFSC      PORTB+0, 5
	GOTO       L_Move_Home58
;ACB_2.c,250 :: 		Move_Y(0, 300);
	CLRF       FARG_Move_Y_dir+0
	MOVLW      44
	MOVWF      FARG_Move_Y_steps+0
	MOVLW      1
	MOVWF      FARG_Move_Y_steps+1
	CALL       _Move_Y+0
	GOTO       L_Move_Home59
L_Move_Home58:
;ACB_2.c,251 :: 		else if ((PORTB & 0x10) && (PORTB & 0x20))
	BTFSS      PORTB+0, 4
	GOTO       L_Move_Home62
	BTFSS      PORTB+0, 5
	GOTO       L_Move_Home62
L__Move_Home110:
;ACB_2.c,252 :: 		break;
	GOTO       L_Move_Home51
L_Move_Home62:
L_Move_Home59:
L_Move_Home57:
L_Move_Home55:
;ACB_2.c,253 :: 		}
	GOTO       L_Move_Home50
L_Move_Home51:
;ACB_2.c,254 :: 		Move_X(1, home_X);
	MOVLW      1
	MOVWF      FARG_Move_X_dir+0
	MOVLW      140
	MOVWF      FARG_Move_X_steps+0
	MOVLW      0
	MOVWF      FARG_Move_X_steps+1
	CALL       _Move_X+0
;ACB_2.c,255 :: 		}
L_end_Move_Home:
	RETURN
; end of _Move_Home

_USART_Init:

;ACB_2.c,257 :: 		void USART_Init() {
;ACB_2.c,258 :: 		SPBRG = 12;   // 9600 Baud Rate
	MOVLW      12
	MOVWF      SPBRG+0
;ACB_2.c,259 :: 		TXSTA = 0x20; // 8-bit, Tx enable, Async, Low speed
	MOVLW      32
	MOVWF      TXSTA+0
;ACB_2.c,260 :: 		RCSTA = 0x90; // SP Enbale, 8-bit, cont. Rx
	MOVLW      144
	MOVWF      RCSTA+0
;ACB_2.c,261 :: 		TRISC = 0x80;
	MOVLW      128
	MOVWF      TRISC+0
;ACB_2.c,262 :: 		PIE1 = PIE1 | 0x20; // RCIE
	BSF        PIE1+0, 5
;ACB_2.c,263 :: 		}
L_end_USART_Init:
	RETURN
; end of _USART_Init

_USART_Tx:

;ACB_2.c,264 :: 		void USART_Tx(char trans) {
;ACB_2.c,265 :: 		while (!(TXSTA & 0x02));
L_USART_Tx63:
	BTFSC      TXSTA+0, 1
	GOTO       L_USART_Tx64
	GOTO       L_USART_Tx63
L_USART_Tx64:
;ACB_2.c,266 :: 		TXREG = trans;
	MOVF       FARG_USART_Tx_trans+0, 0
	MOVWF      TXREG+0
;ACB_2.c,267 :: 		}
L_end_USART_Tx:
	RETURN
; end of _USART_Tx

_Move:

;ACB_2.c,270 :: 		void Move(char startx, char starty, char endx, char endy) {
;ACB_2.c,271 :: 		if ((endx - startx) == (endy - starty)) { // Move is diagonal
	MOVF       FARG_Move_startx+0, 0
	SUBWF      FARG_Move_endx+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	BTFSS      STATUS+0, 0
	DECF       R3+1, 1
	MOVF       FARG_Move_starty+0, 0
	SUBWF      FARG_Move_endy+0, 0
	MOVWF      R1+0
	CLRF       R1+1
	BTFSS      STATUS+0, 0
	DECF       R1+1, 1
	MOVF       R3+1, 0
	XORWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Move132
	MOVF       R1+0, 0
	XORWF      R3+0, 0
L__Move132:
	BTFSS      STATUS+0, 2
	GOTO       L_Move65
;ACB_2.c,272 :: 		step_count = abs(endy - starty);
	MOVF       FARG_Move_starty+0, 0
	SUBWF      FARG_Move_endy+0, 0
	MOVWF      FARG_abs_a+0
	CLRF       FARG_abs_a+1
	BTFSS      STATUS+0, 0
	DECF       FARG_abs_a+1, 1
	CALL       _abs+0
	MOVF       R0+0, 0
	MOVWF      _step_count+0
	MOVF       R0+1, 0
	MOVWF      _step_count+1
;ACB_2.c,273 :: 		if (endx > startx && endy > starty) // Up, right
	MOVF       FARG_Move_endx+0, 0
	SUBWF      FARG_Move_startx+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move68
	MOVF       FARG_Move_endy+0, 0
	SUBWF      FARG_Move_starty+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move68
L__Move115:
;ACB_2.c,275 :: 		k = step_count;
	MOVF       _step_count+0, 0
	MOVWF      _k+0
	MOVF       _step_count+1, 0
	MOVWF      _k+1
;ACB_2.c,276 :: 		while (k > 0) {
L_Move69:
	MOVF       _k+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Move133
	MOVF       _k+0, 0
	SUBLW      0
L__Move133:
	BTFSC      STATUS+0, 0
	GOTO       L_Move70
;ACB_2.c,277 :: 		Move_D(3, Square_Size);
	MOVLW      3
	MOVWF      FARG_Move_D_dir+0
	MOVLW      250
	MOVWF      FARG_Move_D_steps+0
	MOVLW      0
	MOVWF      FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,278 :: 		k--;
	MOVLW      1
	SUBWF      _k+0, 1
	BTFSS      STATUS+0, 0
	DECF       _k+1, 1
;ACB_2.c,279 :: 		}
	GOTO       L_Move69
L_Move70:
;ACB_2.c,280 :: 		} else if (endx > startx && starty > endy) // Down, right
	GOTO       L_Move71
L_Move68:
	MOVF       FARG_Move_endx+0, 0
	SUBWF      FARG_Move_startx+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move74
	MOVF       FARG_Move_starty+0, 0
	SUBWF      FARG_Move_endy+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move74
L__Move114:
;ACB_2.c,282 :: 		k = step_count;
	MOVF       _step_count+0, 0
	MOVWF      _k+0
	MOVF       _step_count+1, 0
	MOVWF      _k+1
;ACB_2.c,283 :: 		while (k > 0) {
L_Move75:
	MOVF       _k+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Move134
	MOVF       _k+0, 0
	SUBLW      0
L__Move134:
	BTFSC      STATUS+0, 0
	GOTO       L_Move76
;ACB_2.c,284 :: 		Move_D(1, Square_Size);
	MOVLW      1
	MOVWF      FARG_Move_D_dir+0
	MOVLW      250
	MOVWF      FARG_Move_D_steps+0
	MOVLW      0
	MOVWF      FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,285 :: 		k--;
	MOVLW      1
	SUBWF      _k+0, 1
	BTFSS      STATUS+0, 0
	DECF       _k+1, 1
;ACB_2.c,286 :: 		}
	GOTO       L_Move75
L_Move76:
;ACB_2.c,287 :: 		} else if (startx > endx && starty > endy) // Down, left
	GOTO       L_Move77
L_Move74:
	MOVF       FARG_Move_startx+0, 0
	SUBWF      FARG_Move_endx+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move80
	MOVF       FARG_Move_starty+0, 0
	SUBWF      FARG_Move_endy+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move80
L__Move113:
;ACB_2.c,289 :: 		k = step_count;
	MOVF       _step_count+0, 0
	MOVWF      _k+0
	MOVF       _step_count+1, 0
	MOVWF      _k+1
;ACB_2.c,290 :: 		while (k > 0) {
L_Move81:
	MOVF       _k+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Move135
	MOVF       _k+0, 0
	SUBLW      0
L__Move135:
	BTFSC      STATUS+0, 0
	GOTO       L_Move82
;ACB_2.c,291 :: 		Move_D(0, Square_Size);
	CLRF       FARG_Move_D_dir+0
	MOVLW      250
	MOVWF      FARG_Move_D_steps+0
	MOVLW      0
	MOVWF      FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,292 :: 		k--;
	MOVLW      1
	SUBWF      _k+0, 1
	BTFSS      STATUS+0, 0
	DECF       _k+1, 1
;ACB_2.c,293 :: 		}
	GOTO       L_Move81
L_Move82:
;ACB_2.c,294 :: 		} else if (startx > endx && endy > starty) // Up, left
	GOTO       L_Move83
L_Move80:
	MOVF       FARG_Move_startx+0, 0
	SUBWF      FARG_Move_endx+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move86
	MOVF       FARG_Move_endy+0, 0
	SUBWF      FARG_Move_starty+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move86
L__Move112:
;ACB_2.c,296 :: 		k = step_count;
	MOVF       _step_count+0, 0
	MOVWF      _k+0
	MOVF       _step_count+1, 0
	MOVWF      _k+1
;ACB_2.c,297 :: 		while (k > 0) {
L_Move87:
	MOVF       _k+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Move136
	MOVF       _k+0, 0
	SUBLW      0
L__Move136:
	BTFSC      STATUS+0, 0
	GOTO       L_Move88
;ACB_2.c,298 :: 		Move_D(2, Square_Size);
	MOVLW      2
	MOVWF      FARG_Move_D_dir+0
	MOVLW      250
	MOVWF      FARG_Move_D_steps+0
	MOVLW      0
	MOVWF      FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,299 :: 		k--;
	MOVLW      1
	SUBWF      _k+0, 1
	BTFSS      STATUS+0, 0
	DECF       _k+1, 1
;ACB_2.c,300 :: 		}
	GOTO       L_Move87
L_Move88:
;ACB_2.c,301 :: 		}
L_Move86:
L_Move83:
L_Move77:
L_Move71:
;ACB_2.c,302 :: 		} else { // Move is not diagonal
	GOTO       L_Move89
L_Move65:
;ACB_2.c,303 :: 		step_count = abs(endy - starty);
	MOVF       FARG_Move_starty+0, 0
	SUBWF      FARG_Move_endy+0, 0
	MOVWF      FARG_abs_a+0
	CLRF       FARG_abs_a+1
	BTFSS      STATUS+0, 0
	DECF       FARG_abs_a+1, 1
	CALL       _abs+0
	MOVF       R0+0, 0
	MOVWF      _step_count+0
	MOVF       R0+1, 0
	MOVWF      _step_count+1
;ACB_2.c,304 :: 		if (endy > starty) { // Up
	MOVF       FARG_Move_endy+0, 0
	SUBWF      FARG_Move_starty+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move90
;ACB_2.c,305 :: 		k = step_count;
	MOVF       _step_count+0, 0
	MOVWF      _k+0
	MOVF       _step_count+1, 0
	MOVWF      _k+1
;ACB_2.c,306 :: 		while (k > 0) {
L_Move91:
	MOVF       _k+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Move137
	MOVF       _k+0, 0
	SUBLW      0
L__Move137:
	BTFSC      STATUS+0, 0
	GOTO       L_Move92
;ACB_2.c,307 :: 		Move_Y(1, Square_Size);
	MOVLW      1
	MOVWF      FARG_Move_Y_dir+0
	MOVLW      250
	MOVWF      FARG_Move_Y_steps+0
	MOVLW      0
	MOVWF      FARG_Move_Y_steps+1
	CALL       _Move_Y+0
;ACB_2.c,308 :: 		k--;
	MOVLW      1
	SUBWF      _k+0, 1
	BTFSS      STATUS+0, 0
	DECF       _k+1, 1
;ACB_2.c,309 :: 		}
	GOTO       L_Move91
L_Move92:
;ACB_2.c,310 :: 		} else { // Down
	GOTO       L_Move93
L_Move90:
;ACB_2.c,311 :: 		k = step_count;
	MOVF       _step_count+0, 0
	MOVWF      _k+0
	MOVF       _step_count+1, 0
	MOVWF      _k+1
;ACB_2.c,312 :: 		while (k > 0) {
L_Move94:
	MOVF       _k+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Move138
	MOVF       _k+0, 0
	SUBLW      0
L__Move138:
	BTFSC      STATUS+0, 0
	GOTO       L_Move95
;ACB_2.c,313 :: 		Move_Y(0, Square_Size);
	CLRF       FARG_Move_Y_dir+0
	MOVLW      250
	MOVWF      FARG_Move_Y_steps+0
	MOVLW      0
	MOVWF      FARG_Move_Y_steps+1
	CALL       _Move_Y+0
;ACB_2.c,314 :: 		k--;
	MOVLW      1
	SUBWF      _k+0, 1
	BTFSS      STATUS+0, 0
	DECF       _k+1, 1
;ACB_2.c,315 :: 		}
	GOTO       L_Move94
L_Move95:
;ACB_2.c,316 :: 		}
L_Move93:
;ACB_2.c,317 :: 		step_count = abs(endx - startx);
	MOVF       FARG_Move_startx+0, 0
	SUBWF      FARG_Move_endx+0, 0
	MOVWF      FARG_abs_a+0
	CLRF       FARG_abs_a+1
	BTFSS      STATUS+0, 0
	DECF       FARG_abs_a+1, 1
	CALL       _abs+0
	MOVF       R0+0, 0
	MOVWF      _step_count+0
	MOVF       R0+1, 0
	MOVWF      _step_count+1
;ACB_2.c,318 :: 		if (endx > startx) { // Right
	MOVF       FARG_Move_endx+0, 0
	SUBWF      FARG_Move_startx+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_Move96
;ACB_2.c,319 :: 		k = step_count;
	MOVF       _step_count+0, 0
	MOVWF      _k+0
	MOVF       _step_count+1, 0
	MOVWF      _k+1
;ACB_2.c,320 :: 		while (k > 0) {
L_Move97:
	MOVF       _k+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Move139
	MOVF       _k+0, 0
	SUBLW      0
L__Move139:
	BTFSC      STATUS+0, 0
	GOTO       L_Move98
;ACB_2.c,321 :: 		Move_X(1, Square_Size);
	MOVLW      1
	MOVWF      FARG_Move_X_dir+0
	MOVLW      250
	MOVWF      FARG_Move_X_steps+0
	MOVLW      0
	MOVWF      FARG_Move_X_steps+1
	CALL       _Move_X+0
;ACB_2.c,322 :: 		k--;
	MOVLW      1
	SUBWF      _k+0, 1
	BTFSS      STATUS+0, 0
	DECF       _k+1, 1
;ACB_2.c,323 :: 		}
	GOTO       L_Move97
L_Move98:
;ACB_2.c,324 :: 		} else { // Left
	GOTO       L_Move99
L_Move96:
;ACB_2.c,325 :: 		k = step_count;
	MOVF       _step_count+0, 0
	MOVWF      _k+0
	MOVF       _step_count+1, 0
	MOVWF      _k+1
;ACB_2.c,326 :: 		while (k > 0) {
L_Move100:
	MOVF       _k+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__Move140
	MOVF       _k+0, 0
	SUBLW      0
L__Move140:
	BTFSC      STATUS+0, 0
	GOTO       L_Move101
;ACB_2.c,327 :: 		Move_X(0, Square_Size);
	CLRF       FARG_Move_X_dir+0
	MOVLW      250
	MOVWF      FARG_Move_X_steps+0
	MOVLW      0
	MOVWF      FARG_Move_X_steps+1
	CALL       _Move_X+0
;ACB_2.c,328 :: 		k--;
	MOVLW      1
	SUBWF      _k+0, 1
	BTFSS      STATUS+0, 0
	DECF       _k+1, 1
;ACB_2.c,329 :: 		}
	GOTO       L_Move100
L_Move101:
;ACB_2.c,330 :: 		}
L_Move99:
;ACB_2.c,331 :: 		}
L_Move89:
;ACB_2.c,332 :: 		}
L_end_Move:
	RETURN
; end of _Move

_Move_motors:

;ACB_2.c,334 :: 		void Move_motors() {
;ACB_2.c,335 :: 		if (Move_Type == 'x') {
	MOVF       _Move_Type+0, 0
	XORLW      120
	BTFSS      STATUS+0, 2
	GOTO       L_Move_motors102
;ACB_2.c,337 :: 		Move('1', endy, endx, endy);
	MOVLW      49
	MOVWF      FARG_Move_startx+0
	MOVF       _endy+0, 0
	MOVWF      FARG_Move_starty+0
	MOVF       _endx+0, 0
	MOVWF      FARG_Move_endx+0
	MOVF       _endy+0, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,338 :: 		Move(endx, '1', endx, endy);
	MOVF       _endx+0, 0
	MOVWF      FARG_Move_startx+0
	MOVLW      49
	MOVWF      FARG_Move_starty+0
	MOVF       _endx+0, 0
	MOVWF      FARG_Move_endx+0
	MOVF       _endy+0, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,339 :: 		PORTE = PORTE | 0x04; // Magnet On
	BSF        PORTE+0, 2
;ACB_2.c,340 :: 		msDelay(500);
	MOVLW      244
	MOVWF      FARG_msDelay_ms+0
	MOVLW      1
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,341 :: 		Move_D(3, 128);              // Top right of square
	MOVLW      3
	MOVWF      FARG_Move_D_dir+0
	MOVLW      128
	MOVWF      FARG_Move_D_steps+0
	CLRF       FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,342 :: 		Move(endx, endy, '8', endy); // Edge of box
	MOVF       _endx+0, 0
	MOVWF      FARG_Move_startx+0
	MOVF       _endy+0, 0
	MOVWF      FARG_Move_starty+0
	MOVLW      56
	MOVWF      FARG_Move_endx+0
	MOVF       _endy+0, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,343 :: 		Move_X(1, home_X);           // Out of box
	MOVLW      1
	MOVWF      FARG_Move_X_dir+0
	MOVLW      140
	MOVWF      FARG_Move_X_steps+0
	MOVLW      0
	MOVWF      FARG_Move_X_steps+1
	CALL       _Move_X+0
;ACB_2.c,344 :: 		PORTE = PORTE & 0xFB;        // Magnet Off
	MOVLW      251
	ANDWF      PORTE+0, 1
;ACB_2.c,345 :: 		msDelay(500);
	MOVLW      244
	MOVWF      FARG_msDelay_ms+0
	MOVLW      1
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,346 :: 		Move_Home(); // return home
	CALL       _Move_Home+0
;ACB_2.c,347 :: 		Move('1', starty, startx, starty);
	MOVLW      49
	MOVWF      FARG_Move_startx+0
	MOVF       _starty+0, 0
	MOVWF      FARG_Move_starty+0
	MOVF       _startx+0, 0
	MOVWF      FARG_Move_endx+0
	MOVF       _starty+0, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,348 :: 		Move(startx, '1', startx, starty); // Go to pickup
	MOVF       _startx+0, 0
	MOVWF      FARG_Move_startx+0
	MOVLW      49
	MOVWF      FARG_Move_starty+0
	MOVF       _startx+0, 0
	MOVWF      FARG_Move_endx+0
	MOVF       _starty+0, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,350 :: 		PORTE = PORTE | 0x04; // Magnet On
	BSF        PORTE+0, 2
;ACB_2.c,351 :: 		msDelay(500);
	MOVLW      244
	MOVWF      FARG_msDelay_ms+0
	MOVLW      1
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,352 :: 		Move_D(3, 128); // Top right of square
	MOVLW      3
	MOVWF      FARG_Move_D_dir+0
	MOVLW      128
	MOVWF      FARG_Move_D_steps+0
	CLRF       FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,353 :: 		Move(startx, starty, endx, endy);
	MOVF       _startx+0, 0
	MOVWF      FARG_Move_startx+0
	MOVF       _starty+0, 0
	MOVWF      FARG_Move_starty+0
	MOVF       _endx+0, 0
	MOVWF      FARG_Move_endx+0
	MOVF       _endy+0, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,354 :: 		Move_D(0, 128);       // bottom left of square
	CLRF       FARG_Move_D_dir+0
	MOVLW      128
	MOVWF      FARG_Move_D_steps+0
	CLRF       FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,355 :: 		PORTE = PORTE & 0xFB; // Magnet Off
	MOVLW      251
	ANDWF      PORTE+0, 1
;ACB_2.c,356 :: 		msDelay(500);
	MOVLW      244
	MOVWF      FARG_msDelay_ms+0
	MOVLW      1
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,358 :: 		} else if (myRxBuffer[3] = 't') {
	GOTO       L_Move_motors103
L_Move_motors102:
	MOVLW      116
	MOVWF      _myRxBuffer+3
;ACB_2.c,360 :: 		startx = myRxBuffer[1];
	MOVF       _myRxBuffer+1, 0
	MOVWF      _startx+0
;ACB_2.c,361 :: 		starty = myRxBuffer[2];
	MOVF       _myRxBuffer+2, 0
	MOVWF      _starty+0
;ACB_2.c,362 :: 		endx = myRxBuffer[4];
	MOVF       _myRxBuffer+4, 0
	MOVWF      _endx+0
;ACB_2.c,363 :: 		endy = myRxbuffer[5];
	MOVF       _myRxBuffer+5, 0
	MOVWF      _endy+0
;ACB_2.c,364 :: 		Move('1', starty, startx, starty);
	MOVLW      49
	MOVWF      FARG_Move_startx+0
	MOVF       _myRxBuffer+2, 0
	MOVWF      FARG_Move_starty+0
	MOVF       _myRxBuffer+1, 0
	MOVWF      FARG_Move_endx+0
	MOVF       _myRxBuffer+2, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,365 :: 		Move(startx, '1', startx, starty);
	MOVF       _startx+0, 0
	MOVWF      FARG_Move_startx+0
	MOVLW      49
	MOVWF      FARG_Move_starty+0
	MOVF       _startx+0, 0
	MOVWF      FARG_Move_endx+0
	MOVF       _starty+0, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,366 :: 		msDelay(500);
	MOVLW      244
	MOVWF      FARG_msDelay_ms+0
	MOVLW      1
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,367 :: 		PORTE = PORTE | 0x04; // Magnet On
	BSF        PORTE+0, 2
;ACB_2.c,368 :: 		Move_D(3, 128);       // Top right of square
	MOVLW      3
	MOVWF      FARG_Move_D_dir+0
	MOVLW      128
	MOVWF      FARG_Move_D_steps+0
	CLRF       FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,369 :: 		msDelay(500);
	MOVLW      244
	MOVWF      FARG_msDelay_ms+0
	MOVLW      1
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,370 :: 		Move(startx, starty, endx, endy);
	MOVF       _startx+0, 0
	MOVWF      FARG_Move_startx+0
	MOVF       _starty+0, 0
	MOVWF      FARG_Move_starty+0
	MOVF       _endx+0, 0
	MOVWF      FARG_Move_endx+0
	MOVF       _endy+0, 0
	MOVWF      FARG_Move_endy+0
	CALL       _Move+0
;ACB_2.c,371 :: 		msDelay(500);
	MOVLW      244
	MOVWF      FARG_msDelay_ms+0
	MOVLW      1
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,372 :: 		Move_D(0, 128);       // bottom left of square
	CLRF       FARG_Move_D_dir+0
	MOVLW      128
	MOVWF      FARG_Move_D_steps+0
	CLRF       FARG_Move_D_steps+1
	CALL       _Move_D+0
;ACB_2.c,373 :: 		PORTE = PORTE & 0xFB; // Magnet Off
	MOVLW      251
	ANDWF      PORTE+0, 1
;ACB_2.c,374 :: 		msDelay(500);
	MOVLW      244
	MOVWF      FARG_msDelay_ms+0
	MOVLW      1
	MOVWF      FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,375 :: 		}
L_Move_motors103:
;ACB_2.c,377 :: 		Move_Home();
	CALL       _Move_Home+0
;ACB_2.c,378 :: 		}
L_end_Move_motors:
	RETURN
; end of _Move_motors

_ATD_init:

;ACB_2.c,380 :: 		void ATD_init(void){
;ACB_2.c,381 :: 		ADCON0 = 0x41;// ATD ON, Don't GO, Channel 0, Fosc/16
	MOVLW      65
	MOVWF      ADCON0+0
;ACB_2.c,382 :: 		ADCON1 = 0x4E;// A0  Analog, 500 KHz, left justified
	MOVLW      78
	MOVWF      ADCON1+0
;ACB_2.c,383 :: 		TRISA = 0x01;
	MOVLW      1
	MOVWF      TRISA+0
;ACB_2.c,385 :: 		}
L_end_ATD_init:
	RETURN
; end of _ATD_init

_ATD_read:

;ACB_2.c,386 :: 		unsigned char ATD_read(void){
;ACB_2.c,387 :: 		ADCON0 = ADCON0 | 0x04;// GO
	BSF        ADCON0+0, 2
;ACB_2.c,388 :: 		while(ADCON0 & 0x04);
L_ATD_read105:
	BTFSS      ADCON0+0, 2
	GOTO       L_ATD_read106
	GOTO       L_ATD_read105
L_ATD_read106:
;ACB_2.c,389 :: 		return ADRESH;
	MOVF       ADRESH+0, 0
	MOVWF      R0+0
;ACB_2.c,390 :: 		}
L_end_ATD_read:
	RETURN
; end of _ATD_read

_read_level:

;ACB_2.c,392 :: 		unsigned char read_level(){
;ACB_2.c,394 :: 		do{
L_read_level107:
;ACB_2.c,395 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;ACB_2.c,396 :: 		lvl = ATD_read();
	CALL       _ATD_read+0
	MOVF       R0+0, 0
	MOVWF      read_level_lvl_L0+0
;ACB_2.c,397 :: 		lvl = (lvl*4)/255;
	MOVF       R0+0, 0
	MOVWF      R2+0
	CLRF       R2+1
	RLF        R2+0, 1
	RLF        R2+1, 1
	BCF        R2+0, 0
	RLF        R2+0, 1
	RLF        R2+1, 1
	BCF        R2+0, 0
	MOVF       R2+0, 0
	MOVWF      R0+0
	MOVF       R2+1, 0
	MOVWF      R0+1
	MOVLW      255
	MOVWF      R4+0
	CLRF       R4+1
	CALL       _Div_16x16_S+0
	MOVF       R0+0, 0
	MOVWF      read_level_lvl_L0+0
;ACB_2.c,398 :: 		LCD_Out(1,1, "Level: ");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr11_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,399 :: 		txtlvl[0] = lvl+'1';
	MOVLW      49
	ADDWF      read_level_lvl_L0+0, 0
	MOVWF      _txtlvl+0
;ACB_2.c,400 :: 		LCD_Out(1,8,txtlvl);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _txtlvl+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,401 :: 		Lcd_Out(2, 1, "Confrim?");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr12_ACB_2+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;ACB_2.c,402 :: 		msDelay(150);
	MOVLW      150
	MOVWF      FARG_msDelay_ms+0
	CLRF       FARG_msDelay_ms+1
	CALL       _msDelay+0
;ACB_2.c,404 :: 		} while (!(PORTD & 0x01));
	BTFSS      PORTD+0, 0
	GOTO       L_read_level107
;ACB_2.c,405 :: 		return lvl;
	MOVF       read_level_lvl_L0+0, 0
	MOVWF      R0+0
;ACB_2.c,406 :: 		}
L_end_read_level:
	RETURN
; end of _read_level

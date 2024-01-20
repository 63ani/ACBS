void msDelay(unsigned int ms);
void Move_X(unsigned char dir, unsigned int steps);
void Move_Y(unsigned char dir, unsigned int steps);
void Move_D(unsigned char dir, unsigned int steps);
void Move(char startx, char starty, char endx, char endy);
void Move_Home();
void USART_Init();
void USART_Tx(char trans);
void Move_motors();
void MotorDelay();
void ATD_init(void);
unsigned char ATD_read(void);
unsigned char read_level();


unsigned int i;
unsigned char level;
unsigned char a;
unsigned int k;
unsigned int tick;
unsigned int step_count;
const unsigned int square_size = 250;
const unsigned int home_x = 140;
unsigned char myRxBuffer[] = "              ";
unsigned char Rx_count = 0;
char txtkp[] = "    ";
char txtlvl[2] = " ";
unsigned char myRxflag = 0;
unsigned char Move_Valid;
unsigned char startx, starty, endx, endy;
unsigned char Move_Type;

sbit LCD_RS at RC4_bit;
sbit LCD_EN at RC5_bit;
sbit LCD_D4 at RA2_bit;
sbit LCD_D5 at RB1_bit;
sbit LCD_D6 at RB2_bit;
sbit LCD_D7 at RB3_bit;

sbit LCD_RS_Direction at TRISC4_bit;
sbit LCD_EN_Direction at TRISC5_bit;
sbit LCD_D4_Direction at TRISA2_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D7_Direction at TRISB3_bit;

char serial[] = "     ";
char game;

void interrupt(void) {
  if (INTCON & 0x01) {      // PORTB Change interrupt
    if (PORTB & 0x10)       // X_Limit = 1
      PORTE = PORTE | 0x01; // Turn off X axis motor
    else if (PORTB & 0x20)  // Y_Limit = 1
      PORTE = PORTE | 0x02; // Turn off Y axis motor

    INTCON = INTCON & 0xFE; // Clear RBIF
  } else if (PIR1 & 0x20) { // Received data
    myRxBuffer[Rx_count] = RCREG;
    Rx_count++;
    PIR1 = PIR1 & 0xDF;       // Clear RCIF
  } else if (INTCON & 0x04) { // TMRO overflow
    TMR0 = 248;
    tick++;
    INTCON = INTCON & 0xFB;
  }
}

void main() {
  ADCON0 = 0x41;// ATD ON, Don't GO, Channel 0, Fosc/16
  ADCON1 = 0x4E;// A0  Analog, 500 KHz, left justified
  TRISA = 0x01;  // RA2 = D1 (LCD), RA0 = Analog input (Potentiometer)
  TRISB = 0x30;  // RB1-RB3 = D2-D4, RB4 = Switch_X, RB5 = Switch_Y, RB6 and RB7
                 // (not used)
  TRISC = 0x80;  // RC0 = Step_X, RC1 = Dir_X, RC2 = Step_Y, RC3 = Dir_Y, RC4 =
                 // RS, RC5 = E, RC6 = Tx RC7 = Rx
  TRISD = 0x01; // RD0 = Push button
  TRISE = 0x00; // RE0 = EN_X, RE1 = EN_Y (active low), RE2 = Magnet

  PORTC = 0x00;
  PORTE = 0x03;  // Motors OFF
  INTCON = 0xE8; // GIE, RBIE, PEIE, and TMR0IE
  OPTION_REG = 0x87;
  TMR0 = 248;


  Lcd_Init();
  USART_Init();
  Lcd_Cmd(_LCD_CLEAR);      // Clear display
  Lcd_Cmd(_LCD_CURSOR_OFF); // Cursor off
  Move_Home();
  Rx_count = 0;
  while (1) {
    Lcd_Cmd(_LCD_CLEAR);
    Lcd_Out(1, 1, "Welcome to ACBS");
    Lcd_Out(2, 1, "Start?");
    // Wait for start key to be pressed and released
    while (!(PORTD & 0x01));
    USART_Tx('S');

    msDelay(200);
    level = read_level();
    USART_TX(level+'0');

    Lcd_Cmd(_LCD_CLEAR);
    Lcd_Out(1, 1, "Game On");
    game = 1;


    do { // Game is on
      Lcd_Cmd(_LCD_CLEAR);
      Lcd_Out(1, 1, "Enter Move...");
      Rx_Count = 0;
      while (Rx_count != 6);           // Wait for recieval of the Move
      Rx_count = 0; // Reset rx counter
      Move_Valid = myRXBuffer[0];
      startx = myRxBuffer[1];
      starty = myRxBuffer[2];
      Move_Type = myRxBuffer[3];
      endx = myRxBuffer[4];
      endy = myRxbuffer[5];

      if (Move_Valid == 'L') { // Move is legal
        Lcd_Cmd(_LCD_CLEAR);
        Lcd_Out(1, 1, "Player Moving...");
        Move_motors();
        USART_Tx('D');
      }

      else if (Move_Valid == 'M') {
        // Display player wins
        Lcd_Cmd(_LCD_CLEAR);
        Lcd_Out(1, 1, "Game ended");
        Lcd_Out(2, 1, "Player wins");
        game = 0;
        break;
      }
      Rx_Count = 0;
      while (Rx_count != 6);           // Wait to recieve engine move
      Rx_count = 0; // reset counter
      Move_Valid = myRXBuffer[0];
      startx = myRxBuffer[1];
      starty = myRxBuffer[2];
      Move_Type = myRxBuffer[3];
      endx = myRxBuffer[4];
      endy = myRxbuffer[5];

      if (Move_Valid == 'E'){
        Lcd_Cmd(_LCD_CLEAR);
        Lcd_Out(1, 1, "Engine Moving...");
        Move_motors();
        USART_Tx('D');
      }

      else if (Move_Valid == 'M') {
        // Display Engine wins
        Lcd_Cmd(_LCD_CLEAR);
        Lcd_Out(1, 1, "Game ended");
        Lcd_Out(2, 1, "Engine wins");
        game = 0;
        break;
      }
    } while (game);
    msDelay(60000); // Wait one minute
  }
}

void msDelay(unsigned int ms) {
  tick = 0;
  while (tick < ms)
    ;
}

void MotorDelay() {
  for (a = 0; a < 200; a++)
    ;
}


void Move_X(unsigned char dir, unsigned int steps) {
  unsigned int j;
  if (dir)
    PORTC = 0x02; // Dir_X (RC1) = 1 (right)
  else
    PORTC = 0x00; // Dir_X (RC1) = 0 (left)

  PORTE = PORTE & 0xFE; // EN_X (RE0) = 0 (Enable X motor)

  for (j = 0; j < steps; j++) {
    PORTC = PORTC & 0xFE; // Step_X (RC0) = 0
    MotorDelay();
    PORTC = PORTC | 0x01; // Step_X (RC0) = 1
    MotorDelay();
  }

  PORTE = PORTE | 0x03; // Disable all motors
}

void Move_Y(unsigned char dir, unsigned int steps) {
  unsigned int j;
  if (dir)
    PORTC = 0x08; // Dir_Y (RC3) = 1 (up)
  else
    PORTC = 0x00; // Dir_Y (RC3) = 0 (down)

  PORTE = PORTE & 0xFD; // EN_Y (RE1) = 0 (Enable Y motor)

  for (j = 0; j < steps; j++) {
    PORTC = PORTC & 0xFB; // Step_Y (RC2) = 0
    MotorDelay();
    PORTC = PORTC | 0x04; // Step_Y (RC2) = 1
    MotorDelay();
  }

  PORTE = PORTE | 0x03; // Disable all motors
}

void Move_D(unsigned char dir, unsigned int steps) {
  unsigned int j;
  if (dir == 0)
    PORTC = 0x00; // Dir_Y (RC3) = 0, Dir_X (RC1) = 0 (bottom left)
  else if (dir == 1)
    PORTC = 0x02; // Dir_Y (RC3) = 0, Dir_X (RC1) = 1 (bottom right)
  else if (dir == 2)
    PORTC = 0x08; // Dir_Y (RC3) = 1, Dir_X (RC1) = 0 (top left)
  else if (dir == 3)
    PORTC = 0x0A; // Dir_Y (RC3) = 1, Dir_X (RC1) = 1 (top right)

  PORTE = PORTE & 0xFC; // EN_X (RE0) = 0, EN_Y (RE1) = 0 (Enable X & Y motors)

  for (j = 0; j < steps; j++) {
    PORTC = PORTC & 0xFA; // Step_X (RC0) = 0, Step_Y (RC2) = 0
    MotorDelay();
    PORTC = PORTC | 0x05; // Step_X (RC0) = 1, Step_Y (RC2) = 1
    MotorDelay();
  }

  PORTE = PORTE | 0x03; // Disable all motors
}

// Move to the bottom left (home position, a1) untill switch is pressed
// (interrupt)
void Move_Home() {
  while (1) {
    if (!(PORTB & 0x10) && !(PORTB & 0X20)) { // Both Switches not hit
      Move_D(0, 300);
    } else if (!(PORTB & 0x10)) // RB4 == 0
      Move_X(0, 300);
    else if (!(PORTB & 0X20)) // RB5 == 0
      Move_Y(0, 300);
    else if ((PORTB & 0x10) && (PORTB & 0x20))
      break;
  }
  Move_X(1, home_X);
}

void USART_Init() {
  SPBRG = 12;   // 9600 Baud Rate
  TXSTA = 0x20; // 8-bit, Tx enable, Async, Low speed
  RCSTA = 0x90; // SP Enbale, 8-bit, cont. Rx
  TRISC = 0x80;
  PIE1 = PIE1 | 0x20; // RCIE
}
void USART_Tx(char trans) {
  while (!(TXSTA & 0x02));
  TXREG = trans;
}


void Move(char startx, char starty, char endx, char endy) {
  if ((endx - startx) == (endy - starty)) { // Move is diagonal
    step_count = abs(endy - starty);
    if (endx > startx && endy > starty) // Up, right
    {
      k = step_count;
      while (k > 0) {
        Move_D(3, Square_Size);
        k--;
      }
    } else if (endx > startx && starty > endy) // Down, right
    {
      k = step_count;
      while (k > 0) {
        Move_D(1, Square_Size);
        k--;
      }
    } else if (startx > endx && starty > endy) // Down, left
    {
      k = step_count;
      while (k > 0) {
        Move_D(0, Square_Size);
        k--;
      }
    } else if (startx > endx && endy > starty) // Up, left
    {
      k = step_count;
      while (k > 0) {
        Move_D(2, Square_Size);
        k--;
      }
    }
  } else { // Move is not diagonal
    step_count = abs(endy - starty);
    if (endy > starty) { // Up
      k = step_count;
      while (k > 0) {
        Move_Y(1, Square_Size);
        k--;
      }
    } else { // Down
      k = step_count;
      while (k > 0) {
       Move_Y(0, Square_Size);
        k--;
      }
    }
    step_count = abs(endx - startx);
    if (endx > startx) { // Right
      k = step_count;
      while (k > 0) {
        Move_X(1, Square_Size);
        k--;
      }
    } else { // Left
      k = step_count;
      while (k > 0) {
        Move_X(0, Square_Size);
        k--;
      }
    }
  }
}

void Move_motors() {
  if (Move_Type == 'x') {
    // Capture move
    Move('1', endy, endx, endy);
    Move(endx, '1', endx, endy);
    PORTE = PORTE | 0x04; // Magnet On
    msDelay(500);
    Move_D(3, 128);              // Top right of square
    Move(endx, endy, '8', endy); // Edge of box
    Move_X(1, home_X);           // Out of box
    PORTE = PORTE & 0xFB;        // Magnet Off
    msDelay(500);
    Move_Home(); // return home
    Move('1', starty, startx, starty);
    Move(startx, '1', startx, starty); // Go to pickup

    PORTE = PORTE | 0x04; // Magnet On
    msDelay(500);
    Move_D(3, 128); // Top right of square
    Move(startx, starty, endx, endy);
    Move_D(0, 128);       // bottom left of square
    PORTE = PORTE & 0xFB; // Magnet Off
    msDelay(500);

  } else if (myRxBuffer[3] = 't') {
    // Normal Move
    startx = myRxBuffer[1];
    starty = myRxBuffer[2];
    endx = myRxBuffer[4];
    endy = myRxbuffer[5];
    Move('1', starty, startx, starty);
    Move(startx, '1', startx, starty);
    msDelay(500);
    PORTE = PORTE | 0x04; // Magnet On
    Move_D(3, 128);       // Top right of square
    msDelay(500);
    Move(startx, starty, endx, endy);
    msDelay(500);
    Move_D(0, 128);       // bottom left of square
    PORTE = PORTE & 0xFB; // Magnet Off
    msDelay(500);
  }

  Move_Home();
}

void ATD_init(void){
 ADCON0 = 0x41;// ATD ON, Don't GO, Channel 0, Fosc/16
 ADCON1 = 0x4E;// A0  Analog, 500 KHz, left justified
 TRISA = 0x01;

}
unsigned char ATD_read(void){
  ADCON0 = ADCON0 | 0x04;// GO
  while(ADCON0 & 0x04);
  return ADRESH;
}

unsigned char read_level(){
   unsigned char lvl;
   do{
   Lcd_Cmd(_LCD_CLEAR);
   lvl = ATD_read();
   lvl = (lvl*4)/255;
   LCD_Out(1,1, "Level: ");
   txtlvl[0] = lvl+'1';
   LCD_Out(1,8,txtlvl);
   Lcd_Out(2, 1, "Confrim?");
   msDelay(150);

   } while (!(PORTD & 0x01));
   return lvl;
}
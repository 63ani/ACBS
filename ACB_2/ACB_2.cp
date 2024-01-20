#line 1 "D:/Uni/Embedded/ACB_2/ACB_2.c"
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
 if (INTCON & 0x01) {
 if (PORTB & 0x10)
 PORTE = PORTE | 0x01;
 else if (PORTB & 0x20)
 PORTE = PORTE | 0x02;

 INTCON = INTCON & 0xFE;
 } else if (PIR1 & 0x20) {
 myRxBuffer[Rx_count] = RCREG;
 Rx_count++;
 PIR1 = PIR1 & 0xDF;
 } else if (INTCON & 0x04) {
 TMR0 = 248;
 tick++;
 INTCON = INTCON & 0xFB;
 }
}

void main() {
 ADCON0 = 0x41;
 ADCON1 = 0x4E;
 TRISA = 0x01;
 TRISB = 0x30;

 TRISC = 0x80;

 TRISD = 0x01;
 TRISE = 0x00;

 PORTC = 0x00;
 PORTE = 0x03;
 INTCON = 0xE8;
 OPTION_REG = 0x87;
 TMR0 = 248;


 Lcd_Init();
 USART_Init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
 Move_Home();
 Rx_count = 0;
 while (1) {
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1, 1, "Welcome to ACBS");
 Lcd_Out(2, 1, "Start?");

 while (!(PORTD & 0x01));
 USART_Tx('S');

 msDelay(200);
 level = read_level();
 USART_TX(level+'0');

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1, 1, "Game On");
 game = 1;


 do {
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1, 1, "Enter Move...");
 Rx_Count = 0;
 while (Rx_count != 6);
 Rx_count = 0;
 Move_Valid = myRXBuffer[0];
 startx = myRxBuffer[1];
 starty = myRxBuffer[2];
 Move_Type = myRxBuffer[3];
 endx = myRxBuffer[4];
 endy = myRxbuffer[5];

 if (Move_Valid == 'L') {
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1, 1, "Player Moving...");
 Move_motors();
 USART_Tx('D');
 }

 else if (Move_Valid == 'M') {

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1, 1, "Game ended");
 Lcd_Out(2, 1, "Player wins");
 game = 0;
 break;
 }
 Rx_Count = 0;
 while (Rx_count != 6);
 Rx_count = 0;
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

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Out(1, 1, "Game ended");
 Lcd_Out(2, 1, "Engine wins");
 game = 0;
 break;
 }
 } while (game);
 msDelay(60000);
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
 PORTC = 0x02;
 else
 PORTC = 0x00;

 PORTE = PORTE & 0xFE;

 for (j = 0; j < steps; j++) {
 PORTC = PORTC & 0xFE;
 MotorDelay();
 PORTC = PORTC | 0x01;
 MotorDelay();
 }

 PORTE = PORTE | 0x03;
}

void Move_Y(unsigned char dir, unsigned int steps) {
 unsigned int j;
 if (dir)
 PORTC = 0x08;
 else
 PORTC = 0x00;

 PORTE = PORTE & 0xFD;

 for (j = 0; j < steps; j++) {
 PORTC = PORTC & 0xFB;
 MotorDelay();
 PORTC = PORTC | 0x04;
 MotorDelay();
 }

 PORTE = PORTE | 0x03;
}

void Move_D(unsigned char dir, unsigned int steps) {
 unsigned int j;
 if (dir == 0)
 PORTC = 0x00;
 else if (dir == 1)
 PORTC = 0x02;
 else if (dir == 2)
 PORTC = 0x08;
 else if (dir == 3)
 PORTC = 0x0A;

 PORTE = PORTE & 0xFC;

 for (j = 0; j < steps; j++) {
 PORTC = PORTC & 0xFA;
 MotorDelay();
 PORTC = PORTC | 0x05;
 MotorDelay();
 }

 PORTE = PORTE | 0x03;
}



void Move_Home() {
 while (1) {
 if (!(PORTB & 0x10) && !(PORTB & 0X20)) {
 Move_D(0, 300);
 } else if (!(PORTB & 0x10))
 Move_X(0, 300);
 else if (!(PORTB & 0X20))
 Move_Y(0, 300);
 else if ((PORTB & 0x10) && (PORTB & 0x20))
 break;
 }
 Move_X(1, home_X);
}

void USART_Init() {
 SPBRG = 12;
 TXSTA = 0x20;
 RCSTA = 0x90;
 TRISC = 0x80;
 PIE1 = PIE1 | 0x20;
}
void USART_Tx(char trans) {
 while (!(TXSTA & 0x02));
 TXREG = trans;
}


void Move(char startx, char starty, char endx, char endy) {
 if ((endx - startx) == (endy - starty)) {
 step_count = abs(endy - starty);
 if (endx > startx && endy > starty)
 {
 k = step_count;
 while (k > 0) {
 Move_D(3, Square_Size);
 k--;
 }
 } else if (endx > startx && starty > endy)
 {
 k = step_count;
 while (k > 0) {
 Move_D(1, Square_Size);
 k--;
 }
 } else if (startx > endx && starty > endy)
 {
 k = step_count;
 while (k > 0) {
 Move_D(0, Square_Size);
 k--;
 }
 } else if (startx > endx && endy > starty)
 {
 k = step_count;
 while (k > 0) {
 Move_D(2, Square_Size);
 k--;
 }
 }
 } else {
 step_count = abs(endy - starty);
 if (endy > starty) {
 k = step_count;
 while (k > 0) {
 Move_Y(1, Square_Size);
 k--;
 }
 } else {
 k = step_count;
 while (k > 0) {
 Move_Y(0, Square_Size);
 k--;
 }
 }
 step_count = abs(endx - startx);
 if (endx > startx) {
 k = step_count;
 while (k > 0) {
 Move_X(1, Square_Size);
 k--;
 }
 } else {
 k = step_count;
 while (k > 0) {
 Move_X(0, Square_Size);
 k--;
 }
 }
 }
}

void Move_motors() {
 if (Move_Type == 'C') {

 } else if (Move_Type == 'c') {

 } else if (Move_Type == 'e') {

 } else if (Move_Type == 'x') {

 Move('1', endy, endx, endy);
 Move(endx, '1', endx, endy);
 PORTE = PORTE | 0x04;
 msDelay(500);
 Move_D(3, 128);
 Move(endx, endy, '8', endy);
 Move_X(1, home_X);
 PORTE = PORTE & 0xFB;
 msDelay(500);
 Move_Home();
 Move('1', starty, startx, starty);
 Move(startx, '1', startx, starty);

 PORTE = PORTE | 0x04;
 msDelay(500);
 Move_D(3, 128);
 Move(startx, starty, endx, endy);
 Move_D(0, 128);
 PORTE = PORTE & 0xFB;
 msDelay(500);

 } else if (myRxBuffer[3] = 't') {

 startx = myRxBuffer[1];
 starty = myRxBuffer[2];
 endx = myRxBuffer[4];
 endy = myRxbuffer[5];
 Move('1', starty, startx, starty);
 Move(startx, '1', startx, starty);
 msDelay(500);
 PORTE = PORTE | 0x04;
 Move_D(3, 128);
 msDelay(500);
 Move(startx, starty, endx, endy);
 msDelay(500);
 Move_D(0, 128);
 PORTE = PORTE & 0xFB;
 msDelay(500);
 }

 Move_Home();
}

void ATD_init(void){
 ADCON0 = 0x41;
 ADCON1 = 0x4E;
 TRISA = 0x01;

}
unsigned char ATD_read(void){
 ADCON0 = ADCON0 | 0x04;
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

char kp[] = {" abcdefgh12345678"};

void keypad_scan(char a, char num) {
  knum = 0;
  do {
    knum = Keypad_Key_Click();
    if (knum == 13 && a != 0) { // Backspace key pressed
      Lcd_Out(1, 12 + a, " ");  // Clear the last character on LCD
      serial[a] = '\0';         // Remove the last character from serial array
    }
  } while ((knum < 1 || knum > 8) && knum != 13);
  if (knum != 13) { // If not backspace
    txtkp[0] = kp[knum + num];
    Lcd_Out(1, 13 + a, txtkp);
    serial[a] = kp[knum + num];
  }
}

void Player_turn() {
  char position = 0;
  do {
    position = 0;
    Lcd_Cmd(_LCD_CLEAR);
    Lcd_Out(1, 1, "Enter Move:");

    while (position < 4) { // Limit input to 4 characters
      // Check position and call appropriate function
      if (position == 0 || position == 2) {
        keypad_scan(position, 0);
      } else {
        keypad_scan(position, 8);
      }

      // Check if the backspace key was pressed and position was decremented
      if (position > 0 && knum == 13) {
        position--; // Go back an additional position for the correct input type
        continue;   // Skip the rest of the loop and re-evaluate
      }

      position++;
    }

    Lcd_Out(2, 1, "Confrim?");
    knum = 0;
    do
      knum = Keypad_Key_Click();
    while (knum != 15 && knum != 14); // Confirm or deny
    Lcd_Cmd(_LCD_CLEAR);

  } while (knum == 14); // Confirm input
}

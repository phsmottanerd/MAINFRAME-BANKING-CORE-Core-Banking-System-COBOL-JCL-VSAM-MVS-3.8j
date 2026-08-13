      *================================================================*
      * PROGRAM: BANKMENU                                             *
      * PURPOSE: MAIN MENU - ROUTES TO ALL BANKING MODULES           *
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKMENU.
       AUTHOR.     MAINFRAME-BANKING-CORE.
       DATE-WRITTEN. 2025.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       COPY WRKSTORE.
       COPY MSGLIB.

       01  WS-SCREEN-LINE        PIC X(79).
       01  WS-SEPARATOR          PIC X(79)
               VALUE ALL '='.

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'BANKMENU'     TO WS-PROGRAM-NAME
           MOVE 'N'            TO WS-ERROR-FLAG
           PERFORM 1000-DISPLAY-MENU
               UNTIL WS-MENU-OPTION = 'X' OR WS-MENU-OPTION = 'x'
           STOP RUN.

       1000-DISPLAY-MENU.
           PERFORM 9900-CLEAR-SCREEN
           DISPLAY WS-SEPARATOR
           DISPLAY '          MAINFRAME BANKING CORE              '
           DISPLAY '          MVS 3.8J TK4- - V1.0               '
           DISPLAY WS-SEPARATOR
           DISPLAY ' '
           DISPLAY '   1 - CUSTOMER MANAGEMENT                    '
           DISPLAY '   2 - ACCOUNT MANAGEMENT                     '
           DISPLAY '   3 - BALANCE INQUIRY                        '
           DISPLAY '   4 - DEPOSIT                                '
           DISPLAY '   5 - WITHDRAWAL                             '
           DISPLAY '   6 - TRANSFER                               '
           DISPLAY '   7 - TRANSACTION HISTORY                    '
           DISPLAY '   8 - ACCOUNT BLOCKING                       '
           DISPLAY '   9 - REPORTS                                '
           DISPLAY '   X - EXIT                                   '
           DISPLAY ' '
           DISPLAY WS-SEPARATOR
           DISPLAY 'SELECT OPTION: ' WITH NO ADVANCING
           ACCEPT  WS-MENU-OPTION
           PERFORM 1100-ROUTE-OPTION.

       1100-ROUTE-OPTION.
           EVALUATE WS-MENU-OPTION
             WHEN '1'
               CALL 'CUSTMGMT'
             WHEN '2'
               CALL 'ACCTMGMT'
             WHEN '3'
               CALL 'BALANCIO'
             WHEN '4'
               CALL 'DEPOSIT'
             WHEN '5'
               CALL 'WITHDRAW'
             WHEN '6'
               CALL 'TRANSFER'
             WHEN '7'
               CALL 'TRANHIST'
             WHEN '8'
               CALL 'ACCTBLCK'
             WHEN '9'
               CALL 'RPTGEN'
             WHEN 'X'  WHEN 'x'
               PERFORM 9800-EXIT-MSG
             WHEN OTHER
               DISPLAY MSG-INVALID-OPT
               PERFORM 9700-PRESS-ENTER
           END-EVALUATE.

       9700-PRESS-ENTER.
           DISPLAY MSG-PRESS-ENTER WITH NO ADVANCING
           ACCEPT  WS-WORK-CHAR.

       9800-EXIT-MSG.
           DISPLAY ' '
           DISPLAY 'THANK YOU FOR USING MAINFRAME BANKING CORE.  '
           DISPLAY 'SESSION ENDED.                               '.

       9900-CLEAR-SCREEN.
           DISPLAY ' '
           DISPLAY ' '
           DISPLAY ' '.

      *================================================================*
      * PROGRAM: ACCTMGMT                                             *
      * PURPOSE: ACCOUNT MANAGEMENT - OPEN / QUERY / UPDATE          *
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ACCTMGMT.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE
               ASSIGN TO CUSTMST
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS RANDOM
               RECORD KEY   IS CUST-ID
               FILE STATUS  IS WS-CUST-FILE-STATUS.
           SELECT ACCOUNT-FILE
               ASSIGN TO ACCTMST
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS DYNAMIC
               RECORD KEY   IS ACCT-NBR
               FILE STATUS  IS WS-ACCT-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  CUSTOMER-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 159 CHARACTERS.
       01  CUSTOMER-FILE-RECORD     PIC X(159).

       FD  ACCOUNT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 110 CHARACTERS.
       01  ACCOUNT-FILE-RECORD      PIC X(110).

       WORKING-STORAGE SECTION.
       COPY WRKSTORE.
       COPY FILESTCD.
       COPY MSGLIB.
       COPY CUSTLAYO.
       COPY ACCTLAYO.

       01  WS-INPUT-ACCT-NBR        PIC X(10).
       01  WS-SUBMENU-OPT           PIC X(01).
       01  WS-SEPARATOR             PIC X(79) VALUE ALL '-'.

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'ACCTMGMT' TO WS-PROGRAM-NAME
           OPEN I-O CUSTOMER-FILE
           IF WS-CUST-FILE-STATUS NOT = '00'
               DISPLAY 'ACCTMGMT: CUSTOMER FILE OPEN ERROR FS='
                        WS-CUST-FILE-STATUS
               STOP RUN
           END-IF
           OPEN I-O ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS = '35'
               OPEN OUTPUT ACCOUNT-FILE
               CLOSE ACCOUNT-FILE
               OPEN I-O ACCOUNT-FILE
           END-IF
           IF WS-ACCT-FILE-STATUS NOT = '00'
               DISPLAY 'ACCTMGMT: ACCOUNT FILE OPEN ERROR FS='
                        WS-ACCT-FILE-STATUS
               CLOSE CUSTOMER-FILE
               STOP RUN
           END-IF
           PERFORM 1000-MENU
               UNTIL WS-SUBMENU-OPT = 'X' OR 'x'
           CLOSE CUSTOMER-FILE
           CLOSE ACCOUNT-FILE
           GOBACK.

       1000-MENU.
           DISPLAY ' '
           DISPLAY '=== ACCOUNT MANAGEMENT ======================'
           DISPLAY '  O - OPEN NEW ACCOUNT                       '
           DISPLAY '  Q - QUERY ACCOUNT                          '
           DISPLAY '  U - UPDATE ACCOUNT                         '
           DISPLAY '  X - RETURN TO MAIN MENU                    '
           DISPLAY '============================================='
           DISPLAY 'OPTION: ' WITH NO ADVANCING
           ACCEPT  WS-SUBMENU-OPT
           EVALUATE WS-SUBMENU-OPT
             WHEN 'O' WHEN 'o'  PERFORM 2000-OPEN-ACCOUNT
             WHEN 'Q' WHEN 'q'  PERFORM 3000-QUERY-ACCOUNT
             WHEN 'U' WHEN 'u'  PERFORM 4000-UPDATE-ACCOUNT
             WHEN 'X' WHEN 'x'  CONTINUE
             WHEN OTHER
               DISPLAY MSG-INVALID-OPT
           END-EVALUATE.

       2000-OPEN-ACCOUNT.
           MOVE SPACES       TO ACCOUNT-RECORD
           MOVE ZEROS        TO ACCT-BALANCE
           MOVE ZEROS        TO ACCT-OVERDRAFT-LIM
           DISPLAY ' '
           DISPLAY '--- OPEN ACCOUNT ----------------------------'
           DISPLAY 'ACCOUNT NUMBER (10): ' WITH NO ADVANCING
           ACCEPT  ACCT-NBR
           IF ACCT-NBR = SPACES
               DISPLAY 'ACCOUNT NUMBER CANNOT BE BLANK'
               GO TO 2000-OPEN-ACCOUNT-EXIT
           END-IF
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           IF WS-ACCT-FILE-STATUS = '00'
               DISPLAY MSG-DUP-KEY
               GO TO 2000-OPEN-ACCOUNT-EXIT
           END-IF
           IF WS-ACCT-FILE-STATUS NOT = '23'
               DISPLAY 'READ ERROR - FS=' WS-ACCT-FILE-STATUS
               GO TO 2000-OPEN-ACCOUNT-EXIT
           END-IF
           DISPLAY 'CUSTOMER ID (8): ' WITH NO ADVANCING
           ACCEPT  ACCT-CUST-ID
           MOVE ACCT-CUST-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           IF WS-CUST-FILE-STATUS = '23'
               DISPLAY MSG-NOT-FOUND
               GO TO 2000-OPEN-ACCOUNT-EXIT
           END-IF
           IF WS-CUST-FILE-STATUS NOT = '00'
               DISPLAY 'CUSTOMER READ ERR FS=' WS-CUST-FILE-STATUS
               GO TO 2000-OPEN-ACCOUNT-EXIT
           END-IF
           IF NOT CUST-ACTIVE
               DISPLAY 'CUSTOMER IS NOT ACTIVE - CANNOT OPEN ACCT'
               GO TO 2000-OPEN-ACCOUNT-EXIT
           END-IF
           DISPLAY 'ACCOUNT TYPE (CH/SV/SL): ' WITH NO ADVANCING
           ACCEPT  ACCT-TYPE
           DISPLAY 'BRANCH CODE (4): ' WITH NO ADVANCING
           ACCEPT  ACCT-BRANCH-CODE
           CALL 'DATEVAL' USING WS-CURRENT-DATE
           MOVE WS-CURRENT-DATE TO ACCT-OPEN-DATE
           MOVE WS-CURRENT-DATE TO ACCT-LAST-MOV-DATE
           MOVE 'A'             TO ACCT-STATUS
           WRITE ACCOUNT-FILE-RECORD FROM ACCOUNT-RECORD
           IF WS-ACCT-FILE-STATUS = '00'
               DISPLAY MSG-OPERATION-OK
               DISPLAY 'ACCOUNT OPENED: ' ACCT-NBR
               ADD 1 TO WS-RECORDS-WRITTEN
           ELSE
               DISPLAY 'WRITE ERROR - FS=' WS-ACCT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     ACCT-NBR
           END-IF
       2000-OPEN-ACCOUNT-EXIT.
           CONTINUE.

       3000-QUERY-ACCOUNT.
           DISPLAY ' '
           DISPLAY '--- QUERY ACCOUNT ---------------------------'
           DISPLAY 'ACCOUNT NUMBER: ' WITH NO ADVANCING
           ACCEPT  WS-INPUT-ACCT-NBR
           MOVE WS-INPUT-ACCT-NBR TO ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           EVALUATE WS-ACCT-FILE-STATUS
             WHEN '00'
               PERFORM 3100-DISPLAY-ACCOUNT
             WHEN '23'
               DISPLAY MSG-NOT-FOUND
             WHEN OTHER
               DISPLAY 'READ ERROR - FS=' WS-ACCT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     ACCT-NBR
           END-EVALUATE.

       3100-DISPLAY-ACCOUNT.
           DISPLAY WS-SEPARATOR
           DISPLAY 'ACCOUNT NBR  : ' ACCT-NBR
           DISPLAY 'CUSTOMER ID  : ' ACCT-CUST-ID
           DISPLAY 'TYPE         : ' ACCT-TYPE
           DISPLAY 'STATUS       : ' ACCT-STATUS
           DISPLAY 'BALANCE      : ' ACCT-BALANCE
           DISPLAY 'OVERDRAFT LIM: ' ACCT-OVERDRAFT-LIM
           DISPLAY 'OPEN DATE    : ' ACCT-OPEN-DATE
           DISPLAY 'LAST MOVEMENT: ' ACCT-LAST-MOV-DATE
           DISPLAY 'BRANCH CODE  : ' ACCT-BRANCH-CODE
           IF ACCT-BLOCKED
               DISPLAY 'BLOCK DATE   : ' ACCT-BLOCK-DATE
               DISPLAY 'BLOCK REASON : ' ACCT-BLOCK-REASON
           END-IF
           DISPLAY WS-SEPARATOR.

       4000-UPDATE-ACCOUNT.
           DISPLAY ' '
           DISPLAY '--- UPDATE ACCOUNT --------------------------'
           DISPLAY 'ACCOUNT NUMBER: ' WITH NO ADVANCING
           ACCEPT  WS-INPUT-ACCT-NBR
           MOVE WS-INPUT-ACCT-NBR TO ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           EVALUATE WS-ACCT-FILE-STATUS
             WHEN '00'
               PERFORM 3100-DISPLAY-ACCOUNT
               DISPLAY 'NEW BRANCH CODE (ENTER TO KEEP): '
                       WITH NO ADVANCING
               ACCEPT  WS-WORK-CHAR
               IF WS-WORK-CHAR NOT = SPACES
                   MOVE WS-WORK-CHAR(1:4) TO ACCT-BRANCH-CODE
               END-IF
               CALL 'DATEVAL' USING WS-CURRENT-DATE
               MOVE WS-CURRENT-DATE TO ACCT-LAST-MOV-DATE
               REWRITE ACCOUNT-FILE-RECORD FROM ACCOUNT-RECORD
               IF WS-ACCT-FILE-STATUS = '00'
                   DISPLAY MSG-OPERATION-OK
               ELSE
                   DISPLAY 'REWRITE ERROR FS=' WS-ACCT-FILE-STATUS
                   CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                         WS-ACCT-FILE-STATUS
                                         ACCT-NBR
               END-IF
             WHEN '23'
               DISPLAY MSG-NOT-FOUND
             WHEN OTHER
               DISPLAY 'READ ERROR - FS=' WS-ACCT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     ACCT-NBR
           END-EVALUATE.

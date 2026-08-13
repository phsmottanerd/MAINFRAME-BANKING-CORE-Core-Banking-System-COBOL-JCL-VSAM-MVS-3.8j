      *================================================================*
      * PROGRAM: CUSTMGMT                                             *
      * PURPOSE: CUSTOMER MANAGEMENT - ADD / QUERY / UPDATE          *
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTMGMT.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE
               ASSIGN TO CUSTMST
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS DYNAMIC
               RECORD KEY   IS CUST-ID
               FILE STATUS  IS WS-CUST-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  CUSTOMER-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 159 CHARACTERS.
       01  CUSTOMER-FILE-RECORD     PIC X(159).

       WORKING-STORAGE SECTION.
       COPY WRKSTORE.
       COPY FILESTCD.
       COPY MSGLIB.
       COPY CUSTLAYO.

       01  WS-INPUT-CUST-ID         PIC X(08).
       01  WS-SUBMENU-OPT           PIC X(01).
       01  WS-SEPARATOR             PIC X(79) VALUE ALL '-'.

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'CUSTMGMT' TO WS-PROGRAM-NAME
           OPEN I-O CUSTOMER-FILE
           IF WS-CUST-FILE-STATUS = '35'
               OPEN OUTPUT CUSTOMER-FILE
               CLOSE CUSTOMER-FILE
               OPEN I-O CUSTOMER-FILE
           END-IF
           IF WS-CUST-FILE-STATUS NOT = '00'
               DISPLAY 'CUSTMGMT: OPEN ERROR - FS='
                        WS-CUST-FILE-STATUS
               STOP RUN
           END-IF
           PERFORM 1000-MENU
               UNTIL WS-SUBMENU-OPT = 'X' OR 'x'
           CLOSE CUSTOMER-FILE
           GOBACK.

       1000-MENU.
           DISPLAY ' '
           DISPLAY '=== CUSTOMER MANAGEMENT ====================='
           DISPLAY '  A - ADD NEW CUSTOMER                       '
           DISPLAY '  Q - QUERY CUSTOMER                         '
           DISPLAY '  U - UPDATE CUSTOMER                        '
           DISPLAY '  X - RETURN TO MAIN MENU                    '
           DISPLAY '============================================='
           DISPLAY 'OPTION: ' WITH NO ADVANCING
           ACCEPT  WS-SUBMENU-OPT
           EVALUATE WS-SUBMENU-OPT
             WHEN 'A' WHEN 'a'  PERFORM 2000-ADD-CUSTOMER
             WHEN 'Q' WHEN 'q'  PERFORM 3000-QUERY-CUSTOMER
             WHEN 'U' WHEN 'u'  PERFORM 4000-UPDATE-CUSTOMER
             WHEN 'X' WHEN 'x'  CONTINUE
             WHEN OTHER
               DISPLAY MSG-INVALID-OPT
           END-EVALUATE.

       2000-ADD-CUSTOMER.
           MOVE SPACES TO CUSTOMER-RECORD
           DISPLAY ' '
           DISPLAY '--- ADD CUSTOMER ----------------------------'
           DISPLAY 'CUSTOMER ID (8 chars): ' WITH NO ADVANCING
           ACCEPT  CUST-ID
           IF CUST-ID = SPACES
               DISPLAY 'CUSTOMER ID CANNOT BE BLANK'
               GO TO 2000-ADD-CUSTOMER-EXIT
           END-IF
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           IF WS-CUST-FILE-STATUS = '00'
               DISPLAY MSG-DUP-KEY
               GO TO 2000-ADD-CUSTOMER-EXIT
           END-IF
           IF WS-CUST-FILE-STATUS NOT = '23'
               DISPLAY 'READ ERROR - FS=' WS-CUST-FILE-STATUS
               GO TO 2000-ADD-CUSTOMER-EXIT
           END-IF
           DISPLAY 'FULL NAME (30 chars): ' WITH NO ADVANCING
           ACCEPT  CUST-NAME
           DISPLAY 'TAX ID / CPF (11 chars): ' WITH NO ADVANCING
           ACCEPT  CUST-TAX-ID
           DISPLAY 'BIRTH DATE (YYYYMMDD): ' WITH NO ADVANCING
           ACCEPT  CUST-BIRTH-DATE
           DISPLAY 'STREET (30 chars): ' WITH NO ADVANCING
           ACCEPT  CUST-STREET
           DISPLAY 'CITY (20 chars): ' WITH NO ADVANCING
           ACCEPT  CUST-CITY
           DISPLAY 'STATE (2 chars): ' WITH NO ADVANCING
           ACCEPT  CUST-STATE
           DISPLAY 'ZIP (8 chars): ' WITH NO ADVANCING
           ACCEPT  CUST-ZIP
           DISPLAY 'PHONE (15 chars): ' WITH NO ADVANCING
           ACCEPT  CUST-PHONE
           CALL 'DATEVAL' USING WS-CURRENT-DATE
           MOVE WS-CURRENT-DATE TO CUST-OPEN-DATE
           MOVE WS-CURRENT-DATE TO CUST-LAST-UPD-DATE
           MOVE 'A' TO CUST-STATUS
           WRITE CUSTOMER-FILE-RECORD FROM CUSTOMER-RECORD
           IF WS-CUST-FILE-STATUS = '00'
               DISPLAY MSG-OPERATION-OK
               ADD 1 TO WS-RECORDS-WRITTEN
           ELSE
               DISPLAY 'WRITE ERROR - FS=' WS-CUST-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-CUST-FILE-STATUS
                                     CUST-ID
           END-IF
       2000-ADD-CUSTOMER-EXIT.
           CONTINUE.

       3000-QUERY-CUSTOMER.
           DISPLAY ' '
           DISPLAY '--- QUERY CUSTOMER --------------------------'
           DISPLAY 'CUSTOMER ID: ' WITH NO ADVANCING
           ACCEPT  WS-INPUT-CUST-ID
           MOVE WS-INPUT-CUST-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           EVALUATE WS-CUST-FILE-STATUS
             WHEN '00'
               PERFORM 3100-DISPLAY-CUSTOMER
             WHEN '23'
               DISPLAY MSG-NOT-FOUND
             WHEN OTHER
               DISPLAY 'READ ERROR - FS=' WS-CUST-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-CUST-FILE-STATUS
                                     CUST-ID
           END-EVALUATE.

       3100-DISPLAY-CUSTOMER.
           DISPLAY WS-SEPARATOR
           DISPLAY 'CUSTOMER ID  : ' CUST-ID
           DISPLAY 'NAME         : ' CUST-NAME
           DISPLAY 'TAX ID       : ' CUST-TAX-ID
           DISPLAY 'BIRTH DATE   : ' CUST-BIRTH-DATE
           DISPLAY 'STREET       : ' CUST-STREET
           DISPLAY 'CITY/STATE   : ' CUST-CITY '/' CUST-STATE
           DISPLAY 'ZIP          : ' CUST-ZIP
           DISPLAY 'PHONE        : ' CUST-PHONE
           DISPLAY 'STATUS       : ' CUST-STATUS
           DISPLAY 'OPEN DATE    : ' CUST-OPEN-DATE
           DISPLAY 'LAST UPDATE  : ' CUST-LAST-UPD-DATE
           DISPLAY WS-SEPARATOR.

       4000-UPDATE-CUSTOMER.
           DISPLAY ' '
           DISPLAY '--- UPDATE CUSTOMER -------------------------'
           DISPLAY 'CUSTOMER ID TO UPDATE: ' WITH NO ADVANCING
           ACCEPT  WS-INPUT-CUST-ID
           MOVE WS-INPUT-CUST-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           EVALUATE WS-CUST-FILE-STATUS
             WHEN '00'
               PERFORM 3100-DISPLAY-CUSTOMER
               PERFORM 4100-INPUT-UPDATES
               PERFORM 4200-DO-REWRITE
             WHEN '23'
               DISPLAY MSG-NOT-FOUND
             WHEN OTHER
               DISPLAY 'READ ERROR - FS=' WS-CUST-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-CUST-FILE-STATUS
                                     CUST-ID
           END-EVALUATE.

       4100-INPUT-UPDATES.
           DISPLAY 'NEW NAME (ENTER TO KEEP): ' WITH NO ADVANCING
           ACCEPT  WS-WORK-CHAR
           IF WS-WORK-CHAR NOT = SPACES
               MOVE WS-WORK-CHAR(1:30)  TO CUST-NAME
           END-IF
           DISPLAY 'NEW PHONE (ENTER TO KEEP): ' WITH NO ADVANCING
           ACCEPT  WS-WORK-CHAR
           IF WS-WORK-CHAR NOT = SPACES
               MOVE WS-WORK-CHAR(1:15) TO CUST-PHONE
           END-IF
           CALL 'DATEVAL' USING WS-CURRENT-DATE
           MOVE WS-CURRENT-DATE TO CUST-LAST-UPD-DATE.

       4200-DO-REWRITE.
           REWRITE CUSTOMER-FILE-RECORD FROM CUSTOMER-RECORD
           IF WS-CUST-FILE-STATUS = '00'
               DISPLAY MSG-OPERATION-OK
               ADD 1 TO WS-RECORDS-UPDATED
           ELSE
               DISPLAY 'REWRITE ERROR - FS=' WS-CUST-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-CUST-FILE-STATUS
                                     CUST-ID
           END-IF.

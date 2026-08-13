      *================================================================*
      * PROGRAM: BATCHPROC                                            *
      * PURPOSE: DAILY BATCH TRANSACTION PROCESSOR                   *
      * READS DAILY.TRANS, VALIDATES, APPLIES TO ACCOUNT VSAM,       *
      * WRITES PROCESSED/REJECTED, DRIVES RPTGEN                     *
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCHPROC.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *--- INPUT BATCH FILE (PHYSICAL SEQUENTIAL) --------------------
           SELECT DAILY-TRANS-FILE
               ASSIGN TO DAILYTRS
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE  IS SEQUENTIAL
               FILE STATUS  IS WS-INPUT-FILE-STATUS.
      *--- OUTPUT: APPROVED -------------------------------------------
           SELECT PROCESSED-FILE
               ASSIGN TO PROCFILE
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE  IS SEQUENTIAL
               FILE STATUS  IS WS-OUTPUT-FILE-STATUS.
      *--- OUTPUT: REJECTED -------------------------------------------
           SELECT REJECTED-FILE
               ASSIGN TO REJECTFL
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE  IS SEQUENTIAL
               FILE STATUS  IS WS-REPORT-FILE-STATUS.
      *--- VSAM: ACCOUNT MASTER ---------------------------------------
           SELECT ACCOUNT-FILE
               ASSIGN TO ACCTMST
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS RANDOM
               RECORD KEY   IS ACCT-NBR
               FILE STATUS  IS WS-ACCT-FILE-STATUS.
      *--- VSAM: TRANSACTION HISTORY ----------------------------------
           SELECT TRAN-HIST-FILE
               ASSIGN TO TRANHIST
               ORGANIZATION IS INDEXED
               ACCESS MODE  IS RANDOM
               RECORD KEY   IS TRAN-KEY
               FILE STATUS  IS WS-TRAN-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  DAILY-TRANS-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 80 CHARACTERS.
       01  DAILY-TRANS-RECORD       PIC X(80).

       FD  PROCESSED-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 120 CHARACTERS.
       01  PROCESSED-RECORD         PIC X(120).

       FD  REJECTED-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 120 CHARACTERS.
       01  REJECTED-RECORD          PIC X(120).

       FD  ACCOUNT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 110 CHARACTERS.
       01  ACCOUNT-FILE-RECORD      PIC X(110).

       FD  TRAN-HIST-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 150 CHARACTERS.
       01  TRAN-HIST-RECORD         PIC X(150).

       WORKING-STORAGE SECTION.
       COPY WRKSTORE.
       COPY FILESTCD.
       COPY MSGLIB.
       COPY ACCTLAYO.
       COPY TRANLAYO.

      *--- INPUT TRANSACTION LAYOUT (80-BYTE FLAT RECORD) -----------*
       01  WS-INPUT-TRAN.
           05  INP-TRAN-TYPE        PIC X(02).
           05  INP-ACCT-NBR         PIC X(10).
           05  INP-AMOUNT           PIC 9(13)V99.
           05  INP-TARGET-ACCT      PIC X(10).
           05  INP-OPERATOR         PIC X(08).
           05  INP-DATE             PIC 9(08).
           05  INP-FILLER           PIC X(13).

      *--- OUTPUT RECORD (PROCESSED / REJECTED 120-BYTE) -----------*
       01  WS-OUTPUT-REC.
           05  OUT-TRAN-TYPE        PIC X(02).
           05  OUT-ACCT-NBR         PIC X(10).
           05  OUT-AMOUNT           PIC 9(13)V99.
           05  OUT-TARGET-ACCT      PIC X(10).
           05  OUT-STATUS           PIC X(01).
           05  OUT-REJECT-CODE      PIC X(04).
           05  OUT-REJECT-DESC      PIC X(40).
           05  OUT-DATE             PIC 9(08).
           05  OUT-OPERATOR         PIC X(08).
           05  OUT-FILLER           PIC X(08).

      *--- BATCH TOTALS -----------------------------------------------
       01  WS-BATCH-TOTALS.
           05  WS-CT-READ           PIC S9(09) COMP-3 VALUE 0.
           05  WS-CT-PROCESSED      PIC S9(09) COMP-3 VALUE 0.
           05  WS-CT-APPROVED       PIC S9(09) COMP-3 VALUE 0.
           05  WS-CT-REJECTED       PIC S9(09) COMP-3 VALUE 0.
           05  WS-AMT-PROCESSED     PIC S9(15)V99 COMP-3 VALUE 0.
           05  WS-AMT-REJECTED      PIC S9(15)V99 COMP-3 VALUE 0.

       01  WS-AVAIL-BALANCE         PIC S9(13)V99 COMP-3.

      *--- TARGET ACCOUNT FOR TRANSFER --------------------------------
       01  WS-TARGET-ACCT-REC.
           05  TARG-ACCT-NBR        PIC X(10).
           05  TARG-CUST-ID         PIC X(08).
           05  TARG-ACCT-TYPE       PIC X(02).
           05  TARG-STATUS          PIC X(01).
               88  TARG-ACTIVE      VALUE 'A'.
               88  TARG-BLOCKED     VALUE 'B'.
               88  TARG-CLOSED      VALUE 'C'.
           05  TARG-BALANCE         PIC S9(13)V99  COMP-3.
           05  TARG-OVERDRAFT       PIC S9(13)V99  COMP-3.
           05  TARG-OPEN-DATE       PIC 9(08).
           05  TARG-LAST-MOV        PIC 9(08).
           05  TARG-BLOCK-DATE      PIC 9(08).
           05  TARG-BLOCK-REASON    PIC X(30).
           05  TARG-BRANCH          PIC X(04).
           05  TARG-FILLER          PIC X(05).

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'BATCHPRC' TO WS-PROGRAM-NAME
           CALL 'DATEVAL' USING WS-CURRENT-DATE
           PERFORM 0100-OPEN-FILES
           IF WS-ERROR-FLAG = 'Y'
               MOVE 16 TO WS-RETURN-CODE
               STOP RUN
           END-IF
           PERFORM 1000-PROCESS-LOOP
               UNTIL WS-EOF = 'Y'
           PERFORM 9000-CLOSE-FILES
           DISPLAY '*** BATCHPROC COMPLETE ***'
           DISPLAY 'RECORDS READ    : ' WS-CT-READ
           DISPLAY 'RECORDS PROC    : ' WS-CT-PROCESSED
           DISPLAY 'RECORDS APPROVED: ' WS-CT-APPROVED
           DISPLAY 'RECORDS REJECTED: ' WS-CT-REJECTED
           DISPLAY 'AMOUNT PROCESSED: ' WS-AMT-PROCESSED
           DISPLAY 'AMOUNT REJECTED : ' WS-AMT-REJECTED
           STOP RUN.

       0100-OPEN-FILES.
           MOVE 'N' TO WS-ERROR-FLAG
           OPEN INPUT DAILY-TRANS-FILE
           IF WS-INPUT-FILE-STATUS NOT = '00'
               DISPLAY 'OPEN ERR DAILY-TRANS FS=' WS-INPUT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-INPUT-FILE-STATUS
                                     'DAILYTRS'
               MOVE 'Y' TO WS-ERROR-FLAG
               GO TO 0100-OPEN-EXIT
           END-IF
           OPEN OUTPUT PROCESSED-FILE
           IF WS-OUTPUT-FILE-STATUS NOT = '00'
               DISPLAY 'OPEN ERR PROCFILE FS=' WS-OUTPUT-FILE-STATUS
               MOVE 'Y' TO WS-ERROR-FLAG
               GO TO 0100-OPEN-EXIT
           END-IF
           OPEN OUTPUT REJECTED-FILE
           IF WS-REPORT-FILE-STATUS NOT = '00'
               DISPLAY 'OPEN ERR REJECTFL FS=' WS-REPORT-FILE-STATUS
               MOVE 'Y' TO WS-ERROR-FLAG
               GO TO 0100-OPEN-EXIT
           END-IF
           OPEN I-O ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS NOT = '00'
               DISPLAY 'OPEN ERR ACCTMST FS=' WS-ACCT-FILE-STATUS
               MOVE 'Y' TO WS-ERROR-FLAG
               GO TO 0100-OPEN-EXIT
           END-IF
           OPEN I-O TRAN-HIST-FILE
           IF WS-TRAN-FILE-STATUS = '35'
               OPEN OUTPUT TRAN-HIST-FILE
               CLOSE TRAN-HIST-FILE
               OPEN I-O TRAN-HIST-FILE
           END-IF
           IF WS-TRAN-FILE-STATUS NOT = '00'
               DISPLAY 'OPEN ERR TRANHIST FS=' WS-TRAN-FILE-STATUS
               MOVE 'Y' TO WS-ERROR-FLAG
           END-IF
       0100-OPEN-EXIT.
           CONTINUE.

       1000-PROCESS-LOOP.
           PERFORM 1100-READ-DAILY
           IF WS-EOF = 'Y'
               GO TO 1000-LOOP-EXIT
           END-IF
           ADD 1 TO WS-CT-READ
           PERFORM 1200-VALIDATE-RECORD
           IF WS-ERROR-FLAG = 'Y'
               PERFORM 9200-WRITE-REJECTED
               ADD 1 TO WS-CT-REJECTED
               ADD INP-AMOUNT TO WS-AMT-REJECTED
           ELSE
               PERFORM 1300-APPLY-TRANSACTION
           END-IF
       1000-LOOP-EXIT.
           CONTINUE.

       1100-READ-DAILY.
           READ DAILY-TRANS-FILE INTO WS-INPUT-TRAN
           EVALUATE WS-INPUT-FILE-STATUS
             WHEN '10'
               MOVE 'Y' TO WS-EOF-FLAG
             WHEN '00'
               CONTINUE
             WHEN OTHER
               DISPLAY 'READ ERR DAILY FS=' WS-INPUT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-INPUT-FILE-STATUS
                                     'DAILYTRS'
               MOVE 'Y' TO WS-EOF-FLAG
           END-EVALUATE.

       1200-VALIDATE-RECORD.
           MOVE 'N' TO WS-ERROR-FLAG
           MOVE SPACES TO OUT-REJECT-CODE
           MOVE SPACES TO OUT-REJECT-DESC
      *--- Validate transaction type
           EVALUATE INP-TRAN-TYPE
             WHEN 'DP'  WHEN 'WD'  WHEN 'TR'
               CONTINUE
             WHEN OTHER
               MOVE 'Y'           TO WS-ERROR-FLAG
               MOVE RC-INVALID-TYPE TO OUT-REJECT-CODE
               MOVE 'INVALID TRAN TYPE'
                                  TO OUT-REJECT-DESC
               GO TO 1200-VALID-EXIT
           END-EVALUATE
      *--- Validate amount
           IF INP-AMOUNT <= 0
               MOVE 'Y'           TO WS-ERROR-FLAG
               MOVE RC-NEG-AMOUNT TO OUT-REJECT-CODE
               MOVE 'AMOUNT ZERO OR NEGATIVE'
                                  TO OUT-REJECT-DESC
               GO TO 1200-VALID-EXIT
           END-IF
      *--- Validate account exists
           MOVE INP-ACCT-NBR      TO ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           EVALUATE WS-ACCT-FILE-STATUS
             WHEN '23'
               MOVE 'Y'              TO WS-ERROR-FLAG
               MOVE RC-ACCT-NOTFOUND TO OUT-REJECT-CODE
               MOVE 'ACCOUNT NOT FOUND'
                                     TO OUT-REJECT-DESC
               GO TO 1200-VALID-EXIT
             WHEN '00'
               CONTINUE
             WHEN OTHER
               MOVE 'Y'          TO WS-ERROR-FLAG
               MOVE RC-IO-ERROR  TO OUT-REJECT-CODE
               MOVE 'I/O ERROR READING ACCOUNT'
                                 TO OUT-REJECT-DESC
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     INP-ACCT-NBR
               GO TO 1200-VALID-EXIT
           END-EVALUATE
      *--- Validate account status
           IF ACCT-BLOCKED
               MOVE 'Y'            TO WS-ERROR-FLAG
               MOVE RC-ACCT-BLOCKED TO OUT-REJECT-CODE
               MOVE 'ACCOUNT IS BLOCKED'
                                   TO OUT-REJECT-DESC
               GO TO 1200-VALID-EXIT
           END-IF
           IF ACCT-CLOSED
               MOVE 'Y'            TO WS-ERROR-FLAG
               MOVE RC-ACCT-CLOSED TO OUT-REJECT-CODE
               MOVE 'ACCOUNT IS CLOSED'
                                   TO OUT-REJECT-DESC
               GO TO 1200-VALID-EXIT
           END-IF
      *--- For withdrawals: check balance
           IF INP-TRAN-TYPE = 'WD'
               COMPUTE WS-AVAIL-BALANCE = ACCT-BALANCE
                                        + ACCT-OVERDRAFT-LIM
               IF INP-AMOUNT > WS-AVAIL-BALANCE
                   MOVE 'Y'              TO WS-ERROR-FLAG
                   MOVE RC-INSUF-FUNDS   TO OUT-REJECT-CODE
                   MOVE 'INSUFFICIENT FUNDS'
                                         TO OUT-REJECT-DESC
                   GO TO 1200-VALID-EXIT
               END-IF
           END-IF
      *--- For transfers: validate target account
           IF INP-TRAN-TYPE = 'TR'
               MOVE INP-TARGET-ACCT TO ACCT-NBR
               READ ACCOUNT-FILE INTO WS-TARGET-ACCT-REC
                   KEY IS ACCT-NBR
               EVALUATE WS-ACCT-FILE-STATUS
                 WHEN '23'
                   MOVE 'Y'                TO WS-ERROR-FLAG
                   MOVE RC-TARGET-NOTFOUND TO OUT-REJECT-CODE
                   MOVE 'TARGET ACCT NOT FOUND'
                                           TO OUT-REJECT-DESC
                   GO TO 1200-VALID-EXIT
                 WHEN '00'
                   CONTINUE
                 WHEN OTHER
                   MOVE 'Y'         TO WS-ERROR-FLAG
                   MOVE RC-IO-ERROR TO OUT-REJECT-CODE
                   MOVE 'I/O ERR READING TARGET'
                                    TO OUT-REJECT-DESC
                   GO TO 1200-VALID-EXIT
               END-EVALUATE
               IF TARG-BLOCKED
                   MOVE 'Y'              TO WS-ERROR-FLAG
                   MOVE RC-ACCT-BLOCKED  TO OUT-REJECT-CODE
                   MOVE 'TARGET ACCOUNT BLOCKED'
                                         TO OUT-REJECT-DESC
                   GO TO 1200-VALID-EXIT
               END-IF
               IF TARG-CLOSED
                   MOVE 'Y'              TO WS-ERROR-FLAG
                   MOVE RC-ACCT-CLOSED   TO OUT-REJECT-CODE
                   MOVE 'TARGET ACCOUNT CLOSED'
                                         TO OUT-REJECT-DESC
                   GO TO 1200-VALID-EXIT
               END-IF
               MOVE INP-ACCT-NBR  TO ACCT-NBR
               READ ACCOUNT-FILE INTO ACCOUNT-RECORD
                   KEY IS ACCT-NBR
               COMPUTE WS-AVAIL-BALANCE = ACCT-BALANCE
                                        + ACCT-OVERDRAFT-LIM
               IF INP-AMOUNT > WS-AVAIL-BALANCE
                   MOVE 'Y'            TO WS-ERROR-FLAG
                   MOVE RC-INSUF-FUNDS TO OUT-REJECT-CODE
                   MOVE 'INSUF FUNDS FOR TRANSFER'
                                       TO OUT-REJECT-DESC
               END-IF
           END-IF
       1200-VALID-EXIT.
           CONTINUE.

       1300-APPLY-TRANSACTION.
           ADD 1 TO WS-CT-PROCESSED
           MOVE INP-ACCT-NBR TO ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           EVALUATE INP-TRAN-TYPE
             WHEN 'DP'
               ADD INP-AMOUNT TO ACCT-BALANCE
               PERFORM 1310-UPDATE-ACCOUNT
               PERFORM 1400-WRITE-HISTORY
             WHEN 'WD'
               SUBTRACT INP-AMOUNT FROM ACCT-BALANCE
               PERFORM 1310-UPDATE-ACCOUNT
               PERFORM 1400-WRITE-HISTORY
             WHEN 'TR'
               SUBTRACT INP-AMOUNT FROM ACCT-BALANCE
               PERFORM 1310-UPDATE-ACCOUNT
               PERFORM 1400-WRITE-HISTORY
               PERFORM 1320-CREDIT-TARGET
           END-EVALUATE
           ADD INP-AMOUNT TO WS-AMT-PROCESSED
           ADD 1 TO WS-CT-APPROVED
           PERFORM 9100-WRITE-PROCESSED.

       1310-UPDATE-ACCOUNT.
           MOVE WS-CURRENT-DATE TO ACCT-LAST-MOV-DATE
           REWRITE ACCOUNT-FILE-RECORD FROM ACCOUNT-RECORD
           IF WS-ACCT-FILE-STATUS NOT = '00'
               DISPLAY 'REWRITE ERR ACCT FS=' WS-ACCT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     ACCT-NBR
           END-IF.

       1320-CREDIT-TARGET.
           MOVE INP-TARGET-ACCT TO ACCT-NBR
           READ ACCOUNT-FILE INTO ACCOUNT-RECORD
               KEY IS ACCT-NBR
           ADD INP-AMOUNT TO ACCT-BALANCE
           MOVE WS-CURRENT-DATE TO ACCT-LAST-MOV-DATE
           REWRITE ACCOUNT-FILE-RECORD FROM ACCOUNT-RECORD
           IF WS-ACCT-FILE-STATUS NOT = '00'
               DISPLAY 'REWRITE ERR TGT FS=' WS-ACCT-FILE-STATUS
               CALL 'ERRHANDL' USING WS-PROGRAM-NAME
                                     WS-ACCT-FILE-STATUS
                                     INP-TARGET-ACCT
           END-IF.

       1400-WRITE-HISTORY.
           MOVE SPACES           TO TRANSACTION-RECORD
           MOVE INP-ACCT-NBR     TO TRAN-ACCT-NBR
           MOVE WS-CURRENT-DATE  TO TRAN-DATE
           ADD 1 TO WS-TRAN-SEQ-CTR
           MOVE WS-TRAN-SEQ-CTR  TO TRAN-SEQ
           MOVE INP-TRAN-TYPE    TO TRAN-TYPE
           MOVE INP-AMOUNT       TO TRAN-AMOUNT
           MOVE 'A'              TO TRAN-STATUS
           MOVE ACCT-BALANCE     TO TRAN-BALANCE-AFTER
           MOVE INP-OPERATOR     TO TRAN-OPERATOR
           MOVE INP-TARGET-ACCT  TO TRAN-TARGET-ACCT
           MOVE 'BAT'            TO TRAN-CHANNEL
           WRITE TRAN-HIST-RECORD FROM TRANSACTION-RECORD
           IF WS-TRAN-FILE-STATUS = '22'
               ADD 1 TO WS-TRAN-SEQ-CTR
               MOVE WS-TRAN-SEQ-CTR TO TRAN-SEQ
               WRITE TRAN-HIST-RECORD FROM TRANSACTION-RECORD
           END-IF
           IF WS-TRAN-FILE-STATUS NOT = '00'
               DISPLAY 'TRAN HIST WRITE ERR FS=' WS-TRAN-FILE-STATUS
           END-IF.

       9000-CLOSE-FILES.
           CLOSE DAILY-TRANS-FILE
           CLOSE PROCESSED-FILE
           CLOSE REJECTED-FILE
           CLOSE ACCOUNT-FILE
           CLOSE TRAN-HIST-FILE.

       9100-WRITE-PROCESSED.
           MOVE INP-TRAN-TYPE    TO OUT-TRAN-TYPE
           MOVE INP-ACCT-NBR     TO OUT-ACCT-NBR
           MOVE INP-AMOUNT       TO OUT-AMOUNT
           MOVE INP-TARGET-ACCT  TO OUT-TARGET-ACCT
           MOVE 'A'              TO OUT-STATUS
           MOVE SPACES           TO OUT-REJECT-CODE
           MOVE SPACES           TO OUT-REJECT-DESC
           MOVE INP-DATE         TO OUT-DATE
           MOVE INP-OPERATOR     TO OUT-OPERATOR
           WRITE PROCESSED-RECORD FROM WS-OUTPUT-REC
           IF WS-OUTPUT-FILE-STATUS NOT = '00'
               DISPLAY 'WRITE ERR PROCFILE FS=' WS-OUTPUT-FILE-STATUS
           END-IF.

       9200-WRITE-REJECTED.
           MOVE INP-TRAN-TYPE    TO OUT-TRAN-TYPE
           MOVE INP-ACCT-NBR     TO OUT-ACCT-NBR
           MOVE INP-AMOUNT       TO OUT-AMOUNT
           MOVE INP-TARGET-ACCT  TO OUT-TARGET-ACCT
           MOVE 'R'              TO OUT-STATUS
           MOVE INP-DATE         TO OUT-DATE
           MOVE INP-OPERATOR     TO OUT-OPERATOR
           WRITE REJECTED-RECORD FROM WS-OUTPUT-REC
           IF WS-REPORT-FILE-STATUS NOT = '00'
               DISPLAY 'WRITE ERR REJECTFL FS=' WS-REPORT-FILE-STATUS
           END-IF.

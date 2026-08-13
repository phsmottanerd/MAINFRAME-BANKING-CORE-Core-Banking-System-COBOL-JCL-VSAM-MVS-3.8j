      *================================================================*
      * PROGRAM: RPTGEN                                               *
      * PURPOSE: DAILY REPORT GENERATOR FROM PROCESSED/REJECTED FILES*
      * AUTHOR:  MAINFRAME-BANKING-CORE                               *
      * DATE:    2025                                                  *
      * ENVIRONMENT: OS/VS COBOL - MVS 3.8J TK4-                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTGEN.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PROCESSED-FILE
               ASSIGN TO PROCFILE
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE  IS SEQUENTIAL
               FILE STATUS  IS WS-INPUT-FILE-STATUS.
           SELECT REJECTED-FILE
               ASSIGN TO REJECTFL
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE  IS SEQUENTIAL
               FILE STATUS  IS WS-OUTPUT-FILE-STATUS.
           SELECT REPORT-FILE
               ASSIGN TO RPTFILE
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE  IS SEQUENTIAL
               FILE STATUS  IS WS-REPORT-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  PROCESSED-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 120 CHARACTERS.
       01  PROCESSED-RECORD         PIC X(120).

       FD  REJECTED-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 120 CHARACTERS.
       01  REJECTED-RECORD          PIC X(120).

       FD  REPORT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 133 CHARACTERS.
       01  REPORT-LINE              PIC X(133).

       WORKING-STORAGE SECTION.
       COPY WRKSTORE.
       COPY FILESTCD.

      *--- INPUT LAYOUT (matches 9100/9200 output in BATCHPROC) -----*
       01  WS-TRAN-REC.
           05  IN-TYPE              PIC X(02).
           05  IN-ACCT              PIC X(10).
           05  IN-AMOUNT            PIC 9(13)V99.
           05  IN-TARGET            PIC X(10).
           05  IN-STATUS            PIC X(01).
           05  IN-REJECT-CODE       PIC X(04).
           05  IN-REJECT-DESC       PIC X(40).
           05  IN-DATE              PIC 9(08).
           05  IN-OPERATOR          PIC X(08).
           05  IN-FILLER            PIC X(08).

      *--- REPORT COUNTERS -------------------------------------------*
       01  WS-RPT-COUNTERS.
           05  WS-CT-APPROVED       PIC S9(09) COMP-3 VALUE 0.
           05  WS-CT-REJECTED       PIC S9(09) COMP-3 VALUE 0.
           05  WS-AMT-APPROVED      PIC S9(15)V99 COMP-3 VALUE 0.
           05  WS-AMT-REJECTED      PIC S9(15)V99 COMP-3 VALUE 0.
           05  WS-CT-DP             PIC S9(09) COMP-3 VALUE 0.
           05  WS-CT-WD             PIC S9(09) COMP-3 VALUE 0.
           05  WS-CT-TR             PIC S9(09) COMP-3 VALUE 0.

      *--- PRINT EDIT FIELDS -----------------------------------------*
       01  WS-LINE-BUFFER           PIC X(133).
       01  WS-AMT-DISP              PIC ZZZ,ZZZ,ZZZ,ZZ9.99-.
       01  WS-CNT-DISP              PIC ZZ,ZZ9.
       01  WS-SEPARATOR             PIC X(79) VALUE ALL '-'.

       PROCEDURE DIVISION.

       0000-MAIN.
           MOVE 'RPTGEN  ' TO WS-PROGRAM-NAME
           CALL 'DATEVAL' USING WS-CURRENT-DATE
           OPEN INPUT  PROCESSED-FILE
           IF WS-INPUT-FILE-STATUS NOT = '00'
               DISPLAY 'RPTGEN: OPEN ERR PROCFILE FS='
                        WS-INPUT-FILE-STATUS
               STOP RUN
           END-IF
           OPEN INPUT  REJECTED-FILE
           IF WS-OUTPUT-FILE-STATUS NOT = '00'
               DISPLAY 'RPTGEN: OPEN ERR REJECTFL FS='
                        WS-OUTPUT-FILE-STATUS
               STOP RUN
           END-IF
           OPEN OUTPUT REPORT-FILE
           IF WS-REPORT-FILE-STATUS NOT = '00'
               DISPLAY 'RPTGEN: OPEN ERR RPTFILE FS='
                        WS-REPORT-FILE-STATUS
               STOP RUN
           END-IF
           PERFORM 1000-WRITE-HEADER
           PERFORM 2000-PROCESS-APPROVED
               UNTIL WS-EOF = 'Y'
           MOVE 'N' TO WS-EOF-FLAG
           PERFORM 3000-PROCESS-REJECTED
               UNTIL WS-EOF = 'Y'
           PERFORM 9000-WRITE-TOTALS
           CLOSE PROCESSED-FILE
           CLOSE REJECTED-FILE
           CLOSE REPORT-FILE
           GOBACK.

       1000-WRITE-HEADER.
           MOVE SPACES TO REPORT-LINE
           WRITE REPORT-LINE
           STRING
               '  MAINFRAME BANKING CORE - DAILY PROCESSING REPORT'
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           STRING '  DATE: ' WS-CURRENT-DATE
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE ALL '=' TO REPORT-LINE(1:79)
           WRITE REPORT-LINE
           STRING
               '  TYP  ACCOUNT     AMOUNT              STATUS  '
               'CODE  DESCRIPTION                     DATE    '
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE ALL '-' TO REPORT-LINE(1:79)
           WRITE REPORT-LINE.

       2000-PROCESS-APPROVED.
           READ PROCESSED-FILE INTO WS-TRAN-REC
           EVALUATE WS-INPUT-FILE-STATUS
             WHEN '10'  MOVE 'Y' TO WS-EOF-FLAG
             WHEN '00'
               ADD 1 TO WS-CT-APPROVED
               ADD IN-AMOUNT TO WS-AMT-APPROVED
               EVALUATE IN-TYPE
                 WHEN 'DP'  ADD 1 TO WS-CT-DP
                 WHEN 'WD'  ADD 1 TO WS-CT-WD
                 WHEN 'TR'  ADD 1 TO WS-CT-TR
               END-EVALUATE
               PERFORM 2100-WRITE-DETAIL-LINE
             WHEN OTHER
               DISPLAY 'READ ERR PROC FS=' WS-INPUT-FILE-STATUS
               MOVE 'Y' TO WS-EOF-FLAG
           END-EVALUATE.

       2100-WRITE-DETAIL-LINE.
           MOVE IN-AMOUNT TO WS-AMT-DISP
           STRING
               '  ' IN-TYPE '  ' IN-ACCT '  '
               WS-AMT-DISP '  ' IN-STATUS '  '
               IN-DATE
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           IF WS-REPORT-FILE-STATUS NOT = '00'
               DISPLAY 'WRITE ERR RPT FS=' WS-REPORT-FILE-STATUS
           END-IF.

       3000-PROCESS-REJECTED.
           READ REJECTED-FILE INTO WS-TRAN-REC
           EVALUATE WS-OUTPUT-FILE-STATUS
             WHEN '10'  MOVE 'Y' TO WS-EOF-FLAG
             WHEN '00'
               ADD 1 TO WS-CT-REJECTED
               ADD IN-AMOUNT TO WS-AMT-REJECTED
               PERFORM 3100-WRITE-REJECT-LINE
             WHEN OTHER
               DISPLAY 'READ ERR REJF FS=' WS-OUTPUT-FILE-STATUS
               MOVE 'Y' TO WS-EOF-FLAG
           END-EVALUATE.

       3100-WRITE-REJECT-LINE.
           MOVE IN-AMOUNT TO WS-AMT-DISP
           STRING
               '  ' IN-TYPE '  ' IN-ACCT '  '
               WS-AMT-DISP '  R  '
               IN-REJECT-CODE '  '
               IN-REJECT-DESC(1:30) '  '
               IN-DATE
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE.

       9000-WRITE-TOTALS.
           MOVE ALL '=' TO REPORT-LINE(1:79)
           WRITE REPORT-LINE
           MOVE WS-CT-APPROVED TO WS-CNT-DISP
           STRING '  APPROVED TRANSACTIONS : ' WS-CNT-DISP
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-AMT-APPROVED TO WS-AMT-DISP
           STRING '  APPROVED AMOUNT       : ' WS-AMT-DISP
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-CT-REJECTED TO WS-CNT-DISP
           STRING '  REJECTED TRANSACTIONS : ' WS-CNT-DISP
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-AMT-REJECTED TO WS-AMT-DISP
           STRING '  REJECTED AMOUNT       : ' WS-AMT-DISP
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-CT-DP TO WS-CNT-DISP
           STRING '  DEPOSITS              : ' WS-CNT-DISP
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-CT-WD TO WS-CNT-DISP
           STRING '  WITHDRAWALS           : ' WS-CNT-DISP
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-CT-TR TO WS-CNT-DISP
           STRING '  TRANSFERS             : ' WS-CNT-DISP
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE ALL '=' TO REPORT-LINE(1:79)
           WRITE REPORT-LINE.

      *================================================================*
      * WRKSTORE - COMMON WORKING-STORAGE VARIABLES                   *
      * Compatible: OS/VS COBOL - MVS 3.8j TK4-                      *
      *================================================================*

       01  WS-COMMON.
           05  WS-PROGRAM-NAME      PIC X(08).
           05  WS-RETURN-CODE       PIC S9(04) COMP.
           05  WS-ERROR-FLAG        PIC X(01).
               88  WS-NO-ERROR      VALUE 'N'.
               88  WS-ERROR-FOUND   VALUE 'Y'.
           05  WS-EOF-FLAG          PIC X(01).
               88  WS-NOT-EOF       VALUE 'N'.
               88  WS-EOF           VALUE 'Y'.
           05  WS-FOUND-FLAG        PIC X(01).
               88  WS-FOUND         VALUE 'Y'.
               88  WS-NOT-FOUND     VALUE 'N'.
           05  WS-ACTION-FLAG       PIC X(01).
               88  WS-ADD           VALUE 'A'.
               88  WS-UPDATE        VALUE 'U'.
               88  WS-DELETE        VALUE 'D'.
               88  WS-QUERY         VALUE 'Q'.

       01  WS-DATE-WORK.
           05  WS-CURRENT-DATE      PIC 9(08).
           05  WS-CURRENT-DATE-X    PIC X(08).
           05  WS-DATE-CC           PIC 9(02).
           05  WS-DATE-YY           PIC 9(02).
           05  WS-DATE-MM           PIC 9(02).
           05  WS-DATE-DD           PIC 9(02).

       01  WS-COUNTERS.
           05  WS-RECORDS-READ      PIC S9(09) COMP-3 VALUE 0.
           05  WS-RECORDS-WRITTEN   PIC S9(09) COMP-3 VALUE 0.
           05  WS-RECORDS-REJECTED  PIC S9(09) COMP-3 VALUE 0.
           05  WS-RECORDS-UPDATED   PIC S9(09) COMP-3 VALUE 0.

       01  WS-ACCUMULATORS.
           05  WS-TOTAL-AMOUNT      PIC S9(15)V99 COMP-3 VALUE 0.
           05  WS-REJECT-AMOUNT     PIC S9(15)V99 COMP-3 VALUE 0.

       01  WS-WORK-FIELDS.
           05  WS-WORK-NBR          PIC S9(13)V99 COMP-3.
           05  WS-WORK-CHAR         PIC X(80).
           05  WS-TRAN-SEQ-CTR      PIC 9(06) VALUE 0.
           05  WS-MENU-OPTION       PIC X(01).
           05  WS-CONFIRM           PIC X(01).

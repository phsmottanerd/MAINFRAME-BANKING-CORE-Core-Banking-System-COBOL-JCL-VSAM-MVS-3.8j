      *================================================================*
      * TRANLAYO - TRANSACTION RECORD LAYOUT                          *
      * Used for VSAM TRANS.HISTORY and flat batch files              *
      * Compatible: OS/VS COBOL - MVS 3.8j TK4-                      *
      *================================================================*
       01  TRANSACTION-RECORD.
           05  TRAN-KEY.
               10  TRAN-ACCT-NBR    PIC X(10).
               10  TRAN-DATE        PIC 9(08).
               10  TRAN-SEQ         PIC 9(06).
           05  TRAN-TYPE            PIC X(02).
               88  TRAN-DEPOSIT     VALUE 'DP'.
               88  TRAN-WITHDRAW    VALUE 'WD'.
               88  TRAN-TRANSFER    VALUE 'TR'.
               88  TRAN-OPENING     VALUE 'OP'.
               88  TRAN-REVERSAL    VALUE 'RV'.
           05  TRAN-AMOUNT          PIC S9(13)V99  COMP-3.
           05  TRAN-STATUS          PIC X(01).
               88  TRAN-APPROVED    VALUE 'A'.
               88  TRAN-REJECTED    VALUE 'R'.
               88  TRAN-PENDING     VALUE 'P'.
           05  TRAN-REJECT-CODE     PIC X(04).
           05  TRAN-REJECT-DESC     PIC X(30).
           05  TRAN-SOURCE-ACCT     PIC X(10).
           05  TRAN-TARGET-ACCT     PIC X(10).
           05  TRAN-BALANCE-AFTER   PIC S9(13)V99  COMP-3.
           05  TRAN-OPERATOR        PIC X(08).
           05  TRAN-CHANNEL         PIC X(03).
               88  TRAN-BATCH       VALUE 'BAT'.
               88  TRAN-TSO         VALUE 'TSO'.
           05  TRAN-FILLER          PIC X(04).

      *----------------------------------------------------------------*
      * TRAN-KEY = 24 bytes (ACCT-NBR+DATE+SEQ) = unique composite key*
      *----------------------------------------------------------------*

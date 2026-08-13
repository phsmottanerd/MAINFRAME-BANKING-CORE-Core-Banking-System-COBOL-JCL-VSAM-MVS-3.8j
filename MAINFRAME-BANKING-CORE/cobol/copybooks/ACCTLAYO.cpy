      *================================================================*
      * ACCTLAYO - ACCOUNT MASTER RECORD LAYOUT                       *
      * Compatible: OS/VS COBOL - MVS 3.8j TK4-                      *
      *================================================================*
       01  ACCOUNT-RECORD.
           05  ACCT-NBR             PIC X(10).
           05  ACCT-CUST-ID         PIC X(08).
           05  ACCT-TYPE            PIC X(02).
               88  ACCT-CHECKING    VALUE 'CH'.
               88  ACCT-SAVINGS     VALUE 'SV'.
               88  ACCT-SALARY      VALUE 'SL'.
           05  ACCT-STATUS          PIC X(01).
               88  ACCT-ACTIVE      VALUE 'A'.
               88  ACCT-BLOCKED     VALUE 'B'.
               88  ACCT-CLOSED      VALUE 'C'.
           05  ACCT-BALANCE         PIC S9(13)V99  COMP-3.
           05  ACCT-OVERDRAFT-LIM   PIC S9(13)V99  COMP-3.
           05  ACCT-OPEN-DATE       PIC 9(08).
           05  ACCT-LAST-MOV-DATE   PIC 9(08).
           05  ACCT-BLOCK-DATE      PIC 9(08).
           05  ACCT-BLOCK-REASON    PIC X(30).
           05  ACCT-BRANCH-CODE     PIC X(04).
           05  ACCT-FILLER          PIC X(05).

      *----------------------------------------------------------------*
      * KEY: ACCT-NBR (10 bytes, leftmost)                            *
      * TOTAL RECORD LENGTH ~ 110 bytes                               *
      *----------------------------------------------------------------*

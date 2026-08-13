      *================================================================*
      * FILESTCD - FILE STATUS CODES AND CONDITION NAMES              *
      * Compatible: OS/VS COBOL - MVS 3.8j TK4-                      *
      *================================================================*

      *--- FILE STATUS FIELDS ----------------------------------------*
       01  WS-CUST-FILE-STATUS       PIC X(02).
       01  WS-ACCT-FILE-STATUS       PIC X(02).
       01  WS-TRAN-FILE-STATUS       PIC X(02).
       01  WS-INPUT-FILE-STATUS      PIC X(02).
       01  WS-OUTPUT-FILE-STATUS     PIC X(02).
       01  WS-REPORT-FILE-STATUS     PIC X(02).

      *--- STANDARD FILE STATUS CONDITION NAMES ----------------------*
       01  FS-GOOD                   PIC X(02) VALUE '00'.
       01  FS-EOF                    PIC X(02) VALUE '10'.
       01  FS-NOTFOUND               PIC X(02) VALUE '23'.
       01  FS-DUPKEY                 PIC X(02) VALUE '22'.
       01  FS-NOSPACE                PIC X(02) VALUE '24'.
       01  FS-READ-ERR               PIC X(02) VALUE '30'.
       01  FS-WRITE-ERR              PIC X(02) VALUE '34'.
       01  FS-OPEN-ERR               PIC X(02) VALUE '35'.
       01  FS-NOT-OPEN               PIC X(02) VALUE '42'.
       01  FS-ALREADY-OPEN          PIC X(02) VALUE '41'.
       01  FS-SEQ-ERROR              PIC X(02) VALUE '21'.

      *--- REJECTION REASON CODES ------------------------------------*
       01  RC-INSUF-FUNDS            PIC X(04) VALUE 'E001'.
       01  RC-ACCT-BLOCKED           PIC X(04) VALUE 'E002'.
       01  RC-ACCT-NOTFOUND          PIC X(04) VALUE 'E003'.
       01  RC-CUST-NOTFOUND          PIC X(04) VALUE 'E004'.
       01  RC-NEG-AMOUNT             PIC X(04) VALUE 'E005'.
       01  RC-DUP-KEY                PIC X(04) VALUE 'E006'.
       01  RC-INVALID-TYPE           PIC X(04) VALUE 'E007'.
       01  RC-INVALID-DATE           PIC X(04) VALUE 'E008'.
       01  RC-TARGET-NOTFOUND        PIC X(04) VALUE 'E009'.
       01  RC-ACCT-CLOSED            PIC X(04) VALUE 'E010'.
       01  RC-IO-ERROR               PIC X(04) VALUE 'E099'.

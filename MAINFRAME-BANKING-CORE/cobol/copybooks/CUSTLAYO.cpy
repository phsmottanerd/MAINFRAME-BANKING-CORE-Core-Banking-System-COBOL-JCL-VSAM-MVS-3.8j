      *================================================================*
      * CUSTLAYO - CUSTOMER MASTER RECORD LAYOUT                      *
      * Compatible: OS/VS COBOL - MVS 3.8j TK4-                      *
      *================================================================*
       01  CUSTOMER-RECORD.
           05  CUST-ID              PIC X(08).
           05  CUST-NAME            PIC X(30).
           05  CUST-TAX-ID          PIC X(11).
           05  CUST-BIRTH-DATE      PIC 9(08).
           05  CUST-ADDRESS.
               10  CUST-STREET      PIC X(30).
               10  CUST-CITY        PIC X(20).
               10  CUST-STATE       PIC X(02).
               10  CUST-ZIP         PIC X(08).
           05  CUST-PHONE           PIC X(15).
           05  CUST-STATUS          PIC X(01).
               88  CUST-ACTIVE      VALUE 'A'.
               88  CUST-INACTIVE    VALUE 'I'.
               88  CUST-SUSPENDED   VALUE 'S'.
           05  CUST-OPEN-DATE       PIC 9(08).
           05  CUST-LAST-UPD-DATE   PIC 9(08).
           05  CUST-FILLER          PIC X(10).

      *----------------------------------------------------------------*
      * TOTAL RECORD LENGTH = 8+30+11+8+30+20+2+8+15+1+8+8+10 = 159  *
      *----------------------------------------------------------------*

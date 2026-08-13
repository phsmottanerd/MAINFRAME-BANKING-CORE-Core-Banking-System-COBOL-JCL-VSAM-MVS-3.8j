      *================================================================*
      * MSGLIB - STANDARD SYSTEM MESSAGES                             *
      * Compatible: OS/VS COBOL - MVS 3.8j TK4-                      *
      *================================================================*

       01  MSG-OPERATION-OK   PIC X(50)
               VALUE 'OPERATION COMPLETED SUCCESSFULLY             '.
       01  MSG-NOT-FOUND      PIC X(50)
               VALUE 'RECORD NOT FOUND                             '.
       01  MSG-DUP-KEY        PIC X(50)
               VALUE 'DUPLICATE KEY - RECORD ALREADY EXISTS       '.
       01  MSG-INSUF-FUNDS    PIC X(50)
               VALUE 'INSUFFICIENT FUNDS FOR THIS OPERATION       '.
       01  MSG-ACCT-BLOCKED   PIC X(50)
               VALUE 'ACCOUNT IS BLOCKED - OPERATION NOT ALLOWED  '.
       01  MSG-ACCT-CLOSED    PIC X(50)
               VALUE 'ACCOUNT IS CLOSED - OPERATION NOT ALLOWED   '.
       01  MSG-NEG-AMOUNT     PIC X(50)
               VALUE 'AMOUNT MUST BE GREATER THAN ZERO            '.
       01  MSG-INVALID-TYPE   PIC X(50)
               VALUE 'INVALID TRANSACTION TYPE                     '.
       01  MSG-IO-ERROR       PIC X(50)
               VALUE 'I/O ERROR - CONTACT SYSTEMS SUPPORT         '.
       01  MSG-INVALID-DATE   PIC X(50)
               VALUE 'INVALID DATE - FORMAT YYYYMMDD EXPECTED     '.
       01  MSG-CONFIRM        PIC X(50)
               VALUE 'CONFIRM OPERATION? (Y/N):                   '.
       01  MSG-PRESS-ENTER    PIC X(50)
               VALUE 'PRESS ENTER TO CONTINUE...                  '.
       01  MSG-INVALID-OPT    PIC X(50)
               VALUE 'INVALID OPTION - PLEASE TRY AGAIN           '.
       01  MSG-NO-MOVEMENT    PIC X(50)
               VALUE 'NO MOVEMENT FOUND FOR THIS ACCOUNT          '.
       01  MSG-TARGET-NFD     PIC X(50)
               VALUE 'TARGET ACCOUNT NOT FOUND                     '.
       01  MSG-ACCT-UNBLOCKED PIC X(50)
               VALUE 'ACCOUNT SUCCESSFULLY UNBLOCKED              '.
       01  MSG-ACCT-BLOCKED-OK PIC X(50)
               VALUE 'ACCOUNT SUCCESSFULLY BLOCKED                '.

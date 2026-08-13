  //BACKVSAM JOB (BANK),'BACKUP VSAM TO SEQUENTIAL',
  //         CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
  //*
  //*================================================================*
  //* JOB: BACKVSAM                                                   *
  //* PURPOSE: REPRO VSAM CLUSTERS TO SEQUENTIAL BACKUP FILES        *
  //* RUN DAILY BEFORE BATCH PROCESSING                               *
  //*================================================================*
  //STEP1    EXEC PGM=IDCAMS
  //SYSPRINT DD SYSOUT=*
  //CUSTMST  DD DSN=BANK.CUSTOMER.MASTER,DISP=SHR
  //CUSTBAK  DD DSN=BANK.BACKUP.CUSTOMERS,
  //         DISP=(NEW,CATLG),
  //         UNIT=SYSDA,
  //         SPACE=(CYL,(1,1)),
  //         DCB=(RECFM=FB,LRECL=159,BLKSIZE=1590)
  //ACCTMST  DD DSN=BANK.ACCOUNT.MASTER,DISP=SHR
  //ACCTBAK  DD DSN=BANK.BACKUP.ACCOUNTS,
  //         DISP=(NEW,CATLG),
  //         UNIT=SYSDA,
  //         SPACE=(CYL,(1,1)),
  //         DCB=(RECFM=FB,LRECL=110,BLKSIZE=1100)
  //TRANHIST DD DSN=BANK.TRANS.HISTORY,DISP=SHR
  //TRANBAK  DD DSN=BANK.BACKUP.HISTORY,
  //         DISP=(NEW,CATLG),
  //         UNIT=SYSDA,
  //         SPACE=(CYL,(2,1)),
  //         DCB=(RECFM=FB,LRECL=150,BLKSIZE=1500)
  //SYSIN    DD *
    REPRO INFILE(CUSTMST)  OUTFILE(CUSTBAK)
    REPRO INFILE(ACCTMST)  OUTFILE(ACCTBAK)
    REPRO INFILE(TRANHIST) OUTFILE(TRANBAK)
  /*

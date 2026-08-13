  //PRTREPORT JOB (BANK),'PRINT DAILY REPORT',
  //          CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
  //*
  //*================================================================*
  //* JOB: PRTREPORT                                                  *
  //* PURPOSE: PRINT DAILY.REPORT TO JES SPOOL / PRINTER             *
  //*================================================================*
  //STEP1    EXEC PGM=IEBGENER
  //SYSPRINT DD SYSOUT=*
  //SYSUT1   DD DSN=BANK.DAILY.REPORT,DISP=SHR
  //SYSUT2   DD SYSOUT=*,
  //         DCB=(RECFM=FBA,LRECL=133,BLKSIZE=1330)
  //SYSIN    DD DUMMY

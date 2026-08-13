  //DAILYBAT JOB (BANK),'DAILY BATCH PROCESSING',
  //         CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
  //         NOTIFY=&SYSUID
  //*
  //*================================================================*
  //* JOB: DAILYBAT                                                   *
  //* PURPOSE: DAILY BATCH TRANSACTION PROCESSING                    *
  //* FLOW:                                                           *
  //*   STEP1 - SORT DAILY TRANSACTIONS BY ACCT+DATE                 *
  //*   STEP2 - BATCHPROC - PROCESS TRANSACTIONS                     *
  //*   STEP3 - RPTGEN    - GENERATE DAILY REPORT                    *
  //*================================================================*
  //*
  //*--- STEP1: SORT INPUT BY ACCOUNT + DATE ------------------------*
  //STEP1    EXEC PGM=SORT,REGION=512K
  //SYSOUT   DD SYSOUT=*
  //SORTIN   DD DSN=BANK.DAILY.TRANS,DISP=SHR
  //SORTOUT  DD DSN=&&SORTED,DISP=(NEW,PASS),
  //         UNIT=SYSDA,SPACE=(TRK,(50,10))
  //SYSIN    DD *
    SORT FIELDS=(3,10,CH,A,13,8,CH,A)
  /*
  //*
  //*--- STEP2: PROCESS TRANSACTIONS --------------------------------*
  //STEP2    EXEC PGM=BATCHPROC,REGION=2048K,COND=(4,LT,STEP1)
  //STEPLIB  DD DSN=SYS1.BANKLOAD,DISP=SHR
  //DAILYTRS DD DSN=&&SORTED,DISP=(OLD,DELETE)
  //ACCTMST  DD DSN=BANK.ACCOUNT.MASTER,DISP=SHR
  //TRANHIST DD DSN=BANK.TRANS.HISTORY,DISP=SHR
  //PROCFILE DD DSN=BANK.TRANS.PROCESSED,
  //         DISP=(NEW,CATLG),
  //         UNIT=SYSDA,
  //         SPACE=(TRK,(50,20)),
  //         DCB=(RECFM=FB,LRECL=120,BLKSIZE=1200)
  //REJECTFL DD DSN=BANK.TRANS.REJECTED,
  //         DISP=(NEW,CATLG),
  //         UNIT=SYSDA,
  //         SPACE=(TRK,(20,10)),
  //         DCB=(RECFM=FB,LRECL=120,BLKSIZE=1200)
  //SYSOUT   DD SYSOUT=*
  //SYSPRINT DD SYSOUT=*
  //*
  //*--- STEP3: GENERATE REPORT -------------------------------------*
  //STEP3    EXEC PGM=RPTGEN,REGION=1024K,COND=(4,LT,STEP2)
  //STEPLIB  DD DSN=SYS1.BANKLOAD,DISP=SHR
  //PROCFILE DD DSN=BANK.TRANS.PROCESSED,DISP=SHR
  //REJECTFL DD DSN=BANK.TRANS.REJECTED,DISP=SHR
  //RPTFILE  DD DSN=BANK.DAILY.REPORT,
  //         DISP=(NEW,CATLG),
  //         UNIT=SYSDA,
  //         SPACE=(TRK,(20,10)),
  //         DCB=(RECFM=FBA,LRECL=133,BLKSIZE=1330)
  //SYSOUT   DD SYSOUT=*
  //SYSPRINT DD SYSOUT=*

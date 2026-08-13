  //DELOUT   JOB (BANK),'DELETE OUTPUT DATASETS',
  //         CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
  //*
  //*================================================================*
  //* JOB: DELOUT                                                     *
  //* PURPOSE: DELETE DAILY OUTPUT DATASETS BEFORE RERUN             *
  //* RUN THIS BEFORE RESUBMITTING DAILYBAT                          *
  //*================================================================*
  //STEP1    EXEC PGM=IEFBR14
  //DD1      DD DSN=BANK.TRANS.PROCESSED,DISP=(MOD,DELETE,DELETE),
  //         UNIT=SYSDA
  //DD2      DD DSN=BANK.TRANS.REJECTED,DISP=(MOD,DELETE,DELETE),
  //         UNIT=SYSDA
  //DD3      DD DSN=BANK.DAILY.REPORT,DISP=(MOD,DELETE,DELETE),
  //         UNIT=SYSDA

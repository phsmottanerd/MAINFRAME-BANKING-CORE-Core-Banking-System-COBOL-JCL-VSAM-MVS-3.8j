  //LISTVSAM  JOB (BANK),'LISTCAT VSAM CLUSTERS',
  //          CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
  //*
  //*================================================================*
  //* JOB: LISTVSAM                                                   *
  //* PURPOSE: LISTCAT OF ALL BANKING VSAM DATASETS                   *
  //* USE AFTER DEFVSAM TO VERIFY CLUSTERS WERE CREATED               *
  //*================================================================*
  //STEP1    EXEC PGM=IDCAMS
  //SYSPRINT DD SYSOUT=*
  //SYSIN    DD *
    LISTCAT ENTRIES(BANK.CUSTOMER.MASTER) ALL
    LISTCAT ENTRIES(BANK.ACCOUNT.MASTER)  ALL
    LISTCAT ENTRIES(BANK.TRANS.HISTORY)   ALL
  /*

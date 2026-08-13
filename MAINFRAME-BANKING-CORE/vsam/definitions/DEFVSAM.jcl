  //DEFVSAM  JOB (BANK),'DEFINE VSAM CLUSTERS',
  //         CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
  //         NOTIFY=&SYSUID
  //*
  //*================================================================*
  //* JOB: DEFVSAM                                                    *
  //* PURPOSE: DEFINE ALL VSAM KSDS CLUSTERS FOR BANKING SYSTEM       *
  //* ENVIRONMENT: MVS 3.8J TK4-                                      *
  //* NOTE: ADJUST VOLUMES TO MATCH YOUR TK4- DISK CONFIGURATION      *
  //*       TYPICAL TK4- VOLUMES: PUB000, PUB001, WORK00, etc.        *
  //*================================================================*
  //STEP1    EXEC PGM=IDCAMS
  //SYSPRINT DD SYSOUT=*
  //SYSIN    DD *

  /*------------------------------------------------------------------*/
  /* DELETE OLD CLUSTERS (IF THEY EXIST) - IGNORE ERRORS              */
  /*------------------------------------------------------------------*/
    DELETE BANK.CUSTOMER.MASTER CLUSTER PURGE
    IF LASTCC > 0 THEN SET MAXCC = 0

    DELETE BANK.ACCOUNT.MASTER CLUSTER PURGE
    IF LASTCC > 0 THEN SET MAXCC = 0

    DELETE BANK.TRANS.HISTORY CLUSTER PURGE
    IF LASTCC > 0 THEN SET MAXCC = 0

  /*------------------------------------------------------------------*/
  /* CUSTOMER MASTER - KSDS                                            */
  /* KEY: CUST-ID (8 bytes, position 1)                               */
  /* RECORD LENGTH: 159 bytes                                          */
  /*------------------------------------------------------------------*/
    DEFINE CLUSTER                                            -
      (NAME(BANK.CUSTOMER.MASTER)                            -
       INDEXED                                               -
       KEYS(8 0)                                             -
       RECORDSIZE(159 159)                                   -
       CYLINDERS(1 1)                                        -
       SHAREOPTIONS(2 3)                                     -
       VOLUMES(PUB000))                                      -
    DATA                                                     -
      (NAME(BANK.CUSTOMER.MASTER.DATA)                       -
       CONTROLINTERVALSIZE(4096))                            -
    INDEX                                                    -
      (NAME(BANK.CUSTOMER.MASTER.INDEX))

  /*------------------------------------------------------------------*/
  /* ACCOUNT MASTER - KSDS                                             */
  /* KEY: ACCT-NBR (10 bytes, position 1)                             */
  /* RECORD LENGTH: 110 bytes                                          */
  /*------------------------------------------------------------------*/
    DEFINE CLUSTER                                            -
      (NAME(BANK.ACCOUNT.MASTER)                             -
       INDEXED                                               -
       KEYS(10 0)                                            -
       RECORDSIZE(110 110)                                   -
       CYLINDERS(1 1)                                        -
       SHAREOPTIONS(2 3)                                     -
       VOLUMES(PUB000))                                      -
    DATA                                                     -
      (NAME(BANK.ACCOUNT.MASTER.DATA)                        -
       CONTROLINTERVALSIZE(4096))                            -
    INDEX                                                    -
      (NAME(BANK.ACCOUNT.MASTER.INDEX))

  /*------------------------------------------------------------------*/
  /* TRANSACTION HISTORY - KSDS                                        */
  /* KEY: TRAN-KEY (24 bytes - ACCT+DATE+SEQ, position 1)             */
  /* RECORD LENGTH: 150 bytes                                          */
  /* Sized larger - more CYLINDERs for growth                          */
  /*------------------------------------------------------------------*/
    DEFINE CLUSTER                                            -
      (NAME(BANK.TRANS.HISTORY)                              -
       INDEXED                                               -
       KEYS(24 0)                                            -
       RECORDSIZE(150 150)                                   -
       CYLINDERS(2 1)                                        -
       SHAREOPTIONS(2 3)                                     -
       VOLUMES(PUB000))                                      -
    DATA                                                     -
      (NAME(BANK.TRANS.HISTORY.DATA)                         -
       CONTROLINTERVALSIZE(4096))                            -
    INDEX                                                    -
      (NAME(BANK.TRANS.HISTORY.INDEX))

  /*

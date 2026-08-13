  //RUNCUST  JOB (BANK),'RUN CUSTOMER MANAGEMENT',
  //         CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
  //         NOTIFY=&SYSUID
  //*
  //*================================================================*
  //* JOB: RUNCUST                                                    *
  //* PURPOSE: INTERACTIVE CUSTOMER MANAGEMENT SESSION               *
  //* NOTE: REQUIRES TSO TERMINAL SESSION                             *
  //*================================================================*
  //STEP1    EXEC PGM=CUSTMGMT,REGION=1024K
  //STEPLIB  DD DSN=SYS1.BANKLOAD,DISP=SHR
  //CUSTMST  DD DSN=BANK.CUSTOMER.MASTER,DISP=SHR
  //SYSOUT   DD SYSOUT=*
  //SYSPRINT DD SYSOUT=*
  //SYSIN    DD DUMMY

  //RUNMENU  JOB (BANK),'RUN MAIN BANKING MENU',
  //         CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1),
  //         NOTIFY=&SYSUID
  //*
  //*================================================================*
  //* JOB: RUNMENU                                                    *
  //* PURPOSE: START MAIN BANKING MENU (BANKMENU)                     *
  //* BANKMENU CALLs ALL SUBMODULES                                   *
  //* ALL VSAM DDs NEEDED BY SUBMODULES MUST BE ALLOCATED HERE        *
  //*================================================================*
  //STEP1    EXEC PGM=BANKMENU,REGION=2048K
  //STEPLIB  DD DSN=SYS1.BANKLOAD,DISP=SHR
  //CUSTMST  DD DSN=BANK.CUSTOMER.MASTER,DISP=SHR
  //ACCTMST  DD DSN=BANK.ACCOUNT.MASTER,DISP=SHR
  //TRANHIST DD DSN=BANK.TRANS.HISTORY,DISP=SHR
  //SYSOUT   DD SYSOUT=*
  //SYSPRINT DD SYSOUT=*
  //SYSIN    DD DUMMY

  //PRTVSAM  JOB (BANK),'PRINT VSAM CONTENTS',
  //         CLASS=A,MSGCLASS=A,MSGLEVEL=(1,1)
  //*
  //*================================================================*
  //* JOB: PRTVSAM                                                    *
  //* PURPOSE: PRINT/DUMP VSAM DATASETS FOR DIAGNOSTICS              *
  //*================================================================*
  //STEP1    EXEC PGM=IDCAMS
  //SYSPRINT DD SYSOUT=*
  //CUSTMST  DD DSN=BANK.CUSTOMER.MASTER,DISP=SHR
  //ACCTMST  DD DSN=BANK.ACCOUNT.MASTER,DISP=SHR
  //TRANHIST DD DSN=BANK.TRANS.HISTORY,DISP=SHR
  //SYSIN    DD *
    PRINT INFILE(CUSTMST) CHARACTER
    PRINT INFILE(ACCTMST) CHARACTER
    PRINT INFILE(TRANHIST) CHARACTER
  /*

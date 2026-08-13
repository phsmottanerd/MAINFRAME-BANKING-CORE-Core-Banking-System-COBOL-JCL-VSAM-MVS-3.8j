# TK4- Transfer and Compatibility Guide

## How to Transfer Members to MVS 3.8j TK4-

### Prerequisites
- TK4- running under Hercules (http://wotho.ethz.ch/tk4-/)
- 3270 terminal emulator (x3270, c3270, or Hercules TCPIP console)
- IND$FILE (TSO file transfer) or FTP if TK4- NJE/FTP is configured
- Alternatively: RECFM/LRECL-correct FTP upload

---

### Step 1 — Create PDSs on TK4-

Logon to TSO (HERC01 / CUL8TR default credentials on TK4-).

From ISPF option 3.2 or via JCL:

```jcl
//CREATPDS JOB ...
//STEP1  EXEC PGM=IEFBR14
//COBOL  DD DSN=SYS1.COBOL,DISP=(NEW,CATLG),
//          UNIT=SYSDA,VOL=SER=PUB000,
//          SPACE=(CYL,(5,2,50)),
//          DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=3120)
//COPYLIB DD DSN=SYS1.COPYLIB,DISP=(NEW,CATLG),
//          UNIT=SYSDA,VOL=SER=PUB000,
//          SPACE=(CYL,(2,1,20)),
//          DCB=(DSORG=PO,RECFM=FB,LRECL=80,BLKSIZE=3120)
//LOADLIB DD DSN=SYS1.BANKLOAD,DISP=(NEW,CATLG),
//          UNIT=SYSDA,VOL=SER=PUB000,
//          SPACE=(CYL,(5,2,30)),
//          DCB=(DSORG=PO,RECFM=U,LRECL=0,BLKSIZE=6144)
```

---

### Step 2 — Upload COBOL Source Members

Each file in `cobol/programs/` and `cobol/utilities/` must be uploaded
as a fixed-80 member of `SYS1.COBOL`.

**Member name mapping** (max 8 chars in MVS):

| Local file            | MVS Member      |
|-----------------------|-----------------|
| BANKMENU.cbl          | BANKMENU        |
| CUSTMGMT.cbl          | CUSTMGMT        |
| ACCTMGMT.cbl          | ACCTMGMT        |
| BALANCIO.cbl          | BALANCIO        |
| DEPOSIT.cbl           | DEPOSIT         |
| WITHDRAW.cbl          | WITHDRAW        |
| TRANSFER.cbl          | TRANSFER        |
| TRANHIST.cbl          | TRANHIST        |
| ACCTBLCK.cbl          | ACCTBLCK        |
| BATCHPROC.cbl         | BATCHPRC        |
| RPTGEN.cbl            | RPTGEN          |
| DATEVAL.cbl           | DATEVAL         |
| ERRHANDL.cbl          | ERRHANDL        |

**Upload command (FTP to TK4-):**
```
ftp <TK4-IP>
quote site recfm=fb lrecl=80 blksize=3120
put BANKMENU.cbl 'SYS1.COBOL(BANKMENU)'
... (repeat for each member)
```

---

### Step 3 — Upload Copybooks

Each file in `cobol/copybooks/` goes to `SYS1.COPYLIB`:

| Local file            | MVS Member      |
|-----------------------|-----------------|
| CUSTLAYO.cpy          | CUSTLAYO        |
| ACCTLAYO.cpy          | ACCTLAYO        |
| TRANLAYO.cpy          | TRANLAYO        |
| FILESTCD.cpy          | FILESTCD        |
| WRKSTORE.cpy          | WRKSTORE        |
| MSGLIB.cpy            | MSGLIB          |

---

### Step 4 — Upload and Submit JCL

Upload JCL files from `jcl/` subdirectories:

```
jcl/maintenance/BACKVSAM.jcl  → SYS1.JCLLIB(BACKVSAM)
jcl/maintenance/DELOUT.jcl    → SYS1.JCLLIB(DELOUT)
vsam/definitions/DEFVSAM.jcl  → SYS1.JCLLIB(DEFVSAM)
vsam/utilities/LOADDATA.jcl   → SYS1.JCLLIB(LOADDATA)
jcl/compile/COMPILALL.jcl     → SYS1.JCLLIB(COMPALL)
jcl/batch/DAILYBAT.jcl        → SYS1.JCLLIB(DAILYBAT)
jcl/run/RUNMENU.jcl           → SYS1.JCLLIB(RUNMENU)
```

From ISPF, submit with: **SUBMIT** command or `S` prefix.

---

### Step 5 — Execution Sequence

1. `SUBMIT 'SYS1.JCLLIB(DEFVSAM)'`   ← Define VSAM clusters
2. `SUBMIT 'SYS1.JCLLIB(COMPALL)'`   ← Compile all COBOL programs
3. `SUBMIT 'SYS1.JCLLIB(LOADDATA)'`  ← Load seed data
4. `SUBMIT 'SYS1.JCLLIB(RUNMENU)'`   ← Run banking menu session
5. Upload DAILY01.txt → BANK.DAILY.TRANS
6. `SUBMIT 'SYS1.JCLLIB(DAILYBAT)'`  ← Run batch

---

### TK4- Specific Notes

**Volume names:** TK4- default volumes are `PUB000`, `PUB001`, `WORK00`, `SORTW00`.
Change `VOL=SER=PUB000` in all JCL to match your configuration.

**Compiler name:** TK4- ships with `IGYCRCTL` (VS COBOL II) or `IEY0AA` (OS/VS COBOL).
Check which is installed:
```
LISTCAT ENTRIES(SYS1.COBLIB) ALL
```

**SYSLIB for COBOL compile:** Ensure SYSLIB points to `SYS1.COPYLIB` where
copybooks are stored. If you use a different PDS, update the compile JCL.

**TSO REGION:** TK4- default region is limited. The programs use up to 2048K.
Verify your TSO default region allows this.

**IND$FILE:** TK4- supports IND$FILE for 3270 file transfer. This is the
simplest method without FTP configuration.

---

### Known Compatibility Issues

| Issue                        | Solution                                    |
|------------------------------|---------------------------------------------|
| `FUNCTION NUMVAL` not in OS/VS COBOL | Replace with arithmetic parsing paragraph |
| `EVALUATE` syntax varies     | OS/VS COBOL supports basic EVALUATE         |
| `END-IF` / `END-EVALUATE`    | Supported in OS/VS COBOL 1.2+               |
| `GOBACK` in subprograms      | Supported                                   |
| `STRING` with DELIMITED SIZE | Supported                                   |
| `ACCEPT DATE`                | Returns YYMMDD on MVS                       |

**IMPORTANT:** The `FUNCTION NUMVAL` intrinsic function may not be available
in the OS/VS COBOL compiler included with TK4-. In that case, replace:
```cobol
MOVE FUNCTION NUMVAL(WS-DEPOSIT-AMT-INPUT) TO WS-DEPOSIT-AMT
```
with a custom numeric parsing paragraph that reads character-by-character
and builds a packed decimal value.

---

### Future DB2/CICS Preparation

When TK4- (or a CICS-enabled MVS image) is available:
- `BANKMENU.cbl` → Replace DISPLAY/ACCEPT with CICS BMS map sends
- `CUSTMGMT.cbl` → Replace VSAM OPEN/CLOSE with EXEC CICS READ/WRITE
- `BATCHPROC.cbl` → Can remain as-is; batch does not require CICS
- DB2 layer → Add EXEC SQL SELECT/INSERT/UPDATE in place of VSAM calls
- Keep copybooks compatible — only I/O verb changes

The logical separation of programs already follows the CICS philosophy:
one program per function, no shared open files across CALLs.

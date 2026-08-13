# MAINFRAME-BANKING-CORE

> **Mainframe Banking System — COBOL + JCL + VSAM**
> Intermediate/Advanced portfolio project compatible with MVS 3.8j TK4- / Hercules

---

## Objective

Simulate a real mainframe banking system using classic IBM technologies:
- **COBOL** (structured, multi-module)
- **JCL** (Job Control Language for MVS)
- **VSAM KSDS** (Key-Sequenced Data Sets)

The system is designed to run on **MVS 3.8j TK4-** under the **Hercules** emulator
and is structured for future evolution toward **CICS** (online) and **DB2** (relational).

---

## Architecture

```
MAINFRAME-BANKING-CORE/
│
├── cobol/
│   ├── programs/       ← Main COBOL programs (one per functional module)
│   ├── copybooks/      ← Shared record layouts, FILE STATUS codes, constants
│   └── utilities/      ← Utility programs (date validation, formatting)
│
├── jcl/
│   ├── compile/        ← JCL to compile each COBOL program
│   ├── run/            ← JCL to run individual programs (online-style batch)
│   ├── batch/          ← Daily batch processing jobs
│   └── maintenance/    ← VSAM IDCAMS define/delete/repro/listcat jobs
│
├── vsam/
│   ├── definitions/    ← IDCAMS DEFINE CLUSTER statements (text)
│   ├── data/           ← REPRO seed data (flat files loaded into VSAM)
│   └── utilities/      ← VSAM LISTCAT / VERIFY / PRINT scripts
│
├── test-data/          ← Flat-file transaction batches for testing
├── documentation/      ← Architecture diagrams, flow descriptions
└── README.md
```

---

## Technologies

| Technology  | Version / Environment        |
|-------------|------------------------------|
| COBOL       | OS/VS COBOL (ANS 74/85)      |
| JCL         | MVS 3.8j JCL                 |
| VSAM        | KSDS (IDCAMS)                |
| Assembler   | Not used in V1               |
| CICS        | Not in V1 — planned for V2   |
| DB2         | Not in V1 — planned for V2   |
| Environment | MVS 3.8j TK4- / Hercules     |
| Editor      | VS Code (local authoring)    |

---

## COBOL Programs

| Program     | Description                                      |
|-------------|--------------------------------------------------|
| BANKMENU    | Main menu — routes to all modules                |
| CUSTMGMT    | Customer management (add / query / update)       |
| ACCTMGMT    | Account management (open / query / update)       |
| BALANCIO    | Balance inquiry                                  |
| DEPOSIT     | Deposit processing                               |
| WITHDRAW    | Withdrawal processing                            |
| TRANSFER    | Funds transfer between accounts                  |
| TRANHIST    | Transaction history inquiry                      |
| ACCTBLCK    | Account block / unblock                          |
| BATCHPROC   | Daily batch transaction processor                |
| RPTGEN      | Report generator                                 |
| DATEVAL     | Utility — date validation / formatting           |
| ERRHANDL    | Utility — centralised error handler / logger     |

---

## Copybooks

| Copybook    | Contents                                          |
|-------------|---------------------------------------------------|
| CUSTLAYO    | CUSTOMER master record layout                     |
| ACCTLAYO    | ACCOUNT master record layout                      |
| TRANLAYO    | TRANSACTION record layout                         |
| FILESTCD    | FILE STATUS code constants and condition names    |
| WRKSTORE    | Common WORKING-STORAGE variables                  |
| MSGLIB      | Standard user-facing messages                     |

---

## VSAM Datasets

| Dataset              | Type  | Key             | Description              |
|----------------------|-------|-----------------|--------------------------|
| BANK.CUSTOMER.MASTER | KSDS  | CUST-ID (8)     | Customer master file     |
| BANK.ACCOUNT.MASTER  | KSDS  | ACCT-NBR (10)   | Account master file      |
| BANK.TRANS.HISTORY   | KSDS  | TRAN-KEY (20)   | Transaction history      |
| BANK.DAILY.TRANS     | PS    | N/A             | Input batch transactions |
| BANK.TRANS.PROCESSED | PS    | N/A             | Approved transactions    |
| BANK.TRANS.REJECTED  | PS    | N/A             | Rejected transactions    |
| BANK.DAILY.REPORT    | PS    | N/A             | Daily processing report  |

---

## Business Rules

1. No withdrawal above available balance
2. No negative or zero amounts
3. No transaction on blocked account
4. No duplicate customer ID or account number
5. No transfer to non-existent account
6. All rejected transactions are logged with reason code
7. Transaction history maintained for every approved movement
8. Account block prevents all debit/credit operations
9. Date validation on all input records
10. FILE STATUS checked after every I/O operation

---

## Batch Processing Flow

```
DAILY.TRANSACTIONS (input flat file)
        │
        ▼
   BATCHPROC
        ├─── Validate record format
        ├─── Lookup CUSTOMER.MASTER
        ├─── Lookup ACCOUNT.MASTER
        ├─── Apply business rules
        ├─── APPROVED ──► TRANSACTIONS.PROCESSED
        │               ──► TRANS.HISTORY (VSAM WRITE)
        │               ──► ACCOUNT (VSAM REWRITE — update balance)
        └─── REJECTED  ──► TRANSACTIONS.REJECTED (with reason code)
        │
        ▼
   RPTGEN ──► DAILY.REPORT
```

---

## How to Compile (TK4-)

1. Upload all members under `cobol/` to a PDS (e.g. `SYS1.COBOL`)
2. Upload copybooks to a copybook PDS (e.g. `SYS1.COPYLIB`)
3. Submit the appropriate JCL from `jcl/compile/` for each program
4. The compile JCL uses `//SYSLIB DD DSN=SYS1.COPYLIB` for copybook resolution
5. Check SYSOUT for compilation errors (RC=0 or RC=4 are acceptable)

### Example compile sequence (order matters due to dependencies):
```
COMPILE: DATEVAL → ERRHANDL → CUSTMGMT → ACCTMGMT →
         DEPOSIT → WITHDRAW → TRANSFER → BATCHPROC → RPTGEN → BANKMENU
```

---

## How to Run (TK4-)

1. Submit `jcl/maintenance/DEFVSAM.jcl` — creates all VSAM clusters
2. Submit `jcl/maintenance/LOADDATA.jcl` — loads seed data via IDCAMS REPRO
3. Submit `jcl/run/BANKMENU.jcl` — runs the interactive menu program
4. For batch: submit `jcl/batch/DAILYBAT.jcl`

---

## TK4- / MVS 3.8j Limitations

| Feature              | Status in TK4-                          | Workaround                           |
|----------------------|-----------------------------------------|--------------------------------------|
| CICS                 | Not available in standard TK4-          | Future V2 with CICS-enabled build    |
| DB2                  | Not available                           | Future V2                            |
| VSAM LDS             | Limited support                         | Use KSDS / ESDS only                 |
| SMS                  | Not available                           | Explicit UNIT/VOL in JCL             |
| RACF                 | Not available                           | No security layer in V1              |
| Long dataset names   | 44 chars max (MVS standard)             | Keep names short                     |
| COBOL II / Enterprise| Not available                           | Use OS/VS COBOL syntax only          |
| Compiler NOSSRANGE   | Use compile option NOSSRANGE            | Already set in compile JCL           |

---

## Future Evolution (V2 — CICS + DB2)

- Replace VSAM sequential menus with CICS BMS maps (3270 screens)
- Replace VSAM master files with DB2 tables
- CUSTMGMT / ACCTMGMT become CICS programs using EXEC CICS READ/WRITE
- BATCHPROC remains batch but writes to DB2 via embedded SQL
- Add IMS/DC as alternative to CICS

---

## Test Data

See `test-data/` directory for:
- `CUSTDATA.txt` — seed customers
- `ACCTDATA.txt` — seed accounts
- `DAILY01.txt` — valid batch transactions
- `DAILY02.txt` — mixed valid/invalid batch
- `DAILY03.txt` — all-reject batch (edge cases)

---

## Project Status

| Etapa | Description                        | Status    |
|-------|------------------------------------|-----------|
| 1     | Project architecture & structure   | ✅ Done   |
| 2     | Copybooks & COBOL programs         | ✅ Done   |
| 3     | VSAM definitions                   | ✅ Done   |
| 4     | Compile & run JCL                  | ✅ Done   |
| 5     | Batch processing                   | ✅ Done   |
| 6     | Business rules & error handling    | ✅ Done   |
| 7     | Test data                          | ✅ Done   |
| 8     | TK4- compatibility review          | ✅ Done   |
| 9     | Local validation                   | ✅ Done   |
| 10    | TK4- transfer documentation        | ✅ Done   |

---

*MAINFRAME-BANKING-CORE — Portfolio Project — MVS 3.8j / TK4- / Hercules*

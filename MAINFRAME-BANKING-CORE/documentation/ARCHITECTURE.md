# System Architecture — MAINFRAME-BANKING-CORE

## Component Relationships

```
BANKMENU (main menu)
│
├── CALL 'CUSTMGMT'  ─── BANK.CUSTOMER.MASTER (VSAM KSDS)
│       COPY CUSTLAYO, WRKSTORE, FILESTCD, MSGLIB
│       CALL 'DATEVAL', 'ERRHANDL'
│
├── CALL 'ACCTMGMT'  ─── BANK.CUSTOMER.MASTER (read/verify)
│       │             ── BANK.ACCOUNT.MASTER  (VSAM KSDS)
│       COPY CUSTLAYO, ACCTLAYO, WRKSTORE, FILESTCD, MSGLIB
│       CALL 'DATEVAL', 'ERRHANDL'
│
├── CALL 'BALANCIO'  ─── BANK.ACCOUNT.MASTER (read-only)
│       COPY ACCTLAYO, WRKSTORE, FILESTCD, MSGLIB
│
├── CALL 'DEPOSIT'   ─── BANK.ACCOUNT.MASTER (REWRITE)
│       │             ── BANK.TRANS.HISTORY  (WRITE)
│       COPY ACCTLAYO, TRANLAYO, WRKSTORE, FILESTCD, MSGLIB
│       CALL 'DATEVAL', 'ERRHANDL'
│
├── CALL 'WITHDRAW'  ─── BANK.ACCOUNT.MASTER (REWRITE)
│       │             ── BANK.TRANS.HISTORY  (WRITE)
│       COPY ACCTLAYO, TRANLAYO, WRKSTORE, FILESTCD, MSGLIB
│       CALL 'DATEVAL', 'ERRHANDL'
│
├── CALL 'TRANSFER'  ─── BANK.ACCOUNT.MASTER (2x REWRITE)
│       │             ── BANK.TRANS.HISTORY  (2x WRITE)
│       COPY ACCTLAYO, TRANLAYO, WRKSTORE, FILESTCD, MSGLIB
│       CALL 'DATEVAL', 'ERRHANDL'
│
├── CALL 'TRANHIST'  ─── BANK.TRANS.HISTORY (START + sequential READ)
│       COPY TRANLAYO, WRKSTORE, FILESTCD, MSGLIB
│
├── CALL 'ACCTBLCK'  ─── BANK.ACCOUNT.MASTER (REWRITE)
│       COPY ACCTLAYO, WRKSTORE, FILESTCD, MSGLIB
│       CALL 'DATEVAL'
│
└── CALL 'RPTGEN'    ─── BANK.TRANS.PROCESSED (read)
        │             ── BANK.TRANS.REJECTED  (read)
        │             ── BANK.DAILY.REPORT    (write)
        COPY WRKSTORE, FILESTCD

BATCHPROC (batch, independent)
        │ reads  BANK.DAILY.TRANS
        │ reads/writes BANK.ACCOUNT.MASTER
        │ writes BANK.TRANS.HISTORY
        │ writes BANK.TRANS.PROCESSED
        │ writes BANK.TRANS.REJECTED
        COPY ACCTLAYO, TRANLAYO, WRKSTORE, FILESTCD
        CALL 'DATEVAL', 'ERRHANDL'
```

---

## Data Flow

```
[ONLINE SESSION]          [BATCH DAILY]
     │                         │
BANKMENU                  DAILY.TRANS (PS)
     │                         │
     ├── CUSTMGMT             SORT step
     ├── ACCTMGMT              │
     ├── BALANCIO          BATCHPROC
     ├── DEPOSIT  ──┐          │
     ├── WITHDRAW ──┼──► ACCOUNT.MASTER (VSAM)
     ├── TRANSFER ──┤          │
     ├── TRANHIST   │     TRANS.HISTORY (VSAM)
     ├── ACCTBLCK   │          │
     └── RPTGEN  ◄──┘    TRANS.PROCESSED (PS)
                          TRANS.REJECTED  (PS)
                               │
                           RPTGEN ──► DAILY.REPORT (PS)
```

---

## VSAM Access Patterns

| Program    | CUSTOMER.MASTER | ACCOUNT.MASTER | TRANS.HISTORY |
|------------|-----------------|----------------|---------------|
| CUSTMGMT   | READ/WRITE/RWR  | -              | -             |
| ACCTMGMT   | READ            | READ/WRITE/RWR | -             |
| BALANCIO   | -               | READ           | -             |
| DEPOSIT    | -               | READ/REWRITE   | WRITE         |
| WITHDRAW   | -               | READ/REWRITE   | WRITE         |
| TRANSFER   | -               | 2x READ/RWRIT  | 2x WRITE      |
| TRANHIST   | -               | -              | START+SEQ READ|
| ACCTBLCK   | -               | READ/REWRITE   | -             |
| BATCHPROC  | -               | READ/REWRITE   | WRITE         |
| RPTGEN     | -               | -              | -             |

---

## Business Rules Matrix

| Rule                           | Enforced In                    |
|--------------------------------|--------------------------------|
| No duplicate customer          | CUSTMGMT (READ before WRITE)   |
| No duplicate account           | ACCTMGMT (READ before WRITE)   |
| No negative amounts            | DEPOSIT, WITHDRAW, TRANSFER, BATCHPROC |
| No saque acima do saldo        | WITHDRAW, TRANSFER, BATCHPROC  |
| No movement on blocked account | DEPOSIT, WITHDRAW, TRANSFER, BATCHPROC |
| No movement on closed account  | DEPOSIT, WITHDRAW, TRANSFER, BATCHPROC |
| Transfer to valid account only | TRANSFER, BATCHPROC            |
| Transaction history maintained | DEPOSIT, WITHDRAW, TRANSFER, BATCHPROC |
| DATE recorded on all writes    | All programs via DATEVAL       |
| All I/O errors logged          | All programs via ERRHANDL      |

---

## FILE STATUS Handling Strategy

Every I/O operation checks FILE STATUS immediately:
- `00` = Success → continue
- `10` = EOF → set EOF-FLAG
- `22` = Duplicate key → sequence retry on WRITE
- `23` = Not found → report to user / reject
- `24` = No space → log via ERRHANDL, abort
- `35` = File not found → auto-create on first OPEN (for output files)
- Other → CALL ERRHANDL with program name + FS code + key

This pattern is consistent across ALL programs, making the
codebase predictable and maintainable.

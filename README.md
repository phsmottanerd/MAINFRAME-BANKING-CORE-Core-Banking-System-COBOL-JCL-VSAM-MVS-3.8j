# MAINFRAME-BANKING-CORE

## Core Banking System — COBOL / JCL / VSAM / MVS 3.8j

![COBOL](https://img.shields.io/badge/COBOL-Mainframe-blue)
![IBM Z](https://img.shields.io/badge/IBM%20Z-z%2FOS%20%7C%20MVS%203.8j-red)
![JCL](https://img.shields.io/badge/JCL-Batch%20Processing-orange)
![VSAM](https://img.shields.io/badge/VSAM-Data%20Management-purple)
![TSO](https://img.shields.io/badge/TSO-3270-green)
![GitHub](https://img.shields.io/badge/Portfolio-Mainframe-black)

---

## 1. Visão geral

**MAINFRAME-BANKING-CORE** é um projeto de laboratório e portfólio desenvolvido em COBOL com uma arquitetura inspirada em sistemas tradicionais de processamento bancário em ambientes IBM Mainframe.

O projeto foi estruturado para demonstrar conhecimentos práticos relacionados a:

* COBOL;
* programação estruturada;
* organização modular;
* Copybooks;
* processamento batch;
* JCL;
* datasets;
* VSAM;
* dados de teste;
* rotinas utilitárias;
* tratamento de erros;
* execução em ambiente MVS/TSO;
* conceitos de operação de sistemas Mainframe.

O objetivo principal é construir um ambiente de estudo que represente, de forma prática, componentes encontrados no ecossistema tradicional de sistemas corporativos e bancários.

> **Projeto de laboratório / portfólio.**
>
> Este repositório não representa um sistema bancário de produção e não contém dados bancários reais.

---

# 2. Objetivos do projeto

O projeto foi criado com os seguintes objetivos:

### Desenvolvimento

* Praticar COBOL em uma arquitetura modular.
* Trabalhar com programas separados por responsabilidade.
* Utilizar Copybooks para compartilhamento de estruturas.
* Desenvolver rotinas de processamento bancário.

### Mainframe

* Trabalhar com conceitos de datasets.
* Organizar fontes como uma estrutura compatível com PDS.
* Utilizar JCL para processos batch.
* Trabalhar com conceitos de VSAM.
* Executar e testar componentes em ambiente MVS 3.8j / TK4-.
* Utilizar TSO e terminal 3270.

### Portfólio profissional

Demonstrar conhecimento prático em uma stack tradicional de Mainframe:

```text
COBOL
  │
  ├── Copybooks
  │
  ├── Programas
  │
  └── Utilities
        │
        ▼
       JCL
        │
        ├── Compile
        ├── Run
        ├── Batch
        └── Maintenance
        │
        ▼
       VSAM
        │
        ▼
     MVS / TSO
        │
        ▼
      TK4-
```

---

# 3. Arquitetura do projeto

A organização do projeto foi pensada para separar código, estruturas compartilhadas, processamento batch, dados e documentação.

```text
MAINFRAME-BANKING-CORE/
│
├── .vscode/
│   └── settings.json
│
├── cobol/
│   │
│   ├── copybooks/
│   │   ├── ACCTLAYO.cpy
│   │   ├── CUSTLAYO.cpy
│   │   ├── FILESTCD.cpy
│   │   ├── MSGLIB.cpy
│   │   ├── TRANLAYO.cpy
│   │   └── WRKSTORE.cpy
│   │
│   ├── programs/
│   │   ├── ACCTBLCK.cbl
│   │   ├── ACCTMGMT.cbl
│   │   ├── BALANCIO.cbl
│   │   ├── BANKMENU.cbl
│   │   ├── BATCHPROC.cbl
│   │   ├── CUSTMGMT.cbl
│   │   ├── DEPOSIT.cbl
│   │   ├── RPTGEN.cbl
│   │   ├── TRANHIST.cbl
│   │   ├── TRANSFER.cbl
│   │   └── WITHDRAW.cbl
│   │
│   └── utilities/
│       ├── DATEVAL.cbl
│       └── ERRHANDL.cbl
│
├── documentation/
│   ├── ARCHITECTURE.md
│   └── TK4-TRANSFER.md
│
├── jcl/
│   │
│   ├── batch/
│   │   ├── DAILYBAT.jcl
│   │   └── PRTREPORT.jcl
│   │
│   ├── compile/
│   │   └── COMPILALL.jcl
│   │
│   ├── maintenance/
│   │   ├── BACKVSAM.jcl
│   │   └── DELOUT.jcl
│   │
│   └── run/
│       ├── RUNACCT.jcl
│       ├── RUNCUST.jcl
│       └── RUNMENU.jcl
│
├── test-data/
│   ├── DAILY01.txt
│   ├── DAILY02.txt
│   └── DAILY03.txt
│
├── vsam/
│   │
│   ├── data/
│   │   ├── ACCTDATA.txt
│   │   └── CUSTDATA.txt
│   │
│   ├── definitions/
│   │   └── DEFVSAM.jcl
│   │
│   └── utilities/
│       ├── LISTVSAM.jcl
│       ├── LOADDATA.jcl
│       ├── PRTVSAM.jcl
│       └── VERFVSAM.jcl
│
└── README.md
```

---

# 4. Camada COBOL

A camada `cobol/` concentra o código-fonte principal da aplicação.

Ela foi dividida em três áreas:

```text
cobol/
├── copybooks/
├── programs/
└── utilities/
```

Essa separação facilita manutenção, reutilização de estruturas e organização do código.

---

# 5. Copybooks

Os Copybooks estão localizados em:

```text
cobol/copybooks/
```

Arquivos:

```text
ACCTLAYO.cpy
CUSTLAYO.cpy
FILESTCD.cpy
MSGLIB.cpy
TRANLAYO.cpy
WRKSTORE.cpy
```

Os Copybooks representam estruturas compartilhadas entre programas COBOL.

A utilização desse mecanismo permite evitar a duplicação de estruturas e manter definições comuns centralizadas.

### Estruturas relacionadas

```text
ACCTLAYO.cpy
    ↓
Estruturas relacionadas a contas

CUSTLAYO.cpy
    ↓
Estruturas relacionadas a clientes

TRANLAYO.cpy
    ↓
Estruturas relacionadas a transações

FILESTCD.cpy
    ↓
Constantes/status relacionados a arquivos

MSGLIB.cpy
    ↓
Mensagens compartilhadas

WRKSTORE.cpy
    ↓
Estruturas de trabalho compartilhadas
```

---

# 6. Programas COBOL

Os programas principais estão em:

```text
cobol/programs/
```

### ACCTBLCK

```text
ACCTBLCK.cbl
```

Componente relacionado ao processamento de contas.

---

### ACCTMGMT

```text
ACCTMGMT.cbl
```

Componente relacionado ao gerenciamento de contas.

---

### BALANCIO

```text
BALANCIO.cbl
```

Componente relacionado às operações de consulta/processamento de saldo.

---

### BANKMENU

```text
BANKMENU.cbl
```

Componente associado à interface/menu principal do sistema bancário.

---

### BATCHPROC

```text
BATCHPROC.cbl
```

Componente destinado ao processamento batch.

---

### CUSTMGMT

```text
CUSTMGMT.cbl
```

Componente relacionado ao gerenciamento de clientes.

---

### DEPOSIT

```text
DEPOSIT.cbl
```

Componente relacionado à operação de depósito.

---

### RPTGEN

```text
RPTGEN.cbl
```

Componente destinado à geração de relatórios.

---

### TRANHIST

```text
TRANHIST.cbl
```

Componente relacionado ao histórico de transações.

---

### TRANSFER

```text
TRANSFER.cbl
```

Componente relacionado às operações de transferência.

---

### WITHDRAW

```text
WITHDRAW.cbl
```

Componente relacionado à operação de saque.

---

# 7. Utilities COBOL

As rotinas auxiliares estão localizadas em:

```text
cobol/utilities/
```

### DATEVAL

```text
DATEVAL.cbl
```

Rotina utilitária relacionada à validação/processamento de datas.

### ERRHANDL

```text
ERRHANDL.cbl
```

Rotina destinada ao tratamento de erros.

A separação dessas rotinas evita colocar responsabilidades auxiliares diretamente nos programas de negócio.

---

# 8. JCL

A camada JCL está organizada em quatro áreas:

```text
jcl/
├── batch/
├── compile/
├── maintenance/
└── run/
```

Essa organização representa uma separação clara entre diferentes tipos de processamento.

---

# 9. JCL de compilação

Arquivo:

```text
jcl/compile/COMPILALL.jcl
```

Responsável pelo processo de compilação dos componentes COBOL conforme a configuração definida no ambiente.

A existência de uma rotina dedicada de compilação permite padronizar o processo de build dentro do ambiente Mainframe.

---

# 10. JCL de execução

Diretório:

```text
jcl/run/
```

Arquivos:

```text
RUNACCT.jcl
RUNCUST.jcl
RUNMENU.jcl
```

Esses jobs representam pontos de entrada para execução de componentes do sistema.

---

# 11. JCL Batch

Diretório:

```text
jcl/batch/
```

Arquivos:

```text
DAILYBAT.jcl
PRTREPORT.jcl
```

Essa camada representa processos batch e geração/processamento de informações.

Em ambientes Mainframe, processamento batch é fundamental para tarefas programadas, processamento de grandes volumes de dados e rotinas operacionais.

---

# 12. JCL de manutenção

Diretório:

```text
jcl/maintenance/
```

Arquivos:

```text
BACKVSAM.jcl
DELOUT.jcl
```

Essa área concentra rotinas administrativas/manutenção relacionadas ao ambiente de processamento.

---

# 13. VSAM

A camada VSAM está organizada da seguinte forma:

```text
vsam/
├── data/
├── definitions/
└── utilities/
```

Essa separação permite distinguir:

* dados;
* definições;
* utilitários de administração.

---

# 14. Dados VSAM

Diretório:

```text
vsam/data/
```

Arquivos:

```text
ACCTDATA.txt
CUSTDATA.txt
```

Esses arquivos representam dados utilizados no laboratório para contas e clientes.

Eles fazem parte do conjunto de dados de teste/documentação do projeto e não representam dados bancários reais.

---

# 15. Definições VSAM

Arquivo:

```text
vsam/definitions/DEFVSAM.jcl
```

Esse job concentra a definição/configuração das estruturas VSAM utilizadas pelo laboratório.

---

# 16. Utilitários VSAM

Diretório:

```text
vsam/utilities/
```

Arquivos:

```text
LISTVSAM.jcl
LOADDATA.jcl
PRTVSAM.jcl
VERFVSAM.jcl
```

Essas rotinas representam operações auxiliares de administração, carga, consulta e verificação dos dados VSAM.

---

# 17. Dados de teste

O diretório:

```text
test-data/
```

contém:

```text
DAILY01.txt
DAILY02.txt
DAILY03.txt
```

Esses arquivos são utilizados como massa de teste para os processos do laboratório.

---

# 18. Documentação

A documentação adicional está em:

```text
documentation/
```

Arquivos:

```text
ARCHITECTURE.md
TK4-TRANSFER.md
```

`ARCHITECTURE.md` documenta a organização arquitetural.

`TK4-TRANSFER.md` documenta o processo de transferência e integração do projeto com o ambiente TK4-.

---

# 19. Ambiente Mainframe

O projeto está sendo preparado para execução em ambiente de laboratório baseado em:

```text
MVS 3.8j
TK4-
TSO
3270
JCL
COBOL
VSAM
```

O ambiente TK4- é utilizado como laboratório para reproduzir conceitos tradicionais de Mainframe sem a necessidade de acesso a um computador IBM Z físico.

---

# 20. TSO e terminal 3270

A interação com o ambiente é realizada através de um terminal 3270.

No laboratório foram utilizados:

```text
TSO
3270
ZOC
RFE
```

O TSO permite executar comandos e acessar recursos do ambiente MVS.

---

# 21. Dataset principal do projeto

Durante a preparação do laboratório foi criado o seguinte PDS:

```text
HERC01.COBOL.SRC
```

Configuração utilizada:

```text
DSORG  = PO
RECFM  = FB
LRECL  = 80
BLKSIZE = 3120
```

Esse dataset foi preparado para receber os membros COBOL do projeto.

A intenção é utilizar uma organização semelhante à encontrada em ambientes tradicionais de desenvolvimento Mainframe, onde fontes COBOL podem ser mantidos em datasets particionados.

---

# 22. Estratégia de implantação no TK4-

A estratégia de integração é:

```text
Windows
   │
   │ MAINFRAME-BANKING-CORE
   │
   ▼
Transferência de arquivos
   │
   ▼
TSO / MVS 3.8j
   │
   ▼
HERC01.COBOL.SRC
   │
   ▼
Compilação via JCL
   │
   ▼
Execução
   │
   ▼
Testes no TK4-
```

A transferência está sendo realizada através do mecanismo `IND$FILE` disponível no ambiente TK4-.

---

# 23. Fluxo conceitual do sistema

```text
                ┌─────────────────────┐
                │     BANKMENU        │
                │   Interface/Menu    │
                └──────────┬──────────┘
                           │
             ┌─────────────┼─────────────┐
             │             │             │
             ▼             ▼             ▼
        Account        Customer       Balance
        Management     Management      Processing
             │             │             │
             └─────────────┼─────────────┘
                           │
                           ▼
                    Transaction Layer
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
           DEPOSIT      WITHDRAW      TRANSFER
              │            │            │
              └────────────┼────────────┘
                           ▼
                    Transaction History
                           │
                           ▼
                         VSAM
                           │
                           ▼
                       Reports
```

---

# 24. Conceitos de Mainframe demonstrados

O projeto foi estruturado para demonstrar familiaridade com:

### Linguagem

* COBOL

### Sistema operacional / ambiente

* MVS 3.8j
* TSO

### Terminal

* 3270

### Job control

* JCL

### Armazenamento

* Datasets
* PDS
* VSAM

### Organização de código

* Copybooks
* Programas modulares
* Utilities

### Processamento

* Online/interativo em laboratório
* Batch
* Jobs de compilação
* Jobs de execução
* Jobs de manutenção

### Operação

* Dataset allocation
* Dataset listing
* PDS members
* TSO commands
* transferência de arquivos
* execução de jobs

---

# 25. Estrutura de responsabilidades

```text
COBOL
 │
 ├── Business Programs
 │
 ├── Copybooks
 │
 └── Utilities
       │
       ▼
JCL
 │
 ├── Compile
 ├── Run
 ├── Batch
 └── Maintenance
       │
       ▼
Data Layer
 │
 └── VSAM
       │
       ▼
MVS / TSO
 │
 └── TK4-
```

---

# 26. Estratégia de desenvolvimento

O projeto segue uma abordagem incremental.

### Etapa 1 — Desenvolvimento

Desenvolvimento e organização dos fontes COBOL.

### Etapa 2 — Organização

Separação entre:

```text
Programs
Copybooks
Utilities
JCL
VSAM
Test Data
Documentation
```

### Etapa 3 — Preparação do ambiente

Configuração do laboratório MVS 3.8j / TK4-.

### Etapa 4 — Dataset

Criação do:

```text
HERC01.COBOL.SRC
```

### Etapa 5 — Transferência

Transferência dos fontes para o ambiente Mainframe.

### Etapa 6 — Compilação

Execução dos JCL de compilação.

### Etapa 7 — Testes

Execução dos programas e validação dos resultados.

### Etapa 8 — Evidências

Registro de telas do TSO, jobs, datasets e execução.

---

# 27. Roadmap

## Concluído

* [x] Estrutura inicial do projeto
* [x] Programas COBOL
* [x] Copybooks
* [x] Utilities
* [x] JCL
* [x] Estrutura VSAM
* [x] Dados de teste
* [x] Documentação inicial
* [x] Ambiente TK4- preparado
* [x] Acesso TSO configurado
* [x] Dataset `HERC01.COBOL.SRC` criado

## Em andamento

* [ ] Transferência dos fontes COBOL para o TK4-
* [ ] Compilação no MVS
* [ ] Execução dos jobs
* [ ] Validação dos resultados
* [ ] Testes integrados
* [ ] Registro de evidências

## Futuro

* [ ] Expandir cobertura de testes
* [ ] Melhorar documentação técnica
* [ ] Adicionar evidências de execução
* [ ] Documentar troubleshooting
* [ ] Criar fluxo completo de build
* [ ] Documentar execução batch
* [ ] Expandir integração VSAM
* [ ] Adicionar diagramas adicionais

---

# 28. Boas práticas utilizadas

O projeto procura aplicar princípios importantes de desenvolvimento Mainframe:

* separação de responsabilidades;
* reutilização através de Copybooks;
* organização de fontes;
* padronização de JCL;
* separação de processos batch;
* documentação técnica;
* organização de dados;
* utilização de rotinas utilitárias;
* tratamento de erros;
* versionamento através de Git.

---

# 29. Segurança e dados

Este projeto é exclusivamente educacional e de portfólio.

Não são utilizados:

* dados bancários reais;
* números reais de contas;
* dados reais de clientes;
* credenciais de produção;
* informações financeiras reais.

Os dados existentes no repositório devem ser considerados **dados fictícios de laboratório**.

---

# 30. Tecnologias

| Tecnologia | Utilização                             |
| ---------- | -------------------------------------- |
| COBOL      | Desenvolvimento dos programas          |
| JCL        | Controle de jobs e processamento batch |
| VSAM       | Estrutura de armazenamento de dados    |
| TSO        | Ambiente de comandos                   |
| 3270       | Interface de terminal                  |
| MVS 3.8j   | Ambiente Mainframe de laboratório      |
| TK4-       | Emulação/laboratório IBM Mainframe     |
| Git        | Controle de versão                     |
| GitHub     | Versionamento e portfólio              |

---

# 31. Competências demonstradas

Este projeto demonstra conhecimentos práticos em:

```text
COBOL
JCL
TSO
MVS
VSAM
PDS
3270
Batch Processing
Mainframe Development
Dataset Management
Copybooks
Error Handling
Technical Documentation
Git
GitHub
```

---

# 32. Perfil profissional

Este projeto faz parte da construção de um portfólio voltado para desenvolvimento e administração de ambientes Mainframe.

O objetivo profissional é combinar conhecimentos de desenvolvimento com conhecimentos de operação e infraestrutura IBM Z, incluindo:

```text
COBOL
JCL
TSO
z/OS
VSAM
DB2
CICS
REXX
System Programming
Mainframe Operations
```

---

# 33. Evidências do laboratório

A seção de evidências poderá conter futuramente:

```text
docs/screenshots/
```

Sugestões:

* Login TSO;
* painel RFE;
* dataset `HERC01.COBOL.SRC`;
* membros COBOL;
* submissão de JCL;
* JES output;
* compilação;
* execução;
* resultados;
* VSAM;
* logs;
* telas do TK4-.

---

# 34. Autor

**Paulo Henrique**

Projeto desenvolvido como laboratório prático de desenvolvimento e administração de sistemas Mainframe.

GitHub:

`https://github.com/phsmottanerd`

LinkedIn:

`https://www.linkedin.com/in/paulo-henrique-santana-motta-52475041a/`

---

# 35. Licença

Este projeto é destinado a fins educacionais, de estudo e demonstração profissional.

Caso uma licença formal seja adicionada ao repositório, esta seção deverá ser atualizada de acordo com a licença escolhida.

---

## MAINFRAME-BANKING-CORE

**COBOL + JCL + VSAM + TSO + MVS 3.8j + TK4-**

Um laboratório de engenharia de software Mainframe construído para transformar conhecimento teórico em experiência prática.

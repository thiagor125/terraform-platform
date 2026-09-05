# Terraform Platform Lab

Laboratório criado para praticar um fluxo completo utilizando Terraform, GitHub, HCP Terraform e AWS.

O código fica no GitHub, enquanto o HCP Terraform executa os planos, armazena o state e controla as alterações na infraestrutura.

A autenticação com a AWS utiliza OIDC e credenciais temporárias, sem armazenar chaves de acesso no repositório.

## Como funciona

GitHub  
↓  
HCP Terraform  
↓  
Plan e aprovação manual  
↓  
AWS  

Quando uma alteração é enviada para o GitHub, o HCP Terraform gera um novo plan. Após a revisão e aprovação manual, a alteração pode ser aplicada na AWS.

## Recursos criados

O workspace `aws-lab` gerencia uma estrutura de rede na região `us-east-1`:

- 1 VPC
- 2 subnets públicas
- 2 subnets privadas
- 1 Internet Gateway
- Tabelas de rotas públicas e privadas
- Associações das tabelas de rotas
- Rota pública para a Internet

## Estrutura do repositório

terraform-platform/  
├── platform/ — Configuração da plataforma e autenticação  
├── modules/ — Módulos reutilizáveis  
├── environments/  
│   └── aws/lab/ — Ambiente do laboratório AWS  
├── docs/ — Documentação  
└── .github/workflows/ — Formatação e validação do Terraform  

## Fluxo de alterações

Alteração no código  
↓  
Push para o GitHub  
↓  
Plan no HCP Terraform  
↓  
Revisão e aprovação  
↓  
Apply na AWS  

O apply automático está desativado. Toda alteração precisa ser revisada e aprovada manualmente no HCP Terraform.

O GitHub Actions é utilizado apenas para verificar a formatação e validar o código Terraform. Ele não cria nem remove recursos da AWS.

## Como destruir o laboratório

No HCP Terraform, acesse:

Workspaces → aws-lab → Settings → Destruction and deletion → Queue destroy plan

Revise os recursos que serão removidos antes de confirmar o destroy.

## Como reconstruir o laboratório

Depois que os recursos forem removidos, o ambiente pode ser criado novamente pelo caminho:

Workspaces → aws-lab → New run → Start run → Confirm & Apply

O HCP Terraform buscará a configuração no GitHub e recriará os recursos na AWS.

Os recursos de autenticação utilizados pelo HCP Terraform são mantidos separadamente. Dessa forma, a conexão com a AWS continua funcionando mesmo depois que o laboratório é destruído.

## Próximo passo

Utilizar este laboratório como base para uma futura implantação na Azure, mantendo o mesmo modelo:

- Código versionado no GitHub
- Execuções e state no HCP Terraform
- Autenticação sem credenciais permanentes
- Módulos reutilizáveis
- Ambientes separados
- Revisão e aprovação antes das alterações

#Infraestrutura AWS com Terraform.
O projeto original apresenta um código em terraform responsável por provisionar a configuração de infraestrutura necessária para uma instância EC2 Debian, utilizando recursos e serviços da plataforma AWS. Observando oportunidades de melhoria no código fornecido, foram realizadas algumas mudanças pertinentes.

## Descrição Técnica Original

### 1. **Provider AWS**:
   - Define a região us-east-1 para o provisionamento dos recursos na AWS.

### 2. **Variáveis**:
   - projeto: Define o nome do projeto, com valor padrão VExpenses.
   - candidato: Define o nome do candidato, com valor padrão SeuNome.

### 3. **Geração de Chave Privada (TLS)**:
   - Gera uma chave privada RSA de 2048 bits para acessar a instância EC2.

### 4. **Par de Chaves EC2**:
   - Cria um par de chaves EC2 utilizando a chave pública derivada da chave privada gerada anteriormente.

### 5. **VPC (Virtual Private Cloud)**:
   - Cria uma VPC com o bloco CIDR 10.0.0.0/16, habilitando suporte para DNS e nomes DNS.

### 6. **Sub-rede (Subnet)**:
   - Cria uma sub-rede associada à VPC, com o bloco CIDR 10.0.1.0/24 e localizada na zona de disponibilidade us-east-1a.

### 7. **Internet Gateway**:
   - Provisiona um gateway de internet associado à VPC, permitindo que os recursos dentro da VPC tenham acesso à internet.

### 8. **Tabela de Rotas**:
   - Cria uma tabela de rotas associada à VPC, definindo uma rota padrão (0.0.0.0/0) que direciona o tráfego para o gateway de internet.

### 9. **Associação de Tabela de Rotas**:
   - Associa a tabela de rotas à sub-rede criada.

### 10. **Grupo de Segurança**:
   - Cria um grupo de segurança permitindo tráfego SSH (porta 22) de qualquer lugar (0.0.0.0/0) e todo o tráfego de saída.

### 11. **Busca de AMI Debian**:
   - Usa um data source para buscar a AMI mais recente do Debian 12 com virtualização HVM.

### 12. **Instância EC2**:
   - Cria uma instância EC2 do tipo t2.micro, utilizando a AMI Debian 12 e associada à sub-rede, par de chaves e grupo de segurança. A instância tem um bloco de dispositivo raiz com 20GB de armazenamento e tipo de volume gp2.

### 13. **User Data (Script de Inicialização)**:
   - Executa um script no boot da instância que atualiza e faz o upgrade do sistema operacional.

### 14. **Outputs**:
   - private_key: Exibe a chave privada gerada para o acesso à instância EC2.
   - ec2_public_ip: Exibe o endereço IP público da instância EC2.

---

## Melhorias Aplicadas

### 1. **Segurança no SSH**:
   - O acesso SSH foi restrito a um IP confiável (por exemplo, o IP do administrador), substituindo o uso de 0.0.0.0/0, que permite acesso irrestrito de qualquer lugar. Isso melhora a segurança contra acessos não autorizados.
   
   
hcl
   cidr_blocks = var.allowed_ssh_ips

   >[allowed_ssh_ips] armazena seu endereço IP Público.

### 2. **Instalação automática do NGINX:**:
   - Através do script userdata que antes era responsável apenas pela atualização e upgrade do sistema operacional, agora é possível instalar o NGINX logo no boot da instância. Isso garante uma máquina com um servidor web básico já disponível assim que a instância está em funcionamento.
    
       
bash
      # Atualiza pacotes e instala o NGINX
      apt-get update -y
      apt-get upgrade -y
      apt-get install -y nginx
      systemctl start nginx
      systemctl enable nginx


### 3. **Acesso web**:
   - O código original permitia somente o tráfego de dados via ssh, visando permitir o acesso de convidados através da web, foram implementadas regras de segurança responsáveis por provir o acesso as portas: HTTP (80) e HTTPS (443). Isso torna a instância EC2 capaz de servir páginas web através do NGINX.

hcl
   ingress {
    description = "Permite HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Permite HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


### 4. **Modularização do código**:
   - Para facilitar a manutenção a reusabilidade do código, o arquivo main foi dividido em outros arquivos que podem ser geridos de forma idependente. Essa nova organização de arquivos garante uma maior clareza sobre o projeto em geral, além de facilitar os processos de manutenção e teste.

   
terraform/
   ├── main.tf            # Definição dos recursos
   ├── variables.tf       # Variáveis personalizáveis
   ├── outputs.tf         # Saídas dos recursos
   ├── provider.tf        # Configuração do provedor
   └── userdata.sh        # Script de inicialização


---

## Executando o projeto

### Requisitos
- Conta ativa na **AWS**
- **Terraform** instalado na máquina local
- **CLI da AWS** configurada (Recomendável)

### Como rodar o projeto
#### 1. Clonar o repositório 
bash
   git clone https://github.com/Fr1edrichGauss/Desafio_DevOps.git
   cd Desafio_Devops

#### 2. Inicializar o Terraform
bash
   terraform init

#### 3. Fazer a verificação do plano de execução do código
bash 
   terraform plan

#### 4. Aplicar o plano para criar a infraestrutura
bash
   terraform apply

> Será necessário digitar "yes" no prompt para prosseguir com a criação da infraestrutura configurada.
#### 5. Acessar a instância EC2 criada via SSH
bash
   ssh -i key.pem admin@$(terraform output -raw ec2_public_ip)

#### 6. Verificar NGINX
bash
   systemctl status nginx

#### 7. Acessar a instância via HTTP
http://<EC2_PUBLIC_IP>

>Deve ser utilizado o IP público fornecido pelo output do Terraform, caso o NGINX esteja instalado corretamente, será recebida a mensagem "Welcome to nginx!"

### Limpeza de recursos
- Após testar e validar a funcionalidade da instância criada, é indicado a limpeza dos recursos que não serão mais necessários para evitar cobranças inesperadas.
bash 
   terraform destroy

> Com esse comando toda a infraestrutura e recursos da AWS seram destruídos (liberados). para confirmar a destruição devemos digitar "yes" no prompt.

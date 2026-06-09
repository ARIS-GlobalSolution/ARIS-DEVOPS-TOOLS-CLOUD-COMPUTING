# Guia de Implantação e Execução da API ARIS

## Visão Geral

Este projeto consiste em uma API REST desenvolvida com Java e Spring Boot, implantada em uma Máquina Virtual Ubuntu na Microsoft Azure utilizando Docker e Docker Compose.

A infraestrutura é criada automaticamente através de um script de provisionamento (`ScriptDevops.sh`), responsável por configurar os recursos da Azure, instalar o Docker, criar os containers da aplicação e do banco de dados PostgreSQL e disponibilizar a API para acesso externo.

---

# Pré-requisitos

Antes de iniciar a implantação, é necessário possuir:

* Conta Microsoft Azure ativa;
* Azure CLI instalada e configurada;
* Permissão para criação de recursos na Azure;
* Arquivo `ScriptDevops.sh`;
* Conexão com a internet.

---

# Passo 1 – Enviar o Script para a Azure

Após acessar o Azure Cloud Shell ou a Máquina Virtual criada, faça o upload do arquivo:

```bash
ScriptDevops.sh
```

para o diretório desejado.

Você pode verificar se o arquivo foi enviado corretamente utilizando:

```bash
ls
```

---

# Passo 2 – Conceder Permissão de Execução

Por padrão, arquivos `.sh` não possuem permissão para execução.

Execute o comando abaixo:

```bash
chmod +x ScriptDevops.sh
```

Este comando torna o script executável pelo sistema operacional Linux.

---

# Passo 3 – Executar o Script

Após conceder a permissão, execute:

```bash
./ScriptDevops.sh
```

Durante a execução, o script realizará automaticamente:

### Criação da infraestrutura Azure

* Resource Group
* Virtual Network (VNet)
* Subnet
* Network Security Group (NSG)
* Máquina Virtual Ubuntu

### Configuração de segurança

Liberação das portas:

| Porta | Função     |
| ----- | ---------- |
| 22    | SSH        |
| 80    | HTTP       |
| 8080  | API REST   |
| 8081  | Swagger    |
| 5432  | PostgreSQL |

### Instalação do Docker

O script instala automaticamente:

* Docker Engine
* Docker Compose
* Dependências necessárias do Ubuntu

### Deploy da aplicação

Após a instalação do Docker:

* Clonagem do repositório GitHub;
* Criação dos containers;
* Configuração da rede Docker;
* Inicialização do PostgreSQL;
* Inicialização da API Spring Boot.

---

# Verificando os Containers

Para confirmar que os containers foram iniciados corretamente:

```bash
sudo docker ps
```

A saída deverá apresentar dois containers em execução:

* aris-java-api-rm566059
* aris-postgres-rm566059

---

# Acessando a Aplicação

Após a conclusão do deploy, obtenha o IP público da Máquina Virtual.

Com o IP em mãos, a API poderá ser acessada através do endereço:

```text
http://IP_DA_VM:8080
```

Exemplo:

```text
http://20.10.100.50:8080
```

---

# Acessando o Swagger

A documentação da API é disponibilizada através do Swagger.

Acesse:

```text
http://IP_DA_VM:8081/swagger-ui.html
```

ou

```text
http://IP_DA_VM:8081/swagger-ui/index.html
```

dependendo da versão utilizada pelo Springdoc.

---

# Testando os Endpoints

Dentro do Swagger será possível:

* Visualizar todos os endpoints disponíveis;
* Consultar dados cadastrados;
* Inserir novos registros;
* Atualizar informações existentes;
* Excluir registros.

Ou seja, realizar todas as operações CRUD (Create, Read, Update e Delete) diretamente pela interface gráfica.
<img width="1680" height="936" alt="GlobalSolutionDevops" src="https://github.com/user-attachments/assets/88987cd4-2950-44b5-a2de-6e9048d1eff5" />

---

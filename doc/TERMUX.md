# Paperclip no Termux

Esta versão adiciona um caminho de execução pensado para Android/Termux. Ela não usa `systemd`, `launchd`, Docker ou o PostgreSQL embutido do Paperclip. Em vez disso, instala PostgreSQL nativo do Termux, mantém os dados em `$PREFIX/var/lib/paperclip` e executa o servidor em primeiro plano.

## Requisitos

Use o [Termux oficial do F-Droid](https://f-droid.org/packages/com.termux/) ou do GitHub. A versão do Node.js precisa atender ao requisito do projeto (`node --version` deve ser **24.11 ou superior**). Se o repositório do Termux ainda oferecer uma versão mais antiga, atualize o Termux e aguarde a atualização do pacote `nodejs-lts`.

## Instalação

```sh
git clone https://github.com/Carlos8781/paperclip-termux.git
cd paperclip-termux
chmod +x scripts/termux-*.sh
./scripts/termux-install.sh
```

O instalador cria um banco PostgreSQL local e uma configuração com armazenamento em disco local. A instalação pode demorar porque o workspace é um monorepo grande.

## Execução

```sh
./scripts/termux-start.sh
```

Abra `http://127.0.0.1:3100` no navegador do telefone. Para acessar de outro aparelho na mesma rede Wi-Fi, descubra o IP do telefone com `ip addr` e abra `http://IP_DO_TELEFONE:3100`. O servidor fica em foreground de propósito; isso evita depender de um supervisor ausente no Android.

Para parar o servidor, pressione `Ctrl+C`. Para parar também o banco PostgreSQL:

```sh
./scripts/termux-stop.sh
```

## Diretórios e variáveis

| Variável | Padrão | Uso |
| --- | --- | --- |
| `PAPERCLIP_HOME` | `$PREFIX/var/lib/paperclip` | Dados, configuração, logs e uploads |
| `PAPERCLIP_PGDATA` | `$PREFIX/var/lib/postgresql` | Cluster PostgreSQL |
| `PAPERCLIP_PGPORT` | `5432` | Porta do banco |
| `PAPERCLIP_BIND` | `lan` | `lan` permite acesso na rede local; use `loopback` para somente o telefone |
| `PORT` | `3100` | Porta do dashboard |

Exemplo somente local:

```sh
PAPERCLIP_BIND=loopback HOST=127.0.0.1 ./scripts/termux-start.sh
```

## Agentes

O Paperclip coordena agentes externos. Cada agente CLI (por exemplo, Claude Code, Codex, Gemini ou OpenCode) precisa estar instalado separadamente e disponível no `PATH` do Termux. Adaptadores HTTP/webhook e agentes remotos são normalmente mais simples no Android.

## Limitações conhecidas

O Android pode suspender processos em segundo plano e encerrar o Termux por economia de bateria. Para uso contínuo, desative a otimização de bateria do Termux e considere o add-on Termux:Boot. A execução por rede local não é uma publicação pública segura; não exponha a porta diretamente à internet sem autenticação e uma camada de rede apropriada.

O script não tenta instalar serviço de boot automaticamente. Isso é intencional: a inicialização automática depende do seu modelo de telefone e do add-on Termux:Boot.

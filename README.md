
# Fake Shop

Ambiente padronizado para desenvolvimento (DevContainer) e produção (Docker Compose), com separação de imagens/arquivos e variáveis de ambiente.

## Pré-requisitos
- Docker e Docker Compose
- Visual Studio Code
- Extensão “Dev Containers” (ms-vscode-remote.remote-containers)

## Estrutura relevante
- Dockerfile → imagem de produção (menor e mais segura)
- .devcontainer/Dockerfile.dev → imagem de desenvolvimento (debug/hot-reload)
- compose.yml → orquestração de produção (app + PostgreSQL)
- .devcontainer/docker-compose.override.yml → ajustes para desenvolvimento (bind-mount, debug, hot-reload)
- .devcontainer/devcontainer.json → configuração do DevContainer (extensões, portas, env)

## Variáveis de ambiente (principais)
- FLASK_ENV: development (dev) | production (prod)
- FLASK_APP: arquivo de inicialização (ex.: index.py)
- DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME: conexão PostgreSQL
- PROMETHEUS_MULTIPROC_DIR: diretório para métricas multiprocess (use “/tmp/metrics”)

Dica: você pode usar um arquivo .env e referenciá-lo no compose.yml (env_file).

---

## Como rodar em produção (compose.yml)
1) Build e subida:
```bash
docker compose -f compose.yml up -d --build
```

2) Acompanhar logs:
```bash
docker compose -f compose.yml logs -f
```

3) Acesso:
- API: http://localhost:5000
- O serviço do banco usa rede interna; evite expor 5432 externamente em produção, a menos que precise.
- Se for expor o banco configure no compose.yml
  ```compose
  services:
  db:
    ports:
      - "5432:5432"
  ```

4) Parar e remover:
```bash
docker compose -f compose.yml down
# Para também remover volume de dados:
docker compose -f compose.yml down -v
```

Observações:
- O serviço db tem healthcheck e o app aguarda o banco antes de iniciar.
- A imagem de produção roda como usuário não-root e cria /tmp/metrics (PROMETHEUS_MULTIPROC_DIR).

---

## Como rodar em desenvolvimento (DevContainer)
O DevContainer combina o compose.yml (raiz) com .devcontainer/docker-compose.override.yml para ativar hot-reload, bind-mount do código e debug.

Passos:
1) Abra a pasta do projeto no VS Code.
2) Pressione F1 e escolha: “Dev Containers: Reopen in Container”.
   - Alternativa: “Dev Containers: Rebuild and Reopen in Container” após alterações de Dockerfile/compose.
3) O VS Code conectará ao serviço ecommerce e instalará dependências (postCreateCommand).
4) Acesse a app em http://localhost:5000 (porta encaminhada).
5) Banco: disponível no serviço db (porta 5432 encaminhada no dev).

No DevContainer:
- Hot-reload do Flask ativo (montagem do volume .:/app).
- PROMETHEUS_MULTIPROC_DIR=/tmp/metrics configurado.
- O serviço aguarda o Postgres (healthcheck + wait script) e aplica migrações (se configurado).

---

## Extensões VS Code (carregadas automaticamente no DevContainer)
- Python (ms-python.python): https://marketplace.visualstudio.com/items?itemName=ms-python.python
- Pylance (ms-python.vscode-pylance): https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance
- REST Client (humao.rest-client): https://marketplace.visualstudio.com/items?itemName=humao.rest-client
- Docker (ms-azuretools.vscode-docker): https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker

---

## Missão (o que foi implementado)
- DevContainer para o Fake Shop (Python/Flask)
- Dois Dockerfiles:
  - .devcontainer/Dockerfile.dev (dev/debug)
  - Dockerfile (produção otimizada)
- compose.yml (produção)
- .devcontainer/docker-compose.override.yml (ajustes de desenvolvimento)
- Variáveis de ambiente separadas para dev e prod
- Extensões VS Code adicionadas no DevContainer
- Documentação de uso (este README)

# clear-up-linux.sh - Script de Limpeza de Disco para Ubuntu/Linux

## Descrição

Script completo para limpeza de disco em sistemas Ubuntu/Linux que remove logs, arquivos temporários, cache de desenvolvimento, pacotes órfãos, core dumps e muito mais — liberando espaço em disco de forma segura e eficiente.

## Recursos

### Limpeza Abrangente (20+ categorias)
- **Logs do sistema**: `*.log`, `log*`, logs rotacionados, logs compactados antigos
- **Cache de pacotes**: APT cache, pacotes não utilizados, listas do APT
- **Arquivos temporários**: `/tmp`, `/var/tmp`, `*.tmp`, `*.temp`, arquivos de backup de editores
- **Cache de aplicativos**: Firefox, Chrome, thumbnails, lixeira dos usuários
- **Kernels antigos**: Remoção segura de kernels não utilizados
- **Docker**: Containers, imagens, volumes, redes, build cache e system prune
- **Snap**: Versões antigas de snap packages
- **aaPanel**: Logs, backups, lixeira, cache web, sessões PHP, binary logs MySQL, logs PostgreSQL/Nginx/PHP, diretórios de teste, Redis src, arquivos de instalação
- **Journal do systemd**: Logs do sistema limitados (últimas 24 horas, máximo 100MB)
- **Caches de desenvolvimento**: pip, npm, yarn, pnpm, Cargo (Rust), Go, Gradle, Maven, Composer (PHP), NuGet (.NET), Gem (Ruby), `__pycache__`, virtualenvs
- **Flatpak**: Runtimes e refs não utilizados
- **Core dumps e crash reports**: systemd coredumps, `/var/crash`, Apport, core files soltos
- **Pacotes órfãos**: Configurações residuais (dpkg `rc`), pacotes órfãos (deborphan)
- **Locales não utilizados**: localepurge, cache de fontes, man pages de idiomas
- **Swap e memória**: Limpeza de PageCache/dentries/inodes, reset seguro de swap
- **Filas de email**: Postfix, Exim, logs de mail
- **Arquivos grandes**: Identificação de ISOs, IMGs, VMDKs, logs > 500MB
- **Arquivos antigos do sistema**: `.dpkg-old`, `.dpkg-new`, `.ucf-old`, `.bak`, backups em `/var/backups` (> 30 dias)
- **Caches do sistema**: ldconfig, APT lists, PackageKit, cache de ícones
- **BleachBit**: Limpeza profunda com instalação automática

### Segurança
- **Modo simulação**: `--dry-run` para preview seguro
- **Modo interativo**: Confirmação antes de remoções críticas (swap, kernels, backups)
- **Verificação de root**: Exige privilégios administrativos
- **Backup automático**: Logs importantes são limpos (conteúdo truncado), não removidos
- **Verificação de RAM**: Swap só é limpo se houver RAM livre suficiente

### Recursos Avançados
- **Relatório detalhado**: Espaço liberado e operações realizadas
- **Modo verbose**: Feedback completo do processo
- **Contador de arquivos**: Estatísticas precisas de limpeza
- **Cálculo de tamanho**: Informação de espaço antes/depois
- **Detecção automática**: Verifica se cada ferramenta/serviço está instalado antes de agir

## Instalação

```bash
# Baixar o script
wget https://raw.githubusercontent.com/afonsoft/agents-skills/main/clear-up-linux.sh

# Tornar executável
chmod +x clear-up-linux.sh

# Mover para diretório do sistema (opcional)
sudo mv clear-up-linux.sh /usr/local/bin/clear-up-linux
```

## Uso

### Básico
```bash
# Execução padrão (requer sudo)
sudo ./clear-up-linux.sh

# Com ajuda
sudo ./clear-up-linux.sh --help
```

### Modo Seguro
```bash
# Simulação (não remove nada)
sudo ./clear-up-linux.sh --dry-run

# Simulação detalhada
sudo ./clear-up-linux.sh --dry-run --verbose
```

### Modo Avançado
```bash
# Execução detalhada
sudo ./clear-up-linux.sh --verbose

# Não-interativo (para automação/cron)
sudo ./clear-up-linux.sh --force

# Com BleachBit (instala automaticamente se necessário)
sudo ./clear-up-linux.sh --bleachbit

# Combinação completa
sudo ./clear-up-linux.sh --force --verbose --bleachbit
```

## Opções de Linha de Comando

| Opção | Abreviação | Descrição |
|-------|------------|-----------|
| `--help` | `-h` | Exibe mensagem de ajuda |
| `--dry-run` | `-d` | Simula a limpeza sem remover arquivos |
| `--verbose` | `-v` | Modo detalhado com feedback completo |
| `--force` | `-f` | Modo não-interativo (pula confirmações) |
| `--bleachbit` | `-b` | Instala e executa BleachBit para limpeza profunda |

## Estrutura de Limpeza

### 1. Logs do Sistema
```
/var/log/
├── *.log              # Logs de aplicativos
├── log*               # Logs com prefixo 'log'
├── *.log.*            # Logs rotacionados
├── *.gz, *.xz, *.bz2 # Logs compactados antigos (mantém 20 mais recentes)
├── syslog*            # Logs do sistema
├── auth.log*          # Logs de autenticação
├── kern.log*          # Logs do kernel
├── dpkg.log*          # Logs do dpkg
├── apt.log*           # Logs do apt
├── mail.log*          # Logs de email
└── mail.err*          # Erros de email
```

### 2. Cache e Temporários
```
/tmp/                  # Temporários do sistema
/var/tmp/              # Temporários persistentes
/var/cache/apt/        # Cache do APT
/var/lib/apt/lists/    # Listas de pacotes do APT
/var/cache/PackageKit/ # Cache do PackageKit
/home/*/.cache/        # Cache de aplicativos dos usuários
/home/*/.thumbnails/   # Cache de imagens
```

### 3. Cache de Aplicativos
```
/home/*/.cache/
├── google-chrome/     # Cache do Chrome
├── mozilla/firefox/   # Cache do Firefox
├── icon-cache/        # Cache de ícones
└── [outros apps]/     # Cache de outros aplicativos
```

### 4. Caches de Desenvolvimento
```
Python:
├── pip cache          # pip cache purge
├── __pycache__/       # Bytecode compilado
├── *.pyc              # Arquivos compilados
├── virtualenvs/       # Cache de virtualenvs
├── pipenv/            # Cache do Pipenv
└── pypoetry/          # Cache do Poetry

Node.js:
├── npm cache          # npm cache clean --force
├── yarn cache         # yarn cache clean
└── pnpm store         # pnpm store prune

Rust:
├── ~/.cargo/registry/cache/      # Cache de pacotes
├── ~/.cargo/registry/src/        # Código fonte de pacotes
└── ~/.cargo/git/checkouts/       # Checkouts Git

Go:
├── go cache           # go clean -cache
└── go mod cache       # go clean -modcache

Java:
├── ~/.gradle/caches/  # Cache do Gradle
└── ~/.m2/repository/  # Cache do Maven

Outros:
├── composer cache     # Composer (PHP)
├── nuget cache        # NuGet (.NET)
└── gem cache          # Gem (Ruby)
```

### 5. Docker (se instalado)
```
docker/
├── containers/        # Containers parados
├── images/            # Imagens não utilizadas
├── volumes/           # Volumes não utilizados
├── networks/          # Redes não utilizadas
├── builder/           # Build cache e histórico
└── system prune       # Limpeza completa do sistema
```

### 6. aaPanel (se instalado)
```
/www/
├── server/panel/logs/           # Logs do painel (error, request, access, panel)
├── wwwlogs/                     # Logs de sites
├── server/pgsql/data/           # Logs do PostgreSQL (data)
├── server/pgsql/logs/           # Logs do PostgreSQL (logs)
├── server/nginx/logs/           # Logs do Nginx
├── server/nginx/proxy_temp/     # Cache proxy Nginx
├── server/nginx/fastcgi_temp/   # Cache FastCGI Nginx
├── server/nginx/uwsgi_temp/     # Cache uWSGI Nginx
├── server/nginx/scgi_temp/      # Cache SCGI Nginx
├── server/nginx/src/            # Código fonte do Nginx
├── server/apache2/cache/        # Cache do Apache
├── server/panel/install/        # Arquivos de instalação (.rpm, .zip, .tar.gz)
├── backup/                      # Backups antigos (> 7 dias)
├── server/mysql/                # Binary logs e testes MySQL
├── server/pgsql/test/           # Testes PostgreSQL
├── server/redis/src/            # Código fonte do Redis
├── server/panel/recycle_bin/    # Lixeira do painel
├── server/php/*/var/log/        # Logs de PHP
├── tmp/                         # Sessões PHP (sess_*)
└── var/lib/php*/sessions/       # Sessões PHP
```

### 7. Core Dumps e Crash Reports
```
/var/lib/systemd/coredump/       # Coredumps do systemd
/var/crash/                      # Crash reports (Ubuntu/Debian)
/var/lib/apport/coredump/        # Apport coredumps
/                                # Arquivos core soltos (até 3 níveis)
```

### 8. Pacotes e Sistema
```
Pacotes órfãos:
├── dpkg 'rc' packages           # Pacotes com configurações residuais
└── deborphan                    # Pacotes órfãos (se disponível)

Arquivos residuais:
├── /etc/*.dpkg-old              # Configs antigas do dpkg
├── /etc/*.dpkg-new              # Configs novas do dpkg
├── /etc/*.dpkg-dist             # Configs distribuídas do dpkg
├── /etc/*.ucf-old               # Configs antigas do ucf
├── /etc/*.ucf-dist              # Configs distribuídas do ucf
├── /etc/*.old                   # Arquivos .old em /etc
├── /etc/*.bak                   # Arquivos .bak em /etc
└── /var/backups/ (> 30 dias)    # Backups antigos do sistema
```

### 9. Memória e Swap
```
Memória:
└── /proc/sys/vm/drop_caches     # Libera PageCache, dentries, inodes

Swap:
└── swapoff/swapon               # Reset do swap (verifica RAM livre)
```

### 10. Filas de Email
```
Postfix:
└── postsuper -d ALL             # Remove todos da fila

Exim:
└── exiqgrep + exim -Mrm         # Remove todos da fila
```

## Exemplo de Output

```
========================================
      clear-up-linux.sh - Limpeza de Disco
========================================

[INFO] Iniciando limpeza de disco...

=== Limpando Logs do Sistema ===
[INFO] Limpando: Logs do sistema (*.log)
[SUCCESS] Removidos 245 arquivos (1.2G)
[INFO] Limpando: Logs com prefixo 'log'
[SUCCESS] Removidos 32 arquivos (156M)

=== Limpando Cache do APT ===
[INFO] Cache do APT: 2.1G
[SUCCESS] Cache do APT limpo

=== Limpando Caches de Desenvolvimento ===
[INFO] Limpando cache do pip...
[SUCCESS] Cache do pip limpo
[INFO] Limpando cache do npm...
[SUCCESS] Cache do npm limpo
[INFO] Limpando cache do Cargo (Rust)...
[SUCCESS] Cache Cargo limpo: cache (340M)

=== Limpando Core Dumps e Crash Reports ===
[INFO] Limpando coredumps do systemd...
[SUCCESS] Coredumps do systemd removidos (89M)

=== Limpando Pacotes Órfãos e Configurações Residuais ===
[INFO] Pacotes com configurações residuais: 12
[SUCCESS] Pacotes residuais purgados: 12

=== Limpando Swap e Memória ===
[SUCCESS] Cache de memória do kernel liberado

========================================
           RELATÓRIO DE LIMPEZA
========================================

[SUCCESS] Limpeza concluída!
Operações realizadas: 25

[INFO] Espaço em disco antes/depois:
  /: 45G usado, 78G livre (37% usado)

[INFO] Sugestões adicionais:
  - Desinstale programas não utilizados
  - Mova arquivos grandes para armazenamento externo
  - Use ferramentas como bleachbit para limpeza profunda
  - Considere compactar arquivos antigos
```

## Requisitos

- **Sistema**: Ubuntu/Debian ou derivados (também suporta Fedora, CentOS, Arch para BleachBit)
- **Permissões**: Root/sudo obrigatório
- **Dependências**: Ferramentas padrão do sistema (find, du, df, free, sync, etc.)
- **Opcional**: BleachBit, localepurge, deborphan

## Avisos Importantes

### AVISO DE SEGURANÇA
- **Execute como root/sudo** para acesso completo aos arquivos do sistema
- **Faça backup** antes de executar em produção
- **Use --dry-run primeiro** para verificar o que será removido

### O que NÃO é removido
- Logs de segurança críticos (mantidos, conteúdo limpo)
- Arquivos de configuração do sistema
- Arquivos de usuário em `/home` (exceto caches)
- Kernels em uso atualmente
- Pacotes essenciais do sistema
- Configurações do aaPanel, sites e certificados SSL
- Bancos de dados (apenas logs e testes)
- Backups recentes (< 7 dias no aaPanel, < 30 dias em /var/backups)
- Módulos DKMS (podem ser necessários para o kernel)

### Segurança de Dados
- Arquivos importantes são apenas limpos (truncados), não removidos
- Kernels antigos, backups e swap requerem confirmação explícita no modo interativo
- Swap só é limpo quando há RAM livre suficiente
- Modo interativo ativado por padrão para operações críticas

## Docker Build Cache

O script limpa completamente o ambiente Docker incluindo:

### O que é limpo:
- **Containers parados**: `docker rm` para containers com status "exited"
- **Imagens não utilizadas**: `docker image prune -f`
- **Volumes não utilizados**: `docker volume prune -f`
- **Redes não utilizadas**: `docker network prune -f`
- **Build cache**: `docker builder prune -af`
- **Sistema completo**: `docker system prune -af`

### Build Cache Específico:
```bash
# Verificar tamanho do build cache
docker builder du

# O que o script faz automaticamente:
[INFO] Limpando histórico de build do Docker...
[INFO] Tamanho do build cache: 2.3GB
[SUCCESS] Histórico de build do Docker limpo
```

## aaPanel Cleaning

O script inclui limpeza completa para servidores com aaPanel (13 categorias):

### O que é limpo no aaPanel:
- **Logs do Painel**: error.log, request.log, access.log, panel.log
- **Logs de Sites**: Todos os logs em /www/wwwlogs/
- **Logs PostgreSQL**: Todos os logs do PostgreSQL aaPanel em múltiplos diretórios
- **Logs Nginx**: Todos os logs em /www/server/nginx/logs/
- **Binary Logs MySQL/MariaDB**: mysql-bin.*, relay-bin.*, logs de erro
- **Backups Antigos**: Arquivos com mais de 7 dias
- **Lixeira**: recycle_bin do painel e sistema
- **Cache Web**: Nginx proxy/fastcgi/uwsgi/scgi temp, src, Apache cache
- **Sessões PHP**: Arquivos sess_* em /tmp, /var/tmp e diretórios de sessões PHP 5/7/8
- **Logs PHP**: Logs de todas as versões PHP instaladas
- **Arquivos de Instalação**: .rpm, .zip, .tar.gz do painel
- **Diretórios de Teste**: mysql-test, pgsql/test e variantes
- **Diretório src do Redis**: Arquivos fonte do Redis

### Segurança Específica para aaPanel:
- **Backups**: Requer confirmação antes de remover (padrão: 7+ dias)
- **Binary Logs**: Avisado sobre impacto na replicação
- **Logs Ativos**: Apenas limpa conteúdo (truncate), preserva arquivos
- **Cache Web**: Remoção segura, não afeta funcionamento

### O que NÃO é removido:
- Configurações do painel
- Sites e arquivos de usuário
- Certificados SSL
- Bancos de dados (apenas logs)
- Backups recentes (< 7 dias)

## Caches de Desenvolvimento

O script detecta e limpa automaticamente caches de 11 ferramentas de desenvolvimento:

| Ferramenta | Comando | O que é limpo |
|------------|---------|---------------|
| **pip** (Python) | `pip cache purge` | Cache de pacotes baixados |
| **npm** | `npm cache clean --force` | Cache global do npm |
| **yarn** | `yarn cache clean` | Cache global do yarn |
| **pnpm** | `pnpm store prune` | Store não utilizado |
| **Cargo** (Rust) | rm registry/cache, registry/src, git/checkouts | Cache de compilação e dependências |
| **Go** | `go clean -cache -modcache` | Cache de compilação e módulos |
| **Gradle** (Java) | rm ~/.gradle/caches/ | Cache de build |
| **Maven** (Java) | rm ~/.m2/repository/ | Repositório local |
| **Composer** (PHP) | `composer clear-cache` | Cache de pacotes |
| **NuGet** (.NET) | `dotnet nuget locals all --clear` | Cache de pacotes NuGet |
| **Gem** (Ruby) | `gem cleanup` | Gems antigas não utilizadas |

Além disso:
- Remove diretórios `__pycache__` e arquivos `.pyc` em `/home`
- Limpa caches de virtualenvs (Pipenv, Poetry)

## BleachBit Integration

O script inclui integração com BleachBit para limpeza profunda do sistema:

### O que o BleachBit limpa:
- **Cache do sistema**: Arquivos temporários e cache de aplicações
- **Logs rotacionados**: Logs antigos e compactados
- **Resíduos do APT**: Pacotes não utilizados e cache
- **Histórico**: Histórico de navegação e documentos recentes
- **Lixeira**: Arquivos da lixeira do sistema
- **Memória swap**: Arquivos de swap temporários

### Modos de uso:
```bash
# Instalar e executar BleachBit automaticamente
sudo ./clear-up-linux.sh --bleachbit

# Simulação do BleachBit
sudo ./clear-up-linux.sh --bleachbit --dry-run

# Execução com BleachBit + verbose
sudo ./clear-up-linux.sh --bleachbit --verbose
```

### Instalação automática:
- **Detecção de distribuição**: Ubuntu, Debian, Fedora, CentOS, Arch
- **Gerenciador de pacotes**: APT, DNF, YUM, Pacman
- **Instalação silenciosa**: Sem interação do usuário
- **Execução imediata**: Após instalação, executa limpeza

## Personalização

### Adicionar Novos Padrões
Edite o script e adicione novas chamadas `remove_files()`:

```bash
# Exemplo: Limpar arquivos de backup específicos
remove_files "*.bak" "Arquivos de backup" "/home"
remove_files "*.old" "Arquivos antigos" "/etc"
```

### Excluir Diretórios
Para proteger diretórios específicos, modifique as funções:

```bash
# Exemplo: Pular diretório específico
if [[ "$dir" == "/home/protected" ]]; then
    log_verbose "Pulando diretório protegido: $dir"
    continue
fi
```

## Estatísticas Típicas

### Espaço Liberado (médio)
- **Logs**: 500MB - 2GB
- **Cache APT**: 200MB - 1GB
- **Temporários**: 100MB - 500MB
- **Cache Apps**: 300MB - 1.5GB
- **Cache Dev (pip/npm/cargo/etc.)**: 500MB - 5GB
- **Docker**: 1GB - 5GB (se usado)
- **aaPanel**: 2GB - 8GB (se instalado)
- **Core dumps**: 100MB - 2GB
- **Pacotes residuais**: 50MB - 500MB
- **Logs rotacionados antigos**: 200MB - 1GB
- **Total**: 5GB - 27GB+

### Tempo de Execução
- **Desktop normal**: 2-5 minutos
- **Server**: 5-15 minutos
- **Com Docker**: 10-20 minutos
- **Com aaPanel**: 15-25 minutos
- **Completo (com BleachBit)**: 20-35 minutos

## Automação

### Cron Job
```bash
# Adicionar ao crontab para execução semanal
sudo crontab -e

# Executar toda sexta-feira às 23:00
0 23 * * 5 /usr/local/bin/clear-up-linux --force >> /var/log/cleanup.log 2>&1
```

### Systemd Timer
```bash
# Criar serviço systemd
sudo tee /etc/systemd/system/cleanup.service > /dev/null <<EOF
[Unit]
Description=System Cleanup
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/clear-up-linux --force
EOF

# Criar timer
sudo tee /etc/systemd/system/cleanup.timer > /dev/null <<EOF
[Unit]
Description=Run cleanup weekly
Requires=cleanup.service

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Ativar timer
sudo systemctl enable cleanup.timer
sudo systemctl start cleanup.timer
```

## Troubleshooting

### Problemas Comuns

#### "Permissão negada"
```bash
# Solução: Execute com sudo
sudo ./clear-up-linux.sh
```

#### "Arquivo não encontrado"
```bash
# Solução: Verifique o caminho do script
ls -la clear-up-linux.sh
chmod +x clear-up-linux.sh
```

#### "Espaço não liberou"
```bash
# Solução: Verifique com --dry-run primeiro
sudo ./clear-up-linux.sh --dry-run --verbose

# Limpe manualmente arquivos grandes
sudo find / -type f -size +1G 2>/dev/null
```

#### "Swap não pode ser limpo"
```bash
# Verificar RAM livre vs swap em uso
free -m

# O script verifica automaticamente se há RAM livre suficiente
# Se não houver, pula a limpeza de swap com mensagem informativa
```

### Logs de Depuração
```bash
# Habilitar logging detalhado
sudo ./clear-up-linux.sh --verbose 2>&1 | tee cleanup.log

# Verificar o que foi feito
grep -E "(SUCCESS|WARNING|ERROR)" cleanup.log
```

## Contribuição

### Para Contribuir
1. Faça um fork do repositório
2. Crie uma branch para sua feature
3. Teste extensivamente com `--dry-run`
4. Faça um pull request

### Sugestões de Melhorias
- Suporte a outras distribuições
- Mais padrões de limpeza
- Integração com ferramentas existentes
- Interface gráfica (GUI)
- Agendamento automático na instalação

## Licença

Este script é distribuído sob licença MIT. Sinta-se livre para usar, modificar e distribuir.

## Suporte

- **Issues**: https://github.com/afonsoft/agents-skills/issues
- **Discussions**: https://github.com/afonsoft/agents-skills/discussions
- **Email**: afonsoft@gmail.com

---

**Dica Final**: Sempre execute com `--dry-run` primeiro para entender o que será removido antes de executar a limpeza real!

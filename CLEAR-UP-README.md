# clear-up.sh - Script de Limpeza de Disco para Ubuntu/Linux

## 📋 Descrição

Script completo para limpeza de disco em sistemas Ubuntu/Linux que remove logs, arquivos temporários, cache e libera espaço em disco de forma segura e eficiente.

## 🚀 Recursos

### 🗑️ **Limpeza Abrangente**
- **Logs do sistema**: `*.log`, `log*`, logs rotacionados
- **Cache de pacotes**: APT cache, pacotes não utilizados
- **Arquivos temporários**: `/tmp`, `/var/tmp`, `*.tmp`, `*.temp`
- **Cache de aplicativos**: Firefox, Chrome, thumbnails
- **Kernels antigos**: Remoção segura de kernels não utilizados
- **Docker**: Containers, imagens, volumes, redes e build cache não utilizados
- **Snap**: Versões antigas de snap packages
- **aaPanel**: Logs, backups, lixeira, cache e binary logs
- **Journal do systemd**: Logs do sistema limitados

### 🛡️ **Segurança**
- **Modo simulação**: `--dry-run` para preview seguro
- **Modo interativo**: Confirmação antes de remoções críticas
- **Verificação de root**: Exige privilégios administrativos
- **Backup automático**: Logs importantes são limpos, não removidos

### 📊 **Recursos Avançados**
- **Relatório detalhado**: Espaço liberado e operações realizadas
- **Modo verbose**: Feedback completo do processo
- **Contador de arquivos**: Estatísticas precisas de limpeza
- **Cálculo de tamanho**: Informação de espaço antes/depois

## 📦 Instalação

```bash
# Baixar o script
wget https://raw.githubusercontent.com/afonsoft/agents-skills/main/clear-up.sh

# Tornar executável
chmod +x clear-up.sh

# Mover para diretório do sistema (opcional)
sudo mv clear-up.sh /usr/local/bin/clear-up
```

## 🎯 Uso

### Básico
```bash
# Execução padrão (requer sudo)
sudo ./clear-up.sh

# Com ajuda
sudo ./clear-up.sh --help
```

### Modo Seguro
```bash
# Simulação (não remove nada)
sudo ./clear-up.sh --dry-run

# Simulação detalhada
sudo ./clear-up.sh --dry-run --verbose
```

### Modo Avançado
```bash
# Execução detalhada
sudo ./clear-up.sh --verbose

# Não-interativo (para automação)
sudo ./clear-up.sh --force
```

## 🗂️ Estrutura de Limpeza

### 1. **Logs do Sistema**
```
/var/log/
├── *.log              # Logs de aplicativos
├── log*               # Logs com prefixo 'log'
├── *.log.*            # Logs rotacionados
├── syslog*            # Logs do sistema
├── auth.log*          # Logs de autenticação
├── kern.log*          # Logs do kernel
├── dpkg.log*          # Logs do dpkg
└── apt.log*           # Logs do apt
```

### 2. **Cache e Temporários**
```
/tmp/                  # Temporários do sistema
/var/tmp/              # Temporários persistentes
/var/cache/apt/        # Cache do APT
/home/*/.cache/        # Cache de aplicativos
/home/*/.thumbnails/   # Cache de imagens
```

### 3. **Cache de Aplicativos**
```
/home/*/.cache/
├── google-chrome/     # Cache do Chrome
├── mozilla/firefox/   # Cache do Firefox
└── [outros apps]/     # Cache de outros aplicativos
```

### 4. **Docker (se instalado)**
```
docker/
├── containers/        # Containers parados
├── images/           # Imensões não utilizadas
├── volumes/          # Volumes não utilizados
├── networks/         # Redes não utilizadas
└── builder/          # Build cache e histórico
```

### 5. **aaPanel (se instalado)**
```
/www/
├── server/panel/logs/        # Logs do painel
├── wwwlogs/                  # Logs de sites
├── server/nginx/logs/        # Logs do Nginx
├── server/panel/install/     # Arquivos de instalação
├── backup/                   # Backups antigos
├── server/mysql/             # Binary logs e testes
├── server/pgsql/              # Testes PostgreSQL
├── server/panel/recycle_bin/ # Lixeira
├── server/*/cache/           # Cache web/PHP (incluindo nginx/src)
├── tmp/                      # Sessões PHP (sess_*)
├── var/lib/php*/sessions/    # Sessões PHP
├── var/lib/mysql/mysql-test/  # Testes MySQL
└── var/lib/pgsql/test/        # Testes PostgreSQL
```

## 📈 Exemplo de Output

```
========================================
      clear-up.sh - Limpeza de Disco
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

=== Limpando Arquivos Temporários ===
[WARNING] DIRETÓRIO: /tmp/* (1.8G) seria removido
[SUCCESS] Removido: /tmp/* (1.8G)

========================================
           RELATÓRIO DE LIMPEZA
========================================

[SUCCESS] Limpeza concluída!
Operações realizadas: 15

[INFO] Espaço em disco antes/depois:
  /: 45G usado, 78G livre (37% usado)

[INFO] Sugestões adicionais:
  - Desinstale programas não utilizados
  - Mova arquivos grandes para armazenamento externo
  - Use ferramentas como bleachbit para limpeza profunda
  - Considere compactar arquivos antigos
```

## ⚙️ Opções de Linha de Comando

| Opção | Descrição |
|-------|-----------|
| `--help, -h` | Exibe mensagem de ajuda |
| `--dry-run, -d` | Simula a limpeza sem remover arquivos |
| `--verbose, -v` | Modo detalhado com feedback completo |
| `--force, -f` | Modo não-interativo (pula confirmações) |

## 🔧 Requisitos

- **Sistema**: Ubuntu/Debian ou derivados
- **Permissões**: Root/sudo obrigatório
- **Dependências**: Ferramentas padrão do sistema (find, du, df, etc.)

## 🚨 Avisos Importantes

### ⚠️ **AVISO DE SEGURANÇA**
- **Execute como root/sudo** para acesso completo aos arquivos do sistema
- **Faça backup** antes de executar em produção
- **Use --dry-run primeiro** para verificar o que será removido

### 📝 **O que NÃO é removido**
- Logs de segurança críticos (mantidos, conteúdo limpo)
- Arquivos de configuração
- Arquivos de usuário em `/home`
- Kernels em uso atualmente
- Pacotes essenciais do sistema

### 🔒 **Segurança de Dados**
- Arquivos importantes são apenas limpos, não removidos
- Kernels antigos requerem confirmação explícita
- Modo interativo por padrão para operações críticas

## � Docker Build Cache

O script agora limpa completamente o ambiente Docker incluindo:

#### **O que é limpo:**
- **Containers parados**: `docker rm` para containers com status "exited"
- **Imensões não utilizadas**: `docker image prune -f`
- **Volumes não utilizados**: `docker volume prune -f`
- **Redes não utilizadas**: `docker network prune -f`
- **Build cache**: `docker builder prune -af` (novo!)
- **Sistema completo**: `docker system prune -af`

#### **Build Cache Específico:**
```bash
# Verificar tamanho do build cache
docker builder du

# Limpar manualmente (se necessário)
docker builder prune -af

# O que o script faz automaticamente:
[INFO] Limpando histórico de build do Docker...
[INFO] Tamanho do build cache: 2.3GB
[SUCCESS] Histórico de build do Docker limpo
```

#### **Por que limpar o build cache?**
- **Economia de espaço**: Build cache pode ocupar vários GB
- **Performance**: Cache antigo pode desacelerar builds
- **Segurança**: Remove artefatos de builds anteriores
- **Consistência**: Fresh builds sem resíduos

## 🖥️ aaPanel Cleaning

O script agora inclui limpeza completa para servidores com aaPanel:

#### **O que é limpo no aaPanel:**
- **Logs do Painel**: error.log, request.log, access.log, panel.log
- **Logs de Sites**: Todos os logs em /www/wwwlogs/
- **Logs Nginx**: Todos os logs em /www/server/nginx/logs/
- **Binary Logs MySQL/MariaDB**: mysql-bin.*, relay-bin.*
- **Backups Antigos**: Arquivos com mais de 7 dias
- **Lixeira**: recycle_bin do painel e sistema
- **Cache Web**: Nginx/Apache proxy, fastcgi, uwsgi cache e src
- **Sessões PHP**: Arquivos sess_* em /tmp e diretórios de sessões
- **Arquivos de Instalação**: .rpm, .zip, .tar.gz do painel
- **Diretórios de Teste**: mysql-test, pgsql/test e variantes
- **Logs PHP**: Logs de todas as versões PHP instaladas
- **Análise de Espaço**: Top 10 maiores consumidores em /www

#### **Comandos Manuais Equivalentes:**
```bash
# Limpar logs do painel
echo "" > /www/server/panel/logs/error.log
echo "" > /www/server/panel/logs/request.log

# Limpar logs de sites
truncate -s 0 /www/wwwlogs/*.log

# Limpar logs do Nginx
truncate -s 0 /www/server/nginx/logs/*.log

# Remover todos os logs do painel
rm -rf /www/server/panel/logs/*

# Remover sessões PHP
find /tmp -name "sess_*" -type f -delete
find /var/lib/php/sessions -name "sess_*" -type f -delete

# Remover diretório src do Nginx
rm -rf /www/server/nginx/src

# Remover arquivos de instalação do painel
rm -rf /www/server/panel/install/*.rpm
rm -rf /www/server/panel/install/*.zip
rm -rf /www/server/panel/install/*.tar.gz

# Remover diretórios de teste de bancos de dados
rm -rf /www/server/mysql/mysql-test
rm -rf /www/server/pgsql/test
rm -rf /var/lib/mysql/mysql-test
rm -rf /var/lib/pgsql/test

# Remover binary logs (cuidado!)
rm -f /www/server/mysql/mysql-bin.*

# Esvaziar lixeira
rm -rf /www/server/panel/recycle_bin/*

# Analisar espaço
du -h /www --max-depth=2 | sort -hr | head -n 10
```

#### **Segurança Específica para aaPanel:**
- **Backups**: Requer confirmação antes de remover (padrão: 7+ dias)
- **Binary Logs**: Avisado sobre impacto na replicação
- **Logs Ativos**: Apenas limpa conteúdo, preserva arquivos
- **Cache Web**: Remoção segura, não afeta funcionamento

#### **O que NÃO é removido:**
- Configurações do painel
- Sites e arquivos de usuário
- Certificados SSL
- Bancos de dados (apenas logs)
- Backups recentes (< 7 dias)

## 🛠️ Personalização

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

## 📊 Estatísticas Típicas

### Espaço Liberado (médio)
- **Logs**: 500MB - 2GB
- **Cache APT**: 200MB - 1GB  
- **Temporários**: 100MB - 500MB
- **Cache Apps**: 300MB - 1.5GB
- **Docker**: 1GB - 5GB (se usado)
- **aaPanel**: 2GB - 8GB (se instalado)
- **Total**: 4GB - 18GB

### Tempo de Execução
- **Desktop normal**: 2-5 minutos
- **Server**: 5-15 minutos
- **Com Docker**: 10-20 minutos
- **Com aaPanel**: 15-25 minutos

## 🔄 Automação

### Cron Job
```bash
# Adicionar ao crontab para execução semanal
sudo crontab -e

# Executar toda sexta-feira às 23:00
0 23 * * 5 /usr/local/bin/clear-up --force >> /var/log/cleanup.log 2>&1
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
ExecStart=/usr/local/bin/clear-up --force
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

## 🐛 Troubleshooting

### Problemas Comuns

#### "Permissão negada"
```bash
# Solução: Execute com sudo
sudo ./clear-up.sh
```

#### "Arquivo não encontrado"
```bash
# Solução: Verifique o caminho do script
ls -la clear-up.sh
chmod +x clear-up.sh
```

#### "Espaço não liberou"
```bash
# Solução: Verifique com --dry-run primeiro
sudo ./clear-up.sh --dry-run --verbose

# Limpe manualmente arquivos grandes
sudo find / -type f -size +1G 2>/dev/null
```

### Logs de Depuração
```bash
# Habilitar logging detalhado
sudo ./clear-up.sh --verbose 2>&1 | tee cleanup.log

# Verificar o que foi feito
grep -E "(SUCCESS|WARNING|ERROR)" cleanup.log
```

## 📝 Contribuição

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

## 📄 Licença

Este script é distribuído sob licença MIT. Sinta-se livre para usar, modificar e distribuir.

## 🤝 Suporte

- **Issues**: https://github.com/afonsoft/agents-skills/issues
- **Discussions**: https://github.com/afonsoft/agents-skills/discussions
- **Email**: afonsoft@gmail.com

---

**⚡ Dica Final**: Sempre execute com `--dry-run` primeiro para entender o que será removido antes de executar a limpeza real!

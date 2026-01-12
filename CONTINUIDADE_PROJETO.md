# 📦 Foundry ERP - Guia de Continuidade do Projeto

## 🔗 Download do Projeto Completo

**Arquivo de Backup**: [foundry_erp_completo_v3_final.tar.gz](https://www.genspark.ai/api/files/s/wJ7o02F4)  
**Tamanho**: 1.6 MB  
**Versão**: v3.0 Final  
**Data**: 09/12/2025

---

## 📋 Índice

1. [Visão Geral do Sistema](#visão-geral-do-sistema)
2. [Tecnologias Utilizadas](#tecnologias-utilizadas)
3. [Como Restaurar o Projeto](#como-restaurar-o-projeto)
4. [Estrutura do Projeto](#estrutura-do-projeto)
5. [Funcionalidades Implementadas](#funcionalidades-implementadas)
6. [Configurações Importantes](#configurações-importantes)
7. [Próximos Passos Recomendados](#próximos-passos-recomendados)
8. [Problemas Conhecidos](#problemas-conhecidos)
9. [Usuários de Teste](#usuários-de-teste)
10. [Comandos Úteis](#comandos-úteis)

---

## 🎯 Visão Geral do Sistema

**Foundry ERP** é um sistema completo de gestão para indústrias de fundição desenvolvido em Flutter, focado em controle de produção, análise espectrométrica, correção de ligas metalúrgicas e gestão de estoque.

### Principais Características

- ✅ **Sistema de Produção Hierárquico**: 8 etapas com sub-etapas
- ✅ **Persistência de Dados**: Hive para armazenamento local
- ✅ **Controle de Acesso**: 5 níveis hierárquicos de permissões
- ✅ **Correção Avançada**: Otimização de ligas metalúrgicas com IA
- ✅ **Análise Espectrométrica**: Gestão completa de análises químicas
- ✅ **Relatórios**: Exportação em PDF e CSV
- ✅ **Responsivo**: Material Design 3 otimizado para web e mobile

---

## 🛠️ Tecnologias Utilizadas

### Core

- **Flutter**: 3.35.4 (LOCKED - NÃO ATUALIZAR)
- **Dart**: 3.9.2 (LOCKED - NÃO ATUALIZAR)
- **Provider**: 6.1.5+1 (State Management)

### Armazenamento

- **Hive**: 2.2.3 (Document Database)
- **Hive Flutter**: 1.1.0
- **Shared Preferences**: 2.5.3 (Key-Value Storage)

### Firebase (Opcional - Ready)

- **Firebase Core**: 3.6.0
- **Cloud Firestore**: 5.4.3
- **Firebase Auth**: 5.3.1
- **Firebase Storage**: 12.3.2

### UI & Charts

- **FL Chart**: 0.69.0
- **Material Design**: 3.0

### Utilitários

- **Intl**: 0.19.0 (Internacionalização)
- **HTTP**: 1.5.0 (API Requests)
- **PDF**: 3.11.1 (Geração de PDFs)
- **CSV**: 6.0.0 (Exportação CSV)

---

## 🚀 Como Restaurar o Projeto

### Método 1: Restauração Completa (Linux/Mac)

```bash
# 1. Baixar o arquivo
wget https://www.genspark.ai/api/files/s/wJ7o02F4 -O foundry_erp_backup.tar.gz

# 2. Extrair para diretório home (restaura caminho absoluto)
tar -xzf foundry_erp_backup.tar.gz -C /

# 3. Navegar para o projeto
cd /home/user/flutter_app

# 4. Instalar dependências
flutter pub get

# 5. Executar análise (verificar erros)
flutter analyze

# 6. Rodar em modo web (preview)
flutter run -d chrome --web-renderer html

# 7. Build para produção web
flutter build web --release

# 8. Servir aplicação (porta 5060)
cd build/web && python3 -m http.server 5060 --bind 0.0.0.0
```

### Método 2: Extração Manual (Windows)

```bash
# 1. Baixar arquivo do link acima

# 2. Extrair com 7-Zip ou WinRAR

# 3. Copiar pasta flutter_app para seu diretório de trabalho

# 4. Abrir terminal no diretório do projeto

# 5. Executar:
flutter pub get
flutter run -d chrome
```

---

## 📁 Estrutura do Projeto

```
flutter_app/
├── lib/
│   ├── main.dart                          # Entry point + navegação
│   ├── models/                            # Modelos de dados
│   │   ├── usuario_model.dart            # Usuário + permissões
│   │   ├── ordem_producao_model.dart     # Ordem de produção
│   │   ├── etapa_producao_model.dart     # Etapas hierárquicas
│   │   ├── material_model.dart           # Materiais do estoque
│   │   ├── liga_metalurgica_model.dart   # Ligas metálicas
│   │   ├── analise_espectrometrica.dart  # Análises químicas
│   │   ├── permissao_model.dart          # Sistema de permissões
│   │   └── ...
│   ├── screens/                           # Telas do aplicativo
│   │   ├── dashboard_screen.dart         # Dashboard principal
│   │   ├── producao_screen.dart          # Gestão de produção (Kanban)
│   │   ├── producao_etapas_screen.dart   # Etapas hierárquicas
│   │   ├── materiais_screen.dart         # Gestão de materiais
│   │   ├── ligas_screen.dart             # Gestão de ligas
│   │   ├── correcao_avancada_screen.dart # Correção de ligas + IA
│   │   ├── gestao_screen.dart            # Menu de gestão
│   │   ├── gerenciamento_usuarios_screen.dart # CRUD usuários
│   │   ├── login_screen.dart             # Autenticação
│   │   └── ...
│   ├── services/                          # Lógica de negócio
│   │   ├── data_service.dart             # Service principal (Singleton)
│   │   ├── storage_service.dart          # Persistência Hive ⭐
│   │   ├── auth_service.dart             # Autenticação
│   │   ├── correcao_avancada_service.dart # Algoritmo de correção
│   │   ├── permissao_service.dart        # Lógica de permissões
│   │   ├── pdf_export_service.dart       # Exportação PDF
│   │   ├── relatorio_service.dart        # Geração de relatórios
│   │   └── ...
│   └── widgets/                           # Componentes reutilizáveis
│       ├── permissao_widget.dart         # Controle de acesso UI
│       └── ...
├── android/                               # Configuração Android
├── web/                                   # Configuração Web
├── pubspec.yaml                           # Dependências (VERSÕES FIXAS!)
└── README.md                              # Documentação básica
```

---

## ✅ Funcionalidades Implementadas

### 1. Sistema de Usuários e Permissões ⭐

**Arquivo**: `lib/models/usuario_model.dart`, `lib/services/auth_service.dart`

**5 Níveis Hierárquicos**:
- **Administrador** (Acesso Total)
- **Gerente** (Gestão + Relatórios)
- **Supervisor** (Produção + Qualidade)
- **Operador** (Produção Limitada)
- **Visualizador** (Somente Leitura)

**Recursos**:
- ✅ Login/Logout persistente
- ✅ Troca de senha
- ✅ CRUD completo de usuários
- ✅ Middleware de proteção (`PermissaoWidget`)
- ✅ Validação hierárquica (supervisor não edita gerente)

### 2. Sistema de Produção com Persistência ⭐⭐⭐

**Arquivos**: 
- `lib/screens/producao_screen.dart`
- `lib/screens/producao_etapas_screen.dart`
- `lib/services/storage_service.dart`

**Funcionalidades**:
- ✅ **Kanban Visual**: 4 colunas (Aguardando, Em Produção, Pausadas, Concluídas)
- ✅ **8 Etapas Hierárquicas**: Preparação → Moldagem → Fundição → Resfriamento → Desmoldagem → Acabamento → Inspeção → Expedição
- ✅ **Sub-etapas**: Cada etapa tem 2-4 sub-etapas obrigatórias/opcionais
- ✅ **Persistência Hive**: Dados salvos localmente e sincronizados
- ✅ **Validação Sequencial**: Etapa N só inicia se N-1 estiver concluída
- ✅ **Status Automático**: Ordem muda para "concluída" ao terminar última etapa
- ✅ **Consumer Pattern**: Atualização em tempo real entre sessões

**⚠️ IMPORTANTE**: Sistema usa `Consumer<DataService>` para sincronização multi-usuário.

### 3. Correção Avançada de Ligas ⭐⭐

**Arquivo**: `lib/screens/correcao_avancada_screen.dart`

**Recursos**:
- ✅ **Algoritmo de Otimização**: Correção múltipla com recálculo em cascata
- ✅ **Materiais do Estoque**: Integração com `DataService.materiais`
- ✅ **Botão "Adicionar Materiais"**: Modal dinâmico com lista do estoque ⭐
- ✅ **Lista Dinâmica**: Materiais adicionados aparecem com checkbox marcado
- ✅ **Validação de Massa**: Controle de massa do forno
- ✅ **Tolerância Ajustável**: Slider de 0.5% a 10%
- ✅ **Relatório Detalhado**: Resumo da correção com custos

### 4. Gestão de Materiais e Estoque

**Arquivo**: `lib/screens/materiais_screen.dart`

**Recursos**:
- ✅ CRUD completo de materiais
- ✅ Controle de estoque (mínimo/atual)
- ✅ Custos e impostos (NCM, ICMS, IPI)
- ✅ Filtros por tipo e status
- ✅ Alertas de estoque baixo

### 5. Análise Espectrométrica

**Arquivo**: `lib/models/analise_espectrometrica.dart`

**Recursos**:
- ✅ Registro de análises químicas
- ✅ Comparação com especificações de liga
- ✅ Status (Aprovada, Correção Necessária, Rejeitada)
- ✅ Histórico de análises

### 6. Relatórios e Exportações

**Arquivos**: `lib/services/pdf_export_service.dart`, `lib/services/relatorio_service.dart`

**Recursos**:
- ✅ Exportação PDF (análises, correções, relatórios)
- ✅ Exportação CSV (dados tabulares)
- ✅ Relatórios personalizados

---

## ⚙️ Configurações Importantes

### 1. Versões FIXAS (NÃO ATUALIZAR!)

O projeto usa versões específicas para garantir compatibilidade:

```yaml
# pubspec.yaml
environment:
  sdk: ^3.9.2  # ⚠️ LOCKED

dependencies:
  flutter: sdk: flutter
  
  # Core (LOCKED)
  provider: 6.1.5+1
  
  # Storage (LOCKED)
  hive: 2.2.3
  hive_flutter: 1.1.0
  shared_preferences: 2.5.3
  
  # Firebase (LOCKED)
  firebase_core: 3.6.0
  cloud_firestore: 5.4.3
  
  # Charts (LOCKED)
  fl_chart: 0.69.0
```

**⚠️ NÃO EXECUTE**:
- `flutter upgrade`
- `flutter pub upgrade`
- Alterações manuais de versões

### 2. Persistência Hive

**Arquivo**: `lib/services/storage_service.dart`

**Inicialização**:
```dart
// Em main.dart
await dataService.inicializarDadosExemplo(); // Inicializa Hive automaticamente
```

**Box Utilizado**:
- `ordensProducao`: Armazena ordens de produção com etapas hierárquicas

**Métodos Principais**:
- `salvarOrdemProducao(ordem)`: Salva ordem
- `carregarOrdemProducao(id)`: Carrega ordem específica
- `carregarTodasOrdens()`: Carrega todas as ordens

### 3. Firebase (Opcional)

O projeto está **pronto para Firebase** mas não obrigatório.

**Para Ativar Firebase**:
1. Colocar `google-services.json` em `android/app/`
2. Colocar `firebase-admin-sdk.json` em `/opt/flutter/`
3. Executar script de criação de coleções

**Coleções Sugeridas**:
- `usuarios`
- `ordensProducao`
- `materiais`
- `ligas`
- `analises`

---

## 🎯 Próximos Passos Recomendados

### Prioridade ALTA

1. **Build Android APK** ⭐⭐⭐
   ```bash
   flutter build apk --release
   ```
   - Arquivo gerado em: `build/app/outputs/flutter-apk/app-release.apk`

2. **Implementar Firebase Real** ⭐⭐
   - Sincronização em nuvem
   - Multi-dispositivo
   - Backup automático

3. **Autenticação Completa** ⭐⭐
   - Recuperação de senha
   - 2FA (autenticação de dois fatores)
   - Sessões expiráveis

### Prioridade MÉDIA

4. **Notificações Push**
   - Alertas de etapas concluídas
   - Notificações de estoque baixo
   - Aprovações pendentes

5. **Relatórios Avançados**
   - Gráficos de produtividade
   - Dashboard executivo
   - KPIs em tempo real

6. **Integração com APIs Externas**
   - ERP externo
   - Nota fiscal eletrônica
   - Cotação de materiais

### Prioridade BAIXA

7. **Otimizações de Performance**
   - Lazy loading
   - Paginação de listas
   - Cache de imagens

8. **Testes Automatizados**
   - Unit tests
   - Widget tests
   - Integration tests

---

## ⚠️ Problemas Conhecidos

### 1. Sincronização Multi-usuário

**Status**: ✅ RESOLVIDO (v3.0)

**Solução Implementada**: `Consumer<DataService>` na ProducaoScreen

**Se Persistir**:
- Verificar se tela usa `Consumer<DataService>`
- Confirmar `notifyListeners()` em `DataService.atualizarOrdemProducao()`

### 2. Materiais Não Aparecem na Correção Avançada

**Status**: ✅ RESOLVIDO (v3.0)

**Solução Implementada**: Lista dinâmica com `..._materiaisSelecionados.map()`

**Se Persistir**:
- Verificar se método `_converterMaterialParaCorrecao()` retorna objeto válido
- Confirmar que `setState()` é chamado após fechar modal

### 3. Dependências Desatualizadas

**Status**: ⚠️ INTENCIONAL

29 pacotes têm versões mais novas, mas **NÃO DEVEM SER ATUALIZADOS** para manter compatibilidade.

**Comando Proibido**:
```bash
flutter pub upgrade  # ❌ NÃO EXECUTAR
```

---

## 👥 Usuários de Teste

### Credenciais Pré-cadastradas

| Email | Senha | Nível | Permissões |
|-------|-------|-------|-----------|
| admin@fundicaopro.com.br | admin123 | Administrador | Acesso Total |
| gerente@fundicaopro.com.br | gerente123 | Gerente | Gestão + Relatórios |
| supervisor@fundicaopro.com.br | supervisor123 | Supervisor | Produção + Qualidade |
| operador@fundicaopro.com.br | operador123 | Operador | Produção Limitada |
| viewer@fundicaopro.com.br | viewer123 | Visualizador | Somente Leitura |

### Testar Permissões

1. Login com **Visualizador** → Não consegue criar/editar
2. Login com **Operador** → Consegue produção, mas não gestão
3. Login com **Gerente** → Consegue gestão de usuários (limitada)
4. Login com **Administrador** → Acesso total

---

## 🔧 Comandos Úteis

### Desenvolvimento

```bash
# Executar em modo debug (web)
flutter run -d chrome

# Executar em modo debug (Android)
flutter run

# Hot reload (durante desenvolvimento)
r

# Hot restart (durante desenvolvimento)
R

# Análise de código
flutter analyze

# Formatação de código
dart format .

# Limpar build cache
flutter clean
```

### Build

```bash
# Build web (release)
flutter build web --release

# Build Android APK (release)
flutter build apk --release

# Build Android App Bundle (Google Play)
flutter build appbundle --release

# Servir aplicação web (após build)
cd build/web && python3 -m http.server 5060
```

### Debug

```bash
# Ver logs do Flutter
flutter logs

# Ver dispositivos conectados
flutter devices

# Verificar ambiente Flutter
flutter doctor -v

# Atualizar dependências (CUIDADO!)
flutter pub get  # ✅ Seguro (não atualiza versões)
flutter pub upgrade  # ❌ EVITAR (atualiza versões)
```

---

## 📞 Suporte e Contato

### Documentação Adicional

- **Flutter Docs**: https://docs.flutter.dev
- **Dart Docs**: https://dart.dev/guides
- **Hive Docs**: https://docs.hivedb.dev
- **Provider Docs**: https://pub.dev/packages/provider

### Informações do Projeto

- **Versão Atual**: v3.0 Final
- **Data de Criação**: Janeiro 2025
- **Última Atualização**: 09/12/2025
- **Desenvolvedor Original**: Sistema IA Claude (Anthropic)
- **Plataformas Suportadas**: Web, Android (iOS preparado)

---

## 📄 Licença

Este projeto é fornecido "como está" para fins educacionais e comerciais.

---

## ✅ Checklist de Continuidade

Ao retomar o projeto, verifique:

- [ ] Flutter 3.35.4 instalado
- [ ] Dart 3.9.2 instalado
- [ ] Dependências restauradas (`flutter pub get`)
- [ ] Nenhum erro de análise (`flutter analyze`)
- [ ] Sistema roda sem erros (`flutter run`)
- [ ] Login funciona com usuários de teste
- [ ] Produção salva etapas corretamente
- [ ] Materiais aparecem na Correção Avançada
- [ ] Firebase configurado (se necessário)

---

## 🎓 Conceitos Importantes para Entender

### Provider Pattern
O projeto usa Provider para gerenciamento de estado. `DataService` é o provider principal.

### Hive Database
Banco de dados NoSQL local, similar ao SQLite mas mais rápido e sem SQL.

### Material Design 3
Usa componentes modernos do Material Design 3.0.

### Consumer vs Provider.of
- `Consumer<T>`: Re-renderiza quando dados mudam
- `Provider.of<T>(context, listen: false)`: Acesso único, não escuta mudanças

---

**BOA SORTE NA CONTINUIDADE DO PROJETO! 🚀**

---

*Este documento foi gerado automaticamente em 09/12/2025*

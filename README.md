# 🏭 Foundry ERP - Sistema de Gestão para Indústrias de Fundição

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Version](https://img.shields.io/badge/Version-3.0%20Final-blue)

Sistema completo de gestão (ERP) desenvolvido em Flutter para indústrias de fundição de alumínio, com foco em controle de produção, gestão de ligas metalúrgicas e correção avançada de composições químicas.

---

## 🎯 Visão Geral

O **Foundry ERP** é uma solução profissional e completa para gestão de fundições, oferecendo:

- 📊 **Dashboard Inteligente** com métricas em tempo real
- 🏭 **Sistema de Produção** com 8 etapas hierárquicas
- 🧪 **Correção Avançada de Ligas** com recálculo em cascata
- 📚 **Biblioteca de 21 Ligas Metalúrgicas** (SAE, ASTM, DIN, AA)
- 👥 **Controle de Acesso** com 5 níveis de permissão
- 💾 **Persistência Local** com Hive para sincronização multi-usuário
- 📈 **Relatórios PDF/CSV** para análises e documentação

---

## ✨ Funcionalidades Principais

### 🏭 Produção
- **8 Etapas Hierárquicas**: Preparação → Moldagem → Fundição → Resfriamento → Desmoldagem → Acabamento → Inspeção → Expedição
- **Sub-etapas com Checklist**: Controle detalhado de cada processo
- **Status Automático**: Atualização inteligente do status das ordens
- **Persistência Completa**: Dados salvos localmente com Hive
- **Sincronização Multi-usuário**: Acesso compartilhado em tempo real

### 🧪 Ligas Metalúrgicas
- **21 Ligas Pré-cadastradas**: SAE (10), ASTM (5), DIN/EN 1706 (4), AA (3)
- **Cálculo Automático**: Composição química com rendimento de forno
- **Verificação de Estoque**: Integração com materiais disponíveis
- **Histórico de Cálculos**: Persistência de cálculos anteriores
- **Filtros por Norma**: SAE, ASTM, DIN, AA

### 🔬 Correção Avançada
- **Recálculo em Cascata**: Ajuste inteligente considerando impactos secundários
- **Integração com Estoque**: Materiais disponíveis em tempo real
- **Priorização Automática**: Elementos críticos primeiro
- **Otimização de Custos**: Menor custo total de correção
- **Sistema de Diluição**: Suporte para diluição com sucata

### 📦 Materiais
- **Gestão de Estoque**: Controle completo de materiais
- **Alertas de Estoque Mínimo**: Notificações automáticas
- **Histórico de Movimentações**: Rastreabilidade completa
- **Custos Unitários**: Cálculo de custos de produção

### 👥 Gestão de Usuários
- **5 Níveis de Permissão**:
  - 🌟🌟🌟🌟🌟 Administrador Master (acesso total)
  - 🌟🌟🌟🌟 Gerente de Produção
  - 🌟🌟🌟🌟 Analista Metalúrgico
  - 🌟🌟🌟 Operador de Produção
  - 🌟🌟 Assistente Operacional
- **CRUD Completo**: Criar, editar, visualizar e excluir usuários
- **Middleware de Proteção**: Segurança em todas as rotas

### 📊 Relatórios
- **Exportação PDF**: Relatórios profissionais
- **Exportação CSV**: Para análise em Excel
- **Análises Espectrométricas**: Documentação técnica
- **Ordens de Produção**: Rastreabilidade completa

---

## 🚀 Tecnologias Utilizadas

### Core
- **Flutter 3.35.4** (FIXO - não atualizar)
- **Dart 3.9.2** (FIXO - não atualizar)
- **Material Design 3**

### State Management & Storage
- **Provider 6.1.5+1** - Gerenciamento de estado
- **Hive 2.2.3** - Banco de dados local (document DB)
- **Hive Flutter 1.1.0** - Integração Flutter
- **Shared Preferences 2.5.3** - Armazenamento key-value

### Firebase (Opcional)
- **Firebase Core 3.6.0**
- **Cloud Firestore 5.4.3**
- **Firebase Auth 5.3.1**
- **Firebase Storage 12.3.2**

### UI & Utilities
- **FL Chart 0.69.2** - Gráficos
- **Intl 0.19.0** - Internacionalização
- **HTTP 1.5.0** - Requisições HTTP
- **PDF 3.11.1** - Geração de PDFs
- **CSV 6.0.0** - Exportação CSV

---

## 📥 Instalação e Configuração

### Pré-requisitos
- Flutter 3.35.4 (OBRIGATÓRIO - não use versões diferentes)
- Dart 3.9.2 (OBRIGATÓRIO - não use versões diferentes)
- Git

### Passo a Passo

1. **Clone o repositório:**
```bash
git clone https://github.com/cmelodm/FUNDICAO_ERP.git
cd FUNDICAO_ERP
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Execute a aplicação:**

**Web (Chrome):**
```bash
flutter run -d chrome
```

**Web Release (Produção):**
```bash
flutter build web --release
python3 -m http.server 5060 --directory build/web --bind 0.0.0.0
```

4. **Acesse no navegador:**
```
http://localhost:5060
```

---

## 👤 Usuários de Teste

### Administrador Master
- **Email:** `admin@fundicaopro.com.br`
- **Senha:** `admin123`
- **Acesso:** Total (5 estrelas)

### Gerente de Produção
- **Email:** `gerente@fundicaopro.com.br`
- **Senha:** `gerente123`
- **Acesso:** Gestão + Relatórios (4 estrelas)

### Analista Metalúrgico
- **Email:** `analista@fundicaopro.com.br`
- **Senha:** `analista123`
- **Acesso:** Análises + Correções (4 estrelas)

### Operador de Produção
- **Email:** `operador@fundicaopro.com.br`
- **Senha:** `operador123`
- **Acesso:** Produção + Materiais (3 estrelas)

---

## 📚 Documentação

### Arquivos de Documentação Inclusos

- **[LEIA_PRIMEIRO.txt](LEIA_PRIMEIRO.txt)** - Guia de início rápido
- **[CONTINUIDADE_PROJETO.md](CONTINUIDADE_PROJETO.md)** - Guia completo de restauração
- **[DOCUMENTACAO_TECNICA.md](DOCUMENTACAO_TECNICA.md)** - Detalhes técnicos do sistema
- **[DOCUMENTACAO_LIGAS_METALURGICAS.md](DOCUMENTACAO_LIGAS_METALURGICAS.md)** - Biblioteca de ligas (36 KB, 1.228 linhas)
- **[LINK_DOWNLOAD_PROJETO.txt](LINK_DOWNLOAD_PROJETO.txt)** - Download do backup completo

### Documentação Online

- [Flutter Documentation](https://docs.flutter.dev)
- [Hive Documentation](https://docs.hivedb.dev)
- [Provider Documentation](https://pub.dev/packages/provider)

---

## 🏗️ Arquitetura do Projeto

```
foundry_erp/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── models/                      # Modelos de dados
│   │   ├── usuario_model.dart
│   │   ├── permissao_model.dart
│   │   ├── ordem_producao_model.dart
│   │   ├── etapa_producao_model.dart
│   │   ├── material_model.dart
│   │   ├── liga_metalurgica_model.dart
│   │   └── analise_espectrometrica.dart
│   ├── screens/                     # Telas principais
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── producao_screen.dart
│   │   ├── producao_etapas_screen.dart
│   │   ├── materiais_screen.dart
│   │   ├── ligas_screen.dart
│   │   ├── correcao_avancada_screen.dart
│   │   ├── gestao_screen.dart
│   │   └── relatorios_screen.dart
│   ├── services/                    # Lógica de negócio
│   │   ├── data_service.dart
│   │   ├── storage_service.dart
│   │   ├── correcao_avancada_service.dart
│   │   ├── liga_templates_service.dart
│   │   └── pdf_export_service.dart
│   └── widgets/                     # Componentes reutilizáveis
│       ├── permissao_widget.dart
│       └── ordem_producao_card.dart
├── android/                         # Configuração Android
├── web/                             # Configuração Web
├── test/                            # Testes unitários
└── pubspec.yaml                     # Dependências
```

---

## 🔧 Build APK/AAB (Android)

### Build APK (Debug)
```bash
flutter build apk --debug
```

### Build APK (Release)
```bash
flutter build apk --release
```

### Build AAB (Google Play Store)
```bash
flutter build appbundle --release
```

**Localização dos builds:**
- APK Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- APK Release: `build/app/outputs/flutter-apk/app-release.apk`
- AAB Release: `build/app/outputs/bundle/release/app-release.aab`

---

## ⚠️ Avisos Importantes

### Versões Fixas (NÃO ATUALIZAR)
- ⛔ **NÃO execute** `flutter upgrade`
- ⛔ **NÃO execute** `flutter pub upgrade`
- ⛔ **NÃO atualize** Flutter além de 3.35.4
- ⛔ **NÃO atualize** Dart além de 3.9.2

**Motivo:** As versões foram testadas e são compatíveis. Atualizações podem quebrar dependências.

### Compatibilidade Web
- ✅ Chrome (recomendado)
- ✅ Firefox
- ✅ Safari
- ✅ Edge

---

## 🐛 Troubleshooting

### Problema: "Exceção não tratada: MissingPluginException"
**Solução:**
```bash
rm -rf build/web .dart_tool/build_cache
flutter clean
flutter pub get
flutter build web --release
```

### Problema: "Erro de persistência Hive"
**Solução:**
Verifique se `storage_service.dart` está inicializado no `main.dart`:
```dart
await Hive.initFlutter();
await StorageService().init();
```

### Problema: "Status da OP não atualiza"
**Solução:**
Verifique se `ProducaoScreen` usa `Consumer<DataService>`:
```dart
Consumer<DataService>(
  builder: (context, dataService, child) {
    // UI aqui
  },
)
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 📧 Contato

**Desenvolvedor:** Claude AI Assistant  
**Versão:** 3.0 Final  
**Data:** 09/12/2025  
**Repositório:** [https://github.com/cmelodm/FUNDICAO_ERP](https://github.com/cmelodm/FUNDICAO_ERP)

---

## 🌟 Recursos Adicionais

### Download Completo do Projeto
- **Backup TAR.GZ:** [foundry_erp_completo_v3_final.tar.gz](https://www.genspark.ai/api/files/s/wJ7o02F4) (1.6 MB)

### Ligas Metalúrgicas Disponíveis
- **SAE:** 303, 305, 305 C, 305 I, 306, 308, 309, 319, 323, 329
- **ASTM:** A356, A357, 380, 383, 413
- **DIN/EN 1706:** AlSi7Mg, AlSi9Cu3, AlSi10Mg, AlSi12
- **AA:** 356.0, 319.0, 443.0

### Normas Técnicas Suportadas
- **SAE J452** - Aluminum Casting Alloy Composition Limits
- **ASTM B108** - Standard Specification for Aluminum-Alloy Permanent Mold Castings
- **DIN EN 1706** - Aluminium and aluminium alloys - Castings
- **AA Standards** - Aluminum Association Standards

---

## 🎉 Agradecimentos

Desenvolvido com ❤️ usando Flutter e Dart para a indústria de fundição.

**Foundry ERP v3.0 Final** - Sistema Profissional de Gestão Industrial

---

⭐ **Se este projeto foi útil para você, considere dar uma estrela!** ⭐

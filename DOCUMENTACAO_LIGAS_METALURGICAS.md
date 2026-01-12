# 📚 FOUNDRY ERP - DOCUMENTAÇÃO TÉCNICA: ABA LIGAS METALÚRGICAS

**Versão:** 3.0 Final  
**Data:** 09/12/2025  
**Módulo:** Biblioteca de Ligas Metalúrgicas  
**Arquivo Principal:** `lib/screens/ligas_screen.dart`  
**Serviço:** `lib/services/liga_templates_service.dart`

---

## 📋 ÍNDICE

1. [Visão Geral](#visão-geral)
2. [Arquitetura e Fluxo de Dados](#arquitetura-e-fluxo-de-dados)
3. [Biblioteca de Ligas Disponíveis](#biblioteca-de-ligas-disponíveis)
4. [Funcionalidades Principais](#funcionalidades-principais)
5. [Interface do Usuário](#interface-do-usuário)
6. [Cálculo de Elementos](#cálculo-de-elementos)
7. [Verificação de Disponibilidade](#verificação-de-disponibilidade)
8. [Histórico de Cálculos](#histórico-de-cálculos)
9. [Integração com Estoque](#integração-com-estoque)
10. [Correção Avançada](#correção-avançada)
11. [Estrutura de Dados](#estrutura-de-dados)
12. [Como Adicionar Novas Ligas](#como-adicionar-novas-ligas)
13. [Troubleshooting](#troubleshooting)

---

## 🎯 VISÃO GERAL

A **Aba Ligas Metalúrgicas** é o módulo central do Foundry ERP para gestão e cálculo de composições de ligas de alumínio para fundição. O sistema oferece:

### ✅ Recursos Principais

- **21 Ligas Pré-cadastradas** seguindo normas internacionais (SAE, ASTM, DIN/EN, AA)
- **Cálculo Automático de Elementos** com base em peso total da liga
- **Rendimento de Forno** específico para cada elemento químico
- **Verificação de Disponibilidade** integrada com estoque de materiais
- **Histórico de Cálculos** salvos para consulta posterior
- **Filtros por Norma** (SAE, ASTM, DIN, AA)
- **Integração com Correção Avançada** para ajustes metalúrgicos

### 🎨 Design Pattern

```
LigasScreen (StatefulWidget)
    ↓
LigaTemplatesService (Singleton)
    ↓
DataService (Singleton + ChangeNotifier)
    ↓
Hive Storage (Persistência Local)
```

---

## 🏗️ ARQUITETURA E FLUXO DE DADOS

### Componentes Principais

```
┌─────────────────────────────────────────────────────────┐
│                    LigasScreen.dart                      │
│  - Exibição de ligas                                     │
│  - Filtros por norma                                     │
│  - Navegação para Correção Avançada                     │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│            LigaTemplatesService.dart                     │
│  - Biblioteca de 21 ligas padrão                        │
│  - Busca por código                                      │
│  - Filtro por norma                                      │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                  DataService.dart                        │
│  - Verificação de disponibilidade                       │
│  - Salvar cálculos no histórico                         │
│  - Integração com estoque                               │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│               StorageService (Hive)                      │
│  - Persistência de cálculos salvos                      │
│  - Sincronização multi-usuário                          │
└─────────────────────────────────────────────────────────┘
```

### Fluxo de Uso Típico

```
1. Usuário acessa aba "Ligas"
2. Sistema carrega biblioteca de ligas (LigaTemplatesService)
3. Usuário filtra por norma (opcional)
4. Usuário seleciona uma liga
5. Sistema abre dialog de cálculo
6. Usuário informa peso total da liga (kg)
7. Sistema calcula:
   - Quantidade de cada elemento na liga
   - Quantidade necessária (considerando rendimento)
   - Verifica disponibilidade no estoque
8. Usuário visualiza resultado em tabela detalhada
9. Usuário pode:
   - Salvar cálculo no histórico
   - Exportar para Excel (futura implementação)
   - Ir para Correção Avançada
```

---

## 📚 BIBLIOTECA DE LIGAS DISPONÍVEIS

### 🔵 NORMA SAE (Society of Automotive Engineers)

#### SAE 303 - Alumínio-Silício (Alta Fluidez)
- **Código:** SAE 303
- **Tipo:** Alumínio-Silício Eutético
- **Aplicação:** Peças de paredes finas, desenhos complexos
- **Composição Principal:**
  - Si: 10.50-12.0% (nominal 11.25%)
  - Cu: 0.0-0.40% (nominal 0.20%)
  - Fe: 0.0-0.60% (nominal 0.30%)
- **Características:** Ótima fluidez, ideal para peças complexas

#### SAE 305 - Alumínio-Silício-Cobre (Fundição sob Pressão)
- **Código:** SAE 305
- **Tipo:** Al-Si-Cu para injeção
- **Aplicação:** Fundição sob pressão, coquilha, areia
- **Composição Principal:**
  - Si: 11.0-13.0% (nominal 12.0%)
  - Cu: 3.0-4.5% (nominal 3.75%)
  - Fe: 0.0-1.0% (nominal 0.50%)
- **Temperatura Vazamento:** 630-690°C

#### SAE 305 C - Alumínio-Silício-Cobre (Versão Comercial)
- **Código:** SAE 305 C
- **Tipo:** Al-Si-Cu Comercial
- **Aplicação:** Componentes automotivos de uso geral
- **Composição Principal:**
  - Si: 4.5-6.0% (nominal 5.25%)
  - Cu: 1.0-2.0% (nominal 1.5%)
  - Fe: 0.0-1.5% (nominal 0.75%)
- **Características:** Tolerâncias mais amplas, custo reduzido

#### SAE 305 I - Alumínio-Silício-Cobre (Versão Industrial)
- **Código:** SAE 305 I
- **Tipo:** Al-Si-Cu Industrial
- **Aplicação:** Blocos de motor, cabeçotes de qualidade superior
- **Composição Principal:**
  - Si: 4.8-5.8% (nominal 5.3%)
  - Cu: 1.0-1.4% (nominal 1.2%)
  - Fe: 0.0-1.0% (nominal 0.5%)
- **Características:** Controle rigoroso de impurezas

#### SAE 306 - Alumínio-Silício-Cobre Hipoeutética
- **Código:** SAE 306
- **Tipo:** Al-Si-Cu
- **Aplicação:** Blocos de motor, cabeçotes, peças automotivas
- **Composição Principal:**
  - Si: 7.5-9.5% (nominal 8.5%)
  - Cu: 4.0-5.0% (nominal 4.5%)
  - Mg: 0.20-0.45% (nominal 0.325%)
  - Fe: 0.0-1.3% (nominal 0.65%)
- **Características:** Excelente fundibilidade, boa resistência

#### SAE 308 - Alumínio-Silício
- **Código:** SAE 308
- **Tipo:** Al-Si
- **Aplicação:** Peças estruturais, componentes marítimos
- **Composição Principal:**
  - Si: 5.0-6.0% (nominal 5.5%)
  - Cu: 4.0-5.0% (nominal 4.5%)
  - Fe: 0.0-1.0% (nominal 0.5%)
- **Características:** Boa resistência à corrosão

#### SAE 309 - Alumínio-Silício-Cobre-Magnésio (Média Resistência)
- **Código:** SAE 309
- **Tipo:** Al-Si-Cu-Mg
- **Aplicação:** Cabeçotes, blocos de cilindros, carters
- **Composição Principal:**
  - Si: 7.5-9.5% (nominal 8.5%)
  - Cu: 3.0-4.0% (nominal 3.5%)
  - Mg: 0.40-0.60% (nominal 0.50%)
  - Fe: 0.0-1.3% (nominal 0.65%)
- **Características:** Média resistência mecânica, boa fundibilidade

#### SAE 319 (A319) - Alumínio-Silício-Cobre
- **Código:** SAE 319
- **Tipo:** Al-Si-Cu
- **Aplicação:** Cabeçotes, cárteres, peças automotivas gerais
- **Composição Principal:**
  - Si: 5.5-6.5% (nominal 6.0%)
  - Cu: 3.0-4.0% (nominal 3.5%)
  - Fe: 0.0-1.0% (nominal 0.5%)
  - Zn: 0.0-3.0% (nominal 1.0%)
- **Características:** Versátil, bom equilíbrio de propriedades

#### SAE 323 - Alumínio-Silício-Magnésio (Equivalente A356)
- **Código:** SAE 323
- **Tipo:** Al-Si-Mg
- **Aplicação:** Rodas automotivas, componentes estruturais
- **Composição Principal:**
  - Si: 6.5-7.5% (nominal 7.0%)
  - Mg: 0.25-0.45% (nominal 0.35%)
  - Cu: 0.0-0.25% (nominal 0.125%)
  - Fe: 0.0-0.6% (nominal 0.3%)
- **Características:** Alta resistência após T6, equivalente A356

#### SAE 329 - Alumínio-Silício-Magnésio (Alta Resistência)
- **Código:** SAE 329
- **Tipo:** Al-Si-Mg Premium
- **Aplicação:** Componentes aeroespaciais, peças críticas
- **Composição Principal:**
  - Si: 6.5-7.5% (nominal 7.0%)
  - Mg: 0.50-0.70% (nominal 0.60%)
  - Cu: 0.0-0.10% (nominal 0.05%)
  - Fe: 0.0-0.15% (nominal 0.075%)
- **Características:** Excelente resistência após T6, premium

---

### 🟢 NORMA ASTM (American Society for Testing and Materials)

#### ASTM A356 (AA 356) - Alumínio-Silício-Magnésio
- **Código:** A356
- **Tipo:** Al-Si-Mg
- **Aplicação:** Rodas automotivas, componentes aeroespaciais
- **Composição Principal:**
  - Si: 6.5-7.5% (nominal 7.0%)
  - Mg: 0.25-0.45% (nominal 0.35%)
  - Fe: 0.0-0.2% (nominal 0.1%)
  - Cu: 0.0-0.2% (nominal 0.1%)
- **Características:** Alta resistência após T6, excelente fundição
- **Tratamento Térmico:** T6

#### ASTM A357 - Alumínio-Silício-Magnésio Premium
- **Código:** A357
- **Tipo:** Al-Si-Mg Premium
- **Aplicação:** Componentes aeroespaciais críticos, rodas alta performance
- **Composição Principal:**
  - Si: 6.5-7.5% (nominal 7.0%)
  - Mg: 0.40-0.70% (nominal 0.55%)
  - Fe: 0.0-0.12% (nominal 0.06%)
  - Cu: 0.0-0.05% (nominal 0.025%)
  - Ti: 0.10-0.20% (nominal 0.15%)
- **Características:** Versão premium da A356, controle rigoroso

#### ASTM 380 - Liga de Injeção sob Pressão
- **Código:** ASTM 380
- **Tipo:** Al-Si die cast
- **Aplicação:** Carcaças eletrônicas, peças injetadas
- **Composição Principal:**
  - Si: 7.5-9.5% (nominal 8.5%)
  - Cu: 3.0-4.0% (nominal 3.5%)
  - Fe: 0.0-1.3% (nominal 0.8%)
  - Zn: 0.0-3.0% (nominal 1.0%)
- **Características:** Mais popular para injeção, excelente fundibilidade

#### ASTM 383 - Excelente Usinabilidade
- **Código:** ASTM 383
- **Tipo:** Al-Si die cast
- **Aplicação:** Peças que requerem usinagem posterior
- **Composição Principal:**
  - Si: 9.5-11.5% (nominal 10.5%)
  - Cu: 2.0-3.0% (nominal 2.5%)
  - Fe: 0.0-1.3% (nominal 0.8%)
  - Zn: 0.0-3.0% (nominal 1.0%)
- **Características:** Versão 380 com melhor usinabilidade

#### ASTM 413 - Máxima Fluidez
- **Código:** ASTM 413
- **Tipo:** Al-Si eutectic
- **Aplicação:** Peças complexas de parede fina
- **Composição Principal:**
  - Si: 11.0-13.0% (nominal 12.0%)
  - Fe: 0.0-1.3% (nominal 0.6%)
  - Cu: 0.0-1.0% (nominal 0.3%)
  - Mn: 0.0-0.35% (nominal 0.15%)
- **Características:** Liga eutética, máxima fluidez, estanqueidade

---

### 🟠 NORMA DIN / EN 1706 (Europeia)

#### DIN AlSi7Mg (EN AC-42100)
- **Código:** AlSi7Mg
- **Tipo:** Al-Si-Mg
- **Aplicação:** Componentes automotivos, peças estruturais
- **Composição Principal:**
  - Si: 6.5-7.5% (nominal 7.0%)
  - Mg: 0.25-0.45% (nominal 0.35%)
  - Fe: 0.0-0.19% (nominal 0.1%)
- **Características:** Equivalente europeu da A356, alta resistência

#### DIN AlSi9Cu3 (EN AC-46000)
- **Código:** AlSi9Cu3
- **Tipo:** Al-Si-Cu
- **Aplicação:** Carcaças, componentes injetados sob pressão
- **Composição Principal:**
  - Si: 8.0-11.0% (nominal 9.5%)
  - Cu: 2.0-4.0% (nominal 3.0%)
  - Fe: 0.0-1.3% (nominal 0.8%)
  - Zn: 0.0-1.2% (nominal 0.5%)
- **Características:** Liga europeia para injeção, excelente fundibilidade

#### DIN AlSi10Mg (EN AC-43000)
- **Código:** AlSi10Mg
- **Tipo:** Al-Si-Mg
- **Aplicação:** Peças fundidas gerais, componentes mecânicos
- **Composição Principal:**
  - Si: 9.0-11.0% (nominal 10.0%)
  - Mg: 0.20-0.45% (nominal 0.32%)
  - Fe: 0.0-0.55% (nominal 0.3%)
- **Características:** Versátil, boa fundibilidade e propriedades

#### DIN AlSi12 (EN AC-44000)
- **Código:** AlSi12
- **Tipo:** Al-Si alto
- **Aplicação:** Peças complexas de parede fina
- **Composição Principal:**
  - Si: 10.5-13.5% (nominal 12.0%)
  - Fe: 0.0-0.55% (nominal 0.3%)
  - Cu: 0.0-0.10% (nominal 0.05%)
- **Características:** Alto silício, excelente fluidez

---

### 🟣 NORMA AA (Aluminum Association)

#### AA 356.0 - Padrão Industrial
- **Código:** AA 356.0
- **Tipo:** Al-Si-Mg
- **Aplicação:** Padrão industrial para fundição de precisão
- **Composição Principal:**
  - Si: 6.5-7.5% (nominal 7.0%)
  - Mg: 0.25-0.45% (nominal 0.35%)
  - Fe: 0.0-0.6% (nominal 0.3%)
  - Cu: 0.0-0.25% (nominal 0.12%)
- **Características:** Padrão Aluminum Association

#### AA 319.0 - Alumínio-Silício-Cobre
- **Código:** AA 319.0
- **Tipo:** Al-Si-Cu
- **Aplicação:** Cabeçotes, blocos de motor
- **Composição Principal:**
  - Si: 5.5-6.5% (nominal 6.0%)
  - Cu: 3.0-4.0% (nominal 3.5%)
  - Fe: 0.0-1.0% (nominal 0.5%)
- **Características:** Padrão AA para Al-Si-Cu

#### AA 443.0 - Alumínio-Silício (Alta Pureza)
- **Código:** AA 443.0
- **Tipo:** Al-Si
- **Aplicação:** Equipamentos químicos, trocadores de calor
- **Composição Principal:**
  - Si: 4.5-6.0% (nominal 5.25%)
  - Fe: 0.0-0.6% (nominal 0.3%)
  - Cu: 0.0-0.3% (nominal 0.15%)
- **Características:** Alta pureza, excelente resistência à corrosão

---

## ⚙️ FUNCIONALIDADES PRINCIPAIS

### 1. Visualização de Ligas

```dart
// Código: ligas_screen.dart (linhas 20-46)
Widget build(BuildContext context) {
  final ligas = _filtroNorma == 'Todas'
      ? _templatesService.ligasTemplates
      : _templatesService.filtrarPorNorma(_filtroNorma);
  
  return Scaffold(
    appBar: AppBar(
      title: const Text('Biblioteca de Ligas'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list),
          onSelected: (value) {
            setState(() {
              _filtroNorma = value;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Todas', child: Text('Todas as Normas')),
            const PopupMenuItem(value: 'SAE', child: Text('SAE')),
            const PopupMenuItem(value: 'ASTM', child: Text('ASTM')),
            const PopupMenuItem(value: 'DIN', child: Text('DIN / EN 1706')),
            const PopupMenuItem(value: 'AA', child: Text('AA (Aluminum Association)')),
          ],
        ),
      ],
    ),
    // ...
  );
}
```

**Recursos:**
- Exibição em lista com cards visuais
- Filtro por norma (SAE, ASTM, DIN, AA)
- Código colorido por norma:
  - 🔵 SAE: Azul
  - 🟢 ASTM: Verde
  - 🟠 DIN: Laranja
  - 🟣 AA: Roxo
- Nome da liga e aplicação
- Composição química resumida

### 2. Cálculo de Ligas

```dart
// Código: ligas_screen.dart (linhas 267-348)
void _showCalcularLigaDialog(LigaTemplate template) {
  final pesoController = TextEditingController(text: '1000');
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Calcular ${template.codigo}'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: pesoController,
              decoration: const InputDecoration(
                labelText: 'Peso Total da Liga (kg)',
                prefixIcon: Icon(Icons.scale),
              ),
              keyboardType: TextInputType.number,
            ),
            // Composição química exibida
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final peso = double.tryParse(pesoController.text) ?? 0;
            if (peso > 0) {
              Navigator.pop(context);
              _mostrarResultadoCalculo(template, peso);
            }
          },
          child: const Text('Calcular'),
        ),
      ],
    ),
  );
}
```

**Fluxo:**
1. Usuário clica em uma liga
2. Dialog solicita peso total (kg)
3. Sistema valida entrada
4. Calcula quantidade de cada elemento
5. Exibe resultado em modal detalhado

### 3. Resultado do Cálculo

```dart
// Código: ligas_screen.dart (linhas 350-445)
void _mostrarResultadoCalculo(LigaTemplate template, double pesoTotal) {
  final liga = template.toLiga(pesoTotal);
  final disponibilidade = _dataService.verificarDisponibilidadeLiga(liga);
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho com código e peso
            // Tabela de elementos
            _buildTabelaElementos(liga, disponibilidade),
            // Botões de ação
            ElevatedButton.icon(
              onPressed: () {
                _salvarCalculo(liga);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text('Salvar Cálculo'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Informações Exibidas:**

| Coluna | Descrição | Exemplo |
|--------|-----------|---------|
| **Elemento** | Símbolo + Nome | Si (Silício) |
| **%** | Percentual nominal | 7.00% |
| **Rend.** | Rendimento do forno | 95% |
| **Qtd Liga** | Peso do elemento na liga | 70.00 kg |
| **Qtd Nec.** | Quantidade necessária considerando rendimento | 73.68 kg |
| **Status** | ✅ Disponível / ⚠️ Insuficiente | ✅ |

---

## 🧮 CÁLCULO DE ELEMENTOS

### Fórmulas Utilizadas

#### 1. Quantidade na Liga (Qtd Liga)

```
Qtd_Liga = Peso_Total × (Percentual_Nominal / 100)
```

**Exemplo:**
- Peso Total: 1000 kg
- Silício: 7.0%
- Qtd_Liga = 1000 × (7.0 / 100) = **70.0 kg**

#### 2. Quantidade Necessária (Qtd Nec.)

```
Qtd_Necessaria = Qtd_Liga / (Rendimento_Forno / 100)
```

**Exemplo:**
- Qtd_Liga: 70.0 kg
- Rendimento Silício: 95%
- Qtd_Necessaria = 70.0 / (95 / 100) = **73.68 kg**

**Rendimentos de Forno Padrão:**

| Elemento | Rendimento | Motivo |
|----------|------------|--------|
| **Si** (Silício) | 95% | Oxidação moderada |
| **Cu** (Cobre) | 98% | Baixa oxidação |
| **Fe** (Ferro) | 98% | Estável no forno |
| **Mg** (Magnésio) | 90% | Alta oxidação (queima) |
| **Mn** (Manganês) | 95% | Oxidação moderada |
| **Zn** (Zinco) | 98% | Baixa volatilização |
| **Ti** (Titânio) | 92% | Oxidação significativa |
| **Ni** (Níquel) | 97% | Estável |
| **Sn** (Estanho) | 98% | Baixa perda |

### Código de Implementação

```dart
// Código: liga_metalurgica_model.dart
class ElementoLiga {
  final String simbolo;
  final String nome;
  final double percentualMinimo;
  final double percentualMaximo;
  final double percentualNominal;
  final double rendimentoForno;
  
  // Calcula quantidade do elemento na liga
  double calcularQuantidadeLiga(double pesoTotal) {
    return pesoTotal * (percentualNominal / 100);
  }
  
  // Calcula quantidade necessária (considerando rendimento)
  double calcularQuantidadeNecessaria(double pesoTotal) {
    final qtdLiga = calcularQuantidadeLiga(pesoTotal);
    return qtdLiga / (rendimentoForno / 100);
  }
}
```

---

## ✅ VERIFICAÇÃO DE DISPONIBILIDADE

### Integração com Estoque

O sistema verifica se há material suficiente no estoque para produzir a liga calculada.

```dart
// Código: data_service.dart (exemplo conceitual)
Map<String, bool> verificarDisponibilidadeLiga(LigaMetalurgicaModel liga) {
  Map<String, bool> disponibilidade = {};
  
  for (var elemento in liga.elementos) {
    // Buscar material no estoque por símbolo
    final material = materiais.firstWhere(
      (m) => m.tipo.toUpperCase().contains(elemento.simbolo.toUpperCase()),
      orElse: () => null,
    );
    
    if (material != null) {
      final qtdNecessaria = elemento.calcularQuantidadeNecessaria(liga.pesoTotal);
      disponibilidade[elemento.simbolo] = material.estoque >= qtdNecessaria;
    } else {
      disponibilidade[elemento.simbolo] = false;
    }
  }
  
  return disponibilidade;
}
```

**Lógica:**
1. Para cada elemento da liga
2. Busca material correspondente no estoque
3. Compara quantidade necessária com estoque disponível
4. Retorna `true` (✅) se suficiente, `false` (⚠️) se insuficiente

**Indicadores Visuais:**

| Status | Ícone | Cor | Significado |
|--------|-------|-----|-------------|
| ✅ Disponível | `Icons.check_circle` | 🟢 Verde | Estoque suficiente |
| ⚠️ Insuficiente | `Icons.warning` | 🟠 Laranja | Estoque insuficiente |

---

## 📜 HISTÓRICO DE CÁLCULOS

### Funcionalidade

```dart
// Código: ligas_screen.dart (linhas 599-671)
void _showHistoricoCalculos() {
  final historico = _dataService.ligas;
  
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Histórico de Cálculos', style: TextStyle(fontSize: 20)),
          Expanded(
            child: historico.isEmpty
                ? Center(child: Text('Nenhum cálculo salvo ainda'))
                : ListView.builder(
                    itemCount: historico.length,
                    itemBuilder: (context, index) {
                      final liga = historico[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(liga.norma[0])),
                        title: Text(liga.codigo),
                        subtitle: Text(
                          '${liga.pesoTotal.toStringAsFixed(0)} kg - ${liga.dataCriacao.day}/${liga.dataCriacao.month}/${liga.dataCriacao.year}',
                        ),
                        onTap: () {
                          // Recalcular liga salva
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
```

**Recursos:**
- Lista de todos os cálculos salvos
- Exibe: Norma, Código, Peso, Data
- Clique para visualizar novamente o cálculo
- Persistência via Hive (local storage)
- Sincronização multi-usuário

**Estrutura de Dados:**

```dart
class LigaMetalurgicaModel {
  final String id;
  final String codigo;
  final String nome;
  final String norma;
  final String tipo;
  final double pesoTotal;
  final List<ElementoLiga> elementos;
  final DateTime dataCriacao;
  final String? descricao;
  final String? aplicacao;
}
```

---

## 🔗 INTEGRAÇÃO COM ESTOQUE

### Conexão com DataService

```dart
// Código: ligas_screen.dart (linhas 14-15)
final DataService _dataService = DataService();

// Verificação de disponibilidade
final disponibilidade = _dataService.verificarDisponibilidadeLiga(liga);
```

### Materiais no Estoque

O sistema busca correspondência entre elementos da liga e materiais cadastrados:

**Exemplo de Materiais no Estoque:**

| Código | Nome | Tipo | Estoque | Custo |
|--------|------|------|---------|-------|
| SI-001 | Silício Metálico | Silício (Si) | 300.0 kg | R$ 12,50/kg |
| CU-001 | Cobre Eletrolítico | Cobre (Cu) | 150.0 kg | R$ 32,00/kg |
| MG-001 | Magnésio Lingote | Magnésio (Mg) | 50.0 kg | R$ 45,00/kg |
| FE-001 | Ferro Fundido | Ferro (Fe) | 500.0 kg | R$ 3,50/kg |

**Lógica de Matching:**
```
Elemento: "Si" → Busca material com tipo contendo "Silício" ou "Si"
Elemento: "Cu" → Busca material com tipo contendo "Cobre" ou "Cu"
```

---

## 🔬 CORREÇÃO AVANÇADA

### Acesso Rápido

```dart
// Código: ligas_screen.dart (linhas 64-126)
Container(
  margin: const EdgeInsets.all(16),
  child: Card(
    elevation: 4,
    color: Colors.deepPurple.shade50,
    child: InkWell(
      onTap: () => Navigator.pushNamed(context, '/correcao-avancada'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_fix_high,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Correção Avançada de Liga',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    'Sistema inteligente com recálculo em cascata',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.deepPurple.shade300),
          ],
        ),
      ),
    ),
  ),
)
```

**Funcionalidade:**
- Card destacado no topo da tela
- Navegação para `/correcao-avancada`
- Sistema inteligente de ajuste metalúrgico
- Recálculo em cascata considerando:
  - Análise espectrométrica atual
  - Liga objetivo (target)
  - Materiais disponíveis no estoque
  - Rendimento de forno
  - Custo otimizado

---

## 🗂️ ESTRUTURA DE DADOS

### 1. LigaTemplate (Template de Liga)

```dart
class LigaTemplate {
  final String codigo;
  final String nome;
  final String norma;
  final String tipo;
  final List<ElementoLiga> elementos;
  final String? descricao;
  final String? aplicacao;
  
  LigaTemplate({
    required this.codigo,
    required this.nome,
    required this.norma,
    required this.tipo,
    required this.elementos,
    this.descricao,
    this.aplicacao,
  });
  
  // Converte template em liga calculada
  LigaMetalurgicaModel toLiga(double pesoTotal) {
    return LigaMetalurgicaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      codigo: codigo,
      nome: nome,
      norma: norma,
      tipo: tipo,
      pesoTotal: pesoTotal,
      elementos: elementos,
      dataCriacao: DateTime.now(),
      descricao: descricao,
      aplicacao: aplicacao,
    );
  }
}
```

### 2. ElementoLiga (Elemento Químico)

```dart
class ElementoLiga {
  final String simbolo;          // Ex: "Si", "Cu", "Mg"
  final String nome;             // Ex: "Silício", "Cobre", "Magnésio"
  final double percentualMinimo; // Ex: 6.5
  final double percentualMaximo; // Ex: 7.5
  final double percentualNominal; // Ex: 7.0
  final double rendimentoForno;  // Ex: 95.0 (%)
  
  ElementoLiga({
    required this.simbolo,
    required this.nome,
    required this.percentualMinimo,
    required this.percentualMaximo,
    required this.percentualNominal,
    required this.rendimentoForno,
  });
  
  double calcularQuantidadeLiga(double pesoTotal) {
    return pesoTotal * (percentualNominal / 100);
  }
  
  double calcularQuantidadeNecessaria(double pesoTotal) {
    final qtdLiga = calcularQuantidadeLiga(pesoTotal);
    return qtdLiga / (rendimentoForno / 100);
  }
}
```

### 3. LigaMetalurgicaModel (Liga Calculada)

```dart
class LigaMetalurgicaModel {
  final String id;
  final String codigo;
  final String nome;
  final String norma;
  final String tipo;
  final double pesoTotal;
  final List<ElementoLiga> elementos;
  final DateTime dataCriacao;
  final String? descricao;
  final String? aplicacao;
  
  LigaMetalurgicaModel({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.norma,
    required this.tipo,
    required this.pesoTotal,
    required this.elementos,
    required this.dataCriacao,
    this.descricao,
    this.aplicacao,
  });
}
```

---

## ➕ COMO ADICIONAR NOVAS LIGAS

### Passo a Passo

#### 1. Abrir `liga_templates_service.dart`

```dart
// Arquivo: lib/services/liga_templates_service.dart
```

#### 2. Adicionar nova liga na lista `ligasTemplates`

```dart
List<LigaTemplate> get ligasTemplates => [
  // Ligas existentes...
  
  // Nova liga
  _createNOVA_LIGA(), // Adicione aqui
];
```

#### 3. Criar método de criação da liga

```dart
// Template de exemplo
LigaTemplate _createNOVA_LIGA() {
  return LigaTemplate(
    codigo: 'CODIGO_LIGA',           // Ex: "SAE 355"
    nome: 'Nome da Liga',             // Ex: "Liga SAE 355 (Al-Si-Mg)"
    norma: 'NORMA',                   // SAE, ASTM, DIN, ou AA
    tipo: 'Alumínio',                 // Tipo de metal
    descricao: 'Descrição técnica',   // Características da liga
    aplicacao: 'Aplicações práticas', // Onde é usada
    elementos: [
      ElementoLiga(
        simbolo: 'Si',
        nome: 'Silício',
        percentualMinimo: 4.5,
        percentualMaximo: 5.5,
        percentualNominal: 5.0,
        rendimentoForno: 95.0,
      ),
      ElementoLiga(
        simbolo: 'Cu',
        nome: 'Cobre',
        percentualMinimo: 1.0,
        percentualMaximo: 1.5,
        percentualNominal: 1.25,
        rendimentoForno: 98.0,
      ),
      // Adicione mais elementos conforme necessário
    ],
  );
}
```

#### 4. Reiniciar aplicação

```bash
# Limpar cache e reconstruir
cd /home/user/flutter_app
rm -rf build/web .dart_tool/build_cache
flutter pub get
flutter build web --release
```

### Exemplo Completo: Adicionar SAE 355

```dart
// 1. Adicionar na lista
List<LigaTemplate> get ligasTemplates => [
  // ... ligas existentes
  _createSAE_355(),
];

// 2. Criar método
LigaTemplate _createSAE_355() {
  return LigaTemplate(
    codigo: 'SAE 355',
    nome: 'Liga SAE 355 (Al-Si-Mg Modificada)',
    norma: 'SAE',
    tipo: 'Alumínio',
    descricao: 'Liga Al-Si-Mg com adição de cobre para maior resistência',
    aplicacao: 'Componentes estruturais de alta resistência',
    elementos: [
      ElementoLiga(
        simbolo: 'Si',
        nome: 'Silício',
        percentualMinimo: 4.5,
        percentualMaximo: 5.5,
        percentualNominal: 5.0,
        rendimentoForno: 95.0,
      ),
      ElementoLiga(
        simbolo: 'Cu',
        nome: 'Cobre',
        percentualMinimo: 1.0,
        percentualMaximo: 1.5,
        percentualNominal: 1.25,
        rendimentoForno: 98.0,
      ),
      ElementoLiga(
        simbolo: 'Mg',
        nome: 'Magnésio',
        percentualMinimo: 0.40,
        percentualMaximo: 0.60,
        percentualNominal: 0.50,
        rendimentoForno: 90.0,
      ),
      ElementoLiga(
        simbolo: 'Fe',
        nome: 'Ferro',
        percentualMinimo: 0.0,
        percentualMaximo: 0.6,
        percentualNominal: 0.3,
        rendimentoForno: 98.0,
      ),
    ],
  );
}
```

---

## 🔧 TROUBLESHOOTING

### Problema 1: Liga não aparece na lista

**Sintoma:** Nova liga adicionada mas não é exibida

**Solução:**
```bash
# 1. Verificar se método foi criado
grep "_createNOVA_LIGA" lib/services/liga_templates_service.dart

# 2. Verificar se foi adicionado à lista ligasTemplates
grep "ligasTemplates =>" lib/services/liga_templates_service.dart

# 3. Limpar cache e reconstruir
rm -rf build/web .dart_tool/build_cache
flutter pub get
flutter build web --release
```

### Problema 2: Filtro por norma não funciona

**Sintoma:** Ao selecionar norma, nenhuma liga é exibida

**Causa:** Norma digitada diferente do esperado

**Solução:**
```dart
// Verificar valores válidos
const String norma = 'SAE';  // ✅ Correto
const String norma = 'sae';  // ❌ Errado (case-sensitive)
```

### Problema 3: Cálculo de quantidade incorreto

**Sintoma:** Quantidade necessária não considera rendimento

**Solução:**
```dart
// Verificar implementação
double calcularQuantidadeNecessaria(double pesoTotal) {
  final qtdLiga = calcularQuantidadeLiga(pesoTotal);
  return qtdLiga / (rendimentoForno / 100); // Dividir, não multiplicar!
}
```

### Problema 4: Histórico não salva

**Sintoma:** Cálculos não aparecem no histórico

**Causa:** Método `_salvarCalculo` não está sendo chamado

**Solução:**
```dart
// Código: ligas_screen.dart (linhas 584-589)
void _salvarCalculo(LigaMetalurgicaModel liga) {
  _dataService.adicionarLiga(liga);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Cálculo salvo com sucesso!')),
  );
}

// Verificar se botão chama este método
ElevatedButton.icon(
  onPressed: () {
    _salvarCalculo(liga); // ✅ Correto
    Navigator.pop(context);
  },
  icon: const Icon(Icons.save),
  label: const Text('Salvar Cálculo'),
)
```

### Problema 5: Disponibilidade sempre falsa

**Sintoma:** Todos os elementos marcados como indisponíveis

**Causa:** Material não cadastrado no estoque ou nome incompatível

**Solução:**
```dart
// Verificar materiais cadastrados
final materiais = dataService.materiais;
print('Materiais no estoque:');
for (var mat in materiais) {
  print('${mat.codigo} - ${mat.nome} - Tipo: ${mat.tipo}');
}

// Adicionar material faltante
final novoMaterial = MaterialModel(
  id: 'MAT-SI',
  codigo: 'SI-001',
  nome: 'Silício Metálico',
  tipo: 'Silício (Si)', // Deve conter o símbolo do elemento
  unidade: 'kg',
  estoque: 300.0,
  estoqueMinimo: 50.0,
  custoUnitario: 12.50,
);
dataService.adicionarMaterial(novoMaterial);
```

---

## 📊 ESTATÍSTICAS DA BIBLIOTECA

### Resumo Geral

| Métrica | Valor |
|---------|-------|
| **Total de Ligas** | 21 ligas |
| **Normas Suportadas** | 4 (SAE, ASTM, DIN, AA) |
| **Elementos Químicos** | 9 elementos |
| **Linhas de Código** | ~1.300 linhas |

### Distribuição por Norma

| Norma | Quantidade | Percentual |
|-------|------------|------------|
| SAE | 10 ligas | 47.6% |
| ASTM | 5 ligas | 23.8% |
| DIN / EN 1706 | 4 ligas | 19.0% |
| AA | 3 ligas | 14.3% |

### Elementos Mais Comuns

| Elemento | Presente em | Percentual |
|----------|-------------|------------|
| Si (Silício) | 21 ligas | 100% |
| Fe (Ferro) | 21 ligas | 100% |
| Cu (Cobre) | 16 ligas | 76.2% |
| Mg (Magnésio) | 14 ligas | 66.7% |
| Zn (Zinco) | 11 ligas | 52.4% |
| Mn (Manganês) | 8 ligas | 38.1% |
| Ti (Titânio) | 7 ligas | 33.3% |
| Ni (Níquel) | 5 ligas | 23.8% |
| Sn (Estanho) | 4 ligas | 19.0% |

---

## 🎓 REFERÊNCIAS TÉCNICAS

### Normas Utilizadas

1. **SAE J452** - Aluminum Casting Alloy Composition Limits
2. **ASTM B108** - Standard Specification for Aluminum-Alloy Permanent Mold Castings
3. **DIN EN 1706** - Aluminium and aluminium alloys - Castings
4. **AA** - Aluminum Association Standards

### Documentos de Referência

- Almeida Metais 2025 - Especificações SAE 306, 309, 323, 329
- Alumiza 2025 - Especificações SAE 305 C e 305 I
- ASM International - Aluminum Casting Technology
- AFS - American Foundry Society Guidelines

---

## ✅ CHECKLIST DE VALIDAÇÃO

Ao adicionar ou modificar ligas, verifique:

- [ ] Código da liga é único
- [ ] Norma está correta (SAE, ASTM, DIN, AA)
- [ ] Todos os elementos têm percentual mínimo, máximo e nominal
- [ ] Rendimento de forno está entre 85-100%
- [ ] Percentual nominal está dentro do range (min-max)
- [ ] Descrição técnica está clara
- [ ] Aplicações práticas estão listadas
- [ ] Soma dos percentuais não excede 100%
- [ ] Liga foi adicionada à lista `ligasTemplates`
- [ ] Sistema foi testado após a adição

---

## 📝 CONCLUSÃO

A **Aba Ligas Metalúrgicas** é um módulo robusto e profissional para gestão de composições metalúrgicas em fundições de alumínio. Com 21 ligas pré-cadastradas seguindo normas internacionais, cálculo automático considerando rendimento de forno, verificação de disponibilidade integrada ao estoque e histórico persistente, o sistema oferece uma solução completa para engenheiros metalúrgicos e gestores de produção.

**Principais Diferenciais:**
- ✅ Biblioteca extensa e atualizada (2025)
- ✅ Cálculos precisos com rendimento real
- ✅ Interface intuitiva e visual
- ✅ Integração completa com sistema de estoque
- ✅ Persistência local com Hive
- ✅ Sincronização multi-usuário
- ✅ Acesso rápido à Correção Avançada

---

**Foundry ERP v3.0 Final**  
Sistema de Gestão para Indústrias de Fundição  
Gerado em: 09/12/2025

---

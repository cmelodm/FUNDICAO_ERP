import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/analise_espectrometrica.dart';
import '../models/liga_metalurgica_model.dart';
import '../models/material_correcao_model.dart';
import '../models/tipo_correcao_enum.dart';
import '../services/correcao_avancada_service.dart';
import '../services/data_service.dart';
import '../services/liga_templates_service.dart';
import '../services/pdf_export_service.dart';

class CorrecaoAvancadaScreen extends StatefulWidget {
  const CorrecaoAvancadaScreen({super.key});

  @override
  State<CorrecaoAvancadaScreen> createState() => _CorrecaoAvancadaScreenState();
}

class _CorrecaoAvancadaScreenState extends State<CorrecaoAvancadaScreen> {
  final _service = CorrecaoAvancadaService();
  final _templatesService = LigaTemplatesService();
  final _pdfService = PdfExportService();
  
  AnaliseEspectrometrica? _analiseSelecionada;
  LigaMetalurgicaModel? _ligaSelecionada;
  List<MaterialCorrecao> _materiaisSelecionados = [];
  double _massaForno = 1000.0;
  double _tolerancia = 2.0;
  ResultadoCorrecaoCompleta? _resultado;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Correção Avançada de Liga'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _resultado != null 
          ? _buildResultado()
          : _buildFormulario(dataService),
    );
  }

  Widget _buildFormulario(DataService dataService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informações
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Correção Múltipla com Recálculo em Cascata',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistema inteligente que corrige automaticamente múltiplos '
                    'elementos químicos considerando impactos cruzados.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 1. Seleção de Análise
          const Text(
            '1. Análise Espectrométrica',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          DropdownButtonFormField<AnaliseEspectrometrica>(
            value: _analiseSelecionada,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecione a análise',
              prefixIcon: Icon(Icons.science),
            ),
            items: dataService.analises.map((analise) {
              return DropdownMenuItem(
                value: analise,
                child: Text('${analise.ligaCodigo} - OP ${analise.ordemProducaoId}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _analiseSelecionada = value;
                // Carregar liga correspondente
                if (value != null) {
                  final template = _templatesService.buscarPorCodigo(value.ligaCodigo);
                  if (template != null) {
                    _ligaSelecionada = LigaMetalurgicaModel(
                      id: template.codigo,
                      nome: template.nome,
                      codigo: template.codigo,
                      norma: template.norma,
                      tipo: template.tipo,
                      pesoTotal: _massaForno,
                      elementos: template.elementos,
                      dataCriacao: DateTime.now(),
                    );
                  }
                }
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // 2. Massa do Forno
          const Text(
            '2. Massa do Forno',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          TextFormField(
            initialValue: _massaForno.toString(),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Massa (kg)',
              prefixIcon: Icon(Icons.scale),
              suffixText: 'kg',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _massaForno = double.tryParse(value) ?? 1000.0;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // 3. Materiais Disponíveis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3. Materiais para Correção',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _mostrarModalAdicionarMateriais(dataService),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Adicionar Materiais'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                // 🔥 MATERIAIS FIXOS PRÉ-DEFINIDOS
                CheckboxListTile(
                  title: const Text('Alumínio Primário 99.7%'),
                  subtitle: const Text('R\$ 12,50/kg | Diluente universal'),
                  secondary: const Icon(Icons.layers),
                  value: _materiaisSelecionados.any((m) => m.codigo == 'AL-PRIM'),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _materiaisSelecionados.add(_criarAluminioPrimario());
                      } else {
                        _materiaisSelecionados.removeWhere((m) => m.codigo == 'AL-PRIM');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Liga-Mãe Al-Cu 50%'),
                  subtitle: const Text('R\$ 45,00/kg | Aditivo de Cobre'),
                  secondary: const Icon(Icons.add_box),
                  value: _materiaisSelecionados.any((m) => m.codigo == 'LM-CU50'),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _materiaisSelecionados.add(_criarLigaMaeCu50());
                      } else {
                        _materiaisSelecionados.removeWhere((m) => m.codigo == 'LM-CU50');
                      }
                    });
                  },
                ),
                
                // 🔥 MATERIAIS ADICIONADOS DO ESTOQUE (DINÂMICO)
                ..._materiaisSelecionados
                    .where((m) => m.codigo != 'AL-PRIM' && m.codigo != 'LM-CU50')
                    .map((material) => CheckboxListTile(
                          title: Text(material.nome),
                          subtitle: Text(
                            'R\$ ${material.custoKg.toStringAsFixed(2)}/kg | '
                            'Estoque: ${material.estoqueDisponivel.toStringAsFixed(2)} kg',
                          ),
                          secondary: const Icon(Icons.inventory_2, color: Colors.deepPurple),
                          value: true, // Sempre marcado (já foi adicionado)
                          onChanged: (checked) {
                            setState(() {
                              if (checked == false) {
                                _materiaisSelecionados.removeWhere((m) => m.codigo == material.codigo);
                              }
                            });
                          },
                        ))
                    .toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 4. Tolerância
          const Text(
            '4. Tolerância',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tolerância Aceitável:'),
                      Text(
                        '${_tolerancia.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _tolerancia,
                    min: 0.5,
                    max: 10.0,
                    divisions: 19,
                    label: '${_tolerancia.toStringAsFixed(1)}%',
                    onChanged: (value) {
                      setState(() {
                        _tolerancia = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botão Executar
          ElevatedButton.icon(
            onPressed: _canExecute() ? _executarCorrecao : null,
            icon: _isProcessing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isProcessing ? 'Processando...' : 'Executar Correção'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultado() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Geral
          Card(
            color: _resultado!.todosElementosOk 
                ? Colors.green.shade50 
                : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    _resultado!.todosElementosOk 
                        ? Icons.check_circle 
                        : Icons.warning,
                    size: 48,
                    color: _resultado!.todosElementosOk 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resultado!.todosElementosOk 
                        ? 'Correção Concluída com Sucesso!'
                        : 'Correção Parcial',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estatísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Iterações',
                  _resultado!.numeroIteracoes.toString(),
                  Icons.sync,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Correções',
                  _resultado!.correcoes.length.toString(),
                  Icons.build,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Custo Total',
                  'R\$ ${_resultado!.custoTotal.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Incremento',
                  '${((_resultado!.massaTotalAdicionada / _resultado!.massaInicialForno) * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Lista de Correções
          const Text(
            'Correções Aplicadas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          ..._resultado!.correcoes.map((correcao) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: correcao.tipoCorrecao == TipoCorrecao.adicao 
                    ? Colors.green 
                    : Colors.blue,
                child: Icon(
                  correcao.tipoCorrecao == TipoCorrecao.adicao 
                      ? Icons.add 
                      : Icons.remove,
                  color: Colors.white,
                ),
              ),
              title: Text('${correcao.simbolo} - ${correcao.nome}'),
              subtitle: Text(
                '${correcao.concentracaoInicial.toStringAsFixed(2)}% → '
                '${correcao.concentracaoFinal.toStringAsFixed(2)}%\n'
                'Material: ${correcao.materialUtilizado}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${correcao.massaMaterialAdicionado.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'R\$ ${correcao.custoCorrecao.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          )).toList(),
          
          const SizedBox(height: 16),
          
          // Botões de Ação
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _resultado = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nova Correção'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _pdfService.exportarCorrecaoPDF(_resultado!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ PDF exportado com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Erro ao exportar PDF: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exportar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canExecute() {
    return _analiseSelecionada != null &&
           _ligaSelecionada != null &&
           _materiaisSelecionados.isNotEmpty &&
           !_isProcessing;
  }

  Future<void> _executarCorrecao() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final resultado = await _service.executarCorrecao(
        analiseInicial: _analiseSelecionada!,
        ligaAlvo: _ligaSelecionada!,
        massaAtualForno: _massaForno,
        materiaisDisponiveis: _materiaisSelecionados,
        toleranciaPercentual: _tolerancia,
        maxIteracoes: 10,
      );

      // Atualizar status da análise no DataService
      final dataService = Provider.of<DataService>(context, listen: false);
      await dataService.atualizarAnaliseAposCorrecao(_analiseSelecionada!);

      setState(() {
        _resultado = resultado;
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resultado.todosElementosOk 
                  ? '✅ Correção concluída com sucesso!' 
                  : '⚠️ Correção parcial realizada',
            ),
            backgroundColor: resultado.todosElementosOk 
                ? Colors.green 
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro na correção: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Materiais pré-definidos
  MaterialCorrecao _criarAluminioPrimario() {
    return MaterialCorrecao(
      id: 'MAT_AL_PRIM',
      nome: 'Alumínio Primário 99.7%',
      codigo: 'AL-PRIM',
      tipo: TipoMaterialCorrecao.primario,
      composicao: {
        'Si': 0.1, 'Cu': 0.0, 'Fe': 0.15, 
        'Mg': 0.0, 'Mn': 0.0, 'Zn': 0.0,
      },
      rendimentos: {
        'Si': 95.0, 'Cu': 98.0, 'Fe': 98.0,
        'Mg': 90.0, 'Mn': 95.0, 'Zn': 98.0,
      },
      custoKg: 12.50,
      estoqueDisponivel: 10000.0,
    );
  }

  MaterialCorrecao _criarLigaMaeCu50() {
    return MaterialCorrecao(
      id: 'MAT_CU_50',
      nome: 'Liga-Mãe Al-Cu 50%',
      codigo: 'LM-CU50',
      tipo: TipoMaterialCorrecao.ligaMae,
      composicao: {
        'Si': 0.5, 'Cu': 50.0, 'Fe': 0.2,
        'Mg': 0.0, 'Mn': 0.0, 'Zn': 0.0,
      },
      rendimentos: {
        'Si': 95.0, 'Cu': 98.0, 'Fe': 98.0,
        'Mg': 90.0, 'Mn': 95.0, 'Zn': 98.0,
      },
      custoKg: 45.00,
      estoqueDisponivel: 1000.0,
    );
  }
  
  /// 🔥 Modal para adicionar materiais do estoque
  void _mostrarModalAdicionarMateriais(DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_box, color: Colors.deepPurple),
            const SizedBox(width: 12),
            const Text('Adicionar Materiais do Estoque'),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 500,
          child: dataService.materiais.isEmpty
              ? const Center(
                  child: Text('Nenhum material disponível no estoque'),
                )
              : ListView.builder(
                  itemCount: dataService.materiais.length,
                  itemBuilder: (context, index) {
                    final material = dataService.materiais[index];
                    final jaAdicionado = _materiaisSelecionados
                        .any((m) => m.codigo == material.codigo);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: jaAdicionado 
                              ? Colors.green 
                              : Colors.grey[300],
                          child: Icon(
                            jaAdicionado ? Icons.check : Icons.inventory_2,
                            color: jaAdicionado ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        title: Text(material.nome),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Código: ${material.codigo}'),
                            Text('Tipo: ${material.tipo}'),
                            Text(
                              'Estoque: ${material.quantidadeEstoque.toStringAsFixed(2)} kg',
                              style: TextStyle(
                                color: material.quantidadeEstoque < material.estoqueMinimo
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Custo: R\$ ${material.custoUnitario.toStringAsFixed(2)}/kg'),
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: jaAdicionado
                              ? null
                              : () {
                                  // 🔥 CORRIGIDO: Adiciona material e fecha modal
                                  final materialParaAdicionar = _converterMaterialParaCorrecao(material);
                                  Navigator.pop(context); // Fecha modal primeiro
                                  
                                  // 🔥 Atualiza tela principal DEPOIS de fechar modal
                                  setState(() {
                                    _materiaisSelecionados.add(materialParaAdicionar);
                                  });
                                  
                                  // Mostra confirmação
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✅ Material "${material.nome}" adicionado!',
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                          icon: Icon(jaAdicionado ? Icons.check : Icons.add),
                          label: Text(jaAdicionado ? 'Adicionado' : 'Adicionar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: jaAdicionado 
                                ? Colors.grey 
                                : Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
  
  /// Converte MaterialModel para MaterialCorrecao
  MaterialCorrecao _converterMaterialParaCorrecao(dynamic material) {
    return MaterialCorrecao(
      id: material.id,
      nome: material.nome,
      codigo: material.codigo,
      tipo: _determinarTipoMaterial(material.tipo),
      composicao: {
        'Si': 0.0, 'Cu': 0.0, 'Fe': 0.0,
        'Mg': 0.0, 'Mn': 0.0, 'Zn': 0.0,
      }, // Composição genérica - pode ser customizada
      rendimentos: {
        'Si': 95.0, 'Cu': 98.0, 'Fe': 98.0,
        'Mg': 90.0, 'Mn': 95.0, 'Zn': 98.0,
      },
      custoKg: material.custoUnitario,
      estoqueDisponivel: material.quantidadeEstoque,
    );
  }
  
  /// Determina tipo de material para correção
  TipoMaterialCorrecao _determinarTipoMaterial(String tipoOriginal) {
    final tipo = tipoOriginal.toLowerCase();
    
    if (tipo.contains('alumínio') || tipo.contains('aluminio')) {
      return TipoMaterialCorrecao.primario;
    } else if (tipo.contains('liga')) {
      return TipoMaterialCorrecao.ligaMae;
    } else if (tipo.contains('sucata')) {
      return TipoMaterialCorrecao.sucata;
    } else {
      return TipoMaterialCorrecao.primario; // Padrão
    }
  }
}

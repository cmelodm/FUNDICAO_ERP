import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/liga_metalurgica_model.dart';
import '../models/analise_espectrometrica.dart';
import '../services/data_service.dart';
import '../services/correcao_liga_service.dart';
import '../services/liga_templates_service.dart';

class AnaliseEspectrometricaScreen extends StatefulWidget {
  const AnaliseEspectrometricaScreen({super.key});

  @override
  State<AnaliseEspectrometricaScreen> createState() => _AnaliseEspectrometricaScreenState();
}

class _AnaliseEspectrometricaScreenState extends State<AnaliseEspectrometricaScreen> {
  final _formKey = GlobalKey<FormState>();
  LigaTemplate? _ligaSelecionada;
  final _pesoLigaController = TextEditingController(text: '5000');
  final Map<String, TextEditingController> _percentuaisControllers = {};
  AnaliseEspectrometrica? _analiseAtual;
  CorrecaoLiga? _correcaoCalculada;

  @override
  void dispose() {
    _pesoLigaController.dispose();
    for (var controller in _percentuaisControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selecionarLiga(LigaTemplate? liga) {
    setState(() {
      _ligaSelecionada = liga;
      _analiseAtual = null;
      _correcaoCalculada = null;
      _percentuaisControllers.clear();
      
      if (liga != null) {
        for (var elemento in liga.elementos) {
          _percentuaisControllers[elemento.simbolo] = TextEditingController();
        }
      }
    });
  }

  void _analisarComposicao() {
    if (!_formKey.currentState!.validate()) return;
    if (_ligaSelecionada == null) return;

    final dataService = Provider.of<DataService>(context, listen: false);
    final ligaRef = _ligaSelecionada!.toLiga(double.parse(_pesoLigaController.text));

    final elementosAnalisados = <ElementoAnalisado>[];
    final elementosForaRange = <String>[];

    for (var elemento in ligaRef.elementos) {
      final percentualMedido = double.parse(_percentuaisControllers[elemento.simbolo]!.text);
      final dentroRange = percentualMedido >= elemento.percentualMinimo && 
                         percentualMedido <= elemento.percentualMaximo;
      
      if (!dentroRange) {
        elementosForaRange.add(elemento.simbolo);
      }

      double? desvio;
      if (percentualMedido < elemento.percentualMinimo) {
        desvio = percentualMedido - elemento.percentualMinimo;
      } else if (percentualMedido > elemento.percentualMaximo) {
        desvio = percentualMedido - elemento.percentualMaximo;
      }

      elementosAnalisados.add(ElementoAnalisado(
        simbolo: elemento.simbolo,
        nome: elemento.nome,
        percentualMedido: percentualMedido,
        percentualMinimo: elemento.percentualMinimo,
        percentualMaximo: elemento.percentualMaximo,
        dentroRange: dentroRange,
        desvio: desvio,
      ));
    }

    final analise = AnaliseEspectrometrica(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ligaId: ligaRef.id,
      ligaNome: ligaRef.nome,
      ligaCodigo: ligaRef.codigo,
      ordemProducaoId: 'OP-TESTE', // TODO: vincular OP real
      equipamentoId: 'EQ-SPEC-001', // TODO: selecionar equipamento
      operadorId: 'OP-001', // TODO: usuário logado
      operadorNome: 'Operador Sistema',
      dataHoraAnalise: DateTime.now(),
      elementos: elementosAnalisados,
      status: elementosForaRange.isEmpty ? StatusAnalise.aprovado : StatusAnalise.aguardandoCorrecao,
      createdAt: DateTime.now(),
      dentroEspecificacao: elementosForaRange.isEmpty,
      elementosForaRange: elementosForaRange,
    );

    // Calcular correção se necessário
    CorrecaoLiga? correcao;
    if (elementosForaRange.isNotEmpty) {
      final materiaisElementos = <String, String>{};
      for (var material in dataService.materiais) {
        if (material.tipo == 'Elemento') {
          for (var elemento in ligaRef.elementos) {
            if (material.nome.contains(elemento.nome)) {
              materiaisElementos[elemento.simbolo] = material.id;
            }
          }
        }
      }

      correcao = CorrecaoLigaService.calcularCorrecao(
        analise,
        ligaRef,
        double.parse(_pesoLigaController.text),
        materiaisElementos,
      );
    }

    setState(() {
      _analiseAtual = analise;
      _correcaoCalculada = correcao;
    });

    dataService.adicionarAnalise(analise);
  }

  Future<void> _autorizarVazamento() async {
    if (_analiseAtual == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Autorização'),
        content: const Text('Deseja autorizar o vazamento desta liga?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('AUTORIZAR VAZAMENTO'),
          ),
        ],
      ),
    );

    if (confirmado == true && mounted) {
      final dataService = Provider.of<DataService>(context, listen: false);
      final analiseAtualizada = _analiseAtual!.copyWith(
        status: StatusAnalise.autorizadoVazamento,
        autorizadoVazamento: true,
        autorizadoPor: 'Sistema', // TODO: usuário logado
        dataAutorizacao: DateTime.now(),
      );

      await dataService.atualizarAnalise(analiseAtualizada);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ VAZAMENTO AUTORIZADO'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _analiseAtual = analiseAtualizada;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesService = LigaTemplatesService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análise Espectrométrica'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seleção de Liga
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Selecionar Liga',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<LigaTemplate>(
                      value: _ligaSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Liga para Análise',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.science),
                      ),
                      items: templatesService.ligasTemplates.map((liga) {
                        return DropdownMenuItem(
                          value: liga,
                          child: Text(liga.codigo + ' - ' + liga.nome),
                        );
                      }).toList(),
                      onChanged: _selecionarLiga,
                    ),
                  ],
                ),
              ),
            ),

            if (_ligaSelecionada != null) ...[
              const SizedBox(height: 16),

              // Peso da Liga
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '2. Peso no Forno',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pesoLigaController,
                        decoration: const InputDecoration(
                          labelText: 'Peso Total (kg)',
                          border: OutlineInputBorder(),
                          suffixText: 'kg',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Obrigatório';
                          if (double.tryParse(value!) == null) return 'Número inválido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dados do Espectrômetro
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '3. Resultado do Espectrômetro',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._ligaSelecionada!.elementos.map((elemento) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  '${elemento.simbolo} (${elemento.nome}):',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _percentuaisControllers[elemento.simbolo],
                                  decoration: InputDecoration(
                                    labelText: 'Percentual Medido',
                                    hintText: '${elemento.percentualMinimo.toStringAsFixed(2)} - ${elemento.percentualMaximo.toStringAsFixed(2)}%',
                                    border: const OutlineInputBorder(),
                                    suffix: const Text('%'),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Obrigatório';
                                    if (double.tryParse(value!) == null) return 'Inválido';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Range: ${elemento.percentualMinimo.toStringAsFixed(2)}-${elemento.percentualMaximo.toStringAsFixed(2)}%',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _analisarComposicao,
                          icon: const Icon(Icons.analytics),
                          label: const Text('ANALISAR COMPOSIÇÃO'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Resultado da Análise
            if (_analiseAtual != null) ...[
              const SizedBox(height: 24),
              Card(
                color: _analiseAtual!.dentroEspecificacao == true ? Colors.green.shade50 : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        _analiseAtual!.dentroEspecificacao == true ? Icons.check_circle : Icons.warning,
                        size: 48,
                        color: _analiseAtual!.dentroEspecificacao == true ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _analiseAtual!.dentroEspecificacao == true
                            ? '✅ LIGA APROVADA'
                            : '⚠️ CORREÇÃO NECESSÁRIA',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ..._analiseAtual!.elementos.map((elem) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: elem.dentroRange ? Colors.green : Colors.red,
                            child: Text(elem.simbolo),
                          ),
                          title: Text('${elem.nome}: ${elem.percentualMedido.toStringAsFixed(3)}%'),
                          subtitle: Text(
                            'Range: ${elem.percentualMinimo.toStringAsFixed(2)}% - ${elem.percentualMaximo.toStringAsFixed(2)}%'
                            + (elem.desvio != null ? ' | Desvio: ${elem.desvio!.toStringAsFixed(3)}%' : ''),
                          ),
                          trailing: Icon(
                            elem.dentroRange ? Icons.check : Icons.close,
                            color: elem.dentroRange ? Colors.green : Colors.red,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Correções Sugeridas
              if (_correcaoCalculada != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Correções Sugeridas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        ..._correcaoCalculada!.correcoes.map((correcao) {
                          return ListTile(
                            leading: const Icon(Icons.add_circle, color: Colors.blue),
                            title: Text('Adicionar ${correcao.quantidadeAdicionar.toStringAsFixed(2)} kg de ${correcao.materialNome}'),
                            subtitle: Text(
                              'De ${correcao.percentualAtual.toStringAsFixed(3)}% para ${correcao.percentualDesejado.toStringAsFixed(2)}%',
                            ),
                          );
                        }),
                        const Divider(),
                        Text(
                          'Peso Total de Correção: ${_correcaoCalculada!.pesoTotalCorrecao.toStringAsFixed(2)} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Botões de Ação
              const SizedBox(height: 24),
              if (_analiseAtual!.dentroEspecificacao == true && _analiseAtual!.autorizadoVazamento != true)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _autorizarVazamento,
                    icon: const Icon(Icons.verified),
                    label: const Text('AUTORIZAR VAZAMENTO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                ),

              if (_analiseAtual!.autorizadoVazamento == true)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 32),
                      const SizedBox(width: 8),
                      const Text(
                        'VAZAMENTO AUTORIZADO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

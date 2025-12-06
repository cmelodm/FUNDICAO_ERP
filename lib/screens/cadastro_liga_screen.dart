import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/liga_metalurgica_model.dart';
import '../services/data_service.dart';

class CadastroLigaScreen extends StatefulWidget {
  final LigaMetalurgicaModel? ligaExistente;

  const CadastroLigaScreen({super.key, this.ligaExistente});

  @override
  State<CadastroLigaScreen> createState() => _CadastroLigaScreenState();
}

class _CadastroLigaScreenState extends State<CadastroLigaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _aplicacaoController = TextEditingController();
  
  String _normaSelecionadaValue = 'CUSTOM';
  String _tipoSelecionado = 'Alumínio';
  
  final List<ElementoLigaFormData> _elementos = [];

  final List<String> _normas = ['CUSTOM', 'SAE', 'ASTM', 'DIN', 'AA', 'ABNT'];
  final List<String> _tipos = ['Alumínio', 'Bronze', 'Latão', 'Ferro', 'Aço'];
  
  final List<Map<String, String>> _elementosDisponiveis = [
    {'simbolo': 'Si', 'nome': 'Silício'},
    {'simbolo': 'Cu', 'nome': 'Cobre'},
    {'simbolo': 'Fe', 'nome': 'Ferro'},
    {'simbolo': 'Mg', 'nome': 'Magnésio'},
    {'simbolo': 'Mn', 'nome': 'Manganês'},
    {'simbolo': 'Zn', 'nome': 'Zinco'},
    {'simbolo': 'Ti', 'nome': 'Titânio'},
    {'simbolo': 'Al', 'nome': 'Alumínio'},
    {'simbolo': 'Ni', 'nome': 'Níquel'},
    {'simbolo': 'Cr', 'nome': 'Cromo'},
    {'simbolo': 'Pb', 'nome': 'Chumbo'},
    {'simbolo': 'Sn', 'nome': 'Estanho'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.ligaExistente != null) {
      _carregarLigaExistente();
    }
  }

  void _carregarLigaExistente() {
    final liga = widget.ligaExistente!;
    _nomeController.text = liga.nome;
    _codigoController.text = liga.codigo;
    _descricaoController.text = liga.descricao ?? '';
    _aplicacaoController.text = liga.aplicacao ?? '';
    _normaSelecionadaValue = liga.norma;
    _tipoSelecionado = liga.tipo;
    
    for (var elemento in liga.elementos) {
      _elementos.add(ElementoLigaFormData(
        simbolo: elemento.simbolo,
        nome: elemento.nome,
        percentualMinimo: elemento.percentualMinimo,
        percentualMaximo: elemento.percentualMaximo,
        percentualNominal: elemento.percentualNominal,
        rendimentoForno: elemento.rendimentoForno,
      ));
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _descricaoController.dispose();
    _aplicacaoController.dispose();
    super.dispose();
  }

  void _adicionarElemento() {
    showDialog(
      context: context,
      builder: (context) => _AdicionarElementoDialog(
        elementosDisponiveis: _elementosDisponiveis,
        elementosJaAdicionados: _elementos.map((e) => e.simbolo).toList(),
        onAdicionar: (elemento) {
          setState(() {
            _elementos.add(elemento);
          });
        },
      ),
    );
  }

  void _removerElemento(int index) {
    setState(() {
      _elementos.removeAt(index);
    });
  }

  void _editarElemento(int index) {
    final elemento = _elementos[index];
    showDialog(
      context: context,
      builder: (context) => _EditarElementoDialog(
        elemento: elemento,
        onSalvar: (elementoAtualizado) {
          setState(() {
            _elementos[index] = elementoAtualizado;
          });
        },
      ),
    );
  }

  Future<void> _salvarLiga() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_elementos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um elemento à liga'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final dataService = Provider.of<DataService>(context, listen: false);

    final elementos = _elementos.map((e) => ElementoLiga(
      simbolo: e.simbolo,
      nome: e.nome,
      percentualMinimo: e.percentualMinimo,
      percentualMaximo: e.percentualMaximo,
      percentualNominal: e.percentualNominal,
      rendimentoForno: e.rendimentoForno,
    )).toList();

    if (widget.ligaExistente != null) {
      // Atualizar liga existente
      final ligaAtualizada = widget.ligaExistente!.copyWith(
        nome: _nomeController.text,
        codigo: _codigoController.text,
        norma: _normaSelecionadaValue,
        tipo: _tipoSelecionado,
        elementos: elementos,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        aplicacao: _aplicacaoController.text.isEmpty ? null : _aplicacaoController.text,
        updatedAt: DateTime.now(),
      );
      await dataService.atualizarLiga(ligaAtualizada);
    } else {
      // Criar nova liga
      final novaLiga = LigaMetalurgicaModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: _nomeController.text,
        codigo: _codigoController.text,
        norma: _normaSelecionadaValue,
        tipo: _tipoSelecionado,
        pesoTotal: 0, // Será definido ao usar a liga
        elementos: elementos,
        descricao: _descricaoController.text.isEmpty ? null : _descricaoController.text,
        aplicacao: _aplicacaoController.text.isEmpty ? null : _aplicacaoController.text,
        dataCriacao: DateTime.now(),
        isCustom: true,
        criadoPor: 'Sistema', // TODO: Usar usuário logado
      );
      await dataService.adicionarLiga(novaLiga);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.ligaExistente != null ? 'Liga atualizada com sucesso!' : 'Liga cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ligaExistente != null ? 'Editar Liga' : 'Cadastrar Nova Liga'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _salvarLiga,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Informações Básicas
            const Text(
              'Informações Básicas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da Liga *',
                hintText: 'Ex: Liga Personalizada A1',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Código *',
                hintText: 'Ex: CUSTOM-001',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _normaSelecionadaValue,
              decoration: const InputDecoration(
                labelText: 'Norma',
                border: OutlineInputBorder(),
              ),
              items: _normas.map((norma) {
                return DropdownMenuItem(value: norma, child: Text(norma));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _normaSelecionadaValue = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Liga',
                border: OutlineInputBorder(),
              ),
              items: _tipos.map((tipo) {
                return DropdownMenuItem(value: tipo, child: Text(tipo));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoSelecionado = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _aplicacaoController,
              decoration: const InputDecoration(
                labelText: 'Aplicação',
                hintText: 'Ex: Fundição de peças aeronáuticas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Elementos da Liga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Composição Química',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _adicionarElemento,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_elementos.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('Nenhum elemento adicionado'),
                  ),
                ),
              )
            else
              ..._elementos.asMap().entries.map((entry) {
                final index = entry.key;
                final elemento = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(elemento.simbolo),
                    ),
                    title: Text(elemento.nome),
                    subtitle: Text(
                      '${elemento.percentualMinimo.toStringAsFixed(2)}% - ${elemento.percentualMaximo.toStringAsFixed(2)}%\n'
                      'Nominal: ${elemento.percentualNominal.toStringAsFixed(2)}% | Rendimento: ${elemento.rendimentoForno.toStringAsFixed(0)}%',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editarElemento(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _removerElemento(index),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _salvarLiga,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(widget.ligaExistente != null ? 'ATUALIZAR LIGA' : 'SALVAR LIGA'),
            ),
          ],
        ),
      ),
    );
  }
}

class ElementoLigaFormData {
  String simbolo;
  String nome;
  double percentualMinimo;
  double percentualMaximo;
  double percentualNominal;
  double rendimentoForno;

  ElementoLigaFormData({
    required this.simbolo,
    required this.nome,
    required this.percentualMinimo,
    required this.percentualMaximo,
    required this.percentualNominal,
    required this.rendimentoForno,
  });
}

class _AdicionarElementoDialog extends StatefulWidget {
  final List<Map<String, String>> elementosDisponiveis;
  final List<String> elementosJaAdicionados;
  final Function(ElementoLigaFormData) onAdicionar;

  const _AdicionarElementoDialog({
    required this.elementosDisponiveis,
    required this.elementosJaAdicionados,
    required this.onAdicionar,
  });

  @override
  State<_AdicionarElementoDialog> createState() => _AdicionarElementoDialogState();
}

class _AdicionarElementoDialogState extends State<_AdicionarElementoDialog> {
  final _formKey = GlobalKey<FormState>();
  Map<String, String>? _elementoSelecionado;
  final _percentualMinimoController = TextEditingController();
  final _percentualMaximoController = TextEditingController();
  final _percentualNominalController = TextEditingController();
  final _rendimentoController = TextEditingController(text: '95.0');

  @override
  Widget build(BuildContext context) {
    final elementosDisponiveis = widget.elementosDisponiveis
        .where((e) => !widget.elementosJaAdicionados.contains(e['simbolo']))
        .toList();

    return AlertDialog(
      title: const Text('Adicionar Elemento'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Map<String, String>>(
                value: _elementoSelecionado,
                decoration: const InputDecoration(labelText: 'Elemento'),
                items: elementosDisponiveis.map((elemento) {
                  return DropdownMenuItem(
                    value: elemento,
                    child: Text('${elemento['simbolo']} - ${elemento['nome']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _elementoSelecionado = value;
                  });
                },
                validator: (value) => value == null ? 'Selecione um elemento' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _percentualMinimoController,
                decoration: const InputDecoration(labelText: 'Percentual Mínimo (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  final val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 100) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _percentualMaximoController,
                decoration: const InputDecoration(labelText: 'Percentual Máximo (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  final val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 100) return 'Valor inválido';
                  final min = double.tryParse(_percentualMinimoController.text) ?? 0;
                  if (val < min) return 'Deve ser maior que o mínimo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _percentualNominalController,
                decoration: const InputDecoration(labelText: 'Percentual Nominal (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  final val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 100) return 'Valor inválido';
                  final min = double.tryParse(_percentualMinimoController.text) ?? 0;
                  final max = double.tryParse(_percentualMaximoController.text) ?? 100;
                  if (val < min || val > max) return 'Deve estar entre min e max';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rendimentoController,
                decoration: const InputDecoration(labelText: 'Rendimento no Forno (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  final val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 100) return 'Valor inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdicionar(ElementoLigaFormData(
                simbolo: _elementoSelecionado!['simbolo']!,
                nome: _elementoSelecionado!['nome']!,
                percentualMinimo: double.parse(_percentualMinimoController.text),
                percentualMaximo: double.parse(_percentualMaximoController.text),
                percentualNominal: double.parse(_percentualNominalController.text),
                rendimentoForno: double.parse(_rendimentoController.text),
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

class _EditarElementoDialog extends StatefulWidget {
  final ElementoLigaFormData elemento;
  final Function(ElementoLigaFormData) onSalvar;

  const _EditarElementoDialog({
    required this.elemento,
    required this.onSalvar,
  });

  @override
  State<_EditarElementoDialog> createState() => _EditarElementoDialogState();
}

class _EditarElementoDialogState extends State<_EditarElementoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _percentualMinimoController;
  late TextEditingController _percentualMaximoController;
  late TextEditingController _percentualNominalController;
  late TextEditingController _rendimentoController;

  @override
  void initState() {
    super.initState();
    _percentualMinimoController = TextEditingController(
      text: widget.elemento.percentualMinimo.toString(),
    );
    _percentualMaximoController = TextEditingController(
      text: widget.elemento.percentualMaximo.toString(),
    );
    _percentualNominalController = TextEditingController(
      text: widget.elemento.percentualNominal.toString(),
    );
    _rendimentoController = TextEditingController(
      text: widget.elemento.rendimentoForno.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ${widget.elemento.nome}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _percentualMinimoController,
                decoration: const InputDecoration(labelText: 'Percentual Mínimo (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  final val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 100) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _percentualMaximoController,
                decoration: const InputDecoration(labelText: 'Percentual Máximo (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  final val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 100) return 'Valor inválido';
                  final min = double.tryParse(_percentualMinimoController.text) ?? 0;
                  if (val < min) return 'Deve ser maior que o mínimo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _percentualNominalController,
                decoration: const InputDecoration(labelText: 'Percentual Nominal (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  final val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 100) return 'Valor inválido';
                  final min = double.tryParse(_percentualMinimoController.text) ?? 0;
                  final max = double.tryParse(_percentualMaximoController.text) ?? 100;
                  if (val < min || val > max) return 'Deve estar entre min e max';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rendimentoController,
                decoration: const InputDecoration(labelText: 'Rendimento no Forno (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo obrigatório';
                  final val = double.tryParse(value!);
                  if (val == null || val < 0 || val > 100) return 'Valor inválido';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSalvar(ElementoLigaFormData(
                simbolo: widget.elemento.simbolo,
                nome: widget.elemento.nome,
                percentualMinimo: double.parse(_percentualMinimoController.text),
                percentualMaximo: double.parse(_percentualMaximoController.text),
                percentualNominal: double.parse(_percentualNominalController.text),
                rendimentoForno: double.parse(_rendimentoController.text),
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

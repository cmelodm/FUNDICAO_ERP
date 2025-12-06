import 'package:flutter/material.dart';
import 'package:foundry_erp/models/material_model.dart';
import 'package:foundry_erp/services/data_service.dart';

class MateriaisScreen extends StatefulWidget {
  const MateriaisScreen({super.key});

  @override
  State<MateriaisScreen> createState() => _MateriaisScreenState();
}

class _MateriaisScreenState extends State<MateriaisScreen> {
  final DataService _dataService = DataService();
  String _filtro = 'todos'; // todos, baixo, esgotado

  @override
  Widget build(BuildContext context) {
    List<MaterialModel> materiais = _dataService.materiais;

    // Aplicar filtro
    if (_filtro == 'baixo') {
      materiais = materiais.where((m) => m.statusEstoque == 'baixo').toList();
    } else if (_filtro == 'esgotado') {
      materiais =
          materiais.where((m) => m.statusEstoque == 'esgotado').toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiais'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtro = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todos', child: Text('Todos')),
              const PopupMenuItem(
                  value: 'baixo', child: Text('Estoque Baixo')),
              const PopupMenuItem(
                  value: 'esgotado', child: Text('Estoque Esgotado')),
            ],
          ),
        ],
      ),
      body: materiais.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum material encontrado',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: materiais.length,
              itemBuilder: (context, index) {
                return _buildMaterialCard(materiais[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMaterialDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Material'),
      ),
    );
  }

  Widget _buildMaterialCard(MaterialModel material) {
    Color statusColor;
    IconData statusIcon;
    switch (material.statusEstoque) {
      case 'esgotado':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'baixo':
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber;
        break;
      default:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMaterialDialog(material: material),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Código: ${material.codigo}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          material.statusEstoque.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Tipo',
                      material.tipo,
                      Icons.category,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Estoque',
                      '${material.quantidadeEstoque.toStringAsFixed(1)} un',
                      Icons.inventory,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Custo Unit.',
                      'R\$ ${material.custoUnitario.toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              if (material.statusEstoque != 'normal') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: statusColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          material.statusEstoque == 'esgotado'
                              ? 'Material esgotado! Necessária reposição urgente.'
                              : 'Estoque abaixo do mínimo (${material.estoqueMinimo} un)',
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showMaterialDialog({MaterialModel? material}) {
    final isEdit = material != null;
    final formKey = GlobalKey<FormState>();

    final nomeController = TextEditingController(text: material?.nome ?? '');
    final codigoController =
        TextEditingController(text: material?.codigo ?? '');
    final tipoController = TextEditingController(text: material?.tipo ?? '');
    final estoqueController = TextEditingController(
        text: material?.quantidadeEstoque.toString() ?? '');
    final estoqueMinController = TextEditingController(
        text: material?.estoqueMinimo.toString() ?? '');
    final custoController =
        TextEditingController(text: material?.custoUnitario.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Editar Material' : 'Novo Material'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Material',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    hintText: 'Ex: Ferro, Aço, Alumínio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: estoqueController,
                        decoration: const InputDecoration(
                          labelText: 'Qtd. Estoque',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Campo obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: estoqueMinController,
                        decoration: const InputDecoration(
                          labelText: 'Estoque Mín.',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Campo obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: custoController,
                  decoration: const InputDecoration(
                    labelText: 'Custo Unitário (R\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (isEdit)
            TextButton(
              onPressed: () {
                _dataService.removerMaterial(material.id);
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Material removido!')),
                );
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final newMaterial = MaterialModel(
                  id: material?.id ?? DateTime.now().toString(),
                  nome: nomeController.text,
                  codigo: codigoController.text,
                  tipo: tipoController.text,
                  quantidadeEstoque: double.parse(estoqueController.text),
                  estoqueMinimo: double.parse(estoqueMinController.text),
                  custoUnitario: double.parse(custoController.text),
                  createdAt: material?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                if (isEdit) {
                  _dataService.atualizarMaterial(newMaterial);
                } else {
                  _dataService.adicionarMaterial(newMaterial);
                }

                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit
                          ? 'Material atualizado!'
                          : 'Material adicionado!',
                    ),
                  ),
                );
              }
            },
            child: Text(isEdit ? 'Salvar' : 'Adicionar'),
          ),
        ],
      ),
    );
  }
}

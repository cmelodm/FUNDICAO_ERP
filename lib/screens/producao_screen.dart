import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundry_erp/models/ordem_producao_model.dart';
import 'package:foundry_erp/services/data_service.dart';
import 'package:foundry_erp/screens/producao_etapas_screen.dart';
import 'package:intl/intl.dart';

class ProducaoScreen extends StatefulWidget {
  const ProducaoScreen({super.key});

  @override
  State<ProducaoScreen> createState() => _ProducaoScreenState();
}

class _ProducaoScreenState extends State<ProducaoScreen> {
  bool _isKanbanView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produção'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isKanbanView ? Icons.list : Icons.view_column),
            onPressed: () {
              setState(() {
                _isKanbanView = !_isKanbanView;
              });
            },
            tooltip: _isKanbanView ? 'Visualização em Lista' : 'Visualização Kanban',
          ),
        ],
      ),
      body: Consumer<DataService>(
        builder: (context, dataService, child) {
          return _isKanbanView 
              ? _buildKanbanView(dataService) 
              : _buildListView(dataService);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNovaOrdemDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Ordem'),
      ),
    );
  }

  Widget _buildKanbanView(DataService dataService) {
    final ordensAguardando = dataService.ordensProducao
        .where((o) => o.status == 'aguardando')
        .toList();
    final ordensEmProducao = dataService.ordensProducao
        .where((o) => o.status == 'em_producao')
        .toList();
    final ordensPausadas = dataService.ordensProducao
        .where((o) => o.status == 'pausada')
        .toList();
    final ordensConcluidas = dataService.ordensProducao
        .where((o) => o.status == 'concluida')
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKanbanColumn('Aguardando', ordensAguardando, Colors.grey),
          const SizedBox(width: 12),
          _buildKanbanColumn('Em Produção', ordensEmProducao, Colors.blue),
          const SizedBox(width: 12),
          _buildKanbanColumn('Pausadas', ordensPausadas, Colors.orange),
          const SizedBox(width: 12),
          _buildKanbanColumn('Concluídas', ordensConcluidas, Colors.green),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
      String title, List<OrdemProducaoModel> ordens, Color color) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ordens.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (ordens.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Nenhuma ordem',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: ordens.length,
                itemBuilder: (context, index) {
                  return _buildKanbanCard(ordens[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(OrdemProducaoModel ordem) {
    Color prioridadeColor;
    switch (ordem.prioridade) {
      case 'urgente':
        prioridadeColor = Colors.red;
        break;
      case 'alta':
        prioridadeColor = Colors.orange;
        break;
      case 'media':
        prioridadeColor = Colors.blue;
        break;
      default:
        prioridadeColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: prioridadeColor, width: 2),
      ),
      child: InkWell(
        onTap: () => _showDetalhesOrdem(ordem),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ordem.numero,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.flag,
                    size: 16,
                    color: prioridadeColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ordem.produto,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                ordem.cliente,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ordem.progresso / 100,
                  minHeight: 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(prioridadeColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${ordem.progresso.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(DataService dataService) {
    final ordens = dataService.ordensProducao;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ordens.length,
      itemBuilder: (context, index) {
        return _buildOrdemListCard(ordens[index]);
      },
    );
  }

  Widget _buildOrdemListCard(OrdemProducaoModel ordem) {
    Color statusColor;
    switch (ordem.status) {
      case 'aguardando':
        statusColor = Colors.grey;
        break;
      case 'em_producao':
        statusColor = Colors.blue;
        break;
      case 'pausada':
        statusColor = Colors.orange;
        break;
      case 'concluida':
        statusColor = Colors.green;
        break;
      case 'cancelada':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetalhesOrdem(ordem),
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
                          ordem.numero,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ordem.produto,
                          style: const TextStyle(fontSize: 14),
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
                    child: Text(
                      ordem.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.business, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    ordem.cliente,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(ordem.dataCriacao),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ordem.progresso / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ordem.progresso.toStringAsFixed(0)}% concluído',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${ordem.etapas.where((e) => e.status == 'concluida').length}/${ordem.etapas.length} etapas',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetalhesOrdem(OrdemProducaoModel ordem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                ordem.numero,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ordem.produto,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              _buildDetalheSection('Cliente', ordem.cliente, Icons.business),
              _buildDetalheSection(
                  'Status', ordem.statusLabel, Icons.info_outline),
              _buildDetalheSection(
                  'Prioridade',
                  ordem.prioridade.toUpperCase(),
                  Icons.flag),
              _buildDetalheSection(
                  'Progresso',
                  '${ordem.progresso.toStringAsFixed(0)}%',
                  Icons.percent),
              const SizedBox(height: 24),
              const Text(
                'Etapas de Produção',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...ordem.etapas.map((etapa) => _buildEtapaCard(etapa)),
              const SizedBox(height: 24),
              const Text(
                'Materiais Utilizados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...ordem.materiaisUtilizados
                  .map((mat) => _buildMaterialUtilizadoCard(mat)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildCustoCard(
                      'Custo Estimado',
                      ordem.custoEstimado,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCustoCard(
                      'Custo Real',
                      ordem.custoReal,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Botão para gerenciar etapas
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirGerenciamentoEtapas(ordem),
                  icon: const Icon(Icons.settings_suggest),
                  label: const Text('Gerenciar Etapas de Produção'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Abre tela de gerenciamento de etapas
  void _abrirGerenciamentoEtapas(OrdemProducaoModel ordem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProducaoEtapasScreen(
          ordemId: ordem.id,
          ordemNumero: ordem.numero,
        ),
      ),
    );
  }

  Widget _buildDetalheSection(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEtapaCard(EtapaProducao etapa) {
    Color statusColor;
    IconData statusIcon;
    switch (etapa.status) {
      case 'aguardando':
        statusColor = Colors.grey;
        statusIcon = Icons.schedule;
        break;
      case 'em_andamento':
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle;
        break;
      case 'concluida':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etapa.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (etapa.operador != null)
                  Text(
                    'Operador: ${etapa.operador}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (etapa.tempoRealMinutos != null)
            Text(
              '${etapa.tempoRealMinutos}min',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMaterialUtilizadoCard(MaterialUtilizado material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              material.materialNome,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${material.quantidade} un × R\$ ${material.custoUnitario.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustoCard(String label, double valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showNovaOrdemDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NovaOrdemProducaoScreen(),
      ),
    );
  }
}

// Tela de criação de nova ordem de produção
class NovaOrdemProducaoScreen extends StatefulWidget {
  const NovaOrdemProducaoScreen({super.key});

  @override
  State<NovaOrdemProducaoScreen> createState() =>
      _NovaOrdemProducaoScreenState();
}

class _NovaOrdemProducaoScreenState extends State<NovaOrdemProducaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();

  // Controladores de formulário
  final _numeroController = TextEditingController();
  final _produtoController = TextEditingController();
  final _clienteController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _prioridade = 'media';
  DateTime _dataInicio = DateTime.now();
  DateTime _dataPrevista = DateTime.now().add(const Duration(days: 7));

  // Lista de materiais utilizados
  final List<Map<String, dynamic>> _materiais = [];

  @override
  void initState() {
    super.initState();
    // Número será gerado no build
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Gerar número automático
    if (_numeroController.text.isEmpty) {
      final dataService = Provider.of<DataService>(context, listen: false);
      final ultimaOrdem = dataService.ordensProducao.length;
      _numeroController.text = 'OP-2024-${(ultimaOrdem + 1).toString().padLeft(3, '0')}';
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _produtoController.dispose();
    _clienteController.dispose();
    _quantidadeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Ordem de Produção'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Número da Ordem
            TextFormField(
              controller: _numeroController,
              decoration: const InputDecoration(
                labelText: 'Número da Ordem',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Produto
            TextFormField(
              controller: _produtoController,
              decoration: const InputDecoration(
                labelText: 'Produto',
                prefixIcon: Icon(Icons.inventory),
                border: OutlineInputBorder(),
                hintText: 'Ex: Bloco Motor V8, Cabeçote 4 cilindros',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Cliente
            TextFormField(
              controller: _clienteController,
              decoration: const InputDecoration(
                labelText: 'Cliente',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Quantidade
            TextFormField(
              controller: _quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                prefixIcon: Icon(Icons.production_quantity_limits),
                border: OutlineInputBorder(),
                suffix: Text('un'),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (double.tryParse(value) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Prioridade
            DropdownButtonFormField<String>(
              value: _prioridade,
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                prefixIcon: Icon(Icons.priority_high),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'baixa', child: Text('Baixa')),
                DropdownMenuItem(value: 'media', child: Text('Média')),
                DropdownMenuItem(value: 'alta', child: Text('Alta')),
                DropdownMenuItem(value: 'urgente', child: Text('Urgente')),
              ],
              onChanged: (value) {
                setState(() {
                  _prioridade = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Data de Início
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data de Início'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataInicio)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () async {
                final data = await showDatePicker(
                  context: context,
                  initialDate: _dataInicio,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (data != null) {
                  setState(() {
                    _dataInicio = data;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Data Prevista
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Data Prevista de Conclusão'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataPrevista)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () async {
                final data = await showDatePicker(
                  context: context,
                  initialDate: _dataPrevista,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (data != null) {
                  setState(() {
                    _dataPrevista = data;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Materiais Utilizados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Materiais Utilizados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _adicionarMaterial,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista de materiais
            if (_materiais.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Nenhum material adicionado',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            else
              ..._materiais.asMap().entries.map((entry) {
                final index = entry.key;
                final material = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(material['nome']),
                    subtitle: Text(
                      'Qtd: ${material['quantidade']} ${material['unidade']} | Custo: R\$ ${material['custoUnitario'].toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _materiais.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),

            // Observações
            TextFormField(
              controller: _observacoesController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
                hintText: 'Informações adicionais sobre a ordem de produção',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _salvarOrdem,
                    child: const Text('Criar Ordem'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarMaterial() {
    final dataService = Provider.of<DataService>(context, listen: false);
    final materiaisDisponiveis = dataService.materiais;

    showDialog(
      context: context,
      builder: (context) {
        String? materialSelecionadoId;
        final quantidadeController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final materialSelecionado = materialSelecionadoId != null
                ? materiaisDisponiveis.firstWhere((m) => m.id == materialSelecionadoId)
                : null;

            return AlertDialog(
              title: const Text('Adicionar Material'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Material',
                      border: OutlineInputBorder(),
                    ),
                    items: materiaisDisponiveis
                        .map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Text('${m.nome} (${m.codigo})'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        materialSelecionadoId = value;
                      });
                    },
                  ),
                  if (materialSelecionado != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Estoque disponível: ${materialSelecionado.quantidadeEstoque.toStringAsFixed(2)} kg',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                        suffix: Text('kg'),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (materialSelecionadoId != null &&
                        quantidadeController.text.isNotEmpty) {
                      final material = materiaisDisponiveis.firstWhere(
                        (m) => m.id == materialSelecionadoId,
                      );
                      final quantidade = double.parse(quantidadeController.text);

                      setState(() {
                        _materiais.add({
                          'id': material.id,
                          'nome': material.nome,
                          'quantidade': quantidade,
                          'unidade': 'kg',
                          'custoUnitario': material.custoUnitario,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _salvarOrdem() {
    if (_formKey.currentState!.validate()) {
      if (_materiais.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicione pelo menos um material à ordem'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Calcular custo estimado
      final custoEstimado = _materiais.fold<double>(
        0.0,
        (total, m) => total + (m['quantidade'] * m['custoUnitario']),
      );

      // Criar nova ordem de produção
      final novaOrdem = OrdemProducaoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        numero: _numeroController.text,
        produto: _produtoController.text,
        cliente: _clienteController.text,
        status: 'aguardando',
        prioridade: _prioridade,
        materiaisUtilizados: _materiais
            .map((m) => MaterialUtilizado(
                  materialId: m['id'],
                  materialNome: m['nome'],
                  quantidade: m['quantidade'],
                  custoUnitario: m['custoUnitario'],
                ))
            .toList(),
        etapas: [], // Lista vazia inicialmente
        custoEstimado: custoEstimado,
        custoReal: 0.0, // Será atualizado durante a produção
        dataCriacao: DateTime.now(),
        dataInicio: _dataInicio,
        observacoes: _observacoesController.text.isNotEmpty
            ? _observacoesController.text
            : null,
      );

      // Adicionar ao DataService
      final dataService = Provider.of<DataService>(context, listen: false);
      dataService.adicionarOrdemProducao(novaOrdem);

      // Voltar e mostrar confirmação
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ordem ${novaOrdem.numero} criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

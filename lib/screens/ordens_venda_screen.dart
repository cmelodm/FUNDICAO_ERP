import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundry_erp/services/data_service.dart';
import 'package:foundry_erp/models/ordem_venda_model.dart';
import 'package:intl/intl.dart';

class OrdensVendaScreen extends StatefulWidget {
  const OrdensVendaScreen({super.key});

  @override
  State<OrdensVendaScreen> createState() => _OrdensVendaScreenState();
}

class _OrdensVendaScreenState extends State<OrdensVendaScreen> {
  String _filtroStatus = 'Todas';

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final ordensVenda = dataService.ordensVenda;

    // Filtrar ordens por status
    final ordensFiltradas = _filtroStatus == 'Todas'
        ? ordensVenda
        : ordensVenda.where((o) => o.statusTexto == _filtroStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Venda'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros e estatísticas
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        ordensVenda.length.toString(),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Em Produção',
                        ordensVenda
                            .where((o) => o.status == StatusOrdemVenda.emProducao)
                            .length
                            .toString(),
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Faturadas',
                        ordensVenda
                            .where((o) => o.status == StatusOrdemVenda.faturada)
                            .length
                            .toString(),
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Filtro de status
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todas'),
                      _buildFilterChip('Orçamento'),
                      _buildFilterChip('Aprovada'),
                      _buildFilterChip('Em Produção'),
                      _buildFilterChip('Aguardando Faturamento'),
                      _buildFilterChip('Faturada'),
                      _buildFilterChip('Entregue'),
                      _buildFilterChip('Cancelada'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lista de ordens de venda
          Expanded(
            child: ordensFiltradas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sell_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma ordem de venda encontrada',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ordensFiltradas.length,
                    itemBuilder: (context, index) {
                      final ordem = ordensFiltradas[index];
                      return _buildOrdemCard(context, ordem, dataService);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogNovaOrdem(context, dataService),
        icon: const Icon(Icons.add),
        label: const Text('Nova Ordem'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  Widget _buildStatCard(String label, String valor, Color cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filtroStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filtroStatus = label;
          });
        },
      ),
    );
  }

  Widget _buildOrdemCard(
      BuildContext context, OrdemVendaModel ordem, DataService dataService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _mostrarDetalhesOrdem(context, ordem, dataService),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ordem.numero,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(ordem.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.business, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ordem.clienteNome,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Emissão: ${DateFormat('dd/MM/yyyy').format(ordem.dataEmissao)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (ordem.dataPrevisaoEntrega != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.local_shipping, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Entrega: ${DateFormat('dd/MM/yyyy').format(ordem.dataPrevisaoEntrega!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ordem.items.length} item(ns)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'R\$ ${ordem.valorTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              if (ordem.ordemProducaoId != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.factory, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Vinculada a OP: ${ordem.ordemProducaoId}',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(StatusOrdemVenda status) {
    Color cor;
    switch (status) {
      case StatusOrdemVenda.orcamento:
        cor = Colors.grey;
        break;
      case StatusOrdemVenda.aprovada:
        cor = Colors.blue;
        break;
      case StatusOrdemVenda.emProducao:
        cor = Colors.orange;
        break;
      case StatusOrdemVenda.aguardandoFaturamento:
        cor = Colors.purple;
        break;
      case StatusOrdemVenda.faturada:
        cor = Colors.green;
        break;
      case StatusOrdemVenda.entregue:
        cor = Colors.teal;
        break;
      case StatusOrdemVenda.cancelada:
        cor = Colors.red;
        break;
    }
    return Chip(
      label: Text(
        _getStatusTexto(status),
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
      backgroundColor: cor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  String _getStatusTexto(StatusOrdemVenda status) {
    switch (status) {
      case StatusOrdemVenda.orcamento:
        return 'Orçamento';
      case StatusOrdemVenda.aprovada:
        return 'Aprovada';
      case StatusOrdemVenda.emProducao:
        return 'Em Produção';
      case StatusOrdemVenda.aguardandoFaturamento:
        return 'Ag. Faturamento';
      case StatusOrdemVenda.faturada:
        return 'Faturada';
      case StatusOrdemVenda.entregue:
        return 'Entregue';
      case StatusOrdemVenda.cancelada:
        return 'Cancelada';
    }
  }

  void _mostrarDetalhesOrdem(
      BuildContext context, OrdemVendaModel ordem, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              // Cabeçalho
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ordem.numero,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ordem.clienteNome,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Conteúdo
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status
                      Row(
                        children: [
                          const Text('Status: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildStatusChip(ordem.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Dados do cliente
                      const Text(
                        'Dados do Cliente',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (ordem.clienteCnpj != null)
                        _buildInfoRow('CNPJ', ordem.clienteCnpj!),
                      if (ordem.clienteEmail != null)
                        _buildInfoRow('Email', ordem.clienteEmail!),
                      if (ordem.clienteTelefone != null)
                        _buildInfoRow('Telefone', ordem.clienteTelefone!),
                      if (ordem.clienteEndereco != null)
                        _buildInfoRow('Endereço', ordem.clienteEndereco!),
                      const Divider(height: 24),
                      // Datas
                      _buildInfoRow('Data Emissão',
                          DateFormat('dd/MM/yyyy').format(ordem.dataEmissao)),
                      if (ordem.dataPrevisaoEntrega != null)
                        _buildInfoRow(
                            'Previsão Entrega',
                            DateFormat('dd/MM/yyyy')
                                .format(ordem.dataPrevisaoEntrega!)),
                      if (ordem.dataFaturamento != null)
                        _buildInfoRow(
                            'Data Faturamento',
                            DateFormat('dd/MM/yyyy')
                                .format(ordem.dataFaturamento!)),
                      if (ordem.dataEntrega != null)
                        _buildInfoRow('Data Entrega',
                            DateFormat('dd/MM/yyyy').format(ordem.dataEntrega!)),
                      const Divider(height: 24),
                      // Itens
                      const Text(
                        'Itens da Ordem',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...ordem.items.map((item) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.produtoNome,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Qtd: ${item.quantidade.toStringAsFixed(2)} ${item.unidade}',
                                        style:
                                            const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        'R\$ ${item.precoUnitario.toStringAsFixed(2)}/${item.unidade}',
                                        style:
                                            const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total: R\$ ${item.valorTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const Divider(height: 24),
                      // Valores
                      _buildInfoRow('Subtotal',
                          'R\$ ${ordem.subtotal.toStringAsFixed(2)}'),
                      _buildInfoRow(
                          'Frete', 'R\$ ${ordem.valorFrete.toStringAsFixed(2)}'),
                      _buildInfoRow('Desconto',
                          '- R\$ ${ordem.valorDesconto.toStringAsFixed(2)}'),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'R\$ ${ordem.valorTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      if (ordem.condicaoPagamento != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                            'Condição de Pagamento', ordem.condicaoPagamento!),
                      ],
                      if (ordem.ordemProducaoId != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                            'Ordem de Produção', ordem.ordemProducaoId!),
                      ],
                      if (ordem.observacoes != null &&
                          ordem.observacoes!.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text(
                          'Observações',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(ordem.observacoes!),
                      ],
                    ],
                  ),
                ),
              ),
              // Botões de ação
              if (ordem.status == StatusOrdemVenda.aguardandoFaturamento)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final sucesso =
                          await dataService.faturarOrdemVenda(ordem.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        if (sucesso) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Ordem faturada e estoque atualizado!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Erro: Estoque insuficiente!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Faturar Ordem'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child:
                Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogNovaOrdem(BuildContext context, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Ordem de Venda'),
        content: const Text(
          'Funcionalidade de cadastro de nova ordem em desenvolvimento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

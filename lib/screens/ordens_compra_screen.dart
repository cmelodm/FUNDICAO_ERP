import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foundry_erp/services/data_service.dart';
import 'package:foundry_erp/models/ordem_compra_model.dart';
import 'package:intl/intl.dart';

class OrdensCompraScreen extends StatefulWidget {
  const OrdensCompraScreen({super.key});

  @override
  State<OrdensCompraScreen> createState() => _OrdensCompraScreenState();
}

class _OrdensCompraScreenState extends State<OrdensCompraScreen> {
  String _filtroStatus = 'Todas';

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final ordensCompra = dataService.ordensCompra;

    // Filtrar ordens por status
    final ordensFiltradas = _filtroStatus == 'Todas'
        ? ordensCompra
        : ordensCompra.where((o) => o.statusTexto == _filtroStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Compra'),
        backgroundColor: Colors.blue.shade700,
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
                        ordensCompra.length.toString(),
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Confirmadas',
                        ordensCompra
                            .where((o) => o.status == StatusOrdemCompra.confirmada)
                            .length
                            .toString(),
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Recebidas',
                        ordensCompra
                            .where((o) => o.status == StatusOrdemCompra.recebida)
                            .length
                            .toString(),
                        Colors.green,
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
                      _buildFilterChip('Rascunho'),
                      _buildFilterChip('Enviada'),
                      _buildFilterChip('Confirmada'),
                      _buildFilterChip('Parcialmente Recebida'),
                      _buildFilterChip('Recebida'),
                      _buildFilterChip('Cancelada'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lista de ordens de compra
          Expanded(
            child: ordensFiltradas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma ordem de compra encontrada',
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
      BuildContext context, OrdemCompraModel ordem, DataService dataService) {
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
              Text(
                ordem.fornecedorNome,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
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
                      'Previsão: ${DateFormat('dd/MM/yyyy').format(ordem.dataPrevisaoEntrega!)}',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(StatusOrdemCompra status) {
    Color cor;
    switch (status) {
      case StatusOrdemCompra.rascunho:
        cor = Colors.grey;
        break;
      case StatusOrdemCompra.enviada:
        cor = Colors.blue;
        break;
      case StatusOrdemCompra.confirmada:
        cor = Colors.orange;
        break;
      case StatusOrdemCompra.parcialmenteRecebida:
        cor = Colors.amber;
        break;
      case StatusOrdemCompra.recebida:
        cor = Colors.green;
        break;
      case StatusOrdemCompra.cancelada:
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

  String _getStatusTexto(StatusOrdemCompra status) {
    switch (status) {
      case StatusOrdemCompra.rascunho:
        return 'Rascunho';
      case StatusOrdemCompra.enviada:
        return 'Enviada';
      case StatusOrdemCompra.confirmada:
        return 'Confirmada';
      case StatusOrdemCompra.parcialmenteRecebida:
        return 'Parc. Recebida';
      case StatusOrdemCompra.recebida:
        return 'Recebida';
      case StatusOrdemCompra.cancelada:
        return 'Cancelada';
    }
  }

  void _mostrarDetalhesOrdem(
      BuildContext context, OrdemCompraModel ordem, DataService dataService) {
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
                color: Colors.blue.shade700,
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
                          ordem.fornecedorNome,
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
                      // Datas
                      _buildInfoRow('Data Emissão',
                          DateFormat('dd/MM/yyyy').format(ordem.dataEmissao)),
                      if (ordem.dataPrevisaoEntrega != null)
                        _buildInfoRow(
                            'Previsão Entrega',
                            DateFormat('dd/MM/yyyy')
                                .format(ordem.dataPrevisaoEntrega!)),
                      if (ordem.dataRecebimento != null)
                        _buildInfoRow(
                            'Data Recebimento',
                            DateFormat('dd/MM/yyyy')
                                .format(ordem.dataRecebimento!)),
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
                                    item.materialNome,
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
                                  if (item.quantidadeRecebida > 0)
                                    Text(
                                      'Recebido: ${item.quantidadeRecebida.toStringAsFixed(2)} ${item.unidade}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.green),
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
                      _buildInfoRow('Frete',
                          'R\$ ${ordem.valorFrete.toStringAsFixed(2)}'),
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
              if (ordem.status == StatusOrdemCompra.confirmada ||
                  ordem.status == StatusOrdemCompra.parcialmenteRecebida)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarDialogReceberMateriais(
                          context, ordem, dataService);
                    },
                    icon: const Icon(Icons.local_shipping),
                    label: const Text('Receber Materiais'),
                    style: ElevatedButton.styleFrom(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _mostrarDialogNovaOrdem(BuildContext context, DataService dataService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Ordem de Compra'),
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

  void _mostrarDialogReceberMateriais(
      BuildContext context, OrdemCompraModel ordem, DataService dataService) {
    final quantidades = <String, double>{};
    ordem.items.forEach((item) {
      quantidades[item.materialId] = item.quantidade - item.quantidadeRecebida;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receber Materiais'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ordem.items.map((item) {
              final restante = item.quantidade - item.quantidadeRecebida;
              return ListTile(
                title: Text(item.materialNome),
                subtitle: Text('Restante: ${restante.toStringAsFixed(2)} ${item.unidade}'),
                trailing: SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: restante.toStringAsFixed(2),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      suffix: Text(item.unidade),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      quantidades[item.materialId] =
                          double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await dataService.receberOrdemCompra(ordem.id, quantidades);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Materiais recebidos com sucesso!')),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar Recebimento'),
          ),
        ],
      ),
    );
  }
}

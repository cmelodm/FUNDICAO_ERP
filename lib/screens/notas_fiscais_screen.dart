import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/nota_fiscal_model.dart';
import '../services/data_service.dart';
import '../services/nfe_parser_service.dart';

class NotasFiscaisScreen extends StatefulWidget {
  const NotasFiscaisScreen({super.key});

  @override
  State<NotasFiscaisScreen> createState() => _NotasFiscaisScreenState();
}

class _NotasFiscaisScreenState extends State<NotasFiscaisScreen> {
  bool _isProcessing = false;

  Future<void> _uploadXML() async {
    try {
      // Usar file_picker para selecionar arquivo XML
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xml'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isProcessing = true;
      });

      final file = result.files.first;
      final xmlContent = String.fromCharCodes(file.bytes!);

      // Parse XML
      final notaFiscal = NFeParserService.parseNFeXML(xmlContent);

      if (notaFiscal == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Erro ao processar XML. Verifique o formato.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Salvar nota fiscal
      final dataService = Provider.of<DataService>(context, listen: false);
      await dataService.adicionarNotaFiscal(notaFiscal);

      // Mostrar dialog de confirmação
      if (mounted) {
        _mostrarDialogProcessamento(notaFiscal);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _mostrarDialogProcessamento(NotaFiscalModel nota) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NFe Processada'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Número: ${nota.numero}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Série: ${nota.serie}'),
              Text('Fornecedor: ${nota.fornecedorNome}'),
              Text('CNPJ: ${nota.fornecedorCnpj}'),
              const Divider(),
              Text('${nota.itens.length} itens'),
              Text('Valor Total: R\$ ${nota.valorTotal.toStringAsFixed(2)}'),
              const Divider(),
              const Text('Deseja atualizar o estoque?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              _processarEntradaEstoque(nota);
              Navigator.pop(context);
            },
            child: const Text('SIM - ATUALIZAR ESTOQUE'),
          ),
        ],
      ),
    );
  }

  Future<void> _processarEntradaEstoque(NotaFiscalModel nota) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    int itensAtualizados = 0;

    for (var item in nota.itens) {
      // Buscar material por NCM ou descrição
      final material = dataService.materiais.firstWhere(
        (m) => m.ncm == item.ncm || m.nome.toLowerCase().contains(item.descricao.toLowerCase()),
        orElse: () => dataService.materiais.first,
      );

      if (material.id.isNotEmpty) {
        // Atualizar estoque
        final materialAtualizado = material.copyWith(
          quantidadeEstoque: material.quantidadeEstoque + item.quantidade,
          custoUnitario: item.valorUnitario,
        );
        await dataService.atualizarMaterial(materialAtualizado);
        itensAtualizados++;
      }
    }

    // Atualizar status da nota
    final notaAtualizada = NotaFiscalModel(
      id: nota.id,
      numero: nota.numero,
      serie: nota.serie,
      tipo: nota.tipo,
      dataEmissao: nota.dataEmissao,
      dataEntrada: nota.dataEntrada,
      chaveAcesso: nota.chaveAcesso,
      fornecedorId: nota.fornecedorId,
      fornecedorNome: nota.fornecedorNome,
      fornecedorCnpj: nota.fornecedorCnpj,
      itens: nota.itens,
      valorTotal: nota.valorTotal,
      valorProdutos: nota.valorProdutos,
      impostos: nota.impostos,
      observacoes: nota.observacoes,
      status: StatusNota.processada,
      createdAt: nota.createdAt,
      updatedAt: DateTime.now(),
      xmlPath: nota.xmlPath,
    );
    await dataService.atualizarNotaFiscal(notaAtualizada);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Estoque atualizado! $itensAtualizados itens processados.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final notas = dataService.notasFiscais;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas Fiscais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _isProcessing ? null : _uploadXML,
            tooltip: 'Upload XML NFe',
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processando XML...'),
                ],
              ),
            )
          : notas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Nenhuma nota fiscal cadastrada'),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _uploadXML,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('UPLOAD XML NFe'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notas.length,
                  itemBuilder: (context, index) {
                    final nota = notas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(nota.status),
                          child: Icon(
                            nota.tipo == TipoNotaFiscal.entrada
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('NFe ${nota.numero} - Série ${nota.serie}'),
                        subtitle: Text(
                          '${nota.fornecedorNome}\n'
                          'R\$ ${nota.valorTotal.toStringAsFixed(2)} | ${nota.status.nome}',
                        ),
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CNPJ: ${nota.fornecedorCnpj}'),
                                Text('Data Emissão: ${nota.dataEmissao.day}/${nota.dataEmissao.month}/${nota.dataEmissao.year}'),
                                Text('Chave: ${NFeParserService.formatarChaveAcesso(nota.chaveAcesso)}'),
                                const Divider(),
                                Text('Itens: ${nota.itens.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ...nota.itens.map((item) => ListTile(
                                  dense: true,
                                  title: Text(item.descricao),
                                  subtitle: Text('${item.quantidade} ${item.unidade} x R\$ ${item.valorUnitario.toStringAsFixed(2)}'),
                                  trailing: Text('R\$ ${item.valorTotal.toStringAsFixed(2)}'),
                                )),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Valor Produtos:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('R\$ ${nota.valorProdutos.toStringAsFixed(2)}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Impostos:'),
                                    Text('R\$ ${nota.impostos.totalImpostos.toStringAsFixed(2)}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('R\$ ${nota.valorTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                if (nota.status == StatusNota.pendente) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _processarEntradaEstoque(nota),
                                      icon: const Icon(Icons.inventory),
                                      label: const Text('PROCESSAR ENTRADA NO ESTOQUE'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: notas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _uploadXML,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload XML'),
            )
          : null,
    );
  }

  Color _getStatusColor(StatusNota status) {
    switch (status) {
      case StatusNota.processada:
        return Colors.green;
      case StatusNota.pendente:
        return Colors.orange;
      case StatusNota.cancelada:
        return Colors.grey;
      case StatusNota.erro:
        return Colors.red;
    }
  }
}

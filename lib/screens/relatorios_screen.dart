import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../services/relatorio_service.dart';

class RelatoriosScreen extends StatelessWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios e Exportações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Exportar Dados',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Materiais
          _buildRelatorioCard(
            context,
            'Materiais',
            '${dataService.materiais.length} registros',
            Icons.inventory,
            Colors.blue,
            onPDF: () async {
              await RelatorioService.gerarRelatorioPDFMateriais(dataService.materiais);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📥 PDF de Materiais baixado!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            onPrint: () async {
              await RelatorioService.imprimirPDFMateriais(dataService.materiais);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🖨️ PDF aberto em nova janela para impressão'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            onCSV: () {
              RelatorioService.exportarMateriaisCSV(dataService.materiais);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📥 CSV de Materiais baixado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),

          // Produção
          _buildRelatorioCard(
            context,
            'Ordens de Produção',
            '${dataService.ordensProducao.length} registros',
            Icons.factory,
            Colors.orange,
            onPDF: () async {
              await RelatorioService.gerarRelatorioPDFProducao(dataService.ordensProducao);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📥 PDF de Produção baixado!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            onPrint: () async {
              await RelatorioService.imprimirPDFProducao(dataService.ordensProducao);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🖨️ PDF aberto em nova janela para impressão'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            onCSV: () {
              RelatorioService.exportarProducaoCSV(dataService.ordensProducao);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📥 CSV de Produção baixado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),

          // Fornecedores
          _buildRelatorioCard(
            context,
            'Fornecedores',
            '${dataService.fornecedores.length} registros',
            Icons.business,
            Colors.green,
            onCSV: () {
              RelatorioService.exportarFornecedoresCSV(dataService.fornecedores);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📥 CSV de Fornecedores baixado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),

          // Qualidade
          _buildRelatorioCard(
            context,
            'Inspeções de Qualidade',
            '${dataService.inspecoes.length} registros',
            Icons.verified,
            Colors.purple,
            onCSV: () {
              RelatorioService.exportarQualidadeCSV(dataService.inspecoes);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📥 CSV de Qualidade baixado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),

          // Notas Fiscais
          _buildRelatorioCard(
            context,
            'Notas Fiscais',
            '${dataService.notasFiscais.length} registros',
            Icons.description,
            Colors.teal,
            onCSV: () {
              RelatorioService.exportarNotasFiscaisCSV(dataService.notasFiscais);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📥 CSV de Notas Fiscais baixado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),

          // Análises Espectrométricas
          _buildRelatorioCard(
            context,
            'Análises Espectrométricas',
            '${dataService.analises.length} registros',
            Icons.analytics,
            Colors.indigo,
            onCSV: () {
              RelatorioService.exportarAnalisesCSV(dataService.analises);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📥 CSV de Análises baixado!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRelatorioCard(
    BuildContext context,
    String titulo,
    String subtitulo,
    IconData icon,
    Color color, {
    VoidCallback? onPDF,
    VoidCallback? onCSV,
    VoidCallback? onPrint,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (onPDF != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPDF,
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Baixar PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onPrint != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPrint,
                      icon: const Icon(Icons.print, size: 18),
                      label: const Text('Imprimir'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onCSV != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onCSV,
                      icon: const Icon(Icons.table_chart, size: 18),
                      label: const Text('CSV/Excel'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

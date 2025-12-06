import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inspecao_qualidade_model.dart';
import '../services/data_service.dart';

class QualidadeScreen extends StatelessWidget {
  const QualidadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final inspecoes = dataService.inspecoes;

    // Estatísticas
    final aprovadas = inspecoes.where((i) => i.resultado == 'aprovado').length;
    final aprovComRessalvas = inspecoes.where((i) => i.resultado == 'aprovado_com_ressalvas').length;
    final reprovadas = inspecoes.where((i) => i.resultado == 'reprovado').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Qualidade'),
      ),
      body: Column(
        children: [
          // Cards de Estatísticas
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard('Aprovadas', aprovadas, Colors.green, Icons.check_circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Com Ressalvas', aprovComRessalvas, Colors.orange, Icons.warning),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Reprovadas', reprovadas, Colors.red, Icons.cancel),
                ),
              ],
            ),
          ),

          // Lista de Inspeções
          Expanded(
            child: inspecoes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Nenhuma inspeção registrada'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: inspecoes.length,
                    itemBuilder: (context, index) {
                      final inspecao = inspecoes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getResultadoColor(inspecao.resultado),
                            child: Icon(
                              _getResultadoIcon(inspecao.resultado),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(inspecao.produto),
                          subtitle: Text(
                            'OP: ${inspecao.ordemProducaoId}\n'
                            '${inspecao.tipoTeste} | ${_getResultadoTexto(inspecao.resultado)}',
                          ),
                          trailing: Text(
                            '${inspecao.dataInspecao.day}/${inspecao.dataInspecao.month}/${inspecao.dataInspecao.year}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Inspetor', inspecao.inspetor ?? 'Não informado'),
                                  _buildInfoRow('Tipo', inspecao.tipoTeste),
                                  _buildInfoRow('Resultado', _getResultadoTexto(inspecao.resultado)),
                                  if (inspecao.observacoes != null) ...[
                                    const Divider(),
                                    const Text(
                                      'Observações:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(inspecao.observacoes!),
                                  ],
                                  if (inspecao.naoConformidades.isNotEmpty) ...[
                                    const Divider(),
                                    const Text(
                                      'Não Conformidades:',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                                    const SizedBox(height: 8),
                                    ...inspecao.naoConformidades.map((nc) => Card(
                                      color: Colors.red.shade50,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nc.descricao,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('Gravidade: ${nc.gravidade}'),
                                            if (nc.acaoCorretiva != null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Ação Corretiva: ${nc.acaoCorretiva}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    )),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getResultadoColor(String resultado) {
    switch (resultado) {
      case 'aprovado':
        return Colors.green;
      case 'aprovado_com_ressalvas':
        return Colors.orange;
      case 'reprovado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getResultadoIcon(String resultado) {
    switch (resultado) {
      case 'aprovado':
        return Icons.check_circle;
      case 'aprovado_com_ressalvas':
        return Icons.warning;
      case 'reprovado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getResultadoTexto(String resultado) {
    switch (resultado) {
      case 'aprovado':
        return 'Aprovado';
      case 'aprovado_com_ressalvas':
        return 'Aprovado com Ressalvas';
      case 'reprovado':
        return 'Reprovado';
      default:
        return resultado;
    }
  }
}

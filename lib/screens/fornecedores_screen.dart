import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/fornecedor_model.dart';
import '../services/data_service.dart';

class FornecedoresScreen extends StatelessWidget {
  const FornecedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);
    final fornecedores = dataService.fornecedores;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
      ),
      body: fornecedores.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum fornecedor cadastrado'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: fornecedores.length,
              itemBuilder: (context, index) {
                final fornecedor = fornecedores[index];
                final avaliacaoMedia = _calcularAvaliacaoMedia(fornecedor);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalheFornecedorScreen(fornecedor: fornecedor),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getAvaliacaoColor(avaliacaoMedia),
                                child: Text(
                                  avaliacaoMedia.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fornecedor.nome,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'CNPJ: ${fornecedor.cnpj}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniMetric('Qualidade', fornecedor.avaliacaoQualidade),
                              _buildMiniMetric('Preço', fornecedor.avaliacaoPreco),
                              _buildMiniMetric('Prazo', fornecedor.avaliacaoPrazo),
                              _buildMiniMetric('Atend.', fornecedor.avaliacaoAtendimento),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMiniMetric(String label, double value) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getAvaliacaoColor(value),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  double _calcularAvaliacaoMedia(FornecedorModel fornecedor) {
    return (fornecedor.avaliacaoQualidade +
            fornecedor.avaliacaoPreco +
            fornecedor.avaliacaoPrazo +
            fornecedor.avaliacaoAtendimento) /
        4;
  }

  Color _getAvaliacaoColor(double avaliacao) {
    if (avaliacao >= 8.0) return Colors.green;
    if (avaliacao >= 6.0) return Colors.orange;
    return Colors.red;
  }
}

class DetalheFornecedorScreen extends StatelessWidget {
  final FornecedorModel fornecedor;

  const DetalheFornecedorScreen({super.key, required this.fornecedor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fornecedor.nome),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações Básicas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildInfoRow('CNPJ', fornecedor.cnpj),
                    _buildInfoRow('Email', fornecedor.email ?? 'Não informado'),
                    _buildInfoRow('Telefone', fornecedor.telefone ?? 'Não informado'),
                    _buildInfoRow('Email', fornecedor.email ?? 'Não informado'),
                    _buildInfoRow('Endereço', fornecedor.endereco ?? 'Não informado'),
                    _buildInfoRow('Cidade', '${fornecedor.cidade ?? ''} - ${fornecedor.estado ?? ''}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gráfico Radar de Avaliação
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Avaliação Geral',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 300,
                      child: RadarChart(
                        RadarChartData(
                          radarShape: RadarShape.polygon,
                          tickCount: 5,
                          ticksTextStyle: const TextStyle(color: Colors.transparent),
                          radarBorderData: const BorderSide(color: Colors.grey, width: 1),
                          gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                          tickBorderData: const BorderSide(color: Colors.transparent),
                          getTitle: (index, angle) {
                            switch (index) {
                              case 0:
                                return RadarChartTitle(text: 'Qualidade\n${fornecedor.avaliacaoQualidade.toStringAsFixed(1)}');
                              case 1:
                                return RadarChartTitle(text: 'Preço\n${fornecedor.avaliacaoPreco.toStringAsFixed(1)}');
                              case 2:
                                return RadarChartTitle(text: 'Prazo\n${fornecedor.avaliacaoPrazo.toStringAsFixed(1)}');
                              case 3:
                                return RadarChartTitle(text: 'Atendimento\n${fornecedor.avaliacaoAtendimento.toStringAsFixed(1)}');
                              default:
                                return const RadarChartTitle(text: '');
                            }
                          },
                          dataSets: [
                            RadarDataSet(
                              fillColor: Colors.blue.withOpacity(0.3),
                              borderColor: Colors.blue,
                              borderWidth: 2,
                              entryRadius: 3,
                              dataEntries: [
                                RadarEntry(value: fornecedor.avaliacaoQualidade),
                                RadarEntry(value: fornecedor.avaliacaoPreco),
                                RadarEntry(value: fornecedor.avaliacaoPrazo),
                                RadarEntry(value: fornecedor.avaliacaoAtendimento),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Média Geral: ${_calcularMedia().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getAvaliacaoColor(_calcularMedia()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Métricas Detalhadas
            _buildMetricCard('Qualidade', fornecedor.avaliacaoQualidade, Colors.green),
            _buildMetricCard('Preço', fornecedor.avaliacaoPreco, Colors.blue),
            _buildMetricCard('Prazo de Entrega', fornecedor.avaliacaoPrazo, Colors.orange),
            _buildMetricCard('Atendimento', fornecedor.avaliacaoAtendimento, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, double value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: value / 10,
                    backgroundColor: Colors.grey[300],
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcularMedia() {
    return (fornecedor.avaliacaoQualidade +
            fornecedor.avaliacaoPreco +
            fornecedor.avaliacaoPrazo +
            fornecedor.avaliacaoAtendimento) /
        4;
  }

  Color _getAvaliacaoColor(double avaliacao) {
    if (avaliacao >= 8.0) return Colors.green;
    if (avaliacao >= 6.0) return Colors.orange;
    return Colors.red;
  }
}

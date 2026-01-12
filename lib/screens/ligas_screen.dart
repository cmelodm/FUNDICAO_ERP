import 'package:flutter/material.dart';
import 'package:foundry_erp/models/liga_metalurgica_model.dart';
import 'package:foundry_erp/services/liga_templates_service.dart';
import 'package:foundry_erp/services/data_service.dart';

class LigasScreen extends StatefulWidget {
  const LigasScreen({super.key});

  @override
  State<LigasScreen> createState() => _LigasScreenState();
}

class _LigasScreenState extends State<LigasScreen> {
  final LigaTemplatesService _templatesService = LigaTemplatesService();
  final DataService _dataService = DataService();
  
  String _filtroNorma = 'Todas';
  
  @override
  Widget build(BuildContext context) {
    final ligas = _filtroNorma == 'Todas'
        ? _templatesService.ligasTemplates
        : _templatesService.filtrarPorNorma(_filtroNorma);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Ligas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtroNorma = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Todas', child: Text('Todas as Normas')),
              const PopupMenuItem(value: 'SAE', child: Text('SAE')),
              const PopupMenuItem(value: 'ASTM', child: Text('ASTM')),
              const PopupMenuItem(value: 'DIN', child: Text('DIN / EN 1706')),
              const PopupMenuItem(value: 'AA', child: Text('AA (Aluminum Association)')),
            ],
          ),
        ],
      ),
      body: ligas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma liga encontrada',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Card de Correção Avançada
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    color: Colors.deepPurple.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.deepPurple.shade200, width: 2),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/correcao-avancada'),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_fix_high,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Correção Avançada de Liga',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Sistema inteligente com recálculo em cascata',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.deepPurple.shade300,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Lista de Ligas
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ligas.length,
                    itemBuilder: (context, index) {
                      return _buildLigaCard(ligas[index]);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHistoricoCalculos(),
        icon: const Icon(Icons.history),
        label: const Text('Histórico'),
      ),
    );
  }

  Widget _buildLigaCard(LigaTemplate liga) {
    Color normaColor;
    switch (liga.norma) {
      case 'SAE':
        normaColor = Colors.blue;
        break;
      case 'ASTM':
        normaColor = Colors.green;
        break;
      case 'DIN':
        normaColor = Colors.orange;
        break;
      case 'AA':
        normaColor = Colors.purple;
        break;
      default:
        normaColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCalcularLigaDialog(liga),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: normaColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      liga.norma,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      liga.codigo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                liga.nome,
                style: const TextStyle(fontSize: 14),
              ),
              if (liga.aplicacao != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.build_circle, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        liga.aplicacao!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: liga.elementos.map((elemento) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${elemento.simbolo}: ${elemento.percentualMinimo.toStringAsFixed(1)}-${elemento.percentualMaximo.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCalcularLigaDialog(LigaTemplate template) {
    final pesoController = TextEditingController(text: '1000');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Calcular ${template.codigo}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                template.nome,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pesoController,
                decoration: const InputDecoration(
                  labelText: 'Peso Total da Liga (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text(
                'Composição:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...template.elementos.map((elemento) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${elemento.simbolo} (${elemento.nome})',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${elemento.percentualNominal.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final peso = double.tryParse(pesoController.text) ?? 0;
              if (peso > 0) {
                Navigator.pop(context);
                _mostrarResultadoCalculo(template, peso);
              }
            },
            child: const Text('Calcular'),
          ),
        ],
      ),
    );
  }

  void _mostrarResultadoCalculo(LigaTemplate template, double pesoTotal) {
    final liga = template.toLiga(pesoTotal);
    final disponibilidade = _dataService.verificarDisponibilidadeLiga(liga);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          liga.codigo,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Peso Total: ${pesoTotal.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: () => _exportarCalculo(liga),
                    tooltip: 'Exportar Excel',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Elementos Necessários',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildTabelaElementos(liga, disponibilidade),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _salvarCalculo(liga);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Cálculo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
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

  Widget _buildTabelaElementos(
      LigaMetalurgicaModel liga, Map<String, bool> disponibilidade) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Elemento',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    '%',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Rend.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Qtd Liga',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Qtd Nec.',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
                Container(width: 30),
              ],
            ),
          ),
          ...liga.elementos.map((elemento) {
            final qtdLiga = elemento.calcularQuantidadeLiga(liga.pesoTotal);
            final qtdNecessaria =
                elemento.calcularQuantidadeNecessaria(liga.pesoTotal);
            final disponivel = disponibilidade[elemento.simbolo] ?? false;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${elemento.simbolo} (${elemento.nome})',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${elemento.percentualNominal.toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${elemento.rendimentoForno.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${qtdLiga.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${qtdNecessaria.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Icon(
                      disponivel ? Icons.check_circle : Icons.warning,
                      size: 16,
                      color: disponivel ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _salvarCalculo(LigaMetalurgicaModel liga) {
    _dataService.adicionarLiga(liga);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cálculo salvo com sucesso!')),
    );
  }

  void _exportarCalculo(LigaMetalurgicaModel liga) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportação Excel será implementada em breve'),
      ),
    );
  }

  void _showHistoricoCalculos() {
    final historico = _dataService.ligas;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Cálculos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: historico.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Nenhum cálculo salvo ainda',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: historico.length,
                      itemBuilder: (context, index) {
                        final liga = historico[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(liga.norma[0]),
                          ),
                          title: Text(liga.codigo),
                          subtitle: Text(
                            '${liga.pesoTotal.toStringAsFixed(0)} kg - ${liga.dataCriacao.day}/${liga.dataCriacao.month}/${liga.dataCriacao.year}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context);
                            _mostrarResultadoCalculo(
                              LigaTemplate(
                                codigo: liga.codigo,
                                nome: liga.nome,
                                norma: liga.norma,
                                tipo: liga.tipo,
                                elementos: liga.elementos,
                                descricao: liga.descricao,
                                aplicacao: liga.aplicacao,
                              ),
                              liga.pesoTotal,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

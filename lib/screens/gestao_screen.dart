import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/analise_espectrometrica.dart';
import 'analise_espectrometrica_screen.dart';
import 'cadastro_liga_screen.dart';
import 'notas_fiscais_screen.dart';
import 'fornecedores_screen.dart';
import 'qualidade_screen.dart';
import 'relatorios_screen.dart';
import 'ordens_compra_screen.dart';
import 'ordens_venda_screen.dart';
import 'usuarios_screen.dart';

class GestaoScreen extends StatelessWidget {
  const GestaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Análise Espectrométrica
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.analytics),
              ),
              title: const Text('Análise Espectrométrica'),
              subtitle: const Text('Análise e correção de ligas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnaliseEspectrometricaScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Cadastro de Ligas
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.science),
              ),
              title: const Text('Cadastrar Nova Liga'),
              subtitle: const Text('Criar ligas personalizadas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CadastroLigaScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Notas Fiscais
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.description),
              ),
              title: const Text('Notas Fiscais'),
              subtitle: Text('${dataService.notasFiscais.length} notas cadastradas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotasFiscaisScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Ordens de Compra
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: Icon(Icons.shopping_cart),
              ),
              title: const Text('Ordens de Compra'),
              subtitle: Text('${dataService.ordensCompra.length} ordens registradas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdensCompraScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Ordens de Venda
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                child: Icon(Icons.sell),
              ),
              title: const Text('Ordens de Venda'),
              subtitle: Text('${dataService.ordensVenda.length} ordens registradas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdensVendaScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Fornecedores
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.business),
              ),
              title: const Text('Fornecedores'),
              subtitle: Text('${dataService.fornecedores.length} fornecedores cadastrados'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FornecedoresScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Usuários
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                child: Icon(Icons.people),
              ),
              title: const Text('Usuários do Sistema'),
              subtitle: Text('${dataService.usuarios.where((u) => u.ativo).length} usuários ativos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UsuariosScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Qualidade
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.verified),
              ),
              title: const Text('Controle de Qualidade'),
              subtitle: Text('${dataService.inspecoes.length} inspeções realizadas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QualidadeScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Relatórios
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.summarize),
              ),
              title: const Text('Relatórios e Exportações'),
              subtitle: const Text('PDF e CSV de todos os módulos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RelatoriosScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Histórico de Análises
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.history),
              ),
              title: const Text('Histórico de Análises'),
              subtitle: Text('${dataService.analises.length} análises realizadas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _mostrarHistoricoAnalises(context, dataService);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarHistoricoAnalises(BuildContext context, DataService dataService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Histórico de Análises',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Expanded(
                    child: dataService.analises.isEmpty
                        ? const Center(child: Text('Nenhuma análise realizada'))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: dataService.analises.length,
                            itemBuilder: (context, index) {
                              final analise = dataService.analises.reversed.toList()[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: analise.dentroEspecificacao == true
                                        ? Colors.green
                                        : Colors.orange,
                                    child: Icon(
                                      analise.dentroEspecificacao == true
                                          ? Icons.check
                                          : Icons.warning,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(analise.ligaNome),
                                  subtitle: Text(
                                    '${analise.ligaCodigo}\n'
                                    '${analise.dataHoraAnalise.day}/${analise.dataHoraAnalise.month}/${analise.dataHoraAnalise.year} '
                                    '${analise.dataHoraAnalise.hour}:${analise.dataHoraAnalise.minute.toString().padLeft(2, '0')}',
                                  ),
                                  isThreeLine: true,
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(analise.status),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      analise.status.nome,
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(StatusAnalise status) {
    switch (status) {
      case StatusAnalise.aprovado:
      case StatusAnalise.autorizadoVazamento:
        return Colors.green;
      case StatusAnalise.aguardandoCorrecao:
      case StatusAnalise.aprovadoComRessalvas:
        return Colors.orange;
      case StatusAnalise.reprovado:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

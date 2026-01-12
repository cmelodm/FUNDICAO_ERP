import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/etapa_producao_model.dart';
import '../services/data_service.dart';

/// Tela para gerenciar etapas hierárquicas de produção
class ProducaoEtapasScreen extends StatefulWidget {
  final String ordemId;
  final String ordemNumero;
  
  const ProducaoEtapasScreen({
    super.key,
    required this.ordemId,
    required this.ordemNumero,
  });

  @override
  State<ProducaoEtapasScreen> createState() => _ProducaoEtapasScreenState();
}

class _ProducaoEtapasScreenState extends State<ProducaoEtapasScreen> {
  final DataService _dataService = DataService();
  late List<EtapaProducao> _etapas;
  
  @override
  void initState() {
    super.initState();
    _carregarEtapas();
  }
  
  /// Carrega etapas salvas ou cria novas
  void _carregarEtapas() {
    final ordem = _dataService.ordensProducao.firstWhere(
      (o) => o.id == widget.ordemId,
      orElse: () => throw Exception('Ordem não encontrada'),
    );
    
    // Se ordem já tem etapas salvas, usa elas
    if (ordem.etapasHierarquicas != null && ordem.etapasHierarquicas!.isNotEmpty) {
      _etapas = ordem.etapasHierarquicas!;
    } else {
      // Caso contrário, usa template padrão
      _etapas = EtapasProducaoTemplate.getEtapasPadrao();
      _salvarEtapas(); // Salva as etapas iniciais
    }
  }
  
  /// Salva etapas no DataService
  Future<void> _salvarEtapas() async {
    final ordem = _dataService.ordensProducao.firstWhere(
      (o) => o.id == widget.ordemId,
    );
    
    final ordemAtualizada = ordem.copyWith(
      etapasHierarquicas: _etapas,
    );
    
    await _dataService.atualizarOrdemProducao(ordemAtualizada);
    
    // 🔥 Atualiza tela imediatamente
    if (mounted) {
      setState(() {});
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etapas - ${widget.ordemNumero}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _mostrarHistorico,
            tooltip: 'Histórico',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _etapas.length,
        itemBuilder: (context, index) {
          return _buildEtapaCard(_etapas[index], index);
        },
      ),
    );
  }
  
  /// Constrói card de etapa hierárquica
  Widget _buildEtapaCard(EtapaProducao etapa, int index) {
    final isExpanded = etapa.status != StatusEtapa.pendente;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: etapa.status.cor,
          width: 2,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          leading: CircleAvatar(
            backgroundColor: etapa.status.cor.withValues(alpha: 0.2),
            child: Icon(
              etapa.tipo.icone,
              color: etapa.status.cor,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  etapa.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: etapa.status.cor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  etapa.status.nome,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: etapa.status.cor,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                etapa.descricao,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: etapa.progresso / 100,
                  minHeight: 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(etapa.status.cor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${etapa.progresso.toStringAsFixed(0)}% concluído',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sub-etapas
                  if (etapa.subEtapas.isNotEmpty) ...[
                    const Text(
                      'Sub-etapas:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...etapa.subEtapas.map((subEtapa) {
                      return _buildSubEtapaCard(etapa, subEtapa);
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Botões de ação
                  _buildAcoesEtapa(etapa, index),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói card de sub-etapa
  Widget _buildSubEtapaCard(EtapaProducao etapaPai, SubEtapa subEtapa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: subEtapa.status.cor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: subEtapa.status.cor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            subEtapa.status == StatusSubEtapa.concluida
                ? Icons.check_circle
                : subEtapa.status == StatusSubEtapa.emAndamento
                    ? Icons.play_circle
                    : subEtapa.status == StatusSubEtapa.pulada
                        ? Icons.skip_next
                        : Icons.radio_button_unchecked,
            size: 20,
            color: subEtapa.status.cor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subEtapa.nome,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          decoration: subEtapa.status == StatusSubEtapa.concluida
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (!subEtapa.obrigatoria)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Opcional',
                          style: TextStyle(fontSize: 9),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subEtapa.descricao,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Botão de ação rápida
          if (subEtapa.status == StatusSubEtapa.pendente &&
              etapaPai.status == StatusEtapa.emAndamento)
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 20),
              onPressed: () => _iniciarSubEtapa(etapaPai, subEtapa),
              tooltip: 'Iniciar',
              color: Colors.blue,
            )
          else if (subEtapa.status == StatusSubEtapa.emAndamento)
            IconButton(
              icon: const Icon(Icons.check, size: 20),
              onPressed: () => _concluirSubEtapa(etapaPai, subEtapa),
              tooltip: 'Concluir',
              color: Colors.green,
            ),
        ],
      ),
    );
  }
  
  /// Constrói botões de ação da etapa
  Widget _buildAcoesEtapa(EtapaProducao etapa, int index) {
    return Row(
      children: [
        // Botão Iniciar
        if (etapa.podeIniciar)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _iniciarEtapa(etapa, index),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar Etapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        
        // Botão Pausar
        if (etapa.podePausar) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pausarEtapa(etapa, index),
              icon: const Icon(Icons.pause),
              label: const Text('Pausar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        
        // Botão Concluir
        if (etapa.podeConcluir)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: etapa.podeConcluir
                  ? () => _concluirEtapa(etapa, index)
                  : null,
              icon: const Icon(Icons.check_circle),
              label: const Text('Concluir Etapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        
        // Botão Cancelar (sempre disponível se não concluída)
        if (etapa.status != StatusEtapa.concluida) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _cancelarEtapa(etapa, index),
            icon: const Icon(Icons.cancel),
            tooltip: 'Cancelar Etapa',
            color: Colors.red,
          ),
        ],
      ],
    );
  }
  
  /// Inicia uma etapa
  void _iniciarEtapa(EtapaProducao etapa, int index) async {
    // Verificar se etapa anterior foi concluída
    if (index > 0 && _etapas[index - 1].status != StatusEtapa.concluida) {
      _mostrarAlerta(
        'Etapa Anterior Pendente',
        'Complete a etapa "${_etapas[index - 1].nome}" antes de iniciar esta.',
      );
      return;
    }
    
    setState(() {
      _etapas[index] = etapa.copyWith(
        status: StatusEtapa.emAndamento,
        dataInicio: DateTime.now(),
      );
    });
    
    await _salvarEtapas(); // 🔥 SALVAR NO DATASERVICE
    _mostrarSucesso('Etapa "${etapa.nome}" iniciada!');
  }
  
  /// Pausa uma etapa
  void _pausarEtapa(EtapaProducao etapa, int index) async {
    setState(() {
      _etapas[index] = etapa.copyWith(
        status: StatusEtapa.pausada,
      );
    });
    
    await _salvarEtapas(); // 🔥 SALVAR NO DATASERVICE
    _mostrarSucesso('Etapa "${etapa.nome}" pausada!');
  }
  
  /// Conclui uma etapa
  void _concluirEtapa(EtapaProducao etapa, int index) async {
    // Verificar se todas sub-etapas obrigatórias foram concluídas
    final subEtapasObrigatorias = etapa.subEtapas.where((s) => s.obrigatoria);
    final subEtapasNaoConcluidas = subEtapasObrigatorias
        .where((s) => s.status != StatusSubEtapa.concluida);
    
    if (subEtapasNaoConcluidas.isNotEmpty) {
      _mostrarAlerta(
        'Sub-etapas Pendentes',
        'Complete todas as sub-etapas obrigatórias antes de concluir esta etapa.',
      );
      return;
    }
    
    setState(() {
      _etapas[index] = etapa.copyWith(
        status: StatusEtapa.concluida,
        dataConclusao: DateTime.now(),
      );
    });
    
    await _salvarEtapas(); // 🔥 SALVAR NO DATASERVICE
    _mostrarSucesso('✅ Etapa "${etapa.nome}" concluída!');
    
    // Verificar se todas as etapas foram concluídas
    if (_etapas.every((e) => e.status == StatusEtapa.concluida)) {
      _mostrarDialogOrdemConcluida();
    }
  }
  
  /// Cancela uma etapa
  void _cancelarEtapa(EtapaProducao etapa, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Etapa'),
        content: Text('Deseja realmente cancelar a etapa "${etapa.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _etapas[index] = etapa.copyWith(
                  status: StatusEtapa.cancelada,
                );
              });
              await _salvarEtapas(); // 🔥 SALVAR NO DATASERVICE
              _mostrarSucesso('Etapa "${etapa.nome}" cancelada!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
  }
  
  /// Inicia uma sub-etapa
  void _iniciarSubEtapa(EtapaProducao etapaPai, SubEtapa subEtapa) async {
    setState(() {
      final index = _etapas.indexWhere((e) => e.id == etapaPai.id);
      final subIndex = etapaPai.subEtapas.indexWhere((s) => s.id == subEtapa.id);
      
      final novasSubEtapas = List<SubEtapa>.from(etapaPai.subEtapas);
      novasSubEtapas[subIndex] = subEtapa.copyWith(
        status: StatusSubEtapa.emAndamento,
        dataInicio: DateTime.now(),
      );
      
      _etapas[index] = etapaPai.copyWith(subEtapas: novasSubEtapas);
    });
    
    await _salvarEtapas(); // 🔥 SALVAR NO DATASERVICE
    _mostrarSucesso('Sub-etapa "${subEtapa.nome}" iniciada!');
  }
  
  /// Conclui uma sub-etapa
  void _concluirSubEtapa(EtapaProducao etapaPai, SubEtapa subEtapa) async {
    setState(() {
      final index = _etapas.indexWhere((e) => e.id == etapaPai.id);
      final subIndex = etapaPai.subEtapas.indexWhere((s) => s.id == subEtapa.id);
      
      final novasSubEtapas = List<SubEtapa>.from(etapaPai.subEtapas);
      novasSubEtapas[subIndex] = subEtapa.copyWith(
        status: StatusSubEtapa.concluida,
        dataConclusao: DateTime.now(),
      );
      
      _etapas[index] = etapaPai.copyWith(subEtapas: novasSubEtapas);
    });
    
    await _salvarEtapas(); // 🔥 SALVAR NO DATASERVICE
    _mostrarSucesso('✅ Sub-etapa "${subEtapa.nome}" concluída!');
  }
  
  /// Mostra histórico de execução
  void _mostrarHistorico() {
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
              const Text(
                'Histórico de Execução',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ..._etapas.where((e) => e.status != StatusEtapa.pendente).map((etapa) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      etapa.tipo.icone,
                      color: etapa.status.cor,
                    ),
                    title: Text(etapa.nome),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(etapa.status.nome),
                        if (etapa.dataInicio != null)
                          Text(
                            'Início: ${DateFormat('dd/MM/yyyy HH:mm').format(etapa.dataInicio!)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        if (etapa.dataConclusao != null)
                          Text(
                            'Conclusão: ${DateFormat('dd/MM/yyyy HH:mm').format(etapa.dataConclusao!)}',
                            style: const TextStyle(fontSize: 11),
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: etapa.status.cor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${etapa.progresso.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: etapa.status.cor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Mostra diálogo de ordem concluída
  void _mostrarDialogOrdemConcluida() async {
    // 🔥 ATUALIZA STATUS DA ORDEM PARA "CONCLUÍDA"
    await _atualizarStatusOrdem();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber[700], size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Ordem Concluída!'),
            ),
          ],
        ),
        content: Text(
          'Todas as etapas da ordem ${widget.ordemNumero} foram concluídas com sucesso!\n\n'
          'A ordem está pronta para expedição.',
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Fecha diálogo
              Navigator.pop(context); // Volta para tela de produção
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Finalizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Atualiza status da ordem para concluída
  Future<void> _atualizarStatusOrdem() async {
    try {
      final ordem = _dataService.ordensProducao.firstWhere(
        (o) => o.id == widget.ordemId,
      );
      
      final ordemAtualizada = ordem.copyWith(
        status: 'concluida',
        dataConclusao: DateTime.now(),
      );
      
      await _dataService.atualizarOrdemProducao(ordemAtualizada);
      
      if (kDebugMode) {
        debugPrint('✅ Status da ordem ${widget.ordemNumero} atualizado para CONCLUÍDA');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao atualizar status da ordem: $e');
      }
    }
  }
  
  /// Mostra mensagem de sucesso
  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  /// Mostra alerta
  void _mostrarAlerta(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(child: Text(titulo)),
          ],
        ),
        content: Text(mensagem),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

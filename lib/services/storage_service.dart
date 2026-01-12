import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:foundry_erp/models/ordem_producao_model.dart';
import 'package:foundry_erp/models/etapa_producao_model.dart' as Hierarquico;

/// Serviço de armazenamento persistente usando Hive
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Boxes do Hive
  Box<Map>? _ordensProducaoBox;

  /// Inicializa o Hive e registra adaptadores
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Abre box para ordens de produção (usando Map para flexibilidade)
    _ordensProducaoBox = await Hive.openBox<Map>('ordensProducao');
  }

  /// Salva uma ordem de produção
  Future<void> salvarOrdemProducao(OrdemProducaoModel ordem) async {
    if (_ordensProducaoBox == null) {
      throw Exception('StorageService não foi inicializado! Chame init() primeiro.');
    }
    
    // Converte para Map e salva
    final ordemMap = _ordemToMap(ordem);
    await _ordensProducaoBox!.put(ordem.id, ordemMap);
  }

  /// Carrega uma ordem de produção
  OrdemProducaoModel? carregarOrdemProducao(String id) {
    if (_ordensProducaoBox == null) return null;
    
    final ordemMap = _ordensProducaoBox!.get(id);
    if (ordemMap == null) return null;
    
    return _ordemFromMap(Map<String, dynamic>.from(ordemMap));
  }

  /// Carrega todas as ordens de produção
  List<OrdemProducaoModel> carregarTodasOrdens() {
    if (_ordensProducaoBox == null) return [];
    
    final ordens = <OrdemProducaoModel>[];
    for (var ordemMap in _ordensProducaoBox!.values) {
      try {
        final ordem = _ordemFromMap(Map<String, dynamic>.from(ordemMap));
        ordens.add(ordem);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Erro ao carregar ordem: $e');
        }
      }
    }
    
    return ordens;
  }

  /// Remove uma ordem de produção
  Future<void> removerOrdemProducao(String id) async {
    if (_ordensProducaoBox == null) return;
    await _ordensProducaoBox!.delete(id);
  }

  /// Limpa todas as ordens (usar apenas para testes)
  Future<void> limparTodasOrdens() async {
    if (_ordensProducaoBox == null) return;
    await _ordensProducaoBox!.clear();
  }

  /// Converte OrdemProducaoModel para Map
  Map<String, dynamic> _ordemToMap(OrdemProducaoModel ordem) {
    return {
      'id': ordem.id,
      'numero': ordem.numero,
      'produto': ordem.produto,
      'cliente': ordem.cliente,
      'status': ordem.status,
      'prioridade': ordem.prioridade,
      'materiaisUtilizados': ordem.materiaisUtilizados.map((m) => {
        'materialId': m.materialId,
        'materialNome': m.materialNome,
        'quantidade': m.quantidade,
        'custoUnitario': m.custoUnitario,
      }).toList(),
      'etapas': ordem.etapas.map((e) => {
        'id': e.id,
        'nome': e.nome,
        'status': e.status,
        'operador': e.operador,
        'maquina': e.maquina,
        'dataInicio': e.dataInicio?.toIso8601String(),
        'dataConclusao': e.dataConclusao?.toIso8601String(),
        'tempoEstimadoMinutos': e.tempoEstimadoMinutos,
        'tempoRealMinutos': e.tempoRealMinutos,
      }).toList(),
      'etapasHierarquicas': ordem.etapasHierarquicas?.map((Hierarquico.EtapaProducao etapa) => {
        'id': etapa.id,
        'nome': etapa.nome,
        'descricao': etapa.descricao,
        'ordem': etapa.ordem,
        'tipo': etapa.tipo.name,
        'status': etapa.status.name,
        'dataInicio': etapa.dataInicio?.toIso8601String(),
        'dataConclusao': etapa.dataConclusao?.toIso8601String(),
        'responsavelId': etapa.responsavelId,
        'responsavelNome': etapa.responsavelNome,
        'observacoes': etapa.observacoes,
        'subEtapas': etapa.subEtapas.map((Hierarquico.SubEtapa sub) => {
          'id': sub.id,
          'nome': sub.nome,
          'descricao': sub.descricao,
          'ordem': sub.ordem,
          'status': sub.status.name,
          'dataInicio': sub.dataInicio?.toIso8601String(),
          'dataConclusao': sub.dataConclusao?.toIso8601String(),
          'responsavelId': sub.responsavelId,
          'responsavelNome': sub.responsavelNome,
          'obrigatoria': sub.obrigatoria,
          'checklist': sub.checklist,
        }).toList(),
      }).toList(),
      'custoEstimado': ordem.custoEstimado,
      'custoReal': ordem.custoReal,
      'dataCriacao': ordem.dataCriacao.toIso8601String(),
      'dataInicio': ordem.dataInicio?.toIso8601String(),
      'dataConclusao': ordem.dataConclusao?.toIso8601String(),
      'observacoes': ordem.observacoes,
    };
  }

  /// Converte Map para OrdemProducaoModel
  OrdemProducaoModel _ordemFromMap(Map<String, dynamic> map) {
    return OrdemProducaoModel(
      id: map['id'] as String,
      numero: map['numero'] as String,
      produto: map['produto'] as String,
      cliente: map['cliente'] as String,
      status: map['status'] as String,
      prioridade: map['prioridade'] as String,
      materiaisUtilizados: (map['materiaisUtilizados'] as List?)
          ?.map((m) => MaterialUtilizado(
                materialId: m['materialId'] as String,
                materialNome: m['materialNome'] as String,
                quantidade: (m['quantidade'] as num).toDouble(),
                custoUnitario: (m['custoUnitario'] as num).toDouble(),
              ))
          .toList() ?? [],
      etapas: (map['etapas'] as List?)
          ?.map((e) => EtapaProducao(
                id: e['id'] as String,
                nome: e['nome'] as String,
                status: e['status'] as String,
                operador: e['operador'] as String?,
                maquina: e['maquina'] as String?,
                dataInicio: e['dataInicio'] != null
                    ? DateTime.parse(e['dataInicio'] as String)
                    : null,
                dataConclusao: e['dataConclusao'] != null
                    ? DateTime.parse(e['dataConclusao'] as String)
                    : null,
                tempoEstimadoMinutos: e['tempoEstimadoMinutos'] as int?,
                tempoRealMinutos: e['tempoRealMinutos'] as int?,
              ))
          .toList() ?? [],
      etapasHierarquicas: (map['etapasHierarquicas'] as List?)
          ?.map((etapa) => Hierarquico.EtapaProducao(
                id: etapa['id'] as String,
                nome: etapa['nome'] as String,
                descricao: etapa['descricao'] as String,
                ordem: etapa['ordem'] as int,
                tipo: Hierarquico.TipoEtapa.values.firstWhere(
                  (t) => t.name == etapa['tipo'],
                  orElse: () => Hierarquico.TipoEtapa.preparacao,
                ),
                status: Hierarquico.StatusEtapa.values.firstWhere(
                  (s) => s.name == etapa['status'],
                  orElse: () => Hierarquico.StatusEtapa.pendente,
                ),
                dataInicio: etapa['dataInicio'] != null
                    ? DateTime.parse(etapa['dataInicio'] as String)
                    : null,
                dataConclusao: etapa['dataConclusao'] != null
                    ? DateTime.parse(etapa['dataConclusao'] as String)
                    : null,
                responsavelId: etapa['responsavelId'] as String?,
                responsavelNome: etapa['responsavelNome'] as String?,
                observacoes: etapa['observacoes'] as String?,
                subEtapas: (etapa['subEtapas'] as List?)
                    ?.map((sub) => Hierarquico.SubEtapa(
                          id: sub['id'] as String,
                          nome: sub['nome'] as String,
                          descricao: sub['descricao'] as String,
                          ordem: sub['ordem'] as int,
                          status: Hierarquico.StatusSubEtapa.values.firstWhere(
                            (s) => s.name == sub['status'],
                            orElse: () => Hierarquico.StatusSubEtapa.pendente,
                          ),
                          dataInicio: sub['dataInicio'] != null
                              ? DateTime.parse(sub['dataInicio'] as String)
                              : null,
                          dataConclusao: sub['dataConclusao'] != null
                              ? DateTime.parse(sub['dataConclusao'] as String)
                              : null,
                          responsavelId: sub['responsavelId'] as String?,
                          responsavelNome: sub['responsavelNome'] as String?,
                          obrigatoria: sub['obrigatoria'] as bool? ?? true,
                          checklist: sub['checklist'] as String?,
                        ))
                    .toList() ?? [],
              ))
          .toList(),
      custoEstimado: (map['custoEstimado'] as num).toDouble(),
      custoReal: (map['custoReal'] as num).toDouble(),
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
      dataInicio: map['dataInicio'] != null
          ? DateTime.parse(map['dataInicio'] as String)
          : null,
      dataConclusao: map['dataConclusao'] != null
          ? DateTime.parse(map['dataConclusao'] as String)
          : null,
      observacoes: map['observacoes'] as String?,
    );
  }
}



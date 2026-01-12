import 'etapa_producao_model.dart' as Hierarquico;

class OrdemProducaoModel {
  final String id;
  final String numero;
  final String produto;
  final String cliente;
  final String status; // aguardando, em_producao, pausada, concluida, cancelada
  final String prioridade; // baixa, media, alta, urgente
  final List<MaterialUtilizado> materiaisUtilizados;
  final List<EtapaProducao> etapas;
  final List<Hierarquico.EtapaProducao>? etapasHierarquicas; // 🔥 NOVO - Etapas hierárquicas com sub-etapas
  final double custoEstimado;
  final double custoReal;
  final DateTime dataCriacao;
  final DateTime? dataInicio;
  final DateTime? dataConclusao;
  final String? observacoes;

  OrdemProducaoModel({
    required this.id,
    required this.numero,
    required this.produto,
    required this.cliente,
    required this.status,
    required this.prioridade,
    required this.materiaisUtilizados,
    required this.etapas,
    this.etapasHierarquicas, // 🔥 NOVO
    required this.custoEstimado,
    required this.custoReal,
    required this.dataCriacao,
    this.dataInicio,
    this.dataConclusao,
    this.observacoes,
  });

  // Cor do status
  String get statusColor {
    switch (status) {
      case 'aguardando':
        return 'grey';
      case 'em_producao':
        return 'blue';
      case 'pausada':
        return 'orange';
      case 'concluida':
        return 'green';
      case 'cancelada':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Label do status
  String get statusLabel {
    switch (status) {
      case 'aguardando':
        return 'Aguardando';
      case 'em_producao':
        return 'Em Produção';
      case 'pausada':
        return 'Pausada';
      case 'concluida':
        return 'Concluída';
      case 'cancelada':
        return 'Cancelada';
      default:
        return 'Desconhecido';
    }
  }

  // Progresso em %
  double get progresso {
    if (etapas.isEmpty) return 0;
    final concluidas = etapas.where((e) => e.status == 'concluida').length;
    return (concluidas / etapas.length) * 100;
  }
  
  /// Método copyWith para OrdemProducaoModel
  OrdemProducaoModel copyWith({
    String? id,
    String? numero,
    String? produto,
    String? cliente,
    String? status,
    String? prioridade,
    List<MaterialUtilizado>? materiaisUtilizados,
    List<EtapaProducao>? etapas,
    List<Hierarquico.EtapaProducao>? etapasHierarquicas,
    double? custoEstimado,
    double? custoReal,
    DateTime? dataCriacao,
    DateTime? dataInicio,
    DateTime? dataConclusao,
    String? observacoes,
  }) {
    return OrdemProducaoModel(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      produto: produto ?? this.produto,
      cliente: cliente ?? this.cliente,
      status: status ?? this.status,
      prioridade: prioridade ?? this.prioridade,
      materiaisUtilizados: materiaisUtilizados ?? this.materiaisUtilizados,
      etapas: etapas ?? this.etapas,
      etapasHierarquicas: etapasHierarquicas ?? this.etapasHierarquicas,
      custoEstimado: custoEstimado ?? this.custoEstimado,
      custoReal: custoReal ?? this.custoReal,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'produto': produto,
      'cliente': cliente,
      'status': status,
      'prioridade': prioridade,
      'materiaisUtilizados':
          materiaisUtilizados.map((m) => m.toMap()).toList(),
      'etapas': etapas.map((e) => e.toMap()).toList(),
      'custoEstimado': custoEstimado,
      'custoReal': custoReal,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataInicio': dataInicio?.toIso8601String(),
      'dataConclusao': dataConclusao?.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  factory OrdemProducaoModel.fromMap(Map<String, dynamic> map) {
    return OrdemProducaoModel(
      id: map['id'] as String,
      numero: map['numero'] as String,
      produto: map['produto'] as String,
      cliente: map['cliente'] as String,
      status: map['status'] as String,
      prioridade: map['prioridade'] as String,
      materiaisUtilizados: (map['materiaisUtilizados'] as List)
          .map((m) => MaterialUtilizado.fromMap(m as Map<String, dynamic>))
          .toList(),
      etapas: (map['etapas'] as List)
          .map((e) => EtapaProducao.fromMap(e as Map<String, dynamic>))
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

class MaterialUtilizado {
  final String materialId;
  final String materialNome;
  final double quantidade;
  final double custoUnitario;

  MaterialUtilizado({
    required this.materialId,
    required this.materialNome,
    required this.quantidade,
    required this.custoUnitario,
  });

  double get custoTotal => quantidade * custoUnitario;

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialNome': materialNome,
      'quantidade': quantidade,
      'custoUnitario': custoUnitario,
    };
  }

  factory MaterialUtilizado.fromMap(Map<String, dynamic> map) {
    return MaterialUtilizado(
      materialId: map['materialId'] as String,
      materialNome: map['materialNome'] as String,
      quantidade: (map['quantidade'] as num).toDouble(),
      custoUnitario: (map['custoUnitario'] as num).toDouble(),
    );
  }
}

class EtapaProducao {
  final String id;
  final String nome; // moldagem, fundição, usinagem, pintura, etc
  final String status; // aguardando, em_andamento, concluida
  final String? operador;
  final String? maquina;
  final DateTime? dataInicio;
  final DateTime? dataConclusao;
  final int? tempoEstimadoMinutos;
  final int? tempoRealMinutos;

  EtapaProducao({
    required this.id,
    required this.nome,
    required this.status,
    this.operador,
    this.maquina,
    this.dataInicio,
    this.dataConclusao,
    this.tempoEstimadoMinutos,
    this.tempoRealMinutos,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'status': status,
      'operador': operador,
      'maquina': maquina,
      'dataInicio': dataInicio?.toIso8601String(),
      'dataConclusao': dataConclusao?.toIso8601String(),
      'tempoEstimadoMinutos': tempoEstimadoMinutos,
      'tempoRealMinutos': tempoRealMinutos,
    };
  }

  factory EtapaProducao.fromMap(Map<String, dynamic> map) {
    return EtapaProducao(
      id: map['id'] as String,
      nome: map['nome'] as String,
      status: map['status'] as String,
      operador: map['operador'] as String?,
      maquina: map['maquina'] as String?,
      dataInicio: map['dataInicio'] != null
          ? DateTime.parse(map['dataInicio'] as String)
          : null,
      dataConclusao: map['dataConclusao'] != null
          ? DateTime.parse(map['dataConclusao'] as String)
          : null,
      tempoEstimadoMinutos: map['tempoEstimadoMinutos'] as int?,
      tempoRealMinutos: map['tempoRealMinutos'] as int?,
    );
  }
}

class AnaliseEspectrometrica {
  final String id;
  final String ligaId;
  final String ligaNome;
  final String ligaCodigo;
  final String ordemProducaoId;
  final String equipamentoId;
  final String operadorId;
  final String operadorNome;
  final DateTime dataHoraAnalise;
  final List<ElementoAnalisado> elementos;
  final StatusAnalise status;
  final String? observacoes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Resultado da validação
  final bool? dentroEspecificacao;
  final List<String>? elementosForaRange;
  final CorrecaoLiga? correcaoSugerida;
  final bool? autorizadoVazamento;
  final String? autorizadoPor;
  final DateTime? dataAutorizacao;

  AnaliseEspectrometrica({
    required this.id,
    required this.ligaId,
    required this.ligaNome,
    required this.ligaCodigo,
    required this.ordemProducaoId,
    required this.equipamentoId,
    required this.operadorId,
    required this.operadorNome,
    required this.dataHoraAnalise,
    required this.elementos,
    required this.status,
    this.observacoes,
    required this.createdAt,
    this.updatedAt,
    this.dentroEspecificacao,
    this.elementosForaRange,
    this.correcaoSugerida,
    this.autorizadoVazamento,
    this.autorizadoPor,
    this.dataAutorizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ligaId': ligaId,
      'ligaNome': ligaNome,
      'ligaCodigo': ligaCodigo,
      'ordemProducaoId': ordemProducaoId,
      'equipamentoId': equipamentoId,
      'operadorId': operadorId,
      'operadorNome': operadorNome,
      'dataHoraAnalise': dataHoraAnalise.toIso8601String(),
      'elementos': elementos.map((e) => e.toMap()).toList(),
      'status': status.toString(),
      'observacoes': observacoes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dentroEspecificacao': dentroEspecificacao,
      'elementosForaRange': elementosForaRange,
      'correcaoSugerida': correcaoSugerida?.toMap(),
      'autorizadoVazamento': autorizadoVazamento,
      'autorizadoPor': autorizadoPor,
      'dataAutorizacao': dataAutorizacao?.toIso8601String(),
    };
  }

  factory AnaliseEspectrometrica.fromMap(Map<String, dynamic> map) {
    return AnaliseEspectrometrica(
      id: map['id'] ?? '',
      ligaId: map['ligaId'] ?? '',
      ligaNome: map['ligaNome'] ?? '',
      ligaCodigo: map['ligaCodigo'] ?? '',
      ordemProducaoId: map['ordemProducaoId'] ?? '',
      equipamentoId: map['equipamentoId'] ?? '',
      operadorId: map['operadorId'] ?? '',
      operadorNome: map['operadorNome'] ?? '',
      dataHoraAnalise: DateTime.parse(map['dataHoraAnalise']),
      elementos: (map['elementos'] as List)
          .map((e) => ElementoAnalisado.fromMap(e))
          .toList(),
      status: StatusAnalise.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => StatusAnalise.aguardandoAnalise,
      ),
      observacoes: map['observacoes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      dentroEspecificacao: map['dentroEspecificacao'],
      elementosForaRange: map['elementosForaRange'] != null 
          ? List<String>.from(map['elementosForaRange']) 
          : null,
      correcaoSugerida: map['correcaoSugerida'] != null
          ? CorrecaoLiga.fromMap(map['correcaoSugerida'])
          : null,
      autorizadoVazamento: map['autorizadoVazamento'],
      autorizadoPor: map['autorizadoPor'],
      dataAutorizacao: map['dataAutorizacao'] != null
          ? DateTime.parse(map['dataAutorizacao'])
          : null,
    );
  }

  AnaliseEspectrometrica copyWith({
    String? id,
    String? ligaId,
    String? ligaNome,
    String? ligaCodigo,
    String? ordemProducaoId,
    String? equipamentoId,
    String? operadorId,
    String? operadorNome,
    DateTime? dataHoraAnalise,
    List<ElementoAnalisado>? elementos,
    StatusAnalise? status,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? dentroEspecificacao,
    List<String>? elementosForaRange,
    CorrecaoLiga? correcaoSugerida,
    bool? autorizadoVazamento,
    String? autorizadoPor,
    DateTime? dataAutorizacao,
  }) {
    return AnaliseEspectrometrica(
      id: id ?? this.id,
      ligaId: ligaId ?? this.ligaId,
      ligaNome: ligaNome ?? this.ligaNome,
      ligaCodigo: ligaCodigo ?? this.ligaCodigo,
      ordemProducaoId: ordemProducaoId ?? this.ordemProducaoId,
      equipamentoId: equipamentoId ?? this.equipamentoId,
      operadorId: operadorId ?? this.operadorId,
      operadorNome: operadorNome ?? this.operadorNome,
      dataHoraAnalise: dataHoraAnalise ?? this.dataHoraAnalise,
      elementos: elementos ?? this.elementos,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dentroEspecificacao: dentroEspecificacao ?? this.dentroEspecificacao,
      elementosForaRange: elementosForaRange ?? this.elementosForaRange,
      correcaoSugerida: correcaoSugerida ?? this.correcaoSugerida,
      autorizadoVazamento: autorizadoVazamento ?? this.autorizadoVazamento,
      autorizadoPor: autorizadoPor ?? this.autorizadoPor,
      dataAutorizacao: dataAutorizacao ?? this.dataAutorizacao,
    );
  }
}

class ElementoAnalisado {
  final String simbolo;
  final String nome;
  final double percentualMedido;
  final double percentualMinimo;
  final double percentualMaximo;
  final bool dentroRange;
  final double? desvio; // Diferença para o range mais próximo

  ElementoAnalisado({
    required this.simbolo,
    required this.nome,
    required this.percentualMedido,
    required this.percentualMinimo,
    required this.percentualMaximo,
    required this.dentroRange,
    this.desvio,
  });

  Map<String, dynamic> toMap() {
    return {
      'simbolo': simbolo,
      'nome': nome,
      'percentualMedido': percentualMedido,
      'percentualMinimo': percentualMinimo,
      'percentualMaximo': percentualMaximo,
      'dentroRange': dentroRange,
      'desvio': desvio,
    };
  }

  factory ElementoAnalisado.fromMap(Map<String, dynamic> map) {
    return ElementoAnalisado(
      simbolo: map['simbolo'] ?? '',
      nome: map['nome'] ?? '',
      percentualMedido: (map['percentualMedido'] as num).toDouble(),
      percentualMinimo: (map['percentualMinimo'] as num).toDouble(),
      percentualMaximo: (map['percentualMaximo'] as num).toDouble(),
      dentroRange: map['dentroRange'] ?? false,
      desvio: map['desvio'] != null ? (map['desvio'] as num).toDouble() : null,
    );
  }
}

class CorrecaoLiga {
  final String id;
  final String analiseId;
  final List<CorrecaoElemento> correcoes;
  final double pesoTotalLiga; // kg no forno
  final DateTime dataCalculo;
  final bool aplicada;
  final DateTime? dataAplicacao;
  final String? aplicadaPor;

  CorrecaoLiga({
    required this.id,
    required this.analiseId,
    required this.correcoes,
    required this.pesoTotalLiga,
    required this.dataCalculo,
    this.aplicada = false,
    this.dataAplicacao,
    this.aplicadaPor,
  });

  double get pesoTotalCorrecao {
    return correcoes.fold(0.0, (sum, c) => sum + c.quantidadeAdicionar);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'analiseId': analiseId,
      'correcoes': correcoes.map((c) => c.toMap()).toList(),
      'pesoTotalLiga': pesoTotalLiga,
      'dataCalculo': dataCalculo.toIso8601String(),
      'aplicada': aplicada,
      'dataAplicacao': dataAplicacao?.toIso8601String(),
      'aplicadaPor': aplicadaPor,
    };
  }

  factory CorrecaoLiga.fromMap(Map<String, dynamic> map) {
    return CorrecaoLiga(
      id: map['id'] ?? '',
      analiseId: map['analiseId'] ?? '',
      correcoes: (map['correcoes'] as List)
          .map((c) => CorrecaoElemento.fromMap(c))
          .toList(),
      pesoTotalLiga: (map['pesoTotalLiga'] as num).toDouble(),
      dataCalculo: DateTime.parse(map['dataCalculo']),
      aplicada: map['aplicada'] ?? false,
      dataAplicacao: map['dataAplicacao'] != null
          ? DateTime.parse(map['dataAplicacao'])
          : null,
      aplicadaPor: map['aplicadaPor'],
    );
  }
}

class CorrecaoElemento {
  final String simbolo;
  final String nome;
  final double percentualAtual;
  final double percentualDesejado;
  final double quantidadeAdicionar; // kg de elemento puro
  final String materialId;
  final String materialNome;

  CorrecaoElemento({
    required this.simbolo,
    required this.nome,
    required this.percentualAtual,
    required this.percentualDesejado,
    required this.quantidadeAdicionar,
    required this.materialId,
    required this.materialNome,
  });

  Map<String, dynamic> toMap() {
    return {
      'simbolo': simbolo,
      'nome': nome,
      'percentualAtual': percentualAtual,
      'percentualDesejado': percentualDesejado,
      'quantidadeAdicionar': quantidadeAdicionar,
      'materialId': materialId,
      'materialNome': materialNome,
    };
  }

  factory CorrecaoElemento.fromMap(Map<String, dynamic> map) {
    return CorrecaoElemento(
      simbolo: map['simbolo'] ?? '',
      nome: map['nome'] ?? '',
      percentualAtual: (map['percentualAtual'] as num).toDouble(),
      percentualDesejado: (map['percentualDesejado'] as num).toDouble(),
      quantidadeAdicionar: (map['quantidadeAdicionar'] as num).toDouble(),
      materialId: map['materialId'] ?? '',
      materialNome: map['materialNome'] ?? '',
    );
  }
}

enum StatusAnalise {
  aguardandoAnalise,
  emAnalise,
  aprovado,
  aprovadoComRessalvas,
  reprovado,
  aguardandoCorrecao,
  corrigido,
  autorizadoVazamento,
}

extension StatusAnaliseExtension on StatusAnalise {
  String get nome {
    switch (this) {
      case StatusAnalise.aguardandoAnalise:
        return 'Aguardando Análise';
      case StatusAnalise.emAnalise:
        return 'Em Análise';
      case StatusAnalise.aprovado:
        return 'Aprovado';
      case StatusAnalise.aprovadoComRessalvas:
        return 'Aprovado com Ressalvas';
      case StatusAnalise.reprovado:
        return 'Reprovado';
      case StatusAnalise.aguardandoCorrecao:
        return 'Aguardando Correção';
      case StatusAnalise.corrigido:
        return 'Corrigido';
      case StatusAnalise.autorizadoVazamento:
        return 'Autorizado para Vazamento';
    }
  }

  String get cor {
    switch (this) {
      case StatusAnalise.aguardandoAnalise:
        return 'grey';
      case StatusAnalise.emAnalise:
        return 'blue';
      case StatusAnalise.aprovado:
        return 'green';
      case StatusAnalise.aprovadoComRessalvas:
        return 'orange';
      case StatusAnalise.reprovado:
        return 'red';
      case StatusAnalise.aguardandoCorrecao:
        return 'orange';
      case StatusAnalise.corrigido:
        return 'teal';
      case StatusAnalise.autorizadoVazamento:
        return 'darkgreen';
    }
  }
}

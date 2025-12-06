class AnaliseEspectrometricaModel {
  final String id;
  final String ligaId;
  final String ligaCodigo;
  final double pesoLigaAtual; // kg de liga já no forno
  final DateTime dataAnalise;
  final String operador;
  final Map<String, ElementoAnalisado> elementosAnalisados;
  final StatusAnalise status;
  final List<CorrecaoElemento> correcoesNecessarias;
  final String? observacoes;
  final bool autorizado;
  final String? autorizadoPor;
  final DateTime? dataAutorizacao;

  AnaliseEspectrometricaModel({
    required this.id,
    required this.ligaId,
    required this.ligaCodigo,
    required this.pesoLigaAtual,
    required this.dataAnalise,
    required this.operador,
    required this.elementosAnalisados,
    required this.status,
    required this.correcoesNecessarias,
    this.observacoes,
    required this.autorizado,
    this.autorizadoPor,
    this.dataAutorizacao,
  });

  // Verificar se todos os elementos estão dentro do range
  bool get todosElementosDentroRange {
    return elementosAnalisados.values.every((e) => e.dentroRange);
  }

  // Verificar se precisa correção
  bool get precisaCorrecao {
    return correcoesNecessarias.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ligaId': ligaId,
      'ligaCodigo': ligaCodigo,
      'pesoLigaAtual': pesoLigaAtual,
      'dataAnalise': dataAnalise.toIso8601String(),
      'operador': operador,
      'elementosAnalisados': elementosAnalisados
          .map((key, value) => MapEntry(key, value.toMap())),
      'status': status.toString(),
      'correcoesNecessarias':
          correcoesNecessarias.map((c) => c.toMap()).toList(),
      'observacoes': observacoes,
      'autorizado': autorizado,
      'autorizadoPor': autorizadoPor,
      'dataAutorizacao': dataAutorizacao?.toIso8601String(),
    };
  }

  factory AnaliseEspectrometricaModel.fromMap(Map<String, dynamic> map) {
    return AnaliseEspectrometricaModel(
      id: map['id'] as String,
      ligaId: map['ligaId'] as String,
      ligaCodigo: map['ligaCodigo'] as String,
      pesoLigaAtual: (map['pesoLigaAtual'] as num).toDouble(),
      dataAnalise: DateTime.parse(map['dataAnalise'] as String),
      operador: map['operador'] as String,
      elementosAnalisados: (map['elementosAnalisados'] as Map)
          .map((key, value) => MapEntry(
              key as String,
              ElementoAnalisado.fromMap(value as Map<String, dynamic>))),
      status: StatusAnalise.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      correcoesNecessarias: (map['correcoesNecessarias'] as List)
          .map((c) => CorrecaoElemento.fromMap(c as Map<String, dynamic>))
          .toList(),
      observacoes: map['observacoes'] as String?,
      autorizado: map['autorizado'] as bool,
      autorizadoPor: map['autorizadoPor'] as String?,
      dataAutorizacao: map['dataAutorizacao'] != null
          ? DateTime.parse(map['dataAutorizacao'] as String)
          : null,
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
  final double desvio; // Diferença do nominal

  ElementoAnalisado({
    required this.simbolo,
    required this.nome,
    required this.percentualMedido,
    required this.percentualMinimo,
    required this.percentualMaximo,
    required this.dentroRange,
    required this.desvio,
  });

  String get statusTexto {
    if (dentroRange) {
      return 'OK';
    } else if (percentualMedido < percentualMinimo) {
      return 'BAIXO';
    } else {
      return 'ALTO';
    }
  }

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
      simbolo: map['simbolo'] as String,
      nome: map['nome'] as String,
      percentualMedido: (map['percentualMedido'] as num).toDouble(),
      percentualMinimo: (map['percentualMinimo'] as num).toDouble(),
      percentualMaximo: (map['percentualMaximo'] as num).toDouble(),
      dentroRange: map['dentroRange'] as bool,
      desvio: (map['desvio'] as num).toDouble(),
    );
  }
}

class CorrecaoElemento {
  final String simbolo;
  final String nome;
  final double percentualAtual;
  final double percentualDesejado;
  final double quantidadeAdicionar; // kg

  CorrecaoElemento({
    required this.simbolo,
    required this.nome,
    required this.percentualAtual,
    required this.percentualDesejado,
    required this.quantidadeAdicionar,
  });

  Map<String, dynamic> toMap() {
    return {
      'simbolo': simbolo,
      'nome': nome,
      'percentualAtual': percentualAtual,
      'percentualDesejado': percentualDesejado,
      'quantidadeAdicionar': quantidadeAdicionar,
    };
  }

  factory CorrecaoElemento.fromMap(Map<String, dynamic> map) {
    return CorrecaoElemento(
      simbolo: map['simbolo'] as String,
      nome: map['nome'] as String,
      percentualAtual: (map['percentualAtual'] as num).toDouble(),
      percentualDesejado: (map['percentualDesejado'] as num).toDouble(),
      quantidadeAdicionar: (map['quantidadeAdicionar'] as num).toDouble(),
    );
  }
}

enum StatusAnalise {
  aguardandoAnalise,
  emAnalise,
  dentroEspecificacao,
  foraEspecificacao,
  corrigido,
  autorizado,
  rejeitado,
}

extension StatusAnaliseExtension on StatusAnalise {
  String get label {
    switch (this) {
      case StatusAnalise.aguardandoAnalise:
        return 'Aguardando Análise';
      case StatusAnalise.emAnalise:
        return 'Em Análise';
      case StatusAnalise.dentroEspecificacao:
        return 'Dentro da Especificação';
      case StatusAnalise.foraEspecificacao:
        return 'Fora da Especificação';
      case StatusAnalise.corrigido:
        return 'Corrigido';
      case StatusAnalise.autorizado:
        return 'Autorizado para Vazamento';
      case StatusAnalise.rejeitado:
        return 'Rejeitado';
    }
  }

  String get cor {
    switch (this) {
      case StatusAnalise.aguardandoAnalise:
        return 'grey';
      case StatusAnalise.emAnalise:
        return 'blue';
      case StatusAnalise.dentroEspecificacao:
        return 'green';
      case StatusAnalise.foraEspecificacao:
        return 'orange';
      case StatusAnalise.corrigido:
        return 'teal';
      case StatusAnalise.autorizado:
        return 'green';
      case StatusAnalise.rejeitado:
        return 'red';
    }
  }
}

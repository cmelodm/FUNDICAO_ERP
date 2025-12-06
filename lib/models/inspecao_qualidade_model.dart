class InspecaoQualidadeModel {
  final String id;
  final String ordemProducaoId;
  final String ordemProducaoNumero;
  final String produto;
  final String tipoTeste; // dimensional, visual, ultrassom, dureza, etc
  final String resultado; // aprovado, reprovado, aprovado_com_ressalvas
  final List<NaoConformidade> naoConformidades;
  final String? inspetor;
  final DateTime dataInspecao;
  final String? observacoes;

  InspecaoQualidadeModel({
    required this.id,
    required this.ordemProducaoId,
    required this.ordemProducaoNumero,
    required this.produto,
    required this.tipoTeste,
    required this.resultado,
    required this.naoConformidades,
    this.inspetor,
    required this.dataInspecao,
    this.observacoes,
  });

  // Cor do resultado
  String get resultadoColor {
    switch (resultado) {
      case 'aprovado':
        return 'green';
      case 'reprovado':
        return 'red';
      case 'aprovado_com_ressalvas':
        return 'orange';
      default:
        return 'grey';
    }
  }

  // Label do resultado
  String get resultadoLabel {
    switch (resultado) {
      case 'aprovado':
        return 'Aprovado';
      case 'reprovado':
        return 'Reprovado';
      case 'aprovado_com_ressalvas':
        return 'Aprovado com Ressalvas';
      default:
        return 'Desconhecido';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ordemProducaoId': ordemProducaoId,
      'ordemProducaoNumero': ordemProducaoNumero,
      'produto': produto,
      'tipoTeste': tipoTeste,
      'resultado': resultado,
      'naoConformidades':
          naoConformidades.map((n) => n.toMap()).toList(),
      'inspetor': inspetor,
      'dataInspecao': dataInspecao.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  factory InspecaoQualidadeModel.fromMap(Map<String, dynamic> map) {
    return InspecaoQualidadeModel(
      id: map['id'] as String,
      ordemProducaoId: map['ordemProducaoId'] as String,
      ordemProducaoNumero: map['ordemProducaoNumero'] as String,
      produto: map['produto'] as String,
      tipoTeste: map['tipoTeste'] as String,
      resultado: map['resultado'] as String,
      naoConformidades: (map['naoConformidades'] as List)
          .map((n) => NaoConformidade.fromMap(n as Map<String, dynamic>))
          .toList(),
      inspetor: map['inspetor'] as String?,
      dataInspecao: DateTime.parse(map['dataInspecao'] as String),
      observacoes: map['observacoes'] as String?,
    );
  }
}

class NaoConformidade {
  final String descricao;
  final String gravidade; // baixa, media, alta, critica
  final String? acaoCorretiva;

  NaoConformidade({
    required this.descricao,
    required this.gravidade,
    this.acaoCorretiva,
  });

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'gravidade': gravidade,
      'acaoCorretiva': acaoCorretiva,
    };
  }

  factory NaoConformidade.fromMap(Map<String, dynamic> map) {
    return NaoConformidade(
      descricao: map['descricao'] as String,
      gravidade: map['gravidade'] as String,
      acaoCorretiva: map['acaoCorretiva'] as String?,
    );
  }
}

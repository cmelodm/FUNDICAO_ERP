class EquipamentoModel {
  final String id;
  final String nome;
  final String numero;
  final TipoEquipamento tipo;
  final double? capacidade; // toneladas para fornos, m/min para esteiras
  final String? unidadeCapacidade;
  final StatusEquipamento status;
  final DateTime dataInstalacao;
  final String? fabricante;
  final String? modelo;
  final String? numeroSerie;
  final DateTime? ultimaManutencao;
  final DateTime? proximaManutencao;
  final List<ManutencaoHistorico> historicoManutencao;
  final String? observacoes;

  EquipamentoModel({
    required this.id,
    required this.nome,
    required this.numero,
    required this.tipo,
    this.capacidade,
    this.unidadeCapacidade,
    required this.status,
    required this.dataInstalacao,
    this.fabricante,
    this.modelo,
    this.numeroSerie,
    this.ultimaManutencao,
    this.proximaManutencao,
    required this.historicoManutencao,
    this.observacoes,
  });

  String get identificacao => '$nome - Nº $numero';

  bool get precisaManutencao {
    if (proximaManutencao == null) return false;
    return DateTime.now().isAfter(proximaManutencao!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'numero': numero,
      'tipo': tipo.toString(),
      'capacidade': capacidade,
      'unidadeCapacidade': unidadeCapacidade,
      'status': status.toString(),
      'dataInstalacao': dataInstalacao.toIso8601String(),
      'fabricante': fabricante,
      'modelo': modelo,
      'numeroSerie': numeroSerie,
      'ultimaManutencao': ultimaManutencao?.toIso8601String(),
      'proximaManutencao': proximaManutencao?.toIso8601String(),
      'historicoManutencao':
          historicoManutencao.map((h) => h.toMap()).toList(),
      'observacoes': observacoes,
    };
  }

  factory EquipamentoModel.fromMap(Map<String, dynamic> map) {
    return EquipamentoModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      numero: map['numero'] as String,
      tipo: TipoEquipamento.values.firstWhere(
        (e) => e.toString() == map['tipo'],
      ),
      capacidade:
          map['capacidade'] != null ? (map['capacidade'] as num).toDouble() : null,
      unidadeCapacidade: map['unidadeCapacidade'] as String?,
      status: StatusEquipamento.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      dataInstalacao: DateTime.parse(map['dataInstalacao'] as String),
      fabricante: map['fabricante'] as String?,
      modelo: map['modelo'] as String?,
      numeroSerie: map['numeroSerie'] as String?,
      ultimaManutencao: map['ultimaManutencao'] != null
          ? DateTime.parse(map['ultimaManutencao'] as String)
          : null,
      proximaManutencao: map['proximaManutencao'] != null
          ? DateTime.parse(map['proximaManutencao'] as String)
          : null,
      historicoManutencao: (map['historicoManutencao'] as List)
          .map((h) => ManutencaoHistorico.fromMap(h as Map<String, dynamic>))
          .toList(),
      observacoes: map['observacoes'] as String?,
    );
  }
}

enum TipoEquipamento {
  fornoRotativo,
  fornoEspera,
  fornoBasculante,
  esteiralLingoteira,
  maquinaMoldagem,
  maquinaUsinagem,
  sistemaResfriamento,
  sistemaFiltragem,
  ponteRolante,
  outro,
}

extension TipoEquipamentoExtension on TipoEquipamento {
  String get label {
    switch (this) {
      case TipoEquipamento.fornoRotativo:
        return 'Forno Rotativo';
      case TipoEquipamento.fornoEspera:
        return 'Forno de Espera';
      case TipoEquipamento.fornoBasculante:
        return 'Forno Basculante';
      case TipoEquipamento.esteiralLingoteira:
        return 'Esteira Lingoteira';
      case TipoEquipamento.maquinaMoldagem:
        return 'Máquina de Moldagem';
      case TipoEquipamento.maquinaUsinagem:
        return 'Máquina de Usinagem';
      case TipoEquipamento.sistemaResfriamento:
        return 'Sistema de Resfriamento';
      case TipoEquipamento.sistemaFiltragem:
        return 'Sistema de Filtragem';
      case TipoEquipamento.ponteRolante:
        return 'Ponte Rolante';
      case TipoEquipamento.outro:
        return 'Outro';
    }
  }

  String get icone {
    switch (this) {
      case TipoEquipamento.fornoRotativo:
      case TipoEquipamento.fornoEspera:
      case TipoEquipamento.fornoBasculante:
        return '🔥';
      case TipoEquipamento.esteiralLingoteira:
        return '📦';
      case TipoEquipamento.maquinaMoldagem:
      case TipoEquipamento.maquinaUsinagem:
        return '⚙️';
      case TipoEquipamento.sistemaResfriamento:
        return '❄️';
      case TipoEquipamento.sistemaFiltragem:
        return '🌀';
      case TipoEquipamento.ponteRolante:
        return '🏗️';
      case TipoEquipamento.outro:
        return '🔧';
    }
  }
}

enum StatusEquipamento {
  operacional,
  emUso,
  emManutencao,
  aguardandoManutencao,
  inativo,
  quebrado,
}

extension StatusEquipamentoExtension on StatusEquipamento {
  String get label {
    switch (this) {
      case StatusEquipamento.operacional:
        return 'Operacional';
      case StatusEquipamento.emUso:
        return 'Em Uso';
      case StatusEquipamento.emManutencao:
        return 'Em Manutenção';
      case StatusEquipamento.aguardandoManutencao:
        return 'Aguardando Manutenção';
      case StatusEquipamento.inativo:
        return 'Inativo';
      case StatusEquipamento.quebrado:
        return 'Quebrado';
    }
  }

  String get cor {
    switch (this) {
      case StatusEquipamento.operacional:
        return 'green';
      case StatusEquipamento.emUso:
        return 'blue';
      case StatusEquipamento.emManutencao:
        return 'orange';
      case StatusEquipamento.aguardandoManutencao:
        return 'yellow';
      case StatusEquipamento.inativo:
        return 'grey';
      case StatusEquipamento.quebrado:
        return 'red';
    }
  }
}

class ManutencaoHistorico {
  final DateTime data;
  final String tipo; // preventiva, corretiva, emergencial
  final String descricao;
  final String? tecnico;
  final double? custo;

  ManutencaoHistorico({
    required this.data,
    required this.tipo,
    required this.descricao,
    this.tecnico,
    this.custo,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data.toIso8601String(),
      'tipo': tipo,
      'descricao': descricao,
      'tecnico': tecnico,
      'custo': custo,
    };
  }

  factory ManutencaoHistorico.fromMap(Map<String, dynamic> map) {
    return ManutencaoHistorico(
      data: DateTime.parse(map['data'] as String),
      tipo: map['tipo'] as String,
      descricao: map['descricao'] as String,
      tecnico: map['tecnico'] as String?,
      custo: map['custo'] != null ? (map['custo'] as num).toDouble() : null,
    );
  }
}

class FuncionarioModel {
  final String id;
  final String nome;
  final String cpf;
  final String? rg;
  final String cargo;
  final String? setor;
  final String? telefone;
  final String? email;
  final DateTime dataAdmissao;
  final bool ativo;
  final String? observacoes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FuncionarioModel({
    required this.id,
    required this.nome,
    required this.cpf,
    this.rg,
    required this.cargo,
    this.setor,
    this.telefone,
    this.email,
    required this.dataAdmissao,
    this.ativo = true,
    this.observacoes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cpf': cpf,
      'rg': rg,
      'cargo': cargo,
      'setor': setor,
      'telefone': telefone,
      'email': email,
      'dataAdmissao': dataAdmissao.toIso8601String(),
      'ativo': ativo,
      'observacoes': observacoes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FuncionarioModel.fromMap(Map<String, dynamic> map) {
    return FuncionarioModel(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      cpf: map['cpf'] ?? '',
      rg: map['rg'],
      cargo: map['cargo'] ?? '',
      setor: map['setor'],
      telefone: map['telefone'],
      email: map['email'],
      dataAdmissao: DateTime.parse(map['dataAdmissao']),
      ativo: map['ativo'] ?? true,
      observacoes: map['observacoes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  FuncionarioModel copyWith({
    String? id,
    String? nome,
    String? cpf,
    String? rg,
    String? cargo,
    String? setor,
    String? telefone,
    String? email,
    DateTime? dataAdmissao,
    bool? ativo,
    String? observacoes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuncionarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      rg: rg ?? this.rg,
      cargo: cargo ?? this.cargo,
      setor: setor ?? this.setor,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      dataAdmissao: dataAdmissao ?? this.dataAdmissao,
      ativo: ativo ?? this.ativo,
      observacoes: observacoes ?? this.observacoes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Lista de cargos padrão na fundição
class CargosFundicao {
  static const List<String> cargos = [
    'Operador de Forno',
    'Fundidor',
    'Moldador',
    'Macheiro',
    'Operador de Desmoldagem',
    'Rebarbador',
    'Soldador',
    'Inspetor de Qualidade',
    'Analista de Laboratório',
    'Operador de Espectrômetro',
    'Supervisor de Produção',
    'Encarregado',
    'Técnico de Manutenção',
    'Almoxarife',
    'Auxiliar de Produção',
    'Gerente de Produção',
  ];

  static const List<String> setores = [
    'Fusão',
    'Moldagem',
    'Desmoldagem',
    'Acabamento',
    'Qualidade',
    'Laboratório',
    'Manutenção',
    'Almoxarifado',
    'Expedição',
    'Administrativo',
  ];
}

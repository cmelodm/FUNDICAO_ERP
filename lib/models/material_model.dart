class MaterialModel {
  final String id;
  final String nome;
  final String codigo;
  final String tipo; // Ferro, Aço, Alumínio, etc
  final double quantidadeEstoque;
  final double estoqueMinimo;
  final double custoUnitario;
  final String? ncm;
  final double? icms;
  final double? ipi;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MaterialModel({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.tipo,
    required this.quantidadeEstoque,
    required this.estoqueMinimo,
    required this.custoUnitario,
    this.ncm,
    this.icms,
    this.ipi,
    required this.createdAt,
    this.updatedAt,
  });

  // Status do estoque
  String get statusEstoque {
    if (quantidadeEstoque == 0) return 'esgotado';
    if (quantidadeEstoque <= estoqueMinimo) return 'baixo';
    return 'normal';
  }

  // Cor do badge de status
  String get statusColor {
    switch (statusEstoque) {
      case 'esgotado':
        return 'red';
      case 'baixo':
        return 'orange';
      default:
        return 'green';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'codigo': codigo,
      'tipo': tipo,
      'quantidadeEstoque': quantidadeEstoque,
      'estoqueMinimo': estoqueMinimo,
      'custoUnitario': custoUnitario,
      'ncm': ncm,
      'icms': icms,
      'ipi': ipi,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      codigo: map['codigo'] as String,
      tipo: map['tipo'] as String,
      quantidadeEstoque: (map['quantidadeEstoque'] as num).toDouble(),
      estoqueMinimo: (map['estoqueMinimo'] as num).toDouble(),
      custoUnitario: (map['custoUnitario'] as num).toDouble(),
      ncm: map['ncm'] as String?,
      icms: map['icms'] != null ? (map['icms'] as num).toDouble() : null,
      ipi: map['ipi'] != null ? (map['ipi'] as num).toDouble() : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  MaterialModel copyWith({
    String? id,
    String? nome,
    String? codigo,
    String? tipo,
    double? quantidadeEstoque,
    double? estoqueMinimo,
    double? custoUnitario,
    String? ncm,
    double? icms,
    double? ipi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      codigo: codigo ?? this.codigo,
      tipo: tipo ?? this.tipo,
      quantidadeEstoque: quantidadeEstoque ?? this.quantidadeEstoque,
      estoqueMinimo: estoqueMinimo ?? this.estoqueMinimo,
      custoUnitario: custoUnitario ?? this.custoUnitario,
      ncm: ncm ?? this.ncm,
      icms: icms ?? this.icms,
      ipi: ipi ?? this.ipi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

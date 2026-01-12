/// Modelo para Material de Correção (sucatas, aditivos, etc)
class MaterialCorrecao {
  final String id;
  final String nome;
  final String codigo;
  final TipoMaterialCorrecao tipo;
  
  // Composição química do material (%)
  final Map<String, double> composicao; // 'Si': 10.0, 'Cu': 3.0, etc
  
  // Rendimentos elementares específicos (%)
  final Map<String, double> rendimentos; // 'Si': 95.0, 'Mg': 60.0, etc
  
  // Dados de custo e estoque
  final double custoKg; // R$/kg
  final double estoqueDisponivel; // kg
  final String? fornecedor;
  final String? observacoes;

  MaterialCorrecao({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.tipo,
    required this.composicao,
    required this.rendimentos,
    required this.custoKg,
    this.estoqueDisponivel = 0,
    this.fornecedor,
    this.observacoes,
  });

  // Obter concentração de um elemento específico
  double getConcentracao(String simbolo) {
    return composicao[simbolo] ?? 0.0;
  }

  // Obter rendimento de um elemento específico
  double getRendimento(String simbolo) {
    return rendimentos[simbolo] ?? 95.0; // Default 95%
  }

  // Serialização
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'codigo': codigo,
      'tipo': tipo.toString(),
      'composicao': composicao,
      'rendimentos': rendimentos,
      'custoKg': custoKg,
      'estoqueDisponivel': estoqueDisponivel,
      'fornecedor': fornecedor,
      'observacoes': observacoes,
    };
  }

  factory MaterialCorrecao.fromMap(Map<String, dynamic> map) {
    return MaterialCorrecao(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      codigo: map['codigo'] ?? '',
      tipo: TipoMaterialCorrecao.values.firstWhere(
        (e) => e.toString() == map['tipo'],
        orElse: () => TipoMaterialCorrecao.sucata,
      ),
      composicao: Map<String, double>.from(map['composicao'] ?? {}),
      rendimentos: Map<String, double>.from(map['rendimentos'] ?? {}),
      custoKg: (map['custoKg'] ?? 0).toDouble(),
      estoqueDisponivel: (map['estoqueDisponivel'] ?? 0).toDouble(),
      fornecedor: map['fornecedor'],
      observacoes: map['observacoes'],
    );
  }
}

/// Tipos de materiais de correção
enum TipoMaterialCorrecao {
  sucata, // Cavacos, blocos, chapas
  primario, // Alumínio primário
  aditivo, // Ferro-Silício, Magnésio puro
  ligaMae, // Liga-mãe (master alloy)
}

extension TipoMaterialCorrecaoExtension on TipoMaterialCorrecao {
  String get nome {
    switch (this) {
      case TipoMaterialCorrecao.sucata:
        return 'Sucata';
      case TipoMaterialCorrecao.primario:
        return 'Alumínio Primário';
      case TipoMaterialCorrecao.aditivo:
        return 'Aditivo Puro';
      case TipoMaterialCorrecao.ligaMae:
        return 'Liga-Mãe';
    }
  }

  String get descricao {
    switch (this) {
      case TipoMaterialCorrecao.sucata:
        return 'Cavacos, blocos, chapas de alumínio';
      case TipoMaterialCorrecao.primario:
        return 'Alumínio primário 99.7%';
      case TipoMaterialCorrecao.aditivo:
        return 'Aditivos puros (FeSi, Mg, etc)';
      case TipoMaterialCorrecao.ligaMae:
        return 'Ligas-mãe com alta concentração';
    }
  }
}

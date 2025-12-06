class LigaMetalurgicaModel {
  final String id;
  final String nome;
  final String codigo; // Ex: SAE 306, DIN AlSi9Cu3
  final String norma; // SAE, ASTM, DIN, AA, CUSTOM
  final String tipo; // Alumínio, Bronze, Latão, etc
  final double pesoTotal; // kg
  final List<ElementoLiga> elementos;
  final String? descricao;
  final String? aplicacao;
  final DateTime dataCriacao;
  final String? ordemProducaoId;
  final bool isCustom; // Liga customizada ou template padrão
  final String? criadoPor;
  final DateTime? updatedAt;

  LigaMetalurgicaModel({
    required this.id,
    required this.nome,
    required this.codigo,
    required this.norma,
    required this.tipo,
    required this.pesoTotal,
    required this.elementos,
    this.descricao,
    this.aplicacao,
    required this.dataCriacao,
    this.ordemProducaoId,
    this.isCustom = false,
    this.criadoPor,
    this.updatedAt,
  });

  // Quantidade total necessária (com perdas)
  double get totalQuantidadeNecessaria {
    return elementos.fold(
        0.0, (sum, elemento) => sum + elemento.quantidadeNecessaria);
  }

  // Custo total estimado
  double calcularCustoTotal(Map<String, double> custosPorElemento) {
    return elementos.fold(0.0, (sum, elemento) {
      final custo = custosPorElemento[elemento.simbolo] ?? 0.0;
      return sum + (elemento.quantidadeNecessaria * custo);
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'codigo': codigo,
      'norma': norma,
      'tipo': tipo,
      'pesoTotal': pesoTotal,
      'elementos': elementos.map((e) => e.toMap()).toList(),
      'descricao': descricao,
      'aplicacao': aplicacao,
      'dataCriacao': dataCriacao.toIso8601String(),
      'ordemProducaoId': ordemProducaoId,
      'isCustom': isCustom,
      'criadoPor': criadoPor,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory LigaMetalurgicaModel.fromMap(Map<String, dynamic> map) {
    return LigaMetalurgicaModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      codigo: map['codigo'] as String,
      norma: map['norma'] as String,
      tipo: map['tipo'] as String,
      pesoTotal: (map['pesoTotal'] as num).toDouble(),
      elementos: (map['elementos'] as List)
          .map((e) => ElementoLiga.fromMap(e as Map<String, dynamic>))
          .toList(),
      descricao: map['descricao'] as String?,
      aplicacao: map['aplicacao'] as String?,
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
      ordemProducaoId: map['ordemProducaoId'] as String?,
      isCustom: map['isCustom'] ?? false,
      criadoPor: map['criadoPor'] as String?,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }

  LigaMetalurgicaModel copyWith({
    String? id,
    String? nome,
    String? codigo,
    String? norma,
    String? tipo,
    double? pesoTotal,
    List<ElementoLiga>? elementos,
    String? descricao,
    String? aplicacao,
    DateTime? dataCriacao,
    String? ordemProducaoId,
    bool? isCustom,
    String? criadoPor,
    DateTime? updatedAt,
  }) {
    return LigaMetalurgicaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      codigo: codigo ?? this.codigo,
      norma: norma ?? this.norma,
      tipo: tipo ?? this.tipo,
      pesoTotal: pesoTotal ?? this.pesoTotal,
      elementos: elementos ?? this.elementos,
      descricao: descricao ?? this.descricao,
      aplicacao: aplicacao ?? this.aplicacao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      ordemProducaoId: ordemProducaoId ?? this.ordemProducaoId,
      isCustom: isCustom ?? this.isCustom,
      criadoPor: criadoPor ?? this.criadoPor,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ElementoLiga {
  final String simbolo; // Si, Cu, Fe, etc
  final String nome; // Silício, Cobre, Ferro, etc
  final double percentualMinimo;
  final double percentualMaximo;
  final double percentualNominal; // Valor central ou usado para cálculo
  final double rendimentoForno; // % (90-98%)

  ElementoLiga({
    required this.simbolo,
    required this.nome,
    required this.percentualMinimo,
    required this.percentualMaximo,
    required this.percentualNominal,
    required this.rendimentoForno,
  });

  // Cálculo da quantidade na liga (kg)
  double calcularQuantidadeLiga(double pesoTotal) {
    return pesoTotal * (percentualNominal / 100);
  }

  // Cálculo da quantidade necessária com compensação de perdas (kg)
  double calcularQuantidadeNecessaria(double pesoTotal) {
    final qtdLiga = calcularQuantidadeLiga(pesoTotal);
    return qtdLiga / (rendimentoForno / 100);
  }

  // Getters com peso total
  double quantidadeLiga(double pesoTotal) => calcularQuantidadeLiga(pesoTotal);
  double get quantidadeNecessaria => 0.0; // Será calculado dinamicamente

  Map<String, dynamic> toMap() {
    return {
      'simbolo': simbolo,
      'nome': nome,
      'percentualMinimo': percentualMinimo,
      'percentualMaximo': percentualMaximo,
      'percentualNominal': percentualNominal,
      'rendimentoForno': rendimentoForno,
    };
  }

  factory ElementoLiga.fromMap(Map<String, dynamic> map) {
    return ElementoLiga(
      simbolo: map['simbolo'] as String,
      nome: map['nome'] as String,
      percentualMinimo: (map['percentualMinimo'] as num).toDouble(),
      percentualMaximo: (map['percentualMaximo'] as num).toDouble(),
      percentualNominal: (map['percentualNominal'] as num).toDouble(),
      rendimentoForno: (map['rendimentoForno'] as num).toDouble(),
    );
  }

  ElementoLiga copyWith({
    String? simbolo,
    String? nome,
    double? percentualMinimo,
    double? percentualMaximo,
    double? percentualNominal,
    double? rendimentoForno,
  }) {
    return ElementoLiga(
      simbolo: simbolo ?? this.simbolo,
      nome: nome ?? this.nome,
      percentualMinimo: percentualMinimo ?? this.percentualMinimo,
      percentualMaximo: percentualMaximo ?? this.percentualMaximo,
      percentualNominal: percentualNominal ?? this.percentualNominal,
      rendimentoForno: rendimentoForno ?? this.rendimentoForno,
    );
  }
}

// Liga Template (padrões de normas)
class LigaTemplate {
  final String codigo;
  final String nome;
  final String norma;
  final String tipo;
  final List<ElementoLiga> elementos;
  final String? descricao;
  final String? aplicacao;

  LigaTemplate({
    required this.codigo,
    required this.nome,
    required this.norma,
    required this.tipo,
    required this.elementos,
    this.descricao,
    this.aplicacao,
  });

  // Converter template para liga com peso específico
  LigaMetalurgicaModel toLiga(double pesoTotal, {String? ordemProducaoId}) {
    return LigaMetalurgicaModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      codigo: codigo,
      norma: norma,
      tipo: tipo,
      pesoTotal: pesoTotal,
      elementos: elementos,
      descricao: descricao,
      aplicacao: aplicacao,
      dataCriacao: DateTime.now(),
      ordemProducaoId: ordemProducaoId,
    );
  }
}

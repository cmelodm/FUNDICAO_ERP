class FornecedorModel {
  final String id;
  final String nome;
  final String cnpj;
  final String? email;
  final String? telefone;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final double avaliacaoQualidade;
  final double avaliacaoPreco;
  final double avaliacaoPrazo;
  final double avaliacaoAtendimento;
  final List<AvaliacaoFornecedor> historico;
  final DateTime createdAt;

  FornecedorModel({
    required this.id,
    required this.nome,
    required this.cnpj,
    this.email,
    this.telefone,
    this.endereco,
    this.cidade,
    this.estado,
    required this.avaliacaoQualidade,
    required this.avaliacaoPreco,
    required this.avaliacaoPrazo,
    required this.avaliacaoAtendimento,
    required this.historico,
    required this.createdAt,
  });

  // Avaliação média geral
  double get avaliacaoGeral {
    return (avaliacaoQualidade +
            avaliacaoPreco +
            avaliacaoPrazo +
            avaliacaoAtendimento) /
        4;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'avaliacaoQualidade': avaliacaoQualidade,
      'avaliacaoPreco': avaliacaoPreco,
      'avaliacaoPrazo': avaliacaoPrazo,
      'avaliacaoAtendimento': avaliacaoAtendimento,
      'historico': historico.map((h) => h.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FornecedorModel.fromMap(Map<String, dynamic> map) {
    return FornecedorModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      cnpj: map['cnpj'] as String,
      email: map['email'] as String?,
      telefone: map['telefone'] as String?,
      endereco: map['endereco'] as String?,
      cidade: map['cidade'] as String?,
      estado: map['estado'] as String?,
      avaliacaoQualidade: (map['avaliacaoQualidade'] as num).toDouble(),
      avaliacaoPreco: (map['avaliacaoPreco'] as num).toDouble(),
      avaliacaoPrazo: (map['avaliacaoPrazo'] as num).toDouble(),
      avaliacaoAtendimento: (map['avaliacaoAtendimento'] as num).toDouble(),
      historico: (map['historico'] as List)
          .map((h) => AvaliacaoFornecedor.fromMap(h as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class AvaliacaoFornecedor {
  final DateTime data;
  final double qualidade;
  final double preco;
  final double prazo;
  final double atendimento;
  final String? observacao;

  AvaliacaoFornecedor({
    required this.data,
    required this.qualidade,
    required this.preco,
    required this.prazo,
    required this.atendimento,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data.toIso8601String(),
      'qualidade': qualidade,
      'preco': preco,
      'prazo': prazo,
      'atendimento': atendimento,
      'observacao': observacao,
    };
  }

  factory AvaliacaoFornecedor.fromMap(Map<String, dynamic> map) {
    return AvaliacaoFornecedor(
      data: DateTime.parse(map['data'] as String),
      qualidade: (map['qualidade'] as num).toDouble(),
      preco: (map['preco'] as num).toDouble(),
      prazo: (map['prazo'] as num).toDouble(),
      atendimento: (map['atendimento'] as num).toDouble(),
      observacao: map['observacao'] as String?,
    );
  }
}

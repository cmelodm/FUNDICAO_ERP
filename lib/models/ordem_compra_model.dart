enum StatusOrdemCompra {
  rascunho,
  enviada,
  confirmada,
  parcialmenteRecebida,
  recebida,
  cancelada,
}

class OrdemCompraModel {
  final String id;
  final String numero;
  final String fornecedorId;
  final String fornecedorNome;
  final List<ItemOrdemCompra> items;
  final StatusOrdemCompra status;
  final DateTime dataEmissao;
  final DateTime? dataPrevisaoEntrega;
  final DateTime? dataRecebimento;
  final double subtotal;
  final double valorFrete;
  final double valorDesconto;
  final double valorTotal;
  final String? observacoes;
  final String? condicaoPagamento;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrdemCompraModel({
    required this.id,
    required this.numero,
    required this.fornecedorId,
    required this.fornecedorNome,
    required this.items,
    required this.status,
    required this.dataEmissao,
    this.dataPrevisaoEntrega,
    this.dataRecebimento,
    required this.subtotal,
    this.valorFrete = 0.0,
    this.valorDesconto = 0.0,
    required this.valorTotal,
    this.observacoes,
    this.condicaoPagamento,
    required this.createdAt,
    this.updatedAt,
  });

  // Getters auxiliares
  String get statusTexto {
    switch (status) {
      case StatusOrdemCompra.rascunho:
        return 'Rascunho';
      case StatusOrdemCompra.enviada:
        return 'Enviada';
      case StatusOrdemCompra.confirmada:
        return 'Confirmada';
      case StatusOrdemCompra.parcialmenteRecebida:
        return 'Parcialmente Recebida';
      case StatusOrdemCompra.recebida:
        return 'Recebida';
      case StatusOrdemCompra.cancelada:
        return 'Cancelada';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'fornecedorId': fornecedorId,
      'fornecedorNome': fornecedorNome,
      'items': items.map((i) => i.toMap()).toList(),
      'status': status.index,
      'dataEmissao': dataEmissao.toIso8601String(),
      'dataPrevisaoEntrega': dataPrevisaoEntrega?.toIso8601String(),
      'dataRecebimento': dataRecebimento?.toIso8601String(),
      'subtotal': subtotal,
      'valorFrete': valorFrete,
      'valorDesconto': valorDesconto,
      'valorTotal': valorTotal,
      'observacoes': observacoes,
      'condicaoPagamento': condicaoPagamento,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrdemCompraModel.fromMap(Map<String, dynamic> map) {
    return OrdemCompraModel(
      id: map['id'] as String,
      numero: map['numero'] as String,
      fornecedorId: map['fornecedorId'] as String,
      fornecedorNome: map['fornecedorNome'] as String,
      items: (map['items'] as List)
          .map((i) => ItemOrdemCompra.fromMap(i as Map<String, dynamic>))
          .toList(),
      status: StatusOrdemCompra.values[map['status'] as int],
      dataEmissao: DateTime.parse(map['dataEmissao'] as String),
      dataPrevisaoEntrega: map['dataPrevisaoEntrega'] != null
          ? DateTime.parse(map['dataPrevisaoEntrega'] as String)
          : null,
      dataRecebimento: map['dataRecebimento'] != null
          ? DateTime.parse(map['dataRecebimento'] as String)
          : null,
      subtotal: (map['subtotal'] as num).toDouble(),
      valorFrete: (map['valorFrete'] as num?)?.toDouble() ?? 0.0,
      valorDesconto: (map['valorDesconto'] as num?)?.toDouble() ?? 0.0,
      valorTotal: (map['valorTotal'] as num).toDouble(),
      observacoes: map['observacoes'] as String?,
      condicaoPagamento: map['condicaoPagamento'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  // Criar cópia com alterações
  OrdemCompraModel copyWith({
    String? id,
    String? numero,
    String? fornecedorId,
    String? fornecedorNome,
    List<ItemOrdemCompra>? items,
    StatusOrdemCompra? status,
    DateTime? dataEmissao,
    DateTime? dataPrevisaoEntrega,
    DateTime? dataRecebimento,
    double? subtotal,
    double? valorFrete,
    double? valorDesconto,
    double? valorTotal,
    String? observacoes,
    String? condicaoPagamento,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrdemCompraModel(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      fornecedorId: fornecedorId ?? this.fornecedorId,
      fornecedorNome: fornecedorNome ?? this.fornecedorNome,
      items: items ?? this.items,
      status: status ?? this.status,
      dataEmissao: dataEmissao ?? this.dataEmissao,
      dataPrevisaoEntrega: dataPrevisaoEntrega ?? this.dataPrevisaoEntrega,
      dataRecebimento: dataRecebimento ?? this.dataRecebimento,
      subtotal: subtotal ?? this.subtotal,
      valorFrete: valorFrete ?? this.valorFrete,
      valorDesconto: valorDesconto ?? this.valorDesconto,
      valorTotal: valorTotal ?? this.valorTotal,
      observacoes: observacoes ?? this.observacoes,
      condicaoPagamento: condicaoPagamento ?? this.condicaoPagamento,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ItemOrdemCompra {
  final String materialId;
  final String materialNome;
  final String unidade;
  final double quantidade;
  final double quantidadeRecebida;
  final double precoUnitario;
  final double valorTotal;
  final String? observacao;

  ItemOrdemCompra({
    required this.materialId,
    required this.materialNome,
    required this.unidade,
    required this.quantidade,
    this.quantidadeRecebida = 0.0,
    required this.precoUnitario,
    required this.valorTotal,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialNome': materialNome,
      'unidade': unidade,
      'quantidade': quantidade,
      'quantidadeRecebida': quantidadeRecebida,
      'precoUnitario': precoUnitario,
      'valorTotal': valorTotal,
      'observacao': observacao,
    };
  }

  factory ItemOrdemCompra.fromMap(Map<String, dynamic> map) {
    return ItemOrdemCompra(
      materialId: map['materialId'] as String,
      materialNome: map['materialNome'] as String,
      unidade: map['unidade'] as String,
      quantidade: (map['quantidade'] as num).toDouble(),
      quantidadeRecebida: (map['quantidadeRecebida'] as num?)?.toDouble() ?? 0.0,
      precoUnitario: (map['precoUnitario'] as num).toDouble(),
      valorTotal: (map['valorTotal'] as num).toDouble(),
      observacao: map['observacao'] as String?,
    );
  }

  // Criar cópia com alterações
  ItemOrdemCompra copyWith({
    String? materialId,
    String? materialNome,
    String? unidade,
    double? quantidade,
    double? quantidadeRecebida,
    double? precoUnitario,
    double? valorTotal,
    String? observacao,
  }) {
    return ItemOrdemCompra(
      materialId: materialId ?? this.materialId,
      materialNome: materialNome ?? this.materialNome,
      unidade: unidade ?? this.unidade,
      quantidade: quantidade ?? this.quantidade,
      quantidadeRecebida: quantidadeRecebida ?? this.quantidadeRecebida,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      valorTotal: valorTotal ?? this.valorTotal,
      observacao: observacao ?? this.observacao,
    );
  }
}

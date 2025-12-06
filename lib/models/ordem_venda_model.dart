enum StatusOrdemVenda {
  orcamento,
  aprovada,
  emProducao,
  aguardandoFaturamento,
  faturada,
  entregue,
  cancelada,
}

class OrdemVendaModel {
  final String id;
  final String numero;
  final String clienteNome;
  final String? clienteCnpj;
  final String? clienteEmail;
  final String? clienteTelefone;
  final String? clienteEndereco;
  final List<ItemOrdemVenda> items;
  final StatusOrdemVenda status;
  final DateTime dataEmissao;
  final DateTime? dataPrevisaoEntrega;
  final DateTime? dataFaturamento;
  final DateTime? dataEntrega;
  final double subtotal;
  final double valorFrete;
  final double valorDesconto;
  final double valorTotal;
  final String? observacoes;
  final String? condicaoPagamento;
  final String? ordemProducaoId; // Vinculação com OP
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrdemVendaModel({
    required this.id,
    required this.numero,
    required this.clienteNome,
    this.clienteCnpj,
    this.clienteEmail,
    this.clienteTelefone,
    this.clienteEndereco,
    required this.items,
    required this.status,
    required this.dataEmissao,
    this.dataPrevisaoEntrega,
    this.dataFaturamento,
    this.dataEntrega,
    required this.subtotal,
    this.valorFrete = 0.0,
    this.valorDesconto = 0.0,
    required this.valorTotal,
    this.observacoes,
    this.condicaoPagamento,
    this.ordemProducaoId,
    required this.createdAt,
    this.updatedAt,
  });

  // Getters auxiliares
  String get statusTexto {
    switch (status) {
      case StatusOrdemVenda.orcamento:
        return 'Orçamento';
      case StatusOrdemVenda.aprovada:
        return 'Aprovada';
      case StatusOrdemVenda.emProducao:
        return 'Em Produção';
      case StatusOrdemVenda.aguardandoFaturamento:
        return 'Aguardando Faturamento';
      case StatusOrdemVenda.faturada:
        return 'Faturada';
      case StatusOrdemVenda.entregue:
        return 'Entregue';
      case StatusOrdemVenda.cancelada:
        return 'Cancelada';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'clienteNome': clienteNome,
      'clienteCnpj': clienteCnpj,
      'clienteEmail': clienteEmail,
      'clienteTelefone': clienteTelefone,
      'clienteEndereco': clienteEndereco,
      'items': items.map((i) => i.toMap()).toList(),
      'status': status.index,
      'dataEmissao': dataEmissao.toIso8601String(),
      'dataPrevisaoEntrega': dataPrevisaoEntrega?.toIso8601String(),
      'dataFaturamento': dataFaturamento?.toIso8601String(),
      'dataEntrega': dataEntrega?.toIso8601String(),
      'subtotal': subtotal,
      'valorFrete': valorFrete,
      'valorDesconto': valorDesconto,
      'valorTotal': valorTotal,
      'observacoes': observacoes,
      'condicaoPagamento': condicaoPagamento,
      'ordemProducaoId': ordemProducaoId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrdemVendaModel.fromMap(Map<String, dynamic> map) {
    return OrdemVendaModel(
      id: map['id'] as String,
      numero: map['numero'] as String,
      clienteNome: map['clienteNome'] as String,
      clienteCnpj: map['clienteCnpj'] as String?,
      clienteEmail: map['clienteEmail'] as String?,
      clienteTelefone: map['clienteTelefone'] as String?,
      clienteEndereco: map['clienteEndereco'] as String?,
      items: (map['items'] as List)
          .map((i) => ItemOrdemVenda.fromMap(i as Map<String, dynamic>))
          .toList(),
      status: StatusOrdemVenda.values[map['status'] as int],
      dataEmissao: DateTime.parse(map['dataEmissao'] as String),
      dataPrevisaoEntrega: map['dataPrevisaoEntrega'] != null
          ? DateTime.parse(map['dataPrevisaoEntrega'] as String)
          : null,
      dataFaturamento: map['dataFaturamento'] != null
          ? DateTime.parse(map['dataFaturamento'] as String)
          : null,
      dataEntrega: map['dataEntrega'] != null
          ? DateTime.parse(map['dataEntrega'] as String)
          : null,
      subtotal: (map['subtotal'] as num).toDouble(),
      valorFrete: (map['valorFrete'] as num?)?.toDouble() ?? 0.0,
      valorDesconto: (map['valorDesconto'] as num?)?.toDouble() ?? 0.0,
      valorTotal: (map['valorTotal'] as num).toDouble(),
      observacoes: map['observacoes'] as String?,
      condicaoPagamento: map['condicaoPagamento'] as String?,
      ordemProducaoId: map['ordemProducaoId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  // Criar cópia com alterações
  OrdemVendaModel copyWith({
    String? id,
    String? numero,
    String? clienteNome,
    String? clienteCnpj,
    String? clienteEmail,
    String? clienteTelefone,
    String? clienteEndereco,
    List<ItemOrdemVenda>? items,
    StatusOrdemVenda? status,
    DateTime? dataEmissao,
    DateTime? dataPrevisaoEntrega,
    DateTime? dataFaturamento,
    DateTime? dataEntrega,
    double? subtotal,
    double? valorFrete,
    double? valorDesconto,
    double? valorTotal,
    String? observacoes,
    String? condicaoPagamento,
    String? ordemProducaoId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrdemVendaModel(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteCnpj: clienteCnpj ?? this.clienteCnpj,
      clienteEmail: clienteEmail ?? this.clienteEmail,
      clienteTelefone: clienteTelefone ?? this.clienteTelefone,
      clienteEndereco: clienteEndereco ?? this.clienteEndereco,
      items: items ?? this.items,
      status: status ?? this.status,
      dataEmissao: dataEmissao ?? this.dataEmissao,
      dataPrevisaoEntrega: dataPrevisaoEntrega ?? this.dataPrevisaoEntrega,
      dataFaturamento: dataFaturamento ?? this.dataFaturamento,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      subtotal: subtotal ?? this.subtotal,
      valorFrete: valorFrete ?? this.valorFrete,
      valorDesconto: valorDesconto ?? this.valorDesconto,
      valorTotal: valorTotal ?? this.valorTotal,
      observacoes: observacoes ?? this.observacoes,
      condicaoPagamento: condicaoPagamento ?? this.condicaoPagamento,
      ordemProducaoId: ordemProducaoId ?? this.ordemProducaoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ItemOrdemVenda {
  final String produtoId;
  final String produtoNome;
  final String unidade;
  final double quantidade;
  final double precoUnitario;
  final double valorTotal;
  final String? observacao;

  ItemOrdemVenda({
    required this.produtoId,
    required this.produtoNome,
    required this.unidade,
    required this.quantidade,
    required this.precoUnitario,
    required this.valorTotal,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'produtoNome': produtoNome,
      'unidade': unidade,
      'quantidade': quantidade,
      'precoUnitario': precoUnitario,
      'valorTotal': valorTotal,
      'observacao': observacao,
    };
  }

  factory ItemOrdemVenda.fromMap(Map<String, dynamic> map) {
    return ItemOrdemVenda(
      produtoId: map['produtoId'] as String,
      produtoNome: map['produtoNome'] as String,
      unidade: map['unidade'] as String,
      quantidade: (map['quantidade'] as num).toDouble(),
      precoUnitario: (map['precoUnitario'] as num).toDouble(),
      valorTotal: (map['valorTotal'] as num).toDouble(),
      observacao: map['observacao'] as String?,
    );
  }

  // Criar cópia com alterações
  ItemOrdemVenda copyWith({
    String? produtoId,
    String? produtoNome,
    String? unidade,
    double? quantidade,
    double? precoUnitario,
    double? valorTotal,
    String? observacao,
  }) {
    return ItemOrdemVenda(
      produtoId: produtoId ?? this.produtoId,
      produtoNome: produtoNome ?? this.produtoNome,
      unidade: unidade ?? this.unidade,
      quantidade: quantidade ?? this.quantidade,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      valorTotal: valorTotal ?? this.valorTotal,
      observacao: observacao ?? this.observacao,
    );
  }
}

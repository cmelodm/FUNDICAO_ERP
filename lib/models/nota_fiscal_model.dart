class NotaFiscalModel {
  final String id;
  final String numero;
  final String serie;
  final TipoNotaFiscal tipo; // ENTRADA ou SAIDA
  final DateTime dataEmissao;
  final DateTime dataEntrada;
  final String chaveAcesso;
  final String fornecedorId;
  final String fornecedorNome;
  final String fornecedorCnpj;
  final List<ItemNotaFiscal> itens;
  final double valorTotal;
  final double valorProdutos;
  final ImpostosNota impostos;
  final String? observacoes;
  final StatusNota status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? xmlPath; // Caminho do arquivo XML

  NotaFiscalModel({
    required this.id,
    required this.numero,
    required this.serie,
    required this.tipo,
    required this.dataEmissao,
    required this.dataEntrada,
    required this.chaveAcesso,
    required this.fornecedorId,
    required this.fornecedorNome,
    required this.fornecedorCnpj,
    required this.itens,
    required this.valorTotal,
    required this.valorProdutos,
    required this.impostos,
    this.observacoes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.xmlPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'serie': serie,
      'tipo': tipo.toString(),
      'dataEmissao': dataEmissao.toIso8601String(),
      'dataEntrada': dataEntrada.toIso8601String(),
      'chaveAcesso': chaveAcesso,
      'fornecedorId': fornecedorId,
      'fornecedorNome': fornecedorNome,
      'fornecedorCnpj': fornecedorCnpj,
      'itens': itens.map((i) => i.toMap()).toList(),
      'valorTotal': valorTotal,
      'valorProdutos': valorProdutos,
      'impostos': impostos.toMap(),
      'observacoes': observacoes,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'xmlPath': xmlPath,
    };
  }

  factory NotaFiscalModel.fromMap(Map<String, dynamic> map) {
    return NotaFiscalModel(
      id: map['id'] ?? '',
      numero: map['numero'] ?? '',
      serie: map['serie'] ?? '',
      tipo: TipoNotaFiscal.values.firstWhere(
        (e) => e.toString() == map['tipo'],
        orElse: () => TipoNotaFiscal.entrada,
      ),
      dataEmissao: DateTime.parse(map['dataEmissao']),
      dataEntrada: DateTime.parse(map['dataEntrada']),
      chaveAcesso: map['chaveAcesso'] ?? '',
      fornecedorId: map['fornecedorId'] ?? '',
      fornecedorNome: map['fornecedorNome'] ?? '',
      fornecedorCnpj: map['fornecedorCnpj'] ?? '',
      itens: (map['itens'] as List)
          .map((i) => ItemNotaFiscal.fromMap(i))
          .toList(),
      valorTotal: (map['valorTotal'] as num).toDouble(),
      valorProdutos: (map['valorProdutos'] as num).toDouble(),
      impostos: ImpostosNota.fromMap(map['impostos']),
      observacoes: map['observacoes'],
      status: StatusNota.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => StatusNota.pendente,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      xmlPath: map['xmlPath'],
    );
  }
}

class ItemNotaFiscal {
  final String codigo;
  final String descricao;
  final String ncm;
  final String cfop;
  final String unidade;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;
  final ImpostosItem impostos;
  final String? materialId; // ID do material no sistema

  ItemNotaFiscal({
    required this.codigo,
    required this.descricao,
    required this.ncm,
    required this.cfop,
    required this.unidade,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
    required this.impostos,
    this.materialId,
  });

  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'descricao': descricao,
      'ncm': ncm,
      'cfop': cfop,
      'unidade': unidade,
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
      'valorTotal': valorTotal,
      'impostos': impostos.toMap(),
      'materialId': materialId,
    };
  }

  factory ItemNotaFiscal.fromMap(Map<String, dynamic> map) {
    return ItemNotaFiscal(
      codigo: map['codigo'] ?? '',
      descricao: map['descricao'] ?? '',
      ncm: map['ncm'] ?? '',
      cfop: map['cfop'] ?? '',
      unidade: map['unidade'] ?? '',
      quantidade: (map['quantidade'] as num).toDouble(),
      valorUnitario: (map['valorUnitario'] as num).toDouble(),
      valorTotal: (map['valorTotal'] as num).toDouble(),
      impostos: ImpostosItem.fromMap(map['impostos']),
      materialId: map['materialId'],
    );
  }
}

class ImpostosNota {
  final double icms;
  final double ipi;
  final double pis;
  final double cofins;

  ImpostosNota({
    required this.icms,
    required this.ipi,
    required this.pis,
    required this.cofins,
  });

  double get totalImpostos => icms + ipi + pis + cofins;

  Map<String, dynamic> toMap() {
    return {
      'icms': icms,
      'ipi': ipi,
      'pis': pis,
      'cofins': cofins,
    };
  }

  factory ImpostosNota.fromMap(Map<String, dynamic> map) {
    return ImpostosNota(
      icms: (map['icms'] as num?)?.toDouble() ?? 0.0,
      ipi: (map['ipi'] as num?)?.toDouble() ?? 0.0,
      pis: (map['pis'] as num?)?.toDouble() ?? 0.0,
      cofins: (map['cofins'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ImpostosItem {
  final double icms;
  final double ipi;
  final double pis;
  final double cofins;

  ImpostosItem({
    required this.icms,
    required this.ipi,
    required this.pis,
    required this.cofins,
  });

  Map<String, dynamic> toMap() {
    return {
      'icms': icms,
      'ipi': ipi,
      'pis': pis,
      'cofins': cofins,
    };
  }

  factory ImpostosItem.fromMap(Map<String, dynamic> map) {
    return ImpostosItem(
      icms: (map['icms'] as num?)?.toDouble() ?? 0.0,
      ipi: (map['ipi'] as num?)?.toDouble() ?? 0.0,
      pis: (map['pis'] as num?)?.toDouble() ?? 0.0,
      cofins: (map['cofins'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

enum TipoNotaFiscal {
  entrada,
  saida,
}

enum StatusNota {
  pendente,
  processada,
  cancelada,
  erro,
}

extension TipoNotaFiscalExtension on TipoNotaFiscal {
  String get nome {
    switch (this) {
      case TipoNotaFiscal.entrada:
        return 'Entrada';
      case TipoNotaFiscal.saida:
        return 'Saída';
    }
  }
}

extension StatusNotaExtension on StatusNota {
  String get nome {
    switch (this) {
      case StatusNota.pendente:
        return 'Pendente';
      case StatusNota.processada:
        return 'Processada';
      case StatusNota.cancelada:
        return 'Cancelada';
      case StatusNota.erro:
        return 'Erro';
    }
  }
}

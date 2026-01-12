/// Tipos de correção necessária para um elemento
enum TipoCorrecao {
  adicao, // Elemento abaixo do mínimo (precisa adicionar)
  diluicao, // Elemento acima do máximo (precisa diluir)
  ok, // Elemento dentro do range
}

extension TipoCorrecaoExtension on TipoCorrecao {
  String get nome {
    switch (this) {
      case TipoCorrecao.adicao:
        return 'Adição';
      case TipoCorrecao.diluicao:
        return 'Diluição';
      case TipoCorrecao.ok:
        return 'OK';
    }
  }

  String get descricao {
    switch (this) {
      case TipoCorrecao.adicao:
        return 'Elemento em falta - precisa adicionar';
      case TipoCorrecao.diluicao:
        return 'Elemento em excesso - precisa diluir';
      case TipoCorrecao.ok:
        return 'Elemento dentro da especificação';
    }
  }

  String get icone {
    switch (this) {
      case TipoCorrecao.adicao:
        return '⬆️'; // Seta para cima
      case TipoCorrecao.diluicao:
        return '⬇️'; // Seta para baixo
      case TipoCorrecao.ok:
        return '✅'; // Check
    }
  }
}

/// Classificação de um elemento quanto à necessidade de correção
class ClassificacaoElemento {
  final String simbolo;
  final String nome;
  final double percentualAtual;
  final double percentualMinimo;
  final double percentualMaximo;
  final TipoCorrecao tipoCorrecao;
  final double? percentualAlvo; // Alvo calculado para correção

  ClassificacaoElemento({
    required this.simbolo,
    required this.nome,
    required this.percentualAtual,
    required this.percentualMinimo,
    required this.percentualMaximo,
    required this.tipoCorrecao,
    this.percentualAlvo,
  });

  // Calcular desvio em relação ao range
  double get desvio {
    if (tipoCorrecao == TipoCorrecao.adicao) {
      return percentualMinimo - percentualAtual; // Positivo
    } else if (tipoCorrecao == TipoCorrecao.diluicao) {
      return percentualAtual - percentualMaximo; // Positivo
    }
    return 0.0;
  }

  // Calcular desvio percentual
  double get desvioPercentual {
    if (tipoCorrecao == TipoCorrecao.adicao) {
      return ((percentualMinimo - percentualAtual) / percentualMinimo) * 100;
    } else if (tipoCorrecao == TipoCorrecao.diluicao) {
      return ((percentualAtual - percentualMaximo) / percentualMaximo) * 100;
    }
    return 0.0;
  }

  // Verificar se está fora do range
  bool get foraDoRange {
    return tipoCorrecao != TipoCorrecao.ok;
  }

  // Obter alvo calculado ou médio
  double get alvoCalculado {
    if (percentualAlvo != null) return percentualAlvo!;
    
    if (tipoCorrecao == TipoCorrecao.adicao) {
      // Para adição, usar valor um pouco acima do mínimo
      return percentualMinimo + (percentualMaximo - percentualMinimo) * 0.2;
    } else if (tipoCorrecao == TipoCorrecao.diluicao) {
      // Para diluição, usar valor um pouco abaixo do máximo
      return percentualMaximo - (percentualMaximo - percentualMinimo) * 0.2;
    }
    
    return (percentualMinimo + percentualMaximo) / 2;
  }

  @override
  String toString() {
    return '$simbolo: $percentualAtual% (Range: $percentualMinimo-$percentualMaximo%) - ${tipoCorrecao.nome}';
  }
}

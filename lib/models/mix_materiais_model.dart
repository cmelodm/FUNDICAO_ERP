import 'material_correcao_model.dart';

/// Item do mix (material + quantidade)
class ItemMix {
  final MaterialCorrecao material;
  final double quantidade; // kg
  final double custoTotal; // R$
  final Map<String, double> contribuicaoElementos; // Contribuição de cada elemento (kg)

  ItemMix({
    required this.material,
    required this.quantidade,
    required this.custoTotal,
    required this.contribuicaoElementos,
  });

  // Calcular custo por kg de elemento útil
  double custoKgElemento(String simbolo) {
    final contribuicao = contribuicaoElementos[simbolo] ?? 0.0;
    if (contribuicao == 0) return double.infinity;
    return custoTotal / contribuicao;
  }
}

/// Resultado do cálculo de mix otimizado
class ResultadoMix {
  final List<ItemMix> itens;
  final double massaTotal; // kg total do mix
  final double custoTotal; // R$ total
  final Map<String, double> composicaoFinal; // Composição final do banho (%)
  final bool todosElementosDentroRange;
  final List<String> elementosForaRange;
  final String metodoUtilizado;

  ResultadoMix({
    required this.itens,
    required this.massaTotal,
    required this.custoTotal,
    required this.composicaoFinal,
    required this.todosElementosDentroRange,
    this.elementosForaRange = const [],
    required this.metodoUtilizado,
  });

  // Calcular custo médio por kg
  double get custoMedioKg {
    if (massaTotal == 0) return 0;
    return custoTotal / massaTotal;
  }

  // Obter resumo por tipo de material
  Map<TipoMaterialCorrecao, double> get resumoPorTipo {
    final resumo = <TipoMaterialCorrecao, double>{};
    for (var item in itens) {
      resumo[item.material.tipo] = 
          (resumo[item.material.tipo] ?? 0) + item.quantidade;
    }
    return resumo;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('  RESULTADO DO MIX OTIMIZADO');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('\n📦 Método: $metodoUtilizado');
    buffer.writeln('⚖️  Massa Total: ${massaTotal.toStringAsFixed(2)} kg');
    buffer.writeln('💰 Custo Total: R\$ ${custoTotal.toStringAsFixed(2)}');
    buffer.writeln('💵 Custo/kg: R\$ ${custoMedioKg.toStringAsFixed(2)}\n');
    
    buffer.writeln('📋 Composição do Mix:');
    for (var i = 0; i < itens.length; i++) {
      final item = itens[i];
      buffer.writeln('  ${i + 1}. ${item.material.nome}');
      buffer.writeln('     • Quantidade: ${item.quantidade.toStringAsFixed(2)} kg');
      buffer.writeln('     • Custo: R\$ ${item.custoTotal.toStringAsFixed(2)}');
      buffer.writeln('     • Tipo: ${item.material.tipo.nome}');
    }
    
    buffer.writeln('\n🧪 Composição Final Prevista:');
    composicaoFinal.forEach((elemento, percentual) {
      buffer.writeln('  $elemento: ${percentual.toStringAsFixed(3)}%');
    });
    
    if (todosElementosDentroRange) {
      buffer.writeln('\n✅ Todos os elementos dentro do range!');
    } else {
      buffer.writeln('\n⚠️ Elementos ainda fora do range:');
      for (var elemento in elementosForaRange) {
        buffer.writeln('  • $elemento');
      }
    }
    
    buffer.writeln('\n═══════════════════════════════════════');
    return buffer.toString();
  }
}

/// Restrições para cálculo de mix
class RestricoesMix {
  final Map<String, double> massaLiquidaNecessaria; // kg de cada elemento
  final Map<String, double> limiteMaximoElemento; // % máximo de cada elemento no banho
  final double massaInicialBanho; // kg
  final bool considerarEstoque; // Respeitar estoque disponível
  final bool minimizarCusto; // Otimizar por custo

  RestricoesMix({
    required this.massaLiquidaNecessaria,
    required this.limiteMaximoElemento,
    required this.massaInicialBanho,
    this.considerarEstoque = true,
    this.minimizarCusto = true,
  });
}

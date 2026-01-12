import 'tipo_correcao_enum.dart';

/// Modelo para priorização de correções
class PrioridadeCorrecao {
  final String simbolo;
  final String nome;
  final TipoCorrecao tipoCorrecao;
  final double fatorCriticidade;
  final int ordem;
  final String justificativa;

  PrioridadeCorrecao({
    required this.simbolo,
    required this.nome,
    required this.tipoCorrecao,
    required this.fatorCriticidade,
    required this.ordem,
    required this.justificativa,
  });

  @override
  String toString() {
    return '$ordem. $simbolo ($nome) - Criticidade: ${fatorCriticidade.toStringAsFixed(4)} - $justificativa';
  }
}

/// Resultado da análise de priorização
class ResultadoPriorizacao {
  final List<PrioridadeCorrecao> ordemCorrecao;
  final String estrategia;
  final List<String> avisos;

  ResultadoPriorizacao({
    required this.ordemCorrecao,
    required this.estrategia,
    this.avisos = const [],
  });

  // Obter elemento mais crítico
  PrioridadeCorrecao? get elementoMaisCritico {
    if (ordemCorrecao.isEmpty) return null;
    return ordemCorrecao.first;
  }

  // Verificar se tem elementos de adição
  bool get temAdicoes {
    return ordemCorrecao.any((p) => p.tipoCorrecao == TipoCorrecao.adicao);
  }

  // Verificar se tem elementos de diluição
  bool get temDiluicoes {
    return ordemCorrecao.any((p) => p.tipoCorrecao == TipoCorrecao.diluicao);
  }

  // Verificar se é correção mista (adição + diluição)
  bool get isCorrecaoMista {
    return temAdicoes && temDiluicoes;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('  ANÁLISE DE PRIORIZAÇÃO DE CORREÇÃO');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('\n📊 Estratégia: $estrategia\n');
    buffer.writeln('🎯 Ordem de Correção:');
    
    for (var prioridade in ordemCorrecao) {
      buffer.writeln('  ${prioridade.toString()}');
    }
    
    if (avisos.isNotEmpty) {
      buffer.writeln('\n⚠️ Avisos:');
      for (var aviso in avisos) {
        buffer.writeln('  • $aviso');
      }
    }
    
    buffer.writeln('\n═══════════════════════════════════════');
    return buffer.toString();
  }
}

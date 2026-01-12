import '../models/analise_espectrometrica.dart';
import '../models/liga_metalurgica_model.dart';
import '../models/material_correcao_model.dart';
import '../models/prioridade_correcao_model.dart';
import '../models/tipo_correcao_enum.dart';
import 'priorizacao_service.dart';

/// Modelo para resultado de correção individual
class ResultadoCorrecaoElemento {
  final String simbolo;
  final String nome;
  final TipoCorrecao tipoCorrecao;
  final double concentracaoInicial;
  final double concentracaoFinal;
  final double concentracaoAlvo;
  final String materialUtilizado;
  final double massaMaterialAdicionado;
  final double custoCorrecao;
  final bool dentroEspecificacao;
  final Map<String, double> impactoOutrosElementos;
  
  ResultadoCorrecaoElemento({
    required this.simbolo,
    required this.nome,
    required this.tipoCorrecao,
    required this.concentracaoInicial,
    required this.concentracaoFinal,
    required this.concentracaoAlvo,
    required this.materialUtilizado,
    required this.massaMaterialAdicionado,
    required this.custoCorrecao,
    required this.dentroEspecificacao,
    required this.impactoOutrosElementos,
  });
  
  @override
  String toString() {
    final tipo = tipoCorrecao == TipoCorrecao.adicao ? 'ADIÇÃO' : 'DILUIÇÃO';
    return '''
    ─────────────────────────────────────────────
    🔧 Correção $tipo - $simbolo ($nome)
    ─────────────────────────────────────────────
    📊 Concentração Inicial: ${concentracaoInicial.toStringAsFixed(2)}%
    🎯 Concentração Alvo: ${concentracaoAlvo.toStringAsFixed(2)}%
    ✅ Concentração Final: ${concentracaoFinal.toStringAsFixed(2)}%
    📦 Material: $materialUtilizado
    ⚖️  Massa Adicionada: ${massaMaterialAdicionado.toStringAsFixed(2)} kg
    💰 Custo: R\$ ${custoCorrecao.toStringAsFixed(2)}
    ${dentroEspecificacao ? '✅' : '❌'} Status: ${dentroEspecificacao ? 'Dentro da especificação' : 'Fora da especificação'}
    ''';
  }
}

/// Resultado completo do processo de correção
class ResultadoCorrecaoCompleta {
  final List<ResultadoCorrecaoElemento> correcoes;
  final double massaInicialForno;
  final double massaFinalForno;
  final double massaTotalAdicionada;
  final double custoTotal;
  final int numeroIteracoes;
  final bool todosElementosOk;
  final Map<String, ConcentracaoEvol> evolucaoConcentracoes;
  final String estrategiaAplicada;
  final Duration tempoProcessamento;
  final List<String> avisos;
  
  ResultadoCorrecaoCompleta({
    required this.correcoes,
    required this.massaInicialForno,
    required this.massaFinalForno,
    required this.massaTotalAdicionada,
    required this.custoTotal,
    required this.numeroIteracoes,
    required this.todosElementosOk,
    required this.evolucaoConcentracoes,
    required this.estrategiaAplicada,
    required this.tempoProcessamento,
    this.avisos = const [],
  });
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('\n═══════════════════════════════════════════════════════════════');
    buffer.writeln('  📋 RELATÓRIO COMPLETO DE CORREÇÃO DE LIGA');
    buffer.writeln('═══════════════════════════════════════════════════════════════\n');
    
    buffer.writeln('📊 Estratégia: $estrategiaAplicada');
    buffer.writeln('🔄 Iterações: $numeroIteracoes');
    buffer.writeln('⏱️  Tempo: ${tempoProcessamento.inMilliseconds}ms\n');
    
    buffer.writeln('⚖️  Massa do Forno:');
    buffer.writeln('   • Inicial: ${massaInicialForno.toStringAsFixed(2)} kg');
    buffer.writeln('   • Final: ${massaFinalForno.toStringAsFixed(2)} kg');
    buffer.writeln('   • Adicionada: ${massaTotalAdicionada.toStringAsFixed(2)} kg');
    buffer.writeln('   • Incremento: ${((massaTotalAdicionada / massaInicialForno) * 100).toStringAsFixed(1)}%\n');
    
    buffer.writeln('💰 Custo Total: R\$ ${custoTotal.toStringAsFixed(2)}\n');
    
    buffer.writeln('🔧 Correções Aplicadas (${correcoes.length}):');
    for (var correcao in correcoes) {
      buffer.writeln(correcao.toString());
    }
    
    if (avisos.isNotEmpty) {
      buffer.writeln('\n⚠️ Avisos:');
      for (var aviso in avisos) {
        buffer.writeln('  • $aviso');
      }
      buffer.writeln();
    }
    
    buffer.writeln('═══════════════════════════════════════════════════════════════');
    buffer.writeln(todosElementosOk 
        ? '  ✅ SUCESSO: Todos elementos dentro da especificação!' 
        : '  ⚠️ ATENÇÃO: Alguns elementos ainda fora da especificação');
    buffer.writeln('═══════════════════════════════════════════════════════════════\n');
    
    return buffer.toString();
  }
}

/// Evolução de concentração de um elemento
class ConcentracaoEvol {
  final String simbolo;
  final List<double> historico;
  final double inicial;
  final double final_;
  final double alvo;
  
  ConcentracaoEvol({
    required this.simbolo,
    required this.historico,
    required this.inicial,
    required this.final_,
    required this.alvo,
  });
}

/// Serviço de correção avançada de liga metálica
/// 
/// Implementa algoritmo completo de correção múltipla com:
/// - Priorização inteligente
/// - Sistema híbrido (adição + diluição)
/// - Recálculo em cascata
/// - Validação automática de faixas
class CorrecaoAvancadaService {
  final PriorizacaoService _priorizacaoService = PriorizacaoService();
  
  /// Executa correção completa da liga
  /// 
  /// Retorna [ResultadoCorrecaoCompleta] com todas correções aplicadas
  Future<ResultadoCorrecaoCompleta> executarCorrecao({
    required AnaliseEspectrometrica analiseInicial,
    required LigaMetalurgicaModel ligaAlvo,
    required double massaAtualForno,
    required List<MaterialCorrecao> materiaisDisponiveis,
    double toleranciaPercentual = 2.0,
    int maxIteracoes = 10,
  }) async {
    
    final inicio = DateTime.now();
    final List<ResultadoCorrecaoElemento> correcoes = [];
    final List<String> avisos = [];
    final Map<String, ConcentracaoEvol> evolucaoConcentracoes = {};
    
    // Estado atual do forno (será atualizado a cada correção)
    AnaliseEspectrometrica analiseAtual = analiseInicial;
    double massaAtualizada = massaAtualForno;
    double custoAcumulado = 0.0;
    int iteracao = 0;
    
    // Inicializar histórico de concentrações
    for (var elemento in analiseInicial.elementos) {
      evolucaoConcentracoes[elemento.simbolo] = ConcentracaoEvol(
        simbolo: elemento.simbolo,
        historico: [elemento.percentualMedido],
        inicial: elemento.percentualMedido,
        final_: elemento.percentualMedido,
        alvo: (elemento.percentualMinimo + elemento.percentualMaximo) / 2,
      );
    }
    
    // LOOP DE CORREÇÃO ITERATIVA
    while (iteracao < maxIteracoes) {
      iteracao++;
      
      // 1. ANALISAR PRIORIDADES
      final priorizacao = _priorizacaoService.analisarPrioridades(
        analise: analiseAtual,
        ligaAlvo: ligaAlvo,
        materiaisDisponiveis: materiaisDisponiveis,
        toleranciaPercentual: toleranciaPercentual,
      );
      
      // Se não há mais correções, finalizamos
      if (priorizacao.ordemCorrecao.isEmpty) {
        break;
      }
      
      // 2. CORRIGIR ELEMENTO MAIS CRÍTICO
      final elementoCritico = priorizacao.ordemCorrecao.first;
      
      try {
        // Selecionar material apropriado
        final material = _selecionarMaterial(
          elementoCritico.simbolo,
          elementoCritico.tipoCorrecao,
          materiaisDisponiveis,
        );
        
        if (material == null) {
          avisos.add('${elementoCritico.simbolo}: Material adequado não disponível');
          break;
        }
        
        // Buscar elemento na liga alvo
        final elementoLiga = ligaAlvo.elementos.firstWhere(
          (e) => e.simbolo == elementoCritico.simbolo,
        );
        
        // Buscar concentração atual
        final elementoAnalisado = analiseAtual.elementos.firstWhere(
          (e) => e.simbolo == elementoCritico.simbolo,
        );
        
        final concentracaoAtual = elementoAnalisado.percentualMedido;
        final concentracaoAlvo = (elementoLiga.percentualMinimo + elementoLiga.percentualMaximo) / 2;
        
        // 3. CALCULAR MASSA NECESSÁRIA
        final massaNecessaria = _priorizacaoService.calcularMassaNecessaria(
          massaAtual: massaAtualizada,
          concentracaoAtual: concentracaoAtual,
          concentracaoAlvo: concentracaoAlvo,
          concentracaoMaterial: material.getConcentracao(elementoCritico.simbolo),
          rendimentoMassa: material.getRendimento(elementoCritico.simbolo),
          rendimentoElementar: material.getRendimento(elementoCritico.simbolo),
        );
        
        // 4. SIMULAR IMPACTO EM TODOS ELEMENTOS (RECÁLCULO EM CASCATA)
        final novasConcentracoes = _priorizacaoService.simularImpacto(
          analiseAtual: analiseAtual,
          massaAtual: massaAtualizada,
          elementoCorrigido: elementoCritico.simbolo,
          massaAdicionada: massaNecessaria,
          material: material,
        );
        
        // 5. ATUALIZAR ESTADO DO FORNO
        massaAtualizada += massaNecessaria * (material.getRendimento(elementoCritico.simbolo) / 100.0);
        custoAcumulado += massaNecessaria * material.custoKg;
        
        // Atualizar análise com novas concentrações
        analiseAtual = _atualizarAnalise(
          analiseAtual,
          novasConcentracoes,
          ligaAlvo,
        );
        
        // 6. REGISTRAR CORREÇÃO
        final concentracaoFinal = novasConcentracoes[elementoCritico.simbolo]!;
        final dentroSpec = concentracaoFinal >= elementoLiga.percentualMinimo &&
                          concentracaoFinal <= elementoLiga.percentualMaximo;
        
        correcoes.add(ResultadoCorrecaoElemento(
          simbolo: elementoCritico.simbolo,
          nome: elementoCritico.nome,
          tipoCorrecao: elementoCritico.tipoCorrecao,
          concentracaoInicial: concentracaoAtual,
          concentracaoFinal: concentracaoFinal,
          concentracaoAlvo: concentracaoAlvo,
          materialUtilizado: material.nome,
          massaMaterialAdicionado: massaNecessaria,
          custoCorrecao: massaNecessaria * material.custoKg,
          dentroEspecificacao: dentroSpec,
          impactoOutrosElementos: novasConcentracoes,
        ));
        
        // 7. ATUALIZAR HISTÓRICO
        for (var simbolo in novasConcentracoes.keys) {
          evolucaoConcentracoes[simbolo]!.historico.add(novasConcentracoes[simbolo]!);
        }
        
      } catch (e) {
        avisos.add('${elementoCritico.simbolo}: Erro no cálculo - $e');
        break;
      }
    }
    
    // Verificar se todos elementos estão ok
    final todosOk = _verificarTodosElementos(analiseAtual, ligaAlvo, toleranciaPercentual);
    
    // Atualizar evolução final
    for (var simbolo in evolucaoConcentracoes.keys) {
      final elementoFinal = analiseAtual.elementos.firstWhere(
        (e) => e.simbolo == simbolo,
      );
      evolucaoConcentracoes[simbolo] = ConcentracaoEvol(
        simbolo: simbolo,
        historico: evolucaoConcentracoes[simbolo]!.historico,
        inicial: evolucaoConcentracoes[simbolo]!.inicial,
        final_: elementoFinal.percentualMedido,
        alvo: evolucaoConcentracoes[simbolo]!.alvo,
      );
    }
    
    final tempoTotal = DateTime.now().difference(inicio);
    
    return ResultadoCorrecaoCompleta(
      correcoes: correcoes,
      massaInicialForno: massaAtualForno,
      massaFinalForno: massaAtualizada,
      massaTotalAdicionada: massaAtualizada - massaAtualForno,
      custoTotal: custoAcumulado,
      numeroIteracoes: iteracao,
      todosElementosOk: todosOk,
      evolucaoConcentracoes: evolucaoConcentracoes,
      estrategiaAplicada: 'Correção Sequencial com Recálculo em Cascata',
      tempoProcessamento: tempoTotal,
      avisos: avisos,
    );
  }
  
  /// Seleciona material mais adequado para correção
  MaterialCorrecao? _selecionarMaterial(
    String simbolo,
    TipoCorrecao tipoCorrecao,
    List<MaterialCorrecao> materiais,
  ) {
    if (tipoCorrecao == TipoCorrecao.adicao) {
      // Para adição, selecionar material com MAIOR concentração do elemento
      final candidatos = materiais
          .where((m) => m.getConcentracao(simbolo) > 5.0)
          .toList();
      
      if (candidatos.isEmpty) return null;
      
      candidatos.sort((a, b) => 
          b.getConcentracao(simbolo).compareTo(a.getConcentracao(simbolo)));
      
      return candidatos.first;
      
    } else {
      // Para diluição, selecionar material com MENOR concentração do elemento
      final candidatos = materiais
          .where((m) => m.getConcentracao(simbolo) < 1.0)
          .toList();
      
      if (candidatos.isEmpty) return null;
      
      candidatos.sort((a, b) => 
          a.getConcentracao(simbolo).compareTo(b.getConcentracao(simbolo)));
      
      return candidatos.first;
    }
  }
  
  /// Atualiza análise com novas concentrações
  AnaliseEspectrometrica _atualizarAnalise(
    AnaliseEspectrometrica analiseAtual,
    Map<String, double> novasConcentracoes,
    LigaMetalurgicaModel ligaAlvo,
  ) {
    final novosElementos = analiseAtual.elementos.map((elemento) {
      final novaConcentracao = novasConcentracoes[elemento.simbolo] ?? elemento.percentualMedido;
      
      // Buscar faixas da liga alvo
      final elementoLiga = ligaAlvo.elementos.firstWhere(
        (e) => e.simbolo == elemento.simbolo,
        orElse: () => ElementoLiga(
          simbolo: elemento.simbolo,
          nome: elemento.nome,
          percentualMinimo: 0.0,
          percentualMaximo: 100.0,
          percentualNominal: novaConcentracao,
          rendimentoForno: 95.0,
        ),
      );
      
      final dentroRange = novaConcentracao >= elementoLiga.percentualMinimo &&
                          novaConcentracao <= elementoLiga.percentualMaximo;
      
      return ElementoAnalisado(
        simbolo: elemento.simbolo,
        nome: elemento.nome,
        percentualMedido: novaConcentracao,
        percentualMinimo: elementoLiga.percentualMinimo,
        percentualMaximo: elementoLiga.percentualMaximo,
        dentroRange: dentroRange,
        desvio: dentroRange ? 0.0 : (novaConcentracao < elementoLiga.percentualMinimo 
            ? novaConcentracao - elementoLiga.percentualMinimo
            : novaConcentracao - elementoLiga.percentualMaximo),
      );
    }).toList();
    
    return analiseAtual.copyWith(elementos: novosElementos);
  }
  
  /// Verifica se todos elementos estão dentro da especificação
  bool _verificarTodosElementos(
    AnaliseEspectrometrica analise,
    LigaMetalurgicaModel ligaAlvo,
    double toleranciaPercentual,
  ) {
    for (var elemento in ligaAlvo.elementos) {
      final elementoAnalisado = analise.elementos.firstWhere(
        (e) => e.simbolo == elemento.simbolo,
        orElse: () => ElementoAnalisado(
          simbolo: elemento.simbolo,
          nome: elemento.nome,
          percentualMedido: 0.0,
          percentualMinimo: elemento.percentualMinimo,
          percentualMaximo: elemento.percentualMaximo,
          dentroRange: false,
        ),
      );
      
      final concentracao = elementoAnalisado.percentualMedido;
      final larguraFaixa = elemento.percentualMaximo - elemento.percentualMinimo;
      final tolerancia = larguraFaixa * (toleranciaPercentual / 100.0);
      
      if (concentracao < (elemento.percentualMinimo - tolerancia) ||
          concentracao > (elemento.percentualMaximo + tolerancia)) {
        return false;
      }
    }
    
    return true;
  }
}

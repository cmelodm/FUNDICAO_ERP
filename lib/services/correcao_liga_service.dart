import '../models/liga_metalurgica_model.dart';
import '../models/analise_espectrometrica.dart';

class CorrecaoLigaService {
  // Validar se a análise está dentro das especificações
  static ResultadoValidacao validarAnalise(
    AnaliseEspectrometrica analise,
    LigaMetalurgicaModel ligaReferencia,
  ) {
    final elementosForaRange = <String>[];
    bool todosDentroRange = true;

    for (var elementoAnalise in analise.elementos) {
      if (!elementoAnalise.dentroRange) {
        todosDentroRange = false;
        elementosForaRange.add(
          '${elementoAnalise.simbolo}: ${elementoAnalise.percentualMedido.toStringAsFixed(3)}% '
          '(esperado: ${elementoAnalise.percentualMinimo.toStringAsFixed(2)}% - ${elementoAnalise.percentualMaximo.toStringAsFixed(2)}%)',
        );
      }
    }

    return ResultadoValidacao(
      aprovado: todosDentroRange,
      elementosForaRange: elementosForaRange,
    );
  }

  // Calcular correção necessária
  static CorrecaoLiga? calcularCorrecao(
    AnaliseEspectrometrica analise,
    LigaMetalurgicaModel ligaReferencia,
    double pesoTotalLigaNoForno,
    Map<String, String> materiaisElementos, // símbolo -> materialId
  ) {
    final correcoes = <CorrecaoElemento>[];

    for (var elementoAnalise in analise.elementos) {
      if (!elementoAnalise.dentroRange) {
        // Buscar elemento de referência da liga
        final elementoRef = ligaReferencia.elementos.firstWhere(
          (e) => e.simbolo == elementoAnalise.simbolo,
          orElse: () => throw Exception('Elemento ${elementoAnalise.simbolo} não encontrado na liga de referência'),
        );

        // Calcular percentual desejado (média do range)
        final percentualDesejado = (elementoRef.percentualMinimo + elementoRef.percentualMaximo) / 2;

        // Se está abaixo do mínimo, precisa adicionar
        if (elementoAnalise.percentualMedido < elementoRef.percentualMinimo) {
          final quantidadeAdicionar = _calcularQuantidadeAdicao(
            pesoTotalLigaNoForno,
            elementoAnalise.percentualMedido,
            percentualDesejado,
            elementoRef.rendimentoForno,
          );

          final materialId = materiaisElementos[elementoAnalise.simbolo] ?? '';
          
          correcoes.add(
            CorrecaoElemento(
              simbolo: elementoAnalise.simbolo,
              nome: elementoAnalise.nome,
              percentualAtual: elementoAnalise.percentualMedido,
              percentualDesejado: percentualDesejado,
              quantidadeAdicionar: quantidadeAdicionar,
              materialId: materialId,
              materialNome: '${elementoAnalise.nome} Puro',
            ),
          );
        }
        // Se está acima do máximo, não há correção simples (diluição necessária)
        else if (elementoAnalise.percentualMedido > elementoRef.percentualMaximo) {
          // Registrar mas sem correção automática
          correcoes.add(
            CorrecaoElemento(
              simbolo: elementoAnalise.simbolo,
              nome: elementoAnalise.nome,
              percentualAtual: elementoAnalise.percentualMedido,
              percentualDesejado: percentualDesejado,
              quantidadeAdicionar: 0.0,
              materialId: '',
              materialNome: 'Excesso - Diluição necessária',
            ),
          );
        }
      }
    }

    if (correcoes.isEmpty) return null;

    return CorrecaoLiga(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      analiseId: analise.id,
      correcoes: correcoes,
      pesoTotalLiga: pesoTotalLigaNoForno,
      dataCalculo: DateTime.now(),
    );
  }

  // Fórmula de cálculo de adição
  // Q = (P × (Cd - Ca)) / ((100 - Cd) × R)
  // Q = Quantidade a adicionar (kg)
  // P = Peso total da liga no forno (kg)
  // Cd = Concentração desejada (%)
  // Ca = Concentração atual (%)
  // R = Rendimento do forno (fração, ex: 0.95 para 95%)
  static double _calcularQuantidadeAdicao(
    double pesoTotalLiga,
    double concentracaoAtual,
    double concentracaoDesejada,
    double rendimentoForno,
  ) {
    final rendimentoFracao = rendimentoForno / 100;
    final numerador = pesoTotalLiga * (concentracaoDesejada - concentracaoAtual);
    final denominador = (100 - concentracaoDesejada) * rendimentoFracao;
    
    return numerador / denominador;
  }

  // Simular resultado após correção
  static Map<String, double> simularCorrecao(
    AnaliseEspectrometrica analise,
    CorrecaoLiga correcao,
  ) {
    final resultado = <String, double>{};
    final pesoFinal = correcao.pesoTotalLiga + correcao.pesoTotalCorrecao;

    for (var elementoAnalise in analise.elementos) {
      // Peso atual do elemento
      final pesoAtual = correcao.pesoTotalLiga * (elementoAnalise.percentualMedido / 100);
      
      // Peso adicionado do elemento
      double pesoAdicionado = 0.0;
      final correcaoElemento = correcao.correcoes.firstWhere(
        (c) => c.simbolo == elementoAnalise.simbolo,
        orElse: () => CorrecaoElemento(
          simbolo: '',
          nome: '',
          percentualAtual: 0,
          percentualDesejado: 0,
          quantidadeAdicionar: 0,
          materialId: '',
          materialNome: '',
        ),
      );
      
      if (correcaoElemento.simbolo.isNotEmpty) {
        pesoAdicionado = correcaoElemento.quantidadeAdicionar;
      }

      // Percentual final
      final percentualFinal = ((pesoAtual + pesoAdicionado) / pesoFinal) * 100;
      resultado[elementoAnalise.simbolo] = percentualFinal;
    }

    return resultado;
  }

  // ==================== DILUIÇÃO DE MÚLTIPLOS ELEMENTOS ====================
  
  /// Calcula diluição sequencial para múltiplos elementos em excesso
  /// 
  /// Metodologia:
  /// 1. Identifica elemento mais crítico (maior fator de excesso)
  /// 2. Calcula diluição para corrigir elemento crítico
  /// 3. Recalcula concentrações de todos os elementos após diluição
  /// 4. Repete processo para próximo elemento em excesso (se necessário)
  /// 
  /// Fórmulas utilizadas:
  /// - Fator de Excesso = (Ci - Cf) / (Cf - Cd)
  /// - Pd_real = (1/Rd) × Pi × (Ci - Cf) / (Cf - Cd)
  /// - Ci_novo = (Pi × Ci + Pd_real × Rd × Cd) / (Pi + Pd_real × Rd)
  static CorrecaoLiga calcularDiluicao({
    required AnaliseEspectrometrica analise,
    required double massaForno,
    required String materialDiluenteId,
    required String materialDiluenteNome,
    required Map<String, double> composicaoDiluente, // Ex: {'Si': 0.0, 'Cu': 0.0, 'Mg': 0.0, 'Al': 99.9}
    required double rendimentoDiluente, // Ex: 0.98 para Alumínio primário
    int maxIteracoes = 10,
  }) {
    print('\n🔬 === INÍCIO CÁLCULO DE DILUIÇÃO ===');
    print('Massa no forno: $massaForno kg');
    print('Material diluente: $materialDiluenteNome');
    print('Rendimento: ${(rendimentoDiluente * 100).toStringAsFixed(1)}%');
    
    // Estado atual dos elementos
    final Map<String, double> percentuaisAtuais = {};
    for (final elem in analise.elementos) {
      percentuaisAtuais[elem.simbolo] = elem.percentualMedido;
    }
    
    double massaTotalAtual = massaForno;
    final List<CorrecaoElemento> diluicoesTotais = [];
    
    // Iteração sequencial
    for (int iteracao = 0; iteracao < maxIteracoes; iteracao++) {
      print('\n--- Iteração ${iteracao + 1} ---');
      print('Massa total atual: ${massaTotalAtual.toStringAsFixed(2)} kg');
      
      // PASSO 1: Identificar elementos em excesso e calcular fator de excesso
      final Map<String, double> fatoresExcesso = {};
      final List<ElementoAnalisado> elementosExcesso = [];
      
      for (final elemento in analise.elementos) {
        final percentualAtual = percentuaisAtuais[elemento.simbolo]!;
        
        if (percentualAtual > elemento.percentualMaximo) {
          final Ci = percentualAtual / 100; // Concentração atual (fração)
          final Cf = elemento.percentualMaximo / 100; // Limite máximo (fração)
          final Cd = (composicaoDiluente[elemento.simbolo] ?? 0.0) / 100; // Concentração no diluente
          
          // Fator de Excesso = (Ci - Cf) / (Cf - Cd)
          final fatorExcesso = (Ci - Cf) / (Cf - Cd);
          fatoresExcesso[elemento.simbolo] = fatorExcesso;
          elementosExcesso.add(elemento);
          
          print('${elemento.simbolo}: ${percentualAtual.toStringAsFixed(4)}% > ${elemento.percentualMaximo}% (Fator: ${fatorExcesso.toStringAsFixed(4)})');
        }
      }
      
      // Se não há elementos em excesso, convergiu
      if (elementosExcesso.isEmpty) {
        print('\n✅ Convergência atingida na iteração ${iteracao + 1}');
        break;
      }
      
      // PASSO 2: Selecionar elemento mais crítico (maior fator de excesso)
      final elementoCritico = elementosExcesso.reduce((a, b) {
        return fatoresExcesso[a.simbolo]! > fatoresExcesso[b.simbolo]! ? a : b;
      });
      
      print('\n🎯 Elemento mais crítico: ${elementoCritico.simbolo} (Fator: ${fatoresExcesso[elementoCritico.simbolo]!.toStringAsFixed(4)})');
      
      final Ci_critico = percentuaisAtuais[elementoCritico.simbolo]! / 100;
      final Cf_critico = elementoCritico.percentualMaximo / 100;
      final Cd_critico = (composicaoDiluente[elementoCritico.simbolo] ?? 0.0) / 100;
      
      // Fórmula de diluição: Pd_real = (1/Rd) × Pi × (Ci - Cf) / (Cf - Cd)
      final Pd_real = (1 / rendimentoDiluente) * massaTotalAtual * 
                      (Ci_critico - Cf_critico) / (Cf_critico - Cd_critico);
      
      print('Massa de diluente necessária: ${Pd_real.toStringAsFixed(2)} kg');
      
      // Registra diluição
      final diluicao = CorrecaoElemento(
        simbolo: elementoCritico.simbolo,
        nome: elementoCritico.nome,
        percentualAtual: percentuaisAtuais[elementoCritico.simbolo]!,
        percentualDesejado: elementoCritico.percentualMaximo,
        quantidadeAdicionar: Pd_real,
        materialId: materialDiluenteId,
        materialNome: materialDiluenteNome,
      );
      
      diluicoesTotais.add(diluicao);
      
      // PASSO 3: Recalcular concentrações de TODOS os elementos
      final massaNovaTotal = massaTotalAtual + (Pd_real * rendimentoDiluente);
      print('\nNova massa total: ${massaNovaTotal.toStringAsFixed(2)} kg');
      
      print('\nRecalculando concentrações:');
      for (final elem in analise.elementos) {
        final Ci = percentuaisAtuais[elem.simbolo]! / 100;
        final Cd = (composicaoDiluente[elem.simbolo] ?? 0.0) / 100;
        
        // Ci_novo = (Pi × Ci + Pd_real × Rd × Cd) / (Pi + Pd_real × Rd)
        final Ci_novo = ((massaTotalAtual * Ci) + (Pd_real * rendimentoDiluente * Cd)) /
                        (massaTotalAtual + (Pd_real * rendimentoDiluente));
        
        final percentualNovo = Ci_novo * 100;
        print('  ${elem.simbolo}: ${percentuaisAtuais[elem.simbolo]!.toStringAsFixed(4)}% → ${percentualNovo.toStringAsFixed(4)}%');
        
        percentuaisAtuais[elem.simbolo] = percentualNovo;
      }
      
      massaTotalAtual = massaNovaTotal;
    }
    
    // Consolida diluições
    final diluicaoFinal = CorrecaoLiga(
      id: 'dil_${analise.id}_${DateTime.now().millisecondsSinceEpoch}',
      analiseId: analise.id,
      correcoes: diluicoesTotais,
      pesoTotalLiga: massaForno,
      dataCalculo: DateTime.now(),
      aplicada: false,
    );
    
    print('\n📋 === RESUMO FINAL ===');
    print('Massa inicial: ${massaForno.toStringAsFixed(2)} kg');
    print('Massa final: ${massaTotalAtual.toStringAsFixed(2)} kg');
    print('Total de diluente: ${diluicaoFinal.pesoTotalCorrecao.toStringAsFixed(2)} kg');
    print('Número de elementos diluídos: ${diluicaoFinal.correcoes.length}');
    
    print('\n✅ Percentuais finais após diluição:');
    percentuaisAtuais.forEach((elem, perc) {
      print('  $elem: ${perc.toStringAsFixed(4)}%');
    });
    
    return diluicaoFinal;
  }

  /// Simula aplicação da diluição e retorna percentuais finais previstos
  static Map<String, double> simularDiluicao(
    AnaliseEspectrometrica analise,
    CorrecaoLiga diluicao,
    Map<String, double> composicaoDiluente,
    double rendimentoDiluente,
  ) {
    final Map<String, double> percentuaisFinais = {};
    
    final massaInicial = diluicao.pesoTotalLiga;
    final massaDiluente = diluicao.pesoTotalCorrecao;
    final massaFinal = massaInicial + (massaDiluente * rendimentoDiluente);
    
    for (final elemento in analise.elementos) {
      final elem = elemento.simbolo;
      final percentualAtual = elemento.percentualMedido;
      
      // Converte para fração
      final Ci = percentualAtual / 100;
      final Cd = (composicaoDiluente[elem] ?? 0.0) / 100;
      
      // Ci_novo = (Pi × Ci + Pd × Rd × Cd) / (Pi + Pd × Rd)
      final Ci_novo = ((massaInicial * Ci) + (massaDiluente * rendimentoDiluente * Cd)) /
                      massaFinal;
      
      percentuaisFinais[elem] = Ci_novo * 100;
    }
    
    return percentuaisFinais;
  }
}

class ResultadoValidacao {
  final bool aprovado;
  final List<String> elementosForaRange;

  ResultadoValidacao({
    required this.aprovado,
    required this.elementosForaRange,
  });
}

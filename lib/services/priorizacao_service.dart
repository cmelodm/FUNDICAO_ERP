import '../models/analise_espectrometrica.dart';
import '../models/liga_metalurgica_model.dart';
import '../models/prioridade_correcao_model.dart';
import '../models/tipo_correcao_enum.dart';
import '../models/material_correcao_model.dart';

/// Serviço para priorização inteligente de correções
/// 
/// Implementa o algoritmo de análise de impacto cruzado para determinar
/// a ordem ótima de correção de múltiplos elementos químicos.
class PriorizacaoService {
  
  /// Analisa todos os elementos e determina a ordem de correção
  /// 
  /// Parâmetros:
  /// - [analise]: Análise espectrométrica atual
  /// - [ligaAlvo]: Liga metalúrgica alvo
  /// - [materiaisDisponiveis]: Materiais disponíveis para correção
  /// - [toleranciaPercentual]: Tolerância para considerar elemento correto (default: 5%)
  /// 
  /// Retorna [ResultadoPriorizacao] com ordem e estratégia de correção
  ResultadoPriorizacao analisarPrioridades({
    required AnaliseEspectrometrica analise,
    required LigaMetalurgicaModel ligaAlvo,
    List<MaterialCorrecao> materiaisDisponiveis = const [],
    double toleranciaPercentual = 5.0,
  }) {
    
    // Lista de elementos que precisam correção
    List<PrioridadeCorrecao> prioridadesCorrecao = [];
    List<String> avisos = [];
    
    // Analisar cada elemento da liga alvo
    for (var elemento in ligaAlvo.elementos) {
      // Buscar concentração atual na análise
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
      
      final concentracaoAtual = elementoAnalisado.percentualMedido;
      
      // Pular se concentração atual está dentro da faixa aceitável
      if (_dentroTolerancia(
        concentracaoAtual, 
        elemento.percentualMinimo, 
        elemento.percentualMaximo,
        toleranciaPercentual,
      )) {
        continue;
      }
      
      // Determinar tipo de correção necessária
      TipoCorrecao tipoCorrecao;
      double fatorCriticidade;
      String justificativa;
      
      if (concentracaoAtual < elemento.percentualMinimo) {
        // ADIÇÃO - Elemento deficiente
        tipoCorrecao = TipoCorrecao.adicao;
        fatorCriticidade = _calcularFatorAdicao(
          concentracaoAtual,
          elemento.percentualMinimo,
          elemento.percentualMaximo,
        );
        justificativa = 'Deficiente: ${concentracaoAtual.toStringAsFixed(2)}% < ${elemento.percentualMinimo.toStringAsFixed(2)}%';
        
      } else {
        // DILUIÇÃO - Elemento em excesso
        tipoCorrecao = TipoCorrecao.diluicao;
        
        // Verificar material diluente disponível
        final temDiluente = _temMaterialParaDiluir(elemento.simbolo, materiaisDisponiveis);
        if (!temDiluente) {
          avisos.add('⚠️ ${elemento.simbolo}: Sem diluente adequado disponível!');
        }
        
        fatorCriticidade = _calcularFatorExcesso(
          concentracaoAtual,
          elemento.percentualMaximo,
          elemento.percentualMinimo,
          temDiluente ? _getConcentracaoDiluente(elemento.simbolo, materiaisDisponiveis) : 0.0,
        );
        justificativa = 'Em excesso: ${concentracaoAtual.toStringAsFixed(2)}% > ${elemento.percentualMaximo.toStringAsFixed(2)}%';
      }
      
      prioridadesCorrecao.add(PrioridadeCorrecao(
        simbolo: elemento.simbolo,
        nome: elemento.nome,
        tipoCorrecao: tipoCorrecao,
        fatorCriticidade: fatorCriticidade,
        ordem: 0, // Será ordenado depois
        justificativa: justificativa,
      ));
    }
    
    // Ordenar por fator de criticidade (maior primeiro)
    prioridadesCorrecao.sort((a, b) => b.fatorCriticidade.compareTo(a.fatorCriticidade));
    
    // Atribuir ordem final
    final prioridadesOrdenadas = List.generate(
      prioridadesCorrecao.length,
      (index) => PrioridadeCorrecao(
        simbolo: prioridadesCorrecao[index].simbolo,
        nome: prioridadesCorrecao[index].nome,
        tipoCorrecao: prioridadesCorrecao[index].tipoCorrecao,
        fatorCriticidade: prioridadesCorrecao[index].fatorCriticidade,
        ordem: index + 1,
        justificativa: prioridadesCorrecao[index].justificativa,
      ),
    );
    
    // Determinar estratégia de correção
    final estrategia = _determinarEstrategia(prioridadesOrdenadas);
    
    return ResultadoPriorizacao(
      ordemCorrecao: prioridadesOrdenadas,
      estrategia: estrategia,
      avisos: avisos,
    );
  }
  
  /// Calcula fator de excesso para elementos em diluição
  /// 
  /// Fórmula: FatorExcesso = (Ci - Cf) / (Cf - Cd)
  /// 
  /// Onde:
  /// - Ci: Concentração inicial (atual)
  /// - Cf: Concentração final desejada (máximo da faixa)
  /// - Cd: Concentração do diluente
  double _calcularFatorExcesso(
    double concentracaoAtual,
    double concentracaoMaxima,
    double concentracaoMinima,
    double concentracaoDiluente,
  ) {
    // Usar ponto médio da faixa como alvo
    final concentracaoAlvo = (concentracaoMaxima + concentracaoMinima) / 2;
    
    // Evitar divisão por zero
    final denominador = concentracaoAlvo - concentracaoDiluente;
    if (denominador.abs() < 0.0001) {
      return 999999.0; // Fator extremamente alto - diluente inadequado
    }
    
    final fator = (concentracaoAtual - concentracaoAlvo) / denominador;
    return fator > 0 ? fator : 0.0;
  }
  
  /// Calcula fator de criticidade para elementos em adição
  /// 
  /// Quanto maior a deficiência relativa à faixa, maior o fator
  double _calcularFatorAdicao(
    double concentracaoAtual,
    double concentracaoMinima,
    double concentracaoMaxima,
  ) {
    // Usar ponto médio da faixa como alvo
    final concentracaoAlvo = (concentracaoMaxima + concentracaoMinima) / 2;
    
    // Quanto falta para atingir o alvo (normalizado pela largura da faixa)
    final larguraFaixa = concentracaoMaxima - concentracaoMinima;
    if (larguraFaixa < 0.0001) {
      return 1.0;
    }
    
    final deficiencia = concentracaoAlvo - concentracaoAtual;
    final fator = deficiencia / larguraFaixa;
    
    return fator > 0 ? fator : 0.0;
  }
  
  /// Verifica se concentração está dentro da tolerância aceitável
  bool _dentroTolerancia(
    double concentracaoAtual,
    double minimo,
    double maximo,
    double toleranciaPercentual,
  ) {
    // Expandir faixa com tolerância
    final larguraFaixa = maximo - minimo;
    final tolerancia = larguraFaixa * (toleranciaPercentual / 100.0);
    
    final minimoTolerado = minimo - tolerancia;
    final maximoTolerado = maximo + tolerancia;
    
    return concentracaoAtual >= minimoTolerado && 
           concentracaoAtual <= maximoTolerado;
  }
  
  /// Verifica se há material disponível para diluir elemento
  bool _temMaterialParaDiluir(
    String simbolo, 
    List<MaterialCorrecao> materiais,
  ) {
    if (materiais.isEmpty) return true; // Assume que tem se não especificou
    
    // Procurar material com concentração baixa do elemento
    return materiais.any((m) => m.getConcentracao(simbolo) < 1.0);
  }
  
  /// Obtém concentração do elemento no diluente mais adequado
  double _getConcentracaoDiluente(
    String simbolo,
    List<MaterialCorrecao> materiais,
  ) {
    if (materiais.isEmpty) return 0.1; // Default para alumínio primário
    
    // Encontrar material com menor concentração do elemento
    final materiaisDiluentes = materiais
        .where((m) => m.getConcentracao(simbolo) < 1.0)
        .toList();
    
    if (materiaisDiluentes.isEmpty) return 0.1;
    
    materiaisDiluentes.sort((a, b) => 
        a.getConcentracao(simbolo).compareTo(b.getConcentracao(simbolo)));
    
    return materiaisDiluentes.first.getConcentracao(simbolo);
  }
  
  /// Determina estratégia geral de correção
  String _determinarEstrategia(List<PrioridadeCorrecao> prioridades) {
    if (prioridades.isEmpty) {
      return 'Nenhuma correção necessária';
    }
    
    final temAdicoes = prioridades.any((p) => p.tipoCorrecao == TipoCorrecao.adicao);
    final temDiluicoes = prioridades.any((p) => p.tipoCorrecao == TipoCorrecao.diluicao);
    
    if (temAdicoes && temDiluicoes) {
      return 'Correção Mista - Adicionar elementos deficientes primeiro, depois diluir excessos';
    } else if (temAdicoes) {
      return 'Adição Sequencial - Adicionar elementos deficientes na ordem de criticidade';
    } else if (temDiluicoes) {
      return 'Diluição Sequencial - Diluir elementos em excesso na ordem de criticidade';
    }
    
    return 'Estratégia indeterminada';
  }
  
  /// Simula impacto de uma correção em todos os elementos
  /// 
  /// Útil para análise "what-if" antes de executar correção
  Map<String, double> simularImpacto({
    required AnaliseEspectrometrica analiseAtual,
    required double massaAtual,
    required String elementoCorrigido,
    required double massaAdicionada,
    required MaterialCorrecao material,
  }) {
    
    final novasConcentracoes = <String, double>{};
    
    // Calcular nova massa total
    final rendimentoMassa = material.getRendimento(elementoCorrigido) / 100.0;
    final novaMassaTotal = massaAtual + (massaAdicionada * rendimentoMassa);
    
    // Recalcular concentração de TODOS os elementos
    for (var elemento in analiseAtual.elementos) {
      final simbolo = elemento.simbolo;
      final concentracaoAtual = elemento.percentualMedido;
      final concentracaoMaterial = material.getConcentracao(simbolo);
      final rendimentoElementar = material.getRendimento(simbolo) / 100.0;
      
      // Fórmula: Ci,novo = (Pi * Ci + Pd,real * Cd * Re) / (Pi + Pd,real * Rm)
      final massaElementoAtual = massaAtual * (concentracaoAtual / 100.0);
      final massaElementoAdicionado = massaAdicionada * (concentracaoMaterial / 100.0) * rendimentoElementar;
      
      final novaConcentracao = ((massaElementoAtual + massaElementoAdicionado) / novaMassaTotal) * 100.0;
      
      novasConcentracoes[simbolo] = novaConcentracao;
    }
    
    return novasConcentracoes;
  }
  
  /// Calcula massa necessária para corrigir um elemento específico
  /// 
  /// Retorna massa do material a ser adicionado (kg)
  double calcularMassaNecessaria({
    required double massaAtual,
    required double concentracaoAtual,
    required double concentracaoAlvo,
    required double concentracaoMaterial,
    required double rendimentoMassa,
    required double rendimentoElementar,
  }) {
    
    // Converter percentuais para frações
    final Ci = concentracaoAtual / 100.0;
    final Cf = concentracaoAlvo / 100.0;
    final Cd = concentracaoMaterial / 100.0;
    final Rm = rendimentoMassa / 100.0;
    final Re = rendimentoElementar / 100.0;
    
    // Fórmula para ADIÇÃO:
    // Pd,real = Pi * (Cf - Ci) / (Cd * Re - Cf * Rm)
    if (concentracaoAtual < concentracaoAlvo) {
      final denominador = (Cd * Re) - (Cf * Rm);
      
      if (denominador.abs() < 0.000001) {
        throw Exception('Material inadequado: concentração insuficiente para correção');
      }
      
      final massaNecessaria = massaAtual * (Cf - Ci) / denominador;
      return massaNecessaria > 0 ? massaNecessaria : 0.0;
    }
    
    // Fórmula para DILUIÇÃO:
    // Pd,real = Pi * (Ci - Cf) / (Cf * Rm - Cd * Re)
    else {
      final denominador = (Cf * Rm) - (Cd * Re);
      
      if (denominador.abs() < 0.000001) {
        throw Exception('Material inadequado: concentração muito alta para diluição');
      }
      
      final massaNecessaria = massaAtual * (Ci - Cf) / denominador;
      return massaNecessaria > 0 ? massaNecessaria : 0.0;
    }
  }
}

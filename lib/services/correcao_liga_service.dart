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
}

class ResultadoValidacao {
  final bool aprovado;
  final List<String> elementosForaRange;

  ResultadoValidacao({
    required this.aprovado,
    required this.elementosForaRange,
  });
}

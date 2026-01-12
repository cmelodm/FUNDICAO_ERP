/// Teste do algoritmo de diluição de múltiplos elementos
/// 
/// CENÁRIO DE TESTE:
/// Liga SAE 306 com 2 elementos em excesso simultâneos:
/// - Si: 12.5% (acima do máximo de 9.5%)
/// - Cu: 6.8% (acima do máximo de 5.0%)
/// - Mg: 0.30% (dentro do range 0.20-0.45%)
/// 
/// Massa no forno: 5000 kg
/// Diluente: Alumínio primário (Al 99.9%, Si 0.0%, Cu 0.0%, Mg 0.0%)
/// Rendimento: 98%

import 'lib/models/analise_espectrometrica.dart';
import 'lib/services/correcao_liga_service.dart';

void main() {
  print('🧪 === TESTE DE DILUIÇÃO DE MÚLTIPLOS ELEMENTOS ===\n');
  
  final now = DateTime.now();
  
  // Cria análise com 2 elementos em excesso
  final analise = AnaliseEspectrometrica(
    id: 'analise_dil_001',
    ligaId: 'SAE306',
    ligaNome: 'SAE 306',
    ligaCodigo: 'SAE 306',
    ordemProducaoId: 'OP002',
    equipamentoId: 'ESPEC001',
    operadorId: 'OP001',
    operadorNome: 'Operador Teste',
    dataHoraAnalise: now,
    createdAt: now,
    status: StatusAnalise.aprovadoComRessalvas,
    elementos: [
      ElementoAnalisado(
        simbolo: 'Si',
        nome: 'Silício',
        percentualMedido: 12.5, // EXCESSO (limite máx: 9.5%)
        percentualMinimo: 7.5,
        percentualMaximo: 9.5,
        dentroRange: false,
        desvio: 3.0,
      ),
      ElementoAnalisado(
        simbolo: 'Cu',
        nome: 'Cobre',
        percentualMedido: 6.8, // EXCESSO (limite máx: 5.0%)
        percentualMinimo: 4.0,
        percentualMaximo: 5.0,
        dentroRange: false,
        desvio: 1.8,
      ),
      ElementoAnalisado(
        simbolo: 'Mg',
        nome: 'Magnésio',
        percentualMedido: 0.30, // OK (dentro do range)
        percentualMinimo: 0.20,
        percentualMaximo: 0.45,
        dentroRange: true,
      ),
    ],
  );
  
  print('📊 DADOS INICIAIS:');
  print('Liga: ${analise.ligaNome}');
  print('Massa no forno: 5000 kg');
  print('\nComposição atual:');
  for (final elem in analise.elementos) {
    final status = elem.dentroRange ? '✅ OK' : '⚠️  EXCESSO';
    print('  ${elem.simbolo}: ${elem.percentualMedido.toStringAsFixed(2)}% '
        '(range: ${elem.percentualMinimo}-${elem.percentualMaximo}%) $status');
  }
  
  print('\n' + '=' * 60);
  print('\n🔬 INICIANDO CÁLCULO DE DILUIÇÃO SEQUENCIAL\n');
  print('Diluente: Alumínio Primário (99.9% Al, 0% Si, 0% Cu, 0% Mg)');
  print('Rendimento: 98%');
  print('\n' + '=' * 60);
  
  // Composição do diluente (Alumínio primário)
  final composicaoDiluente = {
    'Al': 99.9,
    'Si': 0.0,
    'Cu': 0.0,
    'Mg': 0.0,
  };
  
  // Executa cálculo de diluição
  final diluicao = CorrecaoLigaService.calcularDiluicao(
    analise: analise,
    massaForno: 5000,
    materialDiluenteId: 'AL_PRIMARIO',
    materialDiluenteNome: 'Alumínio Primário 99.9%',
    composicaoDiluente: composicaoDiluente,
    rendimentoDiluente: 0.98,
    maxIteracoes: 10,
  );
  
  print('\n' + '=' * 60);
  print('\n📋 RESULTADO DA DILUIÇÃO:\n');
  
  for (final diluicaoElem in diluicao.correcoes) {
    print('${diluicaoElem.simbolo} (${diluicaoElem.nome}):');
    print('  Percentual inicial: ${diluicaoElem.percentualAtual.toStringAsFixed(4)}%');
    print('  Percentual desejado: ${diluicaoElem.percentualDesejado.toStringAsFixed(4)}%');
    print('  ➕ Quantidade de diluente: ${diluicaoElem.quantidadeAdicionar.toStringAsFixed(2)} kg');
    print('');
  }
  
  print('💰 Total de diluente adicionado: ${diluicao.pesoTotalCorrecao.toStringAsFixed(2)} kg');
  print('📦 Nova massa total: ${(diluicao.pesoTotalLiga + diluicao.pesoTotalCorrecao).toStringAsFixed(2)} kg');
  
  // Simula resultado final (usando função específica para diluição)
  final percentuaisFinais = CorrecaoLigaService.simularDiluicao(
    analise,
    diluicao,
    composicaoDiluente,
    0.98,
  );
  
  print('\n🎯 COMPOSIÇÃO FINAL PREVISTA:\n');
  for (final elem in analise.elementos) {
    final percentualFinal = percentuaisFinais[elem.simbolo] ?? 0;
    final dentroRange = percentualFinal >= elem.percentualMinimo && 
                       percentualFinal <= elem.percentualMaximo;
    final status = dentroRange ? '✅ OK' : '⚠️  FORA';
    
    print('  ${elem.simbolo}: ${elem.percentualMedido.toStringAsFixed(4)}% → '
        '${percentualFinal.toStringAsFixed(4)}% '
        '(range: ${elem.percentualMinimo}-${elem.percentualMaximo}%) $status');
  }
  
  // Validação final
  final todosOk = percentuaisFinais.entries.every((e) {
    final elem = analise.elementos.firstWhere((el) => el.simbolo == e.key);
    return e.value >= elem.percentualMinimo && e.value <= elem.percentualMaximo;
  });
  
  print('\n${todosOk ? "✅" : "⚠️ "} STATUS FINAL: ${todosOk ? "TODOS OS ELEMENTOS DENTRO DO RANGE" : "ALGUNS ELEMENTOS AINDA FORA DO RANGE"}');
  
  print('\n' + '=' * 60);
  
  // Análise dos resultados
  print('\n📊 ANÁLISE DOS RESULTADOS:\n');
  
  for (final elem in analise.elementos) {
    final inicial = elem.percentualMedido;
    final final_ = percentuaisFinais[elem.simbolo] ?? 0;
    final reducao = inicial - final_;
    final reducaoPercentual = (reducao / inicial) * 100;
    
    print('${elem.simbolo}:');
    print('  Redução absoluta: ${reducao.toStringAsFixed(4)}%');
    print('  Redução relativa: ${reducaoPercentual.toStringAsFixed(2)}%');
    print('');
  }
  
  print('\n' + '=' * 60);
  print('🏁 TESTE CONCLUÍDO');
}

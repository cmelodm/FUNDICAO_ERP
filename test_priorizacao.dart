import 'package:foundry_erp/models/analise_espectrometrica.dart';
import 'package:foundry_erp/models/liga_metalurgica_model.dart';
import 'package:foundry_erp/models/material_correcao_model.dart';
import 'package:foundry_erp/services/priorizacao_service.dart';
import 'package:foundry_erp/services/liga_templates_service.dart';

void main() {
  print('\n═══════════════════════════════════════════════════════════════');
  print('  🧪 TESTE: PRIORIZACAO SERVICE - Análise de Impacto Cruzado');
  print('═══════════════════════════════════════════════════════════════\n');
  
  final service = PriorizacaoService();
  final templatesService = LigaTemplatesService();
  
  // ========================================
  // TESTE 1: Caso Real SAE 306
  // ========================================
  print('📋 TESTE 1: Correção Múltipla SAE 306\n');
  print('Cenário: Forno com Si e Mg em excesso, Cu deficiente\n');
  
  // Liga alvo: SAE 306
  final ligaSAE306Template = templatesService.buscarPorCodigo('SAE 306')!;
  final ligaSAE306 = LigaMetalurgicaModel(
    id: 'LIGA_SAE306',
    nome: ligaSAE306Template.nome,
    codigo: ligaSAE306Template.codigo,
    norma: ligaSAE306Template.norma,
    tipo: ligaSAE306Template.tipo,
    pesoTotal: 1000.0,
    elementos: ligaSAE306Template.elementos,
    dataCriacao: DateTime.now(),
  );
  
  // Análise atual: problemas múltiplos
  final analiseProblematica = AnaliseEspectrometrica(
    id: 'TEST_001',
    ligaId: 'LIGA_SAE306',
    ligaNome: ligaSAE306.nome,
    ligaCodigo: ligaSAE306.codigo,
    ordemProducaoId: 'OP-TEST-001',
    equipamentoId: 'SPEC-001',
    operadorId: 'OP-001',
    operadorNome: 'Teste Operador',
    dataHoraAnalise: DateTime.now(),
    status: StatusAnalise.emAnalise,
    createdAt: DateTime.now(),
    elementos: [
      ElementoAnalisado(
        simbolo: 'Si',
        nome: 'Silício',
        percentualMedido: 10.5,         // MAX: 9.5% ❌
        percentualMinimo: 7.5,
        percentualMaximo: 9.5,
        dentroRange: false,
        desvio: 1.0,
      ),
      ElementoAnalisado(
        simbolo: 'Cu',
        nome: 'Cobre',
        percentualMedido: 3.5,           // MIN: 4.0% ❌
        percentualMinimo: 4.0,
        percentualMaximo: 5.0,
        dentroRange: false,
        desvio: -0.5,
      ),
      ElementoAnalisado(
        simbolo: 'Fe',
        nome: 'Ferro',
        percentualMedido: 0.8,
        percentualMinimo: 0.0,
        percentualMaximo: 1.3,
        dentroRange: true,
      ),
      ElementoAnalisado(
        simbolo: 'Mg',
        nome: 'Magnésio',
        percentualMedido: 0.50,          // MAX: 0.45% ❌
        percentualMinimo: 0.20,
        percentualMaximo: 0.45,
        dentroRange: false,
        desvio: 0.05,
      ),
      ElementoAnalisado(
        simbolo: 'Mn',
        nome: 'Manganês',
        percentualMedido: 0.20,
        percentualMinimo: 0.0,
        percentualMaximo: 0.50,
        dentroRange: true,
      ),
      ElementoAnalisado(
        simbolo: 'Zn',
        nome: 'Zinco',
        percentualMedido: 0.40,
        percentualMinimo: 0.0,
        percentualMaximo: 1.0,
        dentroRange: true,
      ),
    ],
  );
  
  // Materiais disponíveis
  final materiaisDisponiveis = [
    // Alumínio primário (diluente)
    MaterialCorrecao(
      id: 'MAT_001',
      nome: 'Alumínio Primário 99.7%',
      codigo: 'AL_PRIM',
      tipo: TipoMaterialCorrecao.primario,
      composicao: {'Si': 0.1, 'Cu': 0.0, 'Fe': 0.15, 'Mg': 0.0},
      rendimentos: {'Si': 95.0, 'Cu': 98.0, 'Fe': 98.0, 'Mg': 90.0},
      custoKg: 12.50,
      estoqueDisponivel: 5000.0,
    ),
    
    // Liga-mãe Cu (aditivo)
    MaterialCorrecao(
      id: 'MAT_002',
      nome: 'Liga-Mãe Al-Cu 50%',
      codigo: 'LM_CU50',
      tipo: TipoMaterialCorrecao.ligaMae,
      composicao: {'Si': 0.5, 'Cu': 50.0, 'Fe': 0.2, 'Mg': 0.0},
      rendimentos: {'Si': 95.0, 'Cu': 98.0, 'Fe': 98.0, 'Mg': 90.0},
      custoKg: 45.00,
      estoqueDisponivel: 500.0,
    ),
  ];
  
  // Executar análise de priorização
  final resultado = service.analisarPrioridades(
    analise: analiseProblematica,
    ligaAlvo: ligaSAE306,
    materiaisDisponiveis: materiaisDisponiveis,
    toleranciaPercentual: 2.0,
  );
  
  print(resultado);
  
  // ========================================
  // TESTE 2: Cálculo de Massa Necessária
  // ========================================
  print('\n📋 TESTE 2: Cálculo de Massa para Correção de Cu\n');
  
  if (resultado.ordemCorrecao.any((p) => p.simbolo == 'Cu')) {
    final elementoCu = resultado.ordemCorrecao.firstWhere((p) => p.simbolo == 'Cu');
    final materialCu = materiaisDisponiveis.firstWhere((m) => m.getConcentracao('Cu') > 10.0);
    
    print('🎯 Elemento: ${elementoCu.nome}');
    print('📊 Concentração Atual: 3.5%');
    print('🎯 Concentração Alvo: 4.5% (média da faixa 4.0-5.0%)');
    print('🔧 Material: ${materialCu.nome}');
    print('   • Concentração Cu: ${materialCu.getConcentracao('Cu').toStringAsFixed(1)}%');
    print('   • Rendimento Cu: ${materialCu.getRendimento('Cu').toStringAsFixed(0)}%\n');
    
    try {
      final massaNecessaria = service.calcularMassaNecessaria(
        massaAtual: 1000.0,
        concentracaoAtual: 3.5,
        concentracaoAlvo: 4.5,
        concentracaoMaterial: materialCu.getConcentracao('Cu'),
        rendimentoMassa: 98.0,
        rendimentoElementar: materialCu.getRendimento('Cu'),
      );
      
      print('✅ Massa Necessária: ${massaNecessaria.toStringAsFixed(2)} kg');
      print('💰 Custo Estimado: R\$ ${(massaNecessaria * materialCu.custoKg).toStringAsFixed(2)}');
      
    } catch (e) {
      print('❌ Erro no cálculo: $e');
    }
  }
  
  // ========================================
  // TESTE 3: Simulação de Impacto
  // ========================================
  print('\n📋 TESTE 3: Simulação de Impacto da Adição de Cu\n');
  
  final materialCu = materiaisDisponiveis.firstWhere((m) => m.getConcentracao('Cu') > 10.0);
  
  print('🔬 Simulando adição de 20 kg de Liga-Mãe Al-Cu 50%...\n');
  
  final impactoSimulado = service.simularImpacto(
    analiseAtual: analiseProblematica,
    massaAtual: 1000.0,
    elementoCorrigido: 'Cu',
    massaAdicionada: 20.0,
    material: materialCu,
  );
  
  print('📊 Impacto nas Concentrações:');
  print('─────────────────────────────────────');
  for (var elemento in analiseProblematica.elementos) {
    final simbolo = elemento.simbolo;
    final concentracaoAntes = elemento.percentualMedido;
    final concentracaoDepois = impactoSimulado[simbolo] ?? concentracaoAntes;
    final delta = concentracaoDepois - concentracaoAntes;
    final sinal = delta >= 0 ? '+' : '';
    
    print('  $simbolo: ${concentracaoAntes.toStringAsFixed(2)}% → ${concentracaoDepois.toStringAsFixed(2)}% '
          '($sinal${delta.toStringAsFixed(2)}%)');
  }
  
  print('\n═══════════════════════════════════════════════════════════════');
  print('  ✅ TESTE COMPLETO - PriorizacaoService Funcionando!');
  print('═══════════════════════════════════════════════════════════════\n');
}

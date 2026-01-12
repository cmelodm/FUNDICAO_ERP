import 'package:foundry_erp/models/analise_espectrometrica.dart';
import 'package:foundry_erp/models/liga_metalurgica_model.dart';
import 'package:foundry_erp/models/material_correcao_model.dart';
import 'package:foundry_erp/services/correcao_avancada_service.dart';
import 'package:foundry_erp/services/liga_templates_service.dart';

void main() async {
  print('\n═══════════════════════════════════════════════════════════════');
  print('  🧪 TESTE: CORREÇÃO AVANÇADA - Algoritmo Completo');
  print('═══════════════════════════════════════════════════════════════\n');
  
  final service = CorrecaoAvancadaService();
  final templatesService = LigaTemplatesService();
  
  // ========================================
  // CENÁRIO DE TESTE: SAE 306 com 3 elementos problemáticos
  // ========================================
  print('📋 CENÁRIO: Forno 1000kg SAE 306 com 3 elementos fora de especificação');
  print('─────────────────────────────────────────────────────────────────\n');
  
  // Liga alvo
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
  
  // Análise atual - PROBLEMAS MÚLTIPLOS
  final analise = AnaliseEspectrometrica(
    id: 'TEST_CORR_001',
    ligaId: 'LIGA_SAE306',
    ligaNome: ligaSAE306.nome,
    ligaCodigo: ligaSAE306.codigo,
    ordemProducaoId: 'OP-2025-001',
    equipamentoId: 'SPEC-001',
    operadorId: 'OP-001',
    operadorNome: 'João Silva',
    dataHoraAnalise: DateTime.now(),
    status: StatusAnalise.emAnalise,
    createdAt: DateTime.now(),
    elementos: [
      // Si: Em excesso (10.5% > MAX 9.5%)
      ElementoAnalisado(
        simbolo: 'Si',
        nome: 'Silício',
        percentualMedido: 10.5,
        percentualMinimo: 7.5,
        percentualMaximo: 9.5,
        dentroRange: false,
        desvio: 1.0,
      ),
      
      // Cu: Deficiente (3.2% < MIN 4.0%)
      ElementoAnalisado(
        simbolo: 'Cu',
        nome: 'Cobre',
        percentualMedido: 3.2,
        percentualMinimo: 4.0,
        percentualMaximo: 5.0,
        dentroRange: false,
        desvio: -0.8,
      ),
      
      // Fe: OK
      ElementoAnalisado(
        simbolo: 'Fe',
        nome: 'Ferro',
        percentualMedido: 0.8,
        percentualMinimo: 0.0,
        percentualMaximo: 1.3,
        dentroRange: true,
      ),
      
      // Mg: Em excesso (0.55% > MAX 0.45%)
      ElementoAnalisado(
        simbolo: 'Mg',
        nome: 'Magnésio',
        percentualMedido: 0.55,
        percentualMinimo: 0.20,
        percentualMaximo: 0.45,
        dentroRange: false,
        desvio: 0.10,
      ),
      
      // Mn: OK
      ElementoAnalisado(
        simbolo: 'Mn',
        nome: 'Manganês',
        percentualMedido: 0.25,
        percentualMinimo: 0.0,
        percentualMaximo: 0.50,
        dentroRange: true,
      ),
      
      // Zn: OK
      ElementoAnalisado(
        simbolo: 'Zn',
        nome: 'Zinco',
        percentualMedido: 0.50,
        percentualMinimo: 0.0,
        percentualMaximo: 1.0,
        dentroRange: true,
      ),
    ],
  );
  
  // Materiais disponíveis
  final materiais = [
    // Alumínio Primário (diluente)
    MaterialCorrecao(
      id: 'MAT_AL_PRIM',
      nome: 'Alumínio Primário 99.7%',
      codigo: 'AL-PRIM',
      tipo: TipoMaterialCorrecao.primario,
      composicao: {
        'Si': 0.1,
        'Cu': 0.0,
        'Fe': 0.15,
        'Mg': 0.0,
        'Mn': 0.0,
        'Zn': 0.0,
      },
      rendimentos: {
        'Si': 95.0,
        'Cu': 98.0,
        'Fe': 98.0,
        'Mg': 90.0,
        'Mn': 95.0,
        'Zn': 98.0,
      },
      custoKg: 12.50,
      estoqueDisponivel: 10000.0,
    ),
    
    // Liga-mãe Al-Cu 50%
    MaterialCorrecao(
      id: 'MAT_CU_50',
      nome: 'Liga-Mãe Al-Cu 50%',
      codigo: 'LM-CU50',
      tipo: TipoMaterialCorrecao.ligaMae,
      composicao: {
        'Si': 0.5,
        'Cu': 50.0,
        'Fe': 0.2,
        'Mg': 0.0,
        'Mn': 0.0,
        'Zn': 0.0,
      },
      rendimentos: {
        'Si': 95.0,
        'Cu': 98.0,
        'Fe': 98.0,
        'Mg': 90.0,
        'Mn': 95.0,
        'Zn': 98.0,
      },
      custoKg: 45.00,
      estoqueDisponivel: 1000.0,
    ),
  ];
  
  print('📊 ESTADO INICIAL DO FORNO:');
  print('─────────────────────────────────────────');
  print('  Massa: 1000.00 kg\n');
  
  print('  Elementos Problemáticos:');
  for (var elemento in analise.elementos) {
    if (!elemento.dentroRange) {
      final status = elemento.percentualMedido < elemento.percentualMinimo 
          ? 'DEFICIENTE' 
          : 'EM EXCESSO';
      print('    ❌ ${elemento.simbolo}: ${elemento.percentualMedido.toStringAsFixed(2)}% - $status');
    }
  }
  
  print('\n  Elementos OK:');
  for (var elemento in analise.elementos) {
    if (elemento.dentroRange) {
      print('    ✅ ${elemento.simbolo}: ${elemento.percentualMedido.toStringAsFixed(2)}%');
    }
  }
  
  print('\n💰 MATERIAIS DISPONÍVEIS:');
  print('─────────────────────────────────────────');
  for (var material in materiais) {
    print('  • ${material.nome}');
    print('    Custo: R\$ ${material.custoKg.toStringAsFixed(2)}/kg');
    print('    Estoque: ${material.estoqueDisponivel.toStringAsFixed(0)} kg\n');
  }
  
  // ========================================
  // EXECUTAR CORREÇÃO COMPLETA
  // ========================================
  print('\n🚀 EXECUTANDO CORREÇÃO AVANÇADA...\n');
  print('═══════════════════════════════════════════════════════════════\n');
  
  final resultado = await service.executarCorrecao(
    analiseInicial: analise,
    ligaAlvo: ligaSAE306,
    massaAtualForno: 1000.0,
    materiaisDisponiveis: materiais,
    toleranciaPercentual: 2.0,
    maxIteracoes: 10,
  );
  
  // ========================================
  // EXIBIR RESULTADO COMPLETO
  // ========================================
  print(resultado);
  
  // ========================================
  // ANÁLISE DETALHADA DA EVOLUÇÃO
  // ========================================
  print('\n📈 EVOLUÇÃO DAS CONCENTRAÇÕES:');
  print('═══════════════════════════════════════════════════════════════\n');
  
  for (var simbolo in resultado.evolucaoConcentracoes.keys) {
    final evolucao = resultado.evolucaoConcentracoes[simbolo]!;
    
    if (evolucao.historico.length > 1) {
      print('🔬 $simbolo (${evolucao.simbolo}):');
      print('   Inicial: ${evolucao.inicial.toStringAsFixed(2)}%');
      print('   Alvo: ${evolucao.alvo.toStringAsFixed(2)}%');
      print('   Final: ${evolucao.final_.toStringAsFixed(2)}%');
      print('   Iterações: ${evolucao.historico.length - 1}');
      print('   Histórico: ${evolucao.historico.map((c) => c.toStringAsFixed(2)).join(' → ')}%\n');
    }
  }
  
  // ========================================
  // RESUMO EXECUTIVO
  // ========================================
  print('\n📊 RESUMO EXECUTIVO:');
  print('═══════════════════════════════════════════════════════════════\n');
  
  final taxaSucesso = (resultado.correcoes.where((c) => c.dentroEspecificacao).length / 
                       resultado.correcoes.length * 100);
  
  print('✅ Taxa de Sucesso: ${taxaSucesso.toStringAsFixed(1)}%');
  print('🔄 Iterações Totais: ${resultado.numeroIteracoes}');
  print('⚖️  Incremento de Massa: ${((resultado.massaTotalAdicionada / resultado.massaInicialForno) * 100).toStringAsFixed(2)}%');
  print('💰 Custo por kg Corrigido: R\$ ${(resultado.custoTotal / resultado.massaTotalAdicionada).toStringAsFixed(2)}/kg');
  print('⏱️  Eficiência: ${(resultado.correcoes.length / resultado.numeroIteracoes).toStringAsFixed(2)} correções/iteração');
  
  print('\n═══════════════════════════════════════════════════════════════');
  print(resultado.todosElementosOk 
      ? '  🎉 TESTE APROVADO - Algoritmo Funcionando Perfeitamente!'
      : '  ⚠️  TESTE COM RESSALVAS - Revisar elementos fora de especificação');
  print('═══════════════════════════════════════════════════════════════\n');
}

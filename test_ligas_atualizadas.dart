import 'package:foundry_erp/services/liga_templates_service.dart';

void main() {
  print('═══════════════════════════════════════════════════════');
  print('   TESTE DAS LIGAS SAE ATUALIZADAS (2025)');
  print('═══════════════════════════════════════════════════════\n');

  final service = LigaTemplatesService();

  // Testar ligas SAE atualizadas
  final ligasParaTestar = [
    'SAE 303',
    'SAE 305',
    'SAE 305 C',
    'SAE 305 I',
    'SAE 306',
    'SAE 309',
    'SAE 323',
    'SAE 329',
  ];

  for (var codigo in ligasParaTestar) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Liga: $codigo');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    var liga = service.buscarPorCodigo(codigo);
    
    if (liga == null) {
      print('❌ ERRO: Liga $codigo não encontrada!\n');
      continue;
    }

    print('✅ Nome: ${liga.nome}');
    print('📋 Norma: ${liga.norma}');
    print('🔧 Tipo: ${liga.tipo}');
    print('📝 Descrição: ${liga.descricao}');
    print('🎯 Aplicação: ${liga.aplicacao}');
    print('\n🧪 Composição Química:');
    print('─────────────────────────────────────────────────────────');
    
    for (var elemento in liga.elementos) {
      print(
        '  ${elemento.simbolo.padRight(4)} ${elemento.nome.padRight(12)} '
        '${elemento.percentualMinimo.toStringAsFixed(2)}% - ${elemento.percentualMaximo.toStringAsFixed(2)}% '
        '(Nominal: ${elemento.percentualNominal.toStringAsFixed(2)}%, Rend: ${elemento.rendimentoForno.toStringAsFixed(0)}%)'
      );
    }
    print('');
  }

  print('═══════════════════════════════════════════════════════');
  print('   RESUMO DAS ATUALIZAÇÕES');
  print('═══════════════════════════════════════════════════════');
  print('');
  print('📊 FONTE: ALUMIZA (www.alumiza.com.br)');
  print('   ✅ SAE 303 - Atualizado');
  print('   ✅ SAE 305 - Atualizado');
  print('   ✅ SAE 305 C - NOVO (Versão Comercial)');
  print('   ✅ SAE 305 I - NOVO (Versão Industrial)');
  print('');
  print('📊 FONTE: ALMEIDA METAIS (www.almeidametais.com.br)');
  print('   ✅ SAE 306 - Atualizado (Cu: 4.0-5.0%, Mg: 0.20-0.45%)');
  print('   ✅ SAE 309 - Atualizado (Mg: 0.40-0.60%)');
  print('   ✅ SAE 323 - Atualizado (Equivalente A356 refinado)');
  print('   ✅ SAE 329 - Atualizado (Premium Si-Mg)');
  print('');
  print('🎯 Total de ligas no sistema: ${service.ligasTemplates.length}');
  print('🎯 Ligas SAE disponíveis: ${service.filtrarPorNorma("SAE").length}');
  print('═══════════════════════════════════════════════════════\n');
}

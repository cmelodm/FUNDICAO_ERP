import 'package:foundry_erp/services/liga_templates_service.dart';

void main() {
  print('═══════════════════════════════════════════════════════');
  print('   TESTE DE VALIDAÇÃO - CORREÇÃO Si (SAE 303 e 305)');
  print('═══════════════════════════════════════════════════════\n');

  final service = LigaTemplatesService();

  // Testar SAE 303
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ VALIDAÇÃO SAE 303');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  var sae303 = service.buscarPorCodigo('SAE 303');
  if (sae303 != null) {
    var si303 = sae303.elementos.firstWhere((e) => e.simbolo == 'Si');
    
    print('📋 Especificação do Documento:');
    print('   Si: 10.50% - 12.00%');
    print('');
    print('📊 Especificação no Sistema:');
    print('   Si: ${si303.percentualMinimo}% - ${si303.percentualMaximo}%');
    print('   Nominal: ${si303.percentualNominal}%');
    print('');
    
    bool correto303 = si303.percentualMinimo == 10.50 && 
                       si303.percentualMaximo == 12.0 &&
                       si303.percentualNominal == 11.25;
    
    if (correto303) {
      print('✅ CORRETO - SAE 303 com Si: 10.50-12.0%');
    } else {
      print('❌ ERRO - SAE 303 com especificação incorreta!');
      print('   Esperado: 10.50-12.0% (Nominal: 11.25%)');
      print('   Encontrado: ${si303.percentualMinimo}-${si303.percentualMaximo}% (Nominal: ${si303.percentualNominal}%)');
    }
  } else {
    print('❌ ERRO: Liga SAE 303 não encontrada!');
  }
  
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('✅ VALIDAÇÃO SAE 305');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  var sae305 = service.buscarPorCodigo('SAE 305');
  if (sae305 != null) {
    var si305 = sae305.elementos.firstWhere((e) => e.simbolo == 'Si');
    
    print('📋 Especificação do Documento:');
    print('   Si: 11.00% - 13.00%');
    print('');
    print('📊 Especificação no Sistema:');
    print('   Si: ${si305.percentualMinimo}% - ${si305.percentualMaximo}%');
    print('   Nominal: ${si305.percentualNominal}%');
    print('');
    
    bool correto305 = si305.percentualMinimo == 11.0 && 
                       si305.percentualMaximo == 13.0 &&
                       si305.percentualNominal == 12.0;
    
    if (correto305) {
      print('✅ CORRETO - SAE 305 com Si: 11.0-13.0%');
    } else {
      print('❌ ERRO - SAE 305 com especificação incorreta!');
      print('   Esperado: 11.0-13.0% (Nominal: 12.0%)');
      print('   Encontrado: ${si305.percentualMinimo}-${si305.percentualMaximo}% (Nominal: ${si305.percentualNominal}%)');
    }
  } else {
    print('❌ ERRO: Liga SAE 305 não encontrada!');
  }
  
  print('\n═══════════════════════════════════════════════════════');
  print('   COMPARAÇÃO LADO A LADO');
  print('═══════════════════════════════════════════════════════');
  
  if (sae303 != null && sae305 != null) {
    var si303 = sae303.elementos.firstWhere((e) => e.simbolo == 'Si');
    var si305 = sae305.elementos.firstWhere((e) => e.simbolo == 'Si');
    
    print('');
    print('┌─────────────────────────────────────────────────────┐');
    print('│  ELEMENTO: SILÍCIO (Si)                             │');
    print('├─────────────────────────────────────────────────────┤');
    print('│  SAE 303:  ${si303.percentualMinimo.toStringAsFixed(2)}% - ${si303.percentualMaximo.toStringAsFixed(2)}% (Nominal: ${si303.percentualNominal.toStringAsFixed(2)}%)  │');
    print('│  SAE 305:  ${si305.percentualMinimo.toStringAsFixed(2)}% - ${si305.percentualMaximo.toStringAsFixed(2)}% (Nominal: ${si305.percentualNominal.toStringAsFixed(2)}%)  │');
    print('└─────────────────────────────────────────────────────┘');
    print('');
    
    print('✅ DIFERENÇA:');
    print('   Range SAE 305 é ${(si305.percentualMaximo - si305.percentualMinimo).toStringAsFixed(2)}%');
    print('   Range SAE 303 é ${(si303.percentualMaximo - si303.percentualMinimo).toStringAsFixed(2)}%');
    print('   SAE 305 tem ${(si305.percentualNominal - si303.percentualNominal).toStringAsFixed(2)}% a mais de Si nominal');
  }
  
  print('\n═══════════════════════════════════════════════════════');
  print('   RESULTADO FINAL');
  print('═══════════════════════════════════════════════════════');
  
  if (sae303 != null && sae305 != null) {
    var si303 = sae303.elementos.firstWhere((e) => e.simbolo == 'Si');
    var si305 = sae305.elementos.firstWhere((e) => e.simbolo == 'Si');
    
    bool todosCorretos = (si303.percentualMinimo == 10.50 && si303.percentualMaximo == 12.0) &&
                          (si305.percentualMinimo == 11.0 && si305.percentualMaximo == 13.0);
    
    if (todosCorretos) {
      print('');
      print('✅✅✅ VALIDAÇÃO COMPLETA - TODAS AS ESPECIFICAÇÕES CORRETAS! ✅✅✅');
      print('');
      print('   SAE 303: Si 10.50-12.0% ✓');
      print('   SAE 305: Si 11.0-13.0% ✓');
      print('');
    } else {
      print('');
      print('❌❌❌ ERRO - ESPECIFICAÇÕES INCORRETAS! ❌❌❌');
      print('');
    }
  }
  
  print('═══════════════════════════════════════════════════════\n');
}

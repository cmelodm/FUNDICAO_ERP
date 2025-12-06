import 'package:xml/xml.dart';
import '../models/nota_fiscal_model.dart';

class NFeParserService {
  /// Parse XML de NFe (Modelo 55) e extrai todos os dados
  static NotaFiscalModel? parseNFeXML(String xmlContent) {
    try {
      final document = XmlDocument.parse(xmlContent);
      
      // Buscar nó principal da NFe
      final nfeProc = document.findAllElements('nfeProc').firstOrNull;
      final nfe = nfeProc?.findElements('NFe').firstOrNull ?? 
                  document.findAllElements('NFe').firstOrNull;
      
      if (nfe == null) {
        throw Exception('XML inválido: Tag NFe não encontrada');
      }

      final infNFe = nfe.findElements('infNFe').first;
      final ide = infNFe.findElements('ide').first;
      final emit = infNFe.findElements('emit').first;
      final total = infNFe.findElements('total').first;
      final icmsTot = total.findElements('ICMSTot').first;

      // Extrair dados principais
      final chaveAcesso = infNFe.getAttribute('Id')?.replaceAll('NFe', '') ?? '';
      final numero = ide.findElements('nNF').first.innerText;
      final serie = ide.findElements('serie').first.innerText;
      final dataEmissao = _parseDate(ide.findElements('dhEmi').first.innerText);
      
      // Fornecedor
      final fornecedorCnpj = emit.findElements('CNPJ').firstOrNull?.innerText ?? '';
      final fornecedorNome = emit.findElements('xNome').first.innerText;

      // Itens
      final itens = <ItemNotaFiscal>[];
      for (var det in infNFe.findAllElements('det')) {
        final item = _parseItem(det);
        if (item != null) {
          itens.add(item);
        }
      }

      // Totais e impostos
      final valorProdutos = double.parse(icmsTot.findElements('vProd').first.innerText);
      final valorTotal = double.parse(icmsTot.findElements('vNF').first.innerText);
      
      final impostos = ImpostosNota(
        icms: double.parse(icmsTot.findElements('vICMS').firstOrNull?.innerText ?? '0'),
        ipi: double.parse(icmsTot.findElements('vIPI').firstOrNull?.innerText ?? '0'),
        pis: double.parse(icmsTot.findElements('vPIS').firstOrNull?.innerText ?? '0'),
        cofins: double.parse(icmsTot.findElements('vCOFINS').firstOrNull?.innerText ?? '0'),
      );

      return NotaFiscalModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        numero: numero,
        serie: serie,
        tipo: TipoNotaFiscal.entrada,
        dataEmissao: dataEmissao,
        dataEntrada: DateTime.now(),
        chaveAcesso: chaveAcesso,
        fornecedorId: '', // Será vinculado depois
        fornecedorNome: fornecedorNome,
        fornecedorCnpj: fornecedorCnpj,
        itens: itens,
        valorTotal: valorTotal,
        valorProdutos: valorProdutos,
        impostos: impostos,
        status: StatusNota.pendente,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse item individual da nota
  static ItemNotaFiscal? _parseItem(XmlElement det) {
    try {
      final prod = det.findElements('prod').first;
      final imposto = det.findElements('imposto').first;

      final codigo = prod.findElements('cProd').first.innerText;
      final descricao = prod.findElements('xProd').first.innerText;
      final ncm = prod.findElements('NCM').first.innerText;
      final cfop = prod.findElements('CFOP').first.innerText;
      final unidade = prod.findElements('uCom').first.innerText;
      final quantidade = double.parse(prod.findElements('qCom').first.innerText);
      final valorUnitario = double.parse(prod.findElements('vUnCom').first.innerText);
      final valorTotal = double.parse(prod.findElements('vProd').first.innerText);

      // Impostos do item
      final icmsItem = imposto.findAllElements('ICMS').firstOrNull;
      final ipiItem = imposto.findAllElements('IPI').firstOrNull;
      final pisItem = imposto.findAllElements('PIS').firstOrNull;
      final cofinsItem = imposto.findAllElements('COFINS').firstOrNull;

      final impostosItem = ImpostosItem(
        icms: _extractImpostoValue(icmsItem, 'vICMS'),
        ipi: _extractImpostoValue(ipiItem, 'vIPI'),
        pis: _extractImpostoValue(pisItem, 'vPIS'),
        cofins: _extractImpostoValue(cofinsItem, 'vCOFINS'),
      );

      return ItemNotaFiscal(
        codigo: codigo,
        descricao: descricao,
        ncm: ncm,
        cfop: cfop,
        unidade: unidade,
        quantidade: quantidade,
        valorUnitario: valorUnitario,
        valorTotal: valorTotal,
        impostos: impostosItem,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extrai valor de imposto do XML
  static double _extractImpostoValue(XmlElement? impostoElement, String tagName) {
    if (impostoElement == null) return 0.0;
    
    try {
      final value = impostoElement.findAllElements(tagName).firstOrNull?.innerText;
      return value != null ? double.parse(value) : 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Parse data do formato ISO para DateTime
  static DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Validar chave de acesso da NFe
  static bool validarChaveAcesso(String chave) {
    if (chave.length != 44) return false;
    
    // Validação simples de dígitos
    final regex = RegExp(r'^\d{44}$');
    return regex.hasMatch(chave);
  }

  /// Formatar chave de acesso para exibição
  static String formatarChaveAcesso(String chave) {
    if (chave.length != 44) return chave;
    
    return '${chave.substring(0, 4)} ${chave.substring(4, 8)} '
           '${chave.substring(8, 12)} ${chave.substring(12, 16)} '
           '${chave.substring(16, 20)} ${chave.substring(20, 24)} '
           '${chave.substring(24, 28)} ${chave.substring(28, 32)} '
           '${chave.substring(32, 36)} ${chave.substring(36, 40)} '
           '${chave.substring(40, 44)}';
  }
}

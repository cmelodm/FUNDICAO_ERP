import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:convert';
import '../models/material_model.dart';
import '../models/ordem_producao_model.dart';
import '../models/fornecedor_model.dart';
import '../models/inspecao_qualidade_model.dart';
import '../models/nota_fiscal_model.dart';
import '../models/analise_espectrometrica.dart';

class RelatorioService {
  /// Gerar relatório de materiais em PDF
  static Future<void> gerarRelatorioPDFMateriais(List<MaterialModel> materiais) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Relatório de Materiais', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Cabeçalho
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildCell('Código', bold: true),
                  _buildCell('Nome', bold: true),
                  _buildCell('Tipo', bold: true),
                  _buildCell('Estoque', bold: true),
                  _buildCell('Custo Un.', bold: true),
                ],
              ),
              // Dados
              ...materiais.map((m) => pw.TableRow(
                    children: [
                      _buildCell(m.codigo),
                      _buildCell(m.nome),
                      _buildCell(m.tipo),
                      _buildCell('${m.quantidadeEstoque.toStringAsFixed(2)} kg'),
                      _buildCell('R\$ ${m.custoUnitario.toStringAsFixed(2)}'),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Total de Materiais: ${materiais.length}'),
        ],
      ),
    );

    await _downloadPDF(pdf, 'relatorio_materiais.pdf');
  }

  /// Gerar relatório de produção em PDF
  static Future<void> gerarRelatorioPDFProducao(List<OrdemProducaoModel> ordens) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Relatório de Produção', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _buildCell('Número', bold: true),
                  _buildCell('Produto', bold: true),
                  _buildCell('Cliente', bold: true),
                  _buildCell('Status', bold: true),
                  _buildCell('Custo Est.', bold: true),
                ],
              ),
              ...ordens.map((o) => pw.TableRow(
                    children: [
                      _buildCell(o.numero),
                      _buildCell(o.produto),
                      _buildCell(o.cliente),
                      _buildCell(o.status),
                      _buildCell('R\$ ${o.custoEstimado.toStringAsFixed(2)}'),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Total de Ordens: ${ordens.length}'),
        ],
      ),
    );

    await _downloadPDF(pdf, 'relatorio_producao.pdf');
  }

  /// Exportar materiais para CSV
  static void exportarMateriaisCSV(List<MaterialModel> materiais) {
    final csv = StringBuffer();
    csv.writeln('Código;Nome;Tipo;Estoque (kg);Estoque Mínimo (kg);Custo Unitário (R\$);NCM;ICMS;IPI');

    for (var m in materiais) {
      csv.writeln(
        '${m.codigo};${m.nome};${m.tipo};${m.quantidadeEstoque};${m.estoqueMinimo};'
        '${m.custoUnitario};${m.ncm ?? ''};${m.icms ?? ''};${m.ipi ?? ''}',
      );
    }

    _downloadCSV(csv.toString(), 'materiais.csv');
  }

  /// Exportar produção para CSV
  static void exportarProducaoCSV(List<OrdemProducaoModel> ordens) {
    final csv = StringBuffer();
    csv.writeln('Número;Produto;Cliente;Status;Prioridade;Custo Estimado (R\$);Custo Real (R\$);Data Criação');

    for (var o in ordens) {
      csv.writeln(
        '${o.numero};${o.produto};${o.cliente};${o.status};${o.prioridade};'
        '${o.custoEstimado};${o.custoReal ?? ''};${o.dataCriacao}',
      );
    }

    _downloadCSV(csv.toString(), 'producao.csv');
  }

  /// Exportar fornecedores para CSV
  static void exportarFornecedoresCSV(List<FornecedorModel> fornecedores) {
    final csv = StringBuffer();
    csv.writeln('Nome;CNPJ;Contato;Telefone;Cidade;Estado;Qualidade;Preço;Prazo;Atendimento;Média');

    for (var f in fornecedores) {
      final media = (f.avaliacaoQualidade + f.avaliacaoPreco + f.avaliacaoPrazo + f.avaliacaoAtendimento) / 4;
      csv.writeln(
        '${f.nome};${f.cnpj};${f.email ?? ''};${f.telefone ?? ''};${f.cidade ?? ''};'
        '${f.estado ?? ''};${f.avaliacaoQualidade};${f.avaliacaoPreco};'
        '${f.avaliacaoPrazo};${f.avaliacaoAtendimento};${media.toStringAsFixed(2)}',
      );
    }

    _downloadCSV(csv.toString(), 'fornecedores.csv');
  }

  /// Exportar inspeções de qualidade para CSV
  static void exportarQualidadeCSV(List<InspecaoQualidadeModel> inspecoes) {
    final csv = StringBuffer();
    csv.writeln('Produto;OP;Tipo;Resultado;Inspetor;Data;Não Conformidades');

    for (var i in inspecoes) {
      csv.writeln(
        '${i.produto};${i.ordemProducaoId};${i.tipoTeste};${i.resultado};'
        '${i.inspetor ?? 'N/A'};${i.dataInspecao};${i.naoConformidades.length}',
      );
    }

    _downloadCSV(csv.toString(), 'qualidade.csv');
  }

  /// Exportar notas fiscais para CSV
  static void exportarNotasFiscaisCSV(List<NotaFiscalModel> notas) {
    final csv = StringBuffer();
    csv.writeln('Número;Série;Tipo;Fornecedor;CNPJ;Data Emissão;Valor Total (R\$);Status');

    for (var n in notas) {
      csv.writeln(
        '${n.numero};${n.serie};${n.tipo.nome};${n.fornecedorNome};'
        '${n.fornecedorCnpj};${n.dataEmissao};${n.valorTotal};${n.status.nome}',
      );
    }

    _downloadCSV(csv.toString(), 'notas_fiscais.csv');
  }

  /// Exportar análises espectrométricas para CSV
  static void exportarAnalisesCSV(List<AnaliseEspectrometrica> analises) {
    final csv = StringBuffer();
    csv.writeln('Liga;Código;Data;Status;Dentro Especificação;Operador');

    for (var a in analises) {
      csv.writeln(
        '${a.ligaNome};${a.ligaCodigo};${a.dataHoraAnalise};'
        '${a.status.nome};${a.dentroEspecificacao};${a.operadorNome}',
      );
    }

    _downloadCSV(csv.toString(), 'analises_espectrometricas.csv');
  }

  /// Helper: Construir célula de tabela PDF
  static pw.Widget _buildCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Helper: Download de arquivo PDF
  static Future<void> _downloadPDF(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  /// Helper: Download de arquivo CSV
  static void _downloadCSV(String content, String filename) {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}

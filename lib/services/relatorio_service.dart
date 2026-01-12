import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'dart:html' as html;
import '../models/material_model.dart';
import '../models/ordem_producao_model.dart';
import '../models/fornecedor_model.dart';
import '../models/inspecao_qualidade_model.dart';
import '../models/nota_fiscal_model.dart';
import '../models/analise_espectrometrica.dart';
import 'package:intl/intl.dart';

class RelatorioService {
  /// Gerar relatório de materiais em PDF
  static Future<void> gerarRelatorioPDFMateriais(List<MaterialModel> materiais) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RELATÓRIO DE MATERIAIS',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Foundry ERP - Sistema de Gestão de Fundição',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Data: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              // Cabeçalho
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue50),
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
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              'Total de Materiais: ${materiais.length}',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(
            'Foundry ERP © ${DateTime.now().year}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await _downloadPDF(pdf, 'Relatorio_Materiais_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf');
  }

  /// Gerar relatório de produção em PDF
  static Future<void> gerarRelatorioPDFProducao(List<OrdemProducaoModel> ordens) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RELATÓRIO DE PRODUÇÃO',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Foundry ERP - Sistema de Gestão de Fundição',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Data: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.orange50),
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
                      _buildCell(o.statusLabel),
                      _buildCell('R\$ ${o.custoEstimado.toStringAsFixed(2)}'),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              'Total de Ordens: ${ordens.length}',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text(
            'Foundry ERP © ${DateTime.now().year}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await _downloadPDF(pdf, 'Relatorio_Producao_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf');
  }

  /// Exportar materiais para CSV
  static void exportarMateriaisCSV(List<MaterialModel> materiais) {
    final csv = StringBuffer();
    // Adicionar BOM UTF-8 para Excel reconhecer acentuação
    csv.write('\uFEFF');
    csv.writeln('Código;Nome;Tipo;Estoque (kg);Estoque Mínimo (kg);Custo Unitário (R\$);NCM;ICMS;IPI');

    for (var m in materiais) {
      csv.writeln(
        '${m.codigo};${m.nome};${m.tipo};${m.quantidadeEstoque};${m.estoqueMinimo};'
        '${m.custoUnitario};${m.ncm ?? ''};${m.icms ?? ''};${m.ipi ?? ''}',
      );
    }

    _downloadCSV(csv.toString(), 'Materiais_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
  }

  /// Exportar produção para CSV
  static void exportarProducaoCSV(List<OrdemProducaoModel> ordens) {
    final csv = StringBuffer();
    // Adicionar BOM UTF-8 para Excel reconhecer acentuação
    csv.write('\uFEFF');
    csv.writeln('Número;Produto;Cliente;Status;Prioridade;Custo Estimado (R\$);Custo Real (R\$);Data Criação');

    for (var o in ordens) {
      csv.writeln(
        '${o.numero};${o.produto};${o.cliente};${o.statusLabel};${o.prioridade};'
        '${o.custoEstimado};${o.custoReal};${DateFormat('dd/MM/yyyy').format(o.dataCriacao)}',
      );
    }

    _downloadCSV(csv.toString(), 'Producao_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
  }

  /// Exportar fornecedores para CSV
  static void exportarFornecedoresCSV(List<FornecedorModel> fornecedores) {
    final csv = StringBuffer();
    // Adicionar BOM UTF-8
    csv.write('\uFEFF');
    csv.writeln('Nome;CNPJ;Contato;Telefone;Cidade;Estado;Qualidade;Preço;Prazo;Atendimento;Média');

    for (var f in fornecedores) {
      final media = (f.avaliacaoQualidade + f.avaliacaoPreco + f.avaliacaoPrazo + f.avaliacaoAtendimento) / 4;
      csv.writeln(
        '${f.nome};${f.cnpj};${f.email ?? ''};${f.telefone ?? ''};${f.cidade ?? ''};'
        '${f.estado ?? ''};${f.avaliacaoQualidade};${f.avaliacaoPreco};'
        '${f.avaliacaoPrazo};${f.avaliacaoAtendimento};${media.toStringAsFixed(2)}',
      );
    }

    _downloadCSV(csv.toString(), 'Fornecedores_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
  }

  /// Exportar inspeções de qualidade para CSV
  static void exportarQualidadeCSV(List<InspecaoQualidadeModel> inspecoes) {
    final csv = StringBuffer();
    // Adicionar BOM UTF-8
    csv.write('\uFEFF');
    csv.writeln('Produto;OP;Tipo;Resultado;Inspetor;Data;Não Conformidades');

    for (var i in inspecoes) {
      csv.writeln(
        '${i.produto};${i.ordemProducaoId};${i.tipoTeste};${i.resultado};'
        '${i.inspetor ?? 'N/A'};${DateFormat('dd/MM/yyyy HH:mm').format(i.dataInspecao)};${i.naoConformidades.length}',
      );
    }

    _downloadCSV(csv.toString(), 'Qualidade_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
  }

  /// Exportar notas fiscais para CSV
  static void exportarNotasFiscaisCSV(List<NotaFiscalModel> notas) {
    final csv = StringBuffer();
    // Adicionar BOM UTF-8
    csv.write('\uFEFF');
    csv.writeln('Número;Série;Tipo;Fornecedor;CNPJ;Data Emissão;Valor Total (R\$);Status');

    for (var n in notas) {
      csv.writeln(
        '${n.numero};${n.serie};${n.tipo.nome};${n.fornecedorNome};'
        '${n.fornecedorCnpj};${DateFormat('dd/MM/yyyy').format(n.dataEmissao)};${n.valorTotal};${n.status.nome}',
      );
    }

    _downloadCSV(csv.toString(), 'NotasFiscais_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
  }

  /// Exportar análises espectrométricas para CSV
  static void exportarAnalisesCSV(List<AnaliseEspectrometrica> analises) {
    final csv = StringBuffer();
    // Adicionar BOM UTF-8
    csv.write('\uFEFF');
    csv.writeln('Liga;Código;Data;Status;Dentro Especificação;Operador');

    for (var a in analises) {
      csv.writeln(
        '${a.ligaNome};${a.ligaCodigo};${DateFormat('dd/MM/yyyy HH:mm').format(a.dataHoraAnalise)};'
        '${a.status.nome};${a.dentroEspecificacao};${a.operadorNome}',
      );
    }

    _downloadCSV(csv.toString(), 'AnalisesEspectrometricas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv');
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

  /// Helper: Download REAL de arquivo PDF no navegador
  static Future<void> _downloadPDF(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();
    
    // Criar blob e forçar download no navegador
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';
    
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    html.Url.revokeObjectUrl(url);
  }

  /// Helper: Download REAL de arquivo CSV no navegador
  static void _downloadCSV(String content, String filename) {
    final bytes = utf8.encode(content);
    
    // Criar blob e forçar download no navegador
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';
    
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    
    html.Url.revokeObjectUrl(url);
  }
  
  /// Imprimir relatório de materiais em PDF
  static Future<void> imprimirPDFMateriais(List<MaterialModel> materiais) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RELATÓRIO DE MATERIAIS',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Foundry ERP - Sistema de Gestão de Fundição',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Data: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                children: [
                  _buildCell('Código', bold: true),
                  _buildCell('Nome', bold: true),
                  _buildCell('Tipo', bold: true),
                  _buildCell('Estoque', bold: true),
                  _buildCell('Custo Un.', bold: true),
                ],
              ),
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
        ],
      ),
    );

    await _openPDFInNewWindow(pdf);
  }
  
  /// Imprimir relatório de produção em PDF
  static Future<void> imprimirPDFProducao(List<OrdemProducaoModel> ordens) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RELATÓRIO DE PRODUÇÃO',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Foundry ERP - Sistema de Gestão de Fundição',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Data: ${dateFormat.format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.orange50),
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
                      _buildCell(o.statusLabel),
                      _buildCell('R\$ ${o.custoEstimado.toStringAsFixed(2)}'),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );

    await _openPDFInNewWindow(pdf);
  }
  
  /// Helper: Abrir PDF em nova janela para impressão
  static Future<void> _openPDFInNewWindow(pw.Document pdf) async {
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Abrir em nova janela
    html.window.open(url, '_blank');
    
    // Cleanup após 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      html.Url.revokeObjectUrl(url);
    });
  }
}

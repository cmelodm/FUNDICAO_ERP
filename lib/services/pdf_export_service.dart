import 'dart:io';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../services/correcao_avancada_service.dart';

/// Serviço para exportação de relatórios em PDF
class PdfExportService {
  
  /// Exporta relatório de correção avançada para PDF
  Future<void> exportarCorrecaoPDF(ResultadoCorrecaoCompleta resultado) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final now = DateTime.now();
    
    // Página 1: Cabeçalho e Resumo
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Cabeçalho
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RELATÓRIO DE CORREÇÃO DE LIGA',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Foundry ERP - Sistema de Correção Avançada',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Data: ${dateFormat.format(now)}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Status da Correção
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: resultado.todosElementosOk 
                  ? PdfColors.green50 
                  : PdfColors.orange50,
              border: pw.Border.all(
                color: resultado.todosElementosOk 
                    ? PdfColors.green 
                    : PdfColors.orange,
                width: 2,
              ),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 40,
                  height: 40,
                  decoration: pw.BoxDecoration(
                    color: resultado.todosElementosOk 
                        ? PdfColors.green 
                        : PdfColors.orange,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      resultado.todosElementosOk ? '✓' : '!',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Text(
                  resultado.todosElementosOk 
                      ? 'CORREÇÃO CONCLUÍDA COM SUCESSO'
                      : 'CORREÇÃO PARCIAL',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: resultado.todosElementosOk 
                        ? PdfColors.green900 
                        : PdfColors.orange900,
                  ),
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Resumo Executivo
          pw.Text(
            'RESUMO EXECUTIVO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          
          pw.SizedBox(height: 12),
          
          // Grid de estatísticas
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildStatBox(
                  'Iterações',
                  resultado.numeroIteracoes.toString(),
                  PdfColors.blue,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _buildStatBox(
                  'Correções',
                  resultado.correcoes.length.toString(),
                  PdfColors.purple,
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 12),
          
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildStatBox(
                  'Custo Total',
                  'R\$ ${resultado.custoTotal.toStringAsFixed(2)}',
                  PdfColors.green,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _buildStatBox(
                  'Incremento',
                  '${((resultado.massaTotalAdicionada / resultado.massaInicialForno) * 100).toStringAsFixed(1)}%',
                  PdfColors.orange,
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 20),
          
          // Dados do Forno
          pw.Text(
            'DADOS DO FORNO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          
          pw.SizedBox(height: 12),
          
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _buildTableRow('Massa Inicial', '${resultado.massaInicialForno.toStringAsFixed(2)} kg', true),
              _buildTableRow('Massa Adicionada', '${resultado.massaTotalAdicionada.toStringAsFixed(2)} kg', false),
              _buildTableRow('Massa Final', '${resultado.massaFinalForno.toStringAsFixed(2)} kg', true),
              _buildTableRow('Tempo de Processamento', '${resultado.tempoProcessamento.inMilliseconds} ms', false),
            ],
          ),
          
          pw.SizedBox(height: 20),
          
          // Correções Aplicadas
          pw.Text(
            'CORREÇÕES APLICADAS',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          
          pw.SizedBox(height: 12),
          
          // Tabela de correções
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Cabeçalho
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Tipo', isHeader: true),
                  _buildTableCell('Elemento', isHeader: true),
                  _buildTableCell('Concentração', isHeader: true),
                  _buildTableCell('Massa (kg)', isHeader: true),
                  _buildTableCell('Custo (R\$)', isHeader: true),
                ],
              ),
              
              // Dados das correções
              ...resultado.correcoes.map((correcao) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(
                      correcao.tipoCorrecao.toString().split('.').last.toUpperCase(),
                    ),
                    _buildTableCell('${correcao.simbolo} - ${correcao.nome}'),
                    _buildTableCell(
                      '${correcao.concentracaoInicial.toStringAsFixed(2)}% → '
                      '${correcao.concentracaoFinal.toStringAsFixed(2)}%',
                    ),
                    _buildTableCell(correcao.massaMaterialAdicionado.toStringAsFixed(2)),
                    _buildTableCell(correcao.custoCorrecao.toStringAsFixed(2)),
                  ],
                );
              }).toList(),
            ],
          ),
          
          pw.SizedBox(height: 20),
          
          // Avisos (se houver)
          if (resultado.avisos.isNotEmpty) ...[
            pw.Text(
              'AVISOS',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange900,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange50,
                border: pw.Border.all(color: PdfColors.orange),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: resultado.avisos.map((aviso) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text('• $aviso'),
                  );
                }).toList(),
              ),
            ),
          ],
          
          // Rodapé
          pw.SizedBox(height: 40),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Foundry ERP - Sistema de Correção Avançada',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Text(
                'Página 1',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
    
    // Salvar PDF (Web)
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'Correcao_Liga_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
  
  /// Constrói uma caixa de estatística
  pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói uma linha de tabela
  pw.TableRow _buildTableRow(String label, String value, bool isEven) {
    return pw.TableRow(
      decoration: isEven 
          ? const pw.BoxDecoration(color: PdfColors.grey50) 
          : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }
  
  /// Constrói uma célula de tabela
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}

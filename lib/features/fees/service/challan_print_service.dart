import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../data/models/challan_model.dart';
import '../../../data/models/student_model.dart';
import 'challan_service.dart';

// Custom font setup for Unicode support
final pw.Font _customFont = pw.Font.helvetica();
final pw.Font _customFontBold = pw.Font.helveticaBold();

class ChallanPrintService {
  static Future<void> printChallan(
    String challanId,
    BuildContext context,
  ) async {
    try {
      // Fetch challan data with student details
      final challanData = await ChallanService.fetchChallanWithStudent(
        challanId,
      );

      if (challanData == null) {
        throw Exception('Challan not found');
      }

      // Generate PDF
      final pdf = await _generateChallanPDF(challanData);

      // Show PDF preview dialog
      await _showPdfPreview(context, pdf, challanId);
    } catch (e) {
      print('Error printing challan: $e');
      rethrow;
    }
  }

  static Future<void> _showPdfPreview(
    BuildContext context,
    pw.Document pdf,
    String challanId,
  ) async {
    final pdfBytes = await pdf.save();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Challan Preview - $challanId',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // PDF Preview
                Expanded(
                  child: PdfPreview(
                    build: (format) => pdf.save(),
                    allowPrinting: true,
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    initialPageFormat: PdfPageFormat.a4,
                    pdfFileName: 'Challan_$challanId.pdf',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<pw.Document> _generateChallanPDF(
    Map<String, dynamic> challanData,
  ) async {
    final pdf = pw.Document();

    // Extract data
    final challan = ChallanModel.fromMap(challanData);
    final student = challanData['student'] != null
        ? StudentModel.fromJson(challanData['student'])
        : null;

    // Calculate dates
    final issueDate = challan.dateGenerated;
    final dueDate = challan.dateGenerated.add(const Duration(days: 30));
    final voucherValidUpto = dueDate.add(const Duration(days: 10));

    // Build all copies
    final schoolCopy = await _buildChallanCopy(
      'SCHOOL COPY',
      challan,
      student,
      issueDate,
      dueDate,
      voucherValidUpto,
    );
    final bankCopy = await _buildChallanCopy(
      'BANK COPY',
      challan,
      student,
      issueDate,
      dueDate,
      voucherValidUpto,
    );
    final studentCopy = await _buildChallanCopy(
      'STUDENT COPY',
      challan,
      student,
      issueDate,
      dueDate,
      voucherValidUpto,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Row(
              children: [
                // School Copy
                schoolCopy,
                // Dotted divider
                pw.Container(
                  width: 1,
                  height: double.infinity,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                  child: pw.Column(
                    children: List.generate(
                      100,
                      (index) => pw.Container(
                        width: 1,
                        height: 2,
                        color: PdfColors.grey,
                        margin: const pw.EdgeInsets.symmetric(vertical: 1),
                      ),
                    ),
                  ),
                ),
                // Bank Copy
                bankCopy,
                // Dotted divider
                pw.Container(
                  width: 1,
                  height: double.infinity,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                  child: pw.Column(
                    children: List.generate(
                      100,
                      (index) => pw.Container(
                        width: 1,
                        height: 2,
                        color: PdfColors.grey,
                        margin: const pw.EdgeInsets.symmetric(vertical: 1),
                      ),
                    ),
                  ),
                ),
                // Student Copy
                studentCopy,
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static Future<pw.Widget> _buildChallanCopy(
    String copyType,
    ChallanModel challan,
    StudentModel? student,
    DateTime issueDate,
    DateTime dueDate,
    DateTime voucherValidUpto,
  ) async {
    // Load school logo - handle missing logo gracefully
    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/Logo.jpeg');
      if (logoData.buffer.lengthInBytes > 0) {
        logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
      }
    } catch (e) {
      print('Logo loading error: $e');
      // Logo not found or empty, use placeholder
      logoImage = null;
    }

    return pw.Container(
      width: 180, // Fixed width for each copy
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header with logo and school info
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo - taller to cover title and address height
              pw.Container(
                width: 35,
                height:
                    45, // Increased height to cover both title and address lines
                child: logoImage != null
                    ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                    : pw.Container(
                        color: PdfColors.blue,
                        child: pw.Center(
                          child: pw.Text(
                            'LOGO',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 6,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              pw.SizedBox(width: 8),
              // School info
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'BRIGHT MODEL SCHOOL',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        font: _customFontBold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'Zulfiqar Bagh Road, Ghalib Nagar, Larkano',
                      style: const pw.TextStyle(fontSize: 5),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'Ph: 074-4059330 Mob: 0301-3481610',
                      style: const pw.TextStyle(fontSize: 5),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Container(height: 1, color: PdfColors.black),
                  ],
                ),
              ),
            ],
          ),

          // Copy Type (right aligned)
          pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              copyType,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                font: _customFontBold,
              ),
            ),
          ),

          pw.SizedBox(height: 12),

          // Student Info Block
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'A/C No: ${student?.grNo ?? challan.studentId}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'GR#: ${student?.grNo ?? challan.studentId}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Name: ${student?.studentName ?? challan.studentName ?? 'N/A'}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Father\'s Name: ${student?.fatherName ?? 'N/A'}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Class: ${student?.className ?? 'N/A'}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Section: ${student?.section ?? 'N/A'}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 12),

          // Fees Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'FEES DETAIL',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                        font: _customFontBold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'AMOUNT',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                        font: _customFontBold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'MONTH FEE/LATE',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                        font: _customFontBold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Fee rows
              ..._buildFeeRows(challan),
              // Total row
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'PKR ${challan.amount.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('', style: const pw.TextStyle(fontSize: 8)),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 12),

          // Footer Information
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Paid Fee will not be refunded.',
                  style: const pw.TextStyle(fontSize: 7),
                ),
                pw.Text(
                  'Rs. 100 Late Fee per month will be charged after due date.',
                  style: const pw.TextStyle(fontSize: 7),
                ),
                pw.Text(
                  'Rs. 50 will be charged if voucher is lost or duplicate.',
                  style: const pw.TextStyle(fontSize: 7),
                ),
                pw.Text(
                  'This voucher will not be valid after validation date.',
                  style: const pw.TextStyle(fontSize: 7),
                ),
                pw.Text(
                  'Note: Kindly do not accept any voucher if correction or overwriting is found.',
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // Signatures
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Text('Bank Stamp', style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 20),
                  pw.Container(width: 60, height: 1, color: PdfColors.black),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text(
                    'Authorized Signature',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Container(width: 60, height: 1, color: PdfColors.black),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 8),

          // Issue and Due dates
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Issue Date: ${DateFormat('dd/MM/yyyy').format(issueDate)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Text(
                      'Due Date: ${DateFormat('dd/MM/yyyy').format(dueDate)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    'Valid Upto: ${DateFormat('dd/MM/yyyy').format(voucherValidUpto)}',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.TableRow> _buildFeeRows(ChallanModel challan) {
    final rows = <pw.TableRow>[];

    switch (challan.feesType.toLowerCase()) {
      case 'admission':
        rows.add(
          _buildFeeRow(
            'Admission',
            challan.amount.toStringAsFixed(0),
            challan.month ?? '—',
          ),
        );
        break;
      case 'monthly':
        rows.add(
          _buildFeeRow(
            'Monthly',
            challan.amount.toStringAsFixed(0),
            challan.month ?? '—',
          ),
        );
        break;
      case 'exam':
        rows.add(
          _buildFeeRow(
            'Examination',
            challan.amount.toStringAsFixed(0),
            challan.examDetails ?? '—',
          ),
        );
        break;
      case 'misc':
        rows.add(
          _buildFeeRow(
            'Misc / Other',
            challan.amount.toStringAsFixed(0),
            challan.feeDetails ?? '—',
          ),
        );
        break;
      default:
        rows.add(
          _buildFeeRow(
            'Fee',
            challan.amount.toStringAsFixed(0),
            challan.feesType,
          ),
        );
    }

    // Add empty rows to fill table (typically 3-4 rows total)
    while (rows.length < 3) {
      rows.add(_buildFeeRow('', '', ''));
    }

    return rows;
  }

  static pw.TableRow _buildFeeRow(String detail, String amount, String month) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(detail, style: const pw.TextStyle(fontSize: 9)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            amount,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            month,
            style: const pw.TextStyle(fontSize: 9),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }
}

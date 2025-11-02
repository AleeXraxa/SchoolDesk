import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../data/models/challan_model.dart';
import '../../../data/models/student_model.dart';
import '../../../data/database_service.dart';
import 'challan_service.dart';
import 'combined_challan_service.dart';

// Custom font setup for Unicode support
final pw.Font _customFont = pw.Font.helvetica();
final pw.Font _customFontBold = pw.Font.helveticaBold();

class ChallanPrintService {
  static Future<void> printChallan(
    String challanId,
    BuildContext context,
  ) async {
    try {
      // First try to fetch from regular challans table
      var challanData = await ChallanService.fetchChallanWithStudent(challanId);

      // If not found in regular challans, try combined challans
      if (challanData == null) {
        print(
          'Challan not found in regular challans, trying combined challans...',
        );
        challanData = await _fetchCombinedChallanWithStudent(challanId);
      }

      if (challanData == null) {
        throw Exception('Challan not found in any table');
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

  static Future<Map<String, dynamic>?> _fetchCombinedChallanWithStudent(
    String challanId,
  ) async {
    try {
      final db = await DatabaseService.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
          SELECT mc.*, s.*
          FROM multiple_challans mc
          LEFT JOIN students s ON mc.student_id = s.id
          WHERE mc.id = ?
          LIMIT 1
        ''',
        [int.parse(challanId)],
      );

      if (maps.isNotEmpty) {
        final map = maps.first;
        // Convert student data to StudentModel format
        final studentData = {
          'id': map['id'],
          'roll_no': map['roll_no'],
          'gr_no': map['gr_no'],
          'student_name': map['student_name'],
          'father_name': map['father_name'],
          'caste': map['caste'],
          'place_of_birth': map['place_of_birth'],
          'dob_figures': map['dob_figures'],
          'dob_words': map['dob_words'],
          'gender': map['gender'],
          'religion': map['religion'],
          'father_contact': map['father_contact'],
          'mother_contact': map['mother_contact'],
          'address': map['address'],
          'admission_date': map['admission_date'],
          'class_id': map['class_id'],
          'class_name': map['class_name'],
          'section': map['section'],
          'admission_fees': map['admission_fees'],
          'monthly_fees': map['monthly_fees'],
          'status': map['status'],
          'is_monthly_fee_synced': map['is_monthly_fee_synced'],
        };

        // Parse the selected_fees_details to get individual fee amounts
        final selectedFeesDetails = map['selected_fees_details'];
        double admissionAmount = 0.0;
        double monthlyAmount = 0.0;
        double examAmount = 0.0;
        double miscAmount = 0.0;

        if (selectedFeesDetails != null && selectedFeesDetails is String) {
          try {
            final feesList = jsonDecode(selectedFeesDetails) as List<dynamic>;
            for (final fee in feesList) {
              final type = fee['type'] as String?;
              final amount = (fee['amount'] as num?)?.toDouble() ?? 0.0;

              switch (type?.toLowerCase()) {
                case 'admission':
                  admissionAmount += amount;
                  break;
                case 'monthly':
                  monthlyAmount += amount;
                  break;
                case 'exam':
                  examAmount += amount;
                  break;
                case 'misc':
                  miscAmount += amount;
                  break;
              }
            }
          } catch (e) {
            print('Error parsing fees details: $e');
          }
        }

        // Create a challan-like structure for combined challans with individual fee breakdowns
        final challanData = {
          'challan_id': 'CC-${map['id']}', // Combined Challan prefix
          'student_id': map['student_id'].toString(),
          'fees_type': 'Combined',
          'amount': (map['total_amount'] as num?)?.toDouble() ?? 0.0,
          'status': map['status'] ?? 'Pending',
          'date_generated':
              map['generated_date'] ?? DateTime.now().toIso8601String(),
          'month': map['month'] ?? '',
          'fee_details': 'Combined Challan - Multiple Fees',
          // Add individual fee amounts for PDF generation
          'admission_amount': admissionAmount,
          'monthly_amount': monthlyAmount,
          'exam_amount': examAmount,
          'misc_amount': miscAmount,
        };

        print('Final challanData with amounts:');
        print('admission_amount: ${challanData['admission_amount']}');
        print('monthly_amount: ${challanData['monthly_amount']}');
        print('exam_amount: ${challanData['exam_amount']}');
        print('misc_amount: ${challanData['misc_amount']}');

        print('Combined challan data created:');
        print(
          'Admission: $admissionAmount, Monthly: $monthlyAmount, Exam: $examAmount, Misc: $miscAmount',
        );

        return {...challanData, 'student': studentData};
      }
      return null;
    } catch (e) {
      print('Error fetching combined challan with student: $e');
      return null;
    }
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

    // Store the original challanData for fee breakdown access
    final originalChallanData = challanData;

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
      originalChallanData,
    );
    final bankCopy = await _buildChallanCopy(
      'BANK COPY',
      challan,
      student,
      issueDate,
      dueDate,
      voucherValidUpto,
      originalChallanData,
    );
    final studentCopy = await _buildChallanCopy(
      'STUDENT COPY',
      challan,
      student,
      issueDate,
      dueDate,
      voucherValidUpto,
      originalChallanData,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(5),
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Row(
              children: [
                // School Copy
                pw.Expanded(child: schoolCopy),
                // Dotted divider
                pw.Container(
                  width: 1,
                  height: double.infinity,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 2),
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
                pw.Expanded(child: bankCopy),
                // Dotted divider
                pw.Container(
                  width: 1,
                  height: double.infinity,
                  margin: const pw.EdgeInsets.symmetric(horizontal: 2),
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
                pw.Expanded(child: studentCopy),
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
    Map<String, dynamic>? originalChallanData,
  ) async {
    // Load school logo - handle missing logo gracefully
    pw.MemoryImage? schoolLogoImage;
    pw.MemoryImage? bankLogoImage;

    try {
      final schoolLogoData = await rootBundle.load('assets/images/Logo.jpeg');
      if (schoolLogoData.buffer.lengthInBytes > 0) {
        schoolLogoImage = pw.MemoryImage(schoolLogoData.buffer.asUint8List());
      }
    } catch (e) {
      print('School logo loading error: $e');
      schoolLogoImage = null;
    }

    try {
      final bankLogoData = await rootBundle.load(
        'assets/images/bank logo.jpeg',
      );
      if (bankLogoData.buffer.lengthInBytes > 0) {
        bankLogoImage = pw.MemoryImage(bankLogoData.buffer.asUint8List());
      }
    } catch (e) {
      print('Bank logo loading error: $e');
      bankLogoImage = null;
    }

    return pw.Container(
      width: 180, // Fixed width for each copy
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Copy Type at the top (centered)
          pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(
              copyType,
              style: pw.TextStyle(
                fontSize: 5,
                fontWeight: pw.FontWeight.bold,
                font: _customFontBold,
              ),
            ),
          ),

          // Header with logo and school info
          pw.Column(
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo - taller to cover title and address height
                  pw.Container(
                    width: 35,
                    height:
                        45, // Increased height to cover both title and address lines
                    child: schoolLogoImage != null
                        ? pw.Image(schoolLogoImage, fit: pw.BoxFit.contain)
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
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            font: _customFontBold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Zulfiqar Bagh Road, Ghalib Nagar, Larkano',
                          style: const pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Ph: 074-4059330 Mob: 0301-3481610',
                          style: const pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              // Full-width horizontal divider line
              pw.Container(height: 0.3, color: PdfColors.black),
              pw.SizedBox(height: 6),
              // Bank details section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Bank logo
                  pw.Container(
                    width: 35,
                    height: 45,
                    child: bankLogoImage != null
                        ? pw.Image(bankLogoImage, fit: pw.BoxFit.contain)
                        : pw.Container(
                            color: PdfColors.blue,
                            child: pw.Center(
                              child: pw.Text(
                                'BANK',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 6,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                  pw.SizedBox(width: 6),
                  // Bank info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'AL-BARAK BANK (PAKISTAN) LTD.',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            font: _customFontBold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'Bank Square Road, Larkano',
                          style: const pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          'A/C # 0102-425314-014',
                          style: const pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Bank section divider
              pw.Container(height: 0.3, color: PdfColors.black),
            ],
          ),

          pw.SizedBox(height: 1),

          // Student Info Block
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              children: [
                // First row: A/C No and GR# on same line
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Roll No: ',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.TextSpan(
                              text: '${student?.grNo ?? challan.studentId}',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'GR#: ',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.TextSpan(
                              text: '${student?.grNo ?? challan.studentId}',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
                pw.SizedBox(height: 4),
                // Second row: Name on full width
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Name: ',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.TextSpan(
                          text:
                              '${student?.studentName ?? challan.studentName ?? 'N/A'}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
                pw.SizedBox(height: 4),
                // Third row: Father's Name on full width
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Father\'s Name: ',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.TextSpan(
                          text: '${student?.fatherName ?? 'N/A'}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
                pw.SizedBox(height: 4),
                // Fourth row: Class and Section on same line
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Class: ',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.TextSpan(
                              text: '${student?.className ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.RichText(
                        text: pw.TextSpan(
                          children: [
                            pw.TextSpan(
                              text: 'Section: ',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.TextSpan(
                              text: '${student?.section ?? 'N/A'}',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
              ],
            ),
          ),

          pw.SizedBox(height: 1),

          // Fees Table - Exact layout as specified
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.8),
              1: const pw.FlexColumnWidth(1.2),
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
                        fontSize: 6,
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
                        fontSize: 6,
                        font: _customFontBold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'MONTH',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 6,
                        font: _customFontBold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Fee rows - dynamically populated based on challan type
              ..._buildDynamicFeeRows(challan, originalChallanData),
            ],
          ),

          pw.SizedBox(height: 1),

          // Note Section
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Note:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 8,
                    font: _customFontBold,
                  ),
                ),
                pw.Container(height: 0.3, color: PdfColors.black),
                pw.SizedBox(height: 16),
                pw.Container(height: 0.3, color: PdfColors.black),
              ],
            ),
          ),

          // Total Amount Section
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      'Total Amount:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        font: _customFontBold,
                      ),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      'PKR ${challan.amount.toStringAsFixed(0)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        font: _customFontBold,
                      ),
                    ),
                  ],
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text(
                      'Within Due Date:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      'PKR ${challan.amount.toStringAsFixed(0)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text(
                      'After Due Date:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      'PKR ${(challan.amount + 100).toStringAsFixed(0)}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text(
                      'Due Date:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      DateFormat('dd/MM/yyyy').format(dueDate),
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Text(
                      'Voucher Valid Upto:',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      DateFormat('dd/MM/yyyy').format(voucherValidUpto),
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
                pw.Container(height: 0.2, color: PdfColors.black),
              ],
            ),
          ),

          pw.SizedBox(height: 1),

          // Bank Stamp and Signature Section
          pw.Container(
            width: double.infinity,
            height: 70,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Bank Stamp and Signature',
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 1),

          // Terms and Conditions
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Paid Fees will not be refunded.',
                  style: pw.TextStyle(
                    fontSize: 6,
                    fontWeight: pw.FontWeight.bold,
                    font: _customFontBold,
                  ),
                ),
                pw.Text(
                  'Rs. 100 Late fee per month will be charged after due date.',
                  style: pw.TextStyle(
                    fontSize: 6,
                    fontWeight: pw.FontWeight.bold,
                    font: _customFontBold,
                  ),
                ),
                pw.Text(
                  'Rs. 50 will be charged in case Voucher is lost or duplicate.',
                  style: pw.TextStyle(
                    fontSize: 6,
                    fontWeight: pw.FontWeight.bold,
                    font: _customFontBold,
                  ),
                ),
                pw.Text(
                  'This voucher will not be valid after validation date.',
                  style: pw.TextStyle(
                    fontSize: 6,
                    fontWeight: pw.FontWeight.bold,
                    font: _customFontBold,
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue200,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                  child: pw.Text(
                    'Note: Kindly do not accept any Voucher if correction or over writing is found.',
                    style: pw.TextStyle(
                      fontSize: 6,
                      fontWeight: pw.FontWeight.bold,
                      font: _customFontBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.TableRow> _buildDynamicFeeRows(
    ChallanModel challan, [
    Map<String, dynamic>? originalData,
  ]) {
    final rows = <pw.TableRow>[];

    // Always show 5 rows: Monthly, Admission, Examination, Certificate, Other Fees
    // Fill in the appropriate row based on challan type
    final feeRows = [
      {'label': 'Monthly', 'amount': '', 'month': ''},
      {'label': 'Admission', 'amount': '', 'month': ''},
      {'label': 'Examination', 'amount': '', 'month': ''},
      {'label': 'Certificate', 'amount': '', 'month': ''},
      {'label': 'Other Fees', 'amount': '', 'month': ''},
    ];

    // Check if this is a combined challan (has individual amounts)
    // Use originalData if available (contains the parsed amounts), otherwise fall back to challan.toMap()
    final challanData = originalData ?? challan.toMap();
    final admissionAmount = challanData['admission_amount'] as double?;
    final monthlyAmount = challanData['monthly_amount'] as double?;
    final examAmount = challanData['exam_amount'] as double?;
    final miscAmount = challanData['misc_amount'] as double?;

    print('Challan data keys: ${challanData.keys.toList()}');
    print('Admission amount from challanData: $admissionAmount');
    print('Monthly amount from challanData: $monthlyAmount');
    print('Exam amount from challanData: $examAmount');
    print('Misc amount from challanData: $miscAmount');

    print('Building fee rows - checking amounts:');
    print(
      'Admission: $admissionAmount, Monthly: $monthlyAmount, Exam: $examAmount, Misc: $miscAmount',
    );

    if (admissionAmount != null ||
        monthlyAmount != null ||
        examAmount != null ||
        miscAmount != null) {
      // This is a combined challan - show individual amounts
      feeRows[0]['amount'] = monthlyAmount != null && monthlyAmount > 0
          ? monthlyAmount.toStringAsFixed(0)
          : '';
      feeRows[0]['month'] = challan.month ?? '';
      feeRows[1]['amount'] = admissionAmount != null && admissionAmount > 0
          ? admissionAmount.toStringAsFixed(0)
          : '';
      feeRows[1]['month'] = challan.month ?? '';
      feeRows[2]['amount'] = examAmount != null && examAmount > 0
          ? examAmount.toStringAsFixed(0)
          : '';
      feeRows[2]['month'] = challan.month ?? '';
      feeRows[4]['amount'] = miscAmount != null && miscAmount > 0
          ? miscAmount.toStringAsFixed(0)
          : '';
      feeRows[4]['month'] = challan.month ?? '';
    } else {
      // Regular single-type challan
      switch (challan.feesType.toLowerCase()) {
        case 'admission':
          feeRows[1]['amount'] = challan.amount.toStringAsFixed(0);
          feeRows[1]['month'] = challan.month ?? '';
          break;
        case 'monthly':
          feeRows[0]['amount'] = challan.amount.toStringAsFixed(0);
          feeRows[0]['month'] = challan.month ?? '';
          break;
        case 'exam':
          feeRows[2]['amount'] = challan.amount.toStringAsFixed(0);
          feeRows[2]['month'] = challan.examDetails ?? '';
          break;
        case 'misc':
          feeRows[4]['amount'] = challan.amount.toStringAsFixed(0);
          feeRows[4]['month'] = challan.feeDetails ?? '';
          break;
        default:
          feeRows[4]['amount'] = challan.amount.toStringAsFixed(0);
          feeRows[4]['month'] = challan.feesType;
      }
    }

    // Create TableRow for each fee row
    for (final feeRow in feeRows) {
      rows.add(
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                feeRow['label'] as String,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                feeRow['amount'] as String,
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                feeRow['month'] as String,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
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

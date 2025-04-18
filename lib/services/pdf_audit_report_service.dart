import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PdfAuditReportService {
  final String appVersion;
  final Map<String, dynamic> threatLogs;
  final Map<String, dynamic> policyCompliance;
  final Map<String, dynamic> deviceInfo;

  PdfAuditReportService({
    required this.appVersion,
    required this.threatLogs,
    required this.policyCompliance,
    required this.deviceInfo,
  });

  Future<String> generateAuditReport() async {
    final pdf = pw.Document();

    // Define styles
    final titleStyle = pw.TextStyle(
      fontSize: 24,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final headerStyle = pw.TextStyle(
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue900,
    );
    final contentStyle = pw.TextStyle(fontSize: 12);

    // Generate timestamp
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Create PDF document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text(
            'Generated: $timestamp',
            style: contentStyle,
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'SecureVault - Page ${context.pageNumber} of ${context.pagesCount}',
            style: contentStyle,
          ),
        ),
        build: (context) => [
          // Title
          pw.Text(
            'SecureVault Compliance Audit Report — Confidential',
            style: titleStyle,
          ),
          pw.SizedBox(height: 20),

          // Metadata
          pw.Text('App Version: $appVersion', style: contentStyle),
          pw.Text('Generated: $timestamp', style: contentStyle),
          pw.SizedBox(height: 20),

          // Threat Logs Section
          pw.Text('Threat Logs', style: headerStyle),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Timestamp', style: headerStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Threat Type', style: headerStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Description', style: headerStyle),
                  ),
                ],
              ),
              ...threatLogs.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.value['timestamp']?.toString() ?? '',
                            style: contentStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.value['type']?.toString() ?? '',
                            style: contentStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                            entry.value['description']?.toString() ?? '',
                            style: contentStyle),
                      ),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 20),

          // Policy Compliance Section
          pw.Text('Policy Compliance', style: headerStyle),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Policy', style: headerStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Status', style: headerStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Details', style: headerStyle),
                  ),
                ],
              ),
              ...policyCompliance.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.key, style: contentStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.value['status']?.toString() ?? '',
                            style: contentStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.value['details']?.toString() ?? '',
                            style: contentStyle),
                      ),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 20),

          // Device Info Section
          pw.Text('Device Information', style: headerStyle),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Attribute', style: headerStyle),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Value', style: headerStyle),
                  ),
                ],
              ),
              ...deviceInfo.entries.map((entry) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.key, style: contentStyle),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(entry.value.toString(), style: contentStyle),
                      ),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 20),

          // Digital Signature Placeholder
          pw.Text('Digital Signature', style: headerStyle),
          pw.SizedBox(height: 10),
          pw.Container(
            height: 100,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            child: pw.Center(
              child: pw.Text(
                'Digital Signature Placeholder',
                style: contentStyle.copyWith(fontStyle: pw.FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );

    // Save the PDF
    final outputDir = await getApplicationDocumentsDirectory();
    final file = File(
        '${outputDir.path}/securevault_audit_report_${timestamp.replaceAll(':', '-')}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../data/models/beneficiary_designation_model.dart';

/// Service de génération de PDF pour la désignation de bénéficiaire
class PdfGeneratorService {
  static Future<String> generateBeneficiaryDesignationPdf(
    BeneficiaryDesignation designation,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateTimeFormat = DateFormat('dd/MM/yyyy à HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // En-tête
          _buildHeader(),
          pw.SizedBox(height: 30),

          // Titre
          pw.Center(
            child: pw.Text(
              'DÉSIGNATION DE BÉNÉFICIAIRE',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'En cas de décès - Contrat de retraite',
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(height: 30),

          // Informations du contrat
          _buildSection(
            'CONTRAT CONCERNÉ',
            [
              _buildInfoRow('Nom du contrat', designation.contractName),
              _buildInfoRow('Numéro du contrat', designation.contractId),
              _buildInfoRow('Date de la désignation', dateFormat.format(designation.createdAt)),
            ],
          ),
          pw.SizedBox(height: 20),

          // Type de désignation
          _buildSection(
            'TYPE DE DÉSIGNATION',
            [
              _buildInfoRow(
                'Mode choisi',
                _getDesignationTypeLabel(designation.designationType),
              ),
              if (designation.designationType == DesignationType.nominative)
                _buildInfoRow(
                  'Répartition',
                  designation.distributionMode == DistributionMode.equalParts
                      ? 'Parts égales'
                      : 'Pourcentages personnalisés',
                ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Clause bénéficiaire
          _buildSection(
            'CLAUSE BÉNÉFICIAIRE',
            [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  designation.clauseText,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Détail des bénéficiaires (si nominatif)
          if (designation.designationType == DesignationType.nominative) ...[
            _buildSection(
              'DÉTAIL DES BÉNÉFICIAIRES',
              _buildBeneficiariesTable(designation, dateFormat),
            ),
            pw.SizedBox(height: 20),
          ],

          // Mention légale
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MENTIONS LÉGALES',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Cette désignation annule et remplace toute désignation de bénéficiaire antérieure relative au contrat mentionné ci-dessus. '
                  'En cas de prédécès de l\'ensemble des bénéficiaires désignés, le capital sera versé aux héritiers légaux du souscripteur. '
                  'Le souscripteur peut à tout moment modifier cette désignation par avenant.',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Signature électronique
          _buildSection(
            'SIGNATURE ÉLECTRONIQUE',
            [
              _buildInfoRow(
                'Date et heure de signature',
                designation.signedAt != null
                    ? dateTimeFormat.format(designation.signedAt!)
                    : 'Non signé',
              ),
              _buildInfoRow(
                'Référence de signature',
                designation.signatureReference ?? 'N/A',
              ),
              _buildInfoRow(
                'Méthode d\'authentification',
                'Code OTP par SMS',
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green700),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 20,
                      height: 20,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green700,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '✓',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Text(
                        'Document signé électroniquement conformément au règlement eIDAS et à l\'article 1367 du Code civil.',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.green900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    // Sauvegarder le PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/designation_beneficiaire_${designation.id}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'GAN ASSURANCES',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#003D7A'),
              ),
            ),
            pw.Text(
              'Épargne & Retraite',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FFB81C'),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'DOCUMENT OFFICIEL',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#5C3D00'),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#003D7A'),
            borderRadius: pw.BorderRadius.circular(2),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        ...children,
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildBeneficiariesTable(
    BeneficiaryDesignation designation,
    DateFormat dateFormat,
  ) {
    final widgets = <pw.Widget>[];

    for (final entry in designation.beneficiariesByRank.entries) {
      final rank = entry.key;
      final beneficiaries = entry.value;

      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey800,
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Text(
                      'Rang $rank${rank > 1 ? " (à défaut)" : ""}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // En-tête
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Nom Prénom', isHeader: true),
                      _buildTableCell('Date de naissance', isHeader: true),
                      _buildTableCell('Lien', isHeader: true),
                      _buildTableCell('Part', isHeader: true),
                      _buildTableCell('Propriété', isHeader: true),
                    ],
                  ),
                  // Données
                  ...beneficiaries.map((b) => pw.TableRow(
                        children: [
                          _buildTableCell(b.fullName),
                          _buildTableCell(dateFormat.format(b.birthDate)),
                          _buildTableCell(b.relationshipLabel),
                          _buildTableCell('${b.percentage.toStringAsFixed(0)}%'),
                          _buildTableCell(b.dismembermentLabel),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'GAN Assurances - Document généré automatiquement',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} / ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _getDesignationTypeLabel(DesignationType type) {
    switch (type) {
      case DesignationType.nominative:
        return 'Bénéficiaires nominatifs';
      case DesignationType.standardClause:
        return 'Clause type';
      case DesignationType.freeClause:
        return 'Clause libre';
    }
  }
}

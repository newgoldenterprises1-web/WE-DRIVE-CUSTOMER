import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TripInvoiceService {
  static Future<void> downloadInvoice({
    required String bookingId,
    required String vehicleType,
    required String pickupLocation,
    required String dropLocation,
    required double fare,
    required String driverName,
    String paymentStatus = 'pending',
    String paymentMethod = 'Cash',
    DateTime? completedAt,
  }) async {
    final pdf = pw.Document();
    final normalizedPaymentStatus = paymentStatus.trim().toUpperCase();
    final paymentLabel = normalizedPaymentStatus == 'PAID'
        ? 'Paid'
        : normalizedPaymentStatus == 'PENDING'
            ? 'Pending'
            : (paymentStatus.trim().isEmpty ? 'Pending' : paymentStatus.trim());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header & Brand
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "WE DRIVE",
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex("173B6D"),
                        ),
                      ),
                      pw.Text(
                        "Your Car. Your Comfort. Our Chauffeur.",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColor.fromHex("D4AF37"),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "TRIP RECEIPT",
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex("173B6D"),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Receipt ID: WD-$bookingId",
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 14),

              // Trip Metadata
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Chauffeur: $driverName", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text("Vehicle: $vehicleType", style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("Payment: $paymentLabel", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text("Mode: $paymentMethod", style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

              // Route Section
              pw.Text("TRIP ROUTE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColor.fromHex("173B6D"))),
              pw.SizedBox(height: 8),
              pw.Text("Pickup: $pickupLocation", style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Text("Drop: $dropLocation", style: const pw.TextStyle(fontSize: 10)),
              if (completedAt != null) ...[
                pw.SizedBox(height: 6),
                pw.Text(
                  "Completed: ${completedAt.day.toString().padLeft(2, '0')}/${completedAt.month.toString().padLeft(2, '0')}/${completedAt.year}",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],

              pw.SizedBox(height: 24),

              // Pricing Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex("173B6D")),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Item Description", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Amount (INR)", textAlign: pw.TextAlign.right, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Professional Chauffeur Pilot Fare", style: const pw.TextStyle(fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("₹${baseFare.toStringAsFixed(2)}", textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Taxes / Surcharges", style: const pw.TextStyle(fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("₹0.00", textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 10))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("Total Trip Fare", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text("₹${fare.toStringAsFixed(2)}", textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColor.fromHex("173B6D")))),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              pw.Divider(color: PdfColors.grey300),
              pw.Center(
                child: pw.Text(
                  "Thank you for choosing WE DRIVE. This receipt reflects the trip data recorded by the service.",
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: "Trip_Receipt_$bookingId.pdf",
    );
  }
}
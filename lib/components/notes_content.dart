import 'package:desktop_app/components/button.dart';
import 'package:flutter/material.dart';
import 'package:desktop_app/models/sublevel_model.dart';
import 'package:desktop_app/utils.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class NotesContent extends StatelessWidget {
  final Notes notes;

  const NotesContent({super.key, required this.notes});

  Future<void> _downloadPDF() async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notes.pdf');

      // Copy the asset to the file
      final data = await rootBundle.load(demoNotePath);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes);

      // Launch the file
      if (await canLaunchUrl(Uri.file(file.path))) {
        await launchUrl(Uri.file(file.path));
      } else {
        throw 'Could not launch ${file.path}';
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
    }
  }

  Widget _buildNotesContent(BuildContext context) {
    return Container(
      height: 600, // Fixed height for the PDF viewer
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SfPdfViewer.asset(
          demoNotePath,
          canShowPaginationDialog: true,
          canShowScrollHead: true,
          enableDoubleTapZooming: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Button(
                onPressed: _downloadPDF,
                isLoading: false,
                text: 'Download PDF',
                icon: Icons.download,
                width: 200,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildNotesContent(context)),
        ],
      ),
    );
  }
}

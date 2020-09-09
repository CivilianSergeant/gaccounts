import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
class PdfViewer extends StatelessWidget{

  final String path;
  const PdfViewer({Key key,this.path}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        return false;
      },
      child: PDFViewerScaffold(
              path: path,
      ),
    );
  }

}
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookReaderScreen extends StatefulWidget {
  const BookReaderScreen({super.key});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late String filePath;
  late String fileType;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _pages = [
    "Once upon a time in a distant land...",
    "Through forests dense and mountains high...",
    "With courage and determination, the adventurer reached the golden city..."
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    filePath = args['filePath'];
    fileType = args['fileType'];

    debugPrint('filePath: $filePath');
    debugPrint('fileType: $fileType');
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<ReaderSettings>(context);

    return Scaffold(
      backgroundColor: settings.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: settings.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: settings.isDarkMode ? Colors.white : Colors.black,
        ),
        actions: [
          IconButton(
            icon:
                Icon(settings.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            color: settings.isDarkMode ? Colors.white : Colors.black,
            onPressed: settings.toggleDarkMode,
          ),
        ],
      ),
      body: fileType == "text"
          ? _buildTextReader(settings)
          : fileType == "pdf"
              ? PDFReader(filePath: filePath, settings: settings)
              : _buildHTMLReader(),
    );
  }

  Widget _buildTextReader(ReaderSettings settings) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    _pages[index],
                    style: GoogleFonts.merriweather(
                      fontSize: settings.fontSize,
                      color:
                          settings.isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              );
            },
          ),
        ),
        _buildBottomControls(settings),
      ],
    );
  }

  Widget _buildHTMLReader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: HtmlWidget(
        filePath, // This should be HTML content
        textStyle: TextStyle(fontSize: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildBottomControls(ReaderSettings settings) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: settings.isDarkMode ? Colors.black54 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0
                ? () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
          ),
          Text(
            "Page ${_currentPage + 1}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _pages.length - 1
                ? () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

class PDFReader extends StatelessWidget {
  final String filePath;
  final ReaderSettings settings;

  const PDFReader({
    required this.filePath,
    required this.settings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.network(
      filePath,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
      key: ValueKey(filePath),
      // col: settings.isDarkMode ? Colors.black : Colors.white,
    );
  }
}

class ReaderSettings extends ChangeNotifier {
  double _fontSize = 18.0;
  bool _isDarkMode = false;

  double get fontSize => _fontSize;
  bool get isDarkMode => _isDarkMode;

  void increaseFontSize() {
    _fontSize += 2;
    notifyListeners();
  }

  void decreaseFontSize() {
    if (_fontSize > 14) {
      _fontSize -= 2;
      notifyListeners();
    }
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

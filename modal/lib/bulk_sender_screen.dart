import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'webview_screen.dart';

class BulkSenderScreen extends StatefulWidget {
  const BulkSenderScreen({super.key});

  @override
  State<BulkSenderScreen> createState() => _BulkSenderScreenState();
}

class _BulkSenderScreenState extends State<BulkSenderScreen> {
  final TextEditingController _numbersController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  double _delay = 10.0;
  bool _isSending = false;
  double _progress = 0.0;
  int _totalNumbers = 0;

  @override
  void initState() {
    super.initState();
    _numbersController.addListener(_updateTotalCount);
  }

  void _updateTotalCount() {
    setState(() {
      _totalNumbers = _numbersController.text
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .length;
    });
  }

  Future<void> _importFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        List<String> newNumbers = [];

        if (result.files.single.extension == 'csv') {
          List<List<dynamic>> rows = const CsvToListConverter().convert(content);
          for (var row in rows) {
            if (row.isNotEmpty) {
              newNumbers.add(row[0].toString().trim());
            }
          }
        } else {
          newNumbers = content
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        if (newNumbers.isNotEmpty) {
          String existing = _numbersController.text.trim();
          setState(() {
            _numbersController.text = existing.isEmpty
                ? newNumbers.join('\n')
                : '$existing\n${newNumbers.join('\n')}';
          });
          _updateTotalCount();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing file: $e')),
        );
      }
    }
  }

  Future<void> _startSending() async {
    final List<String> numbers = _numbersController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (numbers.isEmpty) {
      _showSnackBar('Please add at least one number.');
      return;
    }
    if (_messageController.text.isEmpty) {
      _showSnackBar('Please enter a message.');
      return;
    }
    if (WebviewScreen.webViewController == null) {
      _showSnackBar('WhatsApp Web is not initialized. Please open the first tab.');
      return;
    }

    setState(() {
      _isSending = true;
      _progress = 0.0;
    });

    for (int i = 0; i < numbers.length; i++) {
      if (!_isSending) break;

      String number = numbers[i].replaceAll(RegExp(r'\D'), '');
      if (number.isEmpty) continue;

      // 1. Load the specific chat URL
      await WebviewScreen.webViewController?.loadUrl(
        urlRequest: URLRequest(
          url: WebUri("https://web.whatsapp.com/send?phone=$number"),
        ),
      );

      // 2. Wait a few seconds for the chat to load (as per requirements)
      await Future.delayed(const Duration(seconds: 8));

      // 3. Inject the EXACT JavaScript provided
      final String message = _messageController.text.replaceAll("'", "\\'");
      final String jsCode = """
        var input = document.querySelector('div[contenteditable="true"][data-tab="10"]'); 
        if(input) { 
          input.innerText = '$message'; 
          input.dispatchEvent(new Event('input', {bubbles: true})); 
          setTimeout(function() { 
            var btn = document.querySelector('span[data-icon="send"]'); 
            if(btn) btn.click(); 
          }, 1000); 
        }
      """;

      await WebviewScreen.webViewController?.evaluateJavascript(source: jsCode);

      // 4. Wait for the user-selected delay
      await Future.delayed(Duration(seconds: _delay.toInt()));

      // 5. Update progress
      setState(() {
        _progress = (i + 1) / numbers.length;
      });
    }

    setState(() => _isSending = false);
    _showSnackBar('Bulk sending completed!');
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020512),
      appBar: AppBar(
        title: const Text('Bulk Sender Module', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Numbers Input Section
            _buildGlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Target Numbers', style: Theme.of(context).textTheme.titleMedium),
                      Text('Total: $_totalNumbers', style: const TextStyle(color: Color(0xFF00BFFF))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _numbersController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter numbers (one per line)...',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _importFile,
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('Import CSV / TXT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white10,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Message Section
            _buildGlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Message', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Type your message here...',
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Section
            _buildGlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delay Between Messages', style: Theme.of(context).textTheme.titleMedium),
                      Text('${_delay.toInt()}s', style: const TextStyle(color: Color(0xFF00BFFF), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _delay,
                    min: 5,
                    max: 60,
                    divisions: 55,
                    activeColor: const Color(0xFF00BFFF),
                    onChanged: _isSending ? null : (val) => setState(() => _delay = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Progress and Action
            if (_isSending) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white10,
                color: const Color(0xFF00BFFF),
              ),
              const SizedBox(height: 10),
              Center(child: Text('${(_progress * 100).toInt()}% Completed')),
              const SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSending ? () => setState(() => _isSending = false) : _startSending,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSending ? Colors.redAccent : const Color(0xFF00BFFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  _isSending ? 'Stop Sending' : 'Start Bulk Sending',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numbersController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

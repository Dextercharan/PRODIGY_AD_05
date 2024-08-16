import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Scanner_test',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text('QR Scanner_test'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (qrText != null)
                    ElevatedButton(
                      onPressed: () => _showResultDialog(context),
                      child: const Text('See Result'),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code;
      });
    });
  }

  void _showResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scanned info'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(qrText ?? ''),
                const SizedBox(height: 20),
                if (_isURL(qrText!))
                  ElevatedButton(
                    onPressed: _launchURL,
                    child: const Text('Open Link'),
                  ),
                if (_isEmail(qrText!))
                  ElevatedButton(
                    onPressed: _sendEmail,
                    child: const Text('Send Email'),
                  ),
                if (_isPhoneNumber(qrText!))
                  ElevatedButton(
                    onPressed: _makePhoneCall,
                    child: const Text('Call Number'),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isURL(String text) {
    return Uri.tryParse(text)?.hasAbsolutePath ?? false;
  }

  bool _isEmail(String text) {
    return text.contains('@');
  }

  bool _isPhoneNumber(String text) {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(text);
  }

  void _launchURL() async {
    final Uri url = Uri.parse(qrText!);
    if (!await launchUrl(url)) {
      _showError('Could not open the link');
    }
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: qrText,
    );
    if (!await launchUrl(emailUri)) {
      _showError('Could not send email');
    }
  }

  void _makePhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: qrText,
    );
    if (!await launchUrl(phoneUri)) {
      _showError('Could not make the call');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

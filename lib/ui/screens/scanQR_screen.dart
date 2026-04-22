import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/models/ProductData.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _cameraGranted = false;
  bool _handled = false;

  ProductData? _foundProduct;
  String? _statusText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Сканирование QR'),
      ),
      body: SafeArea(
        child: !_cameraGranted ? Center(
          child: Text(_statusText ?? 'Запрос доступа к камере.')
        ) : Column(
          children: [
            Expanded(
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_statusText != null)
                    Text(
                      _statusText!,
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 10),
                  if (_foundProduct != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _foundProduct);
                      },
                      child: Text('Перейти к товару'),
                    ),
                  if (_handled)
                    OutlinedButton(
                      onPressed: _scanAgain,
                      child: Text('Сканировать снова'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    if (!Platform.isAndroid) {
      setState(() {
        _cameraGranted = true;
      });
      return;
    }

    if (await Permission.camera.isGranted) {
      setState(() => _cameraGranted = true);
      return;
    }

    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() => _cameraGranted = true);
      return;
    }

    if (status.isPermanentlyDenied) {
      setState(() {
        _statusText = 'Доступ к камере запрещен. Включите в настройках.';
      });
      return;
    }

    setState(() {
      _statusText = 'Нужен доступ к камере для сканирования QR';
    });
  }

  ProductData? _findProductByQr(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final int? id = map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}');
      if (id == null) return null;

      for (final p in products) {
        if (p.id == id) return p;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.trim().isEmpty) {
      setState(() {
        _handled = true;
        _statusText = 'Некорректный QR';
      });
      return;
    }

    final found = _findProductByQr(raw);

    setState(() {
      _handled = true;
      _foundProduct = found;
      _statusText = found != null ? 'Товар найден' : 'Не удалось найти товар';
    });
  }

  void _scanAgain() {
    setState(() {
      _handled = false;
      _foundProduct = null;
      _statusText = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

}

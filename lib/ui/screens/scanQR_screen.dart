import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/HelperDB.dart';
import '../../domain/models/ProductData.dart';
import '../../domain/models/UserData.dart';

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
        actions: [
          IconButton(
            onPressed: () async {
              await openAppSettings();
            },
            icon: Icon(
              Icons.settings
            ),
          ),
        ]
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

  Future<ProductData?> _findProductByQr(String raw) async {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final String? uuid = map['uuid']?.toString();
      if (uuid == null || uuid.isEmpty) return null;

      final row = await HelperDB.instance.getProductByUuid(uuid);
      if (row == null) return null;
      return ProductData.fromMap(row);
    } catch (_) {
      return null;
    }
  }


  Future<void> _onDetect(BarcodeCapture capture) async {
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

    final found = await _findProductByQr(raw);

    if (found != null){
      try {

        if (!(await _canReturnProduct(found))){
          setState(() {
            _handled = true;
            _statusText = 'Товар не может быть возвращен';
          });
          return;
        }

        await _applyScanAction(found);

        final updatedMap = await HelperDB.instance.getProductById(found.id);
        if (updatedMap == null) return;

        final updatedProduct = ProductData.fromMap(updatedMap);

        setState(() {
          _handled = true;
          _foundProduct = updatedProduct;
          _statusText = found.isActive
              ? 'Товар выдан'
              : 'Товар возвращён';
        });
        return;

      } catch (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() {
      _handled = true;
      _statusText = 'Не удалось найти товар';
    });
  }

  Future<void> _applyScanAction(ProductData product) async {
    final db = HelperDB.instance;

    final int takeActionId = await db.getActionTypeIdByCode('take');
    final int returnActionId = await db.getActionTypeIdByCode('return');
    final int availableStatusId = await db.getStatusIdByCode('in_stock');
    final int unavailableStatusId = await db.getStatusIdByCode('out_of_stock');

    final bool isNowAvailable = product.isActive;

    final int newStatusId = isNowAvailable ? unavailableStatusId : availableStatusId;
    final int newActionTypeId = isNowAvailable ? takeActionId : returnActionId;

    await db.updateProductStatus(
        productId: product.id,
        statusId: newStatusId
    );

    await db.insertAction(
      productId: product.id,
      userId: UserData.getUser()!.id,
      actionTypeId: newActionTypeId,
      createdAt: DateTime.now().toIso8601String(),
    );
  }


  Future<bool> _canReturnProduct(ProductData product) async{

    if (!product.isActive) {
      final int? userId = await HelperDB.instance.getLastUserIdByProductId(product.id);
      if (userId != null && userId != UserData.getUser()?.id){
        return false;
      }
    }
    return true;
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}

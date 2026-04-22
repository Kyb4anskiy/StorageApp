import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/data/HelperDB.dart';
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/ProductData.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isActive = true;
  String? _qrData;
  PlatformFile? _pickedFile;
  String? _imageError;
  static const _uuid = Uuid();
  final _newUuid = _uuid.v4();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавление товара')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Название',
                          ),
                          validator: (value) {
                            final text = (value ?? '');
                            if (text.isEmpty) return 'Введите название';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Описание',
                          ),
                          maxLines: 4,
                          validator: (value) {
                            final text = (value ?? '');
                            if (text.isEmpty) return 'Введите описание';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.image_outlined),
                          label: Text(
                            'Выбрать изображение',
                          ),
                        ),
                        if (_imageError != null)
                          Padding(
                            padding: EdgeInsetsGeometry.directional(start: 14, top: 6),
                            child: Text(
                                _imageError!,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error),
                              ),
                          ),
                        const SizedBox(height: 10),
                        _buildPreview(),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() => _isActive = value ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: Text('В наличии'),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _generateQr,
                            child: Text('Сгенерировать QR'),
                          ),
                        ),
                        if (_qrData != null) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: QrImageView(
                              data: _qrData!,
                              version: QrVersions.auto,
                              size: 220,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: saveProduct,
                              child: Text('Сохранить товар'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_pickedFile == null) return const SizedBox.shrink();

    if (_pickedFile!.path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(_pickedFile!.path!), height: 320, fit: BoxFit.cover),
      );
    }

    return const SizedBox.shrink();
  }

  void _generateQr() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final hasImage = _pickedFile != null;

    setState(() {
      _imageError = hasImage ? null : 'Выберите изображение';
    });

    if (!formValid || !hasImage) return;

    final payload = ProductData.toQRString(
      uuid: _newUuid,
      title: _titleController.text,
      description: _descriptionController.text
    );

    setState(() {
      _qrData = jsonEncode(payload);
    });
  }


  Future<void> saveProduct() async {
    if (_qrData == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Товар не сохранен. Сгенерируйте QR'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2)),
      );
      return;
    }

    final imagePath = await _storeImagePermanently(_pickedFile!);

    try{
      await HelperDB.instance.insertProduct(
          uuid: _newUuid,
          title: _titleController.text,
          description: _descriptionController.text,
          linkImage: imagePath,
          statusId: _isActive ? 1 : 2);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Товар сохранен'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2)),
      );

      Navigator.pop(context, true);
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<String> _storeImagePermanently(PlatformFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/product_images');
    if (!imagesDir.existsSync()) imagesDir.createSync(recursive: true);

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final savedPath = '${imagesDir.path}/$fileName';

    if (file.bytes != null) {
      await File(savedPath).writeAsBytes(file.bytes!);
    } else {
      throw Exception('Файл изображения пуст');
    }

    return savedPath;
  }


  Future<bool> _requestFilePermission() async{
    if (!Platform.isAndroid) return true;

    if (await Permission.photos.isGranted) {
      return true;
    }

    var status = await Permission.photos.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Доступ запрещен. Включите его в настройках приложения.'),
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Нужен доступ к файлам для выбора изображения'),
        duration: Duration(seconds: 3),),
    );
    return false;
  }


  Future<void> _pickImage() async {
    final hasPermission = await _requestFilePermission();
    if (!hasPermission) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _pickedFile = result.files.first;
      _imageError = null;
    });
  }


}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/product_service.dart';
import '../../../core/models/product.dart';

class AddProductViewModel extends ChangeNotifier {
  final ProductService _productService = ProductService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<bool> saveProduct({
    required String nome,
    required String id,
    required String descrizione,
    required int numeroPezzi,
    required double prezzo,
    required bool ordinabile,
  }) async {
    _isLoading = true;
    notifyListeners();

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _productService.uploadProductImage(_selectedImage!, id);
    }

    final newProduct = Product(
      id: id,
      nome: nome,
      descrizione: descrizione,
      prezzo: prezzo,
      numeroPezzi: numeroPezzi,
      ordinabile: ordinabile,
      imageUrl: imageUrl,
    );

    final success = await _productService.addProduct(newProduct);

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
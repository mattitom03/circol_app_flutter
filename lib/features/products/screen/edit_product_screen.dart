import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _descrizioneController;
  late TextEditingController _importoController;
  late TextEditingController _pezziController;
  late bool _isOrdinabile;

  File? _selectedImageFile; // Per tenere in memoria il file della nuova immagine scelta
  String? _currentImageUrl; // Per l'URL dell'immagine esistente
  bool _isUploading = false; // Per mostrare un loader durante l'upload

  @override
  void initState() {
    super.initState();
    // Inizializza i controller con i valori attuali del prodotto
    _nomeController = TextEditingController(text: widget.product.nome);
    _descrizioneController = TextEditingController(text: widget.product.descrizione);
    _importoController = TextEditingController(text: widget.product.importo.toString());
    _pezziController = TextEditingController(text: widget.product.numeroPezzi.toString());
    _currentImageUrl = widget.product.immagine; // Salva l'URL corrente
    _isOrdinabile = widget.product.ordinabile;
  }
  //METODO PER SCEGLIERE L'IMMAGINE
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }


  @override
  void dispose() {
    // Pulisci i controller quando il widget viene rimosso
    _nomeController.dispose();
    _descrizioneController.dispose();
    _importoController.dispose();
    _pezziController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    // Controlla subito se il form è valido
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isUploading = true; // Mostra il caricamento
    });

    // Salva Navigator e ScaffoldMessenger prima della chiamata asincrona
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    String? finalImageUrl = _currentImageUrl;

    try {
      // 1. Se è stata scelta una nuova immagine, caricala
      if (_selectedImageFile != null) {
        finalImageUrl = await context.read<AuthViewModel>().uploadProductImage(
          _selectedImageFile!,
          widget.product.id,
        );
      }

      // 2. Crea l'oggetto Product aggiornato con il link finale dell'immagine
      final updatedProduct = widget.product.copyWith(
        nome: _nomeController.text,
        descrizione: _descrizioneController.text,
        prezzo: double.tryParse(_importoController.text) ?? widget.product.importo,
        numeroPezzi: int.tryParse(_pezziController.text) ?? widget.product.numeroPezzi,
        imageUrl: finalImageUrl,
        ordinabile: _isOrdinabile,
      );
      // 3. Salva il prodotto come prima
      await context.read<AuthViewModel>().updateProduct(updatedProduct);
      messenger.showSnackBar(
        const SnackBar(content: Text('Prodotto aggiornato!'), backgroundColor: Colors.green),
      );
      navigator.pop();

    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Errore durante il salvataggio: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isUploading = false; // Nascondi il caricamento
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica ${widget.product.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProduct, // Salva il prodotto
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Prodotto'),
                validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descrizioneController,
                decoration: const InputDecoration(labelText: 'Descrizione'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _importoController,
                decoration: const InputDecoration(labelText: 'Importo (€)', prefixText: '€ '),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pezziController,
                decoration: const InputDecoration(labelText: 'Numero Pezzi'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obbligatorio' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Prodotto Ordinabile'),
                subtitle: const Text('Se attivo, gli utenti potranno vedere e ordinare questo prodotto.'),
                value: _isOrdinabile,
                onChanged: (bool value) {
                  setState(() {
                    _isOrdinabile = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              if (_isUploading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _saveProduct,
                  child: const Text('Salva Modifiche'),
                ),
            ],
          ),
        ),
      ),
    );
  }
  // NUOVO WIDGET HELPER PER L'ANTEPRIMA
  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      // Mostra la nuova immagine selezionata dal file
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.file(_selectedImageFile!, fit: BoxFit.cover),
      );
    }
    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      // Mostra l'immagine esistente dall'URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(_currentImageUrl!, fit: BoxFit.cover),
      );
    }
    // Messaggio di default se non c'è nessuna immagine
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
          SizedBox(height: 8),
          Text('Tocca per scegliere un\'immagine', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

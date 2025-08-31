import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/add_product_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddProductViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aggiungi Nuovo Prodotto'),
        ),
        body: const AddProductForm(),
      ),
    );
  }
}

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _idController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _pezziController = TextEditingController();
  final _prezzoController = TextEditingController();
  bool _isOrdinabile = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _idController.dispose();
    _descrizioneController.dispose();
    _pezziController.dispose();
    _prezzoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddProductViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => context.read<AddProductViewModel>().pickImage(),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: viewModel.selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.file(viewModel.selectedImage!, fit: BoxFit.cover),
                )
                    : const Center(child: Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Prodotto'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _idController,
                decoration: const InputDecoration(labelText: 'Codice Prodotto (ID Unico)'),
                validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _descrizioneController,
                decoration: const InputDecoration(labelText: 'Descrizione'),
                maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _pezziController, decoration: const InputDecoration(labelText: 'Numero Pezzi'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _prezzoController, decoration: const InputDecoration(labelText: 'Prezzo (€)'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Campo obbligatorio' : null)),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(title: const Text('Ordinabile'),
                value: _isOrdinabile,
                onChanged: (value) => setState(() => _isOrdinabile = value)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () async {
                if (_formKey.currentState!.validate()) {
                  final success = await viewModel.saveProduct(
                    id: _idController.text.trim(),
                    nome: _nomeController.text.trim(),
                    descrizione: _descrizioneController.text,
                    numeroPezzi: int.parse(_pezziController.text),
                    prezzo: double.parse(_prezzoController.text),
                    ordinabile: _isOrdinabile,
                  );
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prodotto salvato!'), backgroundColor: Colors.green));
                    context.read<AuthViewModel>().refreshAllData();
                    Navigator.of(context).pop();
                  }
                }
              },
              child: viewModel.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Salva Prodotto', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
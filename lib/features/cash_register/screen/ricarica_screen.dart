import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class RicaricaScreen extends StatefulWidget {
  const RicaricaScreen({super.key});

  @override
  State<RicaricaScreen> createState() => _RicaricaScreenState();
}

class _RicaricaScreenState extends State<RicaricaScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanComplete = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanComplete) return; // Evita scansioni multiple

    final String? scannedUID = capture.barcodes.first.rawValue;
    if (scannedUID != null && scannedUID.isNotEmpty) {
      setState(() {
        _isScanComplete = true; // Blocca ulteriori scansioni
      });
      _scannerController.stop(); // Ferma la fotocamera

      // Mostra il dialogo per inserire l'importo
      _showImportoDialog(scannedUID);
    }
  }

  void _showImportoDialog(String userId) {
    final importoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false, // L'utente deve interagire con il dialogo
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Inserisci Importo Ricarica'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: importoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '€ ',
                labelText: 'Importo',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obbligatorio';
                }
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Inserisci un numero valido';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Riattiva lo scanner se l'utente annulla
                setState(() => _isScanComplete = false);
                _scannerController.start();
              },
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final importo = double.parse(importoController.text.replaceAll(',', '.'));
                  final authViewModel = context.read<AuthViewModel>();

                  // Chiama la funzione del ViewModel
                  authViewModel.eseguiRicarica(userId, importo)
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ricarica effettuata con successo!'), backgroundColor: Colors.green),
                    );
                    // Torna alla schermata precedente dopo successo
                    Navigator.of(context).pop();
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Errore: ${e.toString()}'), backgroundColor: Colors.red),
                    );
                  });
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Conferma'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inquadra Codice Utente'),
      ),
      body: MobileScanner(
        controller: _scannerController,
        onDetect: _onDetect,
      ),
    );
  }
}
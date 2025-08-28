import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Prendiamo l'UID dell'utente corrente dal ViewModel
    final userUid = context.watch<AuthViewModel>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il Tuo QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (userUid != null)
              QrImageView(
                data: userUid,
                version: QrVersions.auto,
                size: 250.0,
                backgroundColor: Colors.white,
              )
            else
              const Text('Errore: Utente non trovato.'),
            const SizedBox(height: 24),
            const Text(
              'Mostra questo codice all\'admin per la cassa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../core/models/models.dart';
import '../../../core/screen/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            // Ascolta i cambiamenti nell'autenticazione
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final result = authViewModel.authResult;
              if (result is AuthSuccess) {
                // Salva i dati prima di resettare
                final userRole = result.userRole;
                authViewModel.resetAuthResult();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => MainScreen(userRole: userRole),
                  ),
                  (route) => false,
                );
              } else if (result is AuthError) {
                // Salva il messaggio prima di resettare
                final errorMessage = result.message;
                authViewModel.resetAuthResult();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Titolo
                  Text(
                    'Crea il tuo account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Campo Nome
                  TextFormField(
                    controller: _nomeController,
                    enabled: !authViewModel.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                      hintText: 'Inserisci il tuo nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome obbligatorio';
                      }
                      if (value.length < 2) {
                        return 'Nome troppo corto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Username
                  TextFormField(
                    controller: _usernameController,
                    enabled: !authViewModel.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Scegli un username',
                      prefixIcon: Icon(Icons.alternate_email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username obbligatorio';
                      }
                      if (value.length < 3) {
                        return 'Username deve essere di almeno 3 caratteri';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                        return 'Username può contenere solo lettere, numeri e underscore';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !authViewModel.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Inserisci la tua email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email obbligatoria';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Email non valida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !authViewModel.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Inserisci una password sicura',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password obbligatoria';
                      }
                      if (value.length < 6) {
                        return 'Password deve essere di almeno 6 caratteri';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Conferma Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    enabled: !authViewModel.isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Conferma Password',
                      hintText: 'Ripeti la password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Conferma password obbligatoria';
                      }
                      if (value != _passwordController.text) {
                        return 'Le password non coincidono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Pulsante Registrazione
                  ElevatedButton(
                    onPressed: authViewModel.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authViewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'REGISTRATI',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Link per tornare al login
                  TextButton(
                    onPressed: authViewModel.isLoading ? null : () => Navigator.of(context).pop(),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(text: 'Hai già un account? '),
                          TextSpan(
                            text: 'Accedi',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
        nome: _nomeController.text.trim(),
      );
    }
  }
}

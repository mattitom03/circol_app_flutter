// Import dei modelli per utilizzarli qui
import 'user.dart';
import 'user_role.dart';

// Export di tutti i modelli dell'applicazione
export 'user.dart';
export 'user_role.dart';
export 'movimento.dart';
export 'evento.dart';
export 'product.dart';

// Auth result types
abstract class AuthResult {
  const AuthResult();
}

class AuthIdle extends AuthResult {
  const AuthIdle();
}

class AuthLoading extends AuthResult {
  const AuthLoading();
}

class AuthSuccess extends AuthResult {
  final User user;
  final UserRole userRole;
  final Map<String, dynamic> allData;

  const AuthSuccess({
    required this.user,
    required this.userRole,
    required this.allData,
  });
}

class AuthError extends AuthResult {
  final String message;

  const AuthError(this.message);
}

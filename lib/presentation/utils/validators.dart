const Set<String> _allowedEmailDomains = {
  'gmail.com',
  'hotmail.com',
  'outlook.com',
  'outlook.es',
  'hotmail.es',
  'live.com',
  'live.com.mx',
  'yahoo.com',
  'yahoo.com.mx',
  'icloud.com',
  'proton.me',
  'protonmail.com',
};

// Email sin caracteres especiales en la parte local (antes de @)
// Permitimos solo letras, números y punto.
final _emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$');

// Nombre/Apellido: solo letras y espacios, sin números
final _onlyLetters = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]+$');

// Primera letra mayúscula
final _startsWithUppercase = RegExp(r'^[A-ZÁÉÍÓÚÑÜ]');

// Teléfono: solo dígitos
final _digitsOnly = RegExp(r'^\d+$');

// Contraseña:
// - al menos 1 mayúscula
// - al menos 1 minúscula
// - al menos 1 número
// - al menos 1 carácter especial
// - longitud entre 8 y 10
final _passwordRegex = RegExp(
  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_\-+=\[\]{};:,.<>?/\\|~`]).{8,10}$',
);

bool looksLikeEmail(String input) {
  final v = input.trim();
  return _emailRegex.hasMatch(v);
}

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'El correo es requerido.';
  if (!looksLikeEmail(v)) {
    return 'Correo inválido. Usa solo letras, números y punto antes de @';
  }

  final domain = v.toLowerCase().split('@').last;
  if (!_allowedEmailDomains.contains(domain)) {
    return 'Usa un correo de un proveedor válido\n(Gmail, Hotmail, Outlook, etc.)';
  }

  return null;
}

String? validateName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'El nombre es requerido.';
  if (!_onlyLetters.hasMatch(v)) return 'El nombre solo debe contener letras.';
  if (!_startsWithUppercase.hasMatch(v)) {
    return 'El nombre debe iniciar con mayúscula.';
  }
  return null;
}

String? validateLastName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'El apellido es requerido.';
  if (!_onlyLetters.hasMatch(v)) return 'El apellido solo debe contener letras.';
  if (!_startsWithUppercase.hasMatch(v)) {
    return 'El apellido debe iniciar con mayúscula.';
  }
  return null;
}

String capitalizeWords(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';

  return trimmed.split(RegExp(r'\s+')).map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String? validatePhone(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'El teléfono es requerido.';
  if (!_digitsOnly.hasMatch(v)) return 'El teléfono solo debe contener números.';
  if (v.length != 10) return 'El teléfono debe tener 10 dígitos.';
  return null;
}

String? validatePassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'La contraseña es requerida.';
  if (!_passwordRegex.hasMatch(v)) {
    return 'Debe tener 8-10 caracteres, 1 mayúscula, 1 minúscula, 1 número y 1 carácter especial.';
  }
  return null;
}

String? validateConfirmPassword(String? value, String original) {
  final v = value ?? '';
  if (v.isEmpty) return 'Confirma tu contraseña.';
  if (v != original) return 'Las contraseñas no coinciden.';
  return null;
}
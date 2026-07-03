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

bool looksLikeEmail(String input){
  final v = input.trim();
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return emailRegex.hasMatch(v);
}

String? validateEmail(String? value){
  final v = value?.trim().toLowerCase() ?? '';
  if(v.isEmpty) return 'El correo es requerido.';
  if(!looksLikeEmail(v)) return 'El correo no es válido.';
  
  final domain = v.split('@').last;
  if(!_allowedEmailDomains.contains(domain)){
    return 'Usa un correo de un proveedor válido\n(Gmail, Hotmail, Outlook, etc.)';
  }
  
  return null;
}

String? validatePassword(String? value){
  final v = value ?? '';

  if(v.isEmpty) return 'La contraseña es requerida.';
  if(v.length < 8) return 'La contraseña debe tener al menos 8 caracteres.';

  if(!RegExp(r'[A-Z]').hasMatch(v)){
    return 'Debe incluir al menos una letra mayúscula.';
  }
  if(!RegExp(r'[a-z]').hasMatch(v)){
    return 'Debe incluir al menos una letra minúscula.';
  }
  if(!RegExp(r'[0-9]').hasMatch(v)){
    return 'Debe incluir al menos un número.';
  }
  if(!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]\\/~`+=;'"'"']').hasMatch(v)){
    return 'Debe incluir al menos un carácter especial.';
  }

  return null;
}

final _onlyLetters = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ ]+$");

String? validateName(String? value){
  final v = value?.trim() ?? '';
  if(v.isEmpty) return 'El nombre es requerido.';
  if(!_onlyLetters.hasMatch(v)) return 'El nombre solo debe contener letras.';
  return null;
}

String? validateLastName(String? value){
  final v = value?.trim() ?? '';
  if(v.isEmpty) return 'El apellido es requerido.';
  if(!_onlyLetters.hasMatch(v)) return 'El apellido solo debe contener letras.';
  return null;
}

String capitalizeWords(String value){
  final trimmed = value.trim();
  if(trimmed.isEmpty) return '';

  return trimmed.split(RegExp(r'\s+'))
    .map((word){
      if(word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
}

String? validatePhone(String? value){
  final v = value?.trim() ?? '';
  if(v.isEmpty) return 'El teléfono es requerido.';
  final digitsOnly = RegExp(r'^\d+$');
  if(!digitsOnly.hasMatch(v)) return 'El teléfono solo debe contener números.';
  if(v.length <= 9|| v.length > 10) return 'El teléfono debe tener 10 dígitos.';
  return null;
}

String? validateConfirmPassword(String? value, String original){
  final v = value ?? '';
  if(v.isEmpty) return 'Confirma tu contraseña.';
  if(v != original) return 'Las contraseñas no coinciden.';
  return null;
}
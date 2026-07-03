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
  if(v.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
  return null;
}

String? validateName(String? value){
  final v = value?.trim() ?? '';
  if(v.isEmpty) return 'El nombre es requerido.';
  return null;
}

String? validateLastName(String? value){
  final v = value?.trim() ?? '';
  if(v.isEmpty) return 'El apellido es requerido.';
  return null;
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
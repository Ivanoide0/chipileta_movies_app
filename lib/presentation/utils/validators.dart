bool looksLikeEmail(String input){
  final v = input.trim();
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  return emailRegex.hasMatch(v);
}

String? validateEmail(String? value){
  final v = value?.trim() ?? '';
  if(v.isEmpty) return 'El correo es requerido.';
  if(!looksLikeEmail(v)) return 'El correo no es válido.';
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
  if(v.length < 8 || v.length > 15) return 'El teléfono debe tener entre 8 y 15 dígitos.';
  return null;
}

String? validateConfirmPassword(String? value, String original){
  final v = value ?? '';
  if(v.isEmpty) return 'Confirma tu contraseña.';
  if(v != original) return 'Las contraseñas no coinciden.';
  return null;
}
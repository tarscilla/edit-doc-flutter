String? validarNome(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe seu nome completo';
  }
  if (value.trim().split(' ').length < 2) {
    return 'Informe nome e sobrenome';
  }
  return null;
}

String? validarEmail(String? value) {
  if (value == null || value.trim().isEmpty || !value.contains('@')) {
    return 'Informe um e-mail válido';
  }
  return null;
}

String? validarSenha(String? value) {
  if (value == null || value.length < 6) {
    return 'A senha deve ter pelo menos 6 caracteres';
  }
  return null;
}
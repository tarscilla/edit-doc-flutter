class Usuario {
  final String nome;
  final String email;
  final String senha;

  Usuario({required this.nome, required this.email, required this.senha});

  Map<String, dynamic> toMap() => {'nome': nome, 'email': email, 'senha': senha};

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
        nome: m['nome'] as String,
        email: m['email'] as String,
        senha: m['senha'] as String,
      );
}
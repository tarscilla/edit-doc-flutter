class Documento {
  final String id;
  final String titulo;
  final String conteudo;
  final DateTime atualizadoEm;

  Documento({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.atualizadoEm,
  });

  Documento copyWith({String? titulo, String? conteudo, DateTime? atualizadoEm}) =>
      Documento(
        id: id,
        titulo: titulo ?? this.titulo,
        conteudo: conteudo ?? this.conteudo,
        atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };

  factory Documento.fromMap(Map<String, dynamic> m) => Documento(
        id: m['id'] as String,
        titulo: m['titulo'] as String,
        conteudo: m['conteudo'] as String,
        atualizadoEm: DateTime.parse(m['atualizadoEm'] as String),
      );
}
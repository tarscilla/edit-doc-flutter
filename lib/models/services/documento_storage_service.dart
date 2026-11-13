import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../documento.dart';

class DocumentoStorageService {
  String _chave(String email) => 'documentos_${email.toLowerCase()}';

  List<Documento> _iniciais() {
    final agora = DateTime.now();
    return [
      Documento(
        id: 'inicial_1',
        titulo: 'Relatório de Estudos.txt',
        conteudo: 'Resumo da semana:\n- Roteamento no Flutter\n- Validação de formulários',
        atualizadoEm: agora,
      ),
      Documento(
        id: 'inicial_2',
        titulo: 'Lista de Tarefas.txt',
        conteudo: '1. Finalizar o laboratório\n2. Testar no DartPad\n3. Gerar o PDF',
        atualizadoEm: agora,
      ),
      Documento(
        id: 'inicial_3',
        titulo: 'Anotações de Aula.txt',
        conteudo: 'Navigator.pushNamed abre uma nova tela.\nNavigator.pop volta para a anterior.',
        atualizadoEm: agora,
      ),
    ];
  }

  Future<List<Documento>> listar(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chave(email));
    if (raw == null) {
      final iniciais = _iniciais();
      await _salvarTodos(email, iniciais);
      return iniciais;
    }
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista.map((e) => Documento.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> _salvarTodos(String email, List<Documento> docs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave(email), jsonEncode(docs.map((d) => d.toMap()).toList()));
  }

  Future<Documento> criar(String email, String titulo, String conteudo) async {
    final lista = await listar(email);
    final novo = Documento(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titulo: titulo,
      conteudo: conteudo,
      atualizadoEm: DateTime.now(),
    );
    lista.add(novo);
    await _salvarTodos(email, lista);
    return novo;
  }

  Future<void> atualizar(String email, Documento doc) async {
    final lista = await listar(email);
    final i = lista.indexWhere((d) => d.id == doc.id);
    if (i >= 0) {
      lista[i] = doc;
      await _salvarTodos(email, lista);
    }
  }

  Future<void> excluir(String email, String id) async {
    final lista = await listar(email);
    lista.removeWhere((d) => d.id == id);
    await _salvarTodos(email, lista);
  }
}
import 'package:flutter/foundation.dart';
import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';

class DocumentosViewModel extends ChangeNotifier {
  final DocumentoStorageService _storage;

  DocumentosViewModel({DocumentoStorageService? storage})
      : _storage = storage ?? DocumentoStorageService();

  List<Documento> _documentos = [];
  int _selecionado = 0;
  bool _modoLeitura = false;
  bool _carregando = false;
  String _email = '';

  List<Documento> get documentos => List.unmodifiable(_documentos);
  int get indiceSelecionado => _selecionado;
  Documento? get selecionado => _documentos.isEmpty ? null : _documentos[_selecionado];
  bool get modoLeitura => _modoLeitura;
  bool get carregando => _carregando;

  String _normalizarTitulo(String t) {
    final s = t.trim();
    return s.toLowerCase().endsWith('.txt') ? s : '$s.txt';
  }

  Future<void> carregar(String email) async {
    _email = email;
    _carregando = true;
    notifyListeners();
    _documentos = await _storage.listar(email);
    _selecionado = 0;
    _modoLeitura = false;
    _carregando = false;
    notifyListeners();
  }

  Future<void> _persistirTexto(String texto) async {
    final doc = selecionado;
    if (doc == null || doc.conteudo == texto) return;
    final atualizado = doc.copyWith(conteudo: texto, atualizadoEm: DateTime.now());
    _documentos[_selecionado] = atualizado;
    await _storage.atualizar(_email, atualizado);
  }

  Future<void> selecionar(int indice, String textoEditor) async {
    await _persistirTexto(textoEditor);
    _selecionado = indice;
    notifyListeners();
  }

  Future<void> salvarConteudo(String textoEditor) async {
    await _persistirTexto(textoEditor);
    notifyListeners();
  }

  Future<void> alternarModoLeitura(String textoEditor) async {
    await _persistirTexto(textoEditor);
    _modoLeitura = !_modoLeitura;
    notifyListeners();
  }

  Future<void> criar(String titulo, String conteudo) async {
    final novo = await _storage.criar(_email, _normalizarTitulo(titulo), conteudo);
    _documentos.add(novo);
    _selecionado = _documentos.length - 1;
    _modoLeitura = false;
    notifyListeners();
  }

  Future<void> atualizar(Documento doc) async {
    final atualizado = doc.copyWith(
      titulo: _normalizarTitulo(doc.titulo),
      atualizadoEm: DateTime.now(),
    );
    final i = _documentos.indexWhere((d) => d.id == atualizado.id);
    if (i < 0) return;
    _documentos[i] = atualizado;
    await _storage.atualizar(_email, atualizado);
    notifyListeners();
  }

  Future<void> excluir(String id) async {
    await _storage.excluir(_email, id);
    _documentos.removeWhere((d) => d.id == id);
    if (_selecionado >= _documentos.length) {
      _selecionado = _documentos.isEmpty ? 0 : _documentos.length - 1;
    }
    notifyListeners();
  }

  void limpar() {
    _documentos = [];
    _email = '';
    _selecionado = 0;
    _modoLeitura = false;
    notifyListeners();
  }
}
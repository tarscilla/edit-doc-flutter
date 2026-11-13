import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../usuario.dart';

class PreferencesService {
  static const _kTema = 'tema_escuro';
  static const _kSessao = 'sessao_usuario';

  Future<bool> lerTemaEscuro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kTema) ?? false;
  }

  Future<void> salvarTemaEscuro(bool escuro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTema, escuro);
  }

  Future<void> salvarSessao(Usuario u) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessao, jsonEncode({'nome': u.nome, 'email': u.email}));
  }

  Future<Usuario?> lerSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessao);
    if (raw == null) return null;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return Usuario(nome: m['nome'] as String, email: m['email'] as String, senha: '');
  }

  Future<void> limparSessao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessao);
  }
}
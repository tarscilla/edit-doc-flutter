import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../usuario.dart';

class BancoLocalService {
  static const _chave = 'usuarios';

  Future<List<Usuario>> _listar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chave);
    if (raw == null || raw.isEmpty) return [];
    final lista = jsonDecode(raw) as List<dynamic>;
    return lista.map((e) => Usuario.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<bool> cadastrar(Usuario novo) async {
    final lista = await _listar();
    final existe = lista.any((u) => u.email.toLowerCase() == novo.email.toLowerCase());
    if (existe) return false;
    lista.add(novo);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, jsonEncode(lista.map((u) => u.toMap()).toList()));
    return true;
  }

  Future<Usuario?> autenticar(String email, String senha) async {
    final lista = await _listar();
    for (final u in lista) {
      if (u.email.toLowerCase() == email.toLowerCase() && u.senha == senha) return u;
    }
    return null;
  }
}
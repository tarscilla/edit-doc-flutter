import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';

class AuthViewModel extends ChangeNotifier {
  final PreferencesService _prefs;
  final BancoLocalService _banco;

  AuthViewModel({PreferencesService? prefs, BancoLocalService? banco})
      : _prefs = prefs ?? PreferencesService(),
        _banco = banco ?? BancoLocalService();

  bool _temaEscuro = false;
  Usuario? _usuario;
  bool _carregando = false;
  String? _erro;

  bool get temaEscuro => _temaEscuro;
  Usuario? get usuario => _usuario;
  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<void> carregarPreferencias() async {
    _temaEscuro = await _prefs.lerTemaEscuro();
    _usuario = await _prefs.lerSessao();
    notifyListeners();
  }

  Future<bool> login(String email, String senha) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    final u = await _banco.autenticar(email.trim(), senha);
    _carregando = false;
    if (u == null) {
      _erro = 'E-mail ou senha incorretos. Cadastre-se se ainda não tem conta.';
      notifyListeners();
      return false;
    }
    _usuario = u;
    await _prefs.salvarSessao(u);
    notifyListeners();
    return true;
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    final ok = await _banco.cadastrar(
      Usuario(nome: nome.trim(), email: email.trim(), senha: senha),
    );
    _carregando = false;
    if (!ok) _erro = 'Este e-mail já está cadastrado.';
    notifyListeners();
    return ok;
  }

  Future<void> alternarTema() async {
    _temaEscuro = !_temaEscuro;
    notifyListeners();
    await _prefs.salvarTemaEscuro(_temaEscuro);
  }

  Future<void> logout() async {
    _usuario = null;
    await _prefs.limparSessao();
    notifyListeners();
  }
}
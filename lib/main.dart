import 'package:flutter/material.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/editor_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthViewModel();
  final docs = DocumentosViewModel();
  await auth.carregarPreferencias(); 
  runApp(MeuApp(auth: auth, docs: docs));
}

class MeuApp extends StatelessWidget {
  final AuthViewModel auth;
  final DocumentosViewModel docs;
  const MeuApp({super.key, required this.auth, required this.docs});

  ThemeData _tema(Brightness brilho) => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: brilho),
        useMaterial3: true,
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: auth,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Leitor e Editor de Documentos',
        theme: _tema(Brightness.light),
        darkTheme: _tema(Brightness.dark),
        themeMode: auth.temaEscuro ? ThemeMode.dark : ThemeMode.light,
        initialRoute: auth.usuario != null ? '/home' : '/',
        routes: {
          '/': (context) => LoginView(auth: auth),
          '/cadastro': (context) => CadastroView(auth: auth),
          '/home': (context) => HomeView(auth: auth, docs: docs),
          '/editor': (context) => EditorView(docs: docs),
        },
      ),
    );
  }
}
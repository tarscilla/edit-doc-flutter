import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';

class HomeView extends StatefulWidget {
  final AuthViewModel auth;
  final DocumentosViewModel docs;
  const HomeView({super.key, required this.auth, required this.docs});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _editorController = TextEditingController();
  String? _idNoEditor;
  String _conteudoNoEditor = '';

  @override
  void initState() {
    super.initState();
    widget.docs.addListener(_sincronizarEditor);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = widget.auth.usuario;
      if (u != null) widget.docs.carregar(u.email);
    });
  }

  @override
  void dispose() {
    widget.docs.removeListener(_sincronizarEditor);
    _editorController.dispose();
    super.dispose();
  }

  void _sincronizarEditor() {
    final s = widget.docs.selecionado;
    if (s == null) {
      _idNoEditor = null;
      _conteudoNoEditor = '';
      _editorController.text = '';
      return;
    }
    if (s.id != _idNoEditor || s.conteudo != _conteudoNoEditor) {
      _idNoEditor = s.id;
      _conteudoNoEditor = s.conteudo;
      if (_editorController.text != s.conteudo) {
        _editorController.text = s.conteudo;
      }
    }
  }

  void _mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _salvar() async {
    await widget.docs.salvarConteudo(_editorController.text);
    if (!mounted) return;
    _mostrarMensagem('Documento salvo com sucesso!');
  }

  void _exportarPdf() {
    final titulo = widget.docs.selecionado?.titulo ?? '';
    _mostrarMensagem('Exportando "$titulo" para PDF (simulação)');
  }

  Future<void> _novo() async {
    await widget.docs.salvarConteudo(_editorController.text);
    if (!mounted) return;
    Navigator.pushNamed(context, '/editor');
  }

  Future<void> _editar() async {
    await widget.docs.salvarConteudo(_editorController.text);
    if (!mounted) return;
    Navigator.pushNamed(context, '/editor', arguments: widget.docs.selecionado);
  }

  Future<void> _excluir() async {
    final doc = widget.docs.selecionado;
    if (doc == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir documento?'),
        content: Text('"${doc.titulo}" será removido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) await widget.docs.excluir(doc.id);
  }

  Future<void> _sair() async {
    await widget.auth.logout();
    widget.docs.limpar();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.auth, widget.docs]),
      builder: (context, _) {
        final docs = widget.docs;
        final lista = docs.documentos;
        final doc = docs.selecionado;
        final leitura = docs.modoLeitura;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Leitor e Editor'),
            actions: [
              IconButton(
                icon: Icon(widget.auth.temaEscuro ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Alternar tema',
                onPressed: widget.auth.alternarTema,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sair',
                onPressed: _sair,
              ),
            ],
          ),
          body: docs.carregando
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meus documentos${widget.auth.usuario != null ? ' - ${widget.auth.usuario!.nome}' : ''}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: Card(
                          child: lista.isEmpty
                              ? const Center(child: Text('Nenhum documento. Toque em "Novo".'))
                              : ListView.builder(
                                  itemCount: lista.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.description),
                                      title: Text(lista[index].titulo),
                                      selected: index == docs.indiceSelecionado,
                                      onTap: () => docs.selecionar(index, _editorController.text),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _novo,
                            icon: const Icon(Icons.add),
                            label: const Text('Novo'),
                          ),
                          ElevatedButton.icon(
                            onPressed: doc == null ? null : _editar,
                            icon: const Icon(Icons.edit_note),
                            label: const Text('Editar'),
                          ),
                          ElevatedButton.icon(
                            onPressed: doc == null ? null : _excluir,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Excluir'),
                          ),
                          ElevatedButton.icon(
                            onPressed: (doc == null || leitura) ? null : _salvar,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                          ),
                          ElevatedButton.icon(
                            onPressed: doc == null ? null : _exportarPdf,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Exportar PDF'),
                          ),
                          OutlinedButton.icon(
                            onPressed: doc == null
                                ? null
                                : () => docs.alternarModoLeitura(_editorController.text),
                            icon: Icon(leitura ? Icons.edit : Icons.chrome_reader_mode),
                            label: Text(leitura ? 'Modo Edição' : 'Modo Leitura'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doc?.titulo ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: doc == null
                            ? const SizedBox.shrink()
                            : leitura
                                ? Card(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          doc.conteudo.isEmpty ? '(documento vazio)' : doc.conteudo,
                                          style: const TextStyle(fontSize: 16, height: 1.5),
                                        ),
                                      ),
                                    ),
                                  )
                                : TextFormField(
                                    controller: _editorController,
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      hintText: 'Digite o conteúdo do documento...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: Container(
            height: 48,
            color: Colors.indigo,
            alignment: Alignment.center,
            child: const Text(
              'Desenvolvido por Tarscilla Silva Almeida',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        );
      },
    );
  }
}
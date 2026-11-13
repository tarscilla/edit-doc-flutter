import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../viewmodels/documentos_viewmodel.dart';

class EditorView extends StatefulWidget {
  final DocumentosViewModel docs;
  const EditorView({super.key, required this.docs});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _conteudoController = TextEditingController();
  Documento? _doc; // null = criando; preenchido = editando
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Documento) {
      _doc = arg;
      _tituloController.text = arg.titulo.replaceAll(RegExp(r'\.txt$', caseSensitive: false), '');
      _conteudoController.text = arg.conteudo;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_doc == null) {
      await widget.docs.criar(_tituloController.text, _conteudoController.text);
    } else {
      await widget.docs.atualizar(
        _doc!.copyWith(titulo: _tituloController.text, conteudo: _conteudoController.text),
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documento salvo com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_doc == null ? 'Novo documento' : 'Editar documento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Salvar',
            onPressed: _salvar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Nome do documento',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome do documento' : null,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _conteudoController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Digite o conteúdo do documento...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _salvar,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
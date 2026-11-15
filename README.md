# edit-doc-flutter

App "Leitor e Editor de Documentos" em Flutter, organizado na arquitetura MVVM (Model-View-ViewModel).

Autora: Tarscilla Silva Almeida

## Relatório de Migração Arquitetural (DartPad → MVVM)

### 1. Mapeamento de Classes e Widgets

| Item no código do DartPad | Novo local | Camada |
|---|---|---|
| `main()` e `MeuApp` (MaterialApp, tema, rotas nomeadas) | `lib/main.dart` | Entrada |
| `validarNome`, `validarEmail`, `validarSenha` | `lib/utils/validadores.dart` | Utils |
| `Documento` (titulo, conteudo) | `lib/models/documento.dart` (agora com `id`, `atualizadoEm`, `toMap`/`fromMap`/`copyWith`) | Model |
| (novo) dados do usuário | `lib/models/usuario.dart` | Model |
| (novo) persistência de tema e sessão | `lib/models/services/preferences_service.dart` | Model (service) |
| (novo) cadastro/autenticação de usuários | `lib/models/services/banco_local_service.dart` | Model (service) |
| (novo) CRUD de documentos em JSON | `lib/models/services/documento_storage_service.dart` | Model (service) |
| Lógica de `_fazerLogin` e `_cadastrar` dentro dos widgets | `lib/viewmodels/auth_viewmodel.dart` | ViewModel |
| Lista `_documentos`, `_selecionado`, `_modoLeitura` e métodos `_selecionar`, `_novoDocumento`, `_salvar`, `_alternarModoLeitura` de `_TelaHomeState` | `lib/viewmodels/documentos_viewmodel.dart` | ViewModel |
| `TelaLogin` / `_TelaLoginState` | `lib/views/login_view.dart` (`LoginView`, rota `/`) | View |
| `TelaCadastro` / `_TelaCadastroState` | `lib/views/cadastro_view.dart` (`CadastroView`, rota `/cadastro`) | View |
| `TelaHome` / `_TelaHomeState` (somente interface) | `lib/views/home_view.dart` (`HomeView`, rota `/home`) | View |
| (novo, Etapa 5) criação/edição de documento | `lib/views/editor_view.dart` (`EditorView`, rota `/editor`) | View |

### 2. Alterações de Estrutura e Imports

- O arquivo único foi dividido em um arquivo por responsabilidade. Somente views e `main.dart` importam `package:flutter/material.dart`; models e services não dependem de widgets, e os ViewModels importam apenas `flutter/foundation.dart` (`ChangeNotifier`).
- Os imports são relativos (`../models/...`, `../viewmodels/...`, `../utils/...`) e seguem uma direção única: View → ViewModel → Model/Service.
- As funções de validação, que eram globais, continuam funções de nível superior, agora em `validadores.dart`, importadas pelas views de login e cadastro.
- As views passaram a receber os ViewModels por **construtor** (`LoginView(auth: auth)`, `HomeView(auth: auth, docs: docs)`). As instâncias são criadas uma única vez no `main()` e compartilhadas, e por isso a lista `routes` deixou de usar `const`.
- Os atributos de estado nos ViewModels ficaram privados (`_documentos`, `_selecionado`, `_modoLeitura`...) e expostos por **getters**, de modo que a View só lê o estado e altera tudo por métodos.
- Foi preciso adicionar `id` ao `Documento` (para localizar o item ao editar/excluir) e `toMap`/`fromMap` (serialização JSON).
- As rotas nomeadas `/`, `/cadastro`, `/home` e `/editor` ficam centralizadas no `MaterialApp`. A rota inicial é `/home` quando há sessão salva e `/` caso contrário.
- O `main()` virou `async` com `WidgetsFlutterBinding.ensureInitialized()` para carregar tema e sessão antes do `runApp`.
- Os `TextEditingController`s e `GlobalKey<FormState>` permaneceram nas views, por serem estado puramente visual.

### 3. Mudanças no Gerenciamento de Estado

**`setState()` removidos das views.** No `_TelaHomeState` original havia `setState` em `_selecionar`, `_novoDocumento`, `_salvar` e `_alternarModoLeitura`. Todos foram eliminados. As telas de Login e Cadastro não usavam `setState`; agora elas exibem um indicador de carregamento durante a operação assíncrona, controlado pelo ViewModel.

**Variáveis de estado que passaram para os ViewModels:**

- `DocumentosViewModel`: `documentos` (antes `_documentos`), índice do documento selecionado (antes `_selecionado`), `modoLeitura` (antes `_modoLeitura`) e `carregando`.
- `AuthViewModel`: `usuario` (sessão), `temaEscuro`, `carregando` e `erro`.

**Como as telas reagem:** o ViewModel estende `ChangeNotifier` e chama `notifyListeners()` sempre que o estado muda. A View envolve o trecho que depende do estado em um `ListenableBuilder(listenable: viewModel, builder: ...)`, e só esse trecho é reconstruído. Na Home usa-se `Listenable.merge([auth, docs])` para escutar os dois ViewModels. O `MaterialApp` escuta o `AuthViewModel`, por isso o tema muda imediatamente. O campo de texto do editor é sincronizado com o documento selecionado por um listener registrado em `initState` e removido em `dispose`.

### Observações sobre mudanças de comportamento

- O diálogo "Novo documento" (`_novoDocumento`) do DartPad foi substituído pela tela `EditorView` (rota `/editor`), que serve tanto para criar quanto para editar.
- Foram adicionados os botões Editar e Excluir na Home, ligados ao `DocumentosViewModel`.
- `Exportar PDF` continua como simulação (mensagem na tela), como no DartPad.

## Etapa 5: Persistência e CRUD

- `PreferencesService` guarda o tema (`bool`) e a sessão do usuário (`String` JSON) em `shared_preferences`.
- `DocumentoStorageService` implementa Create, Read, Update e Delete, serializando a lista de `Documento` com `jsonEncode`/`jsonDecode` em `shared_preferences`, com uma lista por usuário.
- `EditorView` cria e edita documentos pelo `DocumentosViewModel`; a exclusão é feita na Home, também pelo ViewModel.
- Ao recarregar a página, os documentos, o tema e a sessão permanecem salvos.

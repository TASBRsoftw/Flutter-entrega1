# Relatório - Laboratório 2: Gerenciador de Tarefas

## 1. Implementações Realizadas
O projeto Task Manager Pro evoluiu para uma interface profissional, seguindo os padrões do Material Design 3. As principais funcionalidades implementadas incluem:
- Cadastro, edição e exclusão de tarefas com validação de campos obrigatórios.
- Cards customizados para exibição das tarefas, com cores e ícones de prioridade.
- Filtros dinâmicos (todas, pendentes, concluídas) e estatísticas em tempo real.
- Formulário completo com campos de título, descrição, prioridade e status.
- Feedback visual via SnackBars, Dialogs de confirmação e estados vazios personalizados.
- Pull-to-refresh na lista de tarefas.
- Adição de estatísticas de tarefas (total, pendentes, concluídas) em card destacado.

**Componentes Material Design 3 utilizados:**
- AppBar, Card, FloatingActionButton (FAB), PopupMenuButton, TextFormField, DropdownButtonFormField, SwitchListTile, ElevatedButton, OutlinedButton, SnackBar, AlertDialog, Chips, Badges, Icons.

## 2. Desafios Encontrados
Durante o desenvolvimento, o principal desafio foi implementar a persistência dos dados. Inicialmente, a solução utilizava o pacote `path_provider` para salvar os dados em arquivo local, o que funcionava bem em dispositivos móveis e desktop. No entanto, ao testar a aplicação na web, ocorreu o erro `MissingPluginException` ao tentar acessar o diretório de documentos, pois o método não é suportado no navegador. Para contornar esse problema, foi necessário criar uma camada de abstração para o armazenamento, utilizando `localStorage` no web e arquivo local nas demais plataformas. Essa adaptação exigiu ajustes na inicialização do serviço de dados. No momento, ao fechar a aba do Chrome, ocorre a perda das tarefas, e portanto a persistência dos dados é algo que pode ser aprimorado futuramente.

## 3. Melhorias Implementadas
Além do roteiro proposto, foram realizadas as seguintes melhorias:
- Customização visual dos cards de tarefa, com bordas, gradientes e animações suaves.
- Implementação de data de vencimento para as tarefas, com funcionalidades como alerta via snackbar de tarefas vencidas
- Adição de categorias para as tarefas, permitindo a criação e atribuição de categorias para as tarefas, assim como filtros dedicados.


## 4. Aprendizados
Os principais conceitos aprendidos neste laboratório foram:
- Aplicação dos princípios do Material Design 3 no Flutter, incluindo personalização de componentes e hierarquia visual.
- Gerenciamento de navegação entre telas com o Navigator e rotas nomeadas.
- Criação de formulários robustos com validação em tempo real.


## 5. Próximos Passos
Para evoluir ainda mais a aplicação, o próximo passo pode ser migrar a persistência dos dados para um banco não relacional, como o MongoDB. Isso permitirá escalabilidade, sincronização entre dispositivos e integração com funcionalidades avançadas, como backup, compartilhamento e notificações em tempo real. Também está nos planos aprimorar o gerenciamento de categorias, adicionar notificações locais e exportação/importação de tarefas.

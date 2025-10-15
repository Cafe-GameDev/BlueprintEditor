# BlueprintEditor - Plugin Design Document (PDD)

**Versão do Documento:** 1.0
**Data:** 2025-10-14
**Autor:** Café GameDev

---

## 1. Visão Geral e Filosofia

### 1.1. Conceito

O **BlueprintEditor** é um plugin para Godot Engine 4.x, parte da suíte CafeEngine, que oferece um **editor visual/NoCode de alto nível** para construir e gerenciar a lógica de jogo de forma intuitiva e baseada em grafos. Inspirado no sistema de Blueprints da Unreal Engine, ele visa orquestrar `Resources` inteligentes criados sob a filosofia de Programação Orientada a Resources (ROP).

### 1.2. Filosofia Central

Diferente de plugins que substituem a programação em GDScript, o BlueprintEditor atua como uma **ferramenta de manipulação e visualização**. Ele não é uma linguagem de script em si, mas uma interface gráfica para interagir e organizar os `Resources` da CafeEngine. Seu propósito é:

*   **Orquestração Visual:** Traduzir a modularidade e a inteligência dos `Resources` em um diagrama de fluxo claro e editável.
*   **Complementaridade:** Fornecer uma camada visual para outros plugins da CafeEngine, como o StateMachine, permitindo a manipulação de seus `Resources` de forma gráfica.
*   **NoCode/LowCode:** Capacitar desenvolvedores e designers a criar lógica complexa sem a necessidade de escrever código diretamente, focando na arquitetura e no fluxo.

### 1.3. Política de Versão e Compatibilidade

*   **Versão Alvo:** Godot 4.5+ (essa é a versão alvo para todos os plugins da CafeEngine).
*   **Compatibilidade:** Mantida com versões futuras da série 4.x.
*   **Retrocompatibilidade:** Não haverá suporte para versões anteriores a 4.5.

---

## 2. Arquitetura Central do Plugin

O BlueprintEditor será implementado como um `TopPanel` dedicado no editor Godot, utilizando componentes nativos para criar uma experiência de usuário coesa.

### 2.1. Componentes Principais

*   **`BlueprintTopPanel` (Control):** A cena principal do editor visual, que será instanciada como um `TopPanel`.
    *   **`GraphEdit`:** O coração do editor visual, fornecendo a tela interativa para criar, conectar e organizar nós.
    *   **`GraphNode`:** Representará visualmente as "Machines" e "Behaviors" (ou outros `Resources` de plugins integrados). Cada `GraphNode` terá "portas" para conexões e exibirá informações contextuais.
    *   **Toolbox/Paleta de Resources:** Uma área lateral (ou um `PopupMenu` contextual) que listará os tipos de `Resources` disponíveis para serem arrastados e soltos no grafo, criando novos nós.
    *   **Inspector Integrado:** Ao selecionar um `GraphNode`, suas propriedades detalhadas serão exibidas no Inspector padrão do Godot, permitindo a configuração do `Resource` subjacente.

### 2.2. Integração com `ResourceEditor` (TopPanel)

O BlueprintEditor será acessível como uma aba principal no editor Godot, similar às abas "2D", "3D" ou "Script". Isso garante um espaço de trabalho amplo e dedicado para a criação de grafos complexos.

### 2.3. Módulos CrossPlugin (O Coração da Extensibilidade)

O BlueprintEditor não é apenas um editor de grafos; ele é um **host genérico para Módulos CrossPlugin**. Esses módulos são extensões de outros plugins da CafeEngine que se registram no BlueprintEditor para fornecer interfaces visuais especializadas.

*   **Conceito:** Um Módulo CrossPlugin é uma interface visual e funcional que reside dentro do BlueprintEditor, permitindo a manipulação de `Resources` e lógica de um plugin específico (ex: StateMachine, DataBehavior) de forma gráfica e interativa.
*   **Contrato de Integração:** Para se registrar, um plugin deve fornecer ao BlueprintEditor:
    *   Um nome de módulo (ex: "StateBlue", "CutBlue").
    *   Uma cena ou `Control` que representará a interface do módulo dentro do BlueprintEditor.
    *   Métodos para lidar com a ativação/desativação do módulo, e para receber contexto (ex: `StateComponent` selecionado).
    *   Uma lista de "modos" ou "abas" que o módulo oferece (ex: `ComponentBuild`, `ResourceEdit`, `ScriptNew`).
*   **Benefício:** Centraliza a experiência de edição visual em um único `TopPanel`, promovendo consistência e eliminando a necessidade de múltiplos painéis modais ou docks.

#### 2.3.1. `BlueprintStateModule` (StateBlue) - O Primeiro Módulo CrossPlugin

O `BlueprintStateModule` (apelidado de **StateBlue**) é o primeiro e principal exemplo de um Módulo CrossPlugin, projetado para integrar o StateMachine ao BlueprintEditor.

*   **Propósito:** Fornecer uma interface visual completa para a manipulação de `StateComponent`s, `Machines` e `Behaviors` do plugin StateMachine.
*   **Ativação:** O módulo StateBlue pode ser acessado a qualquer momento através do BlueprintEditor. Ele manterá um histórico dos **`StateComponent`s, `Resources` (como `StateBehavior`s e `Machines`) e scripts** abertos recentemente, garantindo acesso rápido e contínuo.
*   **Integração no SceneTree (Opcional):** Uma melhoria desejável, se tecnicamente viável, seria a exibição de um ícone 'StateBlue' ao lado de um `StateComponent` no SceneTree, permitindo acesso direto.
*   **Modos de Operação (Sidebar/Tabs):** StateBlue oferecerá uma sidebar (ou sistema de abas) com os seguintes modos:
    1.  **`ComponentBuild` (Maestro do Grafo):**
        *   **Finalidade:** Manipulação visual do `StateComponent` através de um editor de grafo.
        *   **Funcionalidade:** Arrastar e soltar `Machines` (domínios como `Move`, `Attack`, `AI`) e `Behaviors` (comportamentos como `Idle`, `Walk`, `SwordStab`) no grafo. Conectar visualmente para orquestrar o `StateComponent`.
        *   **Impacto:** Substitui a necessidade de edição manual complexa e visualiza o fluxo de estados de forma intuitiva.
    2.  **`ResourceEdit` (Precisão do Detalhe):**
        *   **Finalidade:** Edição otimizada das propriedades de um `StateBehavior` ou `Machine` selecionado.
        *   **Funcionalidade:** Apresenta um painel focado (potencialmente com um `EditorInspector` customizado ou um formulário amigável) para ajustar cada detalhe do `Resource`.
        *   **Integração:** Pode ser acessado diretamente do grafo (selecionando um nó) ou do `StateBottomPanel` (clicando no botão "StateBlue" para um item selecionado).
    3.  **`ScriptNew` (Gênese da Inovação):**
        *   **Finalidade:** Criação guiada de novos `StateBehavior`s e seus scripts associados.
        *   **Funcionalidade:** Um "wizard" com campos para nome, tipo base, etc., e um botão para gerar o `.tres` e o `.gd` a partir de templates inteligentes.
        *   **Benefício:** Reduz o boilerplate e acelera a prototipagem de novos comportamentos.

---

## 3. Estrutura de Arquivos Padrão

```
addons/blueprint_editor/
├── plugin.cfg
├── panel/
│   ├── blueprint_top_panel.gd
│   └── blueprint_top_panel.tscn
├── scripts/
│   └── editor_plugin.gd
├── utils/
│   └── blueprint_editor.gd # Autoload Singleton (para utilitários globais do BlueprintEditor)
└── icons/
    └── blueprint_icon.svg # Ícone para o TopPanel e GraphNodes
```

---

## 4. Funcionalidades Detalhadas

### 4.1. Editor de Grafo (`GraphEdit`)

*   **Criação de Nós:** Arrastar `Resources` da Toolbox/FileSystem para o `GraphEdit` para criar `GraphNode`s.
*   **Conexão de Nós:** Desenhar linhas entre as portas dos `GraphNode`s para representar relações (transições, fluxo de dados, etc.).
*   **Edição de Nós:** Selecionar um `GraphNode` para exibir e editar as propriedades do `Resource` associado no Inspector do Godot.
*   **Layout e Organização:** Ferramentas para organizar os nós no grafo (auto-layout, alinhamento, agrupamento).

### 4.2. Nós do Grafo (`GraphNode`)

*   **Representação Visual:** Cada `GraphNode` será uma representação visual de um `Resource` (ex: `StateBehavior`, `MoveMachine`).
*   **Portas:** As portas de entrada e saída permitirão a conexão entre os nós, representando o fluxo lógico.
*   **Informações Contextuais:** Exibirá o nome do `Resource`, seu tipo e, opcionalmente, um ícone ou um pequeno preview.

### 4.3. Toolbox/Paleta de Resources

*   Uma lista filtrável de `Resources` compatíveis (ex: todos os `StateBehavior`s, `DataResource`s) que podem ser arrastados para o `GraphEdit`.

### 4.4. Inspector Integrado

*   Ao selecionar um `GraphNode`, o Inspector padrão do Godot será atualizado para exibir as propriedades do `Resource` associado, permitindo edição direta.

### 4.5. Sincronização e Persistência

*   O editor visual deve sincronizar automaticamente as alterações feitas no grafo com os `Resources` subjacentes e vice-versa.
*   O layout dos nós no `GraphEdit` (posições, conexões) deve ser salvo e carregado junto com o `Resource` principal que está sendo editado (ex: um `StateComponent` ou uma `Machine` abstrata).

---

## 5. Integração Cross-Plugin (StateBlue como Exemplo)

O BlueprintEditor é projetado para ser uma ferramenta genérica de visualização de grafos. Sua funcionalidade real é ativada quando integrada a outros plugins da CafeEngine.

### 5.1. StateBlue (Integração StateMachine + BlueprintEditor)

*   **Manipulação Visual de `StateComponent`:** O principal caso de uso inicial será permitir que o usuário manipule um `StateComponent` de forma visual.
*   **Arrastar Machines e Behaviors:** O usuário poderá arrastar `Machines` (domínios como `MoveMachine`, `AttackMachine`) e `Behaviors` (comportamentos como `Idle`, `Walk`, `Run`) para o grafo, conectando-os para definir o fluxo de estados.
*   **Machines (Domínios):** Representarão os domínios funcionais do `StateComponent` (ex: `MoveMachine` para o domínio "movement"). Cada `Machine` poderá conter múltiplos `Behaviors`.
*   **Behaviors (Lógicas Específicas):** Serão os `StateBehavior`s do plugin StateMachine, que definirão a lógica específica dentro de uma `Machine`.

### 5.2. Outros Plugins

Outros plugins da CafeEngine (como `DataBehavior`, `EventCafe`, `QuestCafe`) poderão estender o BlueprintEditor para criar suas próprias visualizações de grafo para manipulação de seus `Resources` específicos.

---

## 6. Plano de Desenvolvimento em Fases

### Fase 1: Fundação (MVP - Editor de Grafo Básico)

*   [ ] **Configurar `BlueprintTopPanel`:** Criar a cena `blueprint_top_panel.tscn` e o script `blueprint_top_panel.gd` como um `TopPanel` vazio.
*   [ ] **Integrar `GraphEdit`:** Adicionar um nó `GraphEdit` ao `BlueprintTopPanel`.
*   [ ] **Autoload `BlueprintEditor`:** Configurar o `blueprint_editor.gd` como um singleton para utilitários globais.
*   [ ] **Registro de Plugin:** Configurar `editor_plugin.gd` para registrar o `BlueprintEditor` como um `TopPanel`.
*   **Objetivo:** Ter um `TopPanel` funcional com um `GraphEdit` vazio, pronto para receber nós.

### Fase 2: Integração com StateMachine (StateBlue - Criação e Conexão de Nós)

*   [ ] **Definir Interface de Integração:** Criar um sistema no `BlueprintEditor` que permita a outros plugins (como StateMachine) registrar seus tipos de `Resources` e como eles devem ser representados como `GraphNode`s.
*   [ ] **Criação de `GraphNode`s para `StateBehavior`s:** Implementar a lógica para arrastar `StateBehavior`s da Toolbox/FileSystem para o `GraphEdit` e criar `GraphNode`s correspondentes.
*   [ ] **Conexão de `GraphNode`s:** Permitir a conexão visual entre `GraphNode`s que representam `StateBehavior`s, e traduzir essas conexões em referências `next_state` dentro dos `Resources` (ou um `StateTransition` Resource futuro).
*   [ ] **Sincronização Básica:** Garantir que as alterações no grafo (criação/conexão de nós) se reflitam nos `Resources` do StateMachine e vice-versa.
*   **Objetivo:** Permitir a manipulação visual básica de `StateBehavior`s do StateMachine através do BlueprintEditor.

### Fase 3: Expansão e Refinamento da UI/UX

*   [ ] **Toolbox/Paleta de Resources:** Implementar uma interface para listar e filtrar `Resources` compatíveis para arrastar e soltar.
*   [ ] **Inspector Integrado:** Melhorar a experiência de edição de propriedades de `Resources` via Inspector ao selecionar um `GraphNode`.
*   [ ] **Layout Persistente:** Implementar o salvamento e carregamento do layout dos nós no grafo.
*   [ ] **Depuração Visual:** Adicionar funcionalidades para destacar o `StateBehavior` ativo durante a execução do jogo.
*   **Objetivo:** Tornar o BlueprintEditor uma ferramenta visual intuitiva e eficiente para o StateMachine.

### Fase 4: Documentação e Exemplos

*   [ ] **Documentar o Código:** Adicionar comentários claros em todas as classes e funções principais.
*   [ ] **Criar Documentação Externa:** Escrever guias no formato Markdown na pasta `docs/` do plugin, incluindo tutoriais de integração com o StateMachine.
*   [ ] **Criar um Projeto Demo Completo:** Montar um pequeno jogo ou cena de exemplo que utilize o BlueprintEditor para manipular o StateMachine.
*   **Objetivo:** Garantir que o plugin seja acessível e fácil de aprender para novos usuários e integradores.

---

## 7. Considerações Futuras

*   **Suporte a Outros Plugins:** Estender a integração para `DataBehavior`, `EventCafe`, etc.
*   **Nós Customizados:** Permitir que desenvolvedores criem seus próprios tipos de `GraphNode`s para `Resources` específicos.
*   **Sub-grafos/Máquinas Aninhadas:** Funcionalidade para criar grafos dentro de outros nós, permitindo hierarquia.
*   **Geração de Código:** Capacidade de gerar GDScript a partir do grafo visual (para casos específicos).
*   **Versionamento de Grafos:** Integração com sistemas de controle de versão para grafos.

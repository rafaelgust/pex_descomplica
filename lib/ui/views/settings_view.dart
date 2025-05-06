import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  final appNameController = TextEditingController();
  final apiAddressController = TextEditingController();
  late TabController _tabController;
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'João Silva',
      'email': 'joao@exemplo.com',
      'role': 'Administrador',
    },
    {'name': 'Maria Oliveira', 'email': 'maria@exemplo.com', 'role': 'Gestor'},
    {
      'name': 'Carlos Santos',
      'email': 'carlos@exemplo.com',
      'role': 'Convidado',
    },
  ];

  // Exemplos de logs
  final List<Map<String, dynamic>> _logs = [
    {
      'title': 'Login realizado',
      'description': 'Usuário João acessou o sistema',
      'time': '10:30',
      'date': 'Hoje',
    },
    {
      'title': 'Configuração alterada',
      'description': 'API endpoint atualizado',
      'time': '09:15',
      'date': 'Hoje',
    },
    {
      'title': 'Novo usuário',
      'description': 'Maria foi adicionada como editor',
      'time': '18:45',
      'date': 'Ontem',
    },
    {
      'title': 'Backup automático',
      'description': 'Backup completo realizado',
      'time': '00:00',
      'date': 'Ontem',
    },
    {
      'title': 'Manutenção agendada',
      'description': 'Sistema ficará offline por 30min',
      'time': '14:20',
      'date': '02/05',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    appNameController.text = "Meu Aplicativo";
    apiAddressController.text = "https://api.meuapp.com.br/v1";
  }

  @override
  void dispose() {
    _tabController.dispose();
    appNameController.dispose();
    apiAddressController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações salvas com sucesso!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'Convidado';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Adicionar Usuário'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Função',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'Administrador',
                        child: Text('Administrador'),
                      ),
                      DropdownMenuItem(value: 'Gestor', child: Text('Gestor')),
                      DropdownMenuItem(
                        value: 'Convidado',
                        child: Text('Convidado'),
                      ),
                    ],
                    onChanged: (value) {
                      selectedRole = value!;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              FilledButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      emailController.text.isNotEmpty) {
                    setState(() {
                      _users.add({
                        'name': nameController.text,
                        'email': emailController.text,
                        'role': selectedRole,
                      });
                    });
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Usuário adicionado com sucesso!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('ADICIONAR'),
              ),
            ],
          ),
    );
  }

  void _showEditUserDialog(int index) {
    final nameController = TextEditingController(text: _users[index]['name']);
    final emailController = TextEditingController(text: _users[index]['email']);
    String selectedRole = _users[index]['role'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Editar Usuário'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Função',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'Administrador',
                        child: Text('Administrador'),
                      ),
                      DropdownMenuItem(value: 'Gestor', child: Text('Gestor')),
                      DropdownMenuItem(
                        value: 'Convidado',
                        child: Text('Convidado'),
                      ),
                    ],
                    onChanged: (value) {
                      selectedRole = value!;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _users[index] = {
                      'name': nameController.text,
                      'email': emailController.text,
                      'role': selectedRole,
                    };
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário atualizado com sucesso!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('SALVAR'),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Confirmar exclusão'),
                          content: Text(
                            'Tem certeza que deseja excluir o usuário ${_users[index]['name']}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCELAR'),
                            ),
                            FilledButton(
                              onPressed: () {
                                setState(() {
                                  _users.removeAt(index);
                                });
                                Navigator.pop(context);
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Usuário removido com sucesso!',
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('EXCLUIR'),
                            ),
                          ],
                        ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('EXCLUIR'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Salvar configurações',
            onPressed: _saveSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'Geral'),
            Tab(icon: Icon(Icons.people), text: 'Usuários'),
            Tab(icon: Icon(Icons.history), text: 'Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configurações Gerais',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Informações do Aplicativo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: appNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do Aplicativo',
                            prefixIcon: Icon(Icons.app_shortcut),
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Versão XX',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.cloud, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Conexão',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: apiAddressController,
                          decoration: const InputDecoration(
                            labelText: 'Endereço da API',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: 'https://api.exemplo.com',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Testando conexão...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text('Testar Conexão'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  apiAddressController.text =
                                      'https://api.meuapp.com.br/v1';
                                },
                                icon: const Icon(Icons.restart_alt),
                                label: const Text('Restaurar Padrão'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.color_lens, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Aparência',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Modo Escuro'),
                          subtitle: const Text(
                            'Ativar tema escuro no aplicativo',
                          ),
                          value: isDarkMode,
                          onChanged: (value) {
                            setState(() {
                              isDarkMode = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Notificações'),
                          subtitle: const Text('Habilitar notificações push'),
                          value: notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              notificationsEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gerenciar Usuários',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _showAddUserDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Novo Usuário'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: ListView.separated(
                      itemCount: _users.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text(user['name'][0])),
                          title: Text(user['name']),
                          subtitle: Text(user['email']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(user['role']),
                                backgroundColor:
                                    user['role'] == 'Administrador'
                                        ? Colors.red[100]
                                        : user['role'] == 'Gestor'
                                        ? Colors.amber[100]
                                        : Colors.green[100],
                                labelStyle: TextStyle(
                                  color:
                                      user['role'] == 'Administrador'
                                          ? Colors.red[900]
                                          : user['role'] == 'Gestor'
                                          ? Colors.amber[900]
                                          : Colors.green[900],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditUserDialog(index),
                                tooltip: 'Editar usuário',
                              ),
                            ],
                          ),
                          onTap: () => _showEditUserDialog(index),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Logs do Sistema',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logs exportados com sucesso!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Exportar Logs'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    child: ListView.separated(
                      itemCount: _logs.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.article,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(log['title']),
                          subtitle: Text(log['description']),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                log['time'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                log['date'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('© 2025 Meu Aplicativo'), Spacer()],
          ),
        ),
      ),
    );
  }
}

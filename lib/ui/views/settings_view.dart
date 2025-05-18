import 'package:flutter/material.dart';

import '../../data/models/auth/user_model.dart';
import '../../data/services/injector/injector_service.dart';
import '../controllers/setting_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final SettingController _controller = injector.get<SettingController>();

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

  _loadUsers() async {
    try {
      await _controller.fetchUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível carregar os usuários'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    // Criar o usuário na lista
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
    final nameController = TextEditingController(
      text: _controller.userList.value[index].username,
    );
    final emailController = TextEditingController(
      text: _controller.userList.value[index].email,
    );
    String selectedRole = _controller.userList.value[index].role.name;

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
                  // Editar o usuário na lista
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
                            'Tem certeza que deseja excluir o usuário ${_controller.userList.value[index].username}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCELAR'),
                            ),
                            FilledButton(
                              onPressed: () {
                                // Remover o usuário da lista
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
        title: Center(child: const Text('Configurações')),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Usuários'),
            Tab(icon: Icon(Icons.history), text: 'Logs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
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
                    child: ValueListenableBuilder<List<UserModel>>(
                      valueListenable: _controller.userList,
                      builder: (context, List users, child) {
                        return ListView.separated(
                          itemCount: users.length,
                          separatorBuilder:
                              (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(user.username[0]),
                              ),
                              title: Text(user.username),
                              subtitle: Text(user.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(user.role.name),
                                    backgroundColor:
                                        user.role.name == 'Administrador'
                                            ? Colors.red[100]
                                            : user.role.name == 'Gestor'
                                            ? Colors.amber[100]
                                            : Colors.green[100],
                                    labelStyle: TextStyle(
                                      color:
                                          user.role.name == 'Administrador'
                                              ? Colors.red[900]
                                              : user.role.name == 'Gestor'
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
    );
  }
}

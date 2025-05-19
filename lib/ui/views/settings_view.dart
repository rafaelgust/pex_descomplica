import 'package:flutter/material.dart';

import '../../data/models/auth/user_model.dart';
import '../../data/services/injector/injector_service.dart';
import '../controllers/setting_controller.dart';
import 'widgets/home/setting/add_user_dialog.dart';

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

  _init() async {
    await _loadUsers();
  }

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
    _init();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddUserDialog() {
    showDialog(context: context, builder: (context) => AddUserDialog());
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
                      'Usuários',
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
                              leading:
                                  user.urlAvatar.isNotEmpty
                                      ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          user.urlAvatar,
                                        ),
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                      )
                                      : const CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.person_sharp,
                                          color: Colors.white,
                                        ),
                                      ),
                              title: Text(user.fullName),
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
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text(
                                          'Detalhes do Usuário',
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Nome: ${user.fullName}'),
                                            Text('Usuário: ${user.username}'),
                                            Text('Email: ${user.email}'),
                                            Text('Função: ${user.role.name}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('FECHAR'),
                                          ),
                                        ],
                                      ),
                                );
                              },
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

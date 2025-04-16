import 'package:flutter/material.dart';
import '../../data/repositories/auth/auth_repository.dart';
import '../../data/services/injector/injector_service.dart';

import 'responsive_helper.dart';
import '../../config/routers.dart';

class ProfileView extends StatefulWidget {
  final int userId;

  const ProfileView({super.key, required this.userId});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ResponsiveHelper _responsiveHelper = ResponsiveHelper();
  final AuthRepository _repository = injector.get<AuthRepository>();

  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final userData = await _repository.getCurrentUser();
      userData.fold(
        (error) {
          // Tratar erro ao carregar perfil
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${error.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (user) {
          if (user != null) {
            _userProfile = UserProfile(
              id: user.id,
              name: user.fullName,
              role: user.role.name,
              status: user.verified! ? 'Ativo' : 'Inativo',
              email: user.email,
              lastActivity:
                  user.updated != null ? user.updated! : DateTime.now(),
            );
          }
        },
      );
    } catch (e) {
      // Tratar erro ao carregar perfil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar informações do perfil'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sair do sistema'),
            content: const Text('Tem certeza que deseja sair?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _repository.logout();
                  if (mounted) goToPath(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sair'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        leading: BackButton(onPressed: () => goToPath(context, '/')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: _responsiveHelper.getPadding(context),
      child: Column(
        children: [
          // Header com gradiente e avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                  theme.colorScheme.primary.withValues(alpha: 0.5),
                ],
              ),
            ),
            child: Column(
              children: [
                // Avatar com borda
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: _responsiveHelper.getIconSize(context) * 0.8,
                    backgroundColor: theme.colorScheme.secondary.withValues(
                      alpha: 0.2,
                    ),
                    child: Icon(
                      Icons.person,
                      color: theme.colorScheme.secondary,
                      size: _responsiveHelper.getIconSize(context) * 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Informações do usuário
                Text(
                  _userProfile?.name ?? 'Usuário',
                  style: TextStyle(
                    fontSize: _responsiveHelper.isMobile(context) ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userProfile?.role ?? 'Colaborador',
                  style: TextStyle(
                    fontSize: _responsiveHelper.isMobile(context) ? 16 : 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 12),

                // Badge de status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      _userProfile?.status,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(_userProfile?.status),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStatusColor(_userProfile?.status),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _userProfile?.status ?? 'Ativo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize:
                              _responsiveHelper.isMobile(context) ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Cards de estatísticas
          _buildStatisticsCards(context),

          const SizedBox(height: 24),

          // Atividades recentes
          _buildRecentActivities(context),

          const SizedBox(height: 24),

          // Configurações
          _buildSettingsOptions(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = _responsiveHelper.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            'Visão Geral',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 3,
          shrinkWrap: true,
          childAspectRatio: isMobile ? 1.2 : 1.5,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _StatisticsCard(
              title: 'Total de Produtos',
              value: '567',
              icon: Icons.inventory_2_outlined,
              color: theme.colorScheme.primary,
              change: '+12%',
              isPositive: true,
            ),
            _StatisticsCard(
              title: 'Valor em Estoque',
              value: 'R\$ 15.430',
              icon: Icons.monetization_on_outlined,
              color: Colors.green.shade700,
              change: '+8%',
              isPositive: true,
            ),
            _StatisticsCard(
              title: 'Itens Baixos',
              value: '24',
              icon: Icons.warning_amber_outlined,
              color: Colors.orange.shade700,
              change: '-3%',
              isPositive: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = _responsiveHelper.isMobile(context);

    // Exemplos de atividades
    final activities = [
      {
        'type': 'purchase',
        'title': 'Compra #38921',
        'subtitle': '12 produtos adicionados',
        'time': '2h atrás',
      },
      {
        'type': 'update',
        'title': 'Atualização de preços',
        'subtitle': '5 produtos atualizados',
        'time': '5h atrás',
      },
      {
        'type': 'inventory',
        'title': 'Contagem de estoque',
        'subtitle': 'Realizada com sucesso',
        'time': '1d atrás',
      },
    ];

    IconData _getActivityIcon(String type) {
      switch (type) {
        case 'purchase':
          return Icons.shopping_cart_outlined;
        case 'update':
          return Icons.update_outlined;
        case 'inventory':
          return Icons.inventory_2_outlined;
        default:
          return Icons.event_note_outlined;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atividades Recentes',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Ver todas')),
              ],
            ),
            const Divider(),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Icon(
                      _getActivityIcon(activity['type']!),
                      color: theme.colorScheme.primary,
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                  title: Text(
                    activity['title']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                  subtitle: Text(
                    activity['subtitle']!,
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        activity['time']!,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações',
              style: TextStyle(
                fontSize: _responsiveHelper.isMobile(context) ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            _SettingsItem(
              icon: Icons.person_outline,
              title: 'Editar Perfil',
              onTap: () {},
              color: theme.colorScheme.primary,
            ),
            const Divider(),

            _SettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Preferências de Notificação',
              onTap: () {},
              color: theme.colorScheme.secondary,
            ),
            const Divider(),

            _SettingsItem(
              icon: Icons.lock_outline,
              title: 'Segurança e Privacidade',
              onTap: () {},
              color: Colors.indigo,
            ),
            const Divider(),

            _SettingsItem(
              icon: Icons.language_outlined,
              title: 'Idioma e Região',
              onTap: () {},
              color: Colors.teal,
            ),
            const Divider(),

            _SettingsItem(
              icon: Icons.help_outline,
              title: 'Ajuda e Suporte',
              onTap: () {},
              color: Colors.amber.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'ativo':
        return Colors.green;
      case 'inativo':
        return Colors.red;
      case 'pendente':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

class _StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;
  final bool isPositive;

  const _StatisticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final ResponsiveHelper _responsiveHelper = ResponsiveHelper();
    final isMobile = _responsiveHelper.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: isMobile ? 24 : 28, color: color),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isPositive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: isMobile ? 12 : 14,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ResponsiveHelper _responsiveHelper = ResponsiveHelper();
    final isMobile = _responsiveHelper.isMobile(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: isMobile ? 20 : 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// Modelo para dados do usuário
class UserProfile {
  final String id;
  final String name;
  final String role;
  final String status;
  final String email;
  final DateTime lastActivity;

  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.email,
    required this.lastActivity,
  });
}

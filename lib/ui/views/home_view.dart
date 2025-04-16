import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pex_descomplica/ui/view_models/home_view_model.dart';

import '../../config/constants.dart';
import 'responsive_helper.dart';
import '../../config/routers.dart';
import 'widgets/home/add_item_dialog.dart';
import 'widgets/home/dashboard/dashboard_widget.dart';
import 'widgets/home/estoque_search_delegate.dart';
import 'widgets/home/inventory/inventory_widget.dart';
import 'widgets/home/notifications_dialog.dart';
import 'widgets/home/orders/orders_widget.dart';
import 'widgets/home/reports/reports_widget.dart';
import 'widgets/home/settings/settings_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeViewModel _homeViewModel = HomeViewModel();

  @override
  void dispose() {
    _homeViewModel.dispose();
    super.dispose();
  }

  final ResponsiveHelper _responsiveHelper = ResponsiveHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = _responsiveHelper.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          Constants.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar função de busca
              showSearch(context: context, delegate: EstoqueSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Implementar notificações
              _showNotificationsDialog(context);
            },
          ),
          if (!isMobile)
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                goToPath(context, '/profile/123');
              },
            ),
          const SizedBox(width: 8),
        ],
        leading:
            isMobile
                ? IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                )
                : null,
      ),
      drawer: isMobile ? _buildDrawer(context) : null,
      body: Row(
        children: [
          // Side navigation for tablet and desktop
          if (!isMobile) _buildSideNavigation(context),

          // Main content area
          Expanded(child: _buildBody(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegação para adicionar novo item ao estoque
          _showAddItemDialog(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSideNavigation(BuildContext context) {
    return NavigationRail(
      selectedIndex: _homeViewModel.selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _homeViewModel.selectedIndex = index;
        });
      },
      labelType: NavigationRailLabelType.selected,
      backgroundColor: Colors.white,
      elevation: 4,
      leading: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: _homeViewModel.userFirstName,
              builder: (context, String? firstName, child) {
                return Text(
                  firstName ?? '- - -',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: Text('Estoque'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: Text('Pedidos'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: Text('Fornecedores'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Relatórios'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Configurações'),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: ValueListenableBuilder(
              valueListenable: _homeViewModel.userFullName,
              builder: (context, String? value, child) {
                return Text(
                  value ?? 'Usuário',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                );
              },
            ),
            accountEmail: ValueListenableBuilder(
              valueListenable: _homeViewModel.userEmail,
              builder: (context, String? value, child) {
                return Text(
                  value ?? 'Email',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                );
              },
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue, size: 40),
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: _homeViewModel.selectedIndex == 0,
            onTap: () {
              setState(() {
                _homeViewModel.selectedIndex = 0;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Estoque'),
            selected: _homeViewModel.selectedIndex == 1,
            onTap: () {
              setState(() {
                _homeViewModel.selectedIndex = 1;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Pedidos'),
            selected: _homeViewModel.selectedIndex == 2,
            onTap: () {
              setState(() {
                _homeViewModel.selectedIndex = 2;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Fornecedores'),
            selected: _homeViewModel.selectedIndex == 3,
            onTap: () {
              setState(() {
                _homeViewModel.selectedIndex = 3;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Relatórios'),
            selected: _homeViewModel.selectedIndex == 4,
            onTap: () {
              setState(() {
                _homeViewModel.selectedIndex = 4;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            selected: _homeViewModel.selectedIndex == 5,
            onTap: () {
              setState(() {
                _homeViewModel.selectedIndex = 5;
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              goToPath(context, '/profile/123');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              // Implementar logout
              // Navegar para tela de login
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Conteúdo principal baseado no índice selecionado
    switch (_homeViewModel.selectedIndex) {
      case 0:
        return DashboardWidget();
      case 1:
        return InventoryWidget();
      case 2:
        return OrdersWidget();
      case 3:
        return OrdersWidget();
      case 4:
        return ReportsWidget();
      case 5:
        return SettingsWidget();
      default:
        return DashboardWidget();
    }
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog();
      },
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return NotificationsDialog();
      },
    );
  }
}

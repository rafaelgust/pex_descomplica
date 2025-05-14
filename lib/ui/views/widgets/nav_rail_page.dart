import 'package:flutter/material.dart';

import '../../../config/routers.dart';
import '../../../data/services/injector/injector_service.dart';
import '../../responsive_helper.dart';
import '../../view_models/home_view_model.dart';
import 'home/notifications_dialog.dart';

class NavRailPage extends StatefulWidget {
  final Widget? child;
  const NavRailPage({super.key, this.child});

  @override
  State<NavRailPage> createState() => _NavRailPageState();
}

class _NavRailPageState extends State<NavRailPage>
    with TickerProviderStateMixin {
  final HomeViewModel _homeViewModel = injector.get<HomeViewModel>();
  final ResponsiveHelper _responsiveHelper = ResponsiveHelper();

  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _homeViewModel.initialize();
    _homeViewModel.selectedIndex = _homeViewModel.selectedByLocation(
      Routers.getPath(context),
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    super.dispose();
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return NotificationsDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = _responsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          isMobile
              ? AppBar(
                foregroundColor: Theme.of(context).primaryColor,
                elevation: 2,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => _showNotificationsDialog(context),
                  ),
                ],
              )
              : null,
      drawer: isMobile ? _buildDrawer(context) : null,
      body: Row(
        children: [
          !isMobile
              ? AnimatedBuilder(
                animation: _homeViewModel,
                builder: (context, child) {
                  return NavigationRail(
                    selectedIndex: _homeViewModel.selectedIndex,
                    onDestinationSelected: (int index) {
                      if (index == _homeViewModel.selectedIndex) return;
                      _homeViewModel.onItemTapped(index);

                      Routers.goToNamed(
                        context,
                        _homeViewModel.selectedViewName,
                      );
                    },
                    labelType: NavigationRailLabelType.selected,
                    backgroundColor: Colors.white,
                    elevation: 2,
                    groupAlignment: 0.0,
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            right: 0,
                            left: 0,
                            bottom: 0,
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: ValueListenableBuilder(
                                valueListenable: _homeViewModel.userData,
                                builder: (context, userData, child) {
                                  if (userData == null) {
                                    return const CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person, size: 30),
                                    );
                                  }
                                  return Center(
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage:
                                          Image.network(
                                            userData.urlAvatar,
                                            fit: BoxFit.cover,
                                          ).image,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: 0,
                            left: 30,
                            bottom: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                tooltip: 'Notificações',
                                iconSize: 15,
                                color: Colors.white,
                                onPressed:
                                    () => _showNotificationsDialog(context),
                              ),
                            ),
                          ),
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
                        label: Text('Ordens'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.business_outlined),
                        selectedIcon: Icon(Icons.business),
                        label: Text('Fornecedores'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        selectedIcon: Icon(Icons.people),
                        label: Text('Clientes'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: Text('Configurações'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Perfil'),
                      ),
                    ],
                  );
                },
              )
              : const SizedBox(),
          !isMobile
              ? const VerticalDivider(thickness: 1, width: 1)
              : const SizedBox(),
          Expanded(
            child:
                widget.child != null
                    ? FadeTransition(opacity: _animation!, child: widget.child)
                    : Container(
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          'Select an option from the navigation rail',
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: ValueListenableBuilder(
              valueListenable: _homeViewModel.userData,
              builder: (context, user, child) {
                if (user == null) {
                  return const LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.blue,
                  );
                }
                return Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                );
              },
            ),
            accountEmail: ValueListenableBuilder(
              valueListenable: _homeViewModel.userData,
              builder: (context, user, child) {
                if (user == null) {
                  return const LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.blue,
                  );
                }
                return Text(
                  user.email,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                );
              },
            ),
            currentAccountPicture: ValueListenableBuilder(
              valueListenable: _homeViewModel.userData,
              builder: (context, userData, child) {
                if (userData == null) {
                  return const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 30),
                  );
                }
                return Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        Image.network(
                          userData.urlAvatar,
                          fit: BoxFit.cover,
                        ).image,
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: _homeViewModel.selectedIndex == 0,
            onTap: () {
              _homeViewModel.onItemTapped(0);
              Routers.goToNamed(context, _homeViewModel.selectedViewName);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Estoque'),
            selected: _homeViewModel.selectedIndex == 1,
            onTap: () {
              _homeViewModel.onItemTapped(1);
              Routers.goToNamed(context, _homeViewModel.selectedViewName);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Ordens'),
            selected: _homeViewModel.selectedIndex == 2,
            onTap: () {
              _homeViewModel.onItemTapped(2);
              Routers.goToNamed(context, _homeViewModel.selectedViewName);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Fornecedores'),
            selected: _homeViewModel.selectedIndex == 3,
            onTap: () {
              _homeViewModel.onItemTapped(3);
              Routers.goToNamed(context, _homeViewModel.selectedViewName);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Clientes'),
            selected: _homeViewModel.selectedIndex == 4,
            onTap: () {
              _homeViewModel.onItemTapped(4);
              Routers.goToNamed(context, _homeViewModel.selectedViewName);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configurações'),
            selected: _homeViewModel.selectedIndex == 5,
            onTap: () {
              _homeViewModel.onItemTapped(5);
              Routers.goToNamed(context, _homeViewModel.selectedViewName);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            selected: _homeViewModel.selectedIndex == 6,
            onTap: () {
              _homeViewModel.onItemTapped(6);
              Routers.goToNamed(context, _homeViewModel.selectedViewName);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

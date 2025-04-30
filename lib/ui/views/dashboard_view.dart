import 'package:flutter/material.dart';

import 'widgets/home/dashboard/activity_item.dart';
import 'widgets/home/dashboard/infor_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Simulate a network call or data fetching
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.onPrimary,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: [
              InforCard(
                title: 'Total de Itens',
                value: '1.587',
                icon: Icons.inventory_2,
                color: Colors.blue,
              ),
              InforCard(
                title: 'Itens em Baixa',
                value: '23',
                icon: Icons.warning_amber,
                color: Colors.orange,
              ),
              InforCard(
                title: 'Pedidos Pendentes',
                value: '7',
                icon: Icons.shopping_cart,
                color: Colors.green,
              ),
              InforCard(
                title: 'Valor do Estoque',
                value: 'R\$ 145.782,50',
                icon: Icons.attach_money,
                color: Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Lista de atividades recentes
          const Text(
            'Atividades Recentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ActivityItem(
                  title: 'Produto ${index + 1} atualizado',
                  description:
                      'Quantidade atualizada para ${10 * (index + 1)} unidades',
                  time: '${index + 1}h atrás',
                  icon: Icons.update,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

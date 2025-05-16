import 'package:flutter/material.dart';
import '../../data/models/dashboard/info_card_model.dart';
import '../../data/services/injector/injector_service.dart';
import '../controllers/dashboard_controller.dart';
import '../responsive_helper.dart';

import 'widgets/home/dashboard/desktop_charts.dart';
import 'widgets/home/dashboard/infor_card.dart';
import 'widgets/home/dashboard/mobile_charts.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardController _controller = injector.get<DashboardController>();

  void _setState() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addListener(_setState);
      _loadData();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_setState);
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) {
      await _controller.init();
    }
  }

  Future<void> _updateData() async {
    if (mounted) {
      await _controller.updateInfoCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = ResponsiveHelper();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedButton.icon(
              onPressed: _updateData,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
              style: OutlinedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body:
          _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: Container(
                    width: 1720,
                    constraints: const BoxConstraints(maxWidth: 1720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Resumo do Sistema',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        Center(
                          child: ValueListenableBuilder<List<InfoCardModel>>(
                            valueListenable: _controller.infoCards,
                            builder: (
                              BuildContext context,
                              List<InfoCardModel> value,
                              child,
                            ) {
                              return Wrap(
                                spacing: 20,
                                runSpacing: 20,
                                alignment: WrapAlignment.center,
                                children:
                                    value
                                        .map((i) => InforCard(item: i))
                                        .toList(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Divider(height: 1),
                        const SizedBox(height: 40),
                        responsive.isMobile(context)
                            ? MobileCharts(controller: _controller)
                            : DesktopCharts(controller: _controller),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

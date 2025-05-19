import 'package:flutter/material.dart';
import '../../data/models/dashboard/info_card_model.dart';
import '../../data/models/dashboard/product_pie_chart.dart';
import '../../data/models/invoice/invoices_monthly_model.dart';
import '../../data/services/injector/injector_service.dart';
import '../controllers/dashboard_controller.dart';

import 'widgets/home/dashboard/section_charts.dart';
import 'widgets/home/dashboard/infor_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DashboardController _controller = injector.get<DashboardController>();

  final List<ProductPieChart> _pieChartBest = [];

  final List<ProductPieChart> _pieChartAmount = [];

  final List<InvoicesMonthlyModel> _barChartData = [];

  final List<InfoCardModel> _infoCards = [];

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
      _infoCards.addAll(_controller.infoCards);
      _barChartData.addAll(_controller.invoicesMonthly);
      _pieChartAmount.addAll(await _controller.getDataForPieChartStock());
      _pieChartBest.addAll(await _controller.getDataForPieChartBestSellers());
      setState(() {});
    }
  }

  Future<void> _updateData() async {
    if (mounted) {
      _updateInfoCards();
      _updateBarChartData();
      _updatePieChartData();
    }
  }

  Future<void> _updateInfoCards() async {
    if (mounted) {
      await _controller.updateInfoCards();
      _infoCards.clear();
      _infoCards.addAll(_controller.infoCards);
      setState(() {});
    }
  }

  Future<void> _updateBarChartData() async {
    if (mounted) {
      _barChartData.clear();
      _barChartData.addAll(_controller.invoicesMonthly);
      setState(() {});
    }
  }

  Future<void> _updatePieChartData() async {
    if (mounted) {
      _pieChartAmount.clear();
      _pieChartBest.clear();
      _pieChartAmount.addAll(await _controller.getDataForPieChartStock());
      _pieChartBest.addAll(await _controller.getDataForPieChartBestSellers());

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  child: SizedBox(
                    width: 1720,
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
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children:
                                _infoCards
                                    .map((i) => InforCard(item: i))
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Divider(height: 1),
                        const SizedBox(height: 40),
                        SectionCharts(
                          invoicesMonthly: _barChartData,
                          pieChartBestSellersProducts: _pieChartBest,
                          pieChartAmountStockProducts: _pieChartAmount,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

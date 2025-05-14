import 'package:flutter/material.dart';
import '../responsive_helper.dart';
import 'widgets/home/dashboard/charts/bar_chart_widget.dart';
import 'widgets/home/dashboard/charts/line_chart_widget.dart';
import 'widgets/home/dashboard/charts/pie_chart_widget.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() => _isLoading = false);
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
              onPressed: _loadData,
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
          _isLoading
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
                          child: Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildInfoCard(
                                'Total de Produtos em Estoque',
                                '1.587',
                                'R\$ 145.782,50',
                                Icons.inventory_2,
                                const Color(0xFF3182CE),
                                'itens',
                              ),
                              _buildInfoCard(
                                'Débitos com Fornecedores',
                                '23',
                                'R\$ 1.587,00',
                                Icons.warning_amber,
                                const Color(0xFFDD6B20),
                                'pendências',
                              ),
                              _buildInfoCard(
                                'Vendas Pendentes',
                                '7',
                                'R\$ 1.587,00',
                                Icons.shopping_cart,
                                const Color(0xFF2F855A),
                                'pedidos',
                              ),
                              _buildInfoCard(
                                'Faturamento Mensal',
                                'Mai/2025',
                                'R\$ 28.450,75',
                                Icons.attach_money,
                                const Color(0xFF6B46C1),
                                '+12% vs. Abr',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Divider(height: 1),
                        const SizedBox(height: 40),
                        responsive.isMobile(context)
                            ? _buildMobileCharts()
                            : _buildDesktopCharts(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String amount,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4A5568),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Produtos Populares', Icons.pie_chart),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: PieChartWidget(
            produtos: [
              Produto(
                nome: 'Café',
                quantidade: 30,
                imagemUrl:
                    'https://castronaves.vteximg.com.br/arquivos/ids/384748-1000-1000/9330_01.jpg',
              ),
              Produto(
                nome: 'Açúcar',
                quantidade: 20,
                imagemUrl:
                    'https://carrefourbrfood.vtexassets.com/arquivos/ids/110671165/acucar-refinado-uniao-docucar-1kg-1.jpg',
              ),
              Produto(
                nome: 'Arroz',
                quantidade: 50,
                imagemUrl:
                    'https://m.media-amazon.com/images/I/71rBEHnIkXL.jpg',
              ),
            ],
          ),
        ),

        _buildSectionHeader('Vendas Mensais', Icons.trending_up),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LineChartWidget(
                data: [
                  {'title': 'Fev/2025', 'value': 2400},
                  {'title': 'Mar/2025', 'value': 4000},
                  {'title': 'Abr/2025', 'value': 1800},
                  {'title': 'Mai/2025', 'value': 3200},
                ],
              ),
            ],
          ),
        ),

        _buildSectionHeader('Entradas vs Saídas', Icons.bar_chart),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BarChartWidget(
            data: [
              MonthlyEntry(month: 'Jan', entrada: 10, saida: 6),
              MonthlyEntry(month: 'Fev', entrada: 12, saida: 8),
              MonthlyEntry(month: 'Mar', entrada: 14, saida: 9),
              MonthlyEntry(month: 'Abr', entrada: 7, saida: 5),
              MonthlyEntry(month: 'Mai', entrada: 13, saida: 12),
              MonthlyEntry(month: 'Jun', entrada: 10, saida: 11),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Produtos Populares', Icons.pie_chart),
                  Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: PieChartWidget(
                      produtos: [
                        Produto(
                          nome: 'Café',
                          quantidade: 30,
                          imagemUrl: 'https://example.com/imagens/cafe.png',
                        ),
                        Produto(
                          nome: 'Açúcar',
                          quantidade: 20,
                          imagemUrl: 'https://example.com/imagens/acucar.png',
                        ),
                        Produto(
                          nome: 'Arroz',
                          quantidade: 50,
                          imagemUrl: 'https://example.com/imagens/arroz.png',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Vendas Mensais', Icons.trending_up),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: LineChartWidget(
                      data: [
                        {'title': 'Fev/2025', 'value': 2400},
                        {'title': 'Mar/2025', 'value': 4000},
                        {'title': 'Abr/2025', 'value': 1800},
                        {'title': 'Mai/2025', 'value': 3200},
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Entradas vs Saídas', Icons.bar_chart),
        Container(
          width: double.infinity,
          height: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: BarChartWidget(
            data: [
              MonthlyEntry(month: 'Jan', entrada: 10, saida: 6),
              MonthlyEntry(month: 'Fev', entrada: 12, saida: 8),
              MonthlyEntry(month: 'Mar', entrada: 14, saida: 9),
              MonthlyEntry(month: 'Abr', entrada: 7, saida: 5),
              MonthlyEntry(month: 'Mai', entrada: 13, saida: 12),
              MonthlyEntry(month: 'Jun', entrada: 10, saida: 11),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4A5568)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}

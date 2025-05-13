import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Produto {
  final String nome;
  final double quantidade;
  final String imagemUrl;

  Produto({
    required this.nome,
    required this.quantidade,
    required this.imagemUrl,
  });
}

class PieChartWidget extends StatefulWidget {
  final List<Produto> produtos;

  const PieChartWidget({super.key, required this.produtos});

  @override
  State<PieChartWidget> createState() => PieChartWidgetState();
}

class PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 700,
        child: AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse?.touchedSection == null) {
                      touchedIndex = -1;
                    } else {
                      touchedIndex =
                          pieTouchResponse!.touchedSection!.touchedSectionIndex;
                    }
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: showingSections(theme),
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(ThemeData theme) {
    final total = widget.produtos.fold<double>(
      0,
      (sum, item) => sum + item.quantidade,
    );

    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.error,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.primaryContainer,
    ];

    return List.generate(widget.produtos.length, (i) {
      final produto = widget.produtos[i];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 110.0 : 95.0;
      final widgetSize = isTouched ? 50.0 : 36.0;

      final valuePercent =
          total == 0
              ? '0%'
              : '${(produto.quantidade / total * 100).toStringAsFixed(1)}%';

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: produto.quantidade,
        title: valuePercent,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        badgeWidget: _BadgeImage(
          imageUrl: produto.imagemUrl,
          size: widgetSize,
          borderColor: theme.colorScheme.onSurface,
        ),
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _BadgeImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Color borderColor;

  const _BadgeImage({
    required this.imageUrl,
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      ),
    );
  }
}

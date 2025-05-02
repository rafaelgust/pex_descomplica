import 'package:flutter/material.dart';

class OrderSearchBar extends StatefulWidget {
  final void Function(String)? onSearch;
  final void Function(String)? onChange;
  final bool isSearching;
  final String? initialValue;
  const OrderSearchBar({
    super.key,
    this.onSearch,
    this.onChange,
    required this.isSearching,
    this.initialValue,
  });

  @override
  State<OrderSearchBar> createState() => _OrderSearchBarState();
}

class _OrderSearchBarState extends State<OrderSearchBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surfaceContainer,
      shadowColor: Theme.of(context).colorScheme.shadow,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesquisar Ordens',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Produto, Cliente, Fornecedor',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    onChanged: widget.onChange,
                    onSubmitted: widget.onSearch,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed:
                          widget.isSearching
                              ? null
                              : () =>
                                  widget.onSearch?.call(_searchController.text),
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

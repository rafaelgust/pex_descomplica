import 'package:flutter/material.dart';

import '../../../../../data/models/supplier_model.dart';

import 'add_supplier_dialog.dart';

class SupplierList extends StatefulWidget {
  final List<SupplierModel> suppliers;
  final int initialPage;
  final int itemsPerPage;
  final int totalItems;
  final Function(SupplierModel)? onDelete;
  final Function(SupplierModel)? onEdit;

  const SupplierList({
    super.key,
    required this.suppliers,
    this.initialPage = 1,
    this.itemsPerPage = 10,
    required this.totalItems,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<SupplierList> createState() => _SupplierListState();
}

class _SupplierListState extends State<SupplierList> {
  late int currentPage;
  late List<SupplierModel> displayedSuppliers;
  late int itemsPerPage;
  late int totalPages;

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    itemsPerPage = widget.itemsPerPage;
    _updateDisplayedSuppliers();
  }

  void _updateDisplayedSuppliers() {
    totalPages = (widget.totalItems / itemsPerPage).ceil();

    // Garante que a página atual é válida
    if (currentPage < 1) {
      currentPage = 1;
    } else if (currentPage > totalPages && totalPages > 0) {
      currentPage = totalPages;
    }

    // Calcula índices inicial e final
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex =
        startIndex + itemsPerPage > widget.suppliers.length
            ? widget.suppliers.length
            : startIndex + itemsPerPage;

    if (startIndex >= widget.suppliers.length) {
      displayedSuppliers = [];
    } else {
      displayedSuppliers = widget.suppliers.sublist(startIndex, endIndex);
    }
  }

  void _nextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
        _updateDisplayedSuppliers();
      });
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        _updateDisplayedSuppliers();
      });
    }
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddSupplierDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showAddItemDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Novo Fornecedor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // Implementar exportação
                },
                icon: const Icon(Icons.download),
                label: const Text('Exportar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Theme.of(context).colorScheme.surface,
            shadowColor: Theme.of(context).colorScheme.shadow,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Lista de fornecedores
                Expanded(
                  child:
                      displayedSuppliers.isEmpty
                          ? Center(
                            child: Text(
                              'Nenhum fornecedor disponível',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                          : ListView.separated(
                            padding: const EdgeInsets.all(0),
                            itemCount: displayedSuppliers.length,
                            separatorBuilder:
                                (context, index) => Divider(
                                  height: 1,
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.5),
                                ),
                            itemBuilder: (context, index) {
                              final supplier = displayedSuppliers[index];

                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (context) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              title: const Text(
                                                'Editar fornecedor',
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                widget.onEdit?.call(supplier);
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              title: const Text(
                                                'Excluir fornecedor',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                widget.onDelete?.call(supplier);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  borderRadius:
                                      (index == 0)
                                          ? const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          )
                                          : (index ==
                                              displayedSuppliers.length - 1)
                                          ? const BorderRadius.vertical(
                                            bottom: Radius.circular(12),
                                          )
                                          : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom:
                                            index !=
                                                    displayedSuppliers.length -
                                                        1
                                                ? BorderSide(
                                                  color: Colors.grey.shade200,
                                                  width: 1,
                                                )
                                                : BorderSide.none,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                supplier.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    supplier.type == 'CNPJ'
                                                        ? Colors.blue.shade100
                                                        : Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                supplier.type,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      supplier.type == 'CNPJ'
                                                          ? Colors.blue.shade800
                                                          : Colors
                                                              .green
                                                              .shade800,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.badge_outlined,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatRegister(
                                                supplier.register,
                                                supplier.type == 'Jurídico',
                                              ),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (supplier.telefone != null &&
                                            supplier.telefone!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.phone_outlined,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatPhone(
                                                  supplier.telefone!,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (supplier.email != null &&
                                            supplier.email!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.email_outlined,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  supplier.email!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade700,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (supplier.cep != null &&
                                            supplier.cep!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatCEP(supplier.cep!),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                // Paginação e botões de ação
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildPagination(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildTextFieldNumberRows(context, 'Itens por página', itemsPerPage, (
          value,
        ) {
          setState(() {
            itemsPerPage = value;
            _updateDisplayedSuppliers();
          });
        }),
        Spacer(),
        Text(
          'Total de fornecedores: ${widget.totalItems}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        Text(
          'Página $currentPage de ${totalPages == 0 ? 1 : totalPages}',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        const SizedBox(width: 16),
        IconButton(
          onPressed: currentPage > 1 ? _previousPage : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Página anterior',
          disabledColor: Theme.of(context).disabledColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$currentPage',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: currentPage < totalPages ? _nextPage : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Próxima página',
          disabledColor: Theme.of(context).disabledColor,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTextFieldNumberRows(
    BuildContext context,
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Transform.scale(
      scale: 0.7,
      child: Container(
        width: 140,
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: TextEditingController(text: value.toString()),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          onChanged: (text) {
            final newValue = int.tryParse(text);
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  String _formatRegister(String register, bool isCNPJ) {
    final cleanRegister = register.replaceAll(RegExp(r'[^0-9]'), '');

    if (isCNPJ) {
      if (cleanRegister.length != 14) return register;
      return '${cleanRegister.substring(0, 2)}.${cleanRegister.substring(2, 5)}.${cleanRegister.substring(5, 8)}/${cleanRegister.substring(8, 12)}-${cleanRegister.substring(12)}';
    } else {
      if (cleanRegister.length != 11) return register;
      return '${cleanRegister.substring(0, 3)}.${cleanRegister.substring(3, 6)}.${cleanRegister.substring(6, 9)}-${cleanRegister.substring(9)}';
    }
  }

  String _formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.length == 11) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    } else if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    }

    return phone;
  }

  String _formatCEP(String cep) {
    final cleanCEP = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCEP.length == 8) {
      return '${cleanCEP.substring(0, 5)}-${cleanCEP.substring(5)}';
    }

    return cep;
  }
}

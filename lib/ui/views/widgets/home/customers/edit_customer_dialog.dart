import 'package:flutter/material.dart';

import '../../../../../data/models/customer_model.dart';
import '../../../../../data/services/injector/injector_service.dart';
import '../../../../view_models/customer_view_model.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class EditCustomerDialog extends StatefulWidget {
  final CustomerModel customer;
  const EditCustomerDialog({super.key, required this.customer});

  @override
  State<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  final CustomerViewModel _viewModel = injector.get<CustomerViewModel>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _registerController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();

  bool _isCNPJ = false;

  late MaskTextInputFormatter _cpfFormatter;
  late MaskTextInputFormatter _cnpjFormatter;
  late MaskTextInputFormatter _phoneFormatter;
  late MaskTextInputFormatter _cepFormatter;

  @override
  void initState() {
    super.initState();
    _cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
    );

    _cnpjFormatter = MaskTextInputFormatter(
      mask: '##.###.###/####-##',
      filter: {"#": RegExp(r'[0-9]')},
    );

    _phoneFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    _cepFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
    );

    _nameController.text = widget.customer.name;
    _registerController.text = widget.customer.register;
    _telefoneController.text = widget.customer.telefone ?? '';
    _emailController.text = widget.customer.email ?? '';
    _cepController.text = widget.customer.cep ?? '';
    _isCNPJ = widget.customer.type == 'Juridico';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _registerController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  bool _enableButton() {
    if (_nameController.text.isEmpty || _registerController.text.isEmpty) {
      return false;
    }
    return true;
  }

  bool _validateRegister() {
    if (_registerController.text.isEmpty) {
      return false;
    }

    // Remove formatação para verificação
    final cleanRegister = _registerController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (_isCNPJ) {
      // Validação básica de CNPJ (14 dígitos)
      return cleanRegister.length == 14;
    } else {
      // Validação básica de CPF (11 dígitos)
      return cleanRegister.length == 11;
    }
  }

  void editCustomer() async {
    // Remove formatação antes de enviar
    final cleanRegister = _registerController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    await _viewModel
        .updateCustomer(
          customerCopy: widget.customer,
          id: widget.customer.id,
          name: _nameController.text,
          register: cleanRegister,
          telefone:
              _telefoneController.text.isEmpty
                  ? null
                  : _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          email: _emailController.text.isEmpty ? null : _emailController.text,
          cep:
              _cepController.text.isEmpty
                  ? null
                  : _cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
          isCNPJ: _isCNPJ,
        )
        .then((value) {
          if (!value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao alterar cliente')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('cliente alterado com sucesso')),
            );
            _viewModel.searchCustomers();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar cliente'),
      content: Container(
        width: 500,
        constraints: const BoxConstraints(minWidth: 300),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome do cliente',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      title: Text(_isCNPJ ? 'CNPJ' : 'CPF'),
                      value: _isCNPJ,
                      onChanged: (value) {
                        setState(() {
                          _isCNPJ = value;
                          // Limpa o campo quando troca entre CPF e CNPJ
                          _registerController.clear();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _registerController,
                inputFormatters: [_isCNPJ ? _cnpjFormatter : _cpfFormatter],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isCNPJ ? 'CNPJ' : 'CPF',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: _isCNPJ ? '00.000.000/0000-00' : '000.000.000-00',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _telefoneController,
                inputFormatters: [_phoneFormatter],
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '(00) 00000-0000',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'exemplo@email.com',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cepController,
                inputFormatters: [_cepFormatter],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '00000-000',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed:
              !_enableButton()
                  ? null
                  : () {
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nome do cliente é obrigatório'),
                        ),
                      );
                      return;
                    }

                    if (!_validateRegister()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isCNPJ
                                ? 'CNPJ inválido ou incompleto'
                                : 'CPF inválido ou incompleto',
                          ),
                        ),
                      );
                      return;
                    }

                    editCustomer();
                    Navigator.pop(context);
                  },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

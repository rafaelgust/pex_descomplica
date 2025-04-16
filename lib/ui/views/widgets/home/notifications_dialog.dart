import 'package:flutter/material.dart';

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notificações'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: 3,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            String title;
            String message;
            IconData icon;
            Color color;

            switch (index) {
              case 0:
                title = 'Estoque Baixo';
                message = 'Produto X está com estoque abaixo do mínimo';
                icon = Icons.warning_amber;
                color = Colors.orange;
                break;
              case 1:
                title = 'Novo Pedido';
                message = 'Pedido #1234 foi recebido e aguarda processamento';
                icon = Icons.shopping_cart;
                color = Colors.green;
                break;
              case 2:
                title = 'Atualização de Sistema';
                message = 'Nova versão disponível. Atualize quando possível';
                icon = Icons.system_update;
                color = Colors.blue;
                break;
              default:
                title = 'Notificação';
                message = 'Nova mensagem recebida';
                icon = Icons.notifications;
                color = Colors.grey;
            }

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, color: color, size: 20),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(message),
              trailing: Text(
                '${index + 1}h atrás',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Fechar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // Implementar visualização de todas as notificações
          },
          child: const Text('Ver Todas'),
        ),
      ],
    );
  }
}

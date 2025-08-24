import 'package:flutter/material.dart';

class NotificheFragment extends StatefulWidget {
  const NotificheFragment({super.key});

  @override
  State<NotificheFragment> createState() => _NotificheFragmentState();
}

class _NotificheFragmentState extends State<NotificheFragment> {
  final List<Map<String, dynamic>> _notifiche = [
    {
      'id': '1',
      'titolo': 'Nuovo evento disponibile',
      'messaggio': 'È stato aggiunto un nuovo evento: "Cena sociale di primavera"',
      'tipo': 'evento',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'letta': false,
    },
    {
      'id': '2',
      'titolo': 'Ricarica effettuata',
      'messaggio': 'La tua ricarica di €50.00 è stata completata con successo',
      'tipo': 'pagamento',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'letta': true,
    },
    {
      'id': '3',
      'titolo': 'Tessera in scadenza',
      'messaggio': 'La tua tessera scadrà tra 30 giorni. Rinnovala per continuare ad accedere ai servizi',
      'tipo': 'avviso',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'letta': false,
    },
    {
      'id': '4',
      'titolo': 'Nuovo prodotto nel catalogo',
      'messaggio': 'È stato aggiunto un nuovo prodotto: "Maglietta CircolApp 2024"',
      'tipo': 'prodotto',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      'letta': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final notificheNonLette = _notifiche.where((n) => !n['letta']).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifiche'),
            if (notificheNonLette > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$notificheNonLette',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Segna tutte come lette'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Cancella tutte'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _notifiche.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nessuna notifica',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _notifiche.length,
              itemBuilder: (context, index) {
                final notifica = _notifiche[index];
                return _buildNotificaCard(notifica, index);
              },
            ),
    );
  }

  Widget _buildNotificaCard(Map<String, dynamic> notifica, int index) {
    final IconData icon = _getIconForType(notifica['tipo']);
    final Color color = _getColorForType(notifica['tipo']);
    final bool isUnread = !notifica['letta'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isUnread ? 4 : 2,
      child: InkWell(
        onTap: () => _markAsRead(index),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: isUnread
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              notifica['titolo'],
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notifica['messaggio'],
                  style: TextStyle(
                    color: isUnread ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTimestamp(notifica['timestamp']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleNotificaAction(value, index),
              itemBuilder: (context) => [
                if (isUnread)
                  const PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read),
                        SizedBox(width: 8),
                        Text('Segna come letta'),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'mark_unread',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_unread),
                        SizedBox(width: 8),
                        Text('Segna come non letta'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Elimina', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String tipo) {
    switch (tipo) {
      case 'evento':
        return Icons.event;
      case 'pagamento':
        return Icons.payment;
      case 'avviso':
        return Icons.warning;
      case 'prodotto':
        return Icons.shopping_cart;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String tipo) {
    switch (tipo) {
      case 'evento':
        return Colors.green;
      case 'pagamento':
        return Colors.blue;
      case 'avviso':
        return Colors.orange;
      case 'prodotto':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minuti fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ore fa';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _markAsRead(int index) {
    setState(() {
      _notifiche[index]['letta'] = true;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        setState(() {
          for (var notifica in _notifiche) {
            notifica['letta'] = true;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tutte le notifiche sono state segnate come lette'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'clear_all':
        _showClearAllDialog();
        break;
    }
  }

  void _handleNotificaAction(String action, int index) {
    switch (action) {
      case 'mark_read':
        setState(() {
          _notifiche[index]['letta'] = true;
        });
        break;
      case 'mark_unread':
        setState(() {
          _notifiche[index]['letta'] = false;
        });
        break;
      case 'delete':
        setState(() {
          _notifiche.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifica eliminata'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancella tutte le notifiche'),
        content: const Text('Sei sicuro di voler cancellare tutte le notifiche? Questa azione non può essere annullata.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _notifiche.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tutte le notifiche sono state cancellate'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancella tutto'),
          ),
        ],
      ),
    );
  }
}

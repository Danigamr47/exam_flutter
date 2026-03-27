import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifications = auth.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Vider l'historique ?"),
                  content: const Text("Toutes vos notifications seront définitivement supprimées."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
                    TextButton(
                      onPressed: () {
                        auth.clearNotifications();
                        Navigator.pop(context);
                      },
                      child: const Text("Vider", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
              tooltip: "Vider l'historique",
            ),
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => auth.markAllAsRead(),
              child: const Text("Tout lire"),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text("Aucune notification", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Dismissible(
                  key: Key(notif.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) => auth.deleteNotification(notif.id),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: notif.isRead ? Colors.transparent : AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: notif.isRead ? Colors.grey.shade100 : AppTheme.primaryColor.withOpacity(0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: notif.isRead ? Colors.grey.shade100 : AppTheme.primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            size: 20,
                            color: notif.isRead ? Colors.grey : AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(
                                    DateFormat('HH:mm').format(notif.date),
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(notif.message, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                          onPressed: () => auth.deleteNotification(notif.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
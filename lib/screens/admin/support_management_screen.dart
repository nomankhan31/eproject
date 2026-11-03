import 'package:flutter/material.dart';

import '../../models/support_message_model.dart';
import '../../services/support_service.dart';

class SupportManagementScreen extends StatefulWidget {
  const SupportManagementScreen({super.key});

  @override
  State<SupportManagementScreen> createState() =>
      _SupportManagementScreenState();
}

class _SupportManagementScreenState extends State<SupportManagementScreen> {
  final SupportService _service = SupportService();

  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController controllerFor(String userId) {
    return _controllers.putIfAbsent(userId, () => TextEditingController());
  }

  Future<void> reply(String userId) async {
    final controller = controllerFor(userId);
    final message = controller.text.trim();

    if (message.isEmpty) return;

    try {
      await _service.sendMessage(
        userId: userId,
        message: message,
        sender: 'admin',
      );

      controller.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Reply failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Desk'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<SupportMessageModel>>(
        stream: _service.getAllMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading support messages'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!;

          if (messages.isEmpty) {
            return const Center(child: Text('No support messages yet'));
          }

          // Latest message per customer.
          final latestByUser = <String, SupportMessageModel>{};

          for (final message in messages) {
            latestByUser.putIfAbsent(message.userId, () => message);
          }

          final conversations = latestByUser.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    'Customer: ${conversation.userId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    conversation.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          StreamBuilder<List<SupportMessageModel>>(
                            stream: _service.getMessages(conversation.userId),
                            builder: (context, messageSnapshot) {
                              if (!messageSnapshot.hasData) {
                                return const CircularProgressIndicator();
                              }

                              final chatMessages = messageSnapshot.data!;

                              return SizedBox(
                                height: 250,
                                child: ListView.builder(
                                  itemCount: chatMessages.length,
                                  itemBuilder: (context, i) {
                                    final item = chatMessages[i];
                                    final isAdmin = item.sender == 'admin';

                                    return Align(
                                      alignment: isAdmin
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isAdmin
                                              ? Colors.black
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          item.message,
                                          style: TextStyle(
                                            color: isAdmin
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controllerFor(
                                    conversation.userId,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Write a reply...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  reply(conversation.userId);
                                },
                                icon: const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

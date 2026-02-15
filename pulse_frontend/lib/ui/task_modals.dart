import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ModalsShowcase extends StatelessWidget {
  const ModalsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title, String desc, MaterialColor color, VoidCallback onTap) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: const),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color[1], radius: 24, child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40), backgroundColor: color == Colors.red? Colors.white : color, foregroundColor: color == Colors.red? Colors.red : Colors.white, side: color == Colors.red? const BorderSide(color: Colors.red) : null),
            child: Text(color == Colors.red? 'פתח מחיקה' : title.contains('עריכה')? 'פתח עריכה' : 'פתח יצירה'),
          )
        ],
      ),
    );
  }

  void _showCreateTask(BuildContext context) {
    showDialog(context: context, builder: (context) => const CreateTaskModal());
  }

  void _showEditTask(BuildContext context) {
    showDialog(context: context, builder: (context) => const EditTaskModal());
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(context: context, builder: (context) => const DeleteConfirmModal());
  }
}

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({super.key});
  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  String _workerType = 'INTERNAL';
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Color(0xFFF8FAFC), border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:,
            ),
            IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:,
              ),
            )
          ],
        ),
      ),
      actions:,
    );
  }
}

class EditTaskModal extends StatelessWidget {
  const EditTaskModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: Color(0xFFF8FAFC), border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:,
            ),
            IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:,
              onChanged: (val) {},
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions:,
        )
      ],
    );
  }
}

class DeleteConfirmModal extends StatelessWidget {
  const DeleteConfirmModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children:,
      ),
      actions:,
    );
  }
}
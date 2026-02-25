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
          children: [
            _buildCard(context, LucideIcons.plus, 'יצירת מטלה', 'הוסף מטלה חדשה למערכת', Colors.blue, () => _showCreateTask(context)),
            const SizedBox(height: 16),
            _buildCard(context, LucideIcons.pencil, 'עריכת מטלה', 'ערוך פרטי מטלה קיימת', Colors.green, () => _showEditTask(context)),
            const SizedBox(height: 16),
            _buildCard(context, LucideIcons.trash2, 'מחיקת מטלה', 'מחק מטלה מהמערכת', Colors.red, () => _showDeleteConfirm(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title, String desc, MaterialColor color, VoidCallback onTap) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(backgroundColor: color[100], radius: 24, child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
              backgroundColor: color == Colors.red ? Colors.white : color,
              foregroundColor: color == Colors.red ? Colors.red : Colors.white,
              side: color == Colors.red ? const BorderSide(color: Colors.red) : null,
            ),
            child: Text(color == Colors.red ? 'פתח מחיקה' : title.contains('עריכה') ? 'פתח עריכה' : 'פתח יצירה'),
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
  String? _workerType;
  String? _selectedWorker;
  final _taskNameController = TextEditingController();

  static const _internalWorkers = [
    'יוסי כהן', 'דנה לוי', 'שירה רוזנפלד', 'רון שפירא',
    'אבי גולן', 'נועה מזרחי', 'עמית ברקוביץ',
  ];

  static const _externalWorkers = [
    'מיכאל ברג', "ג'ון סמית", 'ליאת פרידמן', 'ספיר אדרי',
  ];

  List<String> get _currentWorkers =>
      _workerType == 'INTERNAL' ? _internalWorkers : _externalWorkers;

  static BoxDecoration get _dropdownDecoration => BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8),
      );

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.plus, size: 18, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Text('יצירת מטלה', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
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
          children: [
            const Text('שם המטלה', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(
                hintText: 'הכנס שם מטלה...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),
            const Text('סוג עובד', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            Container(
              decoration: _dropdownDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: _workerType,
                hint: const Text('בחר סוג עובד...', style: TextStyle(color: Color(0xFF94A3B8))),
                isExpanded: true,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'INTERNAL', child: Text('עובד חברה')),
                  DropdownMenuItem(value: 'EXTERNAL', child: Text('יועץ חיצוני')),
                ],
                onChanged: (val) => setState(() {
                  _workerType = val;
                  _selectedWorker = null;
                }),
              ),
            ),
            if (_workerType != null) ...[
              const SizedBox(height: 16),
              const Text('אחראי ביצוע', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 8),
              Container(
                decoration: _dropdownDecoration,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: _selectedWorker,
                  hint: const Text('בחר עובד...', style: TextStyle(color: Color(0xFF94A3B8))),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _currentWorkers
                      .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedWorker = val),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ביטול'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: wire up to provider / API
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
          child: const Text('צור מטלה'),
        ),
      ],
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
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.pencil, size: 18, color: Color(0xFF16A34A)),
                SizedBox(width: 8),
                Text('עריכת מטלה', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ],
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
          children: [
            const Text('שם המטלה', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'ערוך שם מטלה...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) {},
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ביטול'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: wire up to provider / API
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
          ),
          child: const Text('שמור'),
        ),
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
        children: [
          Icon(LucideIcons.triangleAlert, size: 48, color: Color(0xFFEF4444)),
          SizedBox(height: 16),
          Text(
            'אישור מחיקה',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          SizedBox(height: 8),
          Text(
            'האם אתה בטוח שברצונך למחוק מטלה זו?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ביטול'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: wire up to provider / API
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
          ),
          child: const Text('מחק'),
        ),
      ],
    );
  }
}

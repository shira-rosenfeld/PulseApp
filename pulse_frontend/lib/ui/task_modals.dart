import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── Hebrew date-picker helpers ───────────────────────────────────────────────

const _kWeekdayAbbr = ["א'", "ב'", "ג'", "ד'", "ה'", "ו'", "ש'"];
// Index 0 = Sunday (weekday % 7 of Dart's weekday 7), 1 = Monday, …, 6 = Saturday.

const _kMonths = [
  'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
  'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר',
];

/// Formats [date] as "יום ד', 15 באפריל 2026".
String _fmtHebrew(DateTime d) {
  final wd = _kWeekdayAbbr[d.weekday % 7];
  final mo = _kMonths[d.month - 1];
  return 'יום $wd, ${d.day} ב$mo ${d.year}';
}

// Wraps the existing (already-loaded Hebrew) MaterialLocalizations so that
// only formatMediumDate is replaced — all other strings stay in Hebrew.
class _HebrewDatePickerLocalizations extends DefaultMaterialLocalizations {
  _HebrewDatePickerLocalizations(this._base);
  final MaterialLocalizations _base;

  @override
  String formatMediumDate(DateTime date) => _fmtHebrew(date);

  // Forward every string used inside the calendar date-picker back to the
  // Hebrew base so nothing switches to English.
  @override String get okButtonLabel          => _base.okButtonLabel;
  @override String get cancelButtonLabel      => _base.cancelButtonLabel;
  @override String get datePickerHelpText     => _base.datePickerHelpText;
  @override String get nextMonthTooltip       => _base.nextMonthTooltip;
  @override String get previousMonthTooltip   => _base.previousMonthTooltip;
  @override String get dateHelpText           => _base.dateHelpText;
  @override String get invalidDateFormatLabel => _base.invalidDateFormatLabel;
  @override String get dateOutOfRangeLabel    => _base.dateOutOfRangeLabel;
  @override List<String> get narrowWeekdays   => _base.narrowWeekdays;
  @override int get firstDayOfWeekIndex       => _base.firstDayOfWeekIndex;
  @override String formatMonthYear(DateTime date) => _base.formatMonthYear(date);
  @override String formatYear(DateTime date)      => _base.formatYear(date);
  @override String formatFullDate(DateTime date)  => _base.formatFullDate(date);
  @override String get selectYearSemanticsLabel => _base.selectYearSemanticsLabel;
}

class _MaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MaterialLocalizationsDelegate(this._base);
  final MaterialLocalizations _base;

  @override bool isSupported(Locale locale) => true;
  @override Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
          _HebrewDatePickerLocalizations(_base));
  @override bool shouldReload(_MaterialLocalizationsDelegate old) => false;
}

// Reads the current context's Hebrew MaterialLocalizations and overlays
// _HebrewDatePickerLocalizations so formatMediumDate shows the full month.
class _DatePickerLocalizationsOverride extends StatelessWidget {
  const _DatePickerLocalizationsOverride({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = MaterialLocalizations.of(context);
    return Localizations.override(
      context: context,
      delegates: [_MaterialLocalizationsDelegate(base)],
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────


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
  String? _selectedWorker;
  DateTime? _startDate;
  int _plannedDays = 1;
  final _taskNameController = TextEditingController();

  // Combined list of all workers (backend will handle both types)
  static const _allWorkers = [
    'יוסי כהן', 'דנה לוי', 'שירה רוזנפלד', 'רון שפירא',
    'אבי גולן', 'נועה מזרחי', 'עמית ברקוביץ',
    'מיכאל ברג', "ג'ון סמית", 'ליאת פרידמן', 'ספיר אדרי',
  ];

  static BoxDecoration get _dropdownDecoration => BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(8),
      );

  // Computed due date = start date + planned days (null until start date chosen)
  String? get _computedDueDate {
    if (_startDate == null) return null;
    return _fmtHebrew(_startDate!.add(Duration(days: _plannedDays)));
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          datePickerTheme: const DatePickerThemeData(
            // Smaller headline prevents the full date from being truncated.
            headerHeadlineStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        child: _DatePickerLocalizationsOverride(child: child!),
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

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
            // שם המטלה
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
            // אחראי ביצוע (combined list, no worker-type pre-selection needed)
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
                items: _allWorkers
                    .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedWorker = val),
              ),
            ),
            const SizedBox(height: 16),
            // תאריך התחלה — date picker
            const Text('תאריך התחלה', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickStartDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 16,
                        color: _startDate != null ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                    const SizedBox(width: 8),
                    Text(
                      _startDate != null ? _fmtHebrew(_startDate!) : 'בחר תאריך התחלה...',
                      style: TextStyle(
                        fontSize: 13,
                        color: _startDate != null ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                        fontWeight: _startDate != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // מספר ימים מתוכנן — stepper
            const Text('מספר ימים מתוכנן', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            Container(
              decoration: _dropdownDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.minus, size: 16),
                    onPressed: _plannedDays > 1 ? () => setState(() => _plannedDays--) : null,
                    color: const Color(0xFF64748B),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '$_plannedDays ימים',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.plus, size: 16),
                    onPressed: () => setState(() => _plannedDays++),
                    color: const Color(0xFF2563EB),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // תאריך יעד — computed read-only (start date + planned days)
            const Text('תאריך יעד', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.calendar, size: 14,
                      color: _computedDueDate != null ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
                  const SizedBox(width: 8),
                  Text(
                    _computedDueDate ?? 'יחושב לאחר בחירת תאריך התחלה',
                    style: TextStyle(
                      fontSize: 13,
                      color: _computedDueDate != null ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      fontWeight: _computedDueDate != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
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

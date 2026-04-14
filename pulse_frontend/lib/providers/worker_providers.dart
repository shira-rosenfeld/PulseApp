import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtos/worker_task.dart';
import '../models/enums/work_item_status.dart';
import '../models/enums/worker_type.dart';

class WeekNotifier extends Notifier<int> {
  @override
  int build() => 5;
  void set(int v) => state = v;
}

final weekProvider = NotifierProvider<WeekNotifier, int>(WeekNotifier.new);

class TaskFilterNotifier extends Notifier<String> {
  @override
  String build() => 'OPEN';
  void set(String v) => state = v;
}

final taskFilterProvider = NotifierProvider<TaskFilterNotifier, String>(TaskFilterNotifier.new);

class ProxyUserNotifier extends Notifier<String> {
  @override
  String build() => 'SELF';
  void set(String v) => state = v;
}

final proxyUserProvider = NotifierProvider<ProxyUserNotifier, String>(ProxyUserNotifier.new);

class HasChangesNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

final hasChangesProvider = NotifierProvider<HasChangesNotifier, bool>(HasChangesNotifier.new);

// Sort order: STATUS_DATE = status then due date, DATE = due date only, STATUS = status only
class SortOrderNotifier extends Notifier<String> {
  @override
  String build() => 'STATUS_DATE';
  void set(String v) => state = v;
}

final sortOrderProvider = NotifierProvider<SortOrderNotifier, String>(SortOrderNotifier.new);

final workerTasksProvider = NotifierProvider<WorkerTasksNotifier, List<WorkerTask>>(WorkerTasksNotifier.new);

List<WorkerTask> _initialTasks() {
  return [
    WorkerTask(
      id: 'TASK-1004',
      path: 'WBS-2026.10 / NET-80002',
      desc: 'ממשק מנהל - שולחן עבודה',
      status: WorkItemStatus.inProgress,
      planned: 20,
      totalReported: 14,
      reportedThisWeek: 0,
      actualStart: '15/01/2026',
      dueDate: '04/02/2026',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1005',
      path: 'WBS-2026.10 / NET-80002',
      desc: 'ממשק עובד - דיווח שבועי',
      status: WorkItemStatus.inProgress,
      planned: 16,
      totalReported: 10,
      reportedThisWeek: 0,
      actualStart: '20/01/2026',
      dueDate: '05/02/2026',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1006',
      path: 'WBS-2026.10 / NET-80002',
      desc: 'בדיקות UI',
      status: WorkItemStatus.newTask,
      planned: 12,
      totalReported: 0,
      reportedThisWeek: 0,
      dueDate: '18/02/2026',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1002',
      path: 'WBS-2026.10 / NET-80001',
      desc: 'תכנון API',
      status: WorkItemStatus.onHold,
      planned: 8,
      totalReported: 5,
      reportedThisWeek: 0,
      actualStart: '10/01/2026',
      dueDate: '18/01/2026',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1001',
      path: 'WBS-2026.10 / NET-80001',
      desc: 'עיצוב מסד נתונים',
      status: WorkItemStatus.done,
      planned: 10,
      totalReported: 9,
      reportedThisWeek: 0,
      actualStart: '05/01/2026',
      dueDate: '15/01/2026',
      actualEnd: '14/01/2026',
      workerType: WorkerType.internal,
    ),
    WorkerTask(
      id: 'TASK-1013',
      path: 'WBS-2026.11 / NET-80005',
      desc: 'בדיקות חדירה',
      status: WorkItemStatus.canceled,
      planned: 8,
      totalReported: 0,
      reportedThisWeek: 0,
      workerType: WorkerType.external,
    ),
  ];
}

class WorkerTasksNotifier extends Notifier<List<WorkerTask>> {
  @override
  List<WorkerTask> build() => _initialTasks();

  void updateDays(String id, double delta) {
    ref.read(hasChangesProvider.notifier).set(true);
    state = state.map((task) {
      if (task.id != id) return task;

      final newVal = (task.reportedThisWeek + delta) < 0 ? 0.0 : (task.reportedThisWeek + delta);
      WorkItemStatus newStatus = task.status;

      // Optimistic UI: If days reported on 'New' task, move to 'InProgress'
      if (newVal > 0 && task.status == WorkItemStatus.newTask) {
        newStatus = WorkItemStatus.inProgress;
      }
      return task.copyWith(reportedThisWeek: newVal, status: newStatus);
    }).toList();
  }

  void updateStatus(String id, WorkItemStatus newStatus) {
    ref.read(hasChangesProvider.notifier).set(true);
    state = state.map((task) => task.id == id ? task.copyWith(status: newStatus) : task).toList();
  }
}

// Status priority for sorting: lower number = higher priority (shown first)
int _statusPriority(WorkItemStatus status) {
  switch (status) {
    case WorkItemStatus.inProgress: return 1;
    case WorkItemStatus.newTask:    return 2;
    case WorkItemStatus.onHold:     return 3;
    case WorkItemStatus.done:       return 4;
    case WorkItemStatus.canceled:   return 5;
  }
}

// Parse DD/MM/YYYY date string for comparison (returns null if invalid)
DateTime? _parseDate(String? s) {
  if (s == null) return null;
  final parts = s.split('/');
  if (parts.length != 3) return null;
  final d = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final y = int.tryParse(parts[2]);
  if (d == null || m == null || y == null) return null;
  return DateTime(y, m, d);
}

final filteredWorkerTasksProvider = Provider<List<WorkerTask>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final sortOrder = ref.watch(sortOrderProvider);
  final tasks = ref.watch(workerTasksProvider);

  final filtered = tasks.where((task) {
    if (filter == 'ALL') return true;
    if (filter == 'OPEN') return [WorkItemStatus.inProgress, WorkItemStatus.onHold].contains(task.status);
    if (filter == 'CLOSED') return [WorkItemStatus.done, WorkItemStatus.canceled].contains(task.status);
    return true;
  }).toList();

  filtered.sort((a, b) {
    if (sortOrder == 'STATUS') {
      return _statusPriority(a.status).compareTo(_statusPriority(b.status));
    }
    if (sortOrder == 'DATE') {
      final da = _parseDate(a.dueDate);
      final db = _parseDate(b.dueDate);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    }
    // Default: STATUS_DATE — status priority first, then due date ascending
    final statusCmp = _statusPriority(a.status).compareTo(_statusPriority(b.status));
    if (statusCmp != 0) return statusCmp;
    final da = _parseDate(a.dueDate);
    final db = _parseDate(b.dueDate);
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });

  return filtered;
});

final totalWeeklyDaysProvider = Provider<double>((ref) {
  final tasks = ref.watch(workerTasksProvider);
  return tasks.fold(0.0, (sum, task) => sum + task.reportedThisWeek);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_frontend/models/dtos/worker_task.dart';
import 'package:pulse_frontend/models/enums/work_item_status.dart';
import 'package:pulse_frontend/models/enums/worker_type.dart';
import 'package:pulse_frontend/providers/worker_providers.dart';

// Tasks with explicit due dates for sort-by-date tests.
class _DateSortNotifier extends WorkerTasksNotifier {
  @override
  List<WorkerTask> build() => [
    WorkerTask(id: 'D1', path: 'P', desc: 'Late task',  status: WorkItemStatus.inProgress, planned: 10, totalReported: 0, reportedThisWeek: 0, dueDate: '10/03/2026', workerType: WorkerType.internal),
    WorkerTask(id: 'D2', path: 'P', desc: 'Early task', status: WorkItemStatus.inProgress, planned: 10, totalReported: 0, reportedThisWeek: 0, dueDate: '01/01/2026', workerType: WorkerType.internal),
    WorkerTask(id: 'D3', path: 'P', desc: 'No date',    status: WorkItemStatus.inProgress, planned: 10, totalReported: 0, reportedThisWeek: 0, workerType: WorkerType.internal),
  ];
}

List<WorkerTask> _seedTasks() => [
  WorkerTask(id: 'T1', path: 'P1', desc: 'Task 1', status: WorkItemStatus.newTask, planned: 10, totalReported: 0, reportedThisWeek: 0, workerType: WorkerType.internal),
  WorkerTask(id: 'T2', path: 'P1', desc: 'Task 2', status: WorkItemStatus.inProgress, planned: 8, totalReported: 2, reportedThisWeek: 0, workerType: WorkerType.internal),
  WorkerTask(id: 'T3', path: 'P2', desc: 'Task 3', status: WorkItemStatus.onHold, planned: 5, totalReported: 1, reportedThisWeek: 0, workerType: WorkerType.external),
  WorkerTask(id: 'T4', path: 'P2', desc: 'Task 4', status: WorkItemStatus.done, planned: 6, totalReported: 6, reportedThisWeek: 0, workerType: WorkerType.internal),
  WorkerTask(id: 'T5', path: 'P3', desc: 'Task 5', status: WorkItemStatus.canceled, planned: 4, totalReported: 0, reportedThisWeek: 0, workerType: WorkerType.external),
];

// Injects seed tasks instead of the production initial state.
class _SeedTasksNotifier extends WorkerTasksNotifier {
  @override
  List<WorkerTask> build() => _seedTasks();
}

ProviderContainer _makeContainer() {
  return ProviderContainer(overrides: [
    workerTasksProvider.overrideWith(_SeedTasksNotifier.new),
  ]);
}

void main() {
  group('WorkerTasksNotifier.updateDays', () {
    test('increases days by delta', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateDays('T2', 3.0);
      final task = container.read(workerTasksProvider).firstWhere((t) => t.id == 'T2');

      expect(task.reportedThisWeek, 3.0);
    });

    test('does not go below 0', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateDays('T1', -5.0);
      final task = container.read(workerTasksProvider).firstWhere((t) => t.id == 'T1');

      expect(task.reportedThisWeek, 0.0);
    });

    test('auto-promotes newTask to inProgress when days > 0', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateDays('T1', 0.5);
      final task = container.read(workerTasksProvider).firstWhere((t) => t.id == 'T1');

      expect(task.status, WorkItemStatus.inProgress);
    });

    test('marks hasChanges = true after update', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateDays('T1', 2.0);
      expect(container.read(hasChangesProvider), true);
    });
  });

  group('WorkerTasksNotifier.updateStatus', () {
    test('changes task status', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateStatus('T1', WorkItemStatus.done);
      final task = container.read(workerTasksProvider).firstWhere((t) => t.id == 'T1');

      expect(task.status, WorkItemStatus.done);
    });
  });

  group('filteredWorkerTasksProvider', () {
    test('OPEN filter returns inProgress and onHold, not newTask', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).set('OPEN');
      final filtered = container.read(filteredWorkerTasksProvider);

      expect(filtered.any((t) => t.status == WorkItemStatus.newTask), false);
      expect(filtered.any((t) => t.status == WorkItemStatus.inProgress), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.onHold), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.done), false);
      expect(filtered.any((t) => t.status == WorkItemStatus.canceled), false);
    });

    test('CLOSED filter returns done and canceled', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).set('CLOSED');
      final filtered = container.read(filteredWorkerTasksProvider);

      expect(filtered.any((t) => t.status == WorkItemStatus.done), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.canceled), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.newTask), false);
      expect(filtered.any((t) => t.status == WorkItemStatus.inProgress), false);
    });

    test('ALL filter returns everything', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).set('ALL');
      final filtered = container.read(filteredWorkerTasksProvider);

      expect(filtered.length, 5);
    });
  });

  group('totalWeeklyDaysProvider', () {
    test('initial total is 0.0 when no days reported', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      expect(container.read(totalWeeklyDaysProvider), 0.0);
    });

    test('sums reportedThisWeek after a single update', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateDays('T1', 2.0);

      expect(container.read(totalWeeklyDaysProvider), 2.0);
    });

    test('sums reportedThisWeek across multiple tasks', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateDays('T1', 2.0);
      container.read(workerTasksProvider.notifier).updateDays('T2', 3.0);

      expect(container.read(totalWeeklyDaysProvider), 5.0);
    });
  });

  group('filteredWorkerTasksProvider – sorting', () {
    test('STATUS sort orders by status priority (inProgress → newTask → onHold → done → canceled)', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).set('ALL');
      container.read(sortOrderProvider.notifier).set('STATUS');
      final sorted = container.read(filteredWorkerTasksProvider);
      final ids = sorted.map((t) => t.id).toList();

      expect(ids.indexOf('T2'), lessThan(ids.indexOf('T1'))); // inProgress before newTask
      expect(ids.indexOf('T1'), lessThan(ids.indexOf('T3'))); // newTask before onHold
      expect(ids.indexOf('T3'), lessThan(ids.indexOf('T4'))); // onHold before done
      expect(ids.indexOf('T4'), lessThan(ids.indexOf('T5'))); // done before canceled
    });

    test('DATE sort orders by due date ascending, null dates last', () {
      final container = ProviderContainer(overrides: [
        workerTasksProvider.overrideWith(_DateSortNotifier.new),
      ]);
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).set('ALL');
      container.read(sortOrderProvider.notifier).set('DATE');
      final sorted = container.read(filteredWorkerTasksProvider);
      final ids = sorted.map((t) => t.id).toList();

      expect(ids[0], 'D2'); // 01/01/2026 — earliest
      expect(ids[1], 'D1'); // 10/03/2026 — later
      expect(ids[2], 'D3'); // no dueDate — goes last
    });

    test('default STATUS_DATE sort orders by status first then date', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      // Default sortOrder is STATUS_DATE; default filter is OPEN (inProgress + onHold)
      final sorted = container.read(filteredWorkerTasksProvider);
      final ids = sorted.map((t) => t.id).toList();

      // T2 is inProgress (priority 1), T3 is onHold (priority 3)
      expect(ids.indexOf('T2'), lessThan(ids.indexOf('T3')));
    });
  });
}

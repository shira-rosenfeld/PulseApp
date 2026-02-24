import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_frontend/models/dtos/worker_task.dart';
import 'package:pulse_frontend/models/enums/work_item_status.dart';
import 'package:pulse_frontend/models/enums/worker_type.dart';
import 'package:pulse_frontend/providers/worker_providers.dart';

List<WorkerTask> _seedTasks() => [
  WorkerTask(id: 'T1', path: 'P1', desc: 'Task 1', status: WorkItemStatus.newTask, planned: 10, totalReported: 0, reportedThisWeek: 0, workerType: WorkerType.internal),
  WorkerTask(id: 'T2', path: 'P1', desc: 'Task 2', status: WorkItemStatus.inProgress, planned: 8, totalReported: 2, reportedThisWeek: 0, workerType: WorkerType.internal),
  WorkerTask(id: 'T3', path: 'P2', desc: 'Task 3', status: WorkItemStatus.onHold, planned: 5, totalReported: 1, reportedThisWeek: 0, workerType: WorkerType.external),
  WorkerTask(id: 'T4', path: 'P2', desc: 'Task 4', status: WorkItemStatus.done, planned: 6, totalReported: 6, reportedThisWeek: 0, workerType: WorkerType.internal),
  WorkerTask(id: 'T5', path: 'P3', desc: 'Task 5', status: WorkItemStatus.canceled, planned: 4, totalReported: 0, reportedThisWeek: 0, workerType: WorkerType.external),
];

ProviderContainer _makeContainer() {
  final container = ProviderContainer(overrides: [
    workerTasksProvider.overrideWith((ref) => WorkerTasksNotifier(ref, _seedTasks())),
  ]);
  return container;
}

void main() {
  group('WorkerTasksNotifier.updateHours', () {
    test('increases hours by delta', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateHours('T2', 3.0);
      final task = container.read(workerTasksProvider).firstWhere((t) => t.id == 'T2');

      expect(task.reportedThisWeek, 3.0);
    });

    test('does not go below 0', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateHours('T1', -5.0);
      final task = container.read(workerTasksProvider).firstWhere((t) => t.id == 'T1');

      expect(task.reportedThisWeek, 0.0);
    });

    test('auto-promotes newTask to inProgress when hours > 0', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateHours('T1', 1.0);
      final task = container.read(workerTasksProvider).firstWhere((t) => t.id == 'T1');

      expect(task.status, WorkItemStatus.inProgress);
    });

    test('marks hasChanges = true after update', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(workerTasksProvider.notifier).updateHours('T1', 2.0);
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
    test('OPEN filter returns newTask, inProgress, onHold', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).state = 'OPEN';
      final filtered = container.read(filteredWorkerTasksProvider);

      expect(filtered.any((t) => t.status == WorkItemStatus.newTask), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.inProgress), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.onHold), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.done), false);
      expect(filtered.any((t) => t.status == WorkItemStatus.canceled), false);
    });

    test('CLOSED filter returns done and canceled', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).state = 'CLOSED';
      final filtered = container.read(filteredWorkerTasksProvider);

      expect(filtered.any((t) => t.status == WorkItemStatus.done), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.canceled), true);
      expect(filtered.any((t) => t.status == WorkItemStatus.newTask), false);
      expect(filtered.any((t) => t.status == WorkItemStatus.inProgress), false);
    });

    test('ALL filter returns everything', () {
      final container = _makeContainer();
      addTearDown(container.dispose);

      container.read(taskFilterProvider.notifier).state = 'ALL';
      final filtered = container.read(filteredWorkerTasksProvider);

      expect(filtered.length, 5);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dtos/target.dart';
import '../models/dtos/output.dart';
import '../models/dtos/work_item.dart';
import '../models/dtos/worker.dart';
import '../models/enums/worker_type.dart';
import '../models/enums/work_item_status.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final expandedNodesProvider = StateNotifierProvider<ExpandedNodesNotifier, Map<String, bool>>((ref) {
  return ExpandedNodesNotifier({'WBS-2026.10': true, 'NET-80001': true, 'NET-80002': true});
});

class ExpandedNodesNotifier extends StateNotifier<Map<String, bool>> {
  ExpandedNodesNotifier(super.state);
  void toggle(String id) {
    state = {...state, id: !(state[id] ?? false)};
  }
}

// Mock Data Source
final wbsDataProvider = Provider<List<Target>>((ref) {
  return [
    Target(
      id: 'WBS-2026.10',
      name: 'פיתוח מערכת ניהול תפוקות',
      stats: {'total': 9, 'done': 3, 'inProgress': 3, 'new': 2},
      children: [
        Output(
          id: 'NET-80001',
          name: 'תכנון ארכיטקטורה',
          children: [
            WorkItem(
              id: 'TASK-1001',
              desc: 'עיצוב מסד נתונים',
              status: WorkItemStatus.done,
              worker: Worker(name: 'יוסי כהן', type: WorkerType.internal),
              planned: 10,
              actual: 9,
            ),
            WorkItem(
              id: 'TASK-1002',
              desc: 'תכנון API',
              status: WorkItemStatus.inProgress,
              worker: Worker(name: 'דנה לוי', type: WorkerType.internal),
              planned: 8,
              actual: 5,
            ),
            WorkItem(
              id: 'TASK-1003',
              desc: 'ייעוץ אבטחה',
              status: WorkItemStatus.done,
              worker: Worker(name: 'מיכאל ברג', type: WorkerType.external),
              planned: 6,
              actual: 6,
            ),
          ],
        ),
        Output(
          id: 'NET-80002',
          name: 'פיתוח צד לקוח',
          children: [
            WorkItem(
              id: 'TASK-1004',
              desc: 'ממשק מנהל - שולחן עבודה',
              status: WorkItemStatus.inProgress,
              worker: Worker(name: 'שירה רוזנפלד', type: WorkerType.internal),
              planned: 20,
              actual: 14,
            ),
            WorkItem(
              id: 'TASK-1005',
              desc: 'ממשק עובד - דיווח שבועי',
              status: WorkItemStatus.inProgress,
              worker: Worker(name: 'שירה רוזנפלד', type: WorkerType.internal),
              planned: 16,
              actual: 10,
            ),
            WorkItem(
              id: 'TASK-1006',
              desc: 'בדיקות UI',
              status: WorkItemStatus.newTask,
              worker: Worker(name: 'אבי גולן', type: WorkerType.internal),
              planned: 12,
              actual: 0,
            ),
          ],
        ),
        Output(
          id: 'NET-80003',
          name: 'פיתוח צד שרת',
          children: [
            WorkItem(
              id: 'TASK-1007',
              desc: 'פיתוח שירותי REST',
              status: WorkItemStatus.done,
              worker: Worker(name: 'רון שפירא', type: WorkerType.internal),
              planned: 18,
              actual: 20,
            ),
            WorkItem(
              id: 'TASK-1008',
              desc: 'אינטגרציה עם מסד נתונים',
              status: WorkItemStatus.newTask,
              worker: Worker(name: 'רון שפירא', type: WorkerType.internal),
              planned: 10,
              actual: 0,
            ),
            WorkItem(
              id: 'TASK-1009',
              desc: 'ייעוץ ביצועים',
              status: WorkItemStatus.onHold,
              worker: Worker(name: "ג'ון סמית", type: WorkerType.external),
              planned: 5,
              actual: 2,
            ),
          ],
        ),
      ],
    ),
    Target(
      id: 'WBS-2026.11',
      name: 'הטמעה ובדיקות קבלה',
      stats: {'total': 4, 'done': 1, 'inProgress': 1, 'new': 2},
      children: [
        Output(
          id: 'NET-80004',
          name: 'סביבת הדגמה',
          children: [
            WorkItem(
              id: 'TASK-1010',
              desc: 'הקמת סביבת staging',
              status: WorkItemStatus.done,
              worker: Worker(name: 'יוסי כהן', type: WorkerType.internal),
              planned: 8,
              actual: 8,
            ),
            WorkItem(
              id: 'TASK-1011',
              desc: 'הדרכת משתמשים',
              status: WorkItemStatus.inProgress,
              worker: Worker(name: 'דנה לוי', type: WorkerType.internal),
              planned: 12,
              actual: 4,
            ),
          ],
        ),
        Output(
          id: 'NET-80005',
          name: 'בדיקות קבלה',
          children: [
            WorkItem(
              id: 'TASK-1012',
              desc: 'תסריטי בדיקה',
              status: WorkItemStatus.newTask,
              worker: Worker(name: 'אבי גולן', type: WorkerType.internal),
              planned: 10,
              actual: 0,
            ),
            WorkItem(
              id: 'TASK-1013',
              desc: 'בדיקות חדירה',
              status: WorkItemStatus.canceled,
              worker: Worker(name: 'מיכאל ברג', type: WorkerType.external),
              planned: 8,
              actual: 0,
            ),
          ],
        ),
      ],
    ),
  ];
});

// Deep Search Logic (Targets, Outputs, and Workers)
final filteredDataProvider = Provider<List<Target>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final data = ref.watch(wbsDataProvider);

  if (query.isEmpty) return data;

  List<Target> result = [];

  for (var target in data) {
    bool targetMatches = target.name.toLowerCase().contains(query) ||
        target.id.toLowerCase().contains(query);
    List<Output> filteredOutputs = [];

    for (var output in target.children) {
      bool outputMatches = output.name.toLowerCase().contains(query) ||
          output.id.toLowerCase().contains(query);
      List<WorkItem> filteredItems = [];

      for (var item in output.children) {
        // Matches Task Description, Task ID, OR Worker Name
        bool itemMatches = item.desc.toLowerCase().contains(query) ||
                           item.id.toLowerCase().contains(query) ||
                           item.worker.name.toLowerCase().contains(query);

        if (itemMatches || outputMatches || targetMatches) {
          filteredItems.add(item);
        }
      }

      if (filteredItems.isNotEmpty || outputMatches || targetMatches) {
        filteredOutputs.add(output.copyWith(
          children: (filteredItems.isEmpty && (outputMatches || targetMatches)) ? output.children : filteredItems
        ));
      }
    }

    if (filteredOutputs.isNotEmpty || targetMatches) {
      result.add(target.copyWith(
        children: (filteredOutputs.isEmpty && targetMatches) ? target.children : filteredOutputs
      ));
    }
  }
  return result;
});

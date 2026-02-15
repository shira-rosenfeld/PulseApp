import '../enums/work_item_status.dart';
import 'worker.dart';

class WorkItem {
  final String id;
  final String desc;
  final WorkItemStatus status;
  final Worker worker;
  final double planned;
  final double actual;

  WorkItem({
    required this.id,
    required this.desc,
    required this.status,
    required this.worker,
    required this.planned,
    required this.actual,
  });
}
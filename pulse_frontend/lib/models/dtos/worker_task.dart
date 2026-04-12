import '../enums/work_item_status.dart';
import '../enums/worker_type.dart';

class WorkerTask {
  final String id;
  final String path;
  final String desc;
  final WorkItemStatus status;
  final double planned;
  final double totalReported;
  final double reportedThisWeek;
  final String? actualStart;
  final String? dueDate;    // planned completion date (for sorting + display)
  final String? actualEnd;  // actual end/completion date (for display)
  final WorkerType workerType;

  WorkerTask({
    required this.id,
    required this.path,
    required this.desc,
    required this.status,
    required this.planned,
    required this.totalReported,
    required this.reportedThisWeek,
    this.actualStart,
    this.dueDate,
    this.actualEnd,
    required this.workerType,
  });

  WorkerTask copyWith({
    WorkItemStatus? status,
    double? reportedThisWeek,
  }) {
    return WorkerTask(
      id: id,
      path: path,
      desc: desc,
      status: status ?? this.status,
      planned: planned,
      totalReported: totalReported,
      reportedThisWeek: reportedThisWeek ?? this.reportedThisWeek,
      actualStart: actualStart,
      dueDate: dueDate,
      actualEnd: actualEnd,
      workerType: workerType,
    );
  }
}
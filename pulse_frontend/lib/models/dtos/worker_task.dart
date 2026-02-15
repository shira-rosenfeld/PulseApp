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
      status: status?? this.status,
      planned: planned,
      totalReported: totalReported,
      reportedThisWeek: reportedThisWeek?? this.reportedThisWeek,
      actualStart: actualStart,
      workerType: workerType,
    );
  }
}
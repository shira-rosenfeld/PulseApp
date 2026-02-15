enum WorkItemStatus {
  newTask('10'),
  inProgress('20'),
  onHold('30'),
  done('40'),
  canceled('90');

  final String code;
  const WorkItemStatus(this.code);

  static WorkItemStatus fromCode(String code) {
    return WorkItemStatus.values.firstWhere(
      (e) => e.code == code, 
      orElse: () => WorkItemStatus.newTask
    );
  }
}
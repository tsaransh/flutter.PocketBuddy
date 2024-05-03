class ExpenseRoom {
  ExpenseRoom(
      {required this.groupId,
      required this.groupTitle,
      required this.createdDate,
      required this.userUid,
      required this.username});

  final String? groupId;
  final String? groupTitle;
  final DateTime? createdDate;
  final String? userUid;

  final String? username;
}

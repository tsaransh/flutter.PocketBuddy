class ExpenseRoom {
  ExpenseRoom(
      {required this.groupId,
      required this.groupTitle,
      required this.createdDate,
      required this.userUid,
      required this.roomDescription,
      required this.username});

  final String? groupId;
  String? groupTitle;
  final DateTime? createdDate;
  final String? userUid;
  String? roomDescription;
  final String? username;

  void setDesc(String desc) {
    roomDescription = desc;
  }

  void setName(title) {
    groupTitle = title;
  }
}

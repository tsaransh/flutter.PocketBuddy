class UserJoinGroupDetails {
  final int sno;
  final String groupId;
  final String groupTitle;
  final String userUid;
  final DateTime joinDate;

  const UserJoinGroupDetails(
      {required this.sno,
      required this.groupId,
      required this.groupTitle,
      required this.userUid,
      required this.joinDate});
}

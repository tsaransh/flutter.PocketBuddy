import 'package:uuid/uuid.dart';

const uuid = Uuid();

class RoomExpense {
  final String expenseId;
  final String expenseTitle;
  final double expenseAmount;
  DateTime? dateOfExpense;
  final String userUid;
  final String groupId;
  final String userName;

  RoomExpense(
      {required this.expenseTitle,
      required this.expenseAmount,
      required this.userUid,
      required this.groupId,
      required this.userName})
      : expenseId = uuid.v4();

  RoomExpense.value(
      {required this.expenseId,
      required this.expenseTitle,
      required this.expenseAmount,
      required this.dateOfExpense,
      required this.userUid,
      required this.groupId,
      required this.userName});
}

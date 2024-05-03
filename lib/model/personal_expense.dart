import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class PersonalExpense {
  PersonalExpense(
    this.expenseTitle,
    this.expenseAmount,
    this.userUid,
  ) : id = uuid.v4();
  final String id;
  final String expenseTitle;
  final double expenseAmount;
  DateTime? expenseDate;
  final String userUid;

  PersonalExpense.value(
      {required this.id,
      required this.expenseTitle,
      required this.expenseAmount,
      required this.expenseDate,
      required this.userUid});
}

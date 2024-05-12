import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_buddy_new/model/personal_expense.dart';
import 'package:pocket_buddy_new/model/rest_api_url.dart';
import 'package:http/http.dart' as http;
import 'package:pocket_buddy_new/screens/expense_details.dart';
import 'package:pocket_buddy_new/screens/profile.dart';
import 'package:pocket_buddy_new/screens/statements.dart';

class PersonalExpenseScreen extends StatefulWidget {
  const PersonalExpenseScreen({super.key});

  @override
  State<PersonalExpenseScreen> createState() => _PersonalExpenseScreenState();
}

class _PersonalExpenseScreenState extends State<PersonalExpenseScreen> {
  late List<PersonalExpense> _expenseList;

  final _expenseTitleController = TextEditingController();
  final _expenseAmountController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  bool _fetching = true;

  double? _totalSum = 0.00;
  double? _lastDaysSum = 0.00;

  @override
  void initState() {
    super.initState();
    _fetchDataFromDb();
  }

  @override
  void dispose() {
    _expenseTitleController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  Future<void> _fetchDataFromDb() async {
    _expenseList = [];
    _totalSum = 0.00;
    _lastDaysSum = 0.00;
    setState(() {
      _fetching = true;
    });

    try {
      final Uri allTimeTotal = Uri.parse(
          "${ApiUrl.personalExpense}/alltimetotal?userUid=${_auth.currentUser!.uid}");
      final Uri lastDaysTotal = Uri.parse("${ApiUrl.personalExpense}/total");
      final Uri lastDayStatement =
          Uri.parse("${ApiUrl.personalExpense}/statements");

      final lastDaysSumResponse = await http.post(lastDaysTotal,
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode({
            "id": _auth.currentUser!.uid,
            "startDate": DateTime.now()
                .subtract(const Duration(days: 30))
                .toIso8601String(),
            "endDate": DateTime.now().toIso8601String(),
          }));
      final lastDaysStatementResponse = await http.post(lastDayStatement,
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode({
            "id": _auth.currentUser!.uid,
            "startDate": DateTime.now()
                .subtract(const Duration(days: 30))
                .toIso8601String(),
            "endDate": DateTime.now().toIso8601String(),
          }));

      final allTimeTotalResponse = await http.get(allTimeTotal);

      if (lastDaysStatementResponse.statusCode == 400) {
        return;
      }

      if (allTimeTotalResponse.statusCode == 200 &&
          lastDaysSumResponse.statusCode == 200 &&
          lastDaysStatementResponse.statusCode == 200) {
        final allTimeTotal = json.decode(allTimeTotalResponse.body);
        final lastDaysSum = json.decode(lastDaysSumResponse.body);
        final lastDaysStatement = json.decode(lastDaysStatementResponse.body);

        _totalSum = allTimeTotal;
        _lastDaysSum = lastDaysSum;

        for (final map in lastDaysStatement) {
          final expense = PersonalExpense.value(
            id: map['id'],
            expenseTitle: map['expenseTitle'],
            expenseAmount: map['expenseAmount'],
            expenseDate: DateTime.parse(map['date']),
            userUid: map['userUid'],
          );
          _expenseList.add(expense);
        }
      }
    } catch (error) {
      _showError("oops something went wrong");
    } finally {
      setState(() {
        _fetching = false;
      });
    }
  }

  void _showAddExpense() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _expenseTitleController,
                decoration: const InputDecoration(
                  labelText: 'Reason of Expense',
                  prefixIcon: Icon(Icons.data_array_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _expenseAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                  ),
                  labelText: 'Enter Amount',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addExpense,
                icon: const Icon(Icons.add),
                label: const Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addExpense() async {
    if (_expenseTitleController.text.isEmpty ||
        _expenseAmountController.text.isEmpty) {
      _showError("Please enter title and amount to add expense");
      return;
    }

    final String title = _expenseTitleController.text;
    final double amount = double.parse(_expenseAmountController.text);

    Uri addExpenseUrl = Uri.parse('${ApiUrl.personalExpense}/add');
    try {
      final expense = PersonalExpense(title, amount, _auth.currentUser!.uid);

      final response = await http.post(
        addExpenseUrl,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode({
          "id": expense.id,
          "expenseTitle": expense.expenseTitle,
          "expenseAmount": expense.expenseAmount,
          "userUid": expense.userUid
        }),
      );

      if (response.statusCode == 201) {
        final responseDate = json.decode(response.body);
        _totalSum = _totalSum! + amount;
        _lastDaysSum = _lastDaysSum! + amount;
        final expense = PersonalExpense.value(
            id: responseDate['id'],
            expenseTitle: responseDate['expenseTitle'],
            expenseAmount: responseDate['expenseAmount'],
            expenseDate: DateTime.parse(responseDate['date']),
            userUid: responseDate['userUid']);
        setState(() {
          _expenseList.add(expense);
        });
      }
    } catch (error) {
      _showError("Failed to add expense");
    } finally {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      _expenseTitleController.clear();
      _expenseAmountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Buddy'),
        actions: [
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ));
                  },
                  child: Row(children: [
                    Icon(
                      Icons.person_pin,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    const SizedBox(width: 4),
                    const Text('Profile')
                  ])),
              PopupMenuItem(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FetchStatement(),
                      ),
                    );
                  },
                  child: Row(children: [
                    Icon(
                      Icons.library_books,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    const SizedBox(width: 4),
                    const Text('Statements')
                  ])),
              PopupMenuItem(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Row(children: [
                  Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(width: 4),
                  const Text('Logout')
                ]),
              ),
            ],
          ),
        ],
      ),
      body: !_fetching
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    width: double.infinity,
                    height: 120,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color.fromARGB(255, 189, 158, 132),
                        Color.fromARGB(255, 28, 139, 126)
                      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense Amount',
                          style: GoogleFonts.abhayaLibre(
                            color: Theme.of(context).colorScheme.background,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹ $_totalSum",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Last Month',
                                  style: GoogleFonts.actor(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                                ),
                                Text(
                                  '₹ $_lastDaysSum',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .background,
                                      ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: _expenseList.isEmpty
                              ? const Center(
                                  child: Text('Oops no expense found!'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _expenseList.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onLongPress: () {
                                        _showDeleteDialog(_expenseList[index]);
                                      },
                                      onTap: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => ExpenseDetail(
                                            expense: _expenseList[index],
                                            deleteExpense: _deleteExpense,
                                            refershData: _fetchDataFromDb,
                                          ),
                                        ));
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        width: double.infinity,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: index % 2 == 0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _expenseList[index].expenseTitle,
                                              style: GoogleFonts.aBeeZee(
                                                color: index % 2 == 0
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  '₹ ${_expenseList[index].expenseAmount}',
                                                  style:
                                                      GoogleFonts.abrilFatface(
                                                    color: index % 2 == 0
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(
                                                          _expenseList[index]
                                                              .expenseDate!),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: index % 2 == 0
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .surface,
                                                      ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                onPressed: _showAddExpense,
                                child: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  _showDeleteDialog(PersonalExpense expense) {
    return showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content:
              Text('Are you sure you want to delete ${expense.expenseTitle}'),
          actions: [
            TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red),
                padding: MaterialStatePropertyAll(
                  EdgeInsets.all(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExpense(expense.id);
              },
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  _deleteExpense(String id) async {
    Uri url = Uri.parse('${ApiUrl.personalExpense}/delete?id=$id');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _fetchDataFromDb();
        });
      }
    } catch (error) {
      _showError("failed to delete expense");
    }
  }

  void _showError(String errorMessage) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        action: SnackBarAction(
          label: 'Okay',
          textColor: Theme.of(context).colorScheme.background,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      ),
    );
  }
}

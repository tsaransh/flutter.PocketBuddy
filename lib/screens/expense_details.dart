// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pocket_buddy_new/model/personal_expense.dart';
import 'package:pocket_buddy_new/model/rest_api_url.dart';

import 'package:http/http.dart' as http;

class ExpenseDetail extends StatefulWidget {
  const ExpenseDetail(
      {super.key,
      required this.expense,
      required this.deleteExpense,
      required this.refershData});

  final PersonalExpense expense;
  final Function(String id) deleteExpense;
  final Function() refershData;

  @override
  State<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseDetail> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  bool _updatingExpense = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.expenseTitle);
    _amountController =
        TextEditingController(text: widget.expense.expenseAmount.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  _updateExpenseData() async {
    setState(() {
      _updatingExpense = true;
    });
    Uri updateUrl = Uri.parse('${ApiUrl.personalExpense}/update');
    try {
      final response = await http.post(
        updateUrl,
        headers: <String, String>{"Content-Type": "application/json"},
        body: json.encode({
          "id": widget.expense.id,
          "expenseTitle": _titleController.text,
          "expenseAmount": double.parse(_amountController.text),
          "userUid": widget.expense.userUid,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        widget.refershData();
      }
    } catch (error) {
      showError("filed to update data");
    } finally {
      setState(() {
        _updatingExpense = true;
      });
    }
  }

  showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        action: SnackBarAction(
            label: 'Okay',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Details',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.background,
              ),
        ),
      ),
      body: _updatingExpense
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildNonEditableRow('Expense ID', widget.expense.id),
                    const SizedBox(height: 12),
                    _buildEditableRow('Expense Title', _titleController),
                    const SizedBox(height: 12),
                    _buildEditableRow('Expense Amount', _amountController),
                    const SizedBox(height: 12),
                    _buildNonEditableRow(
                      'Expense Date and Time',
                      widget.expense.expenseDate!.toIso8601String(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.deleteExpense(widget.expense.id);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.background,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: _updateExpenseData,
                          icon: const Icon(Icons.update),
                          label: const Text('Update'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNonEditableRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 94, 92, 92).withOpacity(0.9),
        borderRadius: const BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      width: double.infinity,
      child: TextFormField(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: title,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildEditableRow(String title, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 109, 133, 141).withOpacity(0.9),
        borderRadius: const BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      width: double.infinity,
      child: TextFormField(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }
}

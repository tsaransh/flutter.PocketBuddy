import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_buddy_new/model/personal_expense.dart';
import 'package:pocket_buddy_new/model/rest_api_url.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FetchStatement extends StatefulWidget {
  const FetchStatement({super.key});

  @override
  State<FetchStatement> createState() => _FetchStatementState();
}

class _FetchStatementState extends State<FetchStatement> {
  String? _currentUser;

  DateTime? _startDate;
  DateTime? _endDate;

  List<PersonalExpense>? _expenseList;
  double? _totalSum = 0.00;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!.uid;
  }

  _showDatePicker(int i) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2002, 9),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value == null) return;
      if (i == 0) {
        setState(() {
          _startDate = value;
        });
      } else {
        setState(() {
          _endDate = value;
        });
      }
    });
  }

  _fetchStatement(int i) async {
    _expenseList = [];
    Uri fetchDataUrl = Uri.parse('${ApiUrl.personalExpense}/statements');
    Uri fetchTotalUrl = Uri.parse('${ApiUrl.personalExpense}/total');
    try {
      _endDate = _endDate!.add(const Duration(days: 1));
      final fetchResponse = await http.post(
        fetchDataUrl,
        headers: <String, String>{"Content-Type": "application/json"},
        body: json.encode(
          {
            "id": _currentUser,
            "startDate": _startDate != null
                ? DateFormat('yyyy-MM-dd').format(_startDate!)
                : null,
            "endDate": _endDate != null
                ? DateFormat('yyyy-MM-dd').format(_endDate!)
                : null,
          },
        ),
      );

      final totalSumResponse = await http.post(
        fetchTotalUrl,
        headers: <String, String>{"Content-Type": "application/json"},
        body: json.encode(
          {
            "id": _currentUser,
            "startDate": _startDate != null
                ? DateFormat('yyyy-MM-dd').format(_startDate!)
                : null,
            "endDate": _endDate != null
                ? DateFormat('yyyy-MM-dd').format(_endDate!)
                : null,
          },
        ),
      );

      if (fetchResponse.statusCode == 200 &&
          totalSumResponse.statusCode == 200) {
        final responseStatementResponse = json.decode(fetchResponse.body);

        _totalSum = double.parse(totalSumResponse.body);

        for (final map in responseStatementResponse) {
          final expense = PersonalExpense.value(
            id: map['id'],
            expenseTitle: map['expenseTitle'],
            expenseAmount: map['expenseAmount'],
            expenseDate: DateTime.parse(map['date']),
            userUid: map['userUid'],
          );

          _expenseList!.add(expense);
        }

        if (i == 1) {
          _generatePdf();
        }
      }
    } catch (error) {
      print(error);
    }
  }

  _generatePdf() async {
    try {
      final document = PdfDocument();
      final page = document.pages.add();

      page.graphics.drawString(
        'Report form ${DateFormat('dd-MM-yyyy').format(_startDate!)} to ${DateFormat('dd-MM-yyyy').format(_endDate!)}\n\n\n\n\n',
        PdfStandardFont(PdfFontFamily.helvetica, 20),
      );

      final grid = PdfGrid();

      grid.style = PdfGridStyle(
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
        cellPadding: PdfPaddings(left: 2, right: 2, top: 4, bottom: 4),
      );

      grid.columns.add(count: 3);
      grid.headers.add(1);

      PdfGridRow header = grid.headers[0];
      header.cells[0].value = 'Date';
      header.cells[1].value = 'Title';
      header.cells[2].value = 'Amount';
      PdfGridRow row = grid.rows.add();
      for (final expense in _expenseList!) {
        row.cells[0].value =
            DateFormat("dd-MM-yyyy").format(expense.expenseDate!);
        row.cells[1].value = expense.expenseTitle;
        row.cells[2].value = expense.expenseAmount.toString();
      }
      row.cells[1].value = 'total expense';
      row.cells[2].value = _totalSum.toString();
      grid.draw(
          page: page,
          bounds: Rect.fromLTWH(0, 40, page.getClientSize().width,
              page.getClientSize().height - 40));

      List<int> bytes = await document.save();
      document.dispose();
      _saveAndLaunchFile(bytes, '$_currentUser');
    } catch (e) {
      print("error: $e");
    }
  }

  _saveAndLaunchFile(List<int> bytes, String fileName) async {
    try {
      final path = (await getExternalStorageDirectory())?.path;
      final file = File('$path/$fileName.pdf');
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open('$path/$fileName.pdf');
    } catch (e) {
      print("error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onInverseSurface,
              borderRadius: const BorderRadius.all(
                Radius.circular(25),
              ),
            ),
            width: double.infinity,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'select dates to find!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(_startDate != null
                        ? DateFormat('dd-MM-yyyy').format(_startDate!)
                        : 'No date selected'),
                    Text(_endDate != null
                        ? DateFormat('dd-MM-yyyy').format(_endDate!)
                        : 'No date selected')
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onBackground,
                      ),
                      onPressed: () {
                        _showDatePicker(0);
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('start date'),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onBackground,
                      ),
                      onPressed: () {
                        _showDatePicker(1);
                      },
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: const Text('end date'),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: () => _fetchStatement(0),
                      icon: const Icon(Icons.remove_red_eye_rounded),
                      label: const Text('View'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () => _fetchStatement(1),
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

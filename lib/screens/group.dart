// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_buddy_new/model/expense_room.dart';
import 'package:pocket_buddy_new/model/rest_api_url.dart';
import 'package:pocket_buddy_new/model/room_expense.dart';
import 'package:pocket_buddy_new/widgets/room_details.dart';

import 'package:http/http.dart' as http;

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.room});

  final ExpenseRoom room;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentUser = '';

  List<RoomExpense> roomExpenseList = [];
  double totalAmount = 0.00;
  double todayAmount = 0.00;

  final groupUrl = ApiUrl.groupExpense;
  final groupDataUrl = ApiUrl.groupExpenseData;

  final detailController = TextEditingController();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    getUserData();
    _fetchRoomData();
    _fetchTodayExpense();
    timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => _fetchDataWithTime());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUser = user!.uid;
    });
  }

  _fetchDataWithTime() {
    _fetchRoomData();
    _fetchTodayExpense();
  }

  _fetchRoomData() async {
    roomExpenseList = [];
    final dataUrl =
        Uri.parse('$groupDataUrl/statement?groupId=${widget.room.groupId}');
    final sumUrl =
        Uri.parse('$groupDataUrl/total?groupId=${widget.room.groupId}');

    try {
      final responseDataUrl = await http.get(dataUrl);
      final responseSumUrl = await http.get(sumUrl);
      _fetchTodayExpense();
      if (responseDataUrl.statusCode == 200 &&
          responseSumUrl.statusCode == 200) {
        final responseData = json.decode(responseDataUrl.body);
        // Sort the list by dateOfExpense
        responseData.sort((a, b) => DateTime.parse(a['dateOfExpense'])
            .compareTo(DateTime.parse(b['dateOfExpense'])));
        for (final map in responseData) {
          final room = RoomExpense.value(
            expenseId: map['expenseId'],
            expenseTitle: map['expenseTitle'],
            expenseAmount: double.parse(map['expenseAmount'].toString()),
            dateOfExpense: DateTime.parse(map['dateOfExpense']),
            userUid: map['userUid'],
            groupId: map['groupId'],
            userName: map['userName'],
          );

          roomExpenseList.add(room);
        }

        final responseSumData = json.decode(responseSumUrl.body);

        totalAmount = responseSumData;
      }
    } catch (error) {
      showError("failed to fetch data");
    } finally {
      setState(() {});
    }
  }

  void _fetchTodayExpense() async {
    final url = Uri.parse('$groupDataUrl/getTotalByDates');
    try {
      final response = await http.post(url,
          headers: <String, String>{"Content-Type": "application/json"},
          body: json.encode({
            "id": widget.room.groupId,
            "startDate":
                "${DateTime.now().toIso8601String().substring(0, 10)}T00:00:00",
            "endDate": DateTime.now().toIso8601String(),
          }));

      if (response.statusCode == 200) {
        todayAmount = json.decode(response.body);
      }
    } catch (error) {
      showError('failded to get today expense amount');
    }
  }

  addExpense() async {
    final url = Uri.parse('$groupDataUrl/add');

    try {
      Map<String, dynamic> expenseDetails = getExpenseDetails();
      String item = expenseDetails['item'];
      double amount = expenseDetails['amount'];
      if (item.isEmpty) {
        showError('Please add your expense reason.');
        return;
      }
      if (amount <= 0.00) {
        showError('Amount can\'t be less than or equal to 0');
        return;
      }
      final name = await getName();
      final RoomExpense room = RoomExpense(
          expenseTitle: item,
          expenseAmount: amount,
          userUid: currentUser,
          groupId: widget.room.groupId!,
          userName: name.toString());
      final response = await http.post(
        url,
        headers: <String, String>{"Content-Type": "application/json"},
        body: json.encode(
          {
            "expenseId": room.expenseId,
            "expenseTitle": room.expenseTitle,
            "expenseAmount": room.expenseAmount,
            "groupId": room.groupId,
            "userUid": room.userUid,
            "userName": room.userName,
          },
        ),
      );
      if (response.statusCode == 201) {
        _fetchRoomData();
      }
    } catch (error) {
      showError('failed to add expense');
    } finally {
      detailController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Map<String, dynamic> getExpenseDetails() {
    String input = detailController.text;

    List<String> parts = input.split(' for ');

    double amount = double.tryParse(parts[0]) ?? 0.0;
    String item = parts.length > 1 ? parts.sublist(1).join(' for ') : '';

    return {'amount': amount, 'item': item};
  }

  getName() async {
    try {
      String? name;
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        name = user.displayName;
        if (name == null || name.isEmpty) {
          final data = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser)
              .get();

          name = data['firstname'] + " " + data['lastname'];
        }
      }
      return name;
    } catch (e) {
      showError('something went wrong');
    }
  }

  deleteExpense(String expenseId) async {
    final url = Uri.parse('$groupDataUrl/delete?expenseId=$expenseId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchTodayExpense();
        _fetchRoomData();
      }
    } catch (e) {
      showError('failed to delete expense');
    } finally {
      Navigator.of(context).pop();
    }
  }

  _showUpdateExpense(RoomExpense expense) {
    final titleController = TextEditingController(text: expense.expenseTitle);
    final amountController =
        TextEditingController(text: expense.expenseAmount.toString());
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.title_outlined),
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed: () {
                    _updateExpense(
                        expense, titleController.text, amountController.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Update'))
            ],
          ),
        );
      },
    );
  }

  _updateExpense(RoomExpense room, String title, String amount) async {
    final url = Uri.parse('$groupDataUrl/update');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{"Content-Type": "application/json"},
        body: json.encode(
          {
            "expenseId": room.expenseId,
            "expenseTitle": title,
            "expenseAmount": double.parse(amount),
            "groupId": room.groupId,
            "userUid": room.userUid,
            "userName": room.userName,
          },
        ),
      );
      if (response.statusCode == 201) {
        _fetchRoomData();
        _fetchTodayExpense();
      }
    } catch (error) {
      Navigator.of(context).pop();
      showError('failed to update expense');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RoomDetailsWidget(room: widget.room),
              ),
            );
          },
          child: Text('${widget.room.groupTitle}'),
        ),
        actions: <Widget>[
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          RoomDetailsWidget(room: widget.room),
                    ),
                  );
                },
                child: const Text('Room info'),
              ),
              PopupMenuItem(
                onTap: () {},
                child: const Text('Statements'),
              ),
              PopupMenuItem(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.room.groupId!));
                },
                child: const Text('Copy group id'),
              ),
              PopupMenuItem(
                onTap: leaveRoom,
                child: const Text('Leave'),
              ),
            ],
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFB597F6)
                  : const Color.fromARGB(255, 1, 44, 65),
              Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFF96C6EA)
                  : const Color.fromARGB(255, 31, 4, 0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 189, 158, 132),
                    Color.fromARGB(255, 28, 139, 126)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹ $totalAmount",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Theme.of(context).colorScheme.background,
                            ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Today',
                            style: GoogleFonts.actor(
                              color: Theme.of(context).colorScheme.background,
                            ),
                          ),
                          Text(
                            '₹ $todayAmount',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                reverse: true, // Reverse the ListView
                padding: const EdgeInsets.all(8),
                children: [
                  // Add your message container here
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: roomExpenseList.map((expense) {
                        return expense.expenseAmount == 0.00
                            ? (expense.expenseTitle.compareTo('L') == 0)
                                ? _showLeaveInfo(
                                    expense.userName,
                                    DateFormat('MM/dd/yy \'at\' h:mm a')
                                        .format(expense.dateOfExpense!))
                                : _showJoinWelcome(
                                    expense.userName,
                                    DateFormat('MM/dd/yy \'at\' h:mm a')
                                        .format(expense.dateOfExpense!))
                            : Align(
                                alignment: expense.userUid == currentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: GestureDetector(
                                    onLongPressStart:
                                        (LongPressStartDetails details) {
                                      _showExpenseMenu(expense, details);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: expense.userUid == currentUser
                                            ? const Color.fromARGB(
                                                    255, 103, 224, 107)
                                                .withOpacity(0.7)
                                            : Theme.of(context)
                                                .colorScheme
                                                .background,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expense.userUid == currentUser
                                                ? 'You'
                                                : expense.userName,
                                            style: TextStyle(
                                              color:
                                                  expense.userUid == currentUser
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                expense.expenseTitle,
                                                style: TextStyle(
                                                  color: expense.userUid ==
                                                          currentUser
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                '₹ ${expense.expenseAmount}',
                                                style: TextStyle(
                                                  color: expense.userUid ==
                                                          currentUser
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                DateFormat(
                                                        'MM/dd/yy \'at\' h:mm a')
                                                    .format(
                                                        expense.dateOfExpense!),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: expense.userUid ==
                                                          currentUser
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: detailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          IconData(0xf04e1, fontFamily: 'MaterialIcons'),
                        ),
                        labelText: 'Expense',
                        hintText: 'e.g., ₹ 250 for Riksha',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (detailController.text.isEmpty) {
                        showError('Please enter expense details to add');
                      } else {
                        addExpense();
                      }
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        action: SnackBarAction(
          label: 'Okay',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showExpenseMenu(RoomExpense expense, LongPressStartDetails details) {
    if (expense.userUid.compareTo(currentUser) == 0) {
      final RenderBox overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      showMenu(
        color: Theme.of(context).colorScheme.onBackground,
        context: context,
        position: RelativeRect.fromLTRB(
          details.globalPosition.dx,
          details.globalPosition.dy,
          overlay.size.width - details.globalPosition.dx,
          overlay.size.height - details.globalPosition.dy,
        ),
        items: [
          PopupMenuItem(
            child: ListTile(
              onTap: () {
                Navigator.of(context).pop();
                _showUpdateExpense(expense);
              },
              title: Text(
                'Update Expense',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.background,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            child: ListTile(
              onTap: () {
                deleteExpense(expense.expenseId);
              },
              title: Text(
                'Delete Expense',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.background,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  leaveRoom() async {
    addLeaveMessage(widget.room.groupId!);
    final url = Uri.parse(
        '$groupUrl/leave?groupId=${widget.room.groupId}&userUid=$currentUser');
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
    }
  }

  addLeaveMessage(String roomId) async {
    final url = Uri.parse('${ApiUrl.groupExpenseData}/add');
    try {
      final name = await getName();
      final RoomExpense room = RoomExpense(
          expenseTitle: 'L',
          expenseAmount: 0.00,
          userUid: currentUser,
          groupId: roomId,
          userName: name.toString());
      final response = await http.post(
        url,
        headers: <String, String>{"Content-Type": "application/json"},
        body: json.encode(
          {
            "expenseId": room.expenseId,
            "expenseTitle": room.expenseTitle,
            "expenseAmount": room.expenseAmount,
            "groupId": room.groupId,
            "userUid": room.userUid,
            "userName": room.userName,
          },
        ),
      );
      if (response.statusCode == 200) {
        // do something
      }
    } catch (error) {
      showError('oops something went wrong.');
    }
  }

  Widget _showJoinWelcome(String userName, String date) {
    return Center(
      child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$userName joined the Room',
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 10,
                ),
              )
            ],
          )),
    );
  }

  Widget _showLeaveInfo(String userName, String date) {
    return Center(
      child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$userName left the Room',
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 10,
                ),
              )
            ],
          )),
    );
  }
}

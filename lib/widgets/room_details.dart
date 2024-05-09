// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_buddy_new/model/expense_room.dart';
import 'package:pocket_buddy_new/model/rest_api_url.dart';
import 'package:http/http.dart' as http;
import 'package:pocket_buddy_new/model/room_members_info.dart';

class RoomDetailsWidget extends StatefulWidget {
  const RoomDetailsWidget({super.key, required this.room});

  final ExpenseRoom room;

  @override
  State<StatefulWidget> createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetailsWidget> {
  List<RoomMembersInfo> membersData = [];
  List<String> memberUid = [];
  bool _isFetchingData = true;
  String currentUser = FirebaseAuth.instance.currentUser!.uid;
  final _urlGroupData = ApiUrl.groupExpenseData;
  final _urlGroup = ApiUrl.groupExpense;

  @override
  void initState() {
    super.initState();
    _fetchMemberUid();
    _fetchMembers();
  }

  _fetchMemberUid() async {
    try {
      final url =
          Uri.parse('$_urlGroup/getMembers?groupId=${widget.room.groupId}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        for (String s in responseData) {
          memberUid.add(s);
        }
      }
    } catch (error) {
      showError("Failed to fetch members");
    }
  }

  _fetchMembers() async {
    membersData = [];
    final url = Uri.parse(
        '$_urlGroupData/getMembersData?groupId=${widget.room.groupId}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 400) {
        return;
      }
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        for (final map in responseData) {
          final data = RoomMembersInfo(
              userUid: map['uerUid'],
              userName: map['userName'],
              amount: map['amount']);
          membersData.add(data);
        }
      }
    } catch (error) {
      showError('something went wrong');
    } finally {
      setState(() {
        _isFetchingData = false;
      });
    }
  }

  showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: widget.room.groupId!));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group ID copied'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Text(widget.room.groupId!),
        ),
        actions: [
          PopupMenuButton(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                onTap: null,
                child: Text('Change Group Name'),
              ),
            ],
          )
        ],
      ),
      body: _isFetchingData
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(255, 165, 136, 223)
                        : const Color.fromARGB(255, 30, 14, 61),
                    Theme.of(context).brightness == Brightness.light
                        ? const Color.fromARGB(255, 189, 163, 162)
                        : const Color.fromARGB(255, 36, 3, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.room.groupTitle}',
                      style: GoogleFonts.abel(
                        fontSize: 28,
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Room: ${memberUid.length} Members',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(25),
                        ),
                        color: Theme.of(context).colorScheme.background,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 9,
                            spreadRadius: 1.5,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Add Group Description',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                          Text(
                            'Created by ${widget.room.username}, on ${DateFormat('dd-MM-yyyy').format(widget.room.createdDate!)}',
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onBackground),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(25),
                        ),
                        color: Theme.of(context).colorScheme.background,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 9,
                            spreadRadius: 1.5,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Members',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                          ),
                          const Divider(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: membersData.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      membersData[index].userName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                    ),
                                    Text(
                                      '₹ ${membersData[index].amount > 0.00 ? membersData[index].amount : 0.00}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (widget.room.userUid!.compareTo(currentUser) == 0) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25),
                            ),
                          ),
                        ),
                        onPressed: deleteRoom,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Room'),
                      ),
                    ]
                  ],
                ),
              ),
            ),
    );
  }

  void deleteRoom() async {
    final url = Uri.parse(
        '$_urlGroup/delete?groupId=${widget.room.groupId}&userUid=$currentUser');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Room will be deleted soon, please wait'),
                actions: [
                  TextButton(onPressed: () {}, child: const Text('Okay')),
                ],
              );
            });
      }
    } catch (error) {
      showError('Faild to delete room');
    }
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_buddy_new/model/expense_room.dart';
import 'package:pocket_buddy_new/model/rest_api_url.dart';
import 'package:pocket_buddy_new/model/user_join_group_details.dart';

import 'package:http/http.dart' as http;
import 'package:pocket_buddy_new/screens/group.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  // animation contorller
  // late final AnimationController _controller = AnimationController(
  //   vsync: this,
  //   duration: const Duration(seconds: 2),
  // )..repeat(reverse: true);

  // late final Animation<Offset> _offsetAnimation =
  //     Tween<Offset>(begin: Offset.zero, end: const Offset(1.5, 0.0)).animate(
  //   CurvedAnimation(parent: _controller, curve: Curves.linear),
  // );

  final _url = ApiUrl.groupExpense;
  String? _currentUser;

  bool _isFetching = true;
  bool _isLoading = false;

  List<UserJoinGroupDetails>? _userJoinGroupList;

  final _serchController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!.uid;
    _fetchJoinGroupData();
  }

  _fetchJoinGroupData() async {
    _userJoinGroupList = [];

    final url = Uri.parse('$_url/getUserJoinGroups?userUid=$_currentUser');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> responseDataList = json.decode(response.body);
        for (var responseData in responseDataList) {
          UserJoinGroupDetails joinGroupDetails = UserJoinGroupDetails(
            sno: int.tryParse(responseData['sno'].toString()) ?? 0,
            groupId: responseData['groupId'],
            groupTitle: responseData['groupTitle'],
            userUid: responseData['userUid'],
            joinDate: DateTime.parse(responseData['joinDate']),
          );
          _userJoinGroupList!.add(joinGroupDetails);
        }
      }
    } catch (error) {
      _showError('failed to fetch group');
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Buddy'),
        actions: <Widget>[
          IconButton(onPressed: _showJoinGroup, icon: const Icon(Icons.search)),
          IconButton(onPressed: _showCreateRoom, icon: const Icon(Icons.add)),
        ],
      ),
      body: _isFetching
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            )
          : !_isFetching && _userJoinGroupList!.isEmpty
              ? const Center(
                  child: Text('Your haven\'t join any gorup!'),
                )
              : ListView.builder(
                  itemCount: _userJoinGroupList!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          _openRoomScreen(_userJoinGroupList![index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 24),
                          decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? const Color.fromARGB(177, 151, 135, 134)
                                : const Color.fromARGB(43, 99, 70, 67),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _userJoinGroupList![index].groupTitle,
                                style: GoogleFonts.abhayaLibre(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  _openRoomScreen(UserJoinGroupDetails roomDetails) async {
    ExpenseRoom response = await _getRoomDetails(roomDetails.groupId);
    if (response.groupId!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RoomScreen(
            room: response,
          ),
        ),
      );
    }
  }

  _showJoinGroup() {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          children: <Widget>[
            TextField(
              controller: _serchController,
              decoration: const InputDecoration(
                labelText: 'enter group id',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                foregroundColor: Theme.of(context).colorScheme.background,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: _joinGroup,
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  Future<ExpenseRoom> _getRoomDetails(String groupId) async {
    final findUrl = Uri.parse('$_url/get?groupId=$groupId');
    final response = await http.get(findUrl);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      final room = ExpenseRoom(
        groupId: responseData['groupId'],
        groupTitle: responseData['groupTitle'],
        createdDate: DateTime.parse(responseData['createdDate']),
        userUid: responseData['userUid'],
        username: responseData['creatorName'],
        roomDescription: '',
      );

      return room;
    }
    return ExpenseRoom(
        groupId: '',
        groupTitle: '',
        createdDate: DateTime.now(),
        userUid: '',
        username: '',
        roomDescription: '');
  }

  _joinGroup() async {
    String groupId = _serchController.text;
    if (groupId.isNotEmpty) {
      try {
        ExpenseRoom response = await _getRoomDetails(groupId);
        if (response.groupId!.isNotEmpty) {
          // join the room
          final url =
              Uri.parse('$_url/join?groupId=$groupId&userUid=$_currentUser');
          final joinResponse = await http.get(url);
          if (joinResponse.statusCode == 200) {
            _fetchJoinGroupData();
          }
        } else {
          _showError('No room found');
        }
      } catch (error) {
        _showError('failed to join room');
      } finally {
        Navigator.of(context).pop();
      }
    }
  }

  _showCreateRoom() {
    showBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 250,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            color: Color.fromARGB(100, 207, 188, 100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.background,
                ),
                controller: _titleController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.title),
                  labelText: 'enter group title',
                  fillColor:
                      const Color.fromARGB(255, 155, 149, 149).withOpacity(0.6),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: const Color.fromARGB(255, 34, 133, 179),
                ),
                onPressed: _createRoom,
                child: !_isLoading
                    ? Text(
                        'Create Room',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.white),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              )
            ],
          ),
        );
      },
    );
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
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get();

          name = data['firstname'] + " " + data['lastname'];
        }
      }
      return name;
    } catch (e) {
      _showError('something went wrong');
    }
  }

  _createRoom() async {
    String groupTitle = _titleController.text;
    if (groupTitle.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = !_isLoading;
    });

    final createUrl = Uri.parse('$_url/create');

    try {
      String name = await getName();
      print(name);
      final response = await http.post(
        createUrl,
        headers: <String, String>{"Content-Type": "application/json"},
        body: json.encode(
          {
            "userUid": _currentUser,
            "groupTitle": groupTitle,
            "creatorName": name.toString(),
          },
        ),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print(responseData);

        final room = ExpenseRoom(
          groupId: responseData['groupDetails']['groupId'],
          groupTitle: responseData['groupDetails']['groupTitle'],
          createdDate:
              DateTime.parse(responseData['groupDetails']['createdDate']),
          userUid: responseData['groupDetails']['userUid'],
          username: responseData['groupDetails']['creatorName'],
          roomDescription: '',
        );

        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RoomScreen(
              room: room,
            ),
          ),
        );
        _fetchJoinGroupData();
      }
    } catch (error) {
      print("Error Creating: $error");
      _showError('failed to create room');
    } finally {
      _titleController.clear();
    }
  }

  _showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        action: SnackBarAction(
          label: 'Okay',
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      ),
    );
  }
}

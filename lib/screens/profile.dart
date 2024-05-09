// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_buddy_new/model/rest_api_url.dart';
import 'package:pocket_buddy_new/model/user_join_group_details.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = "";
  bool isLoading = true;

  List<UserJoinGroupDetails> _userJoinGroupList = [];
  final _url = ApiUrl.groupExpense;

  @override
  void initState() {
    super.initState();
    getData();
    _fetchJoinGroupData();
  }

  _fetchJoinGroupData() async {
    _userJoinGroupList = [];

    final url =
        Uri.parse('$_url/getUserJoinGroups?userUid=${_auth.currentUser!.uid}');
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
          _userJoinGroupList.add(joinGroupDetails);
        }
      }
    } catch (error) {
      print(error);
      showError('failed to fetch group');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  getData() async {
    try {
      String? fetchName;
      User? user = _auth.currentUser;
      if (user != null) {
        fetchName = user.displayName;
        final data = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (fetchName == null || fetchName.isEmpty) {
          fetchName = data['firstname'] + " " + data['lastname'];
        }
        setState(() {
          name = fetchName!;
        });
      }
    } catch (e) {
      showError('Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? const Color.fromARGB(255, 0, 255, 135)
                  : const Color.fromARGB(255, 69, 24, 84),
              Theme.of(context).brightness == Brightness.light
                  ? const Color.fromARGB(255, 96, 239, 255)
                  : const Color.fromARGB(255, 172, 24, 91),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color.fromARGB(255, 79, 93, 216)
                                    : const Color.fromARGB(255, 177, 144, 186),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(
                                Icons.person_pin,
                                size: 100,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.zillaSlab(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _auth.currentUser!.email ?? '',
                                    style: GoogleFonts.abel(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.lock),
                          label: const Text('Change Password'),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 79, 93, 216)
                                  : const Color.fromARGB(255, 177, 144, 186),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(25),
                              ),
                            ),
                            child: _userJoinGroupList.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Joined Room',
                                        style: GoogleFonts.akayaTelivigala(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _userJoinGroupList
                                            .length, // Provide itemCount
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(
                                              _userJoinGroupList[index]
                                                  .groupTitle,
                                              style: GoogleFonts.acme(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  )
                                : const Center(
                                    child: Text(
                                        'You have\'n join any expense room'),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Divider(),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _showDeleteAccount,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete Account'),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }

  _showDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          contentPadding: const EdgeInsets.all(18),
          titlePadding: const EdgeInsets.all(16),
          title: const Text('Warning'),
          actions: [
            const Text('Are you sure you want to delete your account.'),
            const SizedBox(height: 8),
            const Text(
                'If you delete your account your data will not be recovered.'),
            IconButton(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete),
            )
          ],
        );
      },
    );
  }

  _deleteAccount() async {
    try {
      final data = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (data.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .delete();
      }

      await _auth.currentUser!.delete();
      _auth.signOut();
    } catch (e) {
      showError('Failed to delete account');
    }
  }

  void showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}

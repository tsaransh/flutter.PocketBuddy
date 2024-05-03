import 'package:flutter/material.dart';
import 'package:pocket_buddy_new/model/expense_room.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.room});

  final ExpenseRoom room;
  @override
  State<RoomScreen> createState() => _GroupHomeScreenState();
}

class _GroupHomeScreenState extends State<RoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.room.groupTitle}')),
    );
  }
}

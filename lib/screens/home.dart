import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pocket_buddy_new/widgets/personal_expense_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _PersonalHomeScreenState();
}

class _PersonalHomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Buddy'),
        actions: <Widget>[
          TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.background,
              )),
          if (_selectedNavIndex + 1 == 2)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search),
                SizedBox(width: 36),
                Icon(Icons.add),
                SizedBox(width: 24),
              ],
            )
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: GNav(
            gap: 8,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            color: Theme.of(context).colorScheme.onBackground,
            activeColor: Theme.of(context).colorScheme.onBackground,
            tabBackgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            padding: const EdgeInsets.all(12),
            onTabChange: (index) {
              setState(() {
                _selectedNavIndex = index;
              });
            },
            tabs: const [
              GButton(
                icon: Icons.person,
                text: 'Personal',
              ),
              GButton(
                icon: Icons.people,
                text: 'Group',
              ),
              GButton(
                icon: Icons.settings,
                text: 'Setting',
              ),
              GButton(
                icon: Icons.create,
                text: 'About',
              ),
            ],
          ),
        ),
      ),
      body: _buildPage(),
    );
  }

  _buildPage() {
    if ((_selectedNavIndex + 1) == 1) {
      return const PersonalExpenseScreen();
    } else if ((_selectedNavIndex + 1) == 2) {
      // return _buildGroupExpense();
    } else if ((_selectedNavIndex + 1) == 3) {
      // return _buildSettings();
    } else if ((_selectedNavIndex + 1) == 4) {
      // return _buildAbout();
    } else {
      return;
    }
  }
}
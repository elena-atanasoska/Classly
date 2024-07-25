import 'package:classly/presentation/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/CustomUser.dart';
import '../../application/services/UserService.dart';

class UserManagementScreen extends StatefulWidget {
  final List<CustomUser> users;
  final UserService userService;

  UserManagementScreen({required this.users, required this.userService});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<CustomUser> filteredUsers = [];
  String searchQuery = '';
  String filterRole = 'All';

  @override
  void initState() {
    super.initState();
    filteredUsers = widget.users;
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = widget.users.where((user) {
        bool matchesSearch = user.getFullName()?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
        bool matchesRole = filterRole == 'All' || user.role.name == filterRole.toUpperCase();
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchQuery = value;
                _filterUsers();
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0), // Make search field rounder
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // Round the border on focus
                  borderSide: BorderSide.none, // Remove border side for rounded corners
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <String>['All', 'Student', 'Professor'].map((role) {
                bool isSelected = filterRole == role;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // Round buttons
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      filterRole = role;
                      _filterUsers();
                    });
                  },
                  child: Text(
                    role,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                CustomUser user = filteredUsers[index];
                return ListTile(
                  title: Text(
                    user.getFullName() ?? 'No name available',
                    style: GoogleFonts.poppins(),
                  ),
                  subtitle: Text(
                    "${user.email}, ${user.role.name}" ?? 'No email available',
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(user: user, userService: widget.userService),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

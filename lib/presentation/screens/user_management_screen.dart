import 'package:classly/presentation/screens/user_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/CustomUser.dart';
import '../../application/services/UserService.dart';

class UserManagementScreen extends StatefulWidget {
  final UserService userService;

  const UserManagementScreen({super.key, required this.userService});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<CustomUser> _users = [];
  List<CustomUser> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchUsers() async {
    try {
      List<CustomUser> users = await widget.userService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return (user.getFullName()?.toLowerCase().contains(query) ?? false) ||
            (user.email.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                CustomUser user = _filteredUsers[index];
                return ListTile(
                  title: Text(user.getFullName() ?? 'No name available', style: GoogleFonts.poppins()),
                  subtitle: Text("${user.email}, ${user.role.name}", style: GoogleFonts.poppins()),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(user: user, userService: widget.userService),
                      ),
                    );
                    if (result == true) {
                      _fetchUsers();
                    }
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

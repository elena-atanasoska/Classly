import 'package:flutter/material.dart';

import '../../application/services/RoomService.dart';
import '../../domain/models/Room.dart';

class RoomManagementScreen extends StatefulWidget {
  final RoomService roomService;

  const RoomManagementScreen({Key? key, required this.roomService}) : super(key: key);

  @override
  _RoomManagementScreenState createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<Room> _rooms = [];
  List<Room> _filteredRooms = [];
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _rowsController = TextEditingController();
  final TextEditingController _columnsController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
    _searchController.addListener(_filterRooms);
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _rowsController.dispose();
    _columnsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchRooms() async {
    try {
      List<Room> rooms = await widget.roomService.getAvailableRooms();
      setState(() {
        _rooms = rooms;
        _filteredRooms = rooms;
      });
    } catch (error) {
      print('Error fetching rooms: $error');
    }
  }

  void _filterRooms() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRooms = _rooms.where((room) {
        return room.name.toLowerCase().contains(query) ||
            room.building.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Room', style: TextStyle(color: Color(0xFF0D47A1))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Room ID'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _buildingController,
                decoration: const InputDecoration(labelText: 'Building'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _floorController,
                decoration: const InputDecoration(labelText: 'Floor'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rowsController,
                decoration: const InputDecoration(labelText: 'Rows'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _columnsController,
                decoration: const InputDecoration(labelText: 'Columns'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                try {
                  String id = _idController.text;
                  String name = _nameController.text;
                  String building = _buildingController.text;
                  String floor = _floorController.text;
                  int rows = int.tryParse(_rowsController.text) ?? 0;
                  int columns = int.tryParse(_columnsController.text) ?? 0;

                  Room room = Room(
                    id: id,
                    name: name,
                    building: building,
                    floor: floor,
                    rows: rows,
                    columns: columns,
                  );
                  await widget.roomService.addRoom(room);
                  _idController.clear();
                  _nameController.clear();
                  _buildingController.clear();
                  _floorController.clear();
                  _rowsController.clear();
                  _columnsController.clear();
                  Navigator.of(context).pop();
                  _fetchRooms();
                } catch (error) {
                  print('Error adding room: $error');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Management'),
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
          ElevatedButton(
            onPressed: _showAddRoomDialog,
            child: const Text('Add New Room', style: TextStyle(color: Color(0xFF0D47A1))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRooms.length,
              itemBuilder: (context, index) {
                Room room = _filteredRooms[index];
                return ListTile(
                  title: Text(room.name),
                  subtitle: Text('${room.building}, Floor: ${room.floor}'),
                  onTap: () {
                    // Navigate to RoomDetailsScreen or handle tap
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

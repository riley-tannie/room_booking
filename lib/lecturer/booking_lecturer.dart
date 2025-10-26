import 'package:flutter/material.dart';
import 'room_detail_lecturer.dart';

// ===== Shared singleton store for lecturer actions (state lives here) =====

// 1. PUBLIC Data Model Class
class PendingRequest {
  final String id;
  final String roomName;
  final String slot; // "8-10", "10-12", "13-15", "15-17"
  final String studentName;
  final DateTime date;
  PendingRequest(this.id, this.roomName, this.slot, this.studentName, this.date);
}

// 2. PUBLIC Singleton Store Class (Fixed the error from other files)
class LecturerStore {
  // Singleton setup
  static final LecturerStore instance = LecturerStore._();
  LecturerStore._();

  // Helper methods
  static String _two(int n) => n.toString().padLeft(2, '0');
  static String fmt(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final requestDay = DateTime(d.year, d.month, d.day);

    if (requestDay.isAtSameMomentAs(today)) {
      return 'Today';
    }
    final tomorrow = today.add(const Duration(days: 1));
    if (requestDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    }
    return '${_two(d.day)}/${_two(d.month)}/${d.year}';
  }

  // Data storage
  final List<PendingRequest> pending = [
    PendingRequest('b1', 'A101', '8-10', 'Alice', DateTime.now().add(const Duration(days: 1))), // Tomorrow example
    PendingRequest('b2', 'B202', '10-12', 'Bob', DateTime.now()), // Today example
  ];
  final List<Map<String, String>> history = [];

  // Actions
  void approve(String id, {required String approverId}) {
    final idx = pending.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final req = pending.removeAt(idx);
    history.insert(0, {
      'room': req.roomName,
      'status': 'Approved',
      'date': fmt(req.date),
      'slot': req.slot,
      'student': req.studentName,
      'approver': approverId,
    });
  }

  void disapprove(String id, {required String approverId}) {
    final idx = pending.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final req = pending.removeAt(idx);
    history.insert(0, {
      'room': req.roomName,
      'status': 'Rejected',
      'date': fmt(req.date),
      'slot': req.slot,
      'student': req.studentName,
      'approver': approverId,
    });
  }
}
// ===== End shared store =====

class BookingLecturer extends StatefulWidget {
  @override
  State<BookingLecturer> createState() => _BookingLecturerState();
}

class _BookingLecturerState extends State<BookingLecturer> {
  // Use the public store
  final store = LecturerStore.instance;
  final String lecturerId = 'lect001'; 

  void _handleProcess(PendingRequest req, String status) {
    setState(() {
      if (status == 'Approved') {
        store.approve(req.id, approverId: lecturerId);
      } else {
        store.disapprove(req.id, approverId: lecturerId);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request for ${req.roomName} ${status.toLowerCase()}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Requests')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: store.pending.isEmpty
            ? const Center(child: Text('No pending requests for today'))
            : ListView.builder(
                itemCount: store.pending.length,
                itemBuilder: (context, index) {
                  final req = store.pending[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text('Room ${req.roomName} • ${req.slot}'),
                      subtitle: Text('Student: ${req.studentName} • Date: ${LecturerStore.fmt(req.date)}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RoomDetailLecturer(roomName: req.roomName)),
                        );
                      },
                      trailing: _ActionButtons(
                        request: req,
                        onApprove: () => _handleProcess(req, 'Approved'),
                        onDisapprove: () => _handleProcess(req, 'Rejected'),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// 3. Extracted Widget with dual Elevated Buttons (Approve Left, Reject Right)
class _ActionButtons extends StatelessWidget {
  final PendingRequest request;
  final VoidCallback onApprove;
  final VoidCallback onDisapprove;

  const _ActionButtons({
    required this.request,
    required this.onApprove,
    required this.onDisapprove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170, // Fixed width to ensure consistent spacing
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 1. APPROVE Button (Left)
          Expanded(
            child: ElevatedButton(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Primary action color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: const Text('Approve', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),

          // 2. REJECT Button (Right)
          Expanded(
            child: ElevatedButton(
              onPressed: onDisapprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Secondary action color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              child: const Text('Reject', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
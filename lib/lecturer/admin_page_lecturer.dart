import 'package:flutter/material.dart';
import 'data_store.dart';

class AdminPageLecturer extends StatefulWidget {
  const AdminPageLecturer({super.key});

  @override
  State<AdminPageLecturer> createState() => _AdminPageLecturerState();
}

class _AdminPageLecturerState extends State<AdminPageLecturer> {
  @override
  Widget build(BuildContext context) {
    final pending = DataStore.pendingRequests;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pending.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No pending requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'All requests have been processed',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ...pending.map((request) => _buildRequestCard(context, request)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Request request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.roomName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.studentName} • ${request.date} • ${request.timeSlot}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF26A65B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: () => _handleDecision(request, true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF6666),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => _handleDecision(request, false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleDecision(Request request, bool approved) {
    setState(() {
      DataStore.addHistoryEntry(request, approved);
      DataStore.pendingRequests.removeWhere((r) => r.requestId == request.requestId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request ${approved ? "approved" : "disapproved"}: ${request.studentName}'),
        backgroundColor: const Color(0xFF2C5473),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class RequestStatus extends StatelessWidget {
  const RequestStatus({super.key});

  static const Color successColor = Color(0xFF10B981); 
  static const Color infoColor = Color(0xFF3B82F6); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),

              _buildRequestCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1593642532400-2682810df593',
                roomName: 'Lanchester Study Room',
                statusText: 'Reserved',
                statusColor: successColor,
                approvalText: 'Reservation Approved',
                approvalBgColor: Color(0xFFC8FACC),
              ),

              const SizedBox(height: 16),
              _buildRequestCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1593642532400-2682810df593',
                roomName: 'Lanchester Study Room',
                statusText: 'Available',
                statusColor: infoColor,
                approvalText: 'Reservation Rejected',
                approvalBgColor: Color(0xFFFBCACA),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard({
    required String imageUrl,
    required String roomName,
    required String statusText,
    required Color statusColor,
    required String approvalText,
    required Color approvalBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on,
                              color: Colors.black54, size: 16),
                          const Text(
                            'Library',
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          const Spacer(),
                          const Text(
                            'See details',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: approvalBgColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Text(
              approvalText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

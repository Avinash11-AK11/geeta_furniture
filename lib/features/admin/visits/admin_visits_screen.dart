import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AdminVisitsScreen extends StatelessWidget {
  const AdminVisitsScreen({super.key});

  // 🔹 Dummy visit data (Firestore later)
  List<Map<String, dynamic>> get _visits => const [
    {
      'name': 'Ramesh Patel',
      'address': 'Ahmedabad',
      'date': '14 Jan 2026',
      'status': 'Pending',
    },
    {
      'name': 'Amit Shah',
      'address': 'Surat',
      'date': '13 Jan 2026',
      'status': 'Completed',
    },
    {
      'name': 'Kunal Mehta',
      'address': 'Vadodara',
      'date': '12 Jan 2026',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ TITLE
            const Text(
              'Visits',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // 📋 VISITS LIST
            Expanded(
              child: ListView.separated(
                itemCount: _visits.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final visit = _visits[index];
                  return _visitCard(visit);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visitCard(Map<String, dynamic> visit) {
    final bool isCompleted = visit['status'] == 'Completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 NAME + STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                visit['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              _statusChip(isCompleted),
            ],
          ),

          const SizedBox(height: 8),

          // 📍 ADDRESS
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                visit['address'],
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // 📅 DATE
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                visit['date'],
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        completed ? 'Completed' : 'Pending',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: completed ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InspirationCard extends StatelessWidget {
  final String quote;
  final VoidCallback onDelete;
  
  const InspirationCard({
    super.key,
    required this.quote,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                quote,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.start,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, size: 20),
            )
          ],
        ),
      ),
    );
  }
}
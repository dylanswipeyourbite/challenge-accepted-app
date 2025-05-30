// lib/widgets/cards/stat_card.dart

import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final bool isLoading;
  final bool isSpecial;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.isLoading = false,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: isSpecial ? _specialGradient : null,
          color: isSpecial ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildValue(),
            const SizedBox(height: 4),
            _buildLabel(),
            if (subtitle != null) _buildSubtitle(),
          ],
        ),
      ),
    );
  }

  LinearGradient get _specialGradient => LinearGradient(
    colors: [Colors.purple.shade300, Colors.blue.shade300],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Widget _buildValue() {
    if (isLoading) {
      return const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isSpecial ? Colors.white : Colors.black,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildLabel() {
    return Text(
      label,
      style: TextStyle(
        color: isSpecial ? Colors.white.withOpacity(0.9) : Colors.grey,
        fontSize: 11,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        subtitle!,
        style: TextStyle(
          color: isSpecial ? Colors.white.withOpacity(0.8) : Colors.green,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
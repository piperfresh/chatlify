import 'package:chatlify/core/extension/size_extension.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            24.sbH,
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            12.sbH,
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

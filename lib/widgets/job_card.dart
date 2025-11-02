import 'package:flutter/material.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String description;
  final String? extraInfo;
  final VoidCallback? onTap;
  final double padding;

  const JobCard({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    this.padding = 16,
    this.extraInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (extraInfo != null) ...[
              const SizedBox(height: 8),
              Text(extraInfo!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
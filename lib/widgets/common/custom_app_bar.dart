import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundColor != null 
            ? null 
            : AppTheme.backgroundGradient,
        color: backgroundColor,
      ),
      child: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        leading: leading,
        actions: actions,
        iconTheme: const IconThemeData(
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


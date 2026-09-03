import 'package:flutter/material.dart';

/// Premium floating inset header bar for ShishuCare pages
class SleekAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const SleekAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && canPop) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
        tooltip: 'Back',
        splashRadius: 20,
        onPressed: () => Navigator.maybePop(context),
      );
    }

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3A0B75), // Deep regal purple
                Color(0xFF6A1B9A), // Rich amethyst violet
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3A0B75).withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: NavigationToolbar(
            leading: leadingWidget != null
                ? SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(child: leadingWidget),
                  )
                : const SizedBox(width: 16),
            middle: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            trailing: actions != null && actions!.isNotEmpty
                ? IconTheme(
                    data: const IconThemeData(color: Colors.white),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!,
                    ),
                  )
                : const SizedBox(width: 16),
            centerMiddle: centerTitle,
          ),
        ),
      ),
    );
  }
}

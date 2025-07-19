// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../providers/user_provider.dart';
// import '../../config/theme.dart';

// class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final List<Widget>? actions;
//   final bool showProfileAction;
//   final VoidCallback? onProfileTap;
//   final Widget? leading;
//   final double elevation;
//   final Color? backgroundColor;
//   final bool centerTitle;

//   const CustomAppBar({
//     Key? key,
//     required this.title,
//     this.actions,
//     this.showProfileAction = false,
//     this.onProfileTap,
//     this.leading,
//     this.elevation = 0,
//     this.backgroundColor,
//     this.centerTitle = true,
//   }) : super(key: key);

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> finalActions = [];

//     // Add provided actions
//     if (actions != null) {
//       finalActions.addAll(actions!);
//     }

//     // Add profile action if requested
//     if (showProfileAction) {
//       finalActions.add(
//         Consumer<UserProvider>(
//           builder: (context, userProvider, _) {
//             final user = userProvider.user;

//             return GestureDetector(
//               onTap: onProfileTap,
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: CircleAvatar(
//                   radius: 16,
//                   backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
//                   backgroundImage: user?.photoUrl != null
//                       ? NetworkImage(user!.photoUrl!)
//                       : null,
//                   child: user?.photoUrl == null
//                       ? Text(
//                           user?.displayName != null &&
//                                   user!.displayName!.isNotEmpty
//                               ? user.displayName![0].toUpperCase()
//                               : user?.email != null && user!.email.isNotEmpty
//                                   ? user.email[0].toUpperCase()
//                                   : 'U',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primaryGreen,
//                           ),
//                         )
//                       : null,
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     }

//     return AppBar(
//       title: Text(title),
//       leading: leading,
//       actions: finalActions,
//       elevation: elevation,
//       backgroundColor: backgroundColor ?? AppColors.primaryGreen,
//       foregroundColor: Colors.white,
//       centerTitle: centerTitle,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wattwise/providers/user_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showProfileAction;
  final VoidCallback? onProfileTap;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showProfileAction = false,
    this.onProfileTap,
    this.leading,
    this.elevation = 0,
    this.backgroundColor,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      elevation: elevation,
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      actions: [
        if (actions != null) ...actions!,
        if (showProfileAction) _buildProfileAction(context, colorScheme),
      ],
    );
  }

  Widget _buildProfileAction(BuildContext context, ColorScheme colorScheme) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final initials = _getUserInitial(user?.firstName, user?.email);

        return GestureDetector(
          onTap: onProfileTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor:
                  colorScheme.onPrimary.withAlpha((0.2 * 255).round()),
              backgroundImage:
                  user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? Text(
                      initials,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }

  String _getUserInitial(String? displayName, String? email) {
    if (displayName != null && displayName.isNotEmpty) {
      return displayName[0].toUpperCase();
    }
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }
}

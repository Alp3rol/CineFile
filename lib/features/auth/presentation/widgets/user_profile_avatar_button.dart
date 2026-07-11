import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../user_profile_screen.dart';

class UserProfileAvatarButton extends ConsumerWidget {
  final double size;

  const UserProfileAvatarButton({
    super.key,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(userModelProvider);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UserProfileScreen(),
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10, width: 1),
          image: userModel?.avatarUrl != null
              ? DecorationImage(
                  image: NetworkImage(userModel!.avatarUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: userModel?.avatarUrl == null
            ? Icon(
                Icons.person_rounded,
                color: Colors.white70,
                size: size * 0.6,
              )
            : null,
      ),
    );
  }
}

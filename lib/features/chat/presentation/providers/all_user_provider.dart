import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:chatlify/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allUsersProvider = FutureProvider(
  (ref) async {
    final allUsers =
        await ref.read(authControllerProvider.notifier).getAllUsers();
    return allUsers.whereType<UserModel>().toList();
  },
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filterUserProvider = Provider<AsyncValue<List<UserModel>>>(
  (ref) {
    final userAsync = ref.watch(allUsersProvider);
    final query = ref.watch(searchQueryProvider);

    return userAsync.when(
      data: (data) {
        if (query.isEmpty) {
          return AsyncValue.data(data);
        } else {
          final filtered = data
              .where((user) =>
                  user.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
          return AsyncValue.data(filtered);
        }
      },
      error: (error, stackTrace) {
        return AsyncValue.error(error, stackTrace);
      },
      loading: () {
        return const AsyncValue.loading();
      },
    );
  },
);

// Provider for tracking loading state during chat creation
final isCreatingChatProvider = StateProvider<bool>((ref) => false);

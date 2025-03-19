import 'package:chatlify/features/auth/data/repository/firebase_auth_repository.dart';
import 'package:chatlify/features/auth/domain/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// This is to get all the user
final allUsersProvider = FutureProvider(
  (ref) async {
    final repository = ref.read(firebaseAuthRepositoryProvider);

    try {
      final allUsers = await repository.getAllUser();
      return allUsers.whereType<UserModel>().toList();
    } catch (e) {
      throw Exception('Failed to load user ${e.toString()}');
    }
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

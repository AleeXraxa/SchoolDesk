import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/user_service.dart';
import '../../../data/models/user_model.dart';
import '../../../widgets/result_dialog.dart';

class UsersController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<UserModel> allUsers = <UserModel>[].obs;
  RxList<UserModel> filteredUsers = <UserModel>[].obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      print('UsersController: Fetching users from database');

      final result = await UserService.getAllUsers();
      allUsers.assignAll(result);
      filteredUsers.assignAll(result);

      print('UsersController: Loaded ${result.length} users');
    } catch (e, stackTrace) {
      print('UsersController: Error fetching users: $e');
      print('UsersController: Stack trace: $stackTrace');

      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Load Users',
        message: 'Failed to load users from database. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUsers() async {
    await fetchUsers();
  }

  Future<void> refreshUsers() async {
    await loadUsers();
  }

  Future<void> addUser(String username, String password, String role) async {
    try {
      print('UsersController: Adding new user: $username');

      // Check if username already exists
      final exists = await UserService.checkUsernameExists(username);
      if (exists) {
        ResultDialog.showError(
          Get.context!,
          title: 'Username Exists',
          message: 'A user with this username already exists.',
        );
        return;
      }

      final newUser = UserModel(
        username: username,
        passwordHash: password, // Will be hashed in service
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await UserService.addUser(newUser);
      await loadUsers();

      ResultDialog.showSuccess(
        Get.context!,
        title: 'User Added',
        message: 'User has been added successfully.',
      );

      print('UsersController: User added successfully');
    } catch (e, stackTrace) {
      print('UsersController: Error adding user: $e');
      print('UsersController: Stack trace: $stackTrace');

      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Add User',
        message: 'Failed to add user. Please try again.',
      );
    }
  }

  Future<void> updateUser(
    int id,
    String username,
    String? password,
    String role,
  ) async {
    try {
      print('UsersController: Updating user ID: $id');

      // Check if username already exists (excluding current user)
      final exists = await UserService.checkUsernameExists(
        username,
        excludeId: id,
      );
      if (exists) {
        ResultDialog.showError(
          Get.context!,
          title: 'Username Exists',
          message: 'A user with this username already exists.',
        );
        return;
      }

      final existingUser = await UserService.getUserById(id);
      if (existingUser == null) {
        ResultDialog.showError(
          Get.context!,
          title: 'User Not Found',
          message: 'The user to update was not found.',
        );
        return;
      }

      final updatedUser = existingUser.copyWith(
        username: username,
        passwordHash:
            password ??
            existingUser.passwordHash, // Keep existing if not changed
        role: role,
        updatedAt: DateTime.now(),
      );

      await UserService.updateUser(updatedUser);
      await loadUsers();

      ResultDialog.showSuccess(
        Get.context!,
        title: 'User Updated',
        message: 'User has been updated successfully.',
      );

      print('UsersController: User updated successfully');
    } catch (e, stackTrace) {
      print('UsersController: Error updating user: $e');
      print('UsersController: Stack trace: $stackTrace');

      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Update User',
        message: 'Failed to update user. Please try again.',
      );
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      print('UsersController: Deleting user with ID: $id');

      // Show confirmation dialog
      final confirmed = await _showDeleteConfirmationDialog(id);
      if (!confirmed) return;

      // Delete from database
      await UserService.deleteUser(id);

      // Refresh the users list
      await loadUsers();

      // Show success dialog
      ResultDialog.showSuccess(
        Get.context!,
        title: 'User Deleted Successfully',
        message: 'The user has been removed from the system.',
      );

      print('UsersController: User deleted successfully');
    } catch (e, stackTrace) {
      print('UsersController: Error deleting user: $e');
      print('UsersController: Stack trace: $stackTrace');

      // Show error dialog
      ResultDialog.showError(
        Get.context!,
        title: 'Failed to Delete User',
        message: 'Failed to delete user. Please try again later.',
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog(int userId) async {
    final result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Confirm Deletion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Message
              const Text(
                'Are you sure you want to delete this user?\n\nThis action cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Delete button
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );

    return result ?? false;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    if (searchQuery.value.isEmpty) {
      filteredUsers.value = List.from(allUsers);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredUsers.value = allUsers.where((user) {
        return user.username.toLowerCase().contains(query) ||
            user.role.toLowerCase().contains(query);
      }).toList();
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    filteredUsers.value = List.from(allUsers);
  }
}

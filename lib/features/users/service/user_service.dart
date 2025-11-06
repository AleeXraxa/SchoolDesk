import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../data/database_service.dart';
import '../../../data/models/user_model.dart';

class UserService {
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static Future<int> addUser(UserModel userModel) async {
    try {
      print('UserService: Adding user: ${userModel.username}');
      final db = await DatabaseService.database;

      // Hash the password before storing
      final passwordHash = _hashPassword(userModel.passwordHash);

      final userWithHash = userModel.copyWith(passwordHash: passwordHash);

      final id = await db.insert('users', userWithHash.toJson());
      print('UserService: Successfully added user with ID: $id');
      return id;
    } catch (e, stackTrace) {
      print('UserService: Error adding user: $e');
      print('UserService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    try {
      print('UserService: Fetching all users from database');
      final db = await DatabaseService.database;
      final result = await db.query('users');
      print('UserService: Query returned ${result.length} rows');
      final users = result.map((json) => UserModel.fromJson(json)).toList();
      print('UserService: Successfully parsed ${users.length} users');
      return users;
    } catch (e, stackTrace) {
      print('UserService: Error fetching users: $e');
      print('UserService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<UserModel?> getUserById(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) {
        return UserModel.fromJson(result.first);
      }
      return null;
    } catch (e, stackTrace) {
      print('UserService: Error fetching user by ID: $e');
      print('UserService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> updateUser(UserModel userModel) async {
    try {
      if (userModel.id == null) return false;
      final db = await DatabaseService.database;

      // If password is being updated, hash it
      String passwordHash = userModel.passwordHash;
      if (!passwordHash.startsWith('\$') && passwordHash.length < 64) {
        // Assuming hashed passwords are longer, if not hashed, hash it
        passwordHash = _hashPassword(userModel.passwordHash);
      }

      final userWithHash = userModel.copyWith(passwordHash: passwordHash);

      final result = await db.update(
        'users',
        userWithHash.toJson(),
        where: 'id = ?',
        whereArgs: [userModel.id],
      );
      return result > 0;
    } catch (e, stackTrace) {
      print('UserService: Error updating user: $e');
      print('UserService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> deleteUser(int id) async {
    try {
      final db = await DatabaseService.database;
      final result = await db.delete('users', where: 'id = ?', whereArgs: [id]);
      return result > 0;
    } catch (e, stackTrace) {
      print('UserService: Error deleting user: $e');
      print('UserService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<bool> checkUsernameExists(
    String username, {
    int? excludeId,
  }) async {
    try {
      final db = await DatabaseService.database;
      var whereClause = 'username = ?';
      var whereArgs = [username];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId.toString());
      }

      final result = await db.query(
        'users',
        where: whereClause,
        whereArgs: whereArgs,
      );
      return result.isNotEmpty;
    } catch (e, stackTrace) {
      print('UserService: Error checking username exists: $e');
      print('UserService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}

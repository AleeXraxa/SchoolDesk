import '../../../data/database_service.dart';
import '../../../data/models/user_model.dart';
import '../model/login_model.dart';

class AuthService {
  Future<bool> login(LoginModel loginModel) async {
    try {
      // Authenticate user against database
      final isAuthenticated = await DatabaseService.authenticateUser(
        loginModel.username,
        loginModel.password,
      );

      return isAuthenticated;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  Future<UserModel?> getCurrentUser(String username) async {
    try {
      final userData = await DatabaseService.getUserByUsername(username);
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
}

import 'package:get/get.dart';
import '../../../core/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../widgets/loading_dialog.dart';
import '../../../widgets/result_dialog.dart';
import '../model/login_model.dart';
import '../service/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var username = ''.obs;
  var password = ''.obs;
  var isPasswordVisible = false.obs;

  // Validation error messages
  var usernameError = ''.obs;
  var passwordError = ''.obs;

  // Current user data
  var currentUser = Rx<UserModel?>(null);

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void validateUsername(String value) {
    username.value = value;
    if (value.isEmpty) {
      usernameError.value = 'Username is required';
    } else if (value.length < 3) {
      usernameError.value = 'Username must be at least 3 characters';
    } else {
      usernameError.value = '';
    }
  }

  void validatePassword(String value) {
    password.value = value;
    if (value.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (value.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
    } else {
      passwordError.value = '';
    }
  }

  bool get isFormValid {
    return usernameError.isEmpty &&
        passwordError.isEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty;
  }

  void login() async {
    // Clear previous errors
    usernameError.value = '';
    passwordError.value = '';

    // Validate fields
    validateUsername(username.value);
    validatePassword(password.value);

    if (!isFormValid) {
      return;
    }

    // Prevent multiple simultaneous login attempts
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;

    // Show loading dialog
    final context = Get.context;
    if (context != null) {
      LoadingDialog.show(context, message: 'Authenticating...');
    }

    try {
      final loginModel = LoginModel(
        username: username.value,
        password: password.value,
      );

      // Simulate minimum loading time for better UX
      final authFuture = _authService.login(loginModel);
      final timeoutFuture = Future.delayed(const Duration(seconds: 3));

      final result = await Future.any([
        authFuture,
        timeoutFuture.then((_) => false), // Return false if timeout
      ]);

      final isAuthenticated = result as bool;

      // Hide loading dialog
      if (context != null) {
        LoadingDialog.hide(context);
      }

      if (isAuthenticated) {
        // Get user data
        final user = await _authService.getCurrentUser(username.value);
        currentUser.value = user;

        print('Login successful for user: ${user?.username} (${user?.role})');

        // Show success dialog
        if (context != null) {
          ResultDialog.showSuccess(
            context,
            title: 'Welcome Back! 👋',
            message: 'Login successful! Welcome ${user?.username}',
          );
        }

        // Navigate to dashboard after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed(AppRoutes.dashboard, arguments: user);
        });
      } else {
        // Show error dialog
        if (context != null) {
          ResultDialog.showError(
            context,
            title: 'Login Failed',
            message: 'Invalid username or password. Please try again.',
          );
        }
      }
    } catch (e) {
      // Hide loading dialog on error
      if (context != null) {
        LoadingDialog.hide(context);
      }
      print('Login error: $e');

      // Show error dialog
      if (context != null) {
        ResultDialog.showError(
          context,
          title: 'Connection Error',
          message: 'An error occurred during login. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}

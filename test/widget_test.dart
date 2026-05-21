import 'package:flutter_test/flutter_test.dart';
import 'package:nextask/main.dart';
import 'package:nextask/providers/auth_provider.dart';
import 'package:nextask/providers/task_provider.dart';
import 'package:nextask/services/auth_service.dart';
import 'package:nextask/services/task_service.dart';

class _FakeAuthService extends AuthService {
  @override
  Future<String?> readToken() async => null;
}

void main() {
  testWidgets('shows login screen when no token is stored', (tester) async {
    final authProvider = AuthProvider(_FakeAuthService());
    final taskProvider = TaskProvider(TaskService());

    await tester.pumpWidget(
      NexTaskApp(authProvider: authProvider, taskProvider: taskProvider),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}

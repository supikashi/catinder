import 'package:catinder/presentation/screens/auth/login_screen.dart';
import 'package:catinder/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    when(() => mockAuthProvider.isLoading).thenReturn(false);
    when(() => mockAuthProvider.errorMessage).thenReturn(null);
    when(() => mockAuthProvider.isAuthenticated).thenReturn(false);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('renders LoginScreen with default Login mode', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
  });

  testWidgets('switches to Sign Up mode when button is tapped', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Don\'t have an account? Sign Up'));
    await tester.pump();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    expect(find.text('Already have an account? Login'), findsOneWidget);

    verify(() => mockAuthProvider.clearError()).called(1);
  });

  testWidgets('shows validation errors for invalid input', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Invalid email format'), findsOneWidget);
  });

  testWidgets('calls login on provider when inputs are valid', (tester) async {
    when(() => mockAuthProvider.login(any(), any()))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    verify(() => mockAuthProvider.login('test@example.com', 'password123'))
        .called(1);
  });

  testWidgets('calls signUp on provider when inputs are valid in Sign Up mode',
      (tester) async {
    when(() => mockAuthProvider.signUp(any(), any()))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text('Don\'t have an account? Sign Up'));
    await tester.pump();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'new@example.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pump();

    verify(() => mockAuthProvider.signUp('new@example.com', 'password123'))
        .called(1);
  });

  testWidgets('shows error message from provider', (tester) async {
    when(() => mockAuthProvider.errorMessage).thenReturn('Invalid credentials');

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}

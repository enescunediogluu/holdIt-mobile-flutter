import 'package:bloc/bloc.dart';
import 'package:holdit/services/auth/auth_provider.dart';
import 'package:holdit/services/auth/bloc/auth_event.dart';
import 'package:holdit/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventSendEmailVerification>(
      (event, emit) async {
        await provider.sendEmailVerification();
        emit(state);
      },
    );

    on<AuthEventRegister>(
      (event, emit) async {
        final email = event.email;
        final password = event.password;
        try {
          await provider.createUser(
            email: email,
            password: password,
          );
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateRegistering(exception: e, isLoading: false));
        }
      },
    );
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      },
    );
    //login
    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Signing In ...',
        ));
        final email = event.email;
        final password = event.password;
        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );
          if (!user.isEmailVerified) {
            emit(
              const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
              ),
            );
            emit(const AuthStateNeedsVerification(isLoading: false));
          } else {
            emit(
              const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
              ),
            );
            emit(AuthStateLoggedIn(user: user, isLoading: false));
          }
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      },
    );

    on<AuthEventGoToNotes>(
      (event, emit) => emit(
        const AuthStateOnNotesView(isLoading: false),
      ),
    );
    //go to todo route
    on<AuthEventGoToTodos>(
      (event, emit) => emit(const AuthStateOnTodosView(
        isLoading: false,
      )),
    );
    //Should register
    on<AuthEventShouldRegister>(
      (event, emit) =>
          emit(const AuthStateRegistering(exception: null, isLoading: false)),
    );

    //logout
    on<AuthEventLogOut>(
      (event, emit) async {
        emit(const AuthStateUninitialized(isLoading: true));
        try {
          await provider.logOut();
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ));
        }
      },
    );
  }
}

import 'package:athlos/features/authentication/authentication_repository_impl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'app_bloc_observer.dart';
import 'features/authentication/bloc/authentication_bloc.dart';
import 'features/database/user_bloc/database_bloc.dart';
import 'features/database/database_repository_impl.dart';
import 'features/form-validation/bloc/form_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ignore: deprecated_member_use
  BlocOverrides.runZoned(
    () => runApp(MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthenticationBloc(AuthenticationRepositoryImpl())
                ..add(AuthenticationStarted()),
        ),
        BlocProvider(
          create: (context) => FormBloc(
              AuthenticationRepositoryImpl(), DatabaseRepositoryImpl()),
        ),
        BlocProvider(
          create: (context) => DatabaseBloc(DatabaseRepositoryImpl()),
        )
      ],
      child: const App(),
    )),
    blocObserver: AppBlocObserver(),
  );
}

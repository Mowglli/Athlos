import 'package:athlos/features/authentication/bloc/authentication_bloc.dart';
import 'package:athlos/features/database/user_bloc/database_bloc.dart';
import 'package:athlos/view/exercise_view.dart';
import 'package:athlos/view/profile_view.dart';
import 'package:athlos/view/volume_view.dart';
import 'package:athlos/utils/constants.dart';
import 'package:athlos/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 2;
  final screens = [
    VolumePage(),
    ExercisePage(),
    ProfilePage(),

    //MaxesPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationFailure) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const WelcomeView()),
              (Route<dynamic> route) => false);
        }
      },
      buildWhen: ((previous, current) {
        if (current is AuthenticationFailure) {
          return false;
        }
        return true;
      }),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: <Widget>[
              IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    context
                        .read<AuthenticationBloc>()
                        .add(AuthenticationSignedOut());
                  })
            ],
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Color.fromARGB(255, 72, 93, 110)),
            title:
                Text("Hello " + (state as AuthenticationSuccess).displayName!),
          ),
          body: screens[_selectedIndex],
          // ignore: prefer_const_constructors
          bottomNavigationBar: Container(
            color: Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
              child: GNav(
                  backgroundColor: Colors.white,
                  color: Colors.black,
                  activeColor: Colors.black,
                  tabBackgroundColor: Colors.grey.shade300,
                  gap: 8,
                  padding: EdgeInsets.all(16),
                  tabs: const [
                    GButton(
                      icon: Icons.timeline,
                      text: "Volume",
                    ),
                    GButton(
                      icon: Icons.add,
                      text: "Workout",
                    ),
                    GButton(icon: Icons.person, text: "Profile"),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  }),
            ),
          ),

          /*BlocBuilder<DatabaseBloc, DatabaseState>(
              builder: (context, state) {
                String? displayName = (context.read<AuthenticationBloc>().state
                        as AuthenticationSuccess)
                    .displayName;
                if (state is DatabaseSuccess &&
                    displayName !=
                        (context.read<DatabaseBloc>().state as DatabaseSuccess)
                            .displayName) {
                  context
                      .read<DatabaseBloc>()
                      .add(DatabaseFetched(displayName));
                }
                if (state is DatabaseInitial) {
                  context
                      .read<DatabaseBloc>()
                      .add(DatabaseFetched(displayName));
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DatabaseSuccess) {
                  if (state.listOfUserData.isEmpty) {
                    return const Center(
                      child: Text(Constants.textNoData),
                    );
                  } else {
                    return Center(
                      child: ListView.builder(
                        itemCount: state.listOfUserData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                  state.listOfUserData[index].displayName!),
                              subtitle:
                                  Text(state.listOfUserData[index].email!),
                              trailing: Text(
                                  state.listOfUserData[index].age!.toString()),
                            ),
                          );
                        },
                      ),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )*/
        );
      },
    );
  }
}

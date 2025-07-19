import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:wattwise/providers/home_provider.dart';
import 'package:wattwise/providers/profile_Provider.dart';
import 'package:wattwise/widgets/profile/editprofile_form.dart';
import 'package:wattwise/widgets/profile/error_view.dart';
import 'package:wattwise/widgets/profile/profile_content.dart';
import '../../providers/user_provider.dart';
import '../../providers/energy_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).loadProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector3<UserProvider, EnergyProvider, HomeProvider,
            Tuple3<UserProvider?, EnergyProvider, HomeProvider>>(
        selector: (
          _,
          userProvider,
          energyProvider,
          homeProvider,
        ) =>
            Tuple3(userProvider, energyProvider, homeProvider),
        builder: (context, tuple, _) {
          final userProvider = tuple.item1!;
          final energyProvider = tuple.item2;
          final homeProvider = tuple.item3;
          // final profileProvider = tuple.item3;

          if (userProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return Consumer<ProfileProvider>(
              builder: (context, profileProvider, _) {
            return Scaffold(
                body: profileProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : userProvider.user == null
                        ? ErrorView(profile: profileProvider)
                        : profileProvider.isEditingProfile
                            ? EditprofileForm(profile: profileProvider)
                            : ProfileContent(
                                user: userProvider.user!,
                                energyProvider: energyProvider,
                                profile: profileProvider,
                                homeProvider: homeProvider,
                              ));
          });
        });
  }
}

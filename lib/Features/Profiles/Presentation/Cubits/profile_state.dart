
// ignore_for_file: camel_case_types

import '../../Domain/Entities/Profile.dart';

abstract class ProfileState{}

class initialProfile extends ProfileState{}

class loadingProfile extends ProfileState{}

class loadedProfile extends ProfileState{
  ProfileUser? profileUser;
  loadedProfile(this.profileUser);
}

class loadfail extends ProfileState{}
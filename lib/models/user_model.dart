class UserModel {
  final String? userSub;
  final String? email;
  final String? stripeCustomerId;
  final bool? emailVerified;
  final bool? phoneVerified;
  final String? groupType;
  final String? groupId;
  final String? accessToken;
  final String? refreshToken;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profession;
  final String? ehrSoftware;
  final String? practiceName;
  final String? practicePhoneNumber;
  final bool? onboardingCompleted;
  final bool? isMfaEnabled;
  final String? fhirBaseUrl;

  const UserModel({
    this.userSub,
    this.email,
    this.stripeCustomerId,
    this.emailVerified,
    this.phoneVerified,
    this.groupType,
    this.groupId,
    this.accessToken,
    this.refreshToken,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profession,
    this.ehrSoftware,
    this.practiceName,
    this.practicePhoneNumber,
    this.onboardingCompleted,
    this.isMfaEnabled,
    this.fhirBaseUrl,
  });

  UserModel copyWith({
    String? userSub,
    String? email,
    String? stripeCustomerId,
    bool? emailVerified,
    bool? phoneVerified,
    String? groupType,
    String? groupId,
    String? accessToken,
    String? refreshToken,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profession,
    String? ehrSoftware,
    String? practiceName,
    String? practicePhoneNumber,
    bool? onboardingCompleted,
    bool? isMfaEnabled,
    String? fhirBaseUrl,
  }) {
    return UserModel(
      userSub: userSub ?? this.userSub,
      email: email ?? this.email,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      groupType: groupType ?? this.groupType,
      groupId: groupId ?? this.groupId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profession: profession ?? this.profession,
      ehrSoftware: ehrSoftware ?? this.ehrSoftware,
      practiceName: practiceName ?? this.practiceName,
      practicePhoneNumber: practicePhoneNumber ?? this.practicePhoneNumber,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
      fhirBaseUrl: fhirBaseUrl ?? this.fhirBaseUrl,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userSub: json['userSub'] as String?,
      email: json['email'] as String?,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      phoneVerified: json['phoneVerified'] as bool?,
      groupType: json['groupType'] as String?,
      groupId: json['groupId'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      profession: json['profession'] as String?,
      ehrSoftware: json['ehrSoftware'] as String?,
      practiceName: json['practiceName'] as String?,
      practicePhoneNumber: json['practicePhoneNumber'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool?,
      isMfaEnabled: json['isMfaEnabled'] as bool?,
      fhirBaseUrl: json['fhirBaseUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userSub': userSub,
      'email': email,
      'stripeCustomerId': stripeCustomerId,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'groupType': groupType,
      'groupId': groupId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profession': profession,
      'ehrSoftware': ehrSoftware,
      'practiceName': practiceName,
      'practicePhoneNumber': practicePhoneNumber,
      'onboardingCompleted': onboardingCompleted,
      'isMfaEnabled': isMfaEnabled,
      'fhirBaseUrl': fhirBaseUrl,
    };
  }
}

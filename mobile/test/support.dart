import 'package:homeroom_api/api.dart';

/// A minimal valid session for tests; [expiresIn] is seconds from when it starts.
Session fakeSession({String access = 'a1', String refresh = 'r1', int expiresIn = 900, DateTime? serverNow}) => Session(
      accessToken: access,
      refreshToken: refresh,
      expiresIn: expiresIn,
      me: Me(
        id: 'p1',
        fullName: 'Esi Mensah',
        role: Role.teacher,
        school: MeSchool(id: 's1', name: 'Greenfield Academy', timezone: 'Africa/Accra'),
        now: serverNow ?? DateTime.utc(2026, 10, 5, 8),
      ),
    );

ApiException unauthorized() => ApiException(401, '{"status":401,"code":"invalid_token","title":"Unauthorized"}');

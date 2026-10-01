//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApiClient {
  ApiClient({this.basePath = 'https://api.homeroom.example/v1', this.authentication,});

  final String basePath;
  final Authentication? authentication;

  var _client = Client();
  final _defaultHeaderMap = <String, String>{};

  /// Returns the current HTTP [Client] instance to use in this class.
  ///
  /// The return value is guaranteed to never be null.
  Client get client => _client;

  /// Requests to use a new HTTP [Client] in this class.
  set client(Client newClient) {
    _client = newClient;
  }

  Map<String, String> get defaultHeaderMap => _defaultHeaderMap;

  void addDefaultHeader(String key, String value) {
     _defaultHeaderMap[key] = value;
  }

  // We don't use a Map<String, String> for queryParams.
  // If collectionFormat is 'multi', a key might appear multiple times.
  Future<Response> invokeAPI(
    String path,
    String method,
    List<QueryParam> queryParams,
    Object? body,
    Map<String, String> headerParams,
    Map<String, String> formParams,
    String? contentType, {
    Future<void>? abortTrigger,
  }) async {
    await authentication?.applyToParams(queryParams, headerParams);

    headerParams.addAll(_defaultHeaderMap);
    if (contentType != null) {
      headerParams['Content-Type'] = contentType;
    }

    final urlEncodedQueryParams = queryParams.map((param) => '$param');
    final queryString = urlEncodedQueryParams.isNotEmpty ? '?${urlEncodedQueryParams.join('&')}' : '';
    final uri = Uri.parse('$basePath$path$queryString');

    try {
      // Special case for uploading a single file which isn't a 'multipart/form-data'.
      if (
        body is MultipartFile && (contentType == null ||
        !contentType.toLowerCase().startsWith('multipart/form-data'))
      ) {
        final request = AbortableStreamedRequest(method, uri, abortTrigger: abortTrigger);
        request.headers.addAll(headerParams);
        request.contentLength = body.length;
        body.finalize().listen(
          request.sink.add,
          onDone: request.sink.close,
          // ignore: avoid_types_on_closure_parameters
          onError: (Object error, StackTrace trace) => request.sink.close(),
          cancelOnError: true,
        );
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      if (body is MultipartRequest) {
        final request = AbortableMultipartRequest(method, uri, abortTrigger: abortTrigger);
        request.fields.addAll(body.fields);
        request.files.addAll(body.files);
        request.headers.addAll(body.headers);
        request.headers.addAll(headerParams);
        final response = await _client.send(request);
        return Response.fromStream(response);
      }

      final msgBody = contentType == 'application/x-www-form-urlencoded'
        ? formParams
        : await serializeAsync(body);
      final nullableHeaderParams = headerParams.isEmpty ? null : headerParams;

      final request = AbortableRequest(method, uri, abortTrigger: abortTrigger);
      if (nullableHeaderParams != null) {
        request.headers.addAll(nullableHeaderParams);
      }
      if (msgBody is String && msgBody.isNotEmpty) {
        request.body = msgBody;
      } else if (msgBody is List<int> && msgBody.isNotEmpty) {
        request.bodyBytes = msgBody;
      } else if (msgBody is Map<String, String>) {
        request.bodyFields = msgBody;
      }
      final response = await _client.send(request);
      return Response.fromStream(response);
    } on SocketException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Socket operation failed: $method $path',
        error,
        trace,
      );
    } on TlsException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'TLS/SSL communication failed: $method $path',
        error,
        trace,
      );
    } on IOException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'I/O operation failed: $method $path',
        error,
        trace,
      );
    } on ClientException catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'HTTP connection failed: $method $path',
        error,
        trace,
      );
    } on Exception catch (error, trace) {
      throw ApiException.withInner(
        HttpStatus.badRequest,
        'Exception occurred: $method $path',
        error,
        trace,
      );
    }
  }

  Future<dynamic> deserializeAsync(String value, String targetType, {bool growable = false,}) async =>
    // ignore: deprecated_member_use_from_same_package
    deserialize(value, targetType, growable: growable);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use deserializeAsync() instead.')
  dynamic deserialize(String value, String targetType, {bool growable = false,}) {
    // Remove all spaces. Necessary for regular expressions as well.
    targetType = targetType.replaceAll(' ', ''); // ignore: parameter_assignments

    // If the expected target type is String, nothing to do...
    return targetType == 'String'
      ? value
      : fromJson(json.decode(value), targetType, growable: growable);
  }

  // ignore: deprecated_member_use_from_same_package
  Future<String> serializeAsync(Object? value) async => serialize(value);

  @Deprecated('Scheduled for removal in OpenAPI Generator 6.x. Use serializeAsync() instead.')
  String serialize(Object? value) => value == null ? '' : json.encode(value);

  /// Returns a native instance of an OpenAPI class matching the [specified type][targetType].
  static dynamic fromJson(dynamic value, String targetType, {bool growable = false,}) {
    try {
      switch (targetType) {
        case 'String':
          return value is String ? value : value.toString();
        case 'int':
          return value is int ? value : int.parse('$value');
        case 'double':
          return value is double ? value : double.parse('$value');
        case 'bool':
          if (value is bool) {
            return value;
          }
          final valueString = '$value'.toLowerCase();
          return valueString == 'true' || valueString == '1';
        case 'DateTime':
          return value is DateTime ? value : DateTime.tryParse(value);
        case 'AdminOverview':
          return AdminOverview.fromJson(value);
        case 'AdminOverviewRegistersUnmarkedInner':
          return AdminOverviewRegistersUnmarkedInner.fromJson(value);
        case 'Announcement':
          return Announcement.fromJson(value);
        case 'AnnouncementInput':
          return AnnouncementInput.fromJson(value);
        case 'AnnouncementPage':
          return AnnouncementPage.fromJson(value);
        case 'AnnouncementResponse':
          return AnnouncementResponse.fromJson(value);
        case 'Assessment':
          return Assessment.fromJson(value);
        case 'AssessmentInput':
          return AssessmentInput.fromJson(value);
        case 'AttendanceRecord':
          return AttendanceRecord.fromJson(value);
        case 'AttendanceReport':
          return AttendanceReport.fromJson(value);
        case 'AttendanceReportRowsInner':
          return AttendanceReportRowsInner.fromJson(value);
        case 'AttendanceStatus':
          return AttendanceStatusTypeTransformer().decode(value);
        case 'AuditEntry':
          return AuditEntry.fromJson(value);
        case 'BatchResult':
          return BatchResult.fromJson(value);
        case 'BatchResultResultsInner':
          return BatchResultResultsInner.fromJson(value);
        case 'BookConferenceSlotRequest':
          return BookConferenceSlotRequest.fromJson(value);
        case 'ClassSection':
          return ClassSection.fromJson(value);
        case 'ClassSectionDetail':
          return ClassSectionDetail.fromJson(value);
        case 'ClassSectionDetailAllOfTeachers':
          return ClassSectionDetailAllOfTeachers.fromJson(value);
        case 'ClassSectionInput':
          return ClassSectionInput.fromJson(value);
        case 'CompleteSandboxPaymentRequest':
          return CompleteSandboxPaymentRequest.fromJson(value);
        case 'ConferenceSlot':
          return ConferenceSlot.fromJson(value);
        case 'Contact':
          return Contact.fromJson(value);
        case 'CorrectAttendanceRecordRequest':
          return CorrectAttendanceRecordRequest.fromJson(value);
        case 'CreateConferenceSlotsRequest':
          return CreateConferenceSlotsRequest.fromJson(value);
        case 'CreateFeeItemRequest':
          return CreateFeeItemRequest.fromJson(value);
        case 'CreateGradeBandRequest':
          return CreateGradeBandRequest.fromJson(value);
        case 'CreateInvoicesRequest':
          return CreateInvoicesRequest.fromJson(value);
        case 'CreateSchoolRequest':
          return CreateSchoolRequest.fromJson(value);
        case 'CreateSchoolRequestAdmin':
          return CreateSchoolRequestAdmin.fromJson(value);
        case 'EnrollStudentRequest':
          return EnrollStudentRequest.fromJson(value);
        case 'Enrollment':
          return Enrollment.fromJson(value);
        case 'FeeItem':
          return FeeItem.fromJson(value);
        case 'GetAnnouncementResponses200Response':
          return GetAnnouncementResponses200Response.fromJson(value);
        case 'GetReportComments200Response':
          return GetReportComments200Response.fromJson(value);
        case 'GetStudentAttendance200Response':
          return GetStudentAttendance200Response.fromJson(value);
        case 'GetStudentGrades200Response':
          return GetStudentGrades200Response.fromJson(value);
        case 'GetStudentHomework200Response':
          return GetStudentHomework200Response.fromJson(value);
        case 'GetStudentInvoices200Response':
          return GetStudentInvoices200Response.fromJson(value);
        case 'GetTeacherToday200Response':
          return GetTeacherToday200Response.fromJson(value);
        case 'GetTimetable200Response':
          return GetTimetable200Response.fromJson(value);
        case 'Grade':
          return Grade.fromJson(value);
        case 'GradeBand':
          return GradeBand.fromJson(value);
        case 'Gradebook':
          return Gradebook.fromJson(value);
        case 'GradebookRowsInner':
          return GradebookRowsInner.fromJson(value);
        case 'GuardianLink':
          return GuardianLink.fromJson(value);
        case 'Homework':
          return Homework.fromJson(value);
        case 'HomeworkInput':
          return HomeworkInput.fromJson(value);
        case 'ImportStudents201Response':
          return ImportStudents201Response.fromJson(value);
        case 'ImportStudentsRequest':
          return ImportStudentsRequest.fromJson(value);
        case 'ImportStudentsRequestStudentsInner':
          return ImportStudentsRequestStudentsInner.fromJson(value);
        case 'Invoice':
          return Invoice.fromJson(value);
        case 'InvoicePage':
          return InvoicePage.fromJson(value);
        case 'LinkGuardianRequest':
          return LinkGuardianRequest.fromJson(value);
        case 'ListAuditLog200Response':
          return ListAuditLog200Response.fromJson(value);
        case 'ListClassSections200Response':
          return ListClassSections200Response.fromJson(value);
        case 'ListConferenceSlots200Response':
          return ListConferenceSlots200Response.fromJson(value);
        case 'ListFeeItems200Response':
          return ListFeeItems200Response.fromJson(value);
        case 'ListGradeBands200Response':
          return ListGradeBands200Response.fromJson(value);
        case 'ListGrades200Response':
          return ListGrades200Response.fromJson(value);
        case 'ListMessages200Response':
          return ListMessages200Response.fromJson(value);
        case 'ListPayments200Response':
          return ListPayments200Response.fromJson(value);
        case 'ListTerms200Response':
          return ListTerms200Response.fromJson(value);
        case 'ListThreads200Response':
          return ListThreads200Response.fromJson(value);
        case 'MarkNotificationsReadRequest':
          return MarkNotificationsReadRequest.fromJson(value);
        case 'Me':
          return Me.fromJson(value);
        case 'MeSchool':
          return MeSchool.fromJson(value);
        case 'Message':
          return Message.fromJson(value);
        case 'Notification':
          return Notification.fromJson(value);
        case 'NotificationPage':
          return NotificationPage.fromJson(value);
        case 'NotificationPrefs':
          return NotificationPrefs.fromJson(value);
        case 'OpenThreadRequest':
          return OpenThreadRequest.fromJson(value);
        case 'Payment':
          return Payment.fromJson(value);
        case 'PaymentStart':
          return PaymentStart.fromJson(value);
        case 'PaymentStartNext':
          return PaymentStartNext.fromJson(value);
        case 'PaymentStatus':
          return PaymentStatusTypeTransformer().decode(value);
        case 'Period':
          return Period.fromJson(value);
        case 'PeriodInput':
          return PeriodInput.fromJson(value);
        case 'Person':
          return Person.fromJson(value);
        case 'PersonAssignmentsInner':
          return PersonAssignmentsInner.fromJson(value);
        case 'PersonContact':
          return PersonContact.fromJson(value);
        case 'PersonInput':
          return PersonInput.fromJson(value);
        case 'PersonPage':
          return PersonPage.fromJson(value);
        case 'Problem':
          return Problem.fromJson(value);
        case 'ProblemErrorsInner':
          return ProblemErrorsInner.fromJson(value);
        case 'RecordManualPaymentRequest':
          return RecordManualPaymentRequest.fromJson(value);
        case 'RefreshSessionRequest':
          return RefreshSessionRequest.fromJson(value);
        case 'Register':
          return Register.fromJson(value);
        case 'RegisterEntriesInner':
          return RegisterEntriesInner.fromJson(value);
        case 'RegisterPushTokenRequest':
          return RegisterPushTokenRequest.fromJson(value);
        case 'RegisterSubmission':
          return RegisterSubmission.fromJson(value);
        case 'RegisterSubmissionEntriesInner':
          return RegisterSubmissionEntriesInner.fromJson(value);
        case 'ReportComment':
          return ReportComment.fromJson(value);
        case 'ReportCommentSheet':
          return ReportCommentSheet.fromJson(value);
        case 'ReportCommentSheetItemsInner':
          return ReportCommentSheetItemsInner.fromJson(value);
        case 'RequestOtpRequest':
          return RequestOtpRequest.fromJson(value);
        case 'RequestPasswordResetRequest':
          return RequestPasswordResetRequest.fromJson(value);
        case 'ResetPasswordRequest':
          return ResetPasswordRequest.fromJson(value);
        case 'RespondToAnnouncementRequest':
          return RespondToAnnouncementRequest.fromJson(value);
        case 'Role':
          return RoleTypeTransformer().decode(value);
        case 'School':
          return School.fromJson(value);
        case 'SelectSessionPersonRequest':
          return SelectSessionPersonRequest.fromJson(value);
        case 'SelectionRequired':
          return SelectionRequired.fromJson(value);
        case 'SelectionRequiredChoicesInner':
          return SelectionRequiredChoicesInner.fromJson(value);
        case 'SendMessageRequest':
          return SendMessageRequest.fromJson(value);
        case 'Session':
          return Session.fromJson(value);
        case 'SignInResult':
          return SignInResult.fromJson(value);
        case 'SignInWithPasswordRequest':
          return SignInWithPasswordRequest.fromJson(value);
        case 'StartPaymentRequest':
          return StartPaymentRequest.fromJson(value);
        case 'Student':
          return Student.fromJson(value);
        case 'StudentDetail':
          return StudentDetail.fromJson(value);
        case 'StudentPage':
          return StudentPage.fromJson(value);
        case 'StudentRef':
          return StudentRef.fromJson(value);
        case 'StudentRefClassSection':
          return StudentRefClassSection.fromJson(value);
        case 'StudentSummary':
          return StudentSummary.fromJson(value);
        case 'StudentSummaryAttendance':
          return StudentSummaryAttendance.fromJson(value);
        case 'StudentSummaryGradesInner':
          return StudentSummaryGradesInner.fromJson(value);
        case 'SubjectGrades':
          return SubjectGrades.fromJson(value);
        case 'SubjectGradesAssessmentsInner':
          return SubjectGradesAssessmentsInner.fromJson(value);
        case 'Term':
          return Term.fromJson(value);
        case 'TermInput':
          return TermInput.fromJson(value);
        case 'Thread':
          return Thread.fromJson(value);
        case 'TodayPeriod':
          return TodayPeriod.fromJson(value);
        case 'UpdateFeeItemRequest':
          return UpdateFeeItemRequest.fromJson(value);
        case 'UpdateGradeBandRequest':
          return UpdateGradeBandRequest.fromJson(value);
        case 'UpdateMyContactRequest':
          return UpdateMyContactRequest.fromJson(value);
        case 'UpsertGradesRequest':
          return UpsertGradesRequest.fromJson(value);
        case 'UpsertGradesRequestGradesInner':
          return UpsertGradesRequestGradesInner.fromJson(value);
        case 'UpsertReportCommentsRequest':
          return UpsertReportCommentsRequest.fromJson(value);
        case 'UpsertReportCommentsRequestCommentsInner':
          return UpsertReportCommentsRequestCommentsInner.fromJson(value);
        case 'VerifyOtpRequest':
          return VerifyOtpRequest.fromJson(value);
        default:
          dynamic match;
          if (value is List && (match = _regList.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toList(growable: growable);
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)?.group(1)) != null) {
            return value
              .map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,))
              .toSet();
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)?.group(1)) != null) {
            return Map<String, dynamic>.fromIterables(
              value.keys.cast<String>(),
              value.values.map<dynamic>((dynamic v) => fromJson(v, match, growable: growable,)),
            );
          }
      }
    } on Exception catch (error, trace) {
      throw ApiException.withInner(HttpStatus.internalServerError, 'Exception during deserialization.', error, trace,);
    }
    throw ApiException(HttpStatus.internalServerError, 'Could not find a suitable class for deserialization',);
  }
}

/// Primarily intended for use in an isolate.
class DeserializationMessage {
  const DeserializationMessage({
    required this.json,
    required this.targetType,
    this.growable = false,
  });

  /// The JSON value to deserialize.
  final String json;

  /// Target type to deserialize to.
  final String targetType;

  /// Whether to make deserialized lists or maps growable.
  final bool growable;
}

/// Primarily intended for use in an isolate.
Future<dynamic> decodeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : json.decode(message.json);
}

/// Primarily intended for use in an isolate.
Future<dynamic> deserializeAsync(DeserializationMessage message) async {
  // Remove all spaces. Necessary for regular expressions as well.
  final targetType = message.targetType.replaceAll(' ', '');

  // If the expected target type is String, nothing to do...
  return targetType == 'String'
    ? message.json
    : ApiClient.fromJson(
        json.decode(message.json),
        targetType,
        growable: message.growable,
      );
}

/// Primarily intended for use in an isolate.
Future<String> serializeAsync(Object? value) async => value == null ? '' : json.encode(value);

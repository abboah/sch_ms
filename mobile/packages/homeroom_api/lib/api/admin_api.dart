//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AdminApi {
  AdminApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create a class section
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ClassSectionInput] classSectionInput (required):
  Future<Response> createClassSectionWithHttpInfo(ClassSectionInput classSectionInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections';

    // ignore: prefer_final_locals
    Object? postBody = classSectionInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create a class section
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [ClassSectionInput] classSectionInput (required):
  Future<ClassSection?> createClassSection(ClassSectionInput classSectionInput, { Future<void>? abortTrigger, }) async {
    final response = await createClassSectionWithHttpInfo(classSectionInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ClassSection',) as ClassSection;
    
    }
    return null;
  }

  /// Create a person (student, guardian, teacher, admin) and optionally invite them
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [PersonInput] personInput (required):
  Future<Response> createPersonWithHttpInfo(PersonInput personInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/people';

    // ignore: prefer_final_locals
    Object? postBody = personInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create a person (student, guardian, teacher, admin) and optionally invite them
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [PersonInput] personInput (required):
  Future<Person?> createPerson(PersonInput personInput, { Future<void>? abortTrigger, }) async {
    final response = await createPersonWithHttpInfo(personInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Person',) as Person;
    
    }
    return null;
  }

  /// Create a term
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [TermInput] termInput (required):
  Future<Response> createTermWithHttpInfo(TermInput termInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/terms';

    // ignore: prefer_final_locals
    Object? postBody = termInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Create a term
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [TermInput] termInput (required):
  Future<Term?> createTerm(TermInput termInput, { Future<void>? abortTrigger, }) async {
    final response = await createTermWithHttpInfo(termInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Term',) as Term;
    
    }
    return null;
  }

  /// Assign a student to a class section
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [EnrollStudentRequest] enrollStudentRequest (required):
  Future<Response> enrollStudentWithHttpInfo(EnrollStudentRequest enrollStudentRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/enrollments';

    // ignore: prefer_final_locals
    Object? postBody = enrollStudentRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Assign a student to a class section
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [EnrollStudentRequest] enrollStudentRequest (required):
  Future<Enrollment?> enrollStudent(EnrollStudentRequest enrollStudentRequest, { Future<void>? abortTrigger, }) async {
    final response = await enrollStudentWithHttpInfo(enrollStudentRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Enrollment',) as Enrollment;
    
    }
    return null;
  }

  /// Date-ranged attendance register export
  ///
  /// Roles: admin. Per-pupil counts over a date range. For a spreadsheet use the .csv variant.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] from (required):
  ///
  /// * [String] to (required):
  ///
  /// * [String] classSectionId:
  Future<Response> getAttendanceReportWithHttpInfo(String id, String from, String to, { String? classSectionId, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/schools/{id}/attendance_report'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));
    if (classSectionId != null) {
      queryParams.addAll(_queryParams('', 'class_section_id', classSectionId));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Date-ranged attendance register export
  ///
  /// Roles: admin. Per-pupil counts over a date range. For a spreadsheet use the .csv variant.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] from (required):
  ///
  /// * [String] to (required):
  ///
  /// * [String] classSectionId:
  Future<AttendanceReport?> getAttendanceReport(String id, String from, String to, { String? classSectionId, Future<void>? abortTrigger, }) async {
    final response = await getAttendanceReportWithHttpInfo(id, from, to, classSectionId: classSectionId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AttendanceReport',) as AttendanceReport;
    
    }
    return null;
  }

  /// Attendance register export as a CSV file
  ///
  /// Roles: admin. The same report as a download: one row per pupil, formula-safe, with a Content-Disposition filename.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] from (required):
  ///
  /// * [String] to (required):
  ///
  /// * [String] classSectionId:
  Future<Response> getAttendanceReportCsvWithHttpInfo(String id, String from, String to, { String? classSectionId, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/schools/{id}/attendance_report.csv'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'from', from));
      queryParams.addAll(_queryParams('', 'to', to));
    if (classSectionId != null) {
      queryParams.addAll(_queryParams('', 'class_section_id', classSectionId));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Attendance register export as a CSV file
  ///
  /// Roles: admin. The same report as a download: one row per pupil, formula-safe, with a Content-Disposition filename.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [String] from (required):
  ///
  /// * [String] to (required):
  ///
  /// * [String] classSectionId:
  Future<String?> getAttendanceReportCsv(String id, String from, String to, { String? classSectionId, Future<void>? abortTrigger, }) async {
    final response = await getAttendanceReportCsvWithHttpInfo(id, from, to, classSectionId: classSectionId, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'String',) as String;
    
    }
    return null;
  }

  /// Bulk-create students and enrol them in this section
  ///
  /// Roles: admin. Each row becomes a new student (there is no matching against existing people); build the array from a CSV client-side, one row per pupil.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ImportStudentsRequest] importStudentsRequest (required):
  Future<Response> importStudentsWithHttpInfo(String id, ImportStudentsRequest importStudentsRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/students/import'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = importStudentsRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Bulk-create students and enrol them in this section
  ///
  /// Roles: admin. Each row becomes a new student (there is no matching against existing people); build the array from a CSV client-side, one row per pupil.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ImportStudentsRequest] importStudentsRequest (required):
  Future<ImportStudents201Response?> importStudents(String id, ImportStudentsRequest importStudentsRequest, { Future<void>? abortTrigger, }) async {
    final response = await importStudentsWithHttpInfo(id, importStudentsRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ImportStudents201Response',) as ImportStudents201Response;
    
    }
    return null;
  }

  /// Link a guardian to a student
  ///
  /// Roles: admin. The link is many-to-many and is the join every guardian permission hangs off.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [LinkGuardianRequest] linkGuardianRequest (required):
  Future<Response> linkGuardianWithHttpInfo(String id, LinkGuardianRequest linkGuardianRequest, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/students/{id}/guardians'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = linkGuardianRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Link a guardian to a student
  ///
  /// Roles: admin. The link is many-to-many and is the join every guardian permission hangs off.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [LinkGuardianRequest] linkGuardianRequest (required):
  Future<void> linkGuardian(String id, LinkGuardianRequest linkGuardianRequest, { Future<void>? abortTrigger, }) async {
    final response = await linkGuardianWithHttpInfo(id, linkGuardianRequest, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Who read or changed which student record
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] studentId:
  ///
  /// * [String] actorId:
  ///
  /// * [String] from:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listAuditLogWithHttpInfo({ String? studentId, String? actorId, String? from, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/audit_log';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (studentId != null) {
      queryParams.addAll(_queryParams('', 'student_id', studentId));
    }
    if (actorId != null) {
      queryParams.addAll(_queryParams('', 'actor_id', actorId));
    }
    if (from != null) {
      queryParams.addAll(_queryParams('', 'from', from));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Who read or changed which student record
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [String] studentId:
  ///
  /// * [String] actorId:
  ///
  /// * [String] from:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<ListAuditLog200Response?> listAuditLog({ String? studentId, String? actorId, String? from, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await listAuditLogWithHttpInfo(studentId: studentId, actorId: actorId, from: from, limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ListAuditLog200Response',) as ListAuditLog200Response;
    
    }
    return null;
  }

  /// Staff and guardians directory
  ///
  /// Roles: admin. (Students are under /students.)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] role:
  ///
  /// * [String] q:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<Response> listPeopleWithHttpInfo({ String? role, String? q, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/people';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (role != null) {
      queryParams.addAll(_queryParams('', 'role', role));
    }
    if (q != null) {
      queryParams.addAll(_queryParams('', 'q', q));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }
    if (cursor != null) {
      queryParams.addAll(_queryParams('', 'cursor', cursor));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Staff and guardians directory
  ///
  /// Roles: admin. (Students are under /students.)
  ///
  /// Parameters:
  ///
  /// * [String] role:
  ///
  /// * [String] q:
  ///
  /// * [int] limit:
  ///
  /// * [String] cursor:
  Future<PersonPage?> listPeople({ String? role, String? q, int? limit, String? cursor, Future<void>? abortTrigger, }) async {
    final response = await listPeopleWithHttpInfo(role: role, q: q, limit: limit, cursor: cursor, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PersonPage',) as PersonPage;
    
    }
    return null;
  }

  /// Replace the section's timetable
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [List<PeriodInput>] periodInput (required):
  Future<Response> setTimetableWithHttpInfo(String id, List<PeriodInput> periodInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}/periods'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = periodInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Replace the section's timetable
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [List<PeriodInput>] periodInput (required):
  Future<GetTimetable200Response?> setTimetable(String id, List<PeriodInput> periodInput, { Future<void>? abortTrigger, }) async {
    final response = await setTimetableWithHttpInfo(id, periodInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'GetTimetable200Response',) as GetTimetable200Response;
    
    }
    return null;
  }

  /// Edit a section, e.g. change the homeroom teacher
  ///
  /// Roles: admin.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ClassSectionInput] classSectionInput (required):
  Future<Response> updateClassSectionWithHttpInfo(String id, ClassSectionInput classSectionInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/class_sections/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = classSectionInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Edit a section, e.g. change the homeroom teacher
  ///
  /// Roles: admin.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [ClassSectionInput] classSectionInput (required):
  Future<ClassSection?> updateClassSection(String id, ClassSectionInput classSectionInput, { Future<void>? abortTrigger, }) async {
    final response = await updateClassSectionWithHttpInfo(id, classSectionInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ClassSection',) as ClassSection;
    
    }
    return null;
  }

  /// Edit a term, or close it
  ///
  /// Roles: admin. `closed: true` locks teacher edits for every section in the term.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [TermInput] termInput (required):
  Future<Response> updateTermWithHttpInfo(String id, TermInput termInput, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/terms/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody = termInput;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PATCH',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Edit a term, or close it
  ///
  /// Roles: admin. `closed: true` locks teacher edits for every section in the term.
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  ///
  /// * [TermInput] termInput (required):
  Future<Term?> updateTerm(String id, TermInput termInput, { Future<void>? abortTrigger, }) async {
    final response = await updateTermWithHttpInfo(id, termInput, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Term',) as Term;
    
    }
    return null;
  }

  /// Withdraw a student from a section
  ///
  /// Roles: admin. **Soft delete**: sets status to `withdrawn`; the row and its history stay for transcripts (the database has no DELETE policy).
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<Response> withdrawStudentWithHttpInfo(String id, { Future<void>? abortTrigger, }) async {
    // ignore: prefer_const_declarations
    final path = r'/enrollments/{id}'
      .replaceAll('{id}', id);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
      abortTrigger: abortTrigger,
    );
  }

  /// Withdraw a student from a section
  ///
  /// Roles: admin. **Soft delete**: sets status to `withdrawn`; the row and its history stay for transcripts (the database has no DELETE policy).
  ///
  /// Parameters:
  ///
  /// * [String] id (required):
  Future<void> withdrawStudent(String id, { Future<void>? abortTrigger, }) async {
    final response = await withdrawStudentWithHttpInfo(id, abortTrigger: abortTrigger,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}

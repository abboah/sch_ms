# homeroom_api.api.AdminApi

## Load the API package
```dart
import 'package:homeroom_api/api.dart';
```

All URIs are relative to *https://api.homeroom.example/v1*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createClassSection**](AdminApi.md#createclasssection) | **POST** /class_sections | Create a class section
[**createPerson**](AdminApi.md#createperson) | **POST** /people | Create a person (student, guardian, teacher, admin) and optionally invite them
[**createTerm**](AdminApi.md#createterm) | **POST** /terms | Create a term
[**enrollStudent**](AdminApi.md#enrollstudent) | **POST** /enrollments | Assign a student to a class section
[**getAttendanceReport**](AdminApi.md#getattendancereport) | **GET** /schools/{id}/attendance_report | Date-ranged attendance register export
[**getAttendanceReportCsv**](AdminApi.md#getattendancereportcsv) | **GET** /schools/{id}/attendance_report.csv | Attendance register export as a CSV file
[**importStudents**](AdminApi.md#importstudents) | **POST** /class_sections/{id}/students/import | Bulk-create students and enrol them in this section
[**linkGuardian**](AdminApi.md#linkguardian) | **PUT** /students/{id}/guardians | Link a guardian to a student
[**listAuditLog**](AdminApi.md#listauditlog) | **GET** /audit_log | Who read or changed which student record
[**listPeople**](AdminApi.md#listpeople) | **GET** /people | Staff and guardians directory
[**setTimetable**](AdminApi.md#settimetable) | **PUT** /class_sections/{id}/periods | Replace the section's timetable
[**updateClassSection**](AdminApi.md#updateclasssection) | **PATCH** /class_sections/{id} | Edit a section, e.g. change the homeroom teacher
[**updateTerm**](AdminApi.md#updateterm) | **PATCH** /terms/{id} | Edit a term, or close it
[**withdrawStudent**](AdminApi.md#withdrawstudent) | **DELETE** /enrollments/{id} | Withdraw a student from a section


# **createClassSection**
> ClassSection createClassSection(classSectionInput)

Create a class section

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final classSectionInput = ClassSectionInput(); // ClassSectionInput | 

try {
    final result = api_instance.createClassSection(classSectionInput);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->createClassSection: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **classSectionInput** | [**ClassSectionInput**](ClassSectionInput.md)|  | 

### Return type

[**ClassSection**](ClassSection.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPerson**
> Person createPerson(personInput)

Create a person (student, guardian, teacher, admin) and optionally invite them

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final personInput = PersonInput(); // PersonInput | 

try {
    final result = api_instance.createPerson(personInput);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->createPerson: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **personInput** | [**PersonInput**](PersonInput.md)|  | 

### Return type

[**Person**](Person.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createTerm**
> Term createTerm(termInput)

Create a term

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final termInput = TermInput(); // TermInput | 

try {
    final result = api_instance.createTerm(termInput);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->createTerm: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **termInput** | [**TermInput**](TermInput.md)|  | 

### Return type

[**Term**](Term.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **enrollStudent**
> Enrollment enrollStudent(enrollStudentRequest)

Assign a student to a class section

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final enrollStudentRequest = EnrollStudentRequest(); // EnrollStudentRequest | 

try {
    final result = api_instance.enrollStudent(enrollStudentRequest);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->enrollStudent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **enrollStudentRequest** | [**EnrollStudentRequest**](EnrollStudentRequest.md)|  | 

### Return type

[**Enrollment**](Enrollment.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAttendanceReport**
> AttendanceReport getAttendanceReport(id, from, to, classSectionId)

Date-ranged attendance register export

Roles: admin. Per-pupil counts over a date range. For a spreadsheet use the .csv variant.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = from_example; // String | 
final to = to_example; // String | 
final classSectionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getAttendanceReport(id, from, to, classSectionId);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAttendanceReport: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **from** | **String**|  | 
 **to** | **String**|  | 
 **classSectionId** | **String**|  | [optional] 

### Return type

[**AttendanceReport**](AttendanceReport.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAttendanceReportCsv**
> String getAttendanceReportCsv(id, from, to, classSectionId)

Attendance register export as a CSV file

Roles: admin. The same report as a download: one row per pupil, formula-safe, with a Content-Disposition filename.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = from_example; // String | 
final to = to_example; // String | 
final classSectionId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final result = api_instance.getAttendanceReportCsv(id, from, to, classSectionId);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->getAttendanceReportCsv: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **from** | **String**|  | 
 **to** | **String**|  | 
 **classSectionId** | **String**|  | [optional] 

### Return type

**String**

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importStudents**
> ImportStudents201Response importStudents(id, importStudentsRequest)

Bulk-create students and enrol them in this section

Roles: admin. Each row becomes a new student (there is no matching against existing people); build the array from a CSV client-side, one row per pupil.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final importStudentsRequest = ImportStudentsRequest(); // ImportStudentsRequest | 

try {
    final result = api_instance.importStudents(id, importStudentsRequest);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->importStudents: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **importStudentsRequest** | [**ImportStudentsRequest**](ImportStudentsRequest.md)|  | 

### Return type

[**ImportStudents201Response**](ImportStudents201Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **linkGuardian**
> linkGuardian(id, linkGuardianRequest)

Link a guardian to a student

Roles: admin. The link is many-to-many and is the join every guardian permission hangs off.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final linkGuardianRequest = LinkGuardianRequest(); // LinkGuardianRequest | 

try {
    api_instance.linkGuardian(id, linkGuardianRequest);
} catch (e) {
    print('Exception when calling AdminApi->linkGuardian: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **linkGuardianRequest** | [**LinkGuardianRequest**](LinkGuardianRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listAuditLog**
> ListAuditLog200Response listAuditLog(studentId, actorId, from, limit, cursor)

Who read or changed which student record

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final studentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final actorId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final from = from_example; // String | 
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listAuditLog(studentId, actorId, from, limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->listAuditLog: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **studentId** | **String**|  | [optional] 
 **actorId** | **String**|  | [optional] 
 **from** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **cursor** | **String**|  | [optional] 

### Return type

[**ListAuditLog200Response**](ListAuditLog200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listPeople**
> PersonPage listPeople(role, q, limit, cursor)

Staff and guardians directory

Roles: admin. (Students are under /students.)

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final role = role_example; // String | 
final q = q_example; // String | 
final limit = 56; // int | 
final cursor = cursor_example; // String | 

try {
    final result = api_instance.listPeople(role, q, limit, cursor);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->listPeople: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **role** | **String**|  | [optional] 
 **q** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] [default to 50]
 **cursor** | **String**|  | [optional] 

### Return type

[**PersonPage**](PersonPage.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **setTimetable**
> GetTimetable200Response setTimetable(id, periodInput)

Replace the section's timetable

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final periodInput = [List<PeriodInput>()]; // List<PeriodInput> | 

try {
    final result = api_instance.setTimetable(id, periodInput);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->setTimetable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **periodInput** | [**List<PeriodInput>**](PeriodInput.md)|  | 

### Return type

[**GetTimetable200Response**](GetTimetable200Response.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateClassSection**
> ClassSection updateClassSection(id, classSectionInput)

Edit a section, e.g. change the homeroom teacher

Roles: admin.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final classSectionInput = ClassSectionInput(); // ClassSectionInput | 

try {
    final result = api_instance.updateClassSection(id, classSectionInput);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->updateClassSection: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **classSectionInput** | [**ClassSectionInput**](ClassSectionInput.md)|  | 

### Return type

[**ClassSection**](ClassSection.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateTerm**
> Term updateTerm(id, termInput)

Edit a term, or close it

Roles: admin. `closed: true` locks teacher edits for every section in the term.

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final termInput = TermInput(); // TermInput | 

try {
    final result = api_instance.updateTerm(id, termInput);
    print(result);
} catch (e) {
    print('Exception when calling AdminApi->updateTerm: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **termInput** | [**TermInput**](TermInput.md)|  | 

### Return type

[**Term**](Term.md)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/problem+json, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **withdrawStudent**
> withdrawStudent(id)

Withdraw a student from a section

Roles: admin. **Soft delete**: sets status to `withdrawn`; the row and its history stay for transcripts (the database has no DELETE policy).

### Example
```dart
import 'package:homeroom_api/api.dart';
// TODO Configure HTTP Bearer authorization: bearer
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearer').setAccessToken(yourTokenGeneratorFunction);

final api_instance = AdminApi();
final id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api_instance.withdrawStudent(id);
} catch (e) {
    print('Exception when calling AdminApi->withdrawStudent: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearer](../README.md#bearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/problem+json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


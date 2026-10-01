//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/admin_api.dart';
part 'api/announcements_api.dart';
part 'api/attendance_api.dart';
part 'api/auth_api.dart';
part 'api/classes_api.dart';
part 'api/conferences_api.dart';
part 'api/fees_api.dart';
part 'api/gradebook_api.dart';
part 'api/homework_api.dart';
part 'api/me_api.dart';
part 'api/messaging_api.dart';
part 'api/onboarding_api.dart';
part 'api/overview_api.dart';
part 'api/students_api.dart';

part 'model/admin_overview.dart';
part 'model/admin_overview_registers_unmarked_inner.dart';
part 'model/announcement.dart';
part 'model/announcement_input.dart';
part 'model/announcement_page.dart';
part 'model/announcement_response.dart';
part 'model/assessment.dart';
part 'model/assessment_input.dart';
part 'model/attendance_record.dart';
part 'model/attendance_report.dart';
part 'model/attendance_report_rows_inner.dart';
part 'model/attendance_status.dart';
part 'model/audit_entry.dart';
part 'model/batch_result.dart';
part 'model/batch_result_results_inner.dart';
part 'model/book_conference_slot_request.dart';
part 'model/class_section.dart';
part 'model/class_section_detail.dart';
part 'model/class_section_detail_all_of_teachers.dart';
part 'model/class_section_input.dart';
part 'model/complete_sandbox_payment_request.dart';
part 'model/conference_slot.dart';
part 'model/contact.dart';
part 'model/correct_attendance_record_request.dart';
part 'model/create_conference_slots_request.dart';
part 'model/create_fee_item_request.dart';
part 'model/create_grade_band_request.dart';
part 'model/create_invoices_request.dart';
part 'model/create_school_request.dart';
part 'model/create_school_request_admin.dart';
part 'model/enroll_student_request.dart';
part 'model/enrollment.dart';
part 'model/fee_item.dart';
part 'model/get_announcement_responses200_response.dart';
part 'model/get_report_comments200_response.dart';
part 'model/get_student_attendance200_response.dart';
part 'model/get_student_grades200_response.dart';
part 'model/get_student_homework200_response.dart';
part 'model/get_student_invoices200_response.dart';
part 'model/get_teacher_today200_response.dart';
part 'model/get_timetable200_response.dart';
part 'model/grade.dart';
part 'model/grade_band.dart';
part 'model/gradebook.dart';
part 'model/gradebook_rows_inner.dart';
part 'model/guardian_link.dart';
part 'model/homework.dart';
part 'model/homework_input.dart';
part 'model/import_students201_response.dart';
part 'model/import_students_request.dart';
part 'model/import_students_request_students_inner.dart';
part 'model/invoice.dart';
part 'model/invoice_page.dart';
part 'model/link_guardian_request.dart';
part 'model/list_audit_log200_response.dart';
part 'model/list_class_sections200_response.dart';
part 'model/list_conference_slots200_response.dart';
part 'model/list_fee_items200_response.dart';
part 'model/list_grade_bands200_response.dart';
part 'model/list_grades200_response.dart';
part 'model/list_messages200_response.dart';
part 'model/list_payments200_response.dart';
part 'model/list_terms200_response.dart';
part 'model/list_threads200_response.dart';
part 'model/mark_notifications_read_request.dart';
part 'model/me.dart';
part 'model/me_school.dart';
part 'model/message.dart';
part 'model/notification.dart';
part 'model/notification_page.dart';
part 'model/notification_prefs.dart';
part 'model/open_thread_request.dart';
part 'model/payment.dart';
part 'model/payment_start.dart';
part 'model/payment_start_next.dart';
part 'model/payment_status.dart';
part 'model/period.dart';
part 'model/period_input.dart';
part 'model/person.dart';
part 'model/person_assignments_inner.dart';
part 'model/person_contact.dart';
part 'model/person_input.dart';
part 'model/person_page.dart';
part 'model/problem.dart';
part 'model/problem_errors_inner.dart';
part 'model/record_manual_payment_request.dart';
part 'model/refresh_session_request.dart';
part 'model/register.dart';
part 'model/register_entries_inner.dart';
part 'model/register_push_token_request.dart';
part 'model/register_submission.dart';
part 'model/register_submission_entries_inner.dart';
part 'model/report_comment.dart';
part 'model/report_comment_sheet.dart';
part 'model/report_comment_sheet_items_inner.dart';
part 'model/request_otp_request.dart';
part 'model/request_password_reset_request.dart';
part 'model/reset_password_request.dart';
part 'model/respond_to_announcement_request.dart';
part 'model/role.dart';
part 'model/school.dart';
part 'model/select_session_person_request.dart';
part 'model/selection_required.dart';
part 'model/selection_required_choices_inner.dart';
part 'model/send_message_request.dart';
part 'model/session.dart';
part 'model/sign_in_result.dart';
part 'model/sign_in_with_password_request.dart';
part 'model/start_payment_request.dart';
part 'model/student.dart';
part 'model/student_detail.dart';
part 'model/student_page.dart';
part 'model/student_ref.dart';
part 'model/student_ref_class_section.dart';
part 'model/student_summary.dart';
part 'model/student_summary_attendance.dart';
part 'model/student_summary_grades_inner.dart';
part 'model/subject_grades.dart';
part 'model/subject_grades_assessments_inner.dart';
part 'model/term.dart';
part 'model/term_input.dart';
part 'model/thread.dart';
part 'model/today_period.dart';
part 'model/update_fee_item_request.dart';
part 'model/update_grade_band_request.dart';
part 'model/update_my_contact_request.dart';
part 'model/upsert_grades_request.dart';
part 'model/upsert_grades_request_grades_inner.dart';
part 'model/upsert_report_comments_request.dart';
part 'model/upsert_report_comments_request_comments_inner.dart';
part 'model/verify_otp_request.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';


import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../models/doctor_model.dart';
import '../models/specialization_model.dart';

class DoctorRepository {
  final SupabaseClient? _clientOverride;

  DoctorRepository({SupabaseClient? client}) : _clientOverride = client;

  SupabaseClient get _client => _clientOverride ?? SupabaseConfig.client;

  Future<List<SpecializationModel>> getSpecializations() async {
    final response = await _client
        .from('specializations')
        .select()
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map(
          (json) => SpecializationModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<DoctorModel>> getDoctors() async {
    final response = await _client
        .from('doctors')
        .select()
        .eq('is_verified', true)
        .order('rating', ascending: false);

    return (response as List)
        .map(
          (json) => DoctorModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<DoctorModel?> getDoctorById(String doctorId) async {
    final response = await _client
        .from('doctors')
        .select()
        .eq('id', doctorId)
        .eq('is_verified', true)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return DoctorModel.fromJson(response);
  }

  Future<List<DoctorModel>> searchDoctors(
    String query, {
    String? specializationId,
  }) async {
    var queryBuilder = _client
        .from('doctors')
        .select()
        .eq('is_verified', true)
        .ilike('name', '%$query%');

    if (specializationId != null && specializationId.isNotEmpty) {
      queryBuilder = queryBuilder.eq('specialization_id', specializationId);
    }

    final response = await queryBuilder.order('rating', ascending: false);

    return (response as List)
        .map(
          (json) => DoctorModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<DoctorModel>> getDoctorsBySpecialization(
    String specializationId,
  ) async {
    final response = await _client
        .from('doctors')
        .select()
        .eq('specialization_id', specializationId)
        .eq('is_verified', true)
        .order('rating', ascending: false);

    return (response as List)
        .map(
          (json) => DoctorModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}

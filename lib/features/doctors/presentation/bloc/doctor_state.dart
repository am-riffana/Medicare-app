import '../../data/models/doctor_model.dart';
import '../../data/models/specialization_model.dart';

abstract class DoctorState {
  const DoctorState();
}

class DoctorInitial extends DoctorState {
  const DoctorInitial();
}

class DoctorLoading extends DoctorState {
  const DoctorLoading();
}

class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;
  final List<SpecializationModel> specializations;
  final String? selectedSpecializationId;
  final String? searchQuery;

  const DoctorLoaded({
    required this.doctors,
    required this.specializations,
    this.selectedSpecializationId,
    this.searchQuery,
  });

  bool get hasActiveFilter =>
      (selectedSpecializationId != null && selectedSpecializationId!.isNotEmpty) ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

class DoctorError extends DoctorState {
  final String message;

  const DoctorError(this.message);
}
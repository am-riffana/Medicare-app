
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

/// Existing state for doctor discovery
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
      (selectedSpecializationId != null &&
          selectedSpecializationId!.isNotEmpty) ||
      (searchQuery != null && searchQuery!.isNotEmpty);
}

/// Loading state for a single doctor's profile
class DoctorProfileLoading extends DoctorState {
  const DoctorProfileLoading();
}

/// Successfully loaded a single doctor's profile
class DoctorProfileLoaded extends DoctorState {
  final DoctorModel doctor;

  const DoctorProfileLoaded(this.doctor);
}

/// Doctor profile not found
class DoctorProfileNotFound extends DoctorState {
  const DoctorProfileNotFound();
}

class DoctorError extends DoctorState {
  final String message;

  const DoctorError(this.message);
}

/// Error while loading a doctor's profile
class DoctorProfileError extends DoctorState {
  final String message;

  const DoctorProfileError(this.message);
}

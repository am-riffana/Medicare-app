abstract class DoctorEvent {
  const DoctorEvent();
}

/// Load doctors and specializations
class LoadDoctors extends DoctorEvent {
  const LoadDoctors();
}

/// Search doctors by name
class SearchDoctors extends DoctorEvent {
  final String query;

  const SearchDoctors(this.query);
}

/// Filter doctors by specialization
class FilterDoctorsBySpecialization extends DoctorEvent {
  final String specializationId;

  const FilterDoctorsBySpecialization(this.specializationId);
}

/// Clear doctor search/filter
class ClearDoctorFilter extends DoctorEvent {
  const ClearDoctorFilter();
}
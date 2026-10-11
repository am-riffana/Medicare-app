import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/doctor_model.dart';
import '../../data/models/specialization_model.dart';
import '../../data/repositories/doctor_repository.dart';

import 'doctor_event.dart';
import 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final DoctorRepository repository;

  DoctorBloc({
    required this.repository,
  }) : super(const DoctorInitial()) {
    on<LoadDoctors>(_onLoadDoctors);
    on<SearchDoctors>(_onSearchDoctors);
    on<FilterDoctorsBySpecialization>(
      _onFilterDoctorsBySpecialization,
    );
    on<ClearDoctorFilter>(_onClearDoctorFilter);
  }

  List<DoctorModel> _allDoctors = [];
  List<SpecializationModel> _allSpecializations = [];

  List<DoctorModel> get allDoctors => List.unmodifiable(_allDoctors);
  List<SpecializationModel> get allSpecializations =>
      List.unmodifiable(_allSpecializations);

  Future<void> _onLoadDoctors(
    LoadDoctors event,
    Emitter<DoctorState> emit,
  ) async {
    emit(const DoctorLoading());

    try {
      final results = await Future.wait([
        repository.getDoctors(),
        repository.getSpecializations(),
      ]);

      final doctors = results[0] as List<DoctorModel>;
      final specializations = results[1] as List<SpecializationModel>;

      _allDoctors = doctors;
      _allSpecializations = specializations;

      emit(
        DoctorLoaded(
          doctors: doctors,
          specializations: specializations,
        ),
      );
    } catch (e) {
      emit(
        const DoctorError(
          'Failed to load doctors and specializations. Please check your connection and try again.',
        ),
      );
    }
  }

  Future<void> _onSearchDoctors(
    SearchDoctors event,
    Emitter<DoctorState> emit,
  ) async {
    final query = event.query.trim();
    final currentState = state;
    final String? activeSpecializationId = currentState is DoctorLoaded
        ? currentState.selectedSpecializationId
        : null;

    if (query.isEmpty) {
      if (activeSpecializationId != null) {
        try {
          final doctors = await repository.getDoctorsBySpecialization(
            activeSpecializationId,
          );
          emit(
            DoctorLoaded(
              doctors: doctors,
              specializations: List.from(_allSpecializations),
              selectedSpecializationId: activeSpecializationId,
              searchQuery: '',
            ),
          );
        } catch (_) {
          emit(
            DoctorLoaded(
              doctors: _allDoctors
                  .where((d) => d.specializationId == activeSpecializationId)
                  .toList(),
              specializations: List.from(_allSpecializations),
              selectedSpecializationId: activeSpecializationId,
              searchQuery: '',
            ),
          );
        }
      } else {
        emit(
          DoctorLoaded(
            doctors: List.from(_allDoctors),
            specializations: List.from(_allSpecializations),
            selectedSpecializationId: null,
            searchQuery: '',
          ),
        );
      }
      return;
    }

    emit(const DoctorLoading());

    try {
      final doctors = await repository.searchDoctors(
        query,
        specializationId: activeSpecializationId,
      );

      emit(
        DoctorLoaded(
          doctors: doctors,
          specializations: List.from(_allSpecializations),
          selectedSpecializationId: activeSpecializationId,
          searchQuery: query,
        ),
      );
    } catch (e) {
      emit(
        const DoctorError(
          'Unable to search doctors. Please try again.',
        ),
      );
    }
  }

  Future<void> _onFilterDoctorsBySpecialization(
    FilterDoctorsBySpecialization event,
    Emitter<DoctorState> emit,
  ) async {
    final currentState = state;
    final bool isAlreadySelected = currentState is DoctorLoaded &&
        currentState.selectedSpecializationId == event.specializationId;

    // Toggle filter: tapping active category deselects it
    if (isAlreadySelected) {
      emit(
        DoctorLoaded(
          doctors: List.from(_allDoctors),
          specializations: List.from(_allSpecializations),
          selectedSpecializationId: null,
          searchQuery: null,
        ),
      );
      return;
    }

    emit(const DoctorLoading());

    try {
      final doctors = await repository.getDoctorsBySpecialization(
        event.specializationId,
      );

      emit(
        DoctorLoaded(
          doctors: doctors,
          specializations: List.from(_allSpecializations),
          selectedSpecializationId: event.specializationId,
          searchQuery: null,
        ),
      );
    } catch (e) {
      emit(
        const DoctorError(
          'Unable to filter doctors by specialization. Please try again.',
        ),
      );
    }
  }

  void _onClearDoctorFilter(
    ClearDoctorFilter event,
    Emitter<DoctorState> emit,
  ) {
    emit(
      DoctorLoaded(
        doctors: List.from(_allDoctors),
        specializations: List.from(_allSpecializations),
        selectedSpecializationId: null,
        searchQuery: null,
      ),
    );
  }
}
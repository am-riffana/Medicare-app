import 'package:flutter_test/flutter_test.dart';
import 'package:medicare/features/doctors/data/models/doctor_model.dart';
import 'package:medicare/features/doctors/data/models/specialization_model.dart';
import 'package:medicare/features/doctors/data/repositories/doctor_repository.dart';
import 'package:medicare/features/doctors/presentation/bloc/doctor_bloc.dart';
import 'package:medicare/features/doctors/presentation/bloc/doctor_event.dart';
import 'package:medicare/features/doctors/presentation/bloc/doctor_state.dart';

class MockDoctorRepository implements DoctorRepository {
  List<DoctorModel> mockDoctors = [];
  List<SpecializationModel> mockSpecializations = [];
  bool shouldThrow = false;
  String errorMessage = 'Database error';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<SpecializationModel>> getSpecializations() async {
    if (shouldThrow) throw Exception(errorMessage);
    return mockSpecializations;
  }

  @override
  Future<List<DoctorModel>> getDoctors() async {
    if (shouldThrow) throw Exception(errorMessage);
    return mockDoctors;
  }

  @override
  Future<List<DoctorModel>> searchDoctors(
    String query, {
    String? specializationId,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return mockDoctors.where((d) {
      final matchesQuery =
          d.name.toLowerCase().contains(query.toLowerCase());
      final matchesSpec = specializationId == null ||
          specializationId.isEmpty ||
          d.specializationId == specializationId;
      return matchesQuery && matchesSpec;
    }).toList();
  }

  @override
  Future<List<DoctorModel>> getDoctorsBySpecialization(
    String specializationId,
  ) async {
    if (shouldThrow) throw Exception(errorMessage);
    return mockDoctors
        .where((d) => d.specializationId == specializationId)
        .toList();
  }
}

void main() {
  group('DoctorBloc Unit Tests', () {
    late MockDoctorRepository mockRepo;
    late DoctorBloc doctorBloc;

    final testSpecializations = [
      const SpecializationModel(
        id: 'spec-1',
        name: 'Cardiology',
        isActive: true,
      ),
      const SpecializationModel(
        id: 'spec-2',
        name: 'Neurology',
        isActive: true,
      ),
    ];

    final testDoctors = [
      const DoctorModel(
        id: 'doc-1',
        userId: 'u1',
        specializationId: 'spec-1',
        name: 'Dr. Jane Smith',
        qualification: 'MD, FACC',
        experienceYears: 12,
        consultationFee: 800.0,
        rating: 4.9,
        totalReviews: 120,
        isAvailable: true,
        isVerified: true,
      ),
      const DoctorModel(
        id: 'doc-2',
        userId: 'u2',
        specializationId: 'spec-2',
        name: 'Dr. John Doe',
        qualification: 'MD, DM',
        experienceYears: 8,
        consultationFee: 650.0,
        rating: 4.7,
        totalReviews: 85,
        isAvailable: true,
        isVerified: true,
      ),
    ];

    setUp(() {
      mockRepo = MockDoctorRepository();
      mockRepo.mockDoctors = List.from(testDoctors);
      mockRepo.mockSpecializations = List.from(testSpecializations);
      doctorBloc = DoctorBloc(repository: mockRepo);
    });

    tearDown(() {
      doctorBloc.close();
    });

    test('initial state is DoctorInitial', () {
      expect(doctorBloc.state, isA<DoctorInitial>());
    });

    group('LoadDoctors', () {
      test('emits [DoctorLoading, DoctorLoaded] on success', () async {
        final expected = [
          isA<DoctorLoading>(),
          isA<DoctorLoaded>().having(
            (s) => s.doctors.length,
            'doctors length',
            2,
          ).having(
            (s) => s.specializations.length,
            'specializations length',
            2,
          ),
        ];

        expectLater(doctorBloc.stream, emitsInOrder(expected));
        doctorBloc.add(const LoadDoctors());
      });

      test('emits [DoctorLoading, DoctorError] on repository failure', () async {
        mockRepo.shouldThrow = true;

        final expected = [
          isA<DoctorLoading>(),
          isA<DoctorError>(),
        ];

        expectLater(doctorBloc.stream, emitsInOrder(expected));
        doctorBloc.add(const LoadDoctors());
      });
    });

    group('SearchDoctors', () {
      test('filters doctors by name query', () async {
        // First load doctors
        doctorBloc.add(const LoadDoctors());
        await pumpEventQueue();

        expectLater(
          doctorBloc.stream,
          emitsInOrder([
            isA<DoctorLoading>(),
            isA<DoctorLoaded>().having(
              (s) => s.doctors.first.name,
              'name',
              'Dr. Jane Smith',
            ),
          ]),
        );

        doctorBloc.add(const SearchDoctors('Jane'));
      });

      test('empty query restores all doctors', () async {
        doctorBloc.add(const LoadDoctors());
        await pumpEventQueue();

        doctorBloc.add(const SearchDoctors('Jane'));
        await pumpEventQueue();

        expectLater(
          doctorBloc.stream,
          emits(isA<DoctorLoaded>().having(
            (s) => s.doctors.length,
            'doctors length',
            2,
          )),
        );

        doctorBloc.add(const SearchDoctors(''));
      });
    });

    group('FilterDoctorsBySpecialization', () {
      test('filters doctors by specialization id', () async {
        doctorBloc.add(const LoadDoctors());
        await pumpEventQueue();

        expectLater(
          doctorBloc.stream,
          emitsInOrder([
            isA<DoctorLoading>(),
            isA<DoctorLoaded>()
                .having((s) => s.doctors.length, 'doctors count', 1)
                .having(
                  (s) => s.selectedSpecializationId,
                  'selected specialization',
                  'spec-2',
                ),
          ]),
        );

        doctorBloc.add(const FilterDoctorsBySpecialization('spec-2'));
      });

      test('tapping selected specialization toggles filter off', () async {
        doctorBloc.add(const LoadDoctors());
        await pumpEventQueue();

        doctorBloc.add(const FilterDoctorsBySpecialization('spec-1'));
        await pumpEventQueue();

        // Tapping again should toggle off
        expectLater(
          doctorBloc.stream,
          emits(isA<DoctorLoaded>()
              .having((s) => s.doctors.length, 'doctors count', 2)
              .having(
                (s) => s.selectedSpecializationId,
                'selected specialization',
                isNull,
              )),
        );

        doctorBloc.add(const FilterDoctorsBySpecialization('spec-1'));
      });
    });

    group('ClearDoctorFilter', () {
      test('resets filter and returns full doctor list', () async {
        doctorBloc.add(const LoadDoctors());
        await pumpEventQueue();

        doctorBloc.add(const FilterDoctorsBySpecialization('spec-1'));
        await pumpEventQueue();

        expectLater(
          doctorBloc.stream,
          emits(isA<DoctorLoaded>()
              .having((s) => s.doctors.length, 'count', 2)
              .having((s) => s.selectedSpecializationId, 'spec id', isNull)),
        );

        doctorBloc.add(const ClearDoctorFilter());
      });
    });
  });
}

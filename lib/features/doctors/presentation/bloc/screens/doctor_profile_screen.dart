
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicare/features/doctors/data/models/doctor_model.dart';
import 'package:medicare/features/doctors/data/repositories/doctor_repository.dart';
import 'package:medicare/features/doctors/presentation/bloc/doctor_bloc.dart';
import 'package:medicare/features/doctors/presentation/bloc/doctor_event.dart';
import 'package:medicare/features/doctors/presentation/bloc/doctor_state.dart';



class DoctorProfileScreen extends StatelessWidget {
  final String doctorId;
  final String? specializationName;

  const DoctorProfileScreen({
    super.key,
    required this.doctorId,
    this.specializationName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorBloc(
        repository: DoctorRepository(),
      )..add(LoadDoctorProfile(doctorId)),
      child: _DoctorProfileView(
        doctorId: doctorId,
        specializationName: specializationName,
      ),
    );
  }
}

class _DoctorProfileView extends StatelessWidget {
  final String doctorId;
  final String? specializationName;

  const _DoctorProfileView({
    required this.doctorId,
    this.specializationName,
  });

  static const Color primary = Color(0xFF1877F2);
  static const Color background = Color(0xFFF6F8FC);
  static const Color textPrimary = Color(0xFF172B4D);
  static const Color textSecondary = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Doctor Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (state is DoctorProfileNotFound) {
            return _buildMessage(
              icon: Icons.person_search_rounded,
              title: 'Doctor not found',
              message:
                  'This doctor may no longer be available or could not be found.',
            );
          }

          if (state is DoctorProfileError) {
            return _buildMessage(
              icon: Icons.wifi_off_rounded,
              title: 'Unable to load profile',
              message: state.message,
              onRetry: () {
                context.read<DoctorBloc>().add(
                      LoadDoctorProfile(doctorId),
                    );
              },
            );
          }

          if (state is DoctorProfileLoaded) {
            return _buildProfile(context, state.doctor);
          }

          if (state is DoctorError) {
            return _buildMessage(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              message: state.message,
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: primary),
          );
        },
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    DoctorModel doctor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor profile header.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildAvatar(doctor, radius: 48),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        doctor.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    if (doctor.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified_rounded,
                        color: primary,
                        size: 21,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  specializationName ?? 'Medical Specialist',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (doctor.qualification != null &&
                    doctor.qualification!.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    doctor.qualification!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _buildStat(
                        icon: Icons.work_outline_rounded,
                        value: '${doctor.experienceYears}',
                        label: 'Years exp.',
                      ),
                    ),
                    _buildDivider(),
                    Expanded(
                      child: _buildStat(
                        icon: Icons.star_rounded,
                        value: doctor.rating.toStringAsFixed(1),
                        label: '${doctor.totalReviews} reviews',
                        iconColor: const Color(0xFFFFB020),
                      ),
                    ),
                    _buildDivider(),
                    Expanded(
                      child: _buildStat(
                        icon: doctor.isAvailable
                            ? Icons.check_circle_outline_rounded
                            : Icons.schedule_rounded,
                        value: doctor.isAvailable
                            ? 'Available'
                            : 'Unavailable',
                        label: 'Status',
                        iconColor: doctor.isAvailable
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Consultation fee.
          _buildSection(
            title: 'Consultation Fee',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.currency_rupee_rounded,
                    color: primary,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${doctor.consultationFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Consultation charge',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // About section.
          _buildSection(
            title: 'About Doctor',
            child: Text(
              doctor.about != null &&
                      doctor.about!.trim().isNotEmpty
                  ? doctor.about!
                  : 'No biography has been added yet.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Clinic information.
          _buildSection(
            title: 'Clinic Information',
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.local_hospital_outlined,
                  title: 'Clinic Name',
                  value: _displayValue(doctor.clinicName),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  title: 'Clinic Address',
                  value: _displayValue(doctor.clinicAddress),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  title: 'Contact Number',
                  value: _displayValue(doctor.phone),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appointment booking will be implemented in Phase 5.
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: doctor.isAvailable
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Appointment booking will be available in Phase 5.',
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.calendar_month_rounded),
              label: Text(
                doctor.isAvailable
                    ? 'Book Appointment'
                    : 'Currently Unavailable',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    DoctorModel doctor, {
    required double radius,
  }) {
    final imageUrl = doctor.profileImage?.trim() ?? '';

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEAF2FF),
      backgroundImage: imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : null,
      onBackgroundImageError:
          imageUrl.isNotEmpty ? (_, _) {} : null,
      child: imageUrl.isEmpty
          ? Text(
              doctor.name.trim().isNotEmpty
                  ? doctor.name.trim()[0].toUpperCase()
                  : 'D',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w800,
                fontSize: radius * 0.7,
              ),
            )
          : null,
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    Color iconColor = primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 21),
          const SizedBox(height: 7),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFE8ECF3),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primary, size: 54),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textSecondary,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not provided';
    }

    return value.trim();
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/auth/auth_bloc.dart';

import '../../../../bloc/auth/auth_event.dart';

import '../../../../bloc/auth/auth_state.dart';

import '../../../../core/constants/app_colors.dart';

import '../../../../core/constants/app_constants.dart';

import '../../../../core/constants/app_strings.dart';

import '../../../../core/widgets/app_button.dart';

import '../../../../core/widgets/empty_state_view.dart';

import '../../../../core/widgets/error_view.dart';

import '../../../../data/models/user_model.dart';

import '../../../../features/auth/presentation/screens/login_screen.dart';

import '../../../../features/doctors/data/models/doctor_model.dart';

import '../../../../features/doctors/data/repositories/doctor_repository.dart';

import '../../../../features/doctors/presentation/bloc/doctor_bloc.dart';

import '../../../../features/doctors/presentation/bloc/doctor_event.dart';

import '../../../../features/doctors/presentation/bloc/doctor_state.dart';
import '../../../../features/doctors/presentation/bloc/screens/doctor_profile_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final UserModel? user;

  const PatientHomeScreen({super.key, this.user});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  IconData _getSpecializationIcon(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('cardio')) return Icons.favorite_rounded;

    if (lower.contains('neuro')) return Icons.psychology_rounded;

    if (lower.contains('pediatric')) return Icons.child_care_rounded;

    if (lower.contains('dental') || lower.contains('dentist')) {
      return Icons.health_and_safety_rounded;
    }

    if (lower.contains('ortho')) return Icons.accessibility_new_rounded;

    if (lower.contains('derma')) return Icons.spa_rounded;

    if (lower.contains('eye') || lower.contains('ophthal')) {
      return Icons.visibility_rounded;
    }

    if (lower.contains('ent') || lower.contains('throat')) {
      return Icons.hearing_rounded;
    }

    return Icons.medical_services_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DoctorBloc(repository: DoctorRepository())..add(const LoadDoctors()),

      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),

                backgroundColor: AppColors.error,

                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is Unauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => LoginScreen(message: state.message),
              ),

              (route) => false,
            );
          }
        },

        builder: (context, authState) {
          final UserModel? currentUser = authState is Authenticated
              ? authState.user
              : widget.user;

          final bool isAuthLoading = authState is AuthLoading;

          final String displayName = currentUser?.name.isNotEmpty == true
              ? currentUser!.name
              : 'Patient';

          final String displayEmail =
              currentUser?.email ?? 'patient@medicare.com';

          final String role = currentUser?.role.toUpperCase() ?? 'PATIENT';

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,

              title: Row(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Container(
                    width: 34,

                    height: 34,

                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,

                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),

                    child: const Icon(
                      Icons.local_hospital_rounded,

                      color: AppColors.primary,

                      size: 22,
                    ),
                  ),

                  const SizedBox(width: AppConstants.spacing12),

                  const Text(
                    AppStrings.appName,

                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  ),
                ],
              ),

              actions: [
                IconButton(
                  tooltip: 'Sign Out',

                  icon: const Icon(
                    Icons.logout_rounded,

                    color: AppColors.error,
                  ),

                  onPressed: isAuthLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(const LogoutRequested());
                        },
                ),
              ],
            ),

            body: RefreshIndicator(
              onRefresh: () async {
                _searchController.clear();

                context.read<DoctorBloc>().add(const LoadDoctors());
              },

              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),

                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),

                      padding: const EdgeInsets.all(AppConstants.spacing24),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // -------------------------------------------------------

                          // GREETING

                          // -------------------------------------------------------
                          Text(
                            'Welcome, $displayName',

                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),

                          const SizedBox(height: AppConstants.spacing4),

                          Text(
                            'Find the right doctor for your health',

                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.textSecondaryLight),
                          ),

                          const SizedBox(height: AppConstants.spacing24),

                          // -------------------------------------------------------

                          // SEARCH BAR

                          // -------------------------------------------------------
                          TextField(
                            controller: _searchController,

                            textInputAction: TextInputAction.search,

                            onSubmitted: (value) {
                              context.read<DoctorBloc>().add(
                                SearchDoctors(value),
                              );
                            },

                            onChanged: (value) {
                              context.read<DoctorBloc>().add(
                                SearchDoctors(value),
                              );

                              setState(() {});
                            },

                            decoration: InputDecoration(
                              hintText: 'Search doctors by name...',

                              prefixIcon: const Icon(
                                Icons.search_rounded,

                                color: AppColors.primary,
                              ),

                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,

                                        color: AppColors.textMutedLight,

                                        size: 20,
                                      ),

                                      onPressed: () {
                                        _searchController.clear();

                                        context.read<DoctorBloc>().add(
                                          const SearchDoctors(''),
                                        );

                                        setState(() {});
                                      },
                                    )
                                  : const Icon(
                                      Icons.tune_rounded,

                                      color: AppColors.textMutedLight,
                                    ),

                              filled: true,

                              fillColor: Colors.white,

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium,
                                ),

                                borderSide: BorderSide.none,
                              ),

                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium,
                                ),

                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMedium,
                                ),

                                borderSide: const BorderSide(
                                  color: AppColors.primary,

                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacing28),

                          // -------------------------------------------------------

                          // SPECIALIZATIONS SECTION

                          // -------------------------------------------------------
                          BlocBuilder<DoctorBloc, DoctorState>(
                            builder: (context, doctorState) {
                              final String? selectedSpecId =
                                  doctorState is DoctorLoaded
                                  ? doctorState.selectedSpecializationId
                                  : null;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  Text(
                                    'Specializations',

                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),

                                  if (selectedSpecId != null)
                                    TextButton(
                                      onPressed: () {
                                        context.read<DoctorBloc>().add(
                                          const ClearDoctorFilter(),
                                        );
                                      },

                                      child: const Text('View All'),
                                    ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: AppConstants.spacing12),

                          BlocBuilder<DoctorBloc, DoctorState>(
                            builder: (context, doctorState) {
                              if (doctorState is DoctorLoading) {
                                return _buildSpecializationsSkeleton();
                              }

                              if (doctorState is DoctorLoaded) {
                                final specializations =
                                    doctorState.specializations;

                                if (specializations.isEmpty) {
                                  return Container(
                                    width: double.infinity,

                                    padding: const EdgeInsets.all(
                                      AppConstants.spacing16,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.white,

                                      borderRadius: BorderRadius.circular(
                                        AppConstants.radiusMedium,
                                      ),

                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),

                                    child: const Center(
                                      child: Text(
                                        'No specializations found.',

                                        style: TextStyle(
                                          color: AppColors.textSecondaryLight,

                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox(
                                  height: 108,

                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,

                                    itemCount: specializations.length,

                                    separatorBuilder: (_, _) => const SizedBox(
                                      width: AppConstants.spacing12,
                                    ),

                                    itemBuilder: (context, index) {
                                      final specialization =
                                          specializations[index];

                                      final bool isSelected =
                                          doctorState
                                              .selectedSpecializationId ==
                                          specialization.id;

                                      return GestureDetector(
                                        onTap: () {
                                          context.read<DoctorBloc>().add(
                                            FilterDoctorsBySpecialization(
                                              specialization.id,
                                            ),
                                          );
                                        },

                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),

                                          width: 114,

                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,

                                            vertical: AppConstants.spacing12,
                                          ),

                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.white,

                                            borderRadius: BorderRadius.circular(
                                              AppConstants.radiusMedium,
                                            ),

                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : const Color(0xFFE2E8F0),

                                              width: isSelected ? 1.5 : 1.0,
                                            ),

                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.primary
                                                          .withValues(
                                                            alpha: 0.25,
                                                          ),

                                                      blurRadius: 8,

                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ]
                                                : null,
                                          ),

                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,

                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),

                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white.withValues(
                                                          alpha: 0.2,
                                                        )
                                                      : AppColors.primaryLight,

                                                  shape: BoxShape.circle,
                                                ),

                                                child: Icon(
                                                  _getSpecializationIcon(
                                                    specialization.name,
                                                  ),

                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.primary,

                                                  size: 24,
                                                ),
                                              ),

                                              const SizedBox(height: 6),

                                              Text(
                                                specialization.name,

                                                textAlign: TextAlign.center,

                                                maxLines: 2,

                                                overflow: TextOverflow.ellipsis,

                                                style: TextStyle(
                                                  fontSize: 11,

                                                  fontWeight: FontWeight.w600,

                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors
                                                            .textPrimaryLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),

                          const SizedBox(height: AppConstants.spacing28),

                          // -------------------------------------------------------

                          // AVAILABLE DOCTORS SECTION

                          // -------------------------------------------------------
                          BlocBuilder<DoctorBloc, DoctorState>(
                            builder: (context, doctorState) {
                              final int doctorCount =
                                  doctorState is DoctorLoaded
                                  ? doctorState.doctors.length
                                  : 0;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Available Doctors',

                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),

                                      if (doctorState is DoctorLoaded) ...[
                                        const SizedBox(width: 8),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,

                                            vertical: 2,
                                          ),

                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,

                                            borderRadius: BorderRadius.circular(
                                              AppConstants.radiusFull,
                                            ),
                                          ),

                                          child: Text(
                                            '$doctorCount',

                                            style: const TextStyle(
                                              fontSize: 12,

                                              fontWeight: FontWeight.w700,

                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  if (doctorState is DoctorLoaded &&
                                      doctorState.hasActiveFilter)
                                    TextButton.icon(
                                      onPressed: () {
                                        _searchController.clear();

                                        context.read<DoctorBloc>().add(
                                          const ClearDoctorFilter(),
                                        );

                                        setState(() {});
                                      },

                                      icon: const Icon(
                                        Icons.close_rounded,

                                        size: 16,
                                      ),

                                      label: const Text('Reset'),
                                    ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: AppConstants.spacing12),

                          // Doctors State Container
                          BlocBuilder<DoctorBloc, DoctorState>(
                            builder: (context, doctorState) {
                              if (doctorState is DoctorLoading) {
                                return _buildDoctorsSkeleton();
                              }

                              if (doctorState is DoctorError) {
                                return AppErrorView(
                                  message: doctorState.message,

                                  onRetry: () {
                                    context.read<DoctorBloc>().add(
                                      const LoadDoctors(),
                                    );
                                  },
                                );
                              }

                              if (doctorState is DoctorLoaded) {
                                final doctors = doctorState.doctors;

                                final specializations =
                                    doctorState.specializations;

                                if (doctors.isEmpty) {
                                  if (_searchController.text.isNotEmpty) {
                                    return AppEmptyState(
                                      icon: Icons.person_search_rounded,

                                      title: 'No Doctors Found',

                                      description:
                                          'No doctors matched "${_searchController.text}". Try searching by another name or specialty.',

                                      actionText: 'Clear Search',

                                      onAction: () {
                                        _searchController.clear();

                                        context.read<DoctorBloc>().add(
                                          const SearchDoctors(''),
                                        );

                                        setState(() {});
                                      },
                                    );
                                  }

                                  if (doctorState.selectedSpecializationId !=
                                      null) {
                                    return AppEmptyState(
                                      icon: Icons.medical_services_outlined,

                                      title: 'No Doctors in This Department',

                                      description:
                                          'There are currently no verified doctors listed under this specialization.',

                                      actionText: 'Show All Doctors',

                                      onAction: () {
                                        context.read<DoctorBloc>().add(
                                          const ClearDoctorFilter(),
                                        );
                                      },
                                    );
                                  }

                                  return AppEmptyState(
                                    icon: Icons.local_hospital_rounded,

                                    title: 'No Doctors Available Yet',

                                    description:
                                        'New medical specialists will be onboarded soon. Tap refresh to check again.',

                                    actionText: 'Refresh',

                                    onAction: () {
                                      context.read<DoctorBloc>().add(
                                        const LoadDoctors(),
                                      );
                                    },
                                  );
                                }

                                return ListView.separated(
                                  shrinkWrap: true,

                                  physics: const NeverScrollableScrollPhysics(),

                                  itemCount: doctors.length,

                                  separatorBuilder: (_, _) => const SizedBox(
                                    height: AppConstants.spacing12,
                                  ),

                                  itemBuilder: (context, index) {
                                    final doctor = doctors[index];

                                    final specializationName =
                                        specializations
                                            .where(
                                              (s) =>
                                                  s.id ==
                                                  doctor.specializationId,
                                            )
                                            .firstOrNull
                                            ?.name ??
                                        'General Practitioner';

                                    return _buildDoctorCard(
                                      context: context,

                                      doctor: doctor,

                                      specializationName: specializationName,
                                    );
                                  },
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),

                          const SizedBox(height: AppConstants.spacing32),

                          // -------------------------------------------------------

                          // PATIENT PROFILE SUMMARY CARD

                          // -------------------------------------------------------
                          Card(
                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMedium,
                              ),

                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppConstants.spacing20,
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,

                                        backgroundColor: AppColors.primaryLight,

                                        child: Text(
                                          displayName.isNotEmpty
                                              ? displayName[0].toUpperCase()
                                              : 'P',

                                          style: const TextStyle(
                                            fontSize: 22,

                                            fontWeight: FontWeight.bold,

                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: AppConstants.spacing16,
                                      ),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              displayName,

                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),

                                            const SizedBox(height: 2),

                                            Text(
                                              displayEmail,

                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppColors
                                                        .textSecondaryLight,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppConstants.spacing12,

                                          vertical: AppConstants.spacing4,
                                        ),

                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,

                                          borderRadius: BorderRadius.circular(
                                            AppConstants.radiusFull,
                                          ),
                                        ),

                                        child: Text(
                                          role,

                                          style: const TextStyle(
                                            fontSize: 11,

                                            fontWeight: FontWeight.w700,

                                            color: AppColors.primaryDark,

                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (currentUser?.phone != null &&
                                      currentUser!.phone!.isNotEmpty) ...[
                                    const SizedBox(
                                      height: AppConstants.spacing16,
                                    ),

                                    const Divider(),

                                    const SizedBox(
                                      height: AppConstants.spacing12,
                                    ),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,

                                          size: 18,

                                          color: AppColors.textMutedLight,
                                        ),

                                        const SizedBox(
                                          width: AppConstants.spacing8,
                                        ),

                                        Text(
                                          currentUser.phone!,

                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacing24),

                          // -------------------------------------------------------

                          // SIGN OUT BUTTON

                          // -------------------------------------------------------
                          AppButton(
                            text: 'Sign Out',

                            onPressed: () {
                              context.read<AuthBloc>().add(
                                const LogoutRequested(),
                              );
                            },

                            isLoading: isAuthLoading,

                            isOutlined: true,

                            textColor: AppColors.error,

                            icon: const Icon(
                              Icons.logout_rounded,

                              color: AppColors.error,

                              size: AppConstants.iconSizeSmall,
                            ),
                          ),

                          const SizedBox(height: AppConstants.spacing20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard({
    required BuildContext context,

    required DoctorModel doctor,

    required String specializationName,
  }) {
    return Card(
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),

        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),

        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DoctorProfileScreen(
                doctorId: doctor.id,
                specializationName: specializationName,
              ),
            ),
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing16),

          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Doctor Avatar
                  CircleAvatar(
                    radius: 30,

                    backgroundColor: AppColors.primaryLight,

                    backgroundImage:
                        doctor.profileImage != null &&
                            doctor.profileImage!.isNotEmpty
                        ? NetworkImage(doctor.profileImage!)
                        : null,

                    child:
                        doctor.profileImage == null ||
                            doctor.profileImage!.isEmpty
                        ? Text(
                            doctor.name.isNotEmpty
                                ? doctor.name[0].toUpperCase()
                                : 'D',

                            style: const TextStyle(
                              fontSize: 22,

                              fontWeight: FontWeight.bold,

                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: AppConstants.spacing16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                doctor.name,

                                maxLines: 1,

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  fontSize: 16,

                                  fontWeight: FontWeight.w700,

                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ),

                            if (doctor.isVerified) ...[
                              const SizedBox(width: 4),

                              const Icon(
                                Icons.verified_rounded,

                                color: AppColors.primary,

                                size: 16,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 2),

                        Text(
                          specializationName,

                          style: const TextStyle(
                            fontSize: 13,

                            fontWeight: FontWeight.w600,

                            color: AppColors.primary,
                          ),
                        ),

                        if (doctor.qualification != null) ...[
                          const SizedBox(height: 2),

                          Text(
                            doctor.qualification!,

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: const TextStyle(
                              fontSize: 12,

                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Availability Dot
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,

                      vertical: 4,
                    ),

                    decoration: BoxDecoration(
                      color: doctor.isAvailable
                          ? AppColors.successLight
                          : Colors.grey.shade100,

                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusFull,
                      ),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Container(
                          width: 6,

                          height: 6,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,

                            color: doctor.isAvailable
                                ? AppColors.success
                                : Colors.grey,
                          ),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          doctor.isAvailable ? 'Available' : 'Offline',

                          style: TextStyle(
                            fontSize: 10,

                            fontWeight: FontWeight.w600,

                            color: doctor.isAvailable
                                ? AppColors.success
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacing12),

              const Divider(height: 1),

              const SizedBox(height: AppConstants.spacing12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,

                        color: Colors.amber,

                        size: 18,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        doctor.rating.toStringAsFixed(1),

                        style: const TextStyle(
                          fontWeight: FontWeight.w700,

                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(width: AppConstants.spacing12),

                      const Icon(
                        Icons.work_outline_rounded,

                        size: 15,

                        color: AppColors.textMutedLight,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${doctor.experienceYears} yrs exp',

                        style: const TextStyle(
                          fontSize: 12,

                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    '₹${doctor.consultationFee.toInt()}',

                    style: const TextStyle(
                      fontSize: 16,

                      fontWeight: FontWeight.w700,

                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecializationsSkeleton() {
    return SizedBox(
      height: 108,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        itemCount: 4,

        separatorBuilder: (_, _) =>
            const SizedBox(width: AppConstants.spacing12),

        itemBuilder: (context, index) {
          return Container(
            width: 114,

            padding: const EdgeInsets.all(AppConstants.spacing12),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),

              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  width: 38,

                  height: 38,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,

                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: 60,

                  height: 10,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,

                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorsSkeleton() {
    return ListView.separated(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      itemCount: 3,

      separatorBuilder: (_, _) =>
          const SizedBox(height: AppConstants.spacing12),

      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacing16),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),

            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),

          child: Row(
            children: [
              Container(
                width: 60,

                height: 60,

                decoration: BoxDecoration(
                  color: Colors.grey.shade200,

                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: AppConstants.spacing16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 140,

                      height: 14,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,

                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: 90,

                      height: 10,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,

                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: 60,

                      height: 10,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,

                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

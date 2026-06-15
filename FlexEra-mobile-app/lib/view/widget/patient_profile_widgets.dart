import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/assets/assets_manager.dart';
import '../../view_model/patient_profile_view_model.dart';
import '../../view_model/patients_view_model.dart';

class PatientProfileScaffold extends StatelessWidget {
  final Patient patient;

  const PatientProfileScaffold({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => PatientProfileViewModel(patient: patient),
      child: Scaffold(
        extendBody: true,
        backgroundColor:
            isDark ? const Color(0xFF171717) : AppColors.backgroundcolor1,
        body: PatientProfileBody(patient: patient),
      ),
    );
  }
}

class PatientProfileBody extends StatelessWidget {
  final Patient patient;

  const PatientProfileBody({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProfileViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const PatientProfileBackgroundImage(),
            const PatientProfileBackgroundBlob(),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: const PatientProfileHeader(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          PatientProfileAvatar(avatarPath: patient.avatarPath),
                          SizedBox(height: 30.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: PatientProfileContent(
                              patient: patient,
                              viewModel: viewModel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class PatientProfileBackgroundBlob extends StatelessWidget {
  const PatientProfileBackgroundBlob({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -150.h,
      right: 0,
      left: 0,
      child: Image.asset(
        "assets/images/paprofilewave.png",
        width: 500.w,
        height: 600.h,
        fit: BoxFit.contain,
      ),
    );
  }
}

class PatientProfileBackgroundImage extends StatelessWidget {
  const PatientProfileBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: -1.h,
      left: 100.w,
      child: Opacity(
        opacity: 0.99,
        child: Image.asset(
          isDark
              ? "assets/images/propaback.png"
              : "assets/images/propabacklight.png",
          width: 460.w,
          height: 400.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class PatientProfileContent extends StatelessWidget {
  final Patient patient;
  final PatientProfileViewModel viewModel;

  const PatientProfileContent({
    super.key,
    required this.patient,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Basic Details'),
        SizedBox(height: 12.h),
        Center(child: BasicDetailsCard(patient: patient)),
        SizedBox(height: 24.h),
        MedicalFileSection(onView: () => viewModel.onViewMedicalFile(context)),
        SizedBox(height: 24.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(title: 'Exercise Plan'),
            GestureDetector(
              onTap: () => viewModel.onAddExercise(context),
              child: Container(
                width: 101.w,
                height: 28.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9FBAF9), Color(0xFF590B8D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    '+  Add Exercise',
                    style: GoogleFonts.quicksand(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ExercisePlanContainer(
          child: ExercisePlanRow(
            exercisePlans: viewModel.exercisePlans,
            onEdit: (index) => viewModel.onEditExercise(context, index),
            onDelete: (index) => viewModel.onDeleteExercise(context, index),
          ),
        ),
        SizedBox(height: 40.h),
        Center(
          child: SaveChangesButton(
            onPressed: () => viewModel.onSaveChanges(context),
          ),
        ),
      ],
    );
  }
}

class PatientProfileHeader extends StatelessWidget {
  const PatientProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(top: 40.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 44.h,
              width: 44.w,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, 4.h),
                      blurRadius: 8),
                ],
                color: isDark ? Colors.white10 : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0.r),
                child: Image.asset('assets/icons/arrow.png',
                    color: isDark ? Colors.white : Colors.black),
              ),
            ),
          ),
          Text(
            "Patient Profile",
            style: GoogleFonts.quicksand(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(width: 45.w,),
        ],
      ),
    );
  }
}

class ExercisePlanRow extends StatelessWidget {
  final List<ExercisePlan> exercisePlans;
  final Function(int index) onEdit;
  final Function(int index) onDelete;

  const ExercisePlanRow({
    super.key,
    required this.exercisePlans,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    for (int i = 0; i < exercisePlans.length; i += 2) {
      List<Widget> rowChildren = [];
      rowChildren.add(
        Expanded(
          child: ExercisePlanCard(
            index: i,
            exercise: exercisePlans[i],
            onEdit: () => onEdit(i),
            onDelete: () => onDelete(i),
          ),
        ),
      );
      rowChildren.add(SizedBox(width: 12.w));
      if (i + 1 < exercisePlans.length) {
        rowChildren.add(
          Expanded(
            child: ExercisePlanCard(
              index: i + 1,
              exercise: exercisePlans[i + 1],
              onEdit: () => onEdit(i + 1),
              onDelete: () => onDelete(i + 1),
            ),
          ),
        );
      } else {
        rowChildren.add(const Expanded(child: SizedBox()));
      }
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      );
      if (i + 2 < exercisePlans.length) {
        rows.add(SizedBox(height: 12.h));
      }
    }
    return Column(children: rows);
  }
}

class ExercisePlanContainer extends StatelessWidget {
  final Widget child;

  const ExercisePlanContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class PatientProfileAvatar extends StatelessWidget {
  final String? avatarPath;
  final VoidCallback? onCameraTap;

  const PatientProfileAvatar({super.key, this.avatarPath, this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 154.w,
            height: 154.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF9FBAF9), Color(0xFF590B8D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.all(2.w),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF171717) : Colors.white,
              ),
              child: ClipOval(
                child: avatarPath != null
                    ? (avatarPath!.startsWith('http')
                        ? Image.network(
                            avatarPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          )
                        : Image.asset(
                            avatarPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          ))
                    : _buildPlaceholder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.lightpurplecolor,
      child: Icon(Icons.person, size: 50.w, color: AppColors.purplecolor),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: GoogleFonts.quicksand(
        fontSize: 23.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
        height: 1.0,
      ),
    );
  }
}

class BasicDetailsCard extends StatelessWidget {
  final Patient patient;

  const BasicDetailsCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 318.w,
      height: 96.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade400,
          width: 1.w,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2.h))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            patient.name,
            style: GoogleFonts.quicksand(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Last Session: ${patient.lastSession}',
            style: GoogleFonts.quicksand(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicalFileSection extends StatelessWidget {
  final VoidCallback onView;

  const MedicalFileSection({super.key, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: 10.w),
            const SectionTitle(title: 'Medical file'),
          ],
        ),
        GestureDetector(
          onTap: onView,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9FBAF9), Color(0xFF590B8D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'View',
              style: GoogleFonts.instrumentSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ExercisePlanCard extends StatelessWidget {
  final int index;
  final ExercisePlan exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExercisePlanCard({
    super.key,
    required this.index,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      height: 185.h,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
          width: 1.w,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2.h))
              ],
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    exercise.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  if (exercise.category != null &&
                      exercise.category!.isNotEmpty &&
                      exercise.category != 'General')
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        exercise.category!.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.quicksand(
                          fontSize: 10.sp,
                          color: const Color(0xFF786AC8),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (exercise.notes.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text(
                        exercise.notes,
                        style: GoogleFonts.quicksand(
                          fontSize: 10.sp,
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text(
                    'Duration: ${exercise.sets ?? 0} min',
                    style: GoogleFonts.quicksand(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                    ),
                  ),
                  Text(
                    'Reps: ${exercise.reps ?? 0} reps',
                    style: GoogleFonts.quicksand(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF5B5F9C),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9FBAF9), Color(0xFF590B8D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                padding: EdgeInsets.all(1.2.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Edit',
                        style: GoogleFonts.quicksand(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(Icons.edit_outlined, size: 10.sp, color: textColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaveChangesButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveChangesButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 235.w,
        height: 54.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9FBAF9), Color(0xFF590B8D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            'Save Changes',
            style: GoogleFonts.quicksand(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class AddExerciseDialog extends StatefulWidget {
  final Map<String, List<String>> exercises;

  final Function(String category, String exerciseName, int sets, int reps,
      String notes) onAdd;
  final dynamic initialExercise;

  const AddExerciseDialog({
    super.key,
    required this.exercises,
    required this.onAdd,
    this.initialExercise,
  });

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  String? selectedCategory;
  String? selectedExercise;
  late TextEditingController durationController;
  late TextEditingController repsController;

  final LinearGradient _mainGradient = const LinearGradient(
    colors: [Color(0xFF590B8D), Color(0xFF6B48FF)],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialExercise != null) {
      selectedExercise = widget.initialExercise!.name;

      if (widget.initialExercise?.category != null) {
        selectedCategory = widget.initialExercise!.category;
      } else {
        widget.exercises.forEach((key, value) {
          if (value.contains(selectedExercise)) {
            selectedCategory = key;
          }
        });
      }

      durationController = TextEditingController(
        text: (widget.initialExercise!.sets ?? 0).toString(),
      );
      repsController = TextEditingController(
        text: (widget.initialExercise!.reps ?? 0).toString(),
      );
    } else {
      durationController = TextEditingController();
      repsController = TextEditingController();
    }
  }

  @override
  void dispose() {
    durationController.dispose();
    repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String bgImage =
        isDark ? 'assets/images/popdark.png' : 'assets/images/Pop up.png';

    final inputFillColor = isDark
        ? const Color(0xFF1E1E1E).withOpacity(0.9)
        : Colors.grey[100]!.withOpacity(0.9);

    final textColor = isDark ? Colors.white : Colors.black87;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: 340.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4.h),
              blurRadius: 4,
            ),
          ],
          image: DecorationImage(
            image: AssetImage(bgImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("F",
                            style: GoogleFonts.grandHotel(
                                fontSize: 26.sp,
                                color: textColor,
                                fontWeight: FontWeight.bold)),
                        SizedBox(width: 4.w),
                        Image.asset(AssetsManager.logoIcon,
                            width: 20.w, fit: BoxFit.contain),
                        SizedBox(width: 2.w),
                        Text("exera",
                            style: GoogleFonts.grandHotel(
                                fontSize: 26.sp,
                                color: textColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                      widget.initialExercise == null
                          ? "Add Exercise"
                          : "Edit Exercise",
                      style: GoogleFonts.dancingScript(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF786AC8))),
                  SizedBox(height: 25.h),
                  _buildContainer(
                    fillColor: inputFillColor,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        icon: GradientIcon(
                            icon: Icons.keyboard_arrow_down_rounded,
                            gradient: _mainGradient,
                            size: 24.sp),
                        hint: Text('Category',
                            style: GoogleFonts.quicksand(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        value: selectedCategory,
                        dropdownColor:
                            isDark ? const Color(0xFF383838) : Colors.white,
                        items: widget.exercises.keys.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                                category.replaceAll('_', ' ').toUpperCase(),
                                style: GoogleFonts.quicksand(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textColor)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() {
                          selectedCategory = value;
                          selectedExercise = null;
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildContainer(
                    fillColor: inputFillColor,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        icon: GradientIcon(
                            icon: Icons.keyboard_arrow_down_rounded,
                            gradient: _mainGradient,
                            size: 24.sp),
                        hint: Text('Exercise Name',
                            style: GoogleFonts.quicksand(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey)),
                        value: selectedExercise,
                        dropdownColor:
                            isDark ? const Color(0xFF383838) : Colors.white,
                        items: (selectedCategory == null
                                ? widget.exercises.values
                                    .expand((x) => x)
                                    .toSet()
                                    .toList()
                                : widget.exercises[selectedCategory]!)
                            .map((exercise) {
                          return DropdownMenuItem(
                            value: exercise,
                            child: Text(exercise,
                                style: GoogleFonts.quicksand(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textColor)),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedExercise = value),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildContainer(
                    fillColor: inputFillColor,
                    child: TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.quicksand(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        hintText: 'Duration (min)',
                        hintStyle: GoogleFonts.quicksand(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                        suffixIconConstraints:
                            BoxConstraints(minWidth: 24.w, minHeight: 24.w),
                        suffixIcon: GradientIcon(
                            image: AssetsManager.field_icon,
                            gradient: _mainGradient,
                            size: 18.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildContainer(
                    fillColor: inputFillColor,
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.quicksand(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        hintText: 'Reps',
                        hintStyle: GoogleFonts.quicksand(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                        suffixIconConstraints:
                            BoxConstraints(minWidth: 24.w, minHeight: 24.w),
                        suffixIcon: GradientIcon(
                            image: AssetsManager.field_icon,
                            gradient: _mainGradient,
                            size: 18.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 35.h),
                  GestureDetector(
                    onTap: () {
                      if (selectedExercise != null) {
                        widget.onAdd(
                            selectedCategory ?? "General",
                            selectedExercise!,
                            int.tryParse(durationController.text) ?? 0,
                            int.tryParse(repsController.text) ?? 0,
                            "" // notes
                            );
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 200.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                          gradient: _mainGradient,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF6B48FF).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ]),
                      child: Center(
                          child: Text('Save Exercise',
                              style: GoogleFonts.quicksand(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer({required Color fillColor, required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      height: 50.h,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.transparent, width: 1),
      ),
      child: child,
    );
  }
}

class GradientIcon extends StatelessWidget {
  final IconData? icon;
  final String? image;
  final Gradient gradient;
  final double size;

  const GradientIcon(
      {super.key,
      this.icon,
      this.image,
      required this.gradient,
      required this.size});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => gradient.createShader(bounds),
      child: SizedBox(
        width: size * 1.2,
        height: size * 1.2,
        child: Center(child: _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    if (icon != null)
      return Icon(icon, size: size, color: Colors.white);
    else if (image != null)
      return Image.asset(image!,
          width: size, height: size, fit: BoxFit.contain, color: Colors.white);
    return const SizedBox();
  }
}

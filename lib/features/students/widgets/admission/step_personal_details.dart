import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controller/new_admission_controller.dart';
import 'custom_text_field.dart';
import 'custom_dropdown.dart';

class StepPersonalDetails extends StatefulWidget {
  const StepPersonalDetails({super.key});

  @override
  State<StepPersonalDetails> createState() => _StepPersonalDetailsState();
}

class _StepPersonalDetailsState extends State<StepPersonalDetails> {
  late NewAdmissionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NewAdmissionController>();
  }

  @override
  Widget build(BuildContext context) {
    print(
      'StepPersonalDetails: Building form with key: ${controller.personalDetailsFormKey}',
    );
    return Form(
      key: controller.personalDetailsFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Roll No and GR No
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.rollNoController,
                    label: 'Roll No',
                    hint: 'Enter roll number',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        controller.validateNumeric(value, 'Roll No'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.grNoController,
                    label: 'GR No',
                    hint: 'Enter GR number',
                    icon: Icons.confirmation_number,
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        controller.validateNumeric(value, 'GR No'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Student Name
            CustomTextField(
              controller: controller.studentNameController,
              label: 'Name of Student',
              hint: 'Enter student full name',
              icon: Icons.person,
              validator: (value) =>
                  controller.validateRequired(value, 'Student name'),
            ),
            SizedBox(height: 16.h),

            // Father's Name
            CustomTextField(
              controller: controller.fatherNameController,
              label: 'Name of Father',
              hint: 'Enter father\'s full name',
              icon: Icons.family_restroom,
              validator: (value) =>
                  controller.validateRequired(value, 'Father\'s name'),
            ),
            SizedBox(height: 16.h),

            // Caste (Optional)
            CustomTextField(
              controller: controller.casteController,
              label: 'Caste (Optional)',
              hint: 'Enter caste',
              icon: Icons.groups,
            ),
            SizedBox(height: 16.h),

            // Place of Birth
            CustomTextField(
              controller: controller.placeOfBirthController,
              label: 'Place of Birth',
              hint: 'Enter place of birth',
              icon: Icons.location_on,
              validator: (value) =>
                  controller.validateRequired(value, 'Place of birth'),
            ),
            SizedBox(height: 16.h),

            // Date of Birth
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date of Birth',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => CustomTextField(
                          label: 'Date (in figures)',
                          hint: 'DD/MM/YYYY',
                          icon: Icons.calendar_today,
                          readOnly: true,
                          controller: TextEditingController(
                            text: controller.dateOfBirth.value != null
                                ? '${controller.dateOfBirth.value!.day.toString().padLeft(2, '0')}/${controller.dateOfBirth.value!.month.toString().padLeft(2, '0')}/${controller.dateOfBirth.value!.year}'
                                : '',
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  controller.dateOfBirth.value ??
                                  DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              controller.setDateOfBirth(date);
                            }
                          },
                          validator: (value) {
                            if (controller.dateOfBirth.value == null) {
                              return 'Date of birth is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Obx(
                        () => CustomTextField(
                          label: 'Date (in words)',
                          hint: 'Date in words',
                          icon: Icons.text_fields,
                          readOnly: true,
                          controller: TextEditingController(
                            text: controller.dateOfBirthInWords.value,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Gender and Religion Row
            Row(
              children: [
                Expanded(
                  child: CustomDropdown(
                    label: 'Gender',
                    selectedValue: controller.selectedGender,
                    options: controller.genderOptions,
                    icon: Icons.wc,
                    validator: (value) =>
                        controller.validateRequired(value, 'Gender'),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomDropdown(
                    label: 'Religion',
                    selectedValue: controller.selectedReligion,
                    options: controller.religionOptions,
                    icon: Icons.mosque,
                    validator: (value) =>
                        controller.validateRequired(value, 'Religion'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Contact Numbers Row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.fathersContactController,
                    label: 'Father\'s Contact',
                    hint: '+92-300-1234567',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: controller.validatePhone,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: controller.mothersContactController,
                    label: 'Mother\'s Contact (Optional)',
                    hint: '+92-300-1234567',
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Address
            CustomTextField(
              controller: controller.addressController,
              label: 'Address',
              hint: 'Enter complete address',
              icon: Icons.home,
              maxLines: 3,
              validator: (value) =>
                  controller.validateRequired(value, 'Address'),
            ),
          ],
        ),
      ),
    );
  }
}

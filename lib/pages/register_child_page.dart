
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/pages/child_detail_page.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/widgets/app_card.dart';

class RegisterChildPage extends StatefulWidget {
  const RegisterChildPage({super.key});

  @override
  State<RegisterChildPage> createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _formKey = GlobalKey<FormState>();
  final childNameController = TextEditingController();
  final guardianController = TextEditingController();
  final phoneController = TextEditingController();
  final villageController = TextEditingController();
  final dobController = TextEditingController();

  DateTime? selectedDate;
  String? selectedGender;
  String selectedParentType = 'Mother';
  int calculatedYears = 0;
  int calculatedMonths = 0;
  bool saving = false;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void dispose() {
    childNameController.dispose();
    guardianController.dispose();
    phoneController.dispose();
    villageController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select child date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final today = DateTime.now();
    var years = today.year - pickedDate.year;
    var months = today.month - pickedDate.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    setState(() {
      selectedDate = pickedDate;
      calculatedYears = years;
      calculatedMonths = months;
      dobController.text =
          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
    });
  }

  Future<void> _registerChild() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      _showMessage('Please select the child\'s date of birth.');
      return;
    }

    setState(() => saving = true);

    try {
      final childID = await firestoreService.registerChild(
        childName: childNameController.text.trim(),
        parentType: selectedParentType,
        guardianName: guardianController.text.trim(),
        phone: phoneController.text.trim(),
        village: villageController.text.trim(),
        gender: selectedGender!,
        dob: selectedDate!,
        ageYears: calculatedYears,
        ageMonths: calculatedMonths,
      );

      if (!mounted) return;
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChildDetailPage(childID: childID),
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) _showMessage('Registration failed: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register New Child',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 18),
                  AppCard(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppSectionTitle(
                            title: 'Child information',
                            subtitle:
                                'Enter the basic details used to create the child profile.',
                            icon: Icons.child_care_rounded,
                          ),
                          const SizedBox(height: 22),
                          _field(
                            controller: childNameController,
                            label: 'Child name',
                            hint: 'Enter full name',
                            icon: Icons.person_outline_rounded,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Please enter the child\'s name'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 560) {
                                return Column(
                                  children: [
                                    _dobField(),
                                    const SizedBox(height: 16),
                                    _genderField(),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: _dobField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _genderField()),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 30),
                          const AppSectionTitle(
                            title: 'Parent / Guardian & contact',
                            subtitle:
                                'Select relationship and enter contact details.',
                            icon: Icons.family_restroom_rounded,
                          ),
                          const SizedBox(height: 22),
                          DropdownButtonFormField<String>(
                            value: selectedParentType,
                            decoration: const InputDecoration(
                              labelText: 'Parent / Guardian Type',
                              prefixIcon: Icon(Icons.people_outline_rounded),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Father', child: Text('Father')),
                              DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                              DropdownMenuItem(value: 'Guardian', child: Text('Guardian')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedParentType = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _field(
                            controller: guardianController,
                            label: '$selectedParentType name',
                            hint: 'Enter $selectedParentType\'s full name',
                            icon: Icons.family_restroom_outlined,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Please enter the $selectedParentType\'s name'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 560) {
                                return Column(
                                  children: [
                                    _phoneField(),
                                    const SizedBox(height: 16),
                                    _field(
                                      controller: villageController,
                                      label: 'Village / area',
                                      hint: 'Enter locality',
                                      icon: Icons.location_on_outlined,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: _phoneField()),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _field(
                                      controller: villageController,
                                      label: 'Village / area',
                                      hint: 'Enter locality',
                                      icon: Icons.location_on_outlined,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 26),
                          if (selectedDate != null) _agePreview(),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: saving ? null : _registerChild,
                              icon: saving
                                  ? const SizedBox(
                                      width: 19,
                                      height: 19,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.person_add_alt_1_rounded),
                              label: Text(
                                saving
                                    ? 'Creating child profile...'
                                    : 'Create child profile',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Text(
            'New child profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
        ),
        const Text(
          'Step 1 of 1',
          style: TextStyle(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _agePreview() {
    final yearLabel = calculatedYears == 1 ? 'year' : 'years';
    final monthLabel = calculatedMonths == 1 ? 'month' : 'months';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(.14)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cake_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          const Text(
            'Calculated age',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          Text(
            '$calculatedYears $yearLabel  $calculatedMonths $monthLabel',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _dobField() {
    return TextFormField(
      controller: dobController,
      readOnly: true,
      onTap: _pickDate,
      decoration: const InputDecoration(
        labelText: 'Date of birth',
        hintText: 'Select date',
        prefixIcon: Icon(Icons.calendar_month_outlined),
        suffixIcon: Icon(Icons.arrow_drop_down_rounded),
      ),
      validator: (value) => value == null || value.isEmpty
          ? 'Please select the date of birth'
          : null,
    );
  }

  Widget _genderField() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.wc_rounded),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) => setState(() => selectedGender = value),
      validator: (value) =>
          value == null ? 'Please select a gender' : null,
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: const InputDecoration(
        labelText: 'Phone number',
        hintText: '10 digit mobile number',
        prefixIcon: Icon(Icons.phone_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the phone number';
        }
        if (value.length != 10) return 'Phone number must be 10 digits';
        return null;
      },
    );
  }
}

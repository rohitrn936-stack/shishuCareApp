
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_page/constants/app_colours.dart';
import 'package:web_page/pages/child_detail_page.dart';
import 'package:web_page/services/firestore_service.dart';
import 'package:web_page/utils/snackbar_helper.dart';
import 'package:web_page/widgets/app_card.dart';
import 'package:web_page/widgets/sleek_app_bar.dart';

class RegisterChildPage extends StatefulWidget {
  final DocumentSnapshot? existingChild;

  const RegisterChildPage({super.key, this.existingChild});

  @override
  State<RegisterChildPage> createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _formKey = GlobalKey<FormState>();
  final childNameController = TextEditingController();
  final guardianController = TextEditingController();
  final phoneController = TextEditingController();
  final houseNoController = TextEditingController();
  final streetController = TextEditingController();
  final localityController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final dobController = TextEditingController();

  DateTime? selectedDate;
  String? selectedGender;
  String selectedParentType = 'Mother';
  int calculatedYears = 0;
  int calculatedMonths = 0;
  bool saving = false;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.existingChild != null) {
      final data = widget.existingChild!.data() as Map<String, dynamic>;
      childNameController.text = data['childName']?.toString() ?? '';
      guardianController.text = data['guardianName']?.toString() ?? '';
      phoneController.text = data['phone']?.toString() ?? '';
      houseNoController.text = data['houseNo']?.toString() ?? '';
      streetController.text = data['street']?.toString() ?? '';
      localityController.text = data['locality']?.toString() ?? '';
      cityController.text = data['city']?.toString() ?? '';
      pincodeController.text = data['pincode']?.toString() ?? '';
      selectedGender = data['gender']?.toString();
      selectedParentType = data['parentType']?.toString() ?? 'Mother';
      if (data['dob'] is Timestamp) {
        selectedDate = (data['dob'] as Timestamp).toDate();
        dobController.text =
            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

        final today = DateTime.now();
        var years = today.year - selectedDate!.year;
        var months = today.month - selectedDate!.month;
        if (months < 0) {
          years--;
          months += 12;
        }
        calculatedYears = years;
        calculatedMonths = months;
      }
    }
  }

  @override
  void dispose() {
    childNameController.dispose();
    guardianController.dispose();
    phoneController.dispose();
    houseNoController.dispose();
    streetController.dispose();
    localityController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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

    final today = DateTime.now();
    if (selectedDate!.isAfter(today)) {
      _showMessage('Error: Date of birth cannot be in the future.');
      return;
    }
    if (selectedDate!.year > today.year) {
      _showMessage('Error: Date of birth year cannot be greater than current year.');
      return;
    }

    setState(() => saving = true);

    final parts = [
      houseNoController.text.trim(),
      streetController.text.trim(),
      localityController.text.trim(),
      cityController.text.trim(),
    ].where((p) => p.isNotEmpty).toList();

    final pin = pincodeController.text.trim();
    String assembledAddress = parts.join(', ');
    if (pin.isNotEmpty) {
      assembledAddress += assembledAddress.isNotEmpty ? ' - $pin' : pin;
    }

    try {
      if (widget.existingChild != null) {
        await firestoreService.updateChild(
          childID: widget.existingChild!.id,
          childName: childNameController.text.trim(),
          parentType: selectedParentType,
          guardianName: guardianController.text.trim(),
          phone: phoneController.text.trim(),
          houseNo: houseNoController.text.trim(),
          street: streetController.text.trim(),
          locality: localityController.text.trim(),
          city: cityController.text.trim(),
          pincode: pincodeController.text.trim(),
          address: assembledAddress,
          gender: selectedGender!,
          dob: selectedDate!,
          ageYears: calculatedYears,
          ageMonths: calculatedMonths,
        );

        if (!mounted) return;
        _showMessage('Child profile updated successfully.');
        Navigator.pop(context, true);
      } else {
        final childID = await firestoreService.registerChild(
          childName: childNameController.text.trim(),
          parentType: selectedParentType,
          guardianName: guardianController.text.trim(),
          phone: phoneController.text.trim(),
          houseNo: houseNoController.text.trim(),
          street: streetController.text.trim(),
          locality: localityController.text.trim(),
          city: cityController.text.trim(),
          pincode: pincodeController.text.trim(),
          address: assembledAddress,
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
      }
    } catch (e) {
      if (mounted) _showMessage('Operation failed: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showMessage(String message) {
    showTopSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingChild != null;
    return Scaffold(
      appBar: SleekAppBar(
        title: isEditing ? 'Edit Child Profile' : 'Register New Child',
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
                            icon: Icons.person_add_alt_1_rounded,
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
                          _phoneField(),
                          const SizedBox(height: 24),
                          const AppSectionTitle(
                            title: 'Residential Address',
                            subtitle: 'Enter apartment/house no, street, locality, and city details.',
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isWide = constraints.maxWidth > 560;

                              final houseField = _field(
                                controller: houseNoController,
                                label: 'Apartment / House / Flat No.',
                                hint: 'e.g. #717/1 or Flat 302',
                                icon: Icons.home_outlined,
                              );

                              final streetField = _field(
                                controller: streetController,
                                label: 'Street / Cross Road',
                                hint: 'e.g. 16th Main, 6th B Cross',
                                icon: Icons.add_road_rounded,
                              );

                              final localityField = _field(
                                controller: localityController,
                                label: 'Locality / Area / Block',
                                hint: 'e.g. Koramangala 3rd Block',
                                icon: Icons.location_city_outlined,
                              );

                              final cityField = _field(
                                controller: cityController,
                                label: 'City / Town',
                                hint: 'e.g. Bangalore',
                                icon: Icons.location_on_outlined,
                              );

                              final pincodeField = _field(
                                controller: pincodeController,
                                label: 'Pincode',
                                hint: 'e.g. 560034',
                                icon: Icons.pin_drop_outlined,
                                keyboardType: TextInputType.number,
                              );

                              if (!isWide) {
                                return Column(
                                  children: [
                                    houseField,
                                    const SizedBox(height: 16),
                                    streetField,
                                    const SizedBox(height: 16),
                                    localityField,
                                    const SizedBox(height: 16),
                                    cityField,
                                    const SizedBox(height: 16),
                                    pincodeField,
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: houseField),
                                      const SizedBox(width: 16),
                                      Expanded(child: streetField),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: localityField),
                                      const SizedBox(width: 16),
                                      Expanded(child: cityField),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(child: pincodeField),
                                      const SizedBox(width: 16),
                                      const Expanded(child: SizedBox()),
                                    ],
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
                                  : Icon(isEditing
                                      ? Icons.save_rounded
                                      : Icons.person_add_alt_1_rounded),
                              label: Text(
                                saving
                                    ? (isEditing
                                        ? 'Saving changes...'
                                        : 'Creating child profile...')
                                    : (isEditing
                                        ? 'Save profile changes'
                                        : 'Create child profile'),
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
    final isEditing = widget.existingChild != null;
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            isEditing ? 'Edit child profile' : 'New child profile',
            style: const TextStyle(
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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

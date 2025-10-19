class StudentModel {
  final int? id;
  final String rollNo;
  final String grNo;
  final String studentName;
  final String fatherName;
  final String caste;
  final String placeOfBirth;
  final DateTime dobFigures;
  final String dobWords;
  final String gender;
  final String religion;
  final String fatherContact;
  final String motherContact;
  final String address;
  final DateTime admissionDate;
  final int? classId;
  final String className;
  final String section;
  final double admissionFees;
  final double monthlyFees;
  final String status;

  StudentModel({
    this.id,
    required this.rollNo,
    required this.grNo,
    required this.studentName,
    required this.fatherName,
    required this.caste,
    required this.placeOfBirth,
    required this.dobFigures,
    required this.dobWords,
    required this.gender,
    required this.religion,
    required this.fatherContact,
    required this.motherContact,
    required this.address,
    required this.admissionDate,
    this.classId,
    required this.className,
    required this.section,
    required this.admissionFees,
    required this.monthlyFees,
    this.status = 'Active',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roll_no': rollNo,
      'gr_no': grNo,
      'student_name': studentName,
      'father_name': fatherName,
      'caste': caste,
      'place_of_birth': placeOfBirth,
      'dob_figures': dobFigures.toIso8601String(),
      'dob_words': dobWords,
      'gender': gender,
      'religion': religion,
      'father_contact': fatherContact,
      'mother_contact': motherContact,
      'address': address,
      'admission_date': admissionDate.toIso8601String(),
      'class_id': classId,
      'class_name': className,
      'section': section,
      'admission_fees': admissionFees,
      'monthly_fees': monthlyFees,
      'status': status,
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      rollNo: json['roll_no'],
      grNo: json['gr_no'],
      studentName: json['student_name'],
      fatherName: json['father_name'],
      caste: json['caste'],
      placeOfBirth: json['place_of_birth'],
      dobFigures: DateTime.parse(json['dob_figures']),
      dobWords: json['dob_words'],
      gender: json['gender'],
      religion: json['religion'],
      fatherContact: json['father_contact'],
      motherContact: json['mother_contact'],
      address: json['address'],
      admissionDate: DateTime.parse(json['admission_date']),
      classId: json['class_id'],
      className: json['class_name'],
      section: json['section'],
      admissionFees: json['admission_fees'].toDouble(),
      monthlyFees: json['monthly_fees'].toDouble(),
      status: json['status'],
    );
  }

  StudentModel copyWith({
    int? id,
    String? rollNo,
    String? grNo,
    String? studentName,
    String? fatherName,
    String? caste,
    String? placeOfBirth,
    DateTime? dobFigures,
    String? dobWords,
    String? gender,
    String? religion,
    String? fatherContact,
    String? motherContact,
    String? address,
    DateTime? admissionDate,
    int? classId,
    String? className,
    String? section,
    double? admissionFees,
    double? monthlyFees,
    String? status,
  }) {
    return StudentModel(
      id: id ?? this.id,
      rollNo: rollNo ?? this.rollNo,
      grNo: grNo ?? this.grNo,
      studentName: studentName ?? this.studentName,
      fatherName: fatherName ?? this.fatherName,
      caste: caste ?? this.caste,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      dobFigures: dobFigures ?? this.dobFigures,
      dobWords: dobWords ?? this.dobWords,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      fatherContact: fatherContact ?? this.fatherContact,
      motherContact: motherContact ?? this.motherContact,
      address: address ?? this.address,
      admissionDate: admissionDate ?? this.admissionDate,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      section: section ?? this.section,
      admissionFees: admissionFees ?? this.admissionFees,
      monthlyFees: monthlyFees ?? this.monthlyFees,
      status: status ?? this.status,
    );
  }
}

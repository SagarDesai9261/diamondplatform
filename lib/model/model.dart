class EmployeeDetails {
  EmployeeDetails({
     this.id,
     this.name,
     this.city,
      this.adress,
     this.mobileNumber,
    this.mobileNumber2,
     this.adharNumber,
     this.adharPhoto,
     this.gender,
     this.department,
     this.designation,
     this.password,
     this.isEmployee,
     this.V,
  });
   String? id;
   String? name;
   String? city;
   String? adress;
  int? mobileNumber;
   int? mobileNumber2;
   int? adharNumber;
   String? adharPhoto;
   String? gender;
   String? department;
   String? designation;
   String? password;
   bool? isEmployee;
   int? V;
   String? companyName;
 bool? isSalaryMethod;
 String? salary;
  String? price;

  EmployeeDetails.fromJson(Map<String, dynamic> json){
    id = json['_id'];
    name = json['name'];
    city = json['city'];
    adress = json['adress'];
    mobileNumber = json['mobileNumber'];
    mobileNumber2 = json['mobileNumber2'];
    adharNumber = json['adharNumber'];
    adharPhoto = json['adharPhoto'];
    gender = json['gender'];
    department = json['department'];
    designation = json['designation'];
    password = json['password'];
    isEmployee = json['isEmployee'];
    V = json['__v'];
    salary= json['salary'];
    price = json['price'];
    isSalaryMethod = json['isSalaryMethod'];
    companyName = json['companyName'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['_id'] = id;
    _data['name'] = name;
    _data['city'] = city;
    _data['adress'] = adress;
    _data['mobileNumber'] = mobileNumber;
    _data['mobileNumber2'] = mobileNumber2;
    _data['adharNumber'] = adharNumber;
    _data['adharPhoto'] = adharPhoto;
    _data['gender'] = gender;
    _data['department'] = department;
    _data['designation'] = designation;
    _data['password'] = password;
    _data['isEmployee'] = isEmployee;
    _data['__v'] = V;

    return _data;
  }
}
class JobPost {
  final String id;
  final String jobpostId;
   String? employeerName = "";
  final String departmentName;
  final String designationName;
  final int mobileNumber;
  final String cityName;
  final String typesOfDiamond;
  final String workType;
  final int numberOfEmp;
  final bool requirementTypes;
   int? salary = 0;
   int? price = 0;
  final String gender;
  final String companyId;
  List? employeeView ;
  List? mobileCount;
  String? createJobPostDate;
  String? endJobPostDate;
  final double? longitude;
  final double? latitude;
  String? address;
  bool? isJobPostShow;
  JobPost({
    required this.id,
    required this.jobpostId,
     this.employeerName,
    required this.departmentName,
    required this.designationName,
    required this.mobileNumber,
    required this.cityName,
    required this.typesOfDiamond,
    required this.workType,
    required this.numberOfEmp,
    required this.requirementTypes,
     this.salary,
     this.price,
    this.address,
    this.isJobPostShow,
    required this.gender,
    required this.companyId,
    this.employeeView,
    this.mobileCount,
    this.createJobPostDate,
    this.endJobPostDate,
     this.longitude,
    this.latitude

  });

  factory JobPost.fromJson(Map<String, dynamic> json) {
    return JobPost(
      id: json['_id'],
      isJobPostShow: json['isJobPostShow'],
      jobpostId: json['jobpostId'],
      employeerName: json['employeerName'],
      departmentName: json['departmentName'],
      designationName: json['designationName'],
      mobileNumber: json['mobileNumber'],
      cityName: json['cityName'],
      typesOfDiamond: json['typesOfDiamond'],
      workType: json['workType'],
      numberOfEmp: json['numberOfEmp'],
      requirementTypes: json['requirementTypes'],
      salary: json['salary'],
      price:json['price'],
      gender: json['gender'],
      companyId: json['companyId'],
      employeeView: json['employeeView'],
      mobileCount: json['mobileCount'],
      createJobPostDate: json['createJobPostDate'],
      endJobPostDate: json['endJobPostDate'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['adress']
    );
  }
}
class BannerItem {
  final String id;
  final String imageUrl;

  BannerItem({required this.id, required this.imageUrl});
}
class CompanyProfile {
  String? name;
  String? gstNumber;
  int? mobileNumber;
  String? address;
  String? selectedCity;
  String? profile;
  String? department;
  String? designation;
  // Add more properties as needed

  CompanyProfile({

    this.name,
    this.gstNumber,
    this.mobileNumber,
    this.address,
    this.selectedCity,
    this.designation,
    this.department,
    this.profile
    // Initialize more properties here
  });

  CompanyProfile copyWith({
    String? name,
    String? gstNumber,
    int? mobileNumber,
    String? address,
    String? selectedCity,
    String? profile,
    String? department,
    String? designation
    // Add more properties to copy here
  }) {
    return CompanyProfile(
      name: name ?? this.name,
      gstNumber: gstNumber ?? this.gstNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      selectedCity: selectedCity ?? this.selectedCity,
      profile: profile ?? this.profile,
      department:  department??this.department,
      designation: designation?? this.designation
      // Copy more properties here
    );
  }
}
class EmployeeProfile {
  String? name;
  String? aadharNumber;
  int? mobileNumber;
  String? address;
  String? selectedCity;
  String? profile;
  String? department;
  String? designation;
  // Add more properties as needed

  EmployeeProfile({

    this.name,
    this.aadharNumber,
    this.mobileNumber,
    this.address,
    this.selectedCity,
    this.designation,
    this.department,
    this.profile
    // Initialize more properties here
  });

  EmployeeProfile copyWith({
    String? name,
    String? aadharNumber,
    int? mobileNumber,
    String? address,
    String? selectedCity,
    String? profile,
    String? department,
    String? designation
    // Add more properties to copy here
  }) {
    return EmployeeProfile(
        name: name ?? this.name,
        aadharNumber: aadharNumber ?? this.aadharNumber,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        address: address ?? this.address,
        selectedCity: selectedCity ?? this.selectedCity,
        profile: profile ?? this.profile,
        department:  department??this.department,
        designation: designation?? this.designation
      // Copy more properties here
    );
  }
}

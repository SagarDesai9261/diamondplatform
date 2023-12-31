import 'dart:convert';
import 'package:diamondplatform/Pages/employee/notification_data.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:diamondplatform/Pages/employee/show_job_posts.dart';
import 'package:diamondplatform/Widget/banner_slider.dart';
import 'package:diamondplatform/model/model.dart';
import 'package:diamondplatform/model/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Ad_Helper.dart';
import '../Custom_Drawer.dart';

class Home_page_employee extends StatefulWidget {
  const Home_page_employee({Key? key}) : super(key: key);

  @override
  State<Home_page_employee> createState() => _Home_page_employeeState();
}

class _Home_page_employeeState extends State<Home_page_employee> {

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  int selectedPos = 0;
  BannerAd? _bannerAd;

  double bottomNavBarHeight = 60;
  List? diamondTypeList = [];
  List? workTypeList = [];
  List? bannerList = [];
  List? job_post_for_company = [];
  String? dropdownValue1;
  String? dropdownValue2;
  String selectedOption3 = 'Option 1';
  List<String> options = ['Option 1', 'Option 2'];

  List<TabItem> tabItems = List.of([
    TabItem(
      Icons.home,
      "Home".tr(),
      Colors.blue,
      labelStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    TabItem(
      Icons.supervised_user_circle,
      "All Post".tr(),
      Colors.orange,
      labelStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
  ]);

  late CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print("error $err");
          ad.dispose();
        },
      ),
    ).load();
    _navigationController = CircularBottomNavigationController(selectedPos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diamond Platform').tr(),
      actions: [
        IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationPage()));
        }, icon: const Icon(Icons.notifications_active_outlined))
      ],
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: bottomNavBarHeight),
            child: bodyContainer(),
          ),
          Align(alignment: Alignment.bottomCenter, child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              bottomNav(),
              if (_bannerAd != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              if (_bannerAd == null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * .8,
                  height: MediaQuery.of(context).size.height * .04,
                  decoration: BoxDecoration(
                      border: Border.all()
                  ),
                  child: const Text("No Ads "),
                ),
              ),
            ],
          )),


        ],
      ),
      drawer: const CustomDrawer(
        isEmployee: true,
      ),
      floatingActionButton: Column(
        children: [

          Container(
            decoration: const BoxDecoration(
              color: Colors.blue
            ),
          )
        ],
      ),
    );
  }

  Widget bodyContainer() {
    switch (selectedPos) {
      case 0:
        return home_view();
      case 1:
        return const ShowAllCategories();
    }
    return Container();

  }
  Future<bool> showExitPopup() async {
    return await showDialog(
      //show confirm dialogue
      //the return value will be from "Yes" or "No" options
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App').tr(),
        content: const Text('Do you want to exit an App?').tr(),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            //return false when click on "NO"
            child: const Text('No').tr(),
          ),
          ElevatedButton(
            onPressed: () {
             // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home_page_employee()), (route) => false);
              SystemNavigator.pop();
            },
            //return true when click on "Yes"
            child: const Text('Yes').tr(),
          ),
        ],
      ),
    ) ??
        false; //if showDialouge had returned null, then return false
  }
  home_view(){
    return WillPopScope(
        onWillPop: showExitPopup,
        child: const Job_post());
  }
  Widget bottomNav() {
    return CircularBottomNavigation(
      tabItems,
      controller: _navigationController,
      selectedPos: selectedPos,
      barHeight: bottomNavBarHeight,
      // use either barBackgroundColor or barBackgroundGradient to have a gradient on bar background
      barBackgroundColor: Colors.white,
      // barBackgroundGradient: LinearGradient(
      //   begin: Alignment.bottomCenter,
      //   end: Alignment.topCenter,
      //   colors: [
      //     Colors.blue,
      //     Colors.red,
      //   ],
      // ),
      backgroundBoxShadow: const <BoxShadow>[
        BoxShadow(color: Colors.black45, blurRadius: 10.0),
      ],
      animationDuration: const Duration(milliseconds: 300),
      selectedCallback: (int? selectedPos) {
        setState(() {
          this.selectedPos = selectedPos ?? 0;
          if (kDebugMode) {
            print(_navigationController.value);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _navigationController.dispose();
  }
}

class Job_post extends StatefulWidget {
  const Job_post({Key? key}) : super(key: key);

  @override
  State<Job_post> createState() => _Job_postState();
}

class _Job_postState extends State<Job_post> {
  late SharedPreferences sharedPrefs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() => sharedPrefs = prefs);
    });
  }
  @override
  Widget build(BuildContext context) {
    final bannerProvider =
    Provider.of<BannerDataProvider>(context, listen: false);
    bannerProvider.fetchBanners();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            BannerSlider(),
            StreamBuilder<List<JobPost>>(
              stream: employee_job_post_details().fetchJobPosts(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const CircularProgressIndicator();
                }
                else if (snapshot.hasError){

                }
                return display_post(snapshot.data!);




              }
            ),
          ],
        ),
      ),
    );
  }
  Widget display_post(List<JobPost> snapshotdata){
    Map<String,dynamic> data = json.decode(sharedPrefs.getString("user_details")!);
  // print(snapshotdata);
    var filterdata =  snapshotdata.where((element) => element.designationName == data["designation"]).toList();
 //  print(filterdata.length);
   //  var designation = data["designationName"].toString();
    return SizedBox(
      height: MediaQuery.of(context).size.height * .56,
      child: ListView.builder(
          itemCount: filterdata.length,
          itemBuilder: (context,index){
         //   print(filterdata[index].designationName);
            return Container(
              height: 120,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  const BoxShadow(color: Colors.grey, spreadRadius: 3),
                ],
              ),
              child: InkWell(
                  onTap: () {
                    employee_add_count(filterdata[index].id);
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => JobPosts(post: filterdata[index],)));
                  },
                  child: ListTile(
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    tileColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.diamond_outlined, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(filterdata[index].typesOfDiamond,
                                    style: const TextStyle(
                                      color: Colors.black,
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.diamond_outlined, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(filterdata[index].workType,
                                    style: const TextStyle(color: Colors.black,
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("${"Vacancy:".tr()}${filterdata[index].numberOfEmp}",
                            style: const TextStyle(fontSize: 16, color: Colors.green)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_city, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text("${filterdata[index].employeerName}",
                                style: const TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  )),
            );
          }),
    );
  }

   employee_add_count(var id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance() ;
    Map<String,dynamic> data = json.decode(prefs.getString("user_details")!);
    //var datetime = DateTime.now();

    //  print(id);
    try {
    //   print(body);
      // print(response.body);
       //var data = json.decode(response.body);
       if (data["statusCode"] == 200) {
        // snackBar().display(context, "Job post updated Successfully", Colors.green);
       }
       //print(response.statusCode);
     }
     catch (e) {
    }
   }
}

class Post {
  final String? ComapanyName;
  final String? MobileNo;
  final int? NoOfvacancy;
  final String? Address;
  final String? City;
  final double? destinationLatitude = 21.762398;
  final double? destinationLongitude = 72.122637;
  final int? price;
  final String? ManagerName;
  final int? CountOfCall;
  Post({
    required this.ComapanyName,
    required this.MobileNo,
    required this.NoOfvacancy,
    required this.Address,
    required this.City,
    required this.price,
    required this.ManagerName,
    required this.CountOfCall,
  });
}

class JobPosts extends StatefulWidget {
  JobPost? post;
  JobPosts({Key? key, this.post}) : super(key: key);

  @override
  State<JobPosts> createState() => _JobPostsState();
}

class _JobPostsState extends State<JobPosts> {
  // Sample list of Post objects
  List<Post> posts = [
    Post(
        ComapanyName: 'Company 1',
        MobileNo: '1234567890',
        NoOfvacancy: 10,
        Address: 'Sardarnagar, Bhavnagar',
        City: 'Bhavnagar',
        price: 10000,
        ManagerName: 'John Doe',
        CountOfCall: 100),
  ];

  @override
  Widget build(BuildContext context) {
    var post = widget.post;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Post Details").tr(),
      ),
      body:  ListView.builder(
          itemCount: 1,
          itemBuilder:(context,index){

          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Position Name:".tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Row(
                        children: [

                          Text(
                            post!.designationName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Text("${"Vacancy:".tr()}  ${post.numberOfEmp}",style: const TextStyle(
                    fontSize: 18,fontWeight: FontWeight.bold
                  ),),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee),
                          Text(
                            post.requirementTypes
                                ? "${post.price}  ${"per piece".tr()}"
                                : "${post.salary}   ${"per month".tr()}",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.employeerName.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showPhoneCallConfirmationDialog(
                                  post.mobileNumber.toString(), post.id);
                            },
                            icon: const Icon(
                              Icons.call,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            "+91 ${post.mobileNumber.toString()}",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.diamond_outlined,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.typesOfDiamond.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.diamond_outlined,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.workType.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              _openGoogleMaps(post.latitude, post.longitude);
                            },
                            child: Text(
                              "${post.address}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_city,
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            post.cityName.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        _openGoogleMaps(post.latitude, post.longitude);
                      },
                      child: const Text("Click to Navigate").tr(),
                    ),
                  ),
                ],
              ),
            ),
          );

        }
      )

    );
  }
  void _openGoogleMaps(destinationLatitude,destinationLongitude) async {
    final url = "https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  void _launchPhoneCall(String phoneNumber) async {
    //set the number here

  }

  void _showPhoneCallConfirmationDialog(String phoneNumber,var id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Make Phone Call"),
          content: Text("Do you want to call +91 $phoneNumber ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Call"),
              onPressed: () {
                Mobile_add_count(id);
                Navigator.of(context).pop(); // Close the dialog
                _launchPhoneCall(phoneNumber);
              },
            ),
          ],
        );
      },
    );
  }
  Mobile_add_count(var id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance() ;
    Map<String,dynamic> data = json.decode(prefs.getString("user_details")!);
    DateTime now = DateTime.now();

    // print(id);
    try {
     // print(body);
     // print(response.body);
      //var data = json.decode(response.body);
      if (data["statusCode"] == 200) {
        // snackBar().display(context, "Job post updated Successfully", Colors.green);
      }
      //print(response.statusCode);
    }
    catch (e) {
    }
  }
}

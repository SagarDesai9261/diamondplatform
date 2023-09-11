import 'dart:convert';

import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diamondplatform/Pages/Custom_Drawer.dart';
import 'package:diamondplatform/Pages/company/employee_details.dart';
import 'package:diamondplatform/Pages/company/history.dart';
import 'package:diamondplatform/Widget/banner_slider.dart';
import 'package:http/http.dart' as http;
import '../../Ad_Helper.dart';
import '../../Widget/MyListTile.dart';
import '../../model/model.dart';
import '../../model/service.dart';
import 'job_Post.dart';
import 'notification_data.dart';

class Home_Page_company extends StatefulWidget {
  Home_Page_company({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  State<Home_Page_company> createState() => _Home_Page_companyState();
}

class _Home_Page_companyState extends State<Home_Page_company> {
  @override
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
  List<String> options = ['Option 1', 'Option 2','Option 3'];

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
      "Employee".tr(),
      Colors.orange,
      labelStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    TabItem(
      Icons.history,
      "History".tr(),
      Colors.red,
     labelStyle: TextStyle(
       color: Colors.red,
       fontWeight: FontWeight.bold
     )
     // circleStrokeColor: Colors.black,
    ),
    TabItem(
      Icons.add,
      "Job Post".tr(),
      Colors.cyan,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        )
    ),
  ]);

  late CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    diamondType();
    workType();
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
    final bannerProvider =
        Provider.of<BannerDataProvider>(context, listen: false);
    bannerProvider.fetchBanners();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diamond Platform").tr(),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> NotificationPage()));
          }, icon: Icon(Icons.notifications_active_outlined))
        ],
      ),
      drawer: const CustomDrawer(
        isEmployee: false,
      ),
      body: Stack(
        children: <Widget>[
          Padding(
            child: bodyContainer(),
            padding: EdgeInsets.only(bottom: bottomNavBarHeight),
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
    );
  }

  Widget bodyContainer() {
    Color? selectedColor = tabItems[selectedPos].circleColor;
    String slogan;
    switch (selectedPos) {
      case 0:
        return Home_page_view();
        //slogan = "Family, Happiness, Food";
      case 1:
        return const employee_view();
      case 2:
        return const History_jobpost();
      case 3:
        // slogan = "Noise, Panic, Ignore";
        return const Job_Post();
      default:
        slogan = "";
        break;
    }

    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: selectedColor,
        child: Center(
          child: Text(
            slogan,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      onTap: () {
        /*if (_navigationController.value == tabItems.length - 1) {
          _navigationController.value = 0;
        } else {
          _navigationController.value = _navigationController.value! + 1;
        }*/
      },
    );
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
      backgroundBoxShadow: <BoxShadow>[
        const BoxShadow(color: Colors.black45, blurRadius: 10.0),
      ],
      animationDuration: const Duration(milliseconds: 300),
      selectedCallback: (int? selectedPos) {
        setState(() {
          this.selectedPos = selectedPos ?? 0;
          print(_navigationController.value);
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _navigationController.dispose();
    diamondType();
  }

  Home_page_view() {
    final jobPostService = JobPostService();
    //final diamondProvider = Provider.of<DiamondProvider>(context);
    return WillPopScope(
      onWillPop: () => showExitPopup(),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .26,
                  padding: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("Diamond"),
                      value: dropdownValue1,
                      onChanged: (newValue) {
                        setState(() {
                          dropdownValue1 = newValue!;
                          // fetch_designation();
                        });
                      },
                      items: diamondTypeList!.map((diamondTypeList) {
                        return DropdownMenuItem<String>(
                          value: diamondTypeList["diamondType"],
                          child: Text(diamondTypeList["diamondType"]),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .45,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("select_worktype"),
                      value: dropdownValue2,
                      onChanged: (newValue) {
                        setState(() {
                          dropdownValue2 = newValue!;
                          // fetch_designation();
                        });
                      },
                      items: workTypeList!.map((workTypeList) {
                        return DropdownMenuItem<String>(
                          value: workTypeList["diamondWorkType"],
                          child: Text(workTypeList["diamondWorkType"]),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  height: MediaQuery.of(context).size.height * .06,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      iconSize: 0.0,
                      value: selectedOption3,
                      onChanged: (newValue) {
                        setState(() {
                          selectedOption3 = newValue!;
                        });
                      },
                      items:
                          options.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: value == "Option 1"
                              ? Image.asset("assets/male.png")
                              : value == "Option 2" ?  Image.asset("assets/female.png") :Image.asset("assets/both.png") ,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            BannerSlider(),
            StreamBuilder<List<JobPost>>(
              stream: jobPostService.fetchJobPosts(), // Make sure this returns a Stream<List<JobPost>>
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Center(child: Text('Error fetching data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No job posts available').tr());
                } else {
                 // var filteredJobPosts;
                  var filteredJobPosts;
                  if (dropdownValue1 == "All" && dropdownValue2 =="All" && selectedOption3 =="Option 1" ) {
                    filteredJobPosts = snapshot.data!.where((jobPost) {
                      return jobPost.gender =="Male";
                    }).toList();
                    // filteredJobPosts = snapshot.data;
                  }
                  else if(dropdownValue1 == "All" && dropdownValue2 =="All" && selectedOption3 =="Option 2"){
                    filteredJobPosts = snapshot.data!.where((jobPost) {
                      return jobPost.gender =="Female";
                    }).toList();
                  }
                  else if(dropdownValue1 == "All" && selectedOption3 == "Option 1"){
                    filteredJobPosts = snapshot.data!.where((jobPost) {
                      return jobPost.workType == dropdownValue2 && jobPost.gender =="Male";
                    }).toList();
                  }
                  else if(dropdownValue1 == "All" && selectedOption3 == "Option 2"){
                    filteredJobPosts = snapshot.data!.where((jobPost) {
                      return jobPost.workType == dropdownValue2 && jobPost.gender =="Female";
                    }).toList();
                  }
                  else if(dropdownValue2 == "All"  && selectedOption3 == "Option 1"){
                    filteredJobPosts = snapshot.data!.where((jobPost) {
                      return jobPost.typesOfDiamond == dropdownValue1 && jobPost.gender =="Male";
                    }).toList();
                  }
                  else if(dropdownValue2 == "All"  && selectedOption3 == "Option 2"){
                    filteredJobPosts = snapshot.data!.where((jobPost) {
                      return jobPost.typesOfDiamond == dropdownValue1 && jobPost.gender =="Female";
                    }).toList();
                  }
                  else if(selectedOption3 == "Option 1") {
                    filteredJobPosts = snapshot.data!.where((jobPost) {
                      return jobPost.typesOfDiamond == dropdownValue1 && jobPost.workType == dropdownValue2 && jobPost.gender == "Male";
                    }).toList();

                  }
                  else if(selectedOption3 == "Option 2") {
                    filteredJobPosts = snapshot.data!.where((jobPost) {
                      return jobPost.typesOfDiamond == dropdownValue1 && jobPost.workType == dropdownValue2 && jobPost.gender == "Female";
                    }).toList();

                  }
                  // Your filtering logic here...

                  if (filteredJobPosts.length == 0) {
                    return const Center(
                      child: Text("No Record Found"),
                    );
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * .5,
                    child: ListView.builder(
                      itemCount: filteredJobPosts.length,
                      itemBuilder: (context, index) {
                        return ChangeNotifierProvider(
                          create: (context) => MyListTileState(),
                          child: MyListTile(
                            title: 'List Tile $index',
                            subTitle: 'Subtitle for Tile $index',
                            jobPost: filteredJobPosts[index],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),


          ],
        ),
      ),
    );
  }
  Future<bool> showExitPopup() async {
    return await showDialog(
      //show confirm dialogue
      //the return value will be from "Yes" or "No" options
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit an App?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            //return false when click on "NO"
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              print(" Navigation length : "+ "${navigator.widget.pages.length}");
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Home_Page_company()), (route) => false);
              SystemNavigator.pop();},
            //return true when click on "Yes"
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ??
        false; //if showDialouge had returned null, then return false
  }
  Future<void> diamondType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    final response = await http.get(
        Uri.parse(
            "https://diamond-platform-12038fd67b59.herokuapp.com/diamondtype/diamondtype"),
        headers: {
          'Authorization': 'Bearer $token',
        });
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data["data"]);
        setState(() {
          diamondTypeList = data["data"];
          //dropdownValue1 = diamondTypeList![0]["diamondType"];
          diamondTypeList!.insert(0, {"diamondType": "All"});
          dropdownValue1 = diamondTypeList![0]["diamondType"];
        });
      }
    } catch (e) {}
  }

  Future<void> workType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    final response = await http.get(
        Uri.parse(
            "https://diamond-platform-12038fd67b59.herokuapp.com/worktype/worktype"),
        headers: {
          'Authorization': 'Bearer $token',
        });
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          workTypeList = data["data"];
          workTypeList!.insert(0, {"diamondWorkType": "All"});
          dropdownValue2 = workTypeList![0]["diamondWorkType"];
        });
        //  print(workTypeList);
      }
    } catch (e) {}
  }
}

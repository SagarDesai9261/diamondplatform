//import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Add_location extends StatefulWidget {
  const Add_location({Key? key}) : super(key: key);

  @override
  State<Add_location> createState() => _Add_locationState();
}

class _Add_locationState extends State<Add_location> {
  LatLng? selectedLocation;

  void _navigateToMapScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        selectedLocation = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (selectedLocation != null)
              Column(
                children: [
                  Text("Company Location : "),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Latitue : "),
                      Text("${selectedLocation!.latitude}")
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Longitude : "),
                      Text("${selectedLocation!.longitude}")
                    ],
                  )
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToMapScreen,
              child: Text('Pick Location on Map'),
            ),
          ],
        ),
      ),
    );
  }
}
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Location _location = Location();
  LatLng? _currentLocation;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
    //selectedLocation = _currentLocation;
  }

  void _getLocation() async {
    try {
      var currentLocation = await _location.getLocation();
      setState(() {
        _currentLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        selectedLocation = _currentLocation;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Current Location on Map'),
      ),
      body: _currentLocation != null
          ? GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedLocation ?? _currentLocation!,
          zoom: 15.0,
        ),
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
        onTap: _onMapLongPress,
        markers: {
          Marker(
            markerId: MarkerId('current_location'),
            position: _currentLocation!,
            infoWindow: InfoWindow(title: 'Current Location'),
          ),
          Marker(
              markerId: MarkerId('selected_location'),
              position: selectedLocation!,
              infoWindow: InfoWindow(title: 'Selected Location')
          )
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async {
          if (selectedLocation != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("logitude", selectedLocation!.longitude.toString());
            prefs.setString("latitude", selectedLocation!.latitude.toString());
            Navigator.of(context).pop(selectedLocation);
          }///
        },
        child: Icon(Icons.check),
      ),
    );
  }
  void _onMapLongPress(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
  }
}

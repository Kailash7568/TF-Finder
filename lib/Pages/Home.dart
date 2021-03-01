
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'DetailScreen.dart';
import 'ListScreen.dart';

const kGoogleApiKey = "AIzaSyC2Ed8NK3U_TNsH74XBu7SUcu89yIw-WhU";


class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {
  double width,height;
  Query _ref;
  GoogleMapController mapController;
  Position pos;
  String result = "Not scanned yet!!  First scan QR code to pay";
  String query='';
  bool searchState = false;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

  }
  Future<String> currentLocation() async {
    pos=await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return 'Location Recieved';
  }
  void customLaunch(command) async{
    if(await canLaunch(command)){
      await launch(command);
    }

  }
  @override
  initState() {
    super.initState();
    requestPermission();
    _ref=FirebaseDatabase.instance.reference()
        .child('turfdata');
  }


  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
        customLaunch(result);
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  Future<void> requestPermission() async {
    await Permission.location.request();
  }

  Widget _buildTurfItem({Map turf}){
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(turf:turf),
          ),
        );
      },
      child:Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.fromLTRB(5.0,0.0, 5.0, 2.0),
        height: 400,
        width: 330,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0,3),
              )
            ]
        ),

        child:Wrap(
          children: <Widget>[

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,

              children: [
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset('assets/t1.jpg',
                            width: 154,
                            height: 90,

                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 9,
                          child: SizedBox(
                            height: 25,
                            width: 70,
                            child: RaisedButton(onPressed: () {},
                              child: Text("PlaySpots",style: TextStyle(fontSize: 8,fontWeight: FontWeight.bold),),color: Colors.red,shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                side: BorderSide(color: Colors.grey),
                              ),
                              textColor: Colors.white,
                              elevation: 0.0,),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 11,),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/t2.jpg',
                        width: 154,
                        height: 90,

                      ),
                    ),
                  ],
                ),


                Text(turf['TurfName'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10,),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                      color: Colors.black,
                      size: 15,
                    ),
                    SizedBox(width:6,),
                    Text(turf['Location'],
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 90,),
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 18,
                      child: Icon(
                        Icons.bookmark_sharp,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.airport_shuttle,
                      color: Colors.black,
                      size: 15,
                    ),
                    SizedBox(width:6,),
                    Text(turf['Distance'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),

                  ],
                ),
                SizedBox(height: 5,),
                Row(
                  children: <Widget>[
                    Text(turf['Pricing'],
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4,),
                    Text('.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4,),
                    Text(turf['PreferredFormat'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: <Widget>[
                    RaisedButton(onPressed: () {},child: Text("Book Now"),color: Colors.green,shape:RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.green)
                    ),
                    textColor: Colors.white,),
                    SizedBox(width: 10,),
                    RaisedButton(onPressed: () {
                      customLaunch(turf['LocationLink']);
                    },child: Text("Directions"),color: Colors.white,shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Colors.grey)
                    ),
                      textColor: Colors.black,
                    elevation: 0.0,)

                  ],
                ),

              ]
          ),
        ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Turf Finder"),
      ),

      body:Stack(
        children: <Widget>[
          Positioned(
            top:0,
            bottom: 0,
            right: 0,
            left:0,
            child:  GoogleMap(
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target:LatLng(19.0760,72.8777),
                zoom: 20.0,
              ),
            ),),

          Positioned(
            top: 0,
            right: 0,
            left:0,
            bottom:0,
            child:FutureBuilder(
                future: currentLocation(),
                builder: (BuildContext context,AsyncSnapshot snapshot){
                  if(snapshot.hasData){
                    return Center(
                      child:
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target:LatLng(pos.latitude,pos.longitude),
                          zoom:10.0,
                        ),

                      ),
                    );

                  }
                  else{
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
            ),),

          Positioned(
            top: 0,
            right: 0,
            left: 0,

              child: Container(
                height:58,
               color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        IconButton(
                          onPressed: (){
                            //Navigator.push(context, MaterialPageRoute(builder: (context)=>Payment()));
                            _scanQR();
                          },
                          icon: Icon(Icons.qr_code_scanner,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                        Container(
                          width: 300,
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                      SizedBox(width: 10,),
                                     !searchState?Text('Search for Turfs, Tennis Courts'):
                                                               Expanded(
                                                                 child: TextField(
                                                                   decoration: InputDecoration(
                                                                     icon: Icon(Icons.search),
                                                                     hintText: 'Search....',
                                                                     hintStyle: TextStyle(
                                                                       color:Colors.grey,
                                                                     )
                                                                   ),
                                                                 ),
                                                               ),
                                    !searchState?IconButton(
                                          color: Colors.grey,
                                          icon: Icon(Icons.search),
                                          onPressed: () {
                                                setState(() {
                                                  searchState = !searchState;
                                                });
                                          },):
                                    IconButton(
                                      color: Colors.grey,
                                      icon: Icon(Icons.cancel),
                                      onPressed: () {
                                        setState(() {
                                          searchState = !searchState;
                                        });
                                      },),
                                ],


                            )
                        ),
                        SizedBox(width: 10,)

                      ],
                    ),
                  ],
                ),
              )
          ),


          Positioned(
              top:(MediaQuery.of(context).size.height)/2-60,
              left:(MediaQuery.of(context).size.width)/2+50,
              right: 10,
              child: RaisedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListScreen(),
                    ),
                  );
                },
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.grey)
                ),
                icon: Icon(Icons.toc),
                label: Text('View List'),
              )
          ),

          Positioned(
              top:(MediaQuery.of(context).size.height)/2-15,
              left: 5,
              right: 5,
              bottom:0,
              child:FutureBuilder(

                  future: currentLocation(),
                  builder: (BuildContext context,AsyncSnapshot snapshot){
                    if(snapshot.hasData){
                      return Center(
                        child:FirebaseAnimatedList(query: _ref, scrollDirection:Axis.horizontal,itemBuilder: (BuildContext context,DataSnapshot snapshot,Animation<double>animation,int index,
                            ){
                          Map turf = snapshot.value;

                          double distance=Geolocator.distanceBetween(pos.latitude,pos.longitude,double.parse(turf['Latitude']),double.parse(turf['Longitude']));
                          if((distance/1000)>20){
                            Map turf1= snapshot.value;
                            turf1.putIfAbsent('Distance', () => (distance/1000).toString()+' km');
                            return _buildTurfItem(turf: turf1);}

                        },),
                      );
                    }
                    else{
                      return Center(
                        child:CircularProgressIndicator(),
                      );
                    }

                  }
              )

          ),
        ],
      ),
    );
  }


}

class _MySearchDelegate extends SearchDelegate<String>{
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: 'Clear',
          icon: Icon(Icons.clear),
          onPressed: (){
          query= '';
          showSuggestions(context);
          }
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
   return IconButton(
     icon: AnimatedIcon(
       icon: AnimatedIcons.menu_arrow,progress: transitionAnimation,
     ),
     onPressed: (){
       close(context,null);
     },
   );
  }

  @override
  Widget buildResults(BuildContext context) {
   return Text(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    throw UnimplementedError();
  }
}

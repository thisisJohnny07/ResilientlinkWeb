import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';

class Maps extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  const Maps({super.key, required this.documentSnapshot});

  @override
  State<Maps> createState() => _MapsDialogState();
}

class _MapsDialogState extends State<Maps> {
  static const googlePlex = LatLng(6.5039, 124.8464);
  final TextEditingController _exactAdressController = TextEditingController();
  bool isEmpty = false;

  // Maintain a set of markers
  final Set<Marker> _markers = {};

  // Store the last tapped marker separately
  Marker? _lastTappedMarker;

  // Variable to store the location selected by the user
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
  }

  void _updateMarker(LatLng position) {
    setState(() {
      // If a previous tapped marker exists, remove it
      if (_lastTappedMarker != null) {
        _markers.remove(_lastTappedMarker);
      }

      // Add a new marker at the tapped position
      final markerId = MarkerId(position.toString());
      _lastTappedMarker = Marker(
        markerId: markerId,
        position: position,
        icon: BitmapDescriptor.defaultMarker,
      );

      _markers.add(_lastTappedMarker!);

      // Store the tapped location in a variable
      _selectedLocation = position;
    });
  }

  void _addLocationToFirestore() async {
    final exactAdress = _exactAdressController.text;
    if (exactAdress.isEmpty) {
      setState(() {
        isEmpty = true;
      });
      return;
    }
    if (_selectedLocation != null) {
      try {
        await FirebaseFirestore.instance
            .collection('donation_drive')
            .doc(widget.documentSnapshot.id)
            .collection('location')
            .add({
          'location': GeoPoint(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
          ),
          'exactAdress': exactAdress,
          'timestamp': FieldValue.serverTimestamp(),
        });
        Navigator.of(context).pop();
      } catch (error) {
        print('Error adding location: $error');
      }
    } else {
      print('No location selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      content: Column(
        children: [
          const Text(
            "Mark Drop Off Point",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          AdvisoryTextfield(
            textEditingController: _exactAdressController,
            label: "Exact Adress",
            line: 1,
            isEmpty: isEmpty,
          ),
          SizedBox(
            width: double.maxFinite,
            height: 370,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: googlePlex,
                zoom: 15,
              ),
              markers: _markers,
              onTap: (LatLng position) {
                _updateMarker(position);
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            _addLocationToFirestore();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

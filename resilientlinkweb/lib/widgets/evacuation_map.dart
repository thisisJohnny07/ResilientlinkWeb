import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';

class EvacuationMap extends StatefulWidget {
  const EvacuationMap({super.key});

  @override
  State<EvacuationMap> createState() => _MapsDialogState();
}

class _MapsDialogState extends State<EvacuationMap> {
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
        await FirebaseFirestore.instance.collection('evacuation_area').add({
          'location': GeoPoint(
            _selectedLocation!.latitude,
            _selectedLocation!.longitude,
          ),
          'exactAdress': exactAdress,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _selectedLocation = null;
          _markers.clear();
          _exactAdressController.clear();
          isEmpty = false;
        });
      } catch (error) {
        print('Error adding location: $error');
      }
    } else {
      print('No location selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdvisoryTextfield(
                textEditingController: _exactAdressController,
                label: "Exact Address",
                line: 1,
                isEmpty: isEmpty,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                const SizedBox(height: 12),
                ElevatedButton(
                    onPressed: () => _addLocationToFirestore(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF015490),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(50, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(Icons.pin_drop)),
              ],
            )
          ],
        ),
        const LocationList(),
        SizedBox(
          width: double.maxFinite,
          height: 370,
          child: GoogleMap(
            mapType: MapType.hybrid,
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
    );
  }
}

class LocationList extends StatefulWidget {
  const LocationList({super.key});

  @override
  State<LocationList> createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('evacuation_area').snapshots(),
      builder: (context, locationSnapshot) {
        if (locationSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (locationSnapshot.hasError) {
          return Center(child: Text('Error: ${locationSnapshot.error}'));
        }

        if (!locationSnapshot.hasData || locationSnapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final locationDocuments = locationSnapshot.data!.docs;
        final locationCount = locationDocuments.length;

        return Row(
          children: locationDocuments.map((locationDoc) {
            final locationData = locationDoc.data() as Map<String, dynamic>;
            final documentId = locationDoc.id;

            return Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10, right: 10, left: 8),
                  padding: const EdgeInsets.only(left: 8),
                  height: 30,
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 219, 234, 247),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF015490),
                        size: 18,
                      ),
                      Text(
                        locationData['exactAdress'],
                      ),
                      locationCount > 1
                          ? IconButton(
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('evacuation_area')
                                      .doc(documentId)
                                      .delete();
                                } catch (e) {
                                  print(e);
                                }
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 15,
                              ),
                            )
                          : const SizedBox(width: 13)
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

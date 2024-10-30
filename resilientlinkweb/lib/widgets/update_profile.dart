import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';

class UpdateProfile extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController facebookLinkController;
  final TextEditingController facebookNameController;
  final TextEditingController websiteController;
  final TextEditingController globeController;
  final TextEditingController smartController;
  final TextEditingController phoneController;
  final String adminId;
  const UpdateProfile(
      {super.key,
      required this.nameController,
      required this.addressController,
      required this.facebookLinkController,
      required this.facebookNameController,
      required this.websiteController,
      required this.globeController,
      required this.smartController,
      required this.phoneController,
      required this.adminId});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  bool isEmpty = false;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Wrap(
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 1000),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Please fill in all fields",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isEmpty ? Colors.red : Colors.black),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.nameController,
                            label: 'Name *',
                            line: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.addressController,
                            label: 'Adress *',
                            line: 1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController:
                                widget.facebookLinkController,
                            label: 'Facebook Link *',
                            line: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController:
                                widget.facebookNameController,
                            label: 'Facebook Name*',
                            line: 1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.websiteController,
                            label: 'Website *',
                            line: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.globeController,
                            label: 'Globe# *',
                            line: 1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.smartController,
                            label: 'Smart# *',
                            line: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.phoneController,
                            label: 'Telephone# *',
                            line: 1,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Align buttons to the right
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            if (widget.nameController.text.isEmpty ||
                                widget.addressController.text.isEmpty ||
                                widget.facebookLinkController.text.isEmpty ||
                                widget.facebookNameController.text.isEmpty ||
                                widget.websiteController.text.isEmpty ||
                                widget.globeController.text.isEmpty ||
                                widget.smartController.text.isEmpty ||
                                widget.phoneController.text.isEmpty) {
                              setState(() {
                                isEmpty = true;
                                _isLoading = false;
                              });
                              return;
                            }
                            try {
                              await FirebaseFirestore.instance
                                  .collection('admin')
                                  .doc(widget.adminId)
                                  .update({
                                'name': widget.nameController.text,
                                'address': widget.addressController.text,
                                'facebookLink':
                                    widget.facebookLinkController.text,
                                'facebookName':
                                    widget.facebookNameController.text,
                                'website': widget.websiteController.text,
                                'globe': widget.globeController.text,
                                'smart': widget.smartController.text,
                                'phone': widget.phoneController.text,
                              });

                              Navigator.pop(context);
                              setState(() {
                                _isLoading = false;
                              });
                            } catch (e) {
                              print(e);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF015490),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text("Update"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5), // Dark background overlay
            child: const Center(
              child: SpinKitFadingCube(
                color: Color(0xFF015490),
                size: 50.0,
              ),
            ),
          ),
      ],
    );
  }
}

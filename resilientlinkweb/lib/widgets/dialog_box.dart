import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';

class DialogBox extends StatefulWidget {
  final String buttonText;
  final Future<void> Function() onTap;
  final VoidCallback? pickImage;
  final TextEditingController? titleController;
  final TextEditingController? weatherSystemController;
  final TextEditingController? detailsController;
  final TextEditingController? hazardsController;
  final TextEditingController? precautionsController;

  final String? type;

  const DialogBox({
    super.key,
    required this.onTap,
    this.pickImage,
    this.titleController,
    this.weatherSystemController,
    this.detailsController,
    this.hazardsController,
    this.precautionsController,
    required this.buttonText,
    this.type,
  });

  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    if (widget.buttonText == "OK") {
      return Stack(
        children: [
          Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "User confirmation needed",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text("Are you sure you want to remove this ${widget.type}?"),
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
                          await widget.onTap();
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(widget.buttonText),
                      ),
                    ],
                  ),
                ],
              ),
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
    } else if (widget.buttonText == "UPDATE") {
      return Stack(
        children: [
          SingleChildScrollView(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
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
                        const Text(
                          "Update the information as needed",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        AdvisoryTextfield(
                          textEditingController: widget.titleController!,
                          label: 'Title',
                          line: 1,
                        ),
                        AdvisoryTextfield(
                          textEditingController:
                              widget.weatherSystemController!,
                          label: 'Weather System',
                          line: 1,
                        ),
                        AdvisoryTextfield(
                          textEditingController: widget.detailsController!,
                          label: 'Details',
                          line: 1,
                        ),
                        AdvisoryTextfield(
                          textEditingController: widget.hazardsController!,
                          label: 'Expectations',
                          line: 1,
                        ),
                        AdvisoryTextfield(
                          textEditingController: widget.precautionsController!,
                          label: 'Possibilities',
                          line: 1,
                        ),
                        GestureDetector(
                          onTap: widget.pickImage,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cloud_upload,
                                    size: 40,
                                    color: const Color(0xFF015490)
                                        .withOpacity(0.3),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Upload Image",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .end, // Align buttons to the right
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
                                await widget.onTap();
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF015490),
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              child: Text(widget.buttonText),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    } else {
      return const SizedBox.shrink();
    }
  }
}

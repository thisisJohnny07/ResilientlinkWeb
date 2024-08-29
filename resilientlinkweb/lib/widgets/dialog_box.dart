import 'package:flutter/material.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';

class DialogBox extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final VoidCallback? pickImage;
  final TextEditingController? titleController;
  final TextEditingController? weatherSystemController;
  final TextEditingController? detailsController;
  final TextEditingController? expectationsController;
  final TextEditingController? possibilitiesController;
  final TextEditingController? imageUrlController; // Add this if needed

  const DialogBox({
    super.key,
    this.onTap,
    required this.buttonText,
    this.titleController,
    this.weatherSystemController,
    this.detailsController,
    this.expectationsController,
    this.possibilitiesController,
    this.imageUrlController, // Add this if needed
    this.pickImage,
  });

  @override
  Widget build(BuildContext context) {
    if (buttonText == "OK") {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
              const Text("Are you sure you want to delete this advisory?"),
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
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(buttonText),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (buttonText == "UPDATE") {
      return SingleChildScrollView(
        child: Dialog(
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
                    const Text(
                      "Update the information as needed",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    AdvisoryTextfield(
                      textEditingController: titleController!,
                      label: 'Title',
                      line: 1,
                    ),
                    AdvisoryTextfield(
                      textEditingController: weatherSystemController!,
                      label: 'Weather System',
                      line: 1,
                    ),
                    AdvisoryTextfield(
                      textEditingController: detailsController!,
                      label: 'Details',
                      line: 1,
                    ),
                    AdvisoryTextfield(
                      textEditingController: expectationsController!,
                      label: 'Expectations',
                      line: 1,
                    ),
                    AdvisoryTextfield(
                      textEditingController: possibilitiesController!,
                      label: 'Possibilities',
                      line: 1,
                    ),
                    GestureDetector(
                      onTap: pickImage,
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
                                color: const Color(0xFF015490).withOpacity(0.3),
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
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF015490),
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(buttonText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Return a default widget if no conditions match
    return const SizedBox.shrink();
  }
}

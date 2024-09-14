import 'package:flutter/material.dart';
import 'package:resilientlinkweb/widgets/advisory_textfield.dart';
import 'package:resilientlinkweb/widgets/checkbox.dart';

class DialogBox extends StatefulWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final VoidCallback? pickImage;
  final TextEditingController? titleController;
  final TextEditingController? weatherSystemController;
  final TextEditingController? detailsController;
  final TextEditingController? hazardsController;
  final TextEditingController? precautionsController;
  final TextEditingController? imageUrlController;

  // for donation drive
  final TextEditingController? purposeController;
  final TextEditingController? itemsNeededController;
  final TextEditingController? proponentController;
  final ValueChanged<bool>? updateIsMonetary;
  final ValueChanged<bool>? updateIsAid;

  const DialogBox({
    super.key,
    this.onTap,
    this.pickImage,
    this.titleController,
    this.weatherSystemController,
    this.detailsController,
    this.hazardsController,
    this.precautionsController,
    this.imageUrlController,
    this.purposeController,
    this.itemsNeededController,
    this.proponentController,
    required this.buttonText,
    this.updateIsMonetary,
    this.updateIsAid,
  });

  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  bool _isMonetary = false;
  bool _isAid = false;

  @override
  Widget build(BuildContext context) {
    if (widget.buttonText == "OK") {
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
                    onPressed: widget.onTap,
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
      );
    } else if (widget.buttonText == "UPDATE") {
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
                      textEditingController: widget.titleController!,
                      label: 'Title',
                      line: 1,
                    ),
                    AdvisoryTextfield(
                      textEditingController: widget.weatherSystemController!,
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
                          onPressed: widget.onTap,
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
      );
    } else if (widget.buttonText == "CREATE") {
      return SingleChildScrollView(
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Wrap(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Fill up the information as needed",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.titleController!,
                            label: 'Title *',
                            line: 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.proponentController!,
                            label: 'Proponent *',
                            line: 1,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Inclusion *",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        CheckboxInput(
                          label: 'Monetary',
                          initialValue: _isMonetary,
                          onChanged: (bool? value) {
                            setState(() {
                              _isMonetary = value ?? false;
                              if (widget.updateIsMonetary != null) {
                                widget.updateIsMonetary!(_isMonetary);
                              }
                            });
                          },
                        ),
                        CheckboxInput(
                          label: 'Aid/Relief',
                          initialValue: _isAid,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAid = value ?? false;
                              if (widget.updateIsAid != null) {
                                widget.updateIsAid!(_isAid);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController: widget.purposeController!,
                            label: 'Purpose *',
                            line: 3,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AdvisoryTextfield(
                            textEditingController:
                                widget.itemsNeededController!,
                            label: 'Items Needed ',
                            line: 3,
                            readOnly: _isAid ? false : true,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Image *",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.pickImage,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.341,
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
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                size: 40,
                                color: const Color(0xFF015490).withOpacity(0.3),
                              ),
                              Text(
                                "Upload a File",
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
                    const SizedBox(height: 5),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                          onPressed: widget.onTap,
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
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

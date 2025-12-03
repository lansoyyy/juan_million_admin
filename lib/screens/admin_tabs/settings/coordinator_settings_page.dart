import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';

class CoordinatorSettingsPage extends StatefulWidget {
  const CoordinatorSettingsPage({super.key});

  @override
  State<CoordinatorSettingsPage> createState() =>
      _CoordinatorSettingsPageState();
}

class _CoordinatorSettingsPageState extends State<CoordinatorSettingsPage> {
  String standardContractUrl = '';
  String otherDocUrl = '';
  bool _configLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('AdminConfig')
          .doc('CoordinatorSettings')
          .get();
      if (!doc.exists) {
        setState(() {
          _configLoaded = true;
        });
        return;
      }
      final data = doc.data()!;
      setState(() {
        standardContractUrl = (data['standardContractUrl'] ?? '') as String;
        otherDocUrl = (data['otherDocUrl'] ?? '') as String;
        _configLoaded = true;
      });
    } catch (e) {
      setState(() {
        _configLoaded = true;
      });
    }
  }

  String _getContentTypeFromExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _uploadTemplate(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.single;
      if (pickedFile.bytes == null) return;

      final fileName = pickedFile.name;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            content: SizedBox(
              height: 80,
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Uploading document... Please wait',
                      style: TextStyle(fontFamily: 'Regular'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final ref = firebase_storage.FirebaseStorage.instance
          .ref('AdminTemplates/coordinator/$type/$fileName');
      final bytes = pickedFile.bytes!;
      final contentType = _getContentTypeFromExtension(fileName);

      await ref.putData(
        bytes,
        firebase_storage.SettableMetadata(contentType: contentType),
      );

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('AdminConfig')
          .doc('CoordinatorSettings')
          .set(
        {
          if (type == 'contract') 'standardContractUrl': url,
          if (type == 'other') 'otherDocUrl': url,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      setState(() {
        if (type == 'contract') {
          standardContractUrl = url;
        } else {
          otherDocUrl = url;
        }
      });
    } on firebase_storage.FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _setApproval(String coordinatorId, bool approved) async {
    await FirebaseFirestore.instance
        .collection('Coordinator')
        .doc(coordinatorId)
        .update({'approved': approved});
  }

  void _showDocumentsDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Submitted Documents',
            fontSize: 18,
            fontFamily: 'Bold',
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDocumentPreview(
                    'DTI / SEC Registration',
                    data['dtiSecUrl'] as String? ?? '',
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentPreview(
                    'Signed Contract',
                    data['contractUrl'] as String? ?? '',
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentPreview(
                    'Valid Government ID',
                    data['govIdUrl'] as String? ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentPreview(String title, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: title,
          fontSize: 14,
          fontFamily: 'Bold',
        ),
        const SizedBox(height: 8),
        if (url.isEmpty)
          const Text(
            'No file submitted',
            style: TextStyle(fontFamily: 'Regular', color: Colors.grey),
          )
        else
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableText(
                      url,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: TextWidget(
          text: 'Coordinator Settings',
          fontSize: 18,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: 'System Documents',
              fontSize: 16,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            TextWidget(
              text:
                  'Upload standard contracts and documentation used for coordinator onboarding.',
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            if (!_configLoaded)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildTemplateChip(
                    label: 'Standard Contract',
                    hasFile: standardContractUrl.isNotEmpty,
                    onUpload: () => _uploadTemplate('contract'),
                  ),
                  _buildTemplateChip(
                    label: 'Other Documentation',
                    hasFile: otherDocUrl.isNotEmpty,
                    onUpload: () => _uploadTemplate('other'),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            TextWidget(
              text: 'Coordinator Registrations',
              fontSize: 16,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            TextWidget(
              text:
                  'Review submitted details and documents. Approve registrations to activate coordinator accounts.',
              fontSize: 12,
              fontFamily: 'Regular',
              color: Colors.grey,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Coordinator')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading coordinators'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No coordinator registrations found.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final approved = (data['approved'] ?? false) as bool;
                      final name = (data['name'] ?? '') as String;
                      final email = (data['email'] ?? '') as String;

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: approved ? primary : Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: name.isEmpty ? '(No name)' : name,
                                      fontSize: 14,
                                      fontFamily: 'Bold',
                                    ),
                                    const SizedBox(height: 4),
                                    TextWidget(
                                      text: email,
                                      fontSize: 12,
                                      fontFamily: 'Regular',
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: approved
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.orange
                                                    .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: TextWidget(
                                            text: approved
                                                ? 'Approved'
                                                : 'Pending',
                                            fontSize: 10,
                                            fontFamily: 'Bold',
                                            color: approved
                                                ? Colors.green
                                                : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => _showDocumentsDialog(doc),
                                    child: TextWidget(
                                      text: 'View Documents',
                                      fontSize: 12,
                                      fontFamily: 'Bold',
                                      color: blue,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: approved
                                            ? null
                                            : () => _setApproval(doc.id, true),
                                        child: const Text('Approve'),
                                      ),
                                      TextButton(
                                        onPressed: !approved
                                            ? null
                                            : () => _setApproval(doc.id, false),
                                        child: const Text('Disapprove'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip({
    required String label,
    required bool hasFile,
    required VoidCallback onUpload,
  }) {
    return InkWell(
      onTap: onUpload,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: blue.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
              color: hasFile ? primary : blue,
              size: 18,
            ),
            const SizedBox(width: 8),
            TextWidget(
              text: hasFile ? '$label (Uploaded)' : label,
              fontSize: 12,
              fontFamily: 'Bold',
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}

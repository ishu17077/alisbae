import 'package:alisbae/service/pdf_file/pdf_file.dart';
import 'package:alisbae/state_management/book_import_export/book_import_export_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class ImportBook extends StatefulWidget {
  const ImportBook({super.key});

  @override
  State<ImportBook> createState() => _ImportBookState();
}

class _ImportBookState extends State<ImportBook> {
  final TextEditingController _bookNameController = TextEditingController();

  final TextEditingController _bookAuthorController = TextEditingController();

  final TextEditingController _bookDescriptionController =
      TextEditingController();

  late final BookImportExportCubit _bookImportExportCubit;

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    _bookImportExportCubit = context.read<BookImportExportCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Import Book")),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                horizontal: 30,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTextField(
                    _bookNameController,
                    label: "Book's Name",
                    hint: "Name of the book",
                    isRequired: true,
                  ),

                  _buildTextField(
                    _bookAuthorController,
                    label: "Author's Name",
                    hint: "Name of the book",
                    isRequired: false,
                  ),

                  _buildTextField(
                    _bookDescriptionController,
                    label: "Book's Description",
                    hint: "Anything related to the book",
                    lines: 5,
                    isRequired: false,
                  ),
                  SizedBox(height: 10),
                  BlocConsumer<BookImportExportCubit, BookImportExportState>(
                    listener: (context, state) {
                      if (state is BookSelected) {
                        if (_bookNameController.text.isEmpty) {
                          setState(() {
                            _bookNameController.text = p
                                .basenameWithoutExtension(state.pdf.fileName);
                          });
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is BookSelected) {
                        return _buildSelectPdfButton(state.pdf, () async {
                          await _bookImportExportCubit.selectBook();
                        });
                      }
                      return _buildSelectPdfButton(null, () {
                        _bookImportExportCubit.selectBook();
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  _buildImportButton(
                    onTap: () {
                      if (_bookImportExportCubit.state is! BookSelected) {
                        return _showSnackBar(context, msg: "No file uploaded.");
                      }
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        return _showSnackBar(
                          context,
                          msg: "No book name provided.",
                        );
                      }

                      _bookImportExportCubit.importBook(
                        (_bookImportExportCubit.state as BookSelected).pdf,
                        bookName: _bookNameController.text,
                        author: _bookAuthorController.text,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, {required String msg}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildImportButton({required VoidCallback onTap}) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 19, 148, 187),
                Color.fromARGB(255, 1, 56, 128),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_file_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                "Import Book",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectPdfButton(Pdf? pdf, Function() onTap) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: pdf != null
                    ? [Color(0xFFEF4444), Color(0xFFB91C1C)]
                    : [Color(0xFF14B8A6), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(80),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withAlpha(60)),
                    ),
                    child: Icon(
                      pdf == null
                          ? Icons.upload_file_rounded
                          : Icons.import_contacts_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pdf?.fileName != null ? pdf!.fileName : "Select Book",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        pdf?.file.path == null
                            ? Text(
                                "Choose a PDF or document to import",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String label,
    required String hint,
    required bool isRequired,
    int lines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return "Book name cannot be empty";
          }
          return null;
        },
        maxLines: lines,
        minLines: lines,
        decoration: InputDecoration(
          label: Text(label),
          hint: Text(hint),
          labelStyle: TextStyle(),
          alignLabelWithHint: true,
          floatingLabelAlignment: FloatingLabelAlignment.center,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

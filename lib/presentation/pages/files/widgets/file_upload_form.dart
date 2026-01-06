import 'package:flutter/material.dart';
import '../../../../data/datasources/local/app_database.dart';
import '../../../../services/file_service.dart';
import '../../../widgets/file_source_picker.dart';

class FileUploadData {
  final int participantId;
  final String title;
  final String type;
  final FileMetadata file;
  final DateTime fileDate;

  const FileUploadData({
    required this.participantId,
    required this.title,
    required this.type,
    required this.file,
    required this.fileDate,
  });
}

class FileUploadForm extends StatefulWidget {
  const FileUploadForm({
    super.key,
    required this.participants,
    required this.fileService,
    required this.onSubmit,
    this.onCancel,
    this.initialParticipantId,
    this.initialTitle,
    this.initialType = 'GENERAL',
    this.initialFileDate,
    this.documentTypes = const [
      'GENERAL',
      'PRESCRIPTION',
      'REFERRAL',
      'ANALYSIS',
    ],
    this.showActions = true,
  });

  final List<Participant> participants;
  final FileService fileService;
  final Future<void> Function(FileUploadData data) onSubmit;
  final VoidCallback? onCancel;
  final int? initialParticipantId;
  final String? initialTitle;
  final String initialType;
  final DateTime? initialFileDate;
  final List<String> documentTypes;
  final bool showActions;

  @override
  State<FileUploadForm> createState() => _FileUploadFormState();
}

class _FileUploadFormState extends State<FileUploadForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  String? _selectedType;
  int? _selectedParticipantId;
  FileMetadata? _selectedFile;
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _selectedType = widget.initialType;
    _selectedParticipantId = widget.initialParticipantId;
    _selectedDate = widget.initialFileDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final files = await showFileSourcePicker(
      context,
      widget.fileService,
      allowMultipleFromGallery: false,
    );
    if (files.isEmpty) return;

    setState(() {
      _selectedFile = files.first;
      _selectedDate = files.first.createdAt;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate.isBefore(DateTime(1900)) ? now : _selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final participantId = widget.participants.any((p) => p.id == _selectedParticipantId)
        ? _selectedParticipantId
        : (widget.participants.isNotEmpty ? widget.participants.first.id : null);

    if (participantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте участника, чтобы загрузить файл')),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите файл для загрузки')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final resolvedType = widget.documentTypes.contains(_selectedType)
          ? _selectedType!
          : (_selectedType ??
              (widget.documentTypes.isNotEmpty ? widget.documentTypes.first : widget.initialType));

      await widget.onSubmit(
        FileUploadData(
          participantId: participantId,
          title: _titleController.text.trim(),
          type: resolvedType,
          file: _selectedFile!,
          fileDate: _selectedDate,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Не удалось загрузить файл: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantId = widget.participants.any((p) => p.id == _selectedParticipantId)
        ? _selectedParticipantId
        : (widget.participants.isNotEmpty ? widget.participants.first.id : null);
    final selectedType = widget.documentTypes.contains(_selectedType)
        ? _selectedType
        : (widget.documentTypes.isNotEmpty ? widget.documentTypes.first : null);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Select Participant'),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: participantId,
            items: widget.participants
                .map(
                  (participant) => DropdownMenuItem<int>(
                    value: participant.id,
                    child: Text('${participant.emoji} ${participant.name}'),
                  ),
                )
                .toList(),
            onChanged: _isSubmitting ? null : (value) => setState(() => _selectedParticipantId = value),
            decoration: _inputDecoration(),
            validator: (_) {
              if (widget.participants.isEmpty) {
                return 'Нет доступных участников';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _SectionLabel('Select File'),
          const SizedBox(height: 8),
          _FilePickerField(
            isDisabled: _isSubmitting,
            fileName: _selectedFile?.fileName,
            onTap: _pickFile,
          ),
          const SizedBox(height: 16),
          _SectionLabel('Document Title'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            enabled: !_isSubmitting,
            decoration: _inputDecoration(
              hintText: 'e.g., Blood Test Results - Dec 2025',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Введите название документа';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _SectionLabel('Document Type'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedType,
            items: widget.documentTypes
                .map(
                  (type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(_formatType(type)),
                  ),
                )
                .toList(),
            onChanged: _isSubmitting ? null : (value) => setState(() => _selectedType = value),
            decoration: _inputDecoration(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Выберите тип документа';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _SectionLabel('Document Date'),
          const SizedBox(height: 8),
          FormField<DateTime>(
            validator: (_) => null,
            builder: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _isSubmitting ? null : _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(_selectedDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                if (state.hasError) ...[
                  const SizedBox(height: 6),
                  Text(
                    state.errorText!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          if (widget.showActions) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload),
                  label: Text(_isSubmitting ? 'Uploading...' : 'Upload'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  String _formatType(String type) {
    if (type.isEmpty) return type;
    final lower = type.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _FilePickerField extends StatelessWidget {
  final VoidCallback onTap;
  final String? fileName;
  final bool isDisabled;

  const _FilePickerField({
    required this.onTap,
    required this.fileName,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  fileName ?? 'Choose File',
                  style: theme.textTheme.bodyMedium?.copyWith(
                        color: fileName == null
                            ? Colors.grey.shade600
                            : theme.colorScheme.onSurface,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.upload_file,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

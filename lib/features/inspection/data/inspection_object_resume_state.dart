/// Serializable in-session state to reopen an inspection with prior field values.
class InspectionObjectResumeState {
  const InspectionObjectResumeState({
    required this.checklist,
    required this.temperatureText,
    required this.pressureText,
    required this.vibrationText,
    required this.comment,
    required this.defectFound,
    required this.defectDescription,
    required this.severityIndex,
    required this.photoPaths,
    this.audioPath,
  });

  final List<bool> checklist;
  final String temperatureText;
  final String pressureText;
  final String vibrationText;
  final String comment;
  final bool defectFound;
  final String defectDescription;
  final int severityIndex;
  final List<String> photoPaths;
  final String? audioPath;
}

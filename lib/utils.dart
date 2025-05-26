import 'package:uuid/uuid.dart';

String randomId() {
  return Uuid().v4();
}

const String pathwayDataDirPath = 'assets/_data';

const String pathwayJsonPath = '$pathwayDataDirPath/pathway.json';

String getSublevelJsonPath(String sublevelId) =>
    '$pathwayDataDirPath/steps/$sublevelId.json';

const String demoVideoPath = '$pathwayDataDirPath/videos/_demo.mp4';

const String demoNotePath = '$pathwayDataDirPath/notes/_demo.pdf';

String getAssignmentIframeUrl(String assignmentId) =>
    'https://assignments.codeyogi.io/a/$assignmentId';

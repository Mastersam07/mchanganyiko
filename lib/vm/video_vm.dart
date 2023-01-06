import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart' as syspaths;

class VideoVm extends ChangeNotifier {
  late ImagePicker picker;
  VideoVm() {
    picker = ImagePicker();
  }

  @override
  dispose() {
    controllers.values.map((controller) => controller.dispose());
    outputVidController?.dispose();
    super.dispose();
  }

  List<File> videos = <File>[];

  Map<int, VideoPlayerController> controllers = {};

  File? outputVideo;
  VideoPlayerController? outputVidController;

  void pickVideo() async {
    // ASSUMING VIDEOS CANT BE MORE THAN 2
    if (videos.length == 2) {
      return;
    }
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      videos.add(File(video.path));
      controllers.putIfAbsent(
          videos.length, () => VideoPlayerController.file(File(video.path)));
      controllers[videos.length]?.initialize().then((_) {});
      controllers[videos.length]?.play();
      notifyListeners();
    }
  }

  void combineVideo() async {
    if (videos.length != 2) {
      return;
    }
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    String rawDocumentPath = appDir.path;
    final outputPath = '$rawDocumentPath/output.mp4';
    const filter =
        " [0:v]scale=480:640,setsar=1[l];[1:v]scale=480:640,setsar=1[r];[l][r]hstack;[0][1]amix -vsync 0 ";
    await FFmpegKit.execute(
            '-y -i ${videos.first.path} -i ${videos.last.path} -filter_complex $filter $outputPath')
        .then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        outputVidController = VideoPlayerController.file(File(outputPath));
        outputVidController?.initialize().then((_) {});
        outputVidController?.play();
        outputVideo = File(outputPath);
      } else if (ReturnCode.isCancel(returnCode)) {
      } else {}
    });
    notifyListeners();
  }
}

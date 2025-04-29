import 'dart:io';
import 'package:get/get.dart';
import 'package:square_up_fresh/constants.dart';
import 'package:square_up_fresh/models/video.dart';
import 'package:video_compress/video_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Upload Video Controller
class UploadVideoController extends GetxController {
  // Compress the video before uploading
  Future<File?> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo?.file;
  }

  // Upload the actual video to Supabase Storage
  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    final videoFile = await _compressVideo(videoPath);

    final uploadedPath = await supabase.storage
        .from('videos') // Bucket name (videos)
        .upload(
      '$id.mp4',
      videoFile!,
    );

    if (uploadedPath.isEmpty) {
      throw Exception('Video upload failed: No path returned.');
    }

    final publicUrl = supabase.storage.from('videos').getPublicUrl('$id.mp4');
    return publicUrl;
  }

  // Get thumbnail of the video
  Future<File> _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  // Upload thumbnail image to Supabase Storage
  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    final thumbFile = await _getThumbnail(videoPath);

    final uploadedPath = await supabase.storage
        .from('thumbnails') // Bucket name (thumbnails)
        .upload(
      '$id.jpg',
      thumbFile,
    );

    if (uploadedPath.isEmpty) {
      throw Exception('Thumbnail upload failed: No path returned.');
    }

    final publicUrl = supabase.storage.from('thumbnails').getPublicUrl('$id.jpg');
    return publicUrl;
  }

  // Main upload function
  Future<void> uploadVideo(String songName, String caption, String videoPath) async {
    try {
      final uid = firebaseAuth.currentUser!.uid;
      final userDoc = await firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        Get.snackbar('Upload Error', 'User document does not exist.');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      final allDocs = await firestore.collection('videos').get();
      final len = allDocs.docs.length;

      final videoUrl = await _uploadVideoToStorage('Video $len', videoPath);
      final thumbnailUrl = await _uploadImageToStorage('Video $len', videoPath);

      final video = Video(
        username: userData['name'] ?? 'Unknown',
        uid: uid,
        id: 'Video $len',
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        profilePhoto: userData['profilePhoto'] ?? '',
        thumbnail: thumbnailUrl,
      );

      await firestore.collection('videos').doc('Video $len').set(video.toJson());

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error Uploading Video',
        e.toString(),
      );
    }
  }
}

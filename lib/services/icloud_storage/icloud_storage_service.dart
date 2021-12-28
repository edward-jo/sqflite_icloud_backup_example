abstract class IcloudStorageService {
  Future<IcloudStorageService> init();
  Future<void> uploadFile(
    String srcFilePath,
    String destFileName,
    void Function(Stream<double>) onProgress,
  );
  Future<void> downloadFile(
    String srcFileName,
    String destFilePath,
    void Function(Stream<double>) onProgress,
  );
}

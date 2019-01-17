import Foundation
import AVFoundation

/// This class is used for video compression you can compress the video taken from camera or choose from library.

public class VideoCompressor {
    
    /**
     This function is used for compressing the video from iphone camera or camera roll.
     - Parameters:
     - presetName: AVAssetExportPresetLowQuality, AVAssetExportPresetMediumQuality, AVAssetExportPresetHighQuality.
     - inputURL: This is the input video url which need to be compressed.
     - completionHandler: This completion handler will give you output url of compressed video.
     
     */
    public class func compressVideoWithQuality(inputURL : URL, completionHandler:@escaping (_ outputUrl: URL) -> ()) {
        
        let videoFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(path: "compressVideo.mp4")
        let savePathUrl =  URL(fileURLWithPath: videoFilePath)
        let sourceAsset = AVURLAsset(url: inputURL, options: nil)
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: sourceAsset, presetName: AVAssetExportPresetLowQuality)!
        assetExport.outputFileType = AVFileType.mov //QuickTimeMovie
        assetExport.outputURL = savePathUrl
        if FileManager.default.fileExists(atPath: videoFilePath) {
            try! FileManager.default.removeItem(atPath: videoFilePath)
        }
        assetExport.exportAsynchronously { () -> Void in
            
            switch assetExport.status {
            case AVAssetExportSession.Status.completed:
                DispatchQueue.main.async {
                    print("successfully exported at \(savePathUrl.path))")
                    completionHandler(savePathUrl)
                }
            case  AVAssetExportSession.Status.failed:
                print("failed \(String(describing: assetExport.error))")
            case AVAssetExportSession.Status.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("complete")
            }
        }
    }
}

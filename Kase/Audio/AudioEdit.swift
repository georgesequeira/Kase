//
//  AudioEdit.swift
//  Kase
//
//  Created by George Sequeira on 3/26/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import AVKit


class AudioEditor {
    static func exportAsset(_ asset: AVAsset, fileName: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        
        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists, removing \(trimmedSoundFileURL.absoluteString)")
            do {
                if try trimmedSoundFileURL.checkResourceIsReachable() {
                    print("is reachable")
                }
                
                try FileManager.default.removeItem(atPath: trimmedSoundFileURL.absoluteString)
            } catch {
                print("could not remove \(trimmedSoundFileURL)")
                print(error.localizedDescription)
            }
            
        }
        
        print("creating export session for \(asset)")
//        
//        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
//            exporter.outputFileType = AVFileType.m4a
//            exporter.outputURL = trimmedSoundFileURL
//            
//            let duration = CMTimeGetSeconds(asset.duration)
//            if duration < 5.0 {
//                print("sound is not long enough")
//                return
//            }
//            // e.g. the first 5 seconds
//            let startTime = CMTimeMake(0, 1)
//            let stopTime = CMTimeMake(5, 1)
//            exporter.timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
//            
//            // do it
//            exporter.exportAsynchronously(completionHandler: {
//                print("export complete \(exporter.status)")
//                
//                switch exporter.status {
//                case  AVAssetExportSessionStatus.failed:
//                    
//                    if let e = exporter.error {
//                        print("export failed \(e)")
//                    }
//                    
//                case AVAssetExportSessionStatus.cancelled:
//                    print("export cancelled \(String(describing: exporter.error))")
//                default:
//                    print("export complete")
//                }
//            })
//        } else {
//            print("cannot create AVAssetExportSession for asset \(asset)")
//        }
//        
    }

    //    static func originalExportAsset (_ asset: AVAsset, fileName: String) {
    //        // pulled from: https://www.rockhoppertech.com/blog/ios-trimming-audio-files/
    //        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    //        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
    //        print("saving to \(trimmedSoundFileURL.absoluteString)")
    //
    //        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
    //            print("sound exists, removing \(trimmedSoundFileURL.absoluteString)")
    //            do {
    //                if try trimmedSoundFileURL.checkResourceIsReachable() {
    //                    print("is reachable")
    //                }
    //
    //                try FileManager.default.removeItem(atPath: trimmedSoundFileURL.absoluteString)
    //            } catch {
    //                print("could not remove \(trimmedSoundFileURL)")
    //                print(error.localizedDescription)
    //            }
    //
    //        }
    //
    //        print("creating export session for \(asset)")
    //
    //        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
    //            exporter.outputFileType = AVFileType.m4a
    //            exporter.outputURL = trimmedSoundFileURL
    //
    //            let duration = CMTimeGetSeconds(asset.duration)
    //            if duration < 5.0 {
    //                print("sound is not long enough")
    //                return
    //            }
    //            // e.g. the first 5 seconds
    //            let startTime = CMTimeMake(0, 1)
    //            let stopTime = CMTimeMake(5, 1)
    //            exporter.timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
    //
    //            // do it
    //            exporter.exportAsynchronously(completionHandler: {
    //                print("export complete \(exporter.status)")
    //
    //                switch exporter.status {
    //                case  AVAssetExportSessionStatus.failed:
    //
    //                    if let e = exporter.error {
    //                        print("export failed \(e)")
    //                    }
    //
    //                case AVAssetExportSessionStatus.cancelled:
    //                    print("export cancelled \(String(describing: exporter.error))")
    //                default:
    //                    print("export complete")
    //                }
    //            })
    //        } else {
    //            print("cannot create AVAssetExportSession for asset \(asset)")
    //        }
    //    }
}

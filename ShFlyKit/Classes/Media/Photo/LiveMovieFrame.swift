//
//  LiveMovieFrame.swift
//  SHKit
//
//  Created by hsh on 2019/8/16.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


//给定的视频资源，抽取某个时间的帧
public class LiveMovieFrame: NSObject {
    
    
    //给定视频的URL获取某一帧
    class public func assetGetThumbImage(_ second:Int,frame:Int,url:URL)->UIImage?{
        let urlSet = AVURLAsset(url: url);
        let generator = AVAssetImageGenerator(asset: urlSet);
        //缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法
        let time:CMTime = CMTimeMake(Int64(second), Int32(frame));
        let cgImage = try? generator.copyCGImage(at: time, actualTime: nil);
        if cgImage != nil {
            let image = UIImage.init(cgImage: cgImage!);
            return image;
        }
        return nil;
    }
    
    
}

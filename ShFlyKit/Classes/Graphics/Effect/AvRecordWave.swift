//
//  AvRecordWave.swift
//  SHKit
//
//  Created by hsh on 2019/5/31.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AVFoundation
import Masonry


//自带录音音量测量的波纹图
class AvRecordWave: UIView ,DisplayDelegate{
    //Variable
    public var recorder:AVAudioRecorder!
    public var wave:LineWaver!
    
    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame);
        //初始化波浪
        wave = LineWaver()
        self.addSubview(wave);
        wave.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
        wave.initConfig();
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //初始化录音器
    private func setUpRecorder(){
        let url:URL = URL.init(fileURLWithPath: "/dev/null");
        let settings = [AVSampleRateKey:NSNumber.init(value: 44100),
                        AVFormatIDKey:NSNumber.init(value: kAudioFormatAppleLossless),
                        AVNumberOfChannelsKey:NSNumber.init(value: 2),
                        AVEncoderAudioQualityKey:NSNumber.init(value: AVAudioQuality.min.rawValue)];
        do {
            try self.recorder = AVAudioRecorder.init(url: url, settings: settings)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {}
        self.recorder.prepareToRecord();
        self.recorder.isMeteringEnabled = true;
        self.recorder.record();
    }
    
    
    //CADisplay回调
    func displayCalled() {
        recorder.updateMeters();
        let normalizedValue = CGFloat(pow(10, recorder.averagePower(forChannel: 0) / 40));
        wave.updateAmplitude(normalizedValue);
    }

    
    //开启定时器
    public func startMonitor(){
        setUpRecorder();
        HeatBeatTimer.shared.addDisplayTask(self);
    }
    
    
    //取消定时器
    public func stopMonitor(){
        HeatBeatTimer.shared.cancelDisplayTask(self);
    }
    
    
}

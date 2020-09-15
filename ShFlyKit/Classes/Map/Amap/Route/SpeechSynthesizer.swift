//
//  SpeechSynthesizer.swift
//  SHKit
//
//  Created by hsh on 2018/12/17.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit
import AVFoundation

///语音播放类

class SpeechSynthesizer: NSObject,AVSpeechSynthesizerDelegate{
    /// MARK: - Variable
    static  let shareInstance = SpeechSynthesizer.init()     //单例
    private var speechSynthesizer:AVSpeechSynthesizer!      

    
    /// MARK: - Load
    override init() {
        super.init();
        let session = AVAudioSession.sharedInstance()
        if let _ = try? session.setCategory(AVAudioSessionCategoryPlayback){}
        self.speechSynthesizer = AVSpeechSynthesizer()
        self.speechSynthesizer.delegate = self;
    }
    
    
    
    /// MARK: - Interface
    //是否正在播放
    public func isSpeaking()->Bool{
        return self.speechSynthesizer.isSpeaking;
    }
    
    
    
    //播放语音
    public func speakString(words:String)->Void{
        if self.speechSynthesizer != nil {
            let utterance = AVSpeechUtterance.init(string: words);
            utterance.voice = AVSpeechSynthesisVoice.init(language: "zh-CN");
            //iOS语音合成在iOS8及以下系统上语速异常
            let systemVersion:NSString = UIDevice.current.systemVersion as NSString
            if (systemVersion.floatValue < 0.0){
                utterance.rate = 0.25
            }else if (systemVersion.floatValue < 9.0){
                utterance.rate = 0.15
            }
            if (self.speechSynthesizer.isSpeaking){
                self.speechSynthesizer.stopSpeaking(at: .word)//下一个词就开始停止
            }
            self.speechSynthesizer.speak(utterance);//开始播放
        }
    }
    
    
    
    //语音播放停止
    public func stopSpeak()->Void{
        if (self.speechSynthesizer != nil) {
            self.speechSynthesizer.stopSpeaking(at: .immediate);//立即停止
        }
    }

}

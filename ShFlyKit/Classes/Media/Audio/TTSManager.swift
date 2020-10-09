//
//  TTSManager.swift
//  SHKit
//
//  Created by mac on 2020/9/9.
//  Copyright © 2020 hsh. All rights reserved.
//

import UIKit
import AVFoundation


//结束的类型
enum TTSStopType {
    case Immediate,WordEnd          //立即,完整词语结束
}


//状态枚举
enum TTSStatus{
    case Default,Start,Pause,Continue,Finish
}



///TTS语音播放
class TTSManager: NSObject , AVSpeechSynthesizerDelegate {
    //variable
    static let shared = TTSManager()
    //只读
    public private(set) var currentStatus:TTSStatus!
    public private(set) var synthesizer = AVSpeechSynthesizer()
    //私有属性
    private var speakString:String!
    private var utterance:AVSpeechUtterance!
    
    
    ///快捷使用方法
    class public func speak(_ text:String){
        TTSManager.shared.speakString = text ;
        TTSManager.shared.start();
    }
    
    
    //开始朗读
    public func start(){
        self.currentStatus = .Start;
        if self.synthesizer.isSpeaking || self.synthesizer.isPaused {
            self.synthesizer.stopSpeaking(at: .immediate);
        }
        self.synthesizer.speak(self.utterance);
    }
    
    
    //停止
    public func stop(_ type:TTSStopType)->Bool{
        var finish:Bool = false;
        if type == .Immediate {
            finish = self.synthesizer.stopSpeaking(at: .immediate);
        }else if (type == .WordEnd){
            finish = self.synthesizer.stopSpeaking(at: .word);
        }
        if finish {
            self.currentStatus = .Finish;
        }
        return finish;
    }
    
    
    //暂停
    public func pause(_ type:TTSStopType)->Bool{
        var finish:Bool = false;
        if type == .Immediate {
            finish = self.synthesizer.pauseSpeaking(at: .immediate);
        }else if (type == .WordEnd){
            finish = self.synthesizer.pauseSpeaking(at: .word);
        }
        if finish {
            self.currentStatus = .Pause;
        }
        return finish;
    }
    
    
    //继续
    public func continueSpeak(){
        self.currentStatus = .Continue;
        self.synthesizer.continueSpeaking();
    }

    
    
    //设置文本字符串
    var speakStr: String {
        set{
            self.speakString = newValue;
            self.utterance = AVSpeechUtterance.init(string: self.speakString);
            let voice:AVSpeechSynthesisVoice = AVSpeechSynthesisVoice.init(language: "zh-CN")!;
            self.utterance.voice = voice;
            self.utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
            self.utterance.preUtteranceDelay = 0;   //朗读本句前延迟
            self.utterance.postUtteranceDelay = 0;  //朗读本句后延迟
        }
        get{
            return self.speakString
        }
    }
    

}

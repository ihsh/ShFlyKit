//
//  AudioPlayer.swift
//  SHKit
//
//  Created by hsh on 2019/9/18.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import AVFoundation


///音频播放器
public class AudioPlayer: NSObject {
    //Variable
    private var audioPlayer:AVQueuePlayer!          //播放器
    
    
    //load
    override init() {
        super.init();
        do {
            //设置会话模式
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback);
            //激活会话
            try AVAudioSession.sharedInstance().setActive(true);
        } catch{}
        //创建播放对象
        self.audioPlayer = AVQueuePlayer()
    }

    
    
    private func playRemote(){
        let url = URL.init(fileURLWithPath: "");
        _ = AVPlayerItem.init(url: url);
    }
    
    
    public func beginPlay(){
        //资源URL
        guard let url = Bundle.main.url(forResource: "music.flac", withExtension: nil) else{
            return;
        };
        let playItem = AVPlayerItem.init(url: url);
        self.audioPlayer.insert(playItem, after: nil);
        self.audioPlayer.play();
    }
    
    
    public func pause(){
        self.audioPlayer.pause();
    }
    
    
    public func stop(){
        
        
    }
    
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }

}

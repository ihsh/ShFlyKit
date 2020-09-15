//
//  AudioPlayerUI.swift
//  SHKit
//
//  Created by hsh on 2019/11/6.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Masonry

class AudioPlayerUI: UIView {
    private var player:AudioPlayer!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        let playBtn = UIButton.initTitle("播放", textColor: UIColor.black, back: UIColor.white, font: kFont(16), super: self);
        playBtn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside);
        playBtn .mas_makeConstraints { (make) in
            make?.center.mas_equalTo()(self);
            make?.width.mas_equalTo()(60);
            make?.height.mas_equalTo()(40);
        }
        player = AudioPlayer();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    @objc private func playBtnClick(){
        player.beginPlay();
    }
    
    
}

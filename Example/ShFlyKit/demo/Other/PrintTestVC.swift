//
//  PrintTestVC.swift
//  SHKit
//
//  Created by hsh on 2019/9/17.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit


class PrintTestVC: UIViewController,SHPhoneAssetsToolDelegate {

    private var webView:WKWebView = WKWebView()
    private var imageV = UIImageView()
    private var photoTool = SHPhoneAssetsTool()
    private var images:[UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white;
        let mainV:UIView = UIScreenFit.createMainView();
        self.view.addSubview(mainV);

        mainV.addSubview(webView);
        webView.mas_makeConstraints { (maker) in
            maker?.left.top()?.mas_equalTo()(mainV);
            maker?.width.mas_equalTo()(ScreenSize().width/2.0);
            maker?.height.mas_equalTo()(200);
        }
        
        imageV = UIImageView()
        mainV.addSubview(imageV);
        imageV.mas_makeConstraints { (maker) in
            maker?.right.top()?.mas_equalTo()(mainV);
            maker?.left.mas_equalTo()(webView.mas_right)?.offset()(10);
            maker?.height.mas_equalTo()(200);
        }
        
        //打印
        let btn = UIButton.initTitle("打印", textColor: UIColor.black, back: UIColor.randomColor(), font: kFont(16), super: mainV);
        btn.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(mainV)?.offset()(30);
            maker?.bottom.mas_equalTo()(mainV)?.offset()(-10);
            maker?.width.mas_equalTo()(80);
            maker?.height.mas_equalTo()(50);
        }
        btn.addTarget(self, action: #selector(print), for: .touchUpInside);
        //查看远程文件
        let btn1 = UIButton.initTitle("在线查看", textColor: UIColor.black, back: UIColor.randomColor(), font: kFont(16), super: mainV);
        btn1.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(btn.mas_top)?.offset()(-10);
            maker?.width.centerX().height()?.mas_equalTo()(btn);
        }
        btn1.addTarget(self, action: #selector(preview), for: .touchUpInside);
        //查看本地文件
        let btn2 = UIButton.initTitle("本地文件", textColor: UIColor.black, back: UIColor.randomColor(), font: kFont(16), super: mainV);
        btn2.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(mainV)?.offset()(-10);
            maker?.width.height()?.mas_equalTo()(btn1);
            maker?.right.mas_equalTo()(mainV)?.offset()(-30);
        }
        btn2.addTarget(self, action: #selector(previewLocal), for: .touchUpInside);
        //打印图片
        let btn3 = UIButton.initTitle("图片", textColor: UIColor.black, back: UIColor.randomColor(), font: kFont(16), super: mainV);
        btn3.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(btn2.mas_top)?.offset()(-10);
            maker?.width.height()?.mas_equalTo()(btn2);
            maker?.centerX.mas_equalTo()(btn2);
        }
        btn3.addTarget(self, action: #selector(printImage), for: .touchUpInside);
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        let request = NSURLRequest.init(url: URL.init(string: "https://www.baidu.com")!);
        webView.load(request as URLRequest);
        
        photoTool.delegate = self;
        photoTool.cameraPhotoAlert(vc: self);
    }
    

    @objc private func print(){
        Printer.printWeb(webView) { (suc, error) in
            
        }
    }
    
    
    @objc private func printImage(){
        Printer.printImage(images) { (suc, eror) in
            
        }
    }
    
    
    @objc private func preview(){
        let tool = PreviewTool()
        let str = "http://42.243.111.150:56602/GXMIS.Server/service/DownloadFile.action?attachmentId=1469062";
        tool.previewRemote(str, title: "自定义标题") { (url, error) in
        
        }
    }
    
    
    @objc private func previewLocal(){
        let tool = PreviewTool()
        if let st = Bundle.main.path(forResource: "test", ofType: "doc"){
            tool.previewLocal(st,title: "自定义标题");
        }
    }
    
    
    //delegate
    func permissionDenyed(_ msg: String) {
        
    }
    
    
    func pickerImage(_ image: UIImage) {
        imageV.image = image;
        images.append(image);
    }

    
}

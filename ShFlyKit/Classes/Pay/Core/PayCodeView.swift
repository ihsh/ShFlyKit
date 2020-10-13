//
//  PayCodeView.swift
//  SHKit
//
//  Created by hsh on 2019/12/28.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import QuartzCore
import Masonry

@objc protocol PayCodeViewDelegate:NSObjectProtocol {
    //点击放大条形码
    @objc optional func amplifyBarCode(_ code:String)
    //点击放大二维码
    @objc optional func amplifyQRcode(_ code:String,logo:UIImage?)
}


//付款码界面
class PayCodeView: UIView , ScreenSnapToolDelegate {
    //Variable
    public weak var delegate:PayCodeViewDelegate?
    public var barEdge:CGFloat = 16             //条形码两边边距
    public var barHeight:CGFloat = 100          //条形码高度
    public var barTop:CGFloat = 55              //条形码距离顶部
    public var qrCodeW:CGFloat = 170            //二维码宽高
    public var qrTopToBar:CGFloat = 40          //二维码距离条形码底部
    public var barTitleL:UILabel!               //条形码点击提示
    public var coverV:PayCodeCover!             //截屏提示视图
    public var payBankV:PayBankPriorityV!       //支付方式图
    //Private
    public private(set) var barCodeImgV:UIImageView!//条形码
    public private(set) var qrCodeImgV:UIImageView! //二维码
    private var showCode:String!                    //显示的内容
    private var showLogo:UIImage?                   //显示的Logo
    private var currentLight:CGFloat!               //当前屏幕亮度
    
    
    //初始化
    public func makeUI()->Void{
        //背景色
        self.backgroundColor = UIColor.white;
        //条形码
        barCodeImgV = UIImageView()
        self.addSubview(barCodeImgV);
        barCodeImgV.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self)?.offset()(barEdge);
            make?.right.mas_equalTo()(self)?.offset()(-barEdge);
            make?.top.mas_equalTo()(self)?.offset()(barTop);
            make?.height.mas_equalTo()(barHeight);
        }
        //条形码标题
        barTitleL = UILabel.initText("点击可查看付款码数字", font: kFont(14), textColor: UIColor.colorHexValue("9E9E9E"), alignment: .center, super: self);
        barTitleL.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(barCodeImgV);
            make?.bottom.mas_equalTo()(barCodeImgV.mas_top)?.offset()(-10);
        }
        //二维码
        qrCodeImgV = UIImageView()
        self.addSubview(qrCodeImgV);
        qrCodeImgV.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(self);
            make?.top.mas_equalTo()(barCodeImgV.mas_bottom)?.offset()(qrTopToBar);
            make?.width.height()?.mas_equalTo()(qrCodeW);
        }
        //支付方式
        payBankV = PayBankPriorityV()
        self.addSubview(payBankV);
        payBankV.mas_makeConstraints { (make) in
            make?.left.right()?.bottom()?.mas_equalTo()(self);
            make?.height.mas_equalTo()(PayBankPriorityV.height);
        }
        //添加截屏/录屏通知
        ScreenSnapTool.shared.registerSnapNotifa(delegate: self);
        //截屏/录屏提醒视图
        coverV = PayCodeCover();
        coverV.makeUI();
        self.addSubview(coverV);
        coverV.isHidden = true;
        coverV.mas_makeConstraints { (make) in
            make?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
    }
    
    
    //显示二维码
    public func updatePayCode(code:String,logo:UIImage?){
        //显示的文本
        showCode = code;
        showLogo = logo;
        //显示条形码
        let width = barCodeImgV.width == 0 ? ScreenSize().width - barEdge * 2 : barCodeImgV.width;
        QRCodeGenerator.generateBarCode(content: code, imageV: barCodeImgV, size: CGSize(width: width, height: barHeight));
        //二维码是否需要logo
        if logo == nil {
            QRCodeGenerator.generateQRCode(content: code, imageV: qrCodeImgV, width: qrCodeW)
        }else{
            QRCodeGenerator.generateLogoQRCode(content: code, imageV: qrCodeImgV, width: qrCodeW, logo: logo!, logoSize: logo!.size, color: UIColor.black, radius: 0);
        }
    }
    
    
    //发生了截图
    func DidTakeScreenshot(image: UIImage, window: UIWindow) {
        coverV.isHidden = false;
    }
    
    
    //发生了录屏
    func CaptureStatusChange(_ capture: Bool) {
        coverV.isHidden = !capture;
    }

    
    //点击处理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event);
        //触摸点位置
        let touch = ((touches as NSSet).anyObject() as AnyObject);
        let point = touch.location(in: self);
        //是否点击条形码，二维码
        let barRect = barCodeImgV.frame;
        let barContains = barRect.contains(point);
        let qrRect = qrCodeImgV.frame;
        let qrContains = qrRect.contains(point);
        //放大二维码
        if qrContains {
            delegate?.amplifyQRcode?(showCode, logo: showLogo);
        }
        //放大条形码
        if barContains {
            delegate?.amplifyBarCode?(showCode);
        }
    }
    
    
}




//付款码截图时遮挡用视图
class PayCodeCover:UIView{
    public var icon:UIImageView!        //显示的图标，最上
    public var tipL:UILabel!            //文本-居中
    public var knowBtn:UIButton!        //我知道了按钮
    
    
    //构建UI
    public func makeUI(){
        //添加模糊视图
        let blur = BlurEffect.blurEffect(effect: .light, view: self);
        blur.mas_makeConstraints { (make) in
            make?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
        //背景色
        self.backgroundColor = .clear;
        //文本
        tipL = UILabel.initText("该功能用于向商家付款时出示使用，请不要将付款码及数字发送给他人", font: kFont(16), textColor: .black, alignment: .center, super: self);
        tipL.numberOfLines = 0;
        tipL.mas_makeConstraints { (make) in
            make?.centerY.mas_equalTo()(self);
            make?.left.mas_equalTo()(self)?.offset()(30);
            make?.right.mas_equalTo()(self)?.offset()(-30);
        }
        //图标
        icon = UIImageView()
        self.addSubview(icon);
        icon.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(self);
            make?.bottom.mas_equalTo()(tipL.mas_top)?.offset()(-30);
        }
        //按钮
        knowBtn = UIButton.initTitle("知道了", textColor: UIColor.colorHexValue("33A75D"), back: .clear, font: kFont(16), super: self);
        knowBtn.addTarget(self, action: #selector(knowBtnClick), for: .touchUpInside);
        knowBtn.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(self);
            make?.top.mas_equalTo()(tipL.mas_bottom)?.offset()(30);
            make?.height.mas_equalTo()(40);
            make?.width.mas_equalTo()(ScreenSize().width/2.0);
        }
        knowBtn.layer.cornerRadius = 5;
        knowBtn.layer.borderWidth = 0.6;
        knowBtn.layer.borderColor = UIColor.colorHexValue("33A75D").cgColor;
    }
    
    
    //我知道了按钮点击
    @objc private func knowBtnClick(){
        self.isHidden = true;
    }
    
    
}



//优先支付方式
class PayBankPriorityV: UIView {
    static var height:CGFloat = 60          //显示的高度
    
    public var logoImg:UIImageView!         //支付行logo
    public var nameL:UILabel!               //支付方式
    public var subTitleL:UILabel!           //优先选择...文案
    public var arrow:UIImageView!           //箭头
    public var line:UIView!                 //分割线
    public var clickBtn:UIButton!           //点击按钮
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        //分割线
        line = UIView()
        line.backgroundColor = UIColor.colorHexValue("F3F4F5")
        self.addSubview(line);
        line.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(self)?.offset()(16);
            make?.right.mas_equalTo()(self)?.offset()(-16);
            make?.top.mas_equalTo()(self);
            make?.height.mas_equalTo()(0.6);
        }
        nameL = UILabel.initText(nil, font: kFont(16), textColor: .black, alignment: .left, super: self);
        nameL.mas_makeConstraints { (make) in
            make?.centerY.mas_equalTo()(self.centerY)?.offset()(-6);
            make?.left.mas_equalTo()(line)?.offset()(30);
        }
        subTitleL = UILabel.initText("优先使用此支付方式付款", font: kFont(14), textColor: UIColor.colorHexValue("9E9E9E"), alignment: .left, super: self);
        subTitleL.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(nameL.mas_bottom);
            make?.left.mas_equalTo()(nameL);
        }
        logoImg = UIImageView()
        self.addSubview(logoImg);
        logoImg.mas_makeConstraints { (make) in
            make?.left.mas_equalTo()(line);
            make?.centerY.mas_equalTo()(self);
        }
        arrow = UIImageView()
        arrow.image = UIImage.name("ic_arrow_right_gray");
        self.addSubview(arrow);
        arrow.mas_makeConstraints { (make) in
            make?.centerY.mas_equalTo()(self);
            make?.right.mas_equalTo()(line);
        }
        clickBtn = UIButton()
        self.addSubview(clickBtn);
        clickBtn.mas_makeConstraints { (make) in
            make?.left.top()?.right()?.bottom()?.mas_equalTo()(self);
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //更新显示
    public func updateBankAndLogo(_ title:String,logo:UIImage?){
        logoImg.image = logo;
        nameL.text = title;
    }
    
    
}

//
//  PayFuncView.swift
//  SHKit
//
//  Created by hsh on 2019/8/5.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Masonry

///支付结果页查询代理
protocol PayFuncDelegate:NSObjectProtocol {
    //支付结果回调,是否来自SDK
    func payResult(suc:Bool,fromSDk:Bool)
    //刷新账单界面
    func refreshPage(msg:String)
    //发起支付
    func callPay(type:PayType,orderNo:String)
    //修改支付选项数据 - 可选
    func editPayTypeDatas(data:[PayTypeData])->[PayTypeData]?
}


///支付选择页面
class PayFuncView: UIView , UIGestureRecognizerDelegate , HeatBeatTimerDelegate , PayTypeDelegate{
    //Variable
    public weak var delegate:PayFuncDelegate?
    //界面元素--从上到下,给出界面元素，可以自定义子类，往上面加元素
    public var contentV:UIView!                     //内容视图
    public var boardV:SHBorderView!                 //关闭一栏
    public var centerL:UILabel!                     //中心大标题
    public var payChooseV:PayTypeV!                 //支付选项界面
    public var payBtn:UIButton!                     //支付按钮
    //配置项
    public var foldRow:Int = 0                      //支付方式在这之后进行折叠,0-不折叠
    public var forbidTimeSpan:Int = 11              //间隔支付时间
    public var extraHeight:CGFloat = 0              //额外添加的高度，额外添加视图用
    private var viewHeight:CGFloat = 0              //视图高度
    //禁止操作相关
    private var pageControl:UIPageControl!          //动画点
    private var forbidV:UIView!                     //支付禁止界面
    private var secL:UILabel!                       //倒计时的文本
    //data
    private var orderNo:String!                     //订单号
    private var payAmount:Int = 0                   //支付金额
    private var payType:PayType?                    //支付方式
    
    
    
    ///Interface
    //调起支付界面
    public func callPay(money:Int,orderNo:String,hideUnInstall:Bool = false,delegate:PayFuncDelegate?){
        self.payAmount = money;
        self.orderNo = orderNo;
        self.delegate = delegate;
        //初始化界面元素
        initSubView();
        //显示金额
        let mulAttri = NSMutableAttributedString.init(string: "￥", attributes:
            [NSAttributedStringKey.foregroundColor : UIColor.colorHexValue("000000", alpha: 0.97),NSAttributedStringKey.font:kFont(32)]);
        mulAttri.append(NSAttributedString.init(string: String(format: "%.2f", Double(payAmount)/100.0),
                                                attributes: [NSAttributedStringKey.foregroundColor : UIColor.colorHexValue("000000", alpha: 0.97),NSAttributedStringKey.font:kFont(32)]))
        centerL.attributedText = mulAttri;
        //设置数据
        initData();
        //进场
        let window:UIWindow? = UIApplication.shared.delegate!.window ?? nil;
        if window != nil{
            window?.addSubview(self);
            self.mas_makeConstraints { (maker) in
                maker?.left.top()?.right()?.bottom()?.mas_equalTo()(window);
            }
            UIView.animate(withDuration: 0.3) {
                self.contentV.frame = CGRect(x: 0, y: ScreenSize().height-self.viewHeight, width: ScreenSize().width, height: self.viewHeight);
            }
        }
    }

    
    //移除视图
    @objc public func dismissFromSuper(){
        UIView.animate(withDuration: 0.3, animations: {
            self.contentV.frame = CGRect(x: 0, y: ScreenSize().height, width: ScreenSize().width, height: self.viewHeight);
        }) { (_) in
            self.removeFromSuperview();
        }
    }
    
    
    
    ///Delegate
    //TapGestureDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if forbidV.isHidden == false {
            return false;
        }
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            let location = gestureRecognizer.location(in: gestureRecognizer.view);
            if location.y >= ScreenSize().height - viewHeight{
                return false;
            }
        }
        return true
    }

    
    
    //HeatBeatTimerDelegate
    func timeCallTimes(times: Int, identifier: String) {
        //上次发起的时间
        let now = NSDate().timeIntervalSince1970;
        let span = now - (PayCheckV.shared.lastPayTime ?? now);
        let left = forbidTimeSpan - times - Int(span);
        if left < 1 {
            invalidateForbid();
        }else{
            let mulAttr = NSMutableAttributedString.init(string: String(format: "%ld", left), attributes: [NSAttributedStringKey.font : kFont(24),NSAttributedStringKey.foregroundColor:UIColor.colorHexValue("424456")]);
            mulAttr.append(NSAttributedString.init(string: "s", attributes: [NSAttributedStringKey.font : kFont(12),NSAttributedStringKey.foregroundColor:UIColor.colorHexValue("424456")]));
            secL.attributedText = mulAttr;
        }
    }
    
    
    
    ///Private
    @objc private func payBtnClick(){
        let now = NSDate().timeIntervalSince1970;
        let span = now - (PayCheckV.shared.lastPayTime ?? 0);
        //小于调用间隙，禁止操作
        if Int(span) < forbidTimeSpan {
            forbidV.isHidden = false;
            HeatBeatTimer.shared.addTimerTask(identifier: "payForbid", span: 1, repeatCount: 11, delegate: self);
        }else{//发起支付
            let type = payChooseV.choosePayType();
            if type != nil{
                delegate?.callPay(type: type!, orderNo: orderNo);
            }
        }
    }
    
    
    //点击空白区域消失
    @objc private func tapDismiss(){
        PayCheckV.shared.payCalled = false;
        self.dismissFromSuper();
    }
    
    
    //去掉禁止视图
    @objc private func invalidateForbid(){
        forbidV.isHidden = true;
        HeatBeatTimer.shared.cancelTaskForKey(taskKey: "payForbid")
    }
    
    
    //初始化选项数据
    private func initData(){
        let wechat = PayTypeData.initType(.WeChat);
        wechat.isSelect = true;
        let alipay = PayTypeData.initType(.ZhiFubao);
        let applePay = PayTypeData.initType(.ApplePay);
        let union = PayTypeData.initType(.Union);
        let cash = PayTypeData.initType(.Cash);
        let wallet = PayTypeData.initType(.Wallet);
        
        var array:[PayTypeData] = [ wallet,wechat,alipay,applePay,union,cash];
        //金额为0，不可点击,按钮不可点击
        if payAmount == 0 {
            for item in array{
                item.isForbid = true;
            }
        }
        payBtn.isEnabled = payAmount > 0;
        //自定义修改数据
        let data = delegate?.editPayTypeDatas(data: array);
        if data != nil{
            array = data!;
        }
        //设置支付样式
        payChooseV.delegate = self;
        //设置数据
        payChooseV.initTypes(array, foldRow: foldRow);
        //当前的高度
        let height = payChooseV.heightForPayType();
        //视图高度
        viewHeight = 16 + 56 + 16 + height + 140 + extraHeight;
        payChooseV.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(contentV);
            maker?.bottom.mas_equalTo()(payBtn.mas_top)?.offset()(-10);
            maker?.height.mas_equalTo()(height);
        }
    }
    
    
    //PayTypeDelegate
    func viewForUnFoldMore() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white;
        //线
        let line = UIView();
        line.backgroundColor = UIColor.colorHexValue("000000",alpha: 0.12);
        view.addSubview(line);
        line.mas_makeConstraints { (maker) in
            maker?.top.left()?.right()?.mas_equalTo()(view);
            maker?.height.mas_equalTo()(0.5);
        }
        let label = UILabel.initText("展开更多支付方式", font: kFont(12), textColor: UIColor.colorHexValue("9E9E9E"), alignment: .left, super: view);
        label.mas_makeConstraints { (maker) in
            maker?.centerY.mas_equalTo()(view);
            maker?.left.mas_equalTo()(24);
        }
        let imagV = UIImageView.init(image: UIImage.name("ic_payment_arrow_adown"));
        view.addSubview(imagV);
        imagV.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(label.mas_right)?.offset()(8);
            maker?.centerY.mas_equalTo()(label);
        }
        //点击按钮
        let btn = UIButton()
        view.addSubview(btn);
        btn.addTarget(self, action: #selector(unFoldPayTypes), for: .touchUpInside);
        btn.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(view);
        }
        return view;
    }
    
    
    //展开的视图高度
    func heightForUnFoldMore() -> CGFloat {
        return 56;
    }
    
    
    //自定义cell
    func customCellForIndex(indexPath: IndexPath, data: PayTypeData) -> UITableViewCell? {
        return nil;
    }
    
    
    //展开更多支付
    @objc private func unFoldPayTypes(){
        payChooseV.unFoldPayTypes();
        let height = payChooseV.heightForPayType();
        viewHeight = 16 + 56 + 16 + height + 140 + extraHeight;
        self.contentV.frame = CGRect(x: 0, y: ScreenSize().height-self.viewHeight, width: ScreenSize().width, height: self.viewHeight);
        payChooseV.mas_remakeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(contentV);
            maker?.bottom.mas_equalTo()(payBtn.mas_top)?.offset()(-10);
            maker?.height.mas_equalTo()(height);
        }
    }
    
    
    
    //初始化界面
    private func initSubView(){
        //遮罩
        self.backgroundColor = UIColor.colorHexValue("000000", alpha: 0.5);
        //点击手势
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapDismiss));
        self.addGestureRecognizer(tap);
        tap.delegate = self;
        //容器视图
        contentV = UIView()
        contentV.backgroundColor = UIColor.white;
        self.addSubview(contentV);
        contentV.frame = CGRect(x: 0, y: ScreenSize().height, width: ScreenSize().width, height: viewHeight);
        //关闭按钮
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage.name("navi_close_ex"), for: .normal);
        closeBtn.addTarget(self, action: #selector(dismissFromSuper), for: .touchUpInside);
        contentV.addSubview(closeBtn);
        closeBtn.mas_makeConstraints { (maker) in
            maker?.left.mas_equalTo()(contentV)?.offset()(2);
            maker?.top.mas_equalTo()(contentV);
            maker?.width.height()?.mas_equalTo()(48);
        }
        //支付金额
        centerL = UILabel.initText("￥0.00", font: kFont(32), textColor: UIColor.colorHexValue("000000", alpha: 0.87), alignment: .center, super: contentV);
        centerL.mas_makeConstraints { (maker) in
            maker?.centerX.mas_equalTo()(contentV);
            maker?.top.mas_equalTo()(contentV)?.offset()(40);
        }
        //支付按钮
        payBtn = UIButton()
        payBtn.setTitle("去支付", for: .normal);
        payBtn.layer.cornerRadius = 4;
        payBtn.layer.masksToBounds = true;
        payBtn.backgroundColor = UIColor.colorHexValue("F16622");
        payBtn.setTitleColor(UIColor.white, for: .normal);
        payBtn.addTarget(self, action: #selector(payBtnClick), for: .touchUpInside);
        contentV.addSubview(payBtn);
        payBtn.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(contentV)?.offset()(-16-ScreenBottomInset());
            maker?.left.mas_equalTo()(contentV)?.offset()(16);
            maker?.right.mas_equalTo()(contentV)?.offset()(-16);
            maker?.height.mas_equalTo()(56);
        }
        //支付方式
        payChooseV = PayTypeV()
        contentV.addSubview(payChooseV);
        payChooseV.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(contentV);
            maker?.bottom.mas_equalTo()(payBtn.mas_top)?.offset()(-16);
        }
        let titleL = UILabel.initText("选择支付方式", font: kFont(14), textColor: UIColor.colorHexValue("9E9E9E"), alignment: .left, super: contentV);
        titleL.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(payChooseV.mas_top);
            maker?.left.mas_equalTo()(contentV)?.offset()(16);
        }
        
        //禁止视图
        forbidV = UIView()
        forbidV.layer.cornerRadius = 2;
        forbidV.layer.masksToBounds = true;
        forbidV.backgroundColor = UIColor.white;
        contentV.addSubview(forbidV);
        forbidV.isHidden = true;
        contentV.addSubview(forbidV);
        forbidV.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(contentV);
        }
        //我知道了按钮
        let btn = UIButton.initTitle("我知道了", textColor: UIColor.colorHexValue("000000", alpha: 0.54), back: UIColor.white, font: kFont(16), super: forbidV);
        btn.addTarget(self, action: #selector(invalidateForbid), for: .touchUpInside);
        btn.layer.cornerRadius = 2;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = UIColor.colorHexValue("000000", alpha: 0.38).cgColor;
        forbidV.addSubview(btn);
        btn.mas_makeConstraints { (maker) in
            maker?.width.mas_equalTo()(104);
            maker?.height.mas_equalTo()(40);
            maker?.centerX.mas_equalTo()(forbidV);
            maker?.centerY.mas_equalTo()(forbidV)?.offset()(30);
        }
        let label = UILabel.initText("支付正在处理中，请稍后再试", font: kFont(16), textColor: UIColor.colorHexValue("000000",alpha: 0.87), alignment: .center, super: forbidV);
        label.mas_makeConstraints { (maker) in
            maker?.bottom.mas_equalTo()(btn.mas_top)?.offset()(-45);
            maker?.centerX.mas_equalTo()(forbidV);
        }
        //倒计时圈
        let circleV = UIView()
        circleV.backgroundColor = UIColor.colorHexValue("F3F4F5");
        circleV.layer.cornerRadius = 27;
        circleV.layer.masksToBounds = true;
        forbidV.addSubview(circleV);
        circleV.mas_makeConstraints { (maker) in
            maker?.width.height()?.mas_equalTo()(54);
            maker?.centerX.mas_equalTo()(forbidV);
            maker?.bottom.mas_equalTo()(label.mas_top)?.offset()(-16);
        }
        //倒计时
        secL = UILabel()
        circleV.addSubview(secL);
        secL.mas_makeConstraints { (maker) in
            maker?.center.mas_equalTo()(circleV);
        }
    }
    
    
    
}

//
//  SHWebBaseVC.swift
//  SHKit
//
//  Created by hsh on 2019/6/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import WebKit

//代理方法 - 建议创建一个UIView类，实现这些协议，成为WebVC的代理
@objc protocol SHWebBaseVCDelegate:NSObjectProtocol {
    @objc optional func webWillDoAction(_ action:String)           //JS回调action即将执行
    @objc optional func webDidDoAction(_ action:String)            //JS回调action执行完成
    @objc optional func moreBtnClick()                             //更多按钮已经点击
    @objc optional func allToustDismiss()                          //所有弹框消失
    
    @objc optional func webHandlePolicy(_ url:String)->Bool//决定是否加载
    @objc optional func webBeginLoad()
    @objc optional func webDidFinishLoad()
    @objc optional func webfailLoad()
}



//浏览器基础类
class SHWebBaseVC: UIViewController,WKNavigationDelegate,WKUIDelegate {
    //Varivale
    public weak var delegate:SHWebBaseVCDelegate?           //代理对象
    public var webView:SHWKWebView!                         //网页
    public var naviBar:SHWebNavBar!                         //导航栏
    public var config:SHWebConfig = SHWebConfig()           //配置信息
    public var actionHandler:SHJsActionHandler?             //Action处理--可自定义子类，实现自定义消息处理
    public var jsHandler:SHJavaScript = SHJavaScript()      //JS回调
    public var errorTipL:UILabel!                           //错误提示
    public var errorV:UIView!                               //错误提示视图
    //私有
    private var actionDict:[String:jsHandler] = [:]         //注册的JS动作
    private var request:URLRequest!                         //网页入口请求-第一个请求
    private var fileUrl:URL!                                //本地文件URL
    private var isLoadLocal:Bool = false                    //是否加载的是本地文件
    private var isNavHide:Bool!                             //进入网页前原生导航栏是否隐藏，用于退出恢复
    

    
    
    //Interface
    //通用初始化网页
    class public func webInit(title:String,url:String,autoTitle:Bool = true)->SHWebBaseVC{
        let vc = SHWebBaseVC();
        vc.config.navTitle = title;
        vc.config.isUseH5Title = autoTitle;
        vc.initWithUrl(url);
        return vc;
    }
    
    //加载本地html
    class public func webLocalPath(_ path:String,title:String)->SHWebBaseVC{
        let vc = SHWebBaseVC()
        vc.config.navTitle = title;
        vc.isLoadLocal = true;
        vc.fileUrl = URL.init(fileURLWithPath: path);
        return vc;
    }
    
    //注册自定义action并处理回调
    public func registerAction(_ action:String,call:@escaping jsHandler){
        actionDict.updateValue(call, forKey: action);
    }
    
    
    //构建请求
    public func initWithUrl(_ url:String){
        request = URLRequest(url: URL(string: url) ?? URL(string: "")!);
        request.timeoutInterval = config.timeoutInterval;
    }
    
    
    //执行JS
    public func doJs(_ jsStr:String,dataHandler:((_ data:Any)->Void)?,errorHandler:((_ error:NSError)->Void)?){
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(jsStr, completionHandler: { (data, error) in
                dataHandler?(data as Any);
                if (error != nil){
                    errorHandler?(error! as NSError);
                }
            })
        }
    }
    
    
    //Load
    override func viewDidLoad() {
        isNavHide = self.navigationController?.navigationBar.isHidden;
        self.navigationController?.navigationBar.isHidden = true;
        //初始化UI,JS
        self.initUI();
        self.initJSAction();
        //加载网页
        if (isLoadLocal) {
            do {
                let htmlStr = try String(contentsOf: fileUrl, encoding: .utf8);
                webView.loadHTMLString(htmlStr, baseURL: fileUrl);
            } catch {}
        }else{
            if (request != nil){
                webView.load(request);
            }else{
                errorV.isHidden = false;
                errorTipL.text = config.loadConfigError;
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.navigationBar.isHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.navigationBar.isHidden = isNavHide;
    }
    
    
    
    //observeKeypath
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            let number:NSNumber = change?[NSKeyValueChangeKey.newKey] as! NSNumber
            let progress:Float = number.floatValue;
            if (progress >= naviBar.progressView.progress){
                naviBar.progressView.setProgress(progress, animated: true);
            }else{
                naviBar.progressView.setProgress(progress, animated: false);
            }
        }else if (keyPath == "title"){
            let title = config.isUseH5Title ? webView.title : config.navTitle;
            if (title?.count ?? 0 > 0){
                naviBar.titleL.text = title;
            }else{
                naviBar.titleL.text = webView.isLoading ? "加载中" : "";
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context);
        }
    }
    
    
    
    //点击事件--返回
    @objc public func backBtnClick(){
        if (webView.canGoBack) {
            webView.goBack();
            return;
        }
        self.closeBtnClose();
    }
    
    
    //关闭按钮
    @objc public func closeBtnClose(){
        if ((self.navigationController?.presentedViewController) != nil) {
            self.navigationController?.dismiss(animated: true, completion: nil);
        }else if ((self.presentingViewController) != nil){
            self.dismiss(animated: true, completion: nil);
        }else{
            self.navigationController?.popViewController(animated: true);
        }
    }
    
    
    //更多的点击，重写或者实现代理
    @objc public func moreBtnClick(){
        let callMoreName = actionHandler?.callMoreName;
        if (callMoreName != nil && callMoreName!.count > 0) {
            self.doJs(String(format: "%@(右侧rightItem点击)", callMoreName!), dataHandler: nil, errorHandler: nil);
        }
    }
    
    
    
    //WKNavigationDelegate
    //提示框
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let vc = viewController();
        if (vc != nil && vc!.isViewLoaded && self.webView != nil && self.webView.superview != nil) {
            let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert);
            alert.addAction(UIAlertAction.init(title: config.alertKnow, style: .default, handler: { (action) in
                completionHandler()
            }))
            vc?.present(alert, animated: true, completion: nil);
        }else{
            completionHandler();
        }
    }
    
    
    //确认框
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let vc = viewController();
        if (vc != nil && vc!.isViewLoaded && self.webView != nil && self.webView.superview != nil) {
            let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert);
            alert.addAction(UIAlertAction.init(title: config.alertComfirm, style: .default, handler: { (action) in
                completionHandler(true);
            }))
            alert.addAction(UIAlertAction.init(title: config.alertCancel, style: .default, handler: { (action) in
                completionHandler(false);
            }))
            vc?.present(alert, animated: true, completion: nil);
        }else{
            completionHandler(false);
        }
    }
   
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let vc = viewController();
        if (vc != nil && vc!.isViewLoaded && self.webView != nil && self.webView.superview != nil) {
            let alert = UIAlertController.init(title: prompt, message: defaultText, preferredStyle: .alert);
            alert.addTextField { (textField) in
                textField.textColor = self.config.alertTextColor;
            }
            alert.addAction(UIAlertAction.init(title: config.alertKnow, style: .default, handler: { (action) in
                completionHandler(alert.textFields?.first?.text);
            }))
            vc?.present(alert, animated: true, completion: nil);
        }else{
            completionHandler(nil);
        }
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate?.webfailLoad?();
    }
    
    
    
    //在发送请求之前，决定是否跳转的代理
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString:String = navigationAction.request.url?.absoluteString ?? "";
        if (delegate?.webHandlePolicy?(urlString) == true) {
            decisionHandler(WKNavigationActionPolicy.cancel);
            return;
        }
        decisionHandler(WKNavigationActionPolicy.allow);
    }
    
    
    //准备加载页面 == UIWebView shouldStartLoadWithRequest
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        naviBar.progressView.isHidden = false;
        delegate?.webBeginLoad?()
        errorV.isHidden = true;
    }
    
    
    //内容开始==UIWebViewDelegate -- webViewDidStartLoad
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        delegate?.webBeginLoad?()
        errorV.isHidden = true;
    }
    
    
    //页面加载完成 ==UIWebViewDelegate - webViewDidFinishLoad
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if (webView.isLoading){
            return;
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.naviBar.progressView.isHidden = true;
            self.updateNavigationItems();
        }
        delegate?.webDidFinishLoad?()
    }
    
    
    //页面加载失败 == UIWebViewDelegate-didFailLoadWithError
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        naviBar.progressView.isHidden = true;
        updateNavigationItems();
        errorV.isHidden = false;
        errorTipL.text = config.loadErrorTip;
        delegate?.webfailLoad?();
    }
    
    
    //意外终止-重新加载
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload();
    }
    
    
    
    //Private Method
    private func initUI(){
        self.view.backgroundColor = UIColor.white;
        //导航栏
        naviBar = SHWebNavBar()
        naviBar.backItem.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside);
        naviBar.closeItem.addTarget(self, action: #selector(closeBtnClose), for: .touchUpInside);
        naviBar.moreItem.addTarget(self, action: #selector(moreBtnClick), for: .touchUpInside);
        self.view.addSubview(naviBar);
        //网页
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true;
        webView = SHWKWebView(frame: CGRect.zero, configuration: configuration);
        webView.backgroundColor = UIColor.green;
        webView.navigationDelegate = self;
        webView.uiDelegate = self;
        webView.allowsBackForwardNavigationGestures = true;
        //添加keypath
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil);
        self.view.addSubview(webView);
        //错误视图
        let errorV = errorView();
        self.view.addSubview(errorV);
        errorV.isHidden = true;
        
        naviBar.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.height.mas_equalTo()(NavgationBarHeight());
            maker?.top.mas_equalTo()(self.view)?.offset()(StatusBarHeight());
        }
        webView.mas_makeConstraints { (maker) in
            maker?.left.right()?.mas_equalTo()(self.view);
            maker?.top.mas_equalTo()(naviBar.mas_bottom);
            maker?.bottom.mas_equalTo()(self.view)?.offset() ((isFullScreen() == true ? -ScreenBottomInset() : 0))
        }
        errorV.mas_makeConstraints { (maker) in
            maker?.left.top()?.right()?.bottom()?.mas_equalTo()(webView);
        }
        
    }
    
    
    //初始化JS
    private func initJSAction(){
        jsHandler.setJSHandler { [unowned self] (json) in
            self.handlerJavascriptCall(jsObj: json);
        }
        webView.configuration.userContentController.removeScriptMessageHandler(forName:jsHandler.scriptHandleName);
        webView.configuration.userContentController.add(jsHandler, name: jsHandler.scriptHandleName);
    }
    
    
    //JS回调分发消息--分发给注册的或者默认的处理类
    private func handlerJavascriptCall(jsObj:NSDictionary){
        let action:String = jsObj.value(forKey: "action") as! String;
        delegate?.webWillDoAction?(action);
        if (actionDict.keys.contains(action)) {
            let callBack:jsHandler? = actionDict[action];
            callBack?(jsObj);
        }else{
            actionHandler?.handleJsAction(jsDict: jsObj, vc: self);
        }
        delegate?.webDidDoAction?(action);
    }
    
    
    //更新导航栏按钮显示
    private func updateNavigationItems(){
        if (webView.canGoBack) {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
            webView.navigationDelegate = self;
            webView.allowsBackForwardNavigationGestures = true;
            naviBar.backItem.isHidden = false;
            naviBar.closeItem.isHidden = false;
        }else{
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
            webView.allowsBackForwardNavigationGestures = false;
            naviBar.backItem.isHidden = false;
            naviBar.closeItem.isHidden = true;
        }
    }
    
    
    //创建一个失败的页面
    private func errorView()->UIView{
        errorV = UIView()
        errorV.backgroundColor = config.errorViewBackColor;
        errorTipL = UILabel()
        errorTipL.font = kFont(14);
        errorTipL.textColor = config.errorTipTextColor;
        errorV.addSubview(errorTipL);
        errorTipL.text = config.netErrorTip;
        errorTipL.mas_makeConstraints { (maker) in
            maker?.center.mas_equalTo()(errorV);
        }
        return errorV;
    }
    
    
    //获取一个VC
    private func viewController()->UIViewController?{
        var next:UIView? = webView.superview;
        while (next != nil) {
            let responder = next?.next;
            if ((responder?.isKind(of: UIViewController.self))!){
                return responder as? UIViewController;
            }
            next = next!.superview;
        }
        return nil;
    }
    
    
    deinit {
        delegate?.allToustDismiss?()       //隐藏所有的指示器
        webView.removeObserver(self, forKeyPath: "estimatedProgress");
        webView.removeObserver(self, forKeyPath: "title");
        webView.configuration.userContentController.removeAllUserScripts();
        webView.configuration.userContentController.removeScriptMessageHandler(forName:jsHandler.scriptHandleName);
    }
    
}



//全局的网页配置项
class SHWebConfig:NSObject{
    //Variable
    public var timeoutInterval:TimeInterval = 15            //超时时间
    public var navTitle:String = ""                         //导航栏标题
    public var isUseH5Title:Bool = true                     //是否自动使用网页设置的标题
    public var linkOpenNew:Bool = false                     //点击网页中的链接，push一个新的界面
    
    //失败UI配置
    public var netErrorTip:String = "网络不给力~~(>_<)~~"
    public var loadErrorTip:String = "加载失败，请重新加载"
    public var loadConfigError:String = "加载错误";
    public var errorViewBackColor:UIColor = UIColor.colorHexValue("F3F4F5")
    public var errorTipTextColor:UIColor = UIColor.colorHexValue("212121");
    //提示文案
    public var alertTitle:String = "温馨提示"
    public var alertKnow:String = "我知道了"
    public var alertGo:String = "前往"
    public var alertComfirm:String = "确认"
    public var alertCancel:String = "取消"
    public var alertTextColor:UIColor = UIColor.red
    
}

//
//  SHWKWebView.swift
//  SHKit
//
//  Created by hsh on 2019/6/4.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import WebKit

//WebView
public class SHWKWebView: WKWebView {
    
    
    //加载请求
    @discardableResult
    public override func load(_ request:URLRequest)->WKNavigation?{
        if #available(iOS 11.0,*) {
            return super.load(request)!;
        }
        //处理iOS11之前POST请求的参数问题
        if (request.httpMethod?.uppercased() == "POST"){
            guard let url = request.url?.absoluteString else { return nil};
            var params:String = String(data: request.httpBody!, encoding: .utf8)!;
            if (params.contains("=")){
                params = params.replacingOccurrences(of: "=", with: "\":\"");
                params = params.replacingOccurrences(of: "&", with: "\",\"");
                params = String(format: "{\"%@\"}", params);
            }else{
                params = "{}";
            }
            let postJavaScript = String(format: "var url = '%@';var params = %@;var form = document.createElement('form');form.setAttribute('method', 'post');form.setAttribute('action', url);for(var key in params) {if(params.hasOwnProperty(key)) {var hiddenField = document.createElement('input');hiddenField.setAttribute('type', 'hidden');hiddenField.setAttribute('name', key);hiddenField.setAttribute('value', params[key]);form.appendChild(hiddenField);}}document.body.appendChild(form);form.submit();", url,params);
            self.evaluateJavaScript(postJavaScript) { [unowned self] (object, error) in
                if (error != nil){
                    self.navigationDelegate?.webView?(self, didFailProvisionalNavigation: nil, withError: error!);
                }
            }
            return nil
        }else{
            return super.load(request);
        }
    }
    
    
    
    //加载请求带post参数
    public func loadRequest(_ request:inout URLRequest,postDict:NSDictionary)->WKNavigation?{
        if (postDict.count == 0) {
            return self.load(request);
        }
        let keys:[String] = postDict.allKeys as! [String];
        let tmpStr = NSMutableString()
        for (index,key) in keys.enumerated() {
            if (index > 0){
                tmpStr.append("&");
            }
            tmpStr.append(String(format: "%@=%@", keys[index],postDict.value(forKey: key) as! CVarArg));
        }
        request.httpMethod = "POST";
        request.httpBody = tmpStr.data(using: String.Encoding.utf8.rawValue);
        return self.load(request);
    }
    
    
    
    //带设置cookie参数接口
    public func loadRequest(_ request:URLRequest,cookiesDict:NSDictionary)->WKNavigation?{
        if #available(iOS 11.0, *) {
            let cookieStore = self.configuration.websiteDataStore.httpCookieStore;
            var wkNavigation:WKNavigation?
            cookieStore.getAllCookies { (cookies) in
                if (cookies.count > 0) {
                    for cookie in cookies{
                        cookieStore.setCookie(cookie, completionHandler: {
                            print(cookie);
                        })
                    }
                }
                wkNavigation = self.load(request);
            }
            return wkNavigation;
        }
        if (cookiesDict.allKeys.count == 0) {
            return self.load(request);
        }
        var finalRequest = request;
        let keys:[String] = cookiesDict.allKeys as! [String];
        let cookiesStr = NSMutableString()
        for (index,value) in keys.enumerated() {
            if (index > 0){
                cookiesStr.append(value);
            }
            cookiesStr.appendFormat("%@=%@", keys[index],cookiesDict.value(forKey:keys[index]) as! CVarArg);
        }
        if (cookiesStr.length > 0){
            finalRequest.addValue(cookiesStr as String, forHTTPHeaderField: "Cookie");
        }
        return self.load(finalRequest);
    }
    
    
    
    //清除缓存
    public func cleanCache(){
        //iOS9
        let websiteDataTypes:NSSet = NSSet(set: [WKWebsiteDataTypeDiskCache,WKWebsiteDataTypeOfflineWebApplicationCache,WKWebsiteDataTypeMemoryCache]);
        let from:Date = Date(timeIntervalSince1970: 0);
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: from) {
            print("清除缓存完毕");
        };
    }
    
    

}

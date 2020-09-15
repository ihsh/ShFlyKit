//
//  PreviewVC.swift
//  SHKit
//
//  Created by hsh on 2019/9/18.
//  Copyright © 2019 hsh. All rights reserved.
//


import UIKit
import QuickLook
import AFNetworking


///预览doc/pdf文件
/*iWork 类的文档。
 微软Office97以上版本的文档。
 RTF 富文本文档。
 PDF 格式的文件。
 图片格式文件。
 CSV 格式文件和本地文件。*/

///预览并打印文件--例如发票，面单
class PreviewTool: NSObject,QLPreviewControllerDelegate,QLPreviewControllerDataSource {
    //Variable
    private var qlPreviewVC:QLPreviewController!    //打开word文档需要引入的视图控制器
    private var holdVC:UIViewController!            //当前控制器
    private var path:URL!                           //保存本地的地址
    private var customTitle:String?                 //自定义标题
    
    

    //预览远程文件
    public func previewRemote(_ url:String,title:String?,result:@escaping ((_ path:String?,_ error:Error?)->Void)){
        holdVC = (UIApplication.shared.delegate?.window?!.rootViewController)!;
        self.customTitle = title;
        //创建下载请求
        let manager = AFHTTPSessionManager();
        let request = URLRequest.init(url: URL(string: url)!);
        //任务
        let downTask = manager.downloadTask(with: request, progress: { (progress) in
            
         }, destination: { (url, rep) -> URL in
            var fullPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last ?? "";
            fullPath = fullPath + (rep.suggestedFilename ?? "");
            return URL.init(fileURLWithPath: fullPath);
        }) { (rep, url, error) in
            //结束
            if url != nil{
                self.path = url;
                self.qlPreviewVC = QLPreviewController()
                self.qlPreviewVC.delegate = self;
                self.qlPreviewVC.dataSource = self;
                self.qlPreviewVC.title = rep.suggestedFilename;
                self.holdVC.present(self.qlPreviewVC, animated: true, completion: {
                })
            }
            result(url?.absoluteString,error);
        }
        //执行task
        downTask.resume();
    }
    
    
    //查看本地文件-如果加载不出来，请检查文件路径，bundle没有,检查是否导入对
    public func previewLocal(_ path:String,title:String?){
        holdVC = (UIApplication.shared.delegate?.window?!.rootViewController)!;
        self.customTitle = title;
        self.path = URL.init(fileURLWithPath: path);
        self.qlPreviewVC = QLPreviewController()
        self.qlPreviewVC.delegate = self;
        self.qlPreviewVC.dataSource = self;
        self.qlPreviewVC.title = title;
        self.holdVC.present(self.qlPreviewVC, animated: true, completion: {
        })
    }
    
    
    
    //Delegate & DataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1;
    }
    
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let item:QLPreviewCustomItem = QLPreviewCustomItem()
        item.previewItemURL = path;
        item.previewItemTitle = customTitle;
        return item;
    }
    
    
    func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil);
        }
        return false;
    }

    
}



//自定义的QLPreviewItem
class QLPreviewCustomItem: NSObject,QLPreviewItem {
    //variable
    public var previewItemURL: URL?
    public var previewItemTitle: String?
}

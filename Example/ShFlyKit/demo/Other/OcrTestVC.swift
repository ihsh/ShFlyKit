//
//  OcrTestVC.swift
//  SHKit
//
//  Created by hsh on 2019/2/11.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit

class OcrTestVC:UITableViewController {
    
    public var ocrScan:OCRScan!
    let actionArr:NSArray = ["身份证正面","身份证背面","银行卡","驾驶证","文本识别"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "OCR"
        self.tableView.reloadData()
        ocrScan = OCRScan()
        ocrScan.authWithAK("02zCXz2EZ8599xpencKB5c8p", SK: "xGEdGFVtVGNyDPu9GRz2DGz7LkQz72wU")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let str = actionArr[indexPath.row];
        cell.textLabel?.text = str as? String;
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            ocrScan.IDCardFrontScan({ (image, result) in
                image?.savePhotoToAlbum()
            }) { (error) in
                
            }
        case 1:
            ocrScan.IDCardBackScan({ (image, result) in
                image?.savePhotoToAlbum()
            }) { (error) in
                
            }
            break;
        case 2:
            ocrScan.bankCardScan({ (image, result) in
                image?.savePhotoToAlbum()
            }) { (error) in
                
            }
        case 3:
            ocrScan.drivinglicenseScan({ (image, result) in
                image?.savePhotoToAlbum()
            }) { (error) in
                
            }
        case 4:
            ocrScan.baseTextScan({ (image, result) in
                let array:NSArray = result.value(forKey: "words_result") as! NSArray;
                let str = array.dictArrayToString(forKey: "words");
                print(str)
            }) { (error) in
                
            }
        default:
            break
        }
    }
    
    
}

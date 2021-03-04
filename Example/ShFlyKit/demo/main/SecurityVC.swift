//
//  SecurityVC.swift
//  SHKit
//
//  Created by hsh on 2018/10/23.
//  Copyright © 2018 hsh. All rights reserved.
//

import UIKit


class SecurityVC: UITableViewController ,SecurityDelegate ,LockScreenDelegate{
    //Varibale
    let actionArr:NSArray = ["面容识别","图案设置","图案验证"]
    var secuityChecker:SecurityCheck!
    
    
    override func viewDidLoad() {
        secuityChecker = SecurityCheck()
        secuityChecker.holdVC = self;
    }
    
    
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
            secuityChecker.checkWithType(type: .Biometry,delegate: self);
        case 2:
            secuityChecker.checkWithType(type: .Pattern,delegate: self);
        case 1:
            secuityChecker.checkWithType(type: .PatternSet,delegate: self);
        default:
            break
        }
    }
    
    
    // MARK: - Protocol
     //指纹识别
    func securityCheckResult(result: Bool, msg: String?) {
        secuityChecker.dismiss(type: .Pattern)
    }
    
    
    //图案解锁
    func unlockScreenResult(pwd: String) {
        secuityChecker.dismiss(type: .Pattern)
    }
    
      
    func failUnlockWithMaxTry() {
        secuityChecker.dismiss(type: .Pattern)
    }
    
    
    func forgotPassWord() {
        secuityChecker.dismiss(type: .Pattern)
    }
    
    
    func useBiometry() {
        secuityChecker.checkWithType(type: .Biometry, delegate: self);
    }
    
    
    func userHeadp() -> UIImage? {
        return UIImage.name("jietu", cls: SecurityCheck.self, bundleName: "Components");
    }
    
    

    func lockScreenDidFinishSetPassword(pwd: String) {
        secuityChecker.checkResult(type: .Pattern, suc: true)
    }
    
    
    func lockScreenCancelSetting() {
        secuityChecker.checkResult(type: .Pattern, suc: true);
    }
    
    
}

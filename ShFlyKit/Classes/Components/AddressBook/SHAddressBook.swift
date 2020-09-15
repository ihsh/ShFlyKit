//
//  SHAddressBook.swift
//  SHKit
//
//  Created by hsh on 2019/5/10.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Contacts


//通讯录数据类
class SHAddressBook: NSObject {
    
    //获取通讯录数据集
    class public func fetchData(callBack:@escaping ((_ contacts:[SHAddressItem],_ msg:String)->Void)){
        var results:[SHAddressItem] = [];
        //请求权限
        CNContactStore().requestAccess(for: .contacts) { (isRight, error) in
            if (isRight == false){
                DispatchQueue.main.async(execute: {
                    callBack(results,"没有权限");
                })
            }else{
                //获取授权状态
                let status = CNContactStore.authorizationStatus(for: .contacts);
                //判断当前授权状态
                guard (status == .authorized || status == .notDetermined) else {return}
                //创建通讯录对象
                let store = CNContactStore()
                //指定要获取联系人中的什么属性,没有指定就访问会崩溃
                let keys = [CNContactFamilyNameKey,CNContactGivenNameKey,CNContactOrganizationNameKey,CNContactEmailAddressesKey,
                            CNContactDepartmentNameKey,CNContactImageDataKey,CNContactThumbnailImageDataKey,CNContactPhoneNumbersKey,
                            CNContactPostalAddressesKey,CNContactDatesKey,CNContactInstantMessageAddressesKey];
                //创建请求对象
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor]);
                //遍历所有联系人
                do{
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stop) in
                        let item = SHAddressItem();
                        item.surname = contact.familyName;                  //姓
                        item.name = contact.givenName;                      //名字
                        item.organazation = contact.organizationName;       //公司名称
                        //判断显示的名称
                        if (item.name != nil) {
                            item.showName = String(format: "%@%@", item.surname ?? "",item.name);
                        }else{
                            item.showName = item.organazation;
                        }
                        //头像
                        let data = contact.thumbnailImageData;
                        if (data != nil){
                            item.headp = UIImage.init(data: data!);
                        }
                        //有多个电话
                        for phone in contact.phoneNumbers{
                            var num = phone.value.stringValue;
                            //去掉空格，去掉括号
                            num = num.replacingOccurrences(of: " ", with: "", options: .literal, range: nil);
                            num = num.replacingOccurrences(of: "+", with: "", options: .literal, range: nil);
                            num = num.replacingOccurrences(of: "-", with: "", options: .literal, range: nil);
                            item.phones.append(num);
                        }
                        for email in contact.emailAddresses{
                            let mail:String = email.value as String;
                            item.mails.append(mail);
                        }
                        for address in contact.postalAddresses{
                            let detail:CNPostalAddress = address.value;
                            let model = SHAddressDetail()
                            model.country = detail.country;
                            model.province = detail.state;
                            model.city = detail.city;
                            if #available(iOS 10.3, *) {
                                model.area = detail.subAdministrativeArea
                            } else {
                                // Fallback on earlier versions
                            };
                            model.street = detail.street;
                            model.generateFullAddress();
                            item.address.append(model);
                        }
                        results.append(item);
                    })
                    DispatchQueue.main.async(execute: {
                        callBack(results,"成功");
                    })
                }catch{
                    DispatchQueue.main.async(execute: {
                        callBack(results,"发生异常");
                    })
                }
            }
        }
    }
    
    
    
    //有多个电话的联系人切分成单个电话的重复联系人
    class public func separateByPhone(_ items:[SHAddressItem])->([SHAddressItem]){
        var results:[SHAddressItem] = [];
        for item in items {
            for phone in item.phones{
                let new = SHAddressItem()
                new.surname = item.surname;
                new.name = item.name;
                new.organazation = item.organazation;
                new.showName = item.showName;
                new.headp = item.headp;
                new.phones.append(phone);
                new.mails.append(contentsOf: item.mails);
                new.address.append(contentsOf: item.address);
                results.append(new);
            }
        }
        return results;
    }
    
    
    
    //将普通联系人按字母分组
    class public func sortBySection(_ items:[SHAddressItem])->([SHAddressSection],[String]){
        var results:[SHAddressSection] = [];
        //本地的字母集合
        let collection = UILocalizedIndexedCollation.current();
        //中文环境下返回的应该是27，是a－z和＃，其他语言则不同
        let highSection = collection.sectionTitles.count;
        //字母索引数组
        let indexArray = NSMutableArray.init(array: collection.sectionTitles);
        //暂存数组
        var newSections:[SHAddressSection] = []
        //空的段数组
        for _ in 0...highSection-1 {
            let section = SHAddressSection()
            newSections.append(section);
        }
        //分发数据
        for item in items{
            //获取name属性的值所在的位置，首字母
            let number = collection.section(for: item, collationStringSelector: #selector(getter: item.showName));
            let character:String = indexArray[number] as! String;
            //获取对应序号的并赋值
            let section = newSections[number];
            section.character = character;
            section.contacts.append(item);
        }
        //索引数组
        var sectionIndexs:[String] = [];
        for section in newSections {
            if (section.contacts.count > 0) {
                results.append(section);
                sectionIndexs.append(section.character);
            }
        }
        return (results,sectionIndexs);
    }
    
    
    
}



//通讯录模型
class SHAddressItem: NSObject {
    @objc public var surname:String?                       //姓氏
    @objc public var name:String!                          //名字
    @objc public var organazation:String?                  //公司名称
    @objc public var showName:String!                      //显示的名字
    @objc public var headp:UIImage?                        //头像
    @objc public var phones:[String] = []                  //电话号码数组
    @objc public var mails:[String] = []                   //邮箱
    @objc public var address:[SHAddressDetail] = []        //地址数组
    
    @objc public var headpTextBackColor:UIColor?           //头像的文字背景颜色
}



//地址详情
class SHAddressDetail:NSObject{
    @objc public var country:String!                       //国籍
    @objc public var province:String!                      //省
    @objc public var city:String!                          //市
    @objc public var area:String!                          //区/县
    @objc public var street:String!                        //街道，剩余完整地址
    @objc public var fullAddress:String!                   //拼接的完整地址
    
    
    //合成完整地址
    public func generateFullAddress(){
        let address = String(format: "%@%@%@%@%@", country != nil ? country : "",province != nil ? province : "",
                             city != nil ? city : "",area != nil ? area : "",street != nil ? street : "");
        self.fullAddress = address;
    }
}


//段模型
class SHAddressSection: NSObject {
    public var character:String!
    public var contacts:[SHAddressItem] = []
}

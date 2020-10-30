//
//  SHAddressSave.swift
//  SHKit
//
//  Created by hsh on 2019/9/30.
//  Copyright © 2019 hsh. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI


///通讯录写入
public class SHAddressSave: NSObject {


    //保存或更新联系人
    public func saveAddressItem(_ item:SHAddressItem){
        let contact = CNMutableContact()
        contact.givenName = item.name;
        contact.familyName = item.surname ?? "";
        contact.organizationName = item.organazation ?? "";
        //电话群
        var phones:[CNLabeledValue<CNPhoneNumber>] = [];
        for it in item.phones {
            let num = CNPhoneNumber.init(stringValue: it);
            let tmp = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: num);
            phones.append(tmp);
        }
        contact.phoneNumbers = phones;
        saveContact(contact);
    }
    
    
    
    //保存或更新联系人
    public func saveContact(_ contact:CNMutableContact){
        //保存请求
        let request = CNSaveRequest()
        if isExitContact(contact.givenName) {
            request.update(contact);
        }else{
            request.add(contact, toContainerWithIdentifier: nil);
        }
        //写入
        let store = CNContactStore()
        do{
            try store.execute(request);
        }catch{
            
        }
    }
    
    
    
    //判断该联系人是否存在
    public func isExitContact(_ name:String)->Bool{
        let store = CNContactStore()
        //检索条件
        let predicate = CNContact.predicateForContacts(matchingName: name);
        //过滤条件
        let keysToFetch = [CNContactGivenNameKey,CNContactFormatter.descriptorForRequiredKeys(for: .fullName)] as [Any];
        do{
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor]);
            return contacts.count > 0;
        }catch{
            
        }
        return false;
    }
    
    
    
}

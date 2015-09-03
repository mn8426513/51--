//
//  MJViewController.m
//  01-通讯录
//
//  Created by apple on 14-6-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "MJViewController.h"
#import <AddressBook/AddressBook.h>

@interface MJViewController ()
- (IBAction)accessAllPeople;
- (IBAction)updatePeople;
- (IBAction)addPeople;
@end

@implementation MJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self requestAccessAddressBook];
}

/**
 *  请求访问通讯录信息
 */
- (void)requestAccessAddressBook
{
    // 凡是函数名中包含了create\retain\copy\new等字眼,创建的数据类型,最终都需要release
    
    // 创建通讯录实例
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    
    // 请求访问通讯录的权限
    ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) { // 请求失败还是成功,都会调用这个block
        // granted : YES , 允许访问
        // granted : NO , 不允许访问
        if (granted) {
            NSLog(@"允许访问");
        } else {
            NSLog(@"不允许访问");
        }
    });
    
    // 释放资源  Core Foundation
    CFRelease(book);
}

/**
 *  访问通讯录信息
 */
- (IBAction)accessAllPeople {
    [self accessAllPeopleWithC];
}

- (void)accessAllPeopleWithOC
{
    // 如果没有授权成功,直接返回
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return;
    
    // 1.创建通讯录实例
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    
    // 2.获得通讯录中的所有联系人
    
    // CFArrayRef, Core Foundation, C语言
    // NSArray *, Foundation, OC语言
    // 两个框架之间的数据类型要转换, 需要用到"桥接"技术
    NSArray *allPeopole = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(book);
    
    // 3.遍历数组中的所有联系人
    for (int i = 0; i < allPeopole.count; i++) {
        // 获得i位置的1条联系人
        ABRecordRef record = (__bridge ABRecordRef)(allPeopole[i]);
        
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        
        NSLog(@"%@ %@", lastName, firstName);
    }
    
    // 释放资源
    CFRelease(book);
}

- (void)accessAllPeopleWithC
{
    // 如果没有授权成功,直接返回
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return;
    
    // 1.创建通讯录实例
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    
    // 2.获得通讯录中的所有联系人
    CFArrayRef allPeopole = ABAddressBookCopyArrayOfAllPeople(book);
    
    // 3.遍历数组中的所有联系人
    CFIndex count = CFArrayGetCount(allPeopole);
    for (CFIndex i = 0; i < count; i++) {
        // 4.获得i这个位置对应的联系人(1个联系人 对应 1个 ABRecordRef)
        ABRecordRef people = CFArrayGetValueAtIndex(allPeopole, i);
        
        // 5.获得联系人的信息
        CFStringRef firstName = ABRecordCopyValue(people, kABPersonFirstNameProperty);
        CFStringRef lastName = ABRecordCopyValue(people, kABPersonLastNameProperty);
        ABMultiValueRef phone = ABRecordCopyValue(people, kABPersonPhoneProperty);
        
        // 获得更详细的数据类型
        CFArrayRef phoneArray = ABMultiValueCopyArrayOfAllValues(phone);
        CFIndex phoneCount = CFArrayGetCount(phoneArray);
        for (int j = 0; j < phoneCount; j++) {
            CFStringRef phoneLabel = ABMultiValueCopyLabelAtIndex(phone, j);
            CFStringRef phoneValue = ABMultiValueCopyValueAtIndex(phone, j);
            NSLog(@"%@ - %@", phoneLabel, phoneValue);
            CFRelease(phoneLabel);
            CFRelease(phoneValue);
        }
        
        // 6.输出
        NSLog(@"%@ %@", lastName, firstName);
        
        // 7.释放
        CFRelease(phoneArray);
        CFRelease(phone);
        CFRelease(firstName);
        CFRelease(lastName);
    }
    
    // 释放资源
    CFRelease(allPeopole);
    CFRelease(book);
}

- (IBAction)updatePeople {
    // 如果没有授权成功,直接返回
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return;
    
    // 1.创建通讯录实例
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    
    // 2.获得通讯录中的所有联系人
    NSArray *allPeopole = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(book);
    
    // 3.获得数组中的第0个人
    ABRecordRef people = (__bridge ABRecordRef)(allPeopole[0]);
    CFStringRef lastName = (__bridge CFStringRef)@"刘";
    // 修改姓
    ABRecordSetValue(people, kABPersonLastNameProperty, lastName, NULL);
    
    // 4.同步
    ABAddressBookSave(book, NULL);
}

- (IBAction)addPeople {
    // 如果没有授权成功,直接返回
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) return;
    
    // 1.创建新的联系人
    ABRecordRef people = ABPersonCreate();
    
    // 2.设置信息
    ABRecordSetValue(people, kABPersonLastNameProperty, (__bridge CFStringRef)@"刘", NULL);
    ABRecordSetValue(people, kABPersonFirstNameProperty, (__bridge CFStringRef)@"蛋疼", NULL);
    
    ABMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(phone, (__bridge CFStringRef)@"10010", kABPersonPhoneMainLabel, NULL);
    ABMultiValueAddValueAndLabel(phone, (__bridge CFStringRef)@"10011", kABPersonPhoneMobileLabel, NULL);
    ABMultiValueAddValueAndLabel(phone, (__bridge CFStringRef)@"10012", kABPersonPhoneIPhoneLabel, NULL);
    ABRecordSetValue(people, kABPersonPhoneProperty, phone, NULL);
    
    // 3.添加联系人到通讯录
    ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookAddRecord(book, people, NULL);
    
    ABAddressBookSave(book, NULL);
    
    // 4.释放
    CFRelease(phone);
    CFRelease(people);
    CFRelease(book);
}
@end

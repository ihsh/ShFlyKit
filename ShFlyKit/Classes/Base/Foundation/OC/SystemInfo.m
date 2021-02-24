//
//  SystemInfo.m
//  SHKit
//
//  Created by 黄少辉 on 2018/3/21.
//  Copyright © 2018年 黄少辉. All rights reserved.
//

#import "SystemInfo.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <sys/mount.h>
#import <ifaddrs.h>
#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <sys/utsname.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <HealthKit/HealthKit.h>
#import <UIKit/UIDevice.h>
#import <Contacts/Contacts.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTCellularData.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <PassKit/PassKit.h>


#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"


@implementation SystemInfo


//网络使用情况
+(NSDictionary*)netDataCounters{
    
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1){
        return @{};
    }
    uint32_t iBytes = 0;    uint32_t oBytes = 0;    uint32_t allFlow    = 0;
    uint32_t wifiIBytes = 0;uint32_t wifiOBytes = 0;uint32_t wifiFlow   = 0;
    uint32_t wwanIBytes = 0;uint32_t wwanOBytes = 0;uint32_t wwanFlow   = 0;
         
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        if (ifa->ifa_data == 0)
            continue;
        if (strncmp(ifa->ifa_name, "lo", 2)){
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
        }
        if (!strcmp(ifa->ifa_name, "en0")){
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow    = wifiIBytes + wifiOBytes;
        }
        if (!strcmp(ifa->ifa_name, "pdp_ip0")){
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow    = wwanIBytes + wwanOBytes;
        }
    }
    freeifaddrs(ifa_list);
    
    NSString *receivedBytes  = [self bytesToAvaiUnit:iBytes];
    NSString *sentBytes      = [self bytesToAvaiUnit:oBytes];
    NSString *networkFlow    = [self bytesToAvaiUnit:allFlow];
         
    NSString *wifiReceived   = [self bytesToAvaiUnit:wifiIBytes];
    NSString *wifiSent       = [self bytesToAvaiUnit: wifiOBytes];
    NSString *wifiBytes      = [self bytesToAvaiUnit:wifiFlow];
         
    NSString *wwanReceived   = [self bytesToAvaiUnit:wwanIBytes];
    NSString *wwanSent       = [self bytesToAvaiUnit:wwanOBytes];
    NSString *wwanBytes      = [self bytesToAvaiUnit:wwanFlow];
       
    NSDictionary *info = @{@"all":networkFlow,
                           @"allSend":sentBytes,
                           @"allRec":receivedBytes,
                           @"wifi":wifiBytes,
                           @"wifiRec":wifiReceived,
                           @"wifiSend":wifiSent,
                           @"celler":wwanBytes,
                           @"cellerSend":wwanSent,
                           @"cellerRec":wwanReceived};
    return info;
}


//Private-格式化数据单位
+(NSString *)bytesToAvaiUnit:(uint32_t)bytes{
    if(bytes < 1024){
        return [NSString stringWithFormat:@"%ldB", bytes];
    }else if(bytes >= 1024 && bytes < 1024 * 1024){
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024){
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
    }else{
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}


//全部内存
+(double)totalMemorySize{
    long long size =  [NSProcessInfo processInfo].physicalMemory/1024.0/1024.0;
    return (double)size;
}


//已使用内存
+(double)taskUsedMemory{
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (result != KERN_SUCCESS)
        return 0;
    return vmInfo.phys_footprint/ 1024.0/1024.0;
}


//cpu使用率
+(double)cpuUsedPersentage{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        basic_info_th = (thread_basic_info_t)thinfo;
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    } // for each thread
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    return tot_cpu;
}


///电池电量
+(double)getBatteryQuantity{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double batterLevel = (double)[[UIDevice currentDevice]batteryLevel];
    return batterLevel;
}


///电池状态
+(UIDeviceBatteryState)stateOfBattery{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
    return state;
}


//低电量模式是否打开
+(BOOL)lowPowerModeEnable{
    return [NSProcessInfo processInfo].lowPowerModeEnabled;
}


//磁盘信息
+(NSDictionary *)diskInfo{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager* fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    
    long long total = totalSpace.longLongValue;
    long long free = freeSpace.longLongValue;
    long long used = total - free;
    
    double rate = used / totalSpace.doubleValue;
    NSDictionary *info = @{@"已占用":[NSString stringWithFormat:@"%.1fG",used/1024.0/1024.0/1024.0],
                           @"剩余":[NSString stringWithFormat:@"%.1fG",free/1024.0/1024.0/1024.0],
                           @"使用率":[NSString stringWithFormat:@"%.1f%%",rate * 100]};
    return info;
}


//系统启动时间
+(NSDate *)systemStartTime {
    size_t size;
    sysctlbyname("kern.boottime", NULL, &size, NULL, 0);
    char *boot_time = malloc(size);
    sysctlbyname("kern.boottime", boot_time, &size, NULL, 0);
    uint32_t timestamp = 0;
    memcpy(&timestamp, boot_time, sizeof(uint32_t));
    free(boot_time);
    NSDate* bootTime = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return  bootTime;
}


//运行时长-秒数
+(NSString*)runningTime{
    NSDate *start = [self systemStartTime];
    NSDate *now = [NSDate date];
    NSInteger span = fabs(now.timeIntervalSince1970 - start.timeIntervalSince1970);
    //天数
    NSInteger day = span/86400;
    //剩余时间小时
    NSInteger hour = (span/3600) % 24;
    NSInteger left = span % 3600;
    NSInteger minues = left / 60;
    NSInteger sec = left % 60;
    NSString *tmpStr = [NSString stringWithFormat:@"%ld天%ld小时%ld分%ld秒",day,hour,minues,sec];
    return tmpStr;
}


//运营商信息
+(NSDictionary *)carrierInfo{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc]init];
    NSDictionary *provider = [info serviceSubscriberCellularProviders];
    NSArray *values = provider.allValues;
    NSString *mobile = @"";
    CTCarrier *carrer = values.firstObject;
    if (carrer) {
        mobile = carrer.carrierName;
    }
    //网络制式
    NSDictionary *net = info.serviceCurrentRadioAccessTechnology;
    NSString *mode = net.allValues.firstObject;
    NSDictionary *dict = @{@"运营商":mobile ? mobile : @"",@"网络制式":mode ? mode : @""};
    return dict;
}



//获取移动网络类型
+(NSString *)getNetType{
    CTTelephonyNetworkInfo *info = [CTTelephonyNetworkInfo new];
    NSString *networkType = @"";
    if ([info respondsToSelector:@selector(currentRadioAccessTechnology)]) {
        
        NSString *currentStatus = info.serviceCurrentRadioAccessTechnology.allValues.firstObject;
        //2G的模式
        NSArray *network2G = @[CTRadioAccessTechnologyGPRS,
                               CTRadioAccessTechnologyEdge,
                               CTRadioAccessTechnologyCDMA1x];
        //3G的模式
        NSArray *network3G = @[CTRadioAccessTechnologyWCDMA,
                               CTRadioAccessTechnologyHSDPA,
                               CTRadioAccessTechnologyHSUPA,
                               CTRadioAccessTechnologyCDMAEVDORev0,
                               CTRadioAccessTechnologyCDMAEVDORevA,
                               CTRadioAccessTechnologyCDMAEVDORevB,
                               CTRadioAccessTechnologyeHRPD];
        //4G的模式
        NSArray *network4G = @[CTRadioAccessTechnologyLTE];
        
        if ([network2G containsObject:currentStatus]) {
            networkType = @"2G";
        }else if ([network3G containsObject:currentStatus]) {
            networkType = @"3G";
        }else if ([network4G containsObject:currentStatus]){
            networkType = @"4G";
        }else {
            networkType = @"未知网络";
        }
    }
    return networkType;
}



//简单的获取wifi地址
+(NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    //没有获取到改为wifi地址
    if ([address containsString:@"error"]) {
        address = [self deviceCellularIP];
    }
    return address;
}



//使用socket编程，建立一个tcp链接来检测(三次握手成功)，只要链接成功则服务器可达。这样只会发送tcpip的报头，数据量最小，ping该地址
+ (double)pingSecForRemote {
    double span = 100;
    NSTimeInterval startTime = [[NSDate alloc]init].timeIntervalSince1970;
    // 客户端 AF_INET:ipv4  SOCK_STREAM:TCP链接
    int socketNumber = socket(AF_INET, SOCK_STREAM, 0);
    // 配置服务器端套接字
    struct sockaddr_in serverAddress;
    // 设置服务器ipv4
    serverAddress.sin_family = AF_INET;
    // 百度的ip
    serverAddress.sin_addr.s_addr = inet_addr("202.108.22.5");
    // 设置端口号，HTTP默认80端口
    serverAddress.sin_port = htons(80);
    if (connect(socketNumber, (const struct sockaddr *)&serverAddress, sizeof(serverAddress)) == 0) {
        close(socketNumber);
        NSTimeInterval endTime = [[NSDate alloc]init].timeIntervalSince1970;
        span = endTime * 1000 - startTime * 1000;
        return span;
    }
    close(socketNumber);
    return span;
}



//获取移动网络IP
+(NSString*)deviceCellularIP{
    NSArray *searchArray =
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}


//Private - deviceCellularIP使用
+ (NSDictionary *)getIPAddresses{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}


//Private -- deviceCellularIP使用
+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            NSLog(@"当前IP地址--%@",result);
            return YES;
        }
    }
    return NO;
}



//读取全局的网速
+ (long long) getInterfaceBytes{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return 0;
    }
    
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
        continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
        continue;
        if (ifa->ifa_data == 0)
        continue;
        /* Not a loopback device. */
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
    return iBytes + oBytes;
}

















//app显示名
+ (NSString *)appDisplayName{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}


//设备名
+ (NSString*)deviceName{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform , *deviceName = @"";
    platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform hasPrefix:@"iPad"]) {
        deviceName = @"iPad";
    }else if ([platform hasPrefix:@"iPod"]){
        deviceName = @"iPod";
    }else{
        deviceName = [self deviceNameDic][platform];
        if (!deviceName || deviceName.length ==0) {
            deviceName = @"Unknown";
        }
    }
    return deviceName;
}


//所在地使用语言
+(NSString *)localLanguage{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey:NSLocaleLanguageCode];
}


//当前所在地信息
+(NSString *)localDisplayName{
    NSString *identifier = [[NSLocale currentLocale] localeIdentifier];
    NSString *displayName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];
    return displayName;
}


//系统语言
+(NSString *)systemLanguage{
    NSArray *arLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *strLang = [arLanguages firstObject];
    return strLang;
}


//系统版本
+(NSString *)systemVersion{
    return [UIDevice currentDevice].systemVersion;
}


+ (NSString *)appBundleID{
    return [[NSBundle mainBundle] bundleIdentifier];
}


+ (NSString *)appVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}


+ (NSString*)appBuild{
    CFStringRef cfKey = kCFBundleVersionKey;
    NSString* bundleVersionKey = (__bridge NSString*)cfKey;
    CFRelease(cfKey);
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:bundleVersionKey];
}


//Private 设备信息字典
+ (NSDictionary<NSString* , NSString*>*)deviceNameDic{
    return @{@"iPhone1,1":@"iPhone 2G",
             @"iPhone1,2":@"iPhone 3G",
             @"iPhone2,1":@"iPhone 3GS",
             @"iPhone3,1":@"iPhone 4",
             @"iPhone3,2":@"iPhone 4",
             @"iPhone3,3":@"iPhone 4",
             @"iPhone3,3":@"iPhone 4",
             @"iPhone4,1":@"iPhone 4S",
             @"iPhone5,1":@"iPhone 5",
             @"iPhone5,2":@"iPhone 5",
             @"iPhone5,3":@"iPhone 5c",
             @"iPhone5,4":@"iPhone 5c",
             @"iPhone6,1":@"iPhone 5s",
             @"iPhone6,2":@"iPhone 5s",
             @"iPhone7,1":@"iPhone 6 Plus",
             @"iPhone7,2":@"iPhone 6",
             @"iPhone8,1":@"iPhone 6s",
             @"iPhone8,2":@"iPhone 6s Plus",
             @"iPhone8,4":@"iPhone SE",
             @"iPhone9,1":@"iPhone 7",
             @"iPhone9,2":@"iPhone 7 Plus",
             @"iPhone10,1":@"iPhone 8",
             @"iPhone10,4":@"iPhone 8",
             @"iPhone10,2":@"iPhone 8 Plus",
             @"iPhone10,5":@"iPhone 8 Plus",
             @"iPhone10,3":@"iPhone X",
             @"iPhone10,6":@"iPhone X",
             @"iPhone11,2":@"iPhone XS",
             @"iPhone11,4":@"iPhone XS Max",
             @"iPhone11,6":@"iPhone XS Max",
             @"iPhone11,8":@"iPhone XR",
    
             @"i386":@"iPhone Simulator",
             @"x86_64":@"iPhone Simulator"};
}


@end











@implementation AuthorityInfo


//网络权限
+(BOOL)networkAuthorised{
    if (@available(iOS 9.0, *)) {
        CTCellularData *cellularData = [[CTCellularData alloc]init];
        CTCellularDataRestrictedState status = cellularData.restrictedState;
        switch (status) {
            case kCTCellularDataRestricted:
                NSLog(@"网络访问权限受限");
                return NO;
                break;
            case kCTCellularDataNotRestricted:
                NSLog(@"网络访问权限已授权");
                return YES;
                break;
            case kCTCellularDataRestrictedStateUnknown:
                NSLog(@"网络访问权限未知");
                return NO;
                break;
            default:
                return NO;
                break;
        }
    } else {
        return YES; // unknown
    }
}


//检测位置权限
+(BOOL)checkLocationPermissions{
    BOOL isLocation = [CLLocationManager locationServicesEnabled];
    if (!isLocation) {
        NSLog(@"未打开定位服务");
        return NO;
    }
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"获得前台和后台定位授权");
            return YES;
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"定位服务仅给予了前台定位权限");
            return YES;
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"定位服务开启，但此APP设置为『从不』");
            return NO;
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"定位权限未决定");
            return NO;
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"访问受限，APP无权限使用定位，用户也无法更改");
            return NO;
            break;
        default:
            return NO;
            break;
    }
}


//麦克风权限
+(BOOL)checkMicroPermissions{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            NSLog(@"麦克风权限已授权");
            return YES;
            break;
        case AVAuthorizationStatusDenied:
            NSLog(@"麦克风权限受限");
            return NO;
            break;
        case AVAuthorizationStatusNotDetermined:
            NSLog(@"麦克风权限未决定");
            return NO;
            break;
        case AVAuthorizationStatusRestricted:
            NSLog(@"此APP不能使用麦克风，用户无法更改");
            return NO;
            break;
        default:
            return NO;
            break;
    }
}


//相机权限
+(BOOL)checkCameraPermissions{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            NSLog(@"相机权限已授权");
            return YES;
            break;
        case AVAuthorizationStatusDenied:
            NSLog(@"相机权限受限");
            return NO;
            break;
        case AVAuthorizationStatusNotDetermined:
            NSLog(@"相机权限未决定");
            return NO;
            break;
        case AVAuthorizationStatusRestricted:
            NSLog(@"此APP不能使用相机，用户无法更改");
            return NO;
            break;
        default:
            return NO;
            break;
    }
}


//相册
+(BOOL)checkPhotoLibraryPermissions{
    if (UIDevice.currentDevice.systemVersion.floatValue < 11.0) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                NSLog(@"相册权限已授权");
                return YES;
                break;
            case PHAuthorizationStatusDenied:
                NSLog(@"相册权限受限");
                return NO;
                break;
            case PHAuthorizationStatusNotDetermined:
                NSLog(@"相册权限未决定");
                return NO;
                break;
            case PHAuthorizationStatusRestricted:
                NSLog(@"此APP不能使用相册，用户无法更改");
                return NO;
                break;
            default:
                return NO;
                break;
        }
    } else {
        // iOS11之后相册权限默认打开
        return YES;
    }
}


//检测是否有联系人权限
+(BOOL)checkContactsPermissions{
    CNAuthorizationStatus contactsStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (contactsStatus) {
        case CNAuthorizationStatusAuthorized:
            return YES;
        default:
            return NO;
    }
}


//检测蓝牙是否连接
+(BOOL)checkBluetoothPermissions{
    CBPeripheralManagerAuthorizationStatus bluetoothStatus = [CBPeripheralManager authorizationStatus];
    switch (bluetoothStatus) {
        case CBPeripheralManagerAuthorizationStatusAuthorized:
            return YES;
        default:
            return NO;
    }
}


//日历/备忘录权限
+(BOOL)checkEventServicePermissions:(EKEntityType)entityType{
    EKAuthorizationStatus eventStatus = [EKEventStore authorizationStatusForEntityType:entityType];
    switch (eventStatus) {
        case EKAuthorizationStatusAuthorized:
            return YES;
        default:
            return NO;
    }
}


//检测健康权限
+(BOOL)checkHealthPermission{
    if (![HKHealthStore isHealthDataAvailable]) {
        return NO;
    }else{
        HKHealthStore *healthStore = [[HKHealthStore alloc]init];
        HKObjectType *hkObjectType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
        HKAuthorizationStatus status = [healthStore authorizationStatusForType:hkObjectType];
        if (status == HKAuthorizationStatusSharingDenied ) {
            return NO;
        }
    }
     return YES;
}


//检车TouchID/FaceID权限
+(BOOL)checkTouchOrFaceIDPermission{
    LAContext *laContext = [[LAContext alloc]init];
    NSError *error;
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        return YES;
    }
    return NO;
}


//检查applePay权限
+(BOOL)checkApplePayPermission{
    NSArray<PKPaymentNetwork> *supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkDiscover];
    if ([PKPaymentAuthorizationViewController canMakePayments] && [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedNetworks]) {
        return YES;
    } return NO;
}


+ (BOOL)pushNotifactionAuthorised {
        BOOL isOpen = NO;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (setting.types != UIUserNotificationTypeNone) {
            isOpen = YES;
        }
    #else
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (type != UIRemoteNotificationTypeNone) {
            isOpen = YES;
        }
    #endif
        return isOpen;
}


+ (BOOL)addressBookAuthorised {
    // 通讯录权限
    CNAuthorizationStatus authStatus;
    CNAuthorizationStatus cStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (cStatus == CNAuthorizationStatusNotDetermined) {
        authStatus = CNAuthorizationStatusDenied;
    } else if (cStatus == CNAuthorizationStatusAuthorized) {
        authStatus = CNAuthorizationStatusAuthorized;
    } else if (cStatus == CNAuthorizationStatusDenied) {
        authStatus = CNAuthorizationStatusDenied;
    } else {
        authStatus = CNAuthorizationStatusRestricted;
    }
    
    switch (authStatus) {
        case CNAuthorizationStatusNotDetermined:
            NSLog(@"通讯录权限未决定");
            return NO;
            break;
        case CNAuthorizationStatusAuthorized:
            NSLog(@"通讯录已授权");
            return YES;
            break;
        case CNAuthorizationStatusDenied:
            NSLog(@"定位服务开启，但此APP设置为『从不』");
            return NO;
            break;
        case CNAuthorizationStatusRestricted:
            NSLog(@"通讯录访问受限");
            return NO;
            break;
        default:
            break;
    }
    return NO;
}





@end

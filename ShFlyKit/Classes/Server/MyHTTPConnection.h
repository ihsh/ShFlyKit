
#import "HTTPConnection.h"
#import <UIKit/UIKit.h>

@class MultipartFormDataParser;

extern NSString *kUploadFileNotificationName;

@interface MyHTTPConnection : HTTPConnection  {
    MultipartFormDataParser*        parser;
	NSFileHandle*					storeFile;
	NSMutableArray*					uploadedFiles;
}

@end

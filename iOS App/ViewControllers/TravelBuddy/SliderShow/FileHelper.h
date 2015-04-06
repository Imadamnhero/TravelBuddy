//
//  FileHelper.h
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 10/29/14.
//
//

#import <Foundation/Foundation.h>

@interface FileHelper : NSObject
+ (NSString*) videoDirectory;
+ (NSString*) videoPathForName: (NSString*) filename;
+ (NSURL*) urlForImageName: (NSString*) filename;
+ (BOOL) saveVideoData: (NSData*) data withName: (NSString*) filename writeToGallery: (BOOL) write;
+ (void) removeImageWithName: (NSString*) filename;
@end

//
//  FileHelper.m
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 10/29/14.
//
//
#import <Foundation/Foundation.h>

#import "FileHelper.h"
#define VIDEO_DIRECTORY @"videos"
@implementation FileHelper
+ (NSString*) videoDirectory {
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSArray       *paths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [paths objectAtIndex:0];
    NSString *videoPath = [docPath stringByAppendingPathComponent: VIDEO_DIRECTORY];
    NSLog(@"==== image path :%@",videoPath);
    if(![fileMan fileExistsAtPath:videoPath isDirectory: nil]) {
        [fileMan createDirectoryAtPath:videoPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return videoPath;
}
+ (NSString*) fileDirectory {
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSArray       *paths   = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath = [paths objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent: VIDEO_DIRECTORY];
    NSLog(@"==== image path :%@",filePath);
    if(![fileMan fileExistsAtPath:filePath isDirectory: nil]) {
        [fileMan createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return filePath;
}

+ (NSURL*) urlForImageName: (NSString*) filename {
    return [NSURL fileURLWithPath:[self videoPathForName:filename]];
}

+ (NSString*) videoPathForName: (NSString*) filename {
    NSString *savePath = @"";
    savePath= [self videoDirectory];
    savePath = [savePath stringByAppendingPathComponent: filename];
    NSLog(@"===== ghi xong roi");
    NSLog(@"File path :%@",savePath);
    return savePath;
}

+ (BOOL) saveVideoData: (NSData*) data withName: (NSString*) filename writeToGallery:(BOOL)write{
    NSError *error;
    NSString *filePath = [self videoPathForName: filename];
    [data writeToFile:filePath options:NSAtomicWrite error:&error];
    if(write) {
        //        @try {
        //            UIImage *image = [UIImage imageWithData: data];
        //            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        //        }
        //        @catch (NSException *exception) {
        //
        //        }
        NSLog(@"===== ghi xong roi");
        NSLog(@"File path :%@",filePath);
    }
    if(error) {
        return NO;
    }
    return YES;
}

+ (void) removeImageWithName: (NSString*) filename {
    NSString *filePath = [self videoPathForName: filename];
    NSFileManager *fileMan = [NSFileManager defaultManager];
    if([fileMan fileExistsAtPath:filePath isDirectory:nil]) {
        [fileMan removeItemAtPath:filePath error: nil];
    }
}
@end

//
//  Common.h
//  Fun Spot App
//
//  Created by Pradeep Sundriyal on 09/10/12.
//
//

#import <Foundation/Foundation.h>
#define DATABASE @"PRODSQLFUNSPOT.sql"
#import "AppDelegate.h"
#import "CoreLocation/CoreLocation.h"

typedef enum{
    GeneralType,
    PlaceType,
}DiscountType;

@interface Common : NSObject{
    AppDelegate *delegate;
}


+ (void)showNetworkFailureAlert;
+ (void)showAlert:(NSString *)msg title:(NSString *)title buttontitle:(NSString *)buttontitle;
+ (void)copyDatabaseIfNeeded;
+ (void)dropDatabase;
+ (BOOL)fileExists:(NSString*)file;
+ (NSString*)getFilePath:(NSString *)add;
+ (void)createTable;
+ (NSString*)sanitizedStringForQuery:(NSString*)query;
+ (UIImage*)whiteBoxingImage:(UIImage*)tmpImg;
+ (UIImage*)whiteBoxingImage:(UIImage*)tmpImg withSize:(CGSize)newSize;
+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor;
+ (CGRect)getWhiteBoxingImageSize:(UIImage*)tmpImg;

@property (nonatomic, strong) NSString *serviceKey;
@property (nonatomic, strong) NSString *langId;
//get file path
+ (NSString *)documentsPathForFileName:(NSString *)name;
//save image to local
+ (void)saveImageToLocal:(NSString*)imageName;
//delete image local
+ (void)removeImage:(NSString *)fileName;
// resize image
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end

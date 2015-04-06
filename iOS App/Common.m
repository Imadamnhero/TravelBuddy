//
//  Common.m
//  Fun Spot App
//
//  Created by Pradeep Sundriyal on 09/10/12.
//  April20
//

#import "Common.h"
//#import "ANIPlaceService.h"
#import "ApplicationData.h"
#import "IMSSqliteManager.h"
#import "UIColor-Expanded.h"
#import "NSFileManager+DoNotBackup.h"
@implementation Common

@synthesize langId;
@synthesize serviceKey;

// Resize image
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    CGFloat actualHeight = image.size.height;
    CGFloat actualWidth = image.size.width;
    
    if(actualWidth <= newSize.width || actualHeight <= newSize.height)
    {
        return image;
    }
    else
    {
        if((actualWidth/actualHeight)<(newSize.width/newSize.height))
        {
            actualHeight=actualHeight*(newSize.width/actualWidth);
            actualWidth=newSize.width;
            
        }else
        {
            actualWidth=actualWidth*(newSize.height/actualHeight);
            actualHeight=newSize.height;
        }
    }
    // Create a graphics image context
    UIGraphicsBeginImageContext(CGSizeMake(actualWidth,actualHeight));
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,actualWidth,actualHeight)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}
//delete image local
+ (void)removeImage:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
//    [fileManager removeItemAtPath:filePath error:NULL];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
//        UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [removeSuccessFulAlert show];
        NSLog(@"Successfully removed");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
// save image to local
+ (void)saveImageToLocal:(NSString*)photoUrl{
    NSString *str = [photoUrl stringByReplacingOccurrencesOfString:@"./" withString:@"/"];
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_LINK,str]]]];
    NSString *imageName = [photoUrl stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSData *pngData = UIImagePNGRepresentation(image);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName]; //Add the file name
    [pngData writeToFile:filePath atomically:YES];
}

//get file name photo
+ (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}
+ (void)copyDatabaseIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [Common getFilePath:DATABASE];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
         NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE];
         NSURL *toURL = [NSURL fileURLWithPath:dbPath];
         NSURL *fromURL = [NSURL fileURLWithPath:defaultDBPath];
        
         success = [fileManager copyItemAtURL:fromURL toURL:toURL error:&error];
        
         if(success)
              [fileManager addSkipBackupAttributeToItemAtURL:toURL];
         else
              NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
}

+ (void)dropDatabase {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;

    NSString *dbPath = [Common getFilePath:DATABASE];
    NSURL *toURL = [NSURL fileURLWithPath:dbPath];
    
    [fileManager removeItemAtURL:toURL error:&error];
    [self copyDatabaseIfNeeded];
}

+ (void)showNetworkFailureAlert
{
//    [Common showAlert:NSLocalizedString(@"NetworkAlert", @"") title:@"" buttontitle:@"OK"];
    [Common showAlert:@"You must connect to the internet" title:@"" buttontitle:@"OK"];
}

+ (void)showAlert:(NSString *)msg title:(NSString *)title buttontitle:(NSString *)buttontitle
{
    //	CustomAlert *alert = [[CustomAlert alloc] initWithTitle:title message:msg	delegate:self cancelButtonTitle:buttontitle otherButtonTitles:nil];
    
    UIAlertView *alert = [[UIAlertView alloc]
    					  initWithTitle:title
                          message:msg
                          delegate:self
                          cancelButtonTitle:buttontitle
                          otherButtonTitles:nil];
	[alert show];
}

/*
+ (void)copyDatabaseIfNeeded {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = [Common getFilePath:DATABASE];
	BOOL success = [fileManager fileExistsAtPath:dbPath];
	
	if(!success) {
		
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		if (!success)
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}
}
*/
+ (BOOL)fileExists:(NSString*)file
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:[Common getFilePath:file]];
}

//Returns the saved information path
+ (NSString*)getFilePath:(NSString *)add
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *path = paths[0];
    NSString *filename = [path stringByAppendingPathComponent:add];
    return filename;
}

+(void)createTable{
    IMSSqliteManager   *ims = [[IMSSqliteManager alloc] init];
    [ims createTable:@""];
    //[ims release];
}

//replace ' with '' in sqlite query
+ (NSString*)sanitizedStringForQuery:(NSString*)query
{
    NSString* sanitizedString = [query stringByReplacingOccurrencesOfString:@"'"
                            withString:@"''"];
    return sanitizedString;
}

+ (UIImage*)whiteBoxingImage:(UIImage*)tmpImg withSize:(CGSize)newSize
{
    float oldWidth = CGImageGetWidth(tmpImg.CGImage);
    float oldHeight = CGImageGetHeight(tmpImg.CGImage);
    float newWidth = newSize.width;
    float newHeight = newSize.height;
    
    float oldRatio = oldWidth/oldHeight;
    float newRatio = newSize.width / newSize.height;
    
    
    //    if(newWidth > oldWidth && newHeight > oldHeight) // use original image, don't resize
    
    if(newWidth > oldWidth && newHeight < oldHeight)
    {
        oldHeight = newHeight;
        oldWidth = oldHeight * oldRatio;
    }
    else if(newWidth < oldWidth && newHeight > oldHeight)
    {
        oldWidth = newWidth;
        oldHeight = oldWidth/oldRatio;
    }
    else if(newWidth < oldWidth && newHeight < oldHeight)
    {
        bool isWide = oldWidth > oldHeight;
        
        if(isWide)
        {
            oldWidth = newWidth;
            oldHeight = oldWidth/oldRatio;
        }
        else
        {
            oldHeight = newHeight;
            oldWidth = oldHeight * oldRatio;
        }
    }
    else
    {
        oldWidth = newWidth;
        oldHeight = newHeight;
    }
    
    CGRect drawRect = CGRectMake((newWidth-oldWidth)/2, (newHeight-oldHeight)/2, oldWidth, oldHeight);
    
    // if we're not passed a proper image, letter box it with white
    if (oldRatio != newRatio) {
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        UIColor *color = [UIColor clearColor];
        [color set];
        
        CGContextFillRect(ctx, CGRectMake(0, 0, newWidth,newHeight));
        [tmpImg drawInRect:drawRect];
        tmpImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    return tmpImg;
}

+ (UIImage*)whiteBoxingImage:(UIImage*)tmpImg
{
    float width = CGImageGetWidth(tmpImg.CGImage);
    float height = CGImageGetHeight(tmpImg.CGImage);
    
    float newWidht = 320;
    float newheightFloat = roundf(newWidht*height/width);
    
    // if we're not passed a proper image, letter box it with white
    if (tmpImg.size.width < newWidht) {
        newheightFloat = height;
    }
    else
    {
        float imgRatio = height/width;
        width = newWidht;
        newheightFloat = imgRatio*newWidht;
    }
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIColor *color = [UIColor colorWithHexString:(appDelegate.funSpotDict)[@"color_bg"]];
    if(!color) color = COLOR_BG;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidht, newheightFloat));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx,color.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, newWidht,newheightFloat));
    
//    CGContextSetFillColorWithColor(ctx,color.CGColor);
    CGRect drawRect = CGRectMake((newWidht - width)/2,
                                 0,
                                 width,
                                 newheightFloat);
    [tmpImg drawInRect:drawRect];
    tmpImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tmpImg;
    
    

//    UIImage *img =nil;
//
//    float actualHeight = tmpImg.size.height;
//    float actualWidth = tmpImg.size.width;
//    float newWidht = 320;
//    
//    if(tmpImg.size.width > newWidht)
//    {
//        float imgRatio = actualHeight/actualWidth;
//        float newheightFloat = imgRatio*newWidht;
//        
//        UIGraphicsBeginImageContext(CGSizeMake(newWidht, newheightFloat));
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        //[[UIColor colorWithRed:1 green:1 blue:1 alpha:1] set];
//        [[UIColor clearColor] set];
//        CGContextFillRect(ctx, CGRectMake(0, 0, newWidht,newheightFloat));
//        
//        CGRect drawRect = CGRectMake(0,
//                                     0,
//                                     newWidht,
//                                     newheightFloat);
//        [tmpImg drawInRect:drawRect];
//        img = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    else
//    {
//        float imgRatio = actualWidth/actualHeight;
//        float maxRatio = 320.0/480.0;
//        
//        if(imgRatio!=maxRatio){
//            if(imgRatio < maxRatio){
//                imgRatio = 480.0 / actualHeight;
//                actualWidth = imgRatio * actualWidth;
//                actualHeight = 480.0;
//            }
//            else{
//                imgRatio = 320.0 / actualWidth;
//                actualHeight = imgRatio * actualHeight;
//                actualWidth = 320.0;
//            }
//        }
//        CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
//        //[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] setFill];
//        UIGraphicsBeginImageContext(rect.size);
//        
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        
//        CGRect outside = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
//        CGRect legend = CGRectInset(outside, 1, 1);
//        
//        //  NSLog(@"Outside: %@", NSStringFromCGRect(outside));
//        // NSLog(@"Legend: %@", NSStringFromCGRect(legend));
//        
//        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        UIColor *color = [UIColor colorWithHexString:[appDelegate.funSpotDict objectForKey:@"color_bg"]];
//        if(!color) color = COLOR_BG;
//        
//        CGContextSetFillColorWithColor(context,color.CGColor);
//        CGContextFillRect(context, legend);
//        
//        CGContextSetStrokeColorWithColor(context, color.CGColor);
//        CGContextStrokeRect(context, outside);
//        
//        
//        [tmpImg drawInRect:rect];
//        img = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    NSLog(@"wtmpImg.size.width==%f height==%f",img.size.width,img.size.height);

//    return img;
}

+ (CGRect)getWhiteBoxingImageSize:(UIImage*)tmpImg {
    
    float width = CGImageGetWidth(tmpImg.CGImage);
    float height = CGImageGetHeight(tmpImg.CGImage);
    
    float newWidh = 320;
    float newHeight = roundf(newWidh*height/width);
    
    float newLeft = 0;
    float newTop = 0;
    
    if (width < newWidh) {
        newWidh = width;
        newHeight = height;
        newLeft = (320-width)/2;
    }

    return CGRectMake(newLeft, newTop, newWidh, newHeight);
}

+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor {
    UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    
    [theColor set];
    CGContextFillRect(ctx, area);
	
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextDrawImage(ctx, area, baseImage.CGImage);
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (NSDictionary*) connectWS:(NSString*) methodName withValue:(NSMutableArray*)arrayPostData{
//    NSData *response;
    NSDictionary* dictResult;
    
    return dictResult;
    
    
//    NSString *kURLString = [NSString stringWithFormat:@"%@/%@.php",SERVER_LINK,methodName];
//    NSURL *url = [NSURL URLWithString:kURLString];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    for (int i = 0 ; i < arrayPostData.count; i++) {
//        [request setPostValue:[arrayPostData objectAtIndex:i] forKey:@"email"];
//    }
//    [request setPostValue:tfEmail.text forKey:@"email"];
//    [request setPostValue:tfPassword.text forKey:@"password"];
//    //username, email, avatarurl, password
//    [request setDelegate:self];
//    [request startSynchronous];
//    
//    NSError *error = [request error];
//    if (!error) {
//        NSLog(@"NO error");
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        NSData *response = [request responseData];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
//        NSLog(@"%@",dict);
//        if ([[dict objectForKey:@"success"] intValue] == 0) {
//            [delegate showAlert:[dict objectForKey:@"message"]];
//        }else{
//            [delegate showAlert:@"Login successfully"];
//            btnSelectCountry.hidden = btnAddTripIcon.hidden = NO;
//            NSString *str = @"true";
//            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//            [userDefault setObject:tfEmail.text forKey:@"userEmail"];
//            [userDefault setObject:tfPassword.text forKey:@"userPassword"];
//            [userDefault setObject:[dict objectForKey:@"userid"] forKey:@"userId"];
//            [userDefault setObject:[[dict objectForKey:@"avatarurl"] substringFromIndex:1] forKey:@"userAvatarUrl"];
//            [userDefault setObject:str forKey:@"isLogin"];
//            [userDefault synchronize];
//            viewLogin.hidden = YES;
//            if (isMemory) {
//                [userDefault setObject:@"true" forKey:@"memoryUser"];
//            }else
//                [userDefault setObject:@"false" forKey:@"memoryUser"];
//            [userDefault synchronize];
//            NSString *strtripId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"tripid"]];
//            if ([strtripId isEqualToString:@"<null>"]) {
//                btnHome.hidden = NO;
//            }else{
//                [userDefault setObject:[dict objectForKey:@"tripid"] forKey:@"userTripId"];
//                [userDefault setObject:[dict objectForKey:@"tripname"] forKey:@"userTripName"];
//                [userDefault synchronize];
//                AddTripVC *viewController = [[AddTripVC alloc]initWithNibName:@"AddTripVC" bundle:nil];
//                viewController.isFromLogin = @"true";
//                [self.navigationController pushViewController:viewController animated:YES];
//            }
//        }
//    }
}


@end

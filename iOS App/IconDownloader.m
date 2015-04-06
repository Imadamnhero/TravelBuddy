/*
     File: IconDownloader.m 
 Abstract: Helper object for managing the downloading of a particular app's icon.
 As a delegate "NSURLConnectionDelegate" is downloads the app icon in the background if it does not
 yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 
 A simple BOOL tracks whether or not a download is already in progress to avoid redundant requests.
  
  Version: 1.3 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "IconDownloader.h"
#import <QuartzCore/QuartzCore.h>

#import "NoteObj.h"
#import "User.h"

#define kAppIconSize 48


@implementation IconDownloader

@synthesize note,userObj;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;


#pragma mark

- (void)dealloc
{
    [imageConnection cancel];
}

- (void)startDownload :(NSString*)imageURL
{
    self.activeDownload = [NSMutableData data];
    // alloc+init and start an NSURLConnection; release on completion/failure
    //NSURL *url=[NSURL URLWithString:event.eventPhoto];
    NSURL *url= [NSURL URLWithString:
                    [[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:NULL];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                             url] delegate:self];
    
    
    self.imageConnection = conn;
}

- (void)startNoteIconDownload : (NSString*)imageURL
{
    self.activeDownload = [NSMutableData data];

    NSURL *tmpurl= [NSURL URLWithString:
                    [[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    [tmpurl setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:NULL];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                             [NSURLRequest requestWithURL:
                              tmpurl] delegate:self];
    self.imageConnection = conn;

}




- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
   ////////NSLog(@"DADTDA AAYA");
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    //image = [self thumbWithSideOfLength:50 :image];
    NSLog(@"WW = %f",image.size.height);
    
//    self.news.newsIcon = image;
    self.note.noteIcon = image;
    self.userObj.userIcon = image;
  
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display
    if(delegate && [delegate respondsToSelector:@selector(appImageDidLoad:)])
    [delegate appImageDidLoad:self.indexPathInTableView];
}


- (UIImage *)thumbWithSideOfLength:(float)length :(UIImage *) mainImage{
    UIImage *thumbnail;
    
    UIImageView *mainImageView = [[UIImageView alloc] initWithImage: mainImage];
    mainImageView.layer.cornerRadius = 4.0;
    BOOL widthGreaterThanHeight = (mainImage.size.width > mainImage.size.height);
    float sideFull = (widthGreaterThanHeight) ? mainImage.size.height : mainImage.size.width;
    CGRect clippedRect = CGRectMake(0, 0, sideFull, sideFull);
    UIGraphicsBeginImageContext(CGSizeMake(length, length));
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextClipToRect( currentContext, clippedRect);
    CGFloat scaleFactor = length/sideFull;
    if (widthGreaterThanHeight) {
        CGContextTranslateCTM(currentContext, -((mainImage.size.width - sideFull) / 2) * scaleFactor, 0);
    }
    else {
        CGContextTranslateCTM(currentContext, 0, -((mainImage.size.height - sideFull) / 2) * scaleFactor);
    }
    //this will automatically scale any CGImage down/up to the required thumbnail side (length) when the CGImage gets drawn into the context on the next line of code
    CGContextScaleCTM(currentContext, scaleFactor, scaleFactor);
    [mainImageView.layer renderInContext:currentContext];
    thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(thumbnail);
    //[imageData writeToFile:fullPathToThumbImage atomically:YES];
    thumbnail = [UIImage imageWithData:imageData];
    
    return thumbnail;
}


@end


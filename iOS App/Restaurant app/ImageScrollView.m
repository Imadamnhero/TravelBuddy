/*
     File: ImageScrollView.m
 Abstract: Centers image within the scroll view and configures image sizing and display.
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

#import <Foundation/Foundation.h>

#import "ImageScrollView.h"
#import "IMSSqliteManager.h"
#import "MBProgressHUD.h"

// forward declaration of our utility functions

//static UIImage *_ImageAtIndex(NSUInteger index);
//static NSString *_ImageNameAtIndex(NSUInteger index);

#pragma mark -

@interface ImageScrollView () <UIScrollViewDelegate>
{
    UIImageView *_zoomView;  // if tiling, this contains a very low-res placeholder image,
                             // otherwise it contains the full image.
    CGSize _imageSize;
        
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}

@property (nonatomic, strong) NSDictionary *imagesDict;
@end

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        mainArray = [[NSMutableArray alloc] init];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"image1.jpg",@"imageName",@"Jessica",@"name",@"50",@"percent", nil];
        [mainArray addObject:dict];
        NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"image2.jpg",@"imageName",@"Sunny",@"name",@"70",@"percent", nil];
        [mainArray addObject:dict1];
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"image3.jpg",@"imageName",@"Sunny",@"name",@"24",@"percent", nil];
        [mainArray addObject:dict2];
        NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"image4.jpg",@"imageName",@"TeayoOn",@"name",@"100",@"percent", nil];
        [mainArray addObject:dict3];
        NSMutableDictionary *dict11 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"image5.jpg",@"imageName",@"Tiffany",@"name",@"70",@"percent", nil];
        [mainArray addObject:dict11];
        NSMutableDictionary *dict21 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"image6.jpg",@"imageName",@"HuynA",@"name",@"24",@"percent", nil];
        [mainArray addObject:dict21];
        NSMutableDictionary *dict211 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"image7.jpg",@"imageName",@"HuynA",@"name",@"24",@"percent", nil];
        [mainArray addObject:dict211];
        NSMutableDictionary *dict2111 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"image8.jpg",@"imageName",@"HuynA",@"name",@"24",@"percent", nil];
        [mainArray addObject:dict2111];
    }
    return self;
}

- (void)setIndex:(NSUInteger)index
{
    _index = index;
    
    
    UIImage *image = nil;
    IMSSqliteManager *sqliteManager = [IMSSqliteManager new];
    NSString *strImageName = [[mainArray objectAtIndex:index] objectForKey:@"imageName"];
    @synchronized(self)
    {
        image = [UIImage imageNamed:strImageName];[sqliteManager getGalleryImageAtIndex:index];
    }
    
    if(image)
    {
        [self displayImage:image];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self WithTitle:nil animated:YES];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^(void) {
        
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSInteger articled = [[delegate.funSpotDict valueForKey:@"articleid"] integerValue];
            
            IMSSqliteManager *sqliteManager = [IMSSqliteManager new];
            NSDictionary *imagesDict = [sqliteManager readImages];
            
            NSString *imageName = [imagesDict valueForKey:[NSString stringWithFormat:@"image_%d",index]];
            NSString *imageURL=[NSString stringWithFormat:@"http://wikifun.com/upload/location/%d/%@",articled,imageName];
            
            NSLog(@"imageURL===%@",imageURL);
            //  You may want to cache this explicitly instead of reloading every time.
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
            UIImage* image = [[UIImage alloc] initWithData:imageData];

            dispatch_async(dispatch_get_main_queue(), ^{
            
                [MBProgressHUD hideAllHUDsForView:self animated:YES];
                [self displayImage:image];
                
                @synchronized(self)
                {
                    IMSSqliteManager *sqliteManager = [IMSSqliteManager new];
//                    [sqliteManager createTable:@"AppImages"];
                    [sqliteManager saveImage:[NSString stringWithFormat:@"GalleryImage_%d",index] Image:image];
                }
            });
        });
    }
}

+ (NSUInteger)imageCount
{
    IMSSqliteManager *sqliteManager = [[IMSSqliteManager alloc] init];
    NSDictionary *imagesDict = [sqliteManager readImages];
    return [imagesDict count];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _zoomView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _zoomView;
}


#pragma mark - Configure scrollView to display new image (tiled or not)

- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;

    // make a new UIImageView for the new image
    _zoomView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_zoomView];
    
    [self configureForImageSize:image.size];
}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
                
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    BOOL imagePortrait = _imageSize.height > _imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];

    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
        
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];

    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];

    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);

    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

@end

//static NSArray *_ImageData(void)
//{
//    static NSArray *data = nil;
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"ImageData" ofType:@"plist"];
//        NSData *plistData = [NSData dataWithContentsOfFile:path];
//        NSString *error; NSPropertyListFormat format;
//        data = [NSPropertyListSerialization propertyListFromData:plistData
//                                                mutabilityOption:NSPropertyListImmutable
//                                                          format:&format
//                                                errorDescription:&error];
//        if (!data) {
//            NSLog(@"Unable to read image data: %@", error);
//        }
//    });
//    
//    return data;
//}

//static NSString *_ImageNameAtIndex(NSUInteger index)
//{
//    NSDictionary *info = _ImageData()[index];
//    return [info valueForKey:@"name"];
//}

// we use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching
//static UIImage *_ImageAtIndex(NSUInteger index)
//{
//    NSString *imageName = _ImageNameAtIndex(index);
//    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
//    return [UIImage imageWithContentsOfFile:path];
//}

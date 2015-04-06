//
//  AsynImageButton.h
//  QGSPos
//
//  Created by vinh pham on 5/2/12.
//  Copyright (c) 2012 QGS Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsynImageButton : UIButton {
    NSURLConnection* connection;
    NSMutableData* data;
    
    UIActivityIndicatorView *myIndicator;
    
}
- (void)loadIMage:(UIImage*)imageData;
- (void)loadImageFromURL:(NSURL*)url;
- (void)loadIMageFromImage:(UIImage*)imageData;

@end

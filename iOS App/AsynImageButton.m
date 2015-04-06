//
//  AsynImageButton.m
//  QGSPos
//
//  Created by vinh pham on 5/2/12.
//  Copyright (c) 2012 QGS Inc.. All rights reserved.
//

#import "AsynImageButton.h"
#import "QuartzCore/QuartzCore.h"

@implementation AsynImageButton

- (void)loadIMageFromImage:(UIImage*)imageData
{
//    [self setImage:nil forState:UIControlStateNormal];
//    [self setImage:imageData forState:UIControlStateNormal];
    [self setBackgroundImage:nil forState:UIControlStateNormal];
    [self setBackgroundImage:imageData forState:UIControlStateNormal];
}
- (void)loadIMage:(UIImage*)imageData
{
    [self setImage:nil forState:UIControlStateNormal];
    [self setImage:imageData forState:UIControlStateNormal];
    
}
- (void)loadImageFromURL:(NSURL*)url {
    @try {
        if (![NSThread isMainThread]) {
            [self performSelectorOnMainThread:@selector(loadImageFromURL:)
                                   withObject:url waitUntilDone:NO];
            return;
        }
        if (connection!=nil) {  
//            [connection release]; 
        }
        if (data!=nil) { 
//            [data release]; 
        }
        NSURLRequest* request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60.0];

        connection = [[NSURLConnection alloc]
                      initWithRequest:request delegate:self];
        //TODO error handling, what if connection is nil?
        
    }
    @catch (NSException *e) {
        //NSlog(@"%@",e);
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
		data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	
//    [connection release];
    connection=nil;
	

    if (data != nil) {
        
        [self setTitle:@"" forState:UIControlStateNormal];
        UIImage *image = [UIImage imageWithData:data];
        [self setBackgroundImage:image forState:UIControlStateNormal];
//        [data release];
        data=nil;
    }
	
    
//    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    self.layer.borderWidth = 1;
    
}

//- (void)dealloc {
//    [connection cancel];
//    [connection release];
//    [data release];
//	
//    [super dealloc];
//}

@end

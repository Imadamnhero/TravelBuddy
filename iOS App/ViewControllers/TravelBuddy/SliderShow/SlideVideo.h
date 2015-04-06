//
//  SlideVideo.h
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 10/29/14.
//
//

#import <Foundation/Foundation.h>

@interface SlideVideo : NSObject
@property (nonatomic,strong) UIImage *thumnail;
@property (nonatomic,strong) NSString *urlVideo;
@property  int choosed;
- (void)initData :(NSString *)urlVideo choosed:(int)choosed thumnail:(UIImage *)thumnail;
@end

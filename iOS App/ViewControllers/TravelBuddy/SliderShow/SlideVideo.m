//
//  SlideVideo.m
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 10/29/14.
//
//

#import "SlideVideo.h"

@implementation SlideVideo
- (void)initData :(NSString *)urlVideo choosed:(int)choosed thumnail:(UIImage *)thumnail
{
    self.urlVideo=urlVideo;
    self.choosed=choosed;
    self.thumnail = thumnail;
}
@end

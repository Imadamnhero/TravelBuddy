//
//  SlideShow.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface SlideShow : NSObject{
    NSInteger videoId;
    NSInteger userId;
    NSInteger tripId;
    NSString *serverUrl;
    NSString *photoUrl;
}
@property (nonatomic) NSInteger userId,tripId,videoId;
@property (nonatomic, strong) NSString *serverUrl,*photoUrl;
@end

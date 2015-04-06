//
//  PackingTitleObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface PackingTitleObj : NSObject{
    NSInteger packingId;
    NSString *title;
    NSInteger ownerUserId;
    NSInteger serverId;
    NSInteger flag;
    NSInteger percent;
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSInteger packingId;
@property (nonatomic) NSInteger ownerUserId;
@property (nonatomic) NSInteger serverId;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger percent;
- (void) setPercent: (int)input;
@end
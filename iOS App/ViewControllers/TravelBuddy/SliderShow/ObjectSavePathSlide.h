//
//  ObjectSavePathSlide.h
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 11/7/14.
//
//

#import <Foundation/Foundation.h>

@interface ObjectSavePathSlide : NSObject
@property (nonatomic,strong) NSString *pathVideo;
@property int saved;
- (void)getData:(NSString *)pathVideo saved:(int)saved;
@end

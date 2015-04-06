//
//  TripObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface TripObj : NSObject{
    NSInteger tripId;
    NSString *tripLocation;
    NSString *startDate;
    NSString *finishDate;
    NSString *budget;
    NSInteger ownerUserId;
}
@property (nonatomic, strong) NSString *tripLocation,*startDate,*finishDate,*budget;
@property (nonatomic) NSInteger tripId;
@property (nonatomic) NSInteger ownerUserId;
@end
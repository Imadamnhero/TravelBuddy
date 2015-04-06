//
//  ExpenseObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface ExpenseObj : NSObject{
    NSInteger expenseId;
    NSInteger cateId;
    NSString *dateTime;
    NSString *money;
    NSString *item;
    NSInteger ownerUserId;
    NSInteger tripId;
    NSInteger serverId;
    NSInteger flag;
}
@property (nonatomic, strong) NSString *item,*dateTime,*money;
@property (nonatomic) NSInteger expenseId;
@property (nonatomic) NSInteger cateId;
@property (nonatomic) NSInteger ownerUserId;
@property (nonatomic) NSInteger tripId;
@property (nonatomic) NSInteger serverId;
@property (nonatomic) NSInteger flag;
@end
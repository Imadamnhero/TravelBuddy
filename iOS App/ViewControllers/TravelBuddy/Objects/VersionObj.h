//
//  VersionObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface VersionObj : NSObject{
    NSInteger versionId;
    NSInteger noteVersion;
    NSInteger categoryVersion;
    NSInteger expenseVersion;
    NSInteger groupVersion;
    NSInteger photoVersion;
    NSInteger packingTitleVersion;
    NSInteger packingItemVersion;
    NSInteger premadeListVersion;
    NSInteger premadeItemVersion;
    NSInteger userVersion;
    NSInteger userId;
}
@property (nonatomic) NSInteger versionId;
@property (nonatomic) NSInteger noteVersion;
@property (nonatomic) NSInteger categoryVersion;
@property (nonatomic) NSInteger expenseVersion;
@property (nonatomic) NSInteger groupVersion;
@property (nonatomic) NSInteger photoVersion;
@property (nonatomic) NSInteger packingTitleVersion;
@property (nonatomic) NSInteger packingItemVersion;
@property (nonatomic) NSInteger premadeListVersion;
@property (nonatomic) NSInteger premadeItemVersion;
@property (nonatomic) NSInteger userVersion;
@property (nonatomic) NSInteger userId;

@end

//
//  PackingTitleObj.m
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import "PackingTitleObj.h"

@implementation PackingTitleObj
@synthesize title,packingId,serverId,ownerUserId,flag,percent;

- (void) setPercent: (int)input;
{
    percent = input;
}

@end

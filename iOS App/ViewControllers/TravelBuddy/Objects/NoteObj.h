//
//  NoteObj.h
//  Fun Spot App
//
//  Created by MAC on 9/11/14.
//
//

#import <Foundation/Foundation.h>

@interface NoteObj : NSObject{
    NSInteger noteId;
    NSString *title;
    NSString *dateTime;
    NSString *content;
    NSInteger ownerUserId;
    NSInteger tripId;
    NSInteger serverId;
    NSInteger flag;
    NSString *userAddNote;
    
    NSString *noteUrl;
    UIImage *noteIcon;

}
@property (nonatomic, strong) NSString *title,*dateTime,*content,*noteUrl,*userAddNote;
@property (nonatomic) NSInteger noteId;
@property (nonatomic) NSInteger ownerUserId;
@property (nonatomic) NSInteger tripId;
@property (nonatomic) NSInteger serverId;
@property (nonatomic) NSInteger flag;

@property(nonatomic, strong) UIImage *noteIcon;

@end
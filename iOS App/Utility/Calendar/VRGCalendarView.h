//
//  VRGCalendarView.h
//  Vurig
//
//  Created by in 't Veen Tjeerd on 5/8/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//


#import <UIKit/UIKit.h>
//#import "Define.h"
#import "UIColor+expanded.h"
//#import "UserObj.h"
//#import "CoreDataManager.h"
//#import "CalendarsObj.h"
//#import "CalistObj.h"
#import "IMSSqliteManager.h"

#define dDeviceOrientation [[UIDevice currentDevice] orientation]
#define isPortrait  UIDeviceOrientationIsPortrait(dDeviceOrientation)
#define isLandscape UIDeviceOrientationIsLandscape(dDeviceOrientation)

#define kVRGCalendarViewTopBarHeight 70

#define kVRGCalendarViewWidth IS_IPAD?(isPortrait?768:1024):320

#define kVRGCalendarViewDayWidth IS_IPAD?(isPortrait?109:147):44
#define kVRGCalendarViewDayHeight IS_IPAD?(isPortrait?109:147):40

//#define kVRGCalendarViewDayWidth  IS_IPAD?85:44
//#define kVRGCalendarViewDayHeight IS_IPAD?85:40

@protocol VRGCalendarViewDelegate;
@interface VRGCalendarView : UIView {
    id <VRGCalendarViewDelegate> delegate;
    
    NSDate *currentMonth;
    
    UILabel *labelCurrentMonth;
    
    BOOL isAnimating;
    BOOL prepAnimationPreviousMonth;
    BOOL prepAnimationNextMonth;
    
    UIImageView *animationView_A;
    UIImageView *animationView_B;
    
    NSMutableArray *markedDates;
    NSArray *markedColors;
    NSMutableArray *arr;
    NSMutableArray *arrCal;
    
    AppDelegate *appDelegate;
    
    IMSSqliteManager *sqlManager;
}

//@property (nonatomic, retain) UserObj *obj;
@property (nonatomic, retain) id <VRGCalendarViewDelegate> delegate;
@property (nonatomic, retain) NSDate *currentMonth;
@property (nonatomic, retain) UILabel *labelCurrentMonth;
@property (nonatomic, retain) UIImageView *animationView_A;
@property (nonatomic, retain) UIImageView *animationView_B;
@property (nonatomic, retain) NSMutableArray *markedDates;
@property (nonatomic, retain) NSArray *markedColors;
@property (nonatomic, getter = calendarHeight) float calendarHeight;
@property (nonatomic, retain, getter = selectedDate) NSDate *selectedDate;

-(void)selectDate:(int)date;
-(void)reset;

-(void)markDates:(NSArray *)dates;
-(void)markDates:(NSArray *)dates withColors:(NSArray *)colors;

-(void)showNextMonth;
-(void)showPreviousMonth;

-(int)numRows;
-(void)updateSize;
-(UIImage *)drawCurrentState;

@end

@protocol VRGCalendarViewDelegate <NSObject>
-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated;
-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date andArr:(NSMutableArray*)_arr;
@end

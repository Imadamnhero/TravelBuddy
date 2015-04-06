//
//  VRGCalendarView.m
//  Vurig
//
//  Created by in 't Veen Tjeerd on 5/8/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//

#import "VRGCalendarView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDate+convenience.h"
#import "NSMutableArray+convenience.h"
#import "UIView+convenience.h"
//#import "Define.h"

@implementation VRGCalendarView
@synthesize currentMonth,delegate,labelCurrentMonth, animationView_A,animationView_B;
@synthesize markedDates,markedColors,calendarHeight,selectedDate;

#pragma mark - Select Date
-(void)selectDate:(int)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.currentMonth];
    [comps setDay:date];
    self.selectedDate = [gregorian dateFromComponents:comps];
    
    int selectedDateYear = [selectedDate year];
    int selectedDateMonth = [selectedDate month];
    int currentMonthYear = [currentMonth year];
    int currentMonthMonth = [currentMonth month];
    
    if (selectedDateYear < currentMonthYear) {
        [self showPreviousMonth];
    } else if (selectedDateYear > currentMonthYear) {
        [self showNextMonth];
    } else if (selectedDateMonth < currentMonthMonth) {
        [self showPreviousMonth];
    } else if (selectedDateMonth > currentMonthMonth) {
        [self showNextMonth];
    } else {
//        [self setNeedsDisplay];
    }
    
    if ([delegate respondsToSelector:@selector(calendarView:dateSelected:andArr:)]) [delegate calendarView:self dateSelected:self.selectedDate andArr:arrCal];
}

#pragma mark - Mark Dates
//NSArray can either contain NSDate objects or NSNumber objects with an int of the day.
-(void)markDates:(NSMutableArray *)dates {
    self.markedDates = dates;
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<[dates count]; i++) {
        [colors addObject:[UIColor colorWithHexString:@"0x383838"]];
    }
    
    self.markedColors = [NSArray arrayWithArray:colors];
//    [colors release];
    
    [self setNeedsDisplay];
}

//NSArray can either contain NSDate objects or NSNumber objects with an int of the day.
-(void)markDates:(NSMutableArray *)dates withColors:(NSArray *)colors {
    self.markedDates = dates;
    self.markedColors = colors;
    
    [self setNeedsDisplay];
}

#pragma mark - Set date to now
-(void)reset {
//    NSCalendar *gregorian = [[NSCalendar alloc]
//                             initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *components =
//    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |
//                           NSDayCalendarUnit) fromDate: [NSDate date]];
//    self.currentMonth = [gregorian dateFromComponents:components]; //clean month
    
    [self updateSize];
    [self setNeedsDisplay];
    [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:NO];
}

#pragma mark - Next & Previous
-(void)showNextMonth {
    if (isAnimating) return;
    self.markedDates=nil;
    isAnimating=YES;
    prepAnimationNextMonth=YES;
    
//    [self setNeedsDisplay];
    
    int lastBlock = [currentMonth firstWeekDayInMonth]+[currentMonth numDaysInMonth]-1;
    int numBlocks = [self numRows]*7;
    BOOL hasNextMonthDays = lastBlock<numBlocks;
    
    //Old month
    float oldSize = self.calendarHeight;
    UIImage *imageCurrentMonth = [self drawCurrentState];
    
    //New month
    self.currentMonth = [currentMonth offsetMonth:1];
    [USER_DEFAULT setObject:self.currentMonth forKey:@"currentMonth"];
    if ([delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight: animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:YES];
    prepAnimationNextMonth=NO;
    [self setNeedsDisplay];
    
    UIImage *imageNextMonth = [self drawCurrentState];
    float targetSize = fmaxf(oldSize, self.calendarHeight);
    UIView *animationHolder = [[UIView alloc] initWithFrame:CGRectMake(0, kVRGCalendarViewTopBarHeight, kVRGCalendarViewWidth, targetSize-kVRGCalendarViewTopBarHeight)];
    [animationHolder setClipsToBounds:YES];
    [self addSubview:animationHolder];
//    [animationHolder release];
    
    //Animate
    self.animationView_A = [[UIImageView alloc] initWithImage:imageCurrentMonth];
    self.animationView_B = [[UIImageView alloc] initWithImage:imageNextMonth];
    [animationHolder addSubview:animationView_A];
    [animationHolder addSubview:animationView_B];
    
    if (hasNextMonthDays) {
        animationView_B.frameY = animationView_A.frameY + animationView_A.frameHeight - (kVRGCalendarViewDayHeight+3);
    } else {
        animationView_B.frameY = animationView_A.frameY + animationView_A.frameHeight -3;
    }
    
    //Animation
    __block VRGCalendarView *blockSafeSelf = self;
    [UIView animateWithDuration:.35
                     animations:^{
                         [self updateSize];
                         //blockSafeSelf.frameHeight = 100;
                         if (hasNextMonthDays) {
                             animationView_A.frameY = -animationView_A.frameHeight + kVRGCalendarViewDayHeight+3;
                         } else {
                             animationView_A.frameY = -animationView_A.frameHeight + 3;
                         }
                         animationView_B.frameY = 0;
                     }
                     completion:^(BOOL finished) {
                         [animationView_A removeFromSuperview];
                         [animationView_B removeFromSuperview];
                         blockSafeSelf.animationView_A=nil;
                         blockSafeSelf.animationView_B=nil;
                         isAnimating=NO;
                         [animationHolder removeFromSuperview];
                     }
     ];
}

-(void)showPreviousMonth {
    if (isAnimating) return;
    isAnimating=YES;
    self.markedDates=nil;
    //Prepare current screen
    prepAnimationPreviousMonth = YES;
//    [self setNeedsDisplay];
    BOOL hasPreviousDays = [currentMonth firstWeekDayInMonth]>1;
    float oldSize = self.calendarHeight;
    UIImage *imageCurrentMonth = [self drawCurrentState];
    
    //Prepare next screen
    self.currentMonth = [currentMonth offsetMonth:-1];
    [USER_DEFAULT setObject:self.currentMonth forKey:@"currentMonth"];
    if ([delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight:animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:YES];
    prepAnimationPreviousMonth=NO;
    [self setNeedsDisplay];
    UIImage *imagePreviousMonth = [self drawCurrentState];
    
    float targetSize = fmaxf(oldSize, self.calendarHeight);
    UIView *animationHolder = [[UIView alloc] initWithFrame:CGRectMake(0, kVRGCalendarViewTopBarHeight, kVRGCalendarViewWidth, targetSize-kVRGCalendarViewTopBarHeight)];
    
    [animationHolder setClipsToBounds:YES];
    [self addSubview:animationHolder];
//    [animationHolder release];
    
    self.animationView_A = [[UIImageView alloc] initWithImage:imageCurrentMonth];
    self.animationView_B = [[UIImageView alloc] initWithImage:imagePreviousMonth];
    [animationHolder addSubview:animationView_A];
    [animationHolder addSubview:animationView_B];
    
    if (hasPreviousDays) {
        animationView_B.frameY = animationView_A.frameY - (animationView_B.frameHeight-kVRGCalendarViewDayHeight) + 3;
    } else {
        animationView_B.frameY = animationView_A.frameY - animationView_B.frameHeight + 3;
    }
    
    __block VRGCalendarView *blockSafeSelf = self;
    [UIView animateWithDuration:.35
                     animations:^{
                         [self updateSize];
                         
                         if (hasPreviousDays) {
                             animationView_A.frameY = animationView_B.frameHeight-(kVRGCalendarViewDayHeight+3);
                             
                         } else {
                             animationView_A.frameY = animationView_B.frameHeight-3;
                         }
                         
                         animationView_B.frameY = 0;
                     }
                     completion:^(BOOL finished) {
                         [animationView_A removeFromSuperview];
                         [animationView_B removeFromSuperview];
                         blockSafeSelf.animationView_A=nil;
                         blockSafeSelf.animationView_B=nil;
                         isAnimating=NO;
                         [animationHolder removeFromSuperview];
                     }
     ];
}


#pragma mark - update size & row count
-(void)updateSize {
    self.frameHeight = self.calendarHeight;
    [self setNeedsDisplay];
}

-(float)calendarHeight {
    return kVRGCalendarViewTopBarHeight + [self numRows]*(kVRGCalendarViewDayHeight+2)+1;
}

-(int)numRows {
    float lastBlock = [self.currentMonth numDaysInMonth]+([self.currentMonth firstWeekDayInMonth]-1);
    return ceilf(lastBlock/7);
}

#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    self.selectedDate=nil;
    
    //Touch a specific day
    if (touchPoint.y > kVRGCalendarViewTopBarHeight) {
        float xLocation = touchPoint.x;
        float yLocation = touchPoint.y-kVRGCalendarViewTopBarHeight;
        
        int column = floorf(xLocation/(kVRGCalendarViewDayWidth+2));
        int row = floorf(yLocation/(kVRGCalendarViewDayHeight+2));
        
        int blockNr = (column+1)+row*7;
        int firstWeekDay = [self.currentMonth firstWeekDayInMonth]-1; //-1 because weekdays begin at 1, not 0
        int date = blockNr-firstWeekDay;
        [self selectDate:date];
        return;
    }
    
    self.markedDates=nil;
    self.markedColors=nil;
    
    CGRect rectArrowLeft = CGRectMake(0, 0, 60, 64);
    CGRect rectArrowRight = CGRectMake(self.frame.size.width-60, 0, 60, 64);
    
    //Touch either arrows or month in middle
    if (CGRectContainsPoint(rectArrowLeft, touchPoint)) {
        [self showPreviousMonth];
    } else if (CGRectContainsPoint(rectArrowRight, touchPoint)) {
        [self showNextMonth];
    } else if (CGRectContainsPoint(self.labelCurrentMonth.frame, touchPoint)) {
        //Detect touch in current month
        int currentMonthIndex = [self.currentMonth month];
        int todayMonth = [[NSDate date] month];
        [self reset];
        if ((todayMonth!=currentMonthIndex) && [delegate respondsToSelector:@selector(calendarView:switchedToMonth:targetHeight:animated:)]) [delegate calendarView:self switchedToMonth:[currentMonth month] targetHeight:self.calendarHeight animated:NO];
    }
}

- (NSString*) changeFr:(NSString*)_str
{
    if ([_str isEqualToString:@"Mon"]) {
        return @"Lu";
    }else if ([_str isEqualToString:@"Tue"]) {
        return @"Ma";
    }else if ([_str isEqualToString:@"Wed"]) {
        return @"Me";
    }else if ([_str isEqualToString:@"Thu"]) {
        return @"Je";
    }else if ([_str isEqualToString:@"Fri"]) {
        return @"Ve";
    }else if ([_str isEqualToString:@"Sat"]) {
        return @"Sa";
    }else if ([_str isEqualToString:@"Sun"]) {
        return @"Di";
    }
    return @"";
}



#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    NSLog(@"Draw");
    int firstWeekDay = [self.currentMonth firstWeekDayInMonth]-1; //-1 because weekdays begin at 1, not 0
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM yyyy"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    labelCurrentMonth.text = [[formatter stringFromDate:self.currentMonth] uppercaseString] ;
    [labelCurrentMonth sizeToFit];
    labelCurrentMonth.frameX = roundf(self.frame.size.width/2 - labelCurrentMonth.frameWidth/2);
    labelCurrentMonth.frameY = 9;
//    [formatter release];
    [currentMonth firstWeekDayInMonth];
    appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIColor *color = [UIColor colorWithHexString:(appDelegate.funSpotDict)[@"color_nav"]];//[UIColor colorWithRed:30.0f/255 green:182.0f/255 blue:320.0f/255 alpha:1.0f];
//    if (_obj.user_id > 0) {
//        if (_obj.pet_type == DOG) {
//            color = [UIColor colorWithRed:238.0f/255 green:105.0f/255 blue:102.0f/255 alpha:1.0f];
//        }else
//        {
            color = [UIColor colorWithRed:135.0f/255 green:215.0f/255 blue:29.0f/255 alpha:1.0f];
//        }
//    }
    
    labelCurrentMonth.textColor = color;
    
    CGContextClearRect(UIGraphicsGetCurrentContext(),rect);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rectangle = CGRectMake(0,0,self.frame.size.width,kVRGCalendarViewTopBarHeight);
    CGContextAddRect(context, rectangle);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillPath(context);
    
    rectangle = CGRectMake(0,38,self.frame.size.width,32);
    CGContextAddRect(context, rectangle);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    
    //Arrows
    int arrowSize = 16;
    int xmargin = 20;
    int ymargin = 12;
    
    //Arrow Left
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, xmargin+arrowSize/1.5, ymargin);
    CGContextAddLineToPoint(context,xmargin+arrowSize/1.5,ymargin+arrowSize);
    CGContextAddLineToPoint(context,xmargin,ymargin+arrowSize/2);
    CGContextAddLineToPoint(context,xmargin+arrowSize/1.5, ymargin);
    
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillPath(context);
    
    //Arrow right
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, self.frame.size.width-(xmargin+arrowSize/1.5), ymargin);
    CGContextAddLineToPoint(context,self.frame.size.width-xmargin,ymargin+arrowSize/2);
    CGContextAddLineToPoint(context,self.frame.size.width-(xmargin+arrowSize/1.5),ymargin+arrowSize);
    CGContextAddLineToPoint(context,self.frame.size.width-(xmargin+arrowSize/1.5), ymargin);
    
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillPath(context);
    
    //Weekdays
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"EEE";
    //always assume gregorian with monday first
    NSMutableArray *weekdays = [[NSMutableArray alloc] initWithArray:[dateFormatter shortWeekdaySymbols]];
    [weekdays moveObjectFromIndex:0 toIndex:6];
    
    CGContextSetFillColorWithColor(context,
                                   [UIColor whiteColor].CGColor);
    for (int i =0; i<[weekdays count]; i++) {
        NSString *weekdayValue = (NSString *)[weekdays objectAtIndex:i];//[self changeFr:(NSString *)[weekdays objectAtIndex:i]];
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:IS_IPAD?17:12];
        NSLog(@"y = %f",labelCurrentMonth.frame.origin.y);
        [weekdayValue drawInRect:CGRectMake(i*(kVRGCalendarViewDayWidth+2), IS_IPAD?labelCurrentMonth.frame.origin.y+40:46, kVRGCalendarViewDayWidth+2, 20) withFont:font lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
        
//        // Make a copy of the default paragraph style
//        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//        // Set line break mode
//        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//        // Set text alignment
//        paragraphStyle.alignment = NSTextAlignmentCenter;
//        
//        NSDictionary *attributes = @{ NSFontAttributeName: font,
//                                      NSParagraphStyleAttributeName: paragraphStyle };
//        
//        [weekdayValue drawInRect:CGRectMake(i*(kVRGCalendarViewDayWidth+2), IS_IPAD?labelCurrentMonth.frame.origin.y+40:46, kVRGCalendarViewDayWidth+2, 20) withAttributes:attributes];
    }
    
    int numRows = [self numRows];
    
    CGContextSetAllowsAntialiasing(context, NO);
    
    //Grid background
    float gridHeight = numRows*(kVRGCalendarViewDayHeight+2)+1;
    CGRect rectangleGrid = CGRectMake(0,kVRGCalendarViewTopBarHeight,self.frame.size.width,gridHeight);
    CGContextAddRect(context, rectangleGrid);
    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xf3f3f3"].CGColor);
    //CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xff0000"].CGColor);
    CGContextFillPath(context);
    
    //Grid white lines
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight+1);
    CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight+1);
    for (int i = 1; i<7; i++) {
        CGContextMoveToPoint(context, i*(kVRGCalendarViewDayWidth+1)+i*1-1, kVRGCalendarViewTopBarHeight);
        CGContextAddLineToPoint(context, i*(kVRGCalendarViewDayWidth+1)+i*1-1, kVRGCalendarViewTopBarHeight+gridHeight);
        
        if (i>numRows-1) continue;
        //rows
        CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight+i*(kVRGCalendarViewDayHeight+1)+i*1+1);
        CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight+i*(kVRGCalendarViewDayHeight+1)+i*1+1);
    }
    
    CGContextStrokePath(context);
    
    //Grid dark lines
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:@"0xcfd4d8"].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight);
    CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight);
    for (int i = 1; i<7; i++) {
        //columns
        CGContextMoveToPoint(context, i*(kVRGCalendarViewDayWidth+1)+i*1, kVRGCalendarViewTopBarHeight);
        CGContextAddLineToPoint(context, i*(kVRGCalendarViewDayWidth+1)+i*1, kVRGCalendarViewTopBarHeight+gridHeight);
        
        if (i>numRows-1) continue;
        //rows
        CGContextMoveToPoint(context, 0, kVRGCalendarViewTopBarHeight+i*(kVRGCalendarViewDayHeight+1)+i*1);
        CGContextAddLineToPoint(context, kVRGCalendarViewWidth, kVRGCalendarViewTopBarHeight+i*(kVRGCalendarViewDayHeight+1)+i*1);
    }
    CGContextMoveToPoint(context, 0, gridHeight+kVRGCalendarViewTopBarHeight);
    CGContextAddLineToPoint(context, kVRGCalendarViewWidth, gridHeight+kVRGCalendarViewTopBarHeight);
    
    CGContextStrokePath(context);
    
    CGContextSetAllowsAntialiasing(context, YES);
    
    //Draw days
    CGContextSetFillColorWithColor(context,
                                   [UIColor colorWithHexString:@"0x383838"].CGColor);
    
    
    //NSLog(@"currentMonth month = %i, first weekday in month = %i",[self.currentMonth month],[self.currentMonth firstWeekDayInMonth]);
    
    int numBlocks = numRows*7;
    NSDate *previousMonth = [self.currentMonth offsetMonth:-1];
    int currentMonthNumDays = [currentMonth numDaysInMonth];
    int prevMonthNumDays = [previousMonth numDaysInMonth];
    
    int selectedDateBlock = ([selectedDate day]-1)+firstWeekDay;
    
    //prepAnimationPreviousMonth nog wat mee doen
    
    //prev next month
    BOOL isSelectedDatePreviousMonth = prepAnimationPreviousMonth;
    BOOL isSelectedDateNextMonth = prepAnimationNextMonth;
    
    if (self.selectedDate!=nil) {
        isSelectedDatePreviousMonth = ([selectedDate year]==[currentMonth year] && [selectedDate month]<[currentMonth month]) || [selectedDate year] < [currentMonth year];
        
        if (!isSelectedDatePreviousMonth) {
            isSelectedDateNextMonth = ([selectedDate year]==[currentMonth year] && [selectedDate month]>[currentMonth month]) || [selectedDate year] > [currentMonth year];
        }
    }
    
    if (isSelectedDatePreviousMonth) {
        int lastPositionPreviousMonth = firstWeekDay-1;
        selectedDateBlock=lastPositionPreviousMonth-([selectedDate numDaysInMonth]-[selectedDate day]);
    } else if (isSelectedDateNextMonth) {
        selectedDateBlock = [currentMonth numDaysInMonth] + (firstWeekDay-1) + [selectedDate day];
    }
    
    
    NSDate *todayDate = [NSDate date];
    int todayBlock = -1;
    
    //    NSLog(@"currentMonth month = %i day = %i, todaydate day = %i",[currentMonth month],[currentMonth day],[todayDate month]);
    
    if ([todayDate month] == [currentMonth month] && [todayDate year] == [currentMonth year]) {
        todayBlock = [todayDate day] + firstWeekDay - 1;
    }
    
    //Draw markings
        
    NSDateFormatter *dateF = [[NSDateFormatter alloc]init];
    dateF.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    if (_obj.user_id > 0) {
//        arr = [sqlManager selectAllCalendar:_obj.user_id];
//    }else
//    {
//        arr = [sqlManager selectAllCalendar:0];
//    }
    
    arrCal = [[NSMutableArray alloc] init];
    
//    for (CalendarsObj *obj in arr) {
//        if (obj.calendar_recurent_type == 0) {
//            if ([currentMonth month] == obj.calendar_month && [currentMonth year] == obj.calendar_year)
//            {
//                int targetDate;
//                targetDate = obj.calendar_day;
//                int targetBlock = firstWeekDay + (targetDate-1);
//                
//                int targetColumn = targetBlock%7;
//                int targetRow = targetBlock/7;
//                
//                int targetX = targetColumn * (kVRGCalendarViewDayWidth+2) + 7;
//                int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2) + 5;
//                
//                CGRect rectangle = CGRectMake(IS_IPAD?targetX+7:targetX,IS_IPAD?targetY+8:targetY,IS_IPAD?64:32,IS_IPAD?64:32);
//                CGContextAddEllipseInRect(context, rectangle);
//                
//                CGContextSetFillColorWithColor(context, color.CGColor);
//                CGContextFillPath(context);
//                CalistObj *ob = [[CalistObj alloc] init];
//                ob.date = targetDate;
//                ob.cal = obj;
//                [arrCal addObject:ob];
//            }
//        }else
//        {
//            int monthEnd = [[obj.calendar_date_end substringWithRange:NSMakeRange(3, 2)] intValue];
//            int dayEnd = [[obj.calendar_date_end substringWithRange:NSMakeRange(0, 2)] intValue];
//            int yearEnd = [[obj.calendar_date_end substringWithRange:NSMakeRange(6, 4)] intValue];
//            
//            NSString *strDate = [[dateF stringFromDate:[NSDate date]] substringWithRange:NSMakeRange(0, 19)];
//            
//            NSDate *date = [Common convertDateTime:[NSString stringWithFormat:@"%d-%d-%d 12:00:00", obj.calendar_year, obj.calendar_month, obj.calendar_day] serverTime:strDate andFormat:([dateF stringFromDate:[NSDate date]].length>19?@"yyyy-MM-dd hh:mm:ss":@"yyyy-MM-dd HH:mm:ss")];
//            
//            if (yearEnd > [currentMonth year]
//                || (yearEnd == [currentMonth year] && monthEnd >= [currentMonth month])) {
//                
//                if (obj.calendar_recurent_type == 1) {// DAY
//                    
//                    while ([date year] < [currentMonth year]) {
//                        date = [date dateByAddingTimeInterval:60*60*24*obj.calendar_recurence];
//                        NSLog(@"[date year] %d, [currentMonth year] %d", [date year], [currentMonth year]);
//                    }
//                    while ([date month] <= [currentMonth month]
//                           && [date year] == [currentMonth year]
//                           && ([date year] < yearEnd
//                               || ([date year] == yearEnd && [date month] < monthEnd) || ([date year] == yearEnd
//                                                                                          && [date month] == monthEnd && [date day] <= dayEnd))) {
//                                   if ([date month] == [currentMonth month]) {
//                                       int targetDate;
//                                       targetDate = [date day];
//                                       int targetBlock = firstWeekDay + (targetDate-1);
//                                       
//                                       int targetColumn = targetBlock%7;
//                                       int targetRow = targetBlock/7;
//                                       
//                                       int targetX = targetColumn * (kVRGCalendarViewDayWidth+2) + 7;
//                                       int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2) + 5;
//                                       
//                                       NSLog(@"Day ne :) draw circle for day");
//                                       int circleY = 7;
//                                       if (self.frame.size.width == 1024) {
//                                           circleY = 23;
//                                       }
//                                       CGRect rectangle = CGRectMake(IS_IPAD?targetX+circleY:targetX,IS_IPAD?targetY+circleY:targetY,IS_IPAD?90:32,IS_IPAD?90:32);
//                                       CGContextAddEllipseInRect(context, rectangle);
//                                       
//                                       CGContextSetFillColorWithColor(context, color.CGColor);
//                                       CGContextFillPath(context);
//                                       CalistObj *ob = [[CalistObj alloc] init];
//                                       ob.date = targetDate;
//                                       ob.cal = obj;
//                                       [arrCal addObject:ob];
//                                   }
//                                   date = [date dateByAddingTimeInterval:60*60*24*obj.calendar_recurence];
//                               }
//                    
//                }else if(obj.calendar_recurent_type == 2){// WEEK
//                    while ([date year] < [currentMonth year]) {
//                        date = [date dateByAddingTimeInterval:60*60*24*obj.calendar_recurence*7];
//                    }
//                    while ([date month] <= [currentMonth month]
//                           && [date year] == [currentMonth year]
//                           && ([date year] < yearEnd
//                               || ([date year] == yearEnd && [date month] < monthEnd) || ([date year] == yearEnd
//                                                                                          && [date month] == monthEnd && [date day] <= dayEnd))) {
//                                   if ([date month] == [currentMonth month]) {
//                                       int targetDate;
//                                       targetDate = [date day];
//                                       int targetBlock = firstWeekDay + (targetDate-1);
//                                       
//                                       int targetColumn = targetBlock%7;
//                                       int targetRow = targetBlock/7;
//                                       
//                                       int targetX = targetColumn * (kVRGCalendarViewDayWidth+2) + 7;
//                                       int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2) + 5;
//                                       
//                                       CGRect rectangle = CGRectMake(IS_IPAD?targetX+7:targetX,IS_IPAD?targetY+8:targetY,IS_IPAD?64:32,IS_IPAD?64:32);
//                                       
//                                       CGContextAddEllipseInRect(context, rectangle);
//                                       
//                                       CGContextSetFillColorWithColor(context, color.CGColor);
//                                       CGContextFillPath(context);
//                                       CalistObj *ob = [[CalistObj alloc] init];
//                                       ob.date = targetDate;
//                                       ob.cal = obj;
//                                       [arrCal addObject:ob];
//                                       
//                                   }
//                                   date = [date dateByAddingTimeInterval:60*60*24*obj.calendar_recurence*7];
//                               }
//                    
//                }else if(obj.calendar_recurent_type == 3){// MONTH
//                    while ([date year] < [currentMonth year]) {
//                        
//                        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
//                        [dateComponents setMonth:obj.calendar_recurence];
//                        NSCalendar* calendar = [NSCalendar currentCalendar];
//                        date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
//                        
//                    }
//                    while ([date month] <= [currentMonth month]
//                           && [date year] == [currentMonth year]) {
//                        if ([date month] == [currentMonth month]
//                            && obj.calendar_day == [date day]
//                            && ([date year] < yearEnd
//                                || ([date year] == yearEnd && [date month] < monthEnd) || ([date year] == yearEnd
//                                                                                           && [date month] == monthEnd && [date day] <= dayEnd))) {
//                                    int targetDate;
//                                    targetDate = [date day];
//                                    int targetBlock = firstWeekDay + (targetDate-1);
//                                    
//                                    int targetColumn = targetBlock%7;
//                                    int targetRow = targetBlock/7;
//                                    
//                                    int targetX = targetColumn * (kVRGCalendarViewDayWidth+2) + 7;
//                                    int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2) + 5;
//                                    
//                                    CGRect rectangle = CGRectMake(IS_IPAD?targetX+7:targetX,IS_IPAD?targetY+8:targetY,IS_IPAD?64:32,IS_IPAD?64:32);
//                                    
//                                    CGContextAddEllipseInRect(context, rectangle);
//                                    
//                                    CGContextSetFillColorWithColor(context, color.CGColor);
//                                    CGContextFillPath(context);
//                                    CalistObj *ob = [[CalistObj alloc] init];
//                                    ob.date = targetDate;
//                                    ob.cal = obj;
//                                    [arrCal addObject:ob];
//                                    
//                                }
//                        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
//                        [dateComponents setMonth:obj.calendar_recurence];
//                        NSCalendar* calendar = [NSCalendar currentCalendar];
//                        date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
//                    }
//                    
//                }else if(obj.calendar_recurent_type == 4){// YEAR
//                    while ([date year] < [currentMonth year]) {
//                        
//                        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
//                        [dateComponents setYear:obj.calendar_recurence];
//                        NSCalendar* calendar = [NSCalendar currentCalendar];
//                        date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
//                        
//                    }
//                    if (obj.calendar_month == [currentMonth month]) {
//                        if (([date year] < yearEnd
//                             || ([date year] == yearEnd && [date month] < monthEnd) || ([date year] == yearEnd
//                                                                                        && [date month] == monthEnd && [date day] <= dayEnd))) {
//                                 int targetDate;
//                                 targetDate = [date day];
//                                 int targetBlock = firstWeekDay + (targetDate-1);
//                                 
//                                 int targetColumn = targetBlock%7;
//                                 int targetRow = targetBlock/7;
//                                 
//                                 int targetX = targetColumn * (kVRGCalendarViewDayWidth+2) + 7;
//                                 int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2) + 5;
//                                 
//                                 CGRect rectangle = CGRectMake(IS_IPAD?targetX+7:targetX,IS_IPAD?targetY+8:targetY,IS_IPAD?64:32,IS_IPAD?64:32);
//                                 
//                                 CGContextAddEllipseInRect(context, rectangle);
//                                 
//                                 CGContextSetFillColorWithColor(context, color.CGColor);
//                                 CGContextFillPath(context);
//                                 CalistObj *ob = [[CalistObj alloc] init];
//                                 ob.date = targetDate;
//                                 ob.cal = obj;
//                                 [arrCal addObject:ob];
//                                 
//                             }
//                        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
//                        [dateComponents setYear:obj.calendar_recurence];
//                        NSCalendar* calendar = [NSCalendar currentCalendar];
//                        date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
//                    }
//                }
//            }
//        }
//    }
    
    /*
     if (!self.markedDates || isSelectedDatePreviousMonth || isSelectedDateNextMonth){
     
     }else{
     for (int i = 0; i<[self.markedDates count]; i++) {
     id markedDateObj = [self.markedDates objectAtIndex:i];
     
     int targetDate;
     if ([markedDateObj isKindOfClass:[NSNumber class]]) {
     targetDate = [(NSNumber *)markedDateObj intValue];
     } else if ([markedDateObj isKindOfClass:[NSDate class]]) {
     NSDate *date = (NSDate *)markedDateObj;
     if ([date day] == [currentMonth day] && [date month] == [currentMonth month] && [date year] == [currentMonth year]) {
     targetDate = [date day];
     }else
     {
     continue;
     }
     } else {
     continue;
     }
     
     int targetBlock = firstWeekDay + (targetDate-1);
     
     int targetColumn = targetBlock%7;
     int targetRow = targetBlock/7;
     
     int targetX = targetColumn * (kVRGCalendarViewDayWidth+2) + 7;
     int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2) + 5;
     
     CGRect rectangle = CGRectMake(targetX,targetY,32,32);
     CGContextAddEllipseInRect(context, rectangle);
     
     CGContextSetFillColorWithColor(context, color.CGColor);
     CGContextFillPath(context);
     
     }
     }
     */
    for (int i=0; i<numBlocks; i++) {
        int targetDate = i;
        int targetColumn = i%7;
        int targetRow = i/7;
        int targetX = targetColumn * (kVRGCalendarViewDayWidth+2);
        int targetY = kVRGCalendarViewTopBarHeight + targetRow * (kVRGCalendarViewDayHeight+2);
        
        // BOOL isCurrentMonth = NO;
        if (i<firstWeekDay) { //previous month
            targetDate = (prevMonthNumDays-firstWeekDay)+(i+1);
            NSString *hex = (isSelectedDatePreviousMonth) ? @"0x383838" : @"aaaaaa";
            
            CGContextSetFillColorWithColor(context,
                                           [UIColor colorWithHexString:hex].CGColor);
        } else if (i>=(firstWeekDay+currentMonthNumDays)) { //next month
            targetDate = (i+1) - (firstWeekDay+currentMonthNumDays);
            NSString *hex = (isSelectedDateNextMonth) ? @"0x383838" : @"aaaaaa";
            CGContextSetFillColorWithColor(context,
                                           [UIColor colorWithHexString:hex].CGColor);
        } else { //current month
            // isCurrentMonth = YES;
            targetDate = (i-firstWeekDay)+1;
            NSString *hex = (isSelectedDatePreviousMonth || isSelectedDateNextMonth) ? @"0xaaaaaa" : @"0x383838";
            CGContextSetFillColorWithColor(context,
                                           [UIColor colorWithHexString:hex].CGColor);
            
//            for (CalistObj *o in arrCal) {
//                if (o.date == targetDate) {
//                    CGContextSetFillColorWithColor(context,
//                                                   [UIColor whiteColor].CGColor);
//                    break;
//                }
//            }
        }
        
        NSString *date = [NSString stringWithFormat:@"%i",targetDate];
        
        //draw selected date
        if (selectedDate && i==selectedDateBlock) {
            /*
             CGRect rectangleGrid = CGRectMake(targetX,targetY,kVRGCalendarViewDayWidth+2,kVRGCalendarViewDayHeight+2);
             CGContextAddRect(context, rectangleGrid);
             CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0x006dbc"].CGColor);
             CGContextFillPath(context);
             
             CGContextSetFillColorWithColor(context,
             [UIColor whiteColor].CGColor);
             */
        } else if (todayBlock==i) {
            
            UIColor *colorToday = [UIColor colorWithRed:30.0f/255 green:182.0f/255 blue:320.0f/255 alpha:0.2f];
//            if (_obj.pet_id > 0) {
//                if (_obj.pet_type == DOG) {
//                    colorToday = [UIColor colorWithRed:238.0f/255 green:105.0f/255 blue:102.0f/255 alpha:0.2f];
//                }else
//                {
//                    colorToday = [UIColor colorWithRed:186.0f/255 green:217.0f/255 blue:42.0f/255 alpha:0.2f];
//                }
//            }
            
            CGRect rectangleGrid = CGRectMake(IS_IPAD?targetX+5:targetX,IS_IPAD?targetY:targetY,kVRGCalendarViewDayWidth+2,kVRGCalendarViewDayHeight+2);
            CGContextAddRect(context, rectangleGrid);
            CGContextSetFillColorWithColor(context, colorToday.CGColor);
            CGContextFillPath(context);
            
            CGContextSetFillColorWithColor(context,
                                           [UIColor whiteColor].CGColor);
        }
        
        int dateY = 39;
        if (self.frame.size.width == 1024) {
            dateY = 56;
        }
        [date drawInRect:CGRectMake(IS_IPAD?targetX+4:targetX, IS_IPAD?targetY+dateY:targetY+10, kVRGCalendarViewDayWidth, kVRGCalendarViewDayHeight) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:IS_IPAD?25:17] lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
        
//        // Make a copy of the default paragraph style
//        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//        // Set line break mode
//        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//        // Set text alignment
//        paragraphStyle.alignment = NSTextAlignmentCenter;
//        
//        NSDictionary *attributes = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:IS_IPAD?25:17],NSParagraphStyleAttributeName: paragraphStyle };
//        
//        [date drawInRect:CGRectMake(IS_IPAD?targetX+5:targetX, IS_IPAD?targetY+39:targetY+10, kVRGCalendarViewDayWidth, kVRGCalendarViewDayHeight) withAttributes:attributes];
    }
    
    //    CGContextClosePath(context);
    
}

#pragma mark - Draw image for animation
-(UIImage *)drawCurrentState {
    float targetHeight = kVRGCalendarViewTopBarHeight + [self numRows]*(kVRGCalendarViewDayHeight+2)+1;
    
    UIGraphicsBeginImageContext(CGSizeMake(kVRGCalendarViewWidth, targetHeight-kVRGCalendarViewTopBarHeight));
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, -kVRGCalendarViewTopBarHeight);    // <-- shift everything up by 40px when drawing.
    [self.layer renderInContext:c];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

#pragma mark - Init
-(id)init {
    self = [super initWithFrame:CGRectMake(0, 0, kVRGCalendarViewWidth, 0)];
    if (self) {
        self.contentMode = UIViewContentModeTop;
        self.clipsToBounds=YES;
        
        isAnimating=NO;
        self.labelCurrentMonth = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, kVRGCalendarViewWidth-68,40)];
        [self addSubview:labelCurrentMonth];
        labelCurrentMonth.backgroundColor=[UIColor whiteColor];
        labelCurrentMonth.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:IS_IPAD?22:17];
        labelCurrentMonth.textColor = [UIColor colorWithHexString:@"0x383838"];
        labelCurrentMonth.textAlignment = NSTextAlignmentCenter;
        
//        if ([USER_DEFAULT objectForKey:@"currentMonth"] == nil) {
            [USER_DEFAULT setObject:[NSDate date] forKey:@"currentMonth"];
//        }
        self.currentMonth = [USER_DEFAULT objectForKey:@"currentMonth"];
        [self performSelector:@selector(reset) withObject:nil afterDelay:0.1]; //so delegate can be set after init and still get called on init
        //        [self reset];
        //init sql manager
        sqlManager = [[IMSSqliteManager alloc] init];
    }
    return self;
}

//-(void)dealloc {
//    
//    self.delegate=nil;
//    self.currentMonth=nil;
//    self.labelCurrentMonth=nil;
//    
//    self.markedDates=nil;
//    self.markedColors=nil;
//    
//    [super dealloc];
//}
@end

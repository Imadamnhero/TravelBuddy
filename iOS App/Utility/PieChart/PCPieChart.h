/**
 * Copyright (c) 2011 Muh Hon Cheng
 * Created by honcheng on 28/4/11.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2011	Muh Hon Cheng
 * @version
 * 
 */

#import <UIKit/UIKit.h>
#import "PCPieChart.h"

@interface PCPieComponent : NSObject
{
    float value, startDeg, endDeg;
    NSString *title;
    UIColor *colour;
    
}
@property (nonatomic, assign) float value, startDeg, endDeg;
@property (nonatomic, retain) UIColor *colour;
@property (nonatomic, retain) NSString *title;


- (id)initWithTitle:(NSString*)_title value:(float)_value;
+ (id)pieComponentWithTitle:(NSString*)_title value:(float)_value;
@end

#define PCColorBlue [UIColor colorWithRed:35/255.0 green:183/255.0 blue:255/255.0 alpha:1.0]
#define PCColorGreen [UIColor colorWithRed:46/255.0 green:255/255.0 blue:31/255.0 alpha:1.0]
#define PCColorOrange [UIColor colorWithRed:1.0 green:98/255.0 blue:36/255.0 alpha:1.0]
#define PCColorRed [UIColor colorWithRed:1.0 green:51/255.0 blue:51/255.0 alpha:1.0]
#define PCColorYellow [UIColor colorWithRed:1.0 green:220/255.0 blue:0.0 alpha:1.0]
#define PCColorDefault [UIColor colorWithRed:36/255.0 green:46/255.0 blue:1.0 alpha:1.0]
#define PCColorViolet [UIColor colorWithRed:212/255.0 green:61/255.0 blue:255/255.0 alpha:1.0]
#define PCColorLightBlue [UIColor colorWithRed:36/255.0 green:46/255.0 blue:1.0 alpha:1.0]

@interface PCPieChart : UIView {
    NSMutableArray *components;
    int diameter;
	UIFont *titleFont, *percentageFont;
	BOOL showArrow, sameColorLabel;
}
@property (nonatomic, assign) int diameter;
@property (nonatomic, retain) NSMutableArray *components;
@property (nonatomic, retain) UIFont *titleFont, *percentageFont;
@property (nonatomic, assign) BOOL showArrow, sameColorLabel;

@end

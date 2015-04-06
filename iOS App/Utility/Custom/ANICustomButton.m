//
//  ANICustomButton.m
//  Fun Spot App
//
//  Created by  Rawat on 05/02/13.
//
//

#import "ANICustomButton.h"

#import "ANICustomButton.h"
#import <QuartzCore/QuartzCore.h>

#define kUINavbarButtonCapWidth 7.0
#define kUINavbarButtonHeight 30.0
#define kGrayButtonHeight 22.0

@interface ANICustomButton ()

@end

@implementation ANICustomButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (id)initWithFrame:(CGRect)rect useWidth:(BOOL)useWidth title:(NSString *)title font:(UIFont*)fontType color:(UIColor*)color style:(UIBarStyle)style{
	
	UILabel *label = [[UILabel alloc] init];
    label.font = fontType ? fontType : [UIFont fontWithName:@"Arial-BoldMT" size:13.0];
    //    [label setShadowOffset:CGSizeMake(0.0, -1.0)];
    [label setText:title];
    [label sizeToFit];
    
    CGFloat width= useWidth ? label.bounds.size.width : rect.size.width;
    
	CGRect frame=CGRectMake(rect.origin.x, rect.origin.y, (width+ 2 * kUINavbarButtonCapWidth), rect.size.height);
    self = [self initWithFrame:frame];
    
    UIImage *backgroundImage = nil;
    
	if (style == SKYCustomStyleBlack)
	{
        backgroundImage = [[UIImage imageNamed:@"navbar_button_black.png"] stretchableImageWithLeftCapWidth:kUINavbarButtonCapWidth topCapHeight:0.0];
    }
    else if(style == SKYCustomStyleBlackTranslucent)
	{
		backgroundImage = [[UIImage imageNamed:@"navbar_button_gray.png"] stretchableImageWithLeftCapWidth:kUINavbarButtonCapWidth topCapHeight:0.0];
	}
	else if(style == SKYCustomStyleGray)
	{
        backgroundImage = [[UIImage imageNamed:@"gray_gradient.png"] stretchableImageWithLeftCapWidth:kUINavbarButtonCapWidth topCapHeight:0.0];
    }
    else
	{
        backgroundImage = [[UIImage imageNamed:@"navbar_button_blue.png"] stretchableImageWithLeftCapWidth:kUINavbarButtonCapWidth topCapHeight:0.0];
    }
    
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    //    [self setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
    
	[self.titleLabel setFont:fontType];
	self.titleLabel.frame = frame;
	[self setTitle:title forState:UIControlStateNormal];
    
	if(color)
		[self setTitleColor:color forState:UIControlStateNormal];
	else
		[self setTitleColor:[UIColor colorWithRed:0.294 green:0.322 blue:0.384 alpha:1.0] forState:UIControlStateNormal];
    
    return self;
}

- (id)initWithFrame:(CGRect)rect image:(UIImage*)image color:(UIColor*)color
{
    self = [self initWithFrame:rect];
    
    [self setBackgroundColor:color];
    
    self.m_iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, rect.size.height-20, rect.size.height-20)];
    [self.m_iconImageView setImage:image];
    [self addSubview:self.m_iconImageView];
    
    self.m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.size.height+10, 0, rect.size.width-rect.size.height, rect.size.height)];
    [self.m_titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.m_titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [self addSubview:self.m_titleLabel];

    return self;
}

@end


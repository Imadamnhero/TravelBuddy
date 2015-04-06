//
//  ANICustomButton.h
//  Fun Spot App
//
//  Created by  Rawat on 05/02/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    SKYCustomStyleDefault          = 0,
    SKYCustomStyleBlack ,
    SKYCustomStyleBlackTranslucent ,
    SKYCustomStyleGray
} SKYCustomStyle;

@interface ANICustomButton : UIButton

@property (nonatomic,strong)id data;
@property (strong, nonatomic) UIImageView *m_iconImageView;
@property (strong, nonatomic) UILabel *m_titleLabel;

- (id)initWithFrame:(CGRect)rect useWidth:(BOOL)useWidth title:(NSString *)title font:(UIFont*)fontType color:(UIColor*)color style:(UIBarStyle)style;
- (id)initWithFrame:(CGRect)rect image:(UIImage*)image color:(UIColor*)color;

@end


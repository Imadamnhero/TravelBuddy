//
//  InfiniTabBar.m
//  Created by http://github.com/iosdeveloper
//

#import "InfiniTabBar.h"
#import "AppDelegate.h"
#import "UIColor-Expanded.h"


#define SCROLLVIEW_HEIGHT 49
#define SCROLLVIEW_WIDTH 320

@interface InfiniTabBar ()
@property (nonatomic,strong) NSArray *tabbarItemsArray;
@end

@implementation InfiniTabBar

@synthesize infiniTabBarDelegate;
@synthesize tabBars;
@synthesize aTabBar;
@synthesize bTabBar;

- (id)initWithItems:(NSArray *)items {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    UIColor *colornav = [UIColor colorWithHexString:(appDelegate.funSpotDict)[@"color_nav"]];
    if(!colornav) colornav = COLOR_NAV;

    self.tabbarItemsArray = items;
    CGSize screenSize = appDelegate.window.frame.size;
    
	self = [super initWithFrame:CGRectMake(0.0, (screenSize.height-SCROLLVIEW_HEIGHT), SCROLLVIEW_WIDTH, SCROLLVIEW_HEIGHT)];
	// TODO:
	//self = [super initWithFrame:CGRectMake(self.superview.frame.origin.x + self.superview.frame.size.width - 320.0, self.superview.frame.origin.y + self.superview.frame.size.height - 49.0, 320.0, 49.0)];
	// Doesn't work. self is nil at this point.
	
    if (self) {
		self.pagingEnabled = YES;
		self.delegate = self;
		
		self.tabBars = [[NSMutableArray alloc] init];
		
		float x = 0.0;
		
		for (double d = 0; d < ceil(items.count / 4.0); d ++) {
			UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(x, 0.0, 320.0, 49.0)];
			tabBar.delegate = self;
			
			int len = 0;
			
			for (int i = d * 4; i < d * 4 + 4; i ++)
				if (i < items.count)
					len ++;
			
			tabBar.items = [items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(d * 4, len)]];
            if(!colornav) colornav = COLOR_NAV;
            tabBar.tintColor =  colornav;

			[self addSubview:tabBar];
			
			[self.tabBars addObject:tabBar];
			
			
			x += 320.0;
		}
		
		self.contentSize = CGSizeMake(x, 49.0);
	}
	
    return self;
}

- (void)setBounces:(BOOL)bounces {
	if (bounces) {
		int count = self.tabBars.count;
		
		if (count > 0) {
			if (self.aTabBar == nil)
				self.aTabBar = [[UITabBar alloc] initWithFrame:CGRectMake(-320.0, 0.0, 320.0, 49.0)];
			
			[self addSubview:self.aTabBar];
			
			if (self.bTabBar == nil)
				self.bTabBar = [[UITabBar alloc] initWithFrame:CGRectMake(count * 320.0, 0.0, 320.0, 49.0)];
			
			[self addSubview:self.bTabBar];
		}
	} else {
		[self.aTabBar removeFromSuperview];
		[self.bTabBar removeFromSuperview];
	}
	
	[super setBounces:bounces];
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
	for (UITabBar *tabBar in self.tabBars) {
		int len = 0;
		
		for (int i = [self.tabBars indexOfObject:tabBar] * 4; i < [self.tabBars indexOfObject:tabBar] * 4 + 4; i ++)
			if (i < items.count)
				len ++;
		
		[tabBar setItems:[items objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange([self.tabBars indexOfObject:tabBar] * 4, len)]] animated:animated];
	}
	
	self.contentSize = CGSizeMake(ceil(items.count / 4.0) * 320.0, 49.0);
}

- (int)currentTabBarTag {
	return self.contentOffset.x / 320.0;
}

-(void)hideTab{
	for (UITabBar *tabBar in self.tabBars)
			 [tabBar setHidden:YES];
	
}

- (int)selectedItemTag {
	for (UITabBar *tabBar in self.tabBars)
		if (tabBar.selectedItem != nil)
			return tabBar.selectedItem.tag;
	
	// No item selected
	return 0;
}

- (BOOL)scrollToTabBarWithTag:(int)tag animated:(BOOL)animated {
	for (UITabBar *tabBar in self.tabBars)
		if ([self.tabBars indexOfObject:tabBar] == tag) {
			UITabBar *tabBar = (self.tabBars)[tag];
			
			[self scrollRectToVisible:tabBar.frame animated:animated];
			
			if (animated == NO)
				[self scrollViewDidEndDecelerating:self];
			
			return YES;
		}
		
	return NO;
}

- (BOOL)selectItemWithTag:(int)tag {
	for (UITabBar *tabBar in self.tabBars)
		for (UITabBarItem *item in tabBar.items){
			if (item.tag == tag) {
				tabBar.selectedItem = item;
				
				[self tabBar:tabBar didSelectItem:item];
				
				return YES;
			}
        }
	
	return NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[infiniTabBarDelegate infiniTabBar:self didScrollToTabBarWithTag:scrollView.contentOffset.x / 320.0];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[self scrollViewDidEndDecelerating:scrollView];
}

- (void)tabBar:(UITabBar *)cTabBar didSelectItem:(UITabBarItem *)item {
	// Act like a single tab bar
	for (UITabBar *tabBar in self.tabBars)
		if (tabBar != cTabBar)
			tabBar.selectedItem = nil;
	
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    UITabBarController *tabBarControlelr = (UITabBarController*)appDelegate.window.rootViewController;
    tabBarControlelr.selectedIndex = [self.tabbarItemsArray indexOfObject:item];
//	[infiniTabBarDelegate infiniTabBar:self didSelectItemWithTag:item.tag];
}


@end
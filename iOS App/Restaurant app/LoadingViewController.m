//
//  LoadingViewController.m
//  i-ZooConnect
//
//  Created by Aniket on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights res
//

#import "LoadingViewController.h"

#define TAG_SPLASHVIEW 100
#define TAG_LOADINGVIEW 101
#define TAG_LOADINGLABEL 102

@implementation LoadingViewController



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	delegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
	NSLog(@"popopopopopopopopopoppppppo");
	//Loading View
	CGRect frame = CGRectMake(30,230,72,35);
	UIImageView *loadingView = [[UIImageView alloc] initWithFrame:frame];
	loadingView.tag=TAG_LOADINGVIEW;
	loadingView.animationImages = [NSArray arrayWithObjects:
								   [UIImage imageNamed:@"loading_01.png"],
								   [UIImage imageNamed:@"loading_02.png"],
								   [UIImage imageNamed:@"loading_03.png"],
								   [UIImage imageNamed:@"loading_04.png"],
								   [UIImage imageNamed:@"loading_05.png"],
								   [UIImage imageNamed:@"loading_06.png"],
								   [UIImage imageNamed:@"loading_07.png"],
								   [UIImage imageNamed:@"loading_08.png"]
								  // [UIImage imageNamed:@"loading_09.png"],
								   //[UIImage imageNamed:@"loading_10.png"]
								   ,nil];
	loadingView.animationDuration = 5.0;
	loadingView.animationRepeatCount = 0;
	[loadingView startAnimating];
	
	UIImageView *_splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,480.0)];
	_splashView.tag=TAG_SPLASHVIEW;
	_splashView.image = [UIImage imageNamed:@"Default.png"];
	//[_splashView addSubview:loadingView];
	[loadingView release];
	
	UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,280,150,50)];
	loadingLabel.tag=TAG_LOADINGLABEL;
	BOOL flag=NO;
	if([self connectedToNetwork]){
		flag=YES;
		loadingLabel.text = @"Checking for updates...";
	}
	
	[loadingLabel setTextColor:[UIColor colorWithRed:0.72 green:0.50 blue:0.06 alpha:1.0]];
	[loadingLabel setBackgroundColor:[UIColor clearColor]];
	[loadingLabel setFont:[UIFont fontWithName:@"Arial" size:12.0]];
	[loadingLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
	
	[self.view addSubview:_splashView];
	sleep(2);
	[_splashView addSubview:loadingLabel];
	[loadingLabel release];
	[_splashView release];
	//[delegate getDBFileFromServer:flag];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


-(void)removeLoadingView
{
	UIImageView *tmpView=(UIImageView*)[[self.view viewWithTag:TAG_SPLASHVIEW] viewWithTag:TAG_LOADINGVIEW];
	[tmpView removeFromSuperview];
}

-(void)removeSplashView
{
	UIImageView *tmpView=(UIImageView*)[self.view viewWithTag:TAG_SPLASHVIEW];
	[tmpView removeFromSuperview];
}

-(void)changeText:(int)num
{
	UILabel *tmpLabel=(UILabel*)[[self.view viewWithTag:TAG_SPLASHVIEW] viewWithTag:TAG_LOADINGLABEL];
   
	switch (num) {
		case 0:
		{
			tmpLabel.text=@"Downloading updates...";
		}
			break;
		case 1:
		{
			tmpLabel.text=@"No Updates Found.";
		}
			break;
		default:
			break;
	}
}
@end

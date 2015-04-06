//
//  ReservationViewController.m
//  Restaurant app
//
//

#import "ReservationViewController.h"

#define kConfigPlistName @"config"
#define kEmailDefaultTo @"test@test.com"
#define kEmailDefaultSubject @"Reservation"

@implementation ReservationViewController
@synthesize descriptionLabel;
@synthesize peopleTextField;
@synthesize dateTextField;
@synthesize phoneTextField;
@synthesize sendReservationButton;
@synthesize callUsButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Reservation";
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm aa"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

//Configures the view by reading from designated plist and sets date picker as input method for dateTextField.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    [datePicker addTarget:self action:@selector(dateSelected:) forControlEvents:UIControlEventValueChanged];
    [dateTextField setInputView:datePicker];
    [datePicker release];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:kConfigPlistName ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    dictionary = [dictionary objectForKey:@"Root"];
    dictionary = [dictionary objectForKey:@"Reservation"];
    if (!phoneNumber) {
        phoneNumber = [[dictionary objectForKey:@"phoneNumber"] retain];
    }
    [descriptionLabel setText:[dictionary objectForKey:@"description"]];
    
    mailComposeViewController = [[MFMailComposeViewController alloc] init];
    [mailComposeViewController setMailComposeDelegate:self];
    [[mailComposeViewController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
}

- (void)viewDidUnload
{
    [mailComposeViewController setDelegate:nil];
    [mailComposeViewController release];
    mailComposeViewController = nil;
    [self setDescriptionLabel:nil];
    [self setPeopleTextField:nil];
    [self setDateTextField:nil];
    [self setPhoneTextField:nil];
    [self setSendReservationButton:nil];
    [self setCallUsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // custom navigation bar
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]) {        
        // iOS5
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"navigation-bar.png"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dateSelected:(UIDatePicker*)datePicker {
    [dateTextField setText:[dateFormatter stringFromDate:[datePicker date]]];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

#pragma mark - buttons methods

//Called when user taps on send button, checks for possible errors and presents prefilled mail interface.
- (IBAction)buttonPressed:(id)sender {
    if (sender == sendReservationButton) {
        if (![MFMailComposeViewController canSendMail]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't send" message:@"This device is unable to send emails." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        if ([[peopleTextField text] isEqualToString:@""] || [[dateTextField text] isEqualToString:@""] || [[phoneTextField text] isEqualToString:@""]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing input" message:@"Please fill out all fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        
        NSMutableString *text = [[NSMutableString alloc] init];
        
        [text appendFormat:@"People: %d\n", [[peopleTextField text] intValue]];
        [text appendFormat:@"Date: %@\n", [dateTextField text]];
        [text appendFormat:@"Phone: %@\n", [phoneTextField text]];
        
        [mailComposeViewController setToRecipients:[NSArray arrayWithObject:kEmailDefaultTo]];
        [mailComposeViewController setSubject:kEmailDefaultSubject];
        [mailComposeViewController setMessageBody:text isHTML:NO];
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
       // [self presentModalViewController:mailComposeViewController animated:YES];
        [text release];
    }
    else if (sender == callUsButton) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]]];
    }
}

#pragma mark - MFMailComposeViewController delegate methods

//Called when user is done with mail interface, presents informational alert based on sending mail result.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    UIAlertView *alert = nil;
    if (result == MFMailComposeResultSent) {
        alert = [[UIAlertView alloc] initWithTitle:@"Sent" message:@"Your email was sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    else if (result == MFMailComposeResultFailed) {
        alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"An error occured and your email was not sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    
    [alert show];
    [alert release];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

    //[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [phoneNumber release];
    [dateFormatter release];
    [mailComposeViewController release];
    [descriptionLabel release];
    [peopleTextField release];
    [dateTextField release];
    [phoneTextField release];
    [sendReservationButton release];
    [callUsButton release];
    [super dealloc];
}

@end

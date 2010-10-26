    //
//  mainViewController.m
//
//  Created by maliy on 7/15/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import "mainViewController.h"
#import "cRecorder.h"

@interface  mainViewController ()
@end



@implementation mainViewController

#pragma mark lifeCycle

- (id) init
{
	if (self = [super init])
	{
		recorder = [[cRecorder alloc] init];
		recorder.delegate = self;
		
		minLevel = 0.0;
	}
	return self;
}

- (void) dealloc
{
	[recorder release];
	
	[super dealloc];
}

#pragma mark -

- (void) recordBtnPress:(UIButton *) sender
{
	if (recorder.recording)
	{
		[recorder stop];
		pv.progress = .0;
		[sender setTitle:NSLocalizedString(@"Record", @"") forState:UIControlStateNormal];
	}
	else
	{
		[recorder start];
		[sender setTitle:NSLocalizedString(@"Stop", @"") forState:UIControlStateNormal];
	}

}

#pragma mark -

- (void) recorder:(cRecorder *) recorder levels:(NSArray *) lvls
{
	CGFloat level = [[lvls objectAtIndex:0] floatValue];
	if (level<minLevel)
	{
		minLevel = level;
		pv.progress = .0;
	}
	else
	{
		pv.progress = (minLevel-level)/minLevel;
	}

}


#pragma mark -

- (void) viewDidAppear:(BOOL) animated
{
}

- (void) viewDidDisappear:(BOOL) animated
{
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
{
	return YES;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	[super loadView];
	
	self.navigationItem.title = NSLocalizedString(@"audio recording", @"");
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	
	UIView *contentView = [[UIView alloc] initWithFrame:screenRect];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	contentView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
	
	self.view = contentView;
	[contentView release];

	CGRect rct = self.navigationController.navigationBar.bounds;
	rct.origin.y += 3.0;
	UIButton *_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	_btn.frame = rct;
	_btn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_btn setTitle:NSLocalizedString(@"Record", @"") forState:UIControlStateNormal];
	[_btn addTarget:self action:@selector(recordBtnPress:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_btn];
	
	rct.origin.y += rct.size.height + 6.0;
	rct.size.height /= 2.0;
	UIProgressView *_pv = [[UIProgressView alloc] initWithFrame:rct];
	_pv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_pv.progress = 0.0;
	pv = [_pv retain];
	[self.view addSubview:pv];
	[_pv release];
	
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	[pv release];
}



@end

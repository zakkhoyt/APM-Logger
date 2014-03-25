//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//


#import <QuartzCore/QuartzCore.h>
#import "VWWVideoViewController.h"
//#import "VWWSettingsTableViewController.h"

//static NSString *VWWSegueVideoToSettings = @"VWWSegueVideoToSettings";

//@interface VWWVideoViewController ()<VWWVideoProcessorDelegate, VWWSettingsTableViewControllerDelegate>
@interface VWWVideoViewController ()<VWWVideoProcessorDelegate>
//@property (nonatomic, strong) VWWSettingsTableViewController *settingsViewController;
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *recordButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

//static inline double radians (double degrees) { return degrees * (M_PI / 180); }

@implementation VWWVideoViewController

//@synthesize previewView;
//@synthesize recordButton;

- (void)updateLabels
{
	if (shouldShowStats) {
		NSString *frameRateString = [NSString stringWithFormat:@"%.2f FPS ", [videoProcessor videoFrameRate]];
 		frameRateLabel.text = frameRateString;
 		[frameRateLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
 		
 		NSString *dimensionsString = [NSString stringWithFormat:@"%d x %d ", [videoProcessor videoDimensions].width, [videoProcessor videoDimensions].height];
 		dimensionsLabel.text = dimensionsString;
 		[dimensionsLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
 		
 		CMVideoCodecType type = [videoProcessor videoType];
 		type = OSSwapHostToBigInt32( type );
 		NSString *typeString = [NSString stringWithFormat:@"%.4s ", (char*)&type];
 		typeLabel.text = typeString;
 		[typeLabel setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
 	}
 	else {
 		frameRateLabel.text = @"";
 		[frameRateLabel setBackgroundColor:[UIColor clearColor]];
 		
 		dimensionsLabel.text = @"";
 		[dimensionsLabel setBackgroundColor:[UIColor clearColor]];
 		
 		typeLabel.text = @"";
 		[typeLabel setBackgroundColor:[UIColor clearColor]];
 	}
}

- (UILabel *)labelWithText:(NSString *)text yPosition:(CGFloat)yPosition
{
	CGFloat labelWidth = 200.0;
	CGFloat labelHeight = 40.0;
	CGFloat xPosition = self.previewView.bounds.size.width - labelWidth - 10;
	CGRect labelFrame = CGRectMake(xPosition, yPosition, labelWidth, labelHeight);
	UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
	[label setFont:[UIFont systemFontOfSize:36]];
	[label setLineBreakMode:NSLineBreakByWordWrapping];
	[label setTextAlignment:NSTextAlignmentRight];
	[label setTextColor:[UIColor whiteColor]];
	[label setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
	[[label layer] setCornerRadius: 4];
	[label setText:text];
	
//	return [label autorelease];
    return label;
}

- (void)applicationDidBecomeActive:(NSNotification*)notifcation
{
	// For performance reasons, we manually pause/resume the session when saving a recording.
	// If we try to resume the session in the background it will fail. Resume the session here as well to ensure we will succeed.
	[videoProcessor resumeCaptureSession];
}

// UIDeviceOrientationDidChangeNotification selector
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	// Don't update the reference orientation when the device orientation is face up/down or unknown.
	if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) )
		[videoProcessor setReferenceOrientation:(AVCaptureVideoOrientation)orientation];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    // Initialize the class responsible for managing AV capture session and asset writer
    videoProcessor = [[VWWVideoProcessor alloc] init];
	videoProcessor.delegate = self;
    
	// Keep track of changes to the device orientation so we can update the video processor
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Setup and start the capture session
    [videoProcessor setupAndStartCaptureSession];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
	oglView = [[VWWVideoPreviewView alloc] initWithFrame:CGRectZero];
	// Our interface is always in portrait.
	oglView.transform = [videoProcessor transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)UIInterfaceOrientationPortrait];
    [self.previewView addSubview:oglView];
 	CGRect bounds = CGRectZero;
 	bounds.size = [self.previewView convertRect:self.previewView.bounds toView:oglView].size;
 	oglView.bounds = bounds;
    oglView.center = CGPointMake(self.previewView.bounds.size.width/2.0, self.previewView.bounds.size.height/2.0);
 	
 	// Set up labels
 	shouldShowStats = YES;
	
	frameRateLabel = [self labelWithText:@"" yPosition: (CGFloat) 10.0];
	[self.previewView addSubview:frameRateLabel];
	
	dimensionsLabel = [self labelWithText:@"" yPosition: (CGFloat) 54.0];
	[self.previewView addSubview:dimensionsLabel];
	
	typeLabel = [self labelWithText:@"" yPosition: (CGFloat) 98.0];
	[self.previewView addSubview:typeLabel];
}

- (void)cleanup
{
//	[oglView release];
	oglView = nil;
    
    frameRateLabel = nil;
    dimensionsLabel = nil;
    typeLabel = nil;
	
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    // Stop and tear down the capture session
	[videoProcessor stopAndTearDownCaptureSession];
	videoProcessor.delegate = nil;
//    [videoProcessor release];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
    
	[self cleanup];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
	[timer invalidate];
	timer = nil;
}

- (void)dealloc
{
	[self cleanup];
    
//	[super dealloc];
}

#pragma mark IBActions
- (IBAction)settingsButtonTouchUpInside:(id)sender {
//    
//    if(self.settingsViewController == nil){
//        self.settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VWWSettingsTableViewController"];
//        self.settingsViewController.delegate = self;
//        self.settingsViewController.view.hidden = YES;
//    }
//    
//    if(self.settingsViewController.view.hidden == YES){
//        [self showChildViewController:self.settingsViewController];
//    } else {
//        [self hideChildViewController:self.settingsViewController];
//    }
}


- (IBAction)toggleRecording:(id)sender
{
	// Wait for the recording to start/stop before re-enabling the record button.
	[[self recordButton] setEnabled:NO];
	
	if ( [videoProcessor isRecording] ) {
		// The recordingWill/DidStop delegate methods will fire asynchronously in response to this call
		[videoProcessor stopRecording];
	}
	else {
		// The recordingWill/DidStart delegate methods will fire asynchronously in response to this call
        [videoProcessor startRecording];
	}
}

#pragma mark RosyWriterVideoProcessorDelegate

- (void)recordingWillStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:NO];
		[[self recordButton] setTitle:@"Stop"];
        
		// Disable the idle timer while we are recording
		[UIApplication sharedApplication].idleTimerDisabled = YES;
        
		// Make sure we have time to finish saving the movie if the app is backgrounded during recording
		if ([[UIDevice currentDevice] isMultitaskingSupported])
			backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	});
}

- (void)recordingDidStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
	});
}

- (void)recordingWillStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Disable until saving to the camera roll is complete
		[[self recordButton] setTitle:@"Record"];
		[[self recordButton] setEnabled:NO];
		
		// Pause the capture session so that saving will be as fast as possible.
		// We resume the sesssion in recordingDidStop:
		[videoProcessor pauseCaptureSession];
	});
}

- (void)recordingDidStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self recordButton] setEnabled:YES];
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;
        
		[videoProcessor resumeCaptureSession];
        
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
	});
}

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
	// Don't make OpenGLES calls while in the background.
	if ( [UIApplication sharedApplication].applicationState != UIApplicationStateBackground )
		[oglView displayPixelBuffer:pixelBuffer];
}





-(void)showChildViewController:(UIViewController*)vc{
    
    
    // Set view
//    CGFloat w = 120;
//    CGFloat h = self.view.bounds.size.height;
//    CGFloat x = self.view.bounds.size.width - w;
//    CGFloat y = 0;
//    CGFloat w = self.view.bounds.size.width;
//    CGFloat h = (self.view.bounds.size.height - self.toolbar.bounds.size.height) / 2.0;
//    CGFloat x = 0;
//    CGFloat y = (self.view.bounds.size.height - self.toolbar.bounds.size.height) / 2.0;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = 120;
    CGFloat x = 0;
    CGFloat y = self.view.bounds.size.height - self.toolbar.bounds.size.height - 120.0;

    CGRect frameForView = CGRectMake(x, y, w, h);
    VWW_LOG_DEBUG(@"Child VC frame: %@", NSStringFromCGRect(frameForView));
    
    
    UIView *view = vc.view;
    view.frame = frameForView;
    view.alpha = 0.0;
    
    
    
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    vc.view.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideChildViewController:(UIViewController*)vc{
    
    if(vc == nil) return;
    if(vc.view.hidden == YES) return;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        vc.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        vc.view.hidden = YES;
        [vc removeFromParentViewController];
    }];
    
}

@end

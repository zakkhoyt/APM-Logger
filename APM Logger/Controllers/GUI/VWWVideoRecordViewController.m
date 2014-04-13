//
//  VWWVideoRecordViewController.m
//  APM Logger
//
//  Created by Zakk Hoyt on 4/12/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWVideoRecordViewController.h"
#import "VWWVideoPreviewView.h"
#import "VWWVideoProcessor.h"
#import <QuartzCore/QuartzCore.h>


@interface VWWVideoRecordViewController () <VWWVideoProcessorDelegate>{
    VWWVideoProcessor *videoProcessor;
    
    //	UIView *previewView;
    VWWVideoPreviewView *oglView;
    //    UIBarButtonItem *recordButton;
	UILabel *frameRateLabel;
	UILabel *dimensionsLabel;
	UILabel *typeLabel;
    
    NSTimer *timer;
    
	BOOL shouldShowStats;
	
	UIBackgroundTaskIdentifier backgroundRecordingID;
}
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *recordButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation VWWVideoRecordViewController



- (void)applicationDidBecomeActive:(NSNotification*)notifcation
{
	// For performance reasons, we manually pause/resume the session when saving a recording.
	// If we try to resume the session in the background it will fail. Resume the session here as well to ensure we will succeed.
	[videoProcessor resumeCaptureSession];
}

#pragma mark UIViewController

- (void)deviceOrientationDidChange {
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	// Don't update the reference orientation when the device orientation is face up/down or unknown.
	if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) )
		[videoProcessor setReferenceOrientation:(AVCaptureVideoOrientation)orientation];
}

- (void)viewDidLoad {
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



- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
	timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
}


- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
	[timer invalidate];
	timer = nil;
}


- (void)viewDidUnload
{
	[super viewDidUnload];
    
	[self cleanup];
}


//
//- (void)dealloc {
//	[self cleanup];
//}
//

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



#pragma mark IBActions


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

#pragma mark VWWVideoProcessorDelegate

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







@end

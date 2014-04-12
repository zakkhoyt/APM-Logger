//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//

#import <AVFoundation/AVFoundation.h>
#import "VWWVideoPreviewView.h"
#import "VWWVideoProcessor.h"

@interface VWWVideoOldViewController : UIViewController 
{
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


- (IBAction)toggleRecording:(id)sender;

@end

//
//  APM Logger
//
//  Created by Zakk Hoyt 2014
//  Copyright (c) 2014 Zakk Hoyt.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

static NSString *SMLocationControllerLocationKey = @"location";
static NSString *SMLocationControllerHeadingKey = @"heading";

@class VWWLocationController;

@protocol VWWLocationControllerDelegate <NSObject>
-(void)locationController:(VWWLocationController*)sender didUpdateLocations:(NSArray*)locations;
-(void)locationController:(VWWLocationController *)sender didUpdateHeading:(CLHeading*)heading;
@end



@interface VWWLocationController : NSObject
+(VWWLocationController*)sharedInstance;

-(void)start;
-(void)stop;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLHeading *heading;

@property (nonatomic, weak) id <VWWLocationControllerDelegate>delegate;

@end

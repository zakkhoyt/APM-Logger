//
//  VWWAudioController.h
//  RCTools
//
//  Created by Zakk Hoyt on 5/8/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>


@class VWWAudioController;

@protocol VWWAudioControllerDelegate <NSObject>
-(void)audioController:(VWWAudioController*)sender didCaptureAudioSample:(void*)buffer;
@end

@interface VWWAudioController : NSObject

-(void)start;
-(void)stop;
-(BOOL)isRunning;
@property (nonatomic, weak) id <VWWAudioControllerDelegate> delegate;

@end

//
//  VWWAudioController.m
//  RCTools
//
//  Created by Zakk Hoyt on 5/8/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWAudioController.h"
@import AVFoundation;
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@import CoreMedia;
// CoreAudio Public Utility
//#include "CAStreamBasicDescription.h"
//#include "CAComponentDescription.h"
//#include "CAAudioBufferList.h"
//#include "AUOutputBL.h"

@interface VWWAudioController ()  <AVAudioRecorderDelegate, AVAudioPlayerDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>{
    AVCaptureSession *captureSession;
    AVCaptureAudioDataOutput *output;
    AVCaptureDeviceInput *input;
}
@property (nonatomic, readwrite) BOOL running;
@end

@implementation VWWAudioController

#pragma mark Public methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupAVF];
    }
    return self;
}


-(void)start{
    if([captureSession isRunning] == NO){
        [captureSession startRunning];
    } else {
        VWW_LOG_ERROR(@"Cannot start AVFoundation for audio capture");
    }
}
-(void)stop{
    [captureSession stopRunning];
}

-(BOOL)isRunning{
    if(captureSession){
        return captureSession.isRunning;
    }
    return NO;
}

#pragma mark Private methods
-(void)setupAVF{
    NSError *error;
    
    // Sesssion
    captureSession = [[AVCaptureSession alloc]init];
    captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // Input Device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    NSLog(@"devices: %@", devices);
    if(devices.count == 0 ||
       devices == nil){
        VWW_LOG_CRITICAL(@"Could not acquire access to a microphone");
        return;
    }
    
    // Input
    AVCaptureDevice *device = devices[0];
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if([captureSession canAddInput:input] == NO){
        VWW_LOG_ERROR(@"Cannot attach input from device: %@", device);
    } else {
        [captureSession addInput:input];
    }
    
    // Output
    output = [[AVCaptureAudioDataOutput alloc]init];
    dispatch_queue_t queue = dispatch_queue_create("com.vaporwarewolf.audiocontroller", DISPATCH_QUEUE_SERIAL);
    [output setSampleBufferDelegate:self queue:queue];
    if([captureSession canAddOutput:output] == NO){
        VWW_LOG_ERROR(@"Cannot attach output to callback queue");
    } else {
        [captureSession addOutput:output];
    }

}

#pragma mark AVFoundationDelegate




- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    
//    VWW_LOG_TRACE;
// 
//    // Get samples.
//    CMBlockBufferRef audioBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
//    size_t lengthAtOffset;
//    size_t totalLength;
//    char *samples;
//    CMBlockBufferGetDataPointer(audioBuffer, 0, &lengthAtOffset, &totalLength, &samples);
//
//    // Get format.
//    CMAudioFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
//    const AudioStreamBasicDescription *description = CMAudioFormatDescriptionGetStreamBasicDescription(format);
////    AudioStreamBasicDescription *d = (AudioStreamBasicDescription*)description;
//    [self printASBD:*((AudioStreamBasicDescription*)description)];

    
    AudioBufferList audioBufferList;
    NSMutableData *data=[[NSMutableData alloc] init];
    CMBlockBufferRef blockBuffer;
    CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
    
    for( int y=0; y<audioBufferList.mNumberBuffers; y++ )
    {
        AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
        Byte *frame = (Byte*)audioBuffer.mData;
        [data appendBytes:frame length:audioBuffer.mDataByteSize];
//        VWW_LOG_DEBUG(@"average: %d", *frame);
    }
    
    
//    VWW_LOG_DEBUG(@"audio: %@", data);
    CFRelease(blockBuffer);
    blockBuffer=NULL;
    
//    [outputStream write:[data bytes]maxLength:[data length]];
//    VWW_LOG_DEBUG(@"average: %f", total);
    
}


- (void) printASBD: (AudioStreamBasicDescription) asbd {
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';

    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}
@end

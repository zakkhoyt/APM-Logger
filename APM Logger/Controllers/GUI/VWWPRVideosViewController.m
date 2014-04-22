//
//  VWWPRVideosViewController.m
//  RCTools
//
//  Created by Zakk Hoyt on 4/21/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//
// See apples' documentation here:
// this talks about using core anmiation to add watermarks
// https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/03_Editing.html#//apple_ref/doc/uid/TP40010188-CH8-SW1
#import "VWWPRVideosViewController.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@import  MobileCoreServices;
@interface VWWPRVideosViewController (){
    AVAssetReader *_movieReader;
    AVAssetWriter *_videoWriter;
}

@property(nonatomic, strong) AVAsset *videoAsset;
@property(nonatomic, strong) AVAsset *audioAsset;
@end


@implementation VWWPRVideosViewController



#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"VIDEO (Post Render)";
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTouchUpInside:)];
    [self.navigationItem setRightBarButtonItem:addButton animated:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//}


#pragma mark IBActions

-(void)addButtonTouchUpInside:(id)sender{
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

#pragma mark Private methods
- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate {
    // 1 - Validations
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    
    // 2 - Get image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    
    // 3 - Display image picker
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    // 1 - Get media type
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
//    
//    // 2 - Dismiss image picker
//    [self dismissViewControllerAnimated:YES completion:nil];
//    
//    
//    
//    // 3 - Handle video selection
//    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
//        self.videoAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
////        self.audioAsset = [self.videoAsset tracksWithMediaType:AVMediaTypeAudio][0];
//
////        //        MPMediaItem *songItem = [selectedSong objectAtIndex:0];
////        NSURL *audioURL = [info objectForKey:UIImagePickerControllerMediaURL];
////        self.audioAsset = [AVAsset assetWithURL:audioURL];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Asset Loaded"
//                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        [self videoOutput];
//    }
    
    
    
     NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:kUTTypeMovie]){
        [self readMovie:[info objectForKey:UIImagePickerControllerMediaURL]];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) readMovie:(NSURL *)url {
    AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVAssetTrack * videoTrack = nil;
            NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if ([tracks count] == 1) {
                videoTrack = [tracks objectAtIndex:0];
                NSError * error = nil;
                // _movieReader is a member variable
                _movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
                if (error){
                    NSLog(error.localizedDescription);
                }
                NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
                NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
                [_movieReader addOutput:[AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:videoSettings]];
                [_movieReader startReading];
                
                NSUInteger c = 0;
                while([self readNextMovieFrame]){
                    NSLog(@"Reading frame %ld", (long)c++);
                }
                //                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //                    [self readNextMovieFrame];
                //                });
                
                
                
            }
        });
    }];
}


- (BOOL) readNextMovieFrame {
    if (_movieReader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * output = [_movieReader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
        if (sampleBuffer) {
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            // Lock the image buffer
            CVPixelBufferLockBaseAddress(imageBuffer,0);
            // Get information of the image
            uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
            size_t width = CVPixelBufferGetWidth(imageBuffer);
            size_t height = CVPixelBufferGetHeight(imageBuffer);
            NSLog(@"width: %ld height: %ld", (long)width, (long)height);
            // // Here's where you can process the buffer!
            // (your code goes here) //
            // Finish processing the buffer!
            // // Unlock the image buffer
            CVPixelBufferUnlockBaseAddress(imageBuffer,0);
            CFRelease(sampleBuffer);
        }
        return YES;
    } else {
        NSLog(@"Status is no longer reading. Perhaps we are done?");
        return NO;
    }
    
    
    
}

/* TODO: UPdate this code to work with our reader
-(void)setup{
    
}
- (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path {
    
    //    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    //    documents = [documents stringByAppendingPathComponent:currentWorkspace];
    //
    //    //NSLog(path);
    //    NSString *filename = [documents stringByAppendingPathComponent:[array objectAtIndex:0]];
    //    UIImage *first = [UIImage imageWithContentsOfFile:[array objectAtIndex:0]];
    UIImage *first = array[0];
    
    
    CGSize frameSize = first.size;
    
    NSError *error = nil;
    _videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
    }
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    
    
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                       assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:videoSettings];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.height] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:attributes];
    
    [videoWriter addInput:writerInput];
    
    // fixes all errors
    writerInput.expectsMediaDataInRealTime = YES;
    
    //Start a session:
    BOOL start = [videoWriter startWriting];
    NSLog(@"Session started? %d", start);
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    buffer = [self pixelBufferFromCGImage:[first CGImage]];
    BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
    
    if (result == NO) //failes on 3GS, but works on iphone 4
        NSLog(@"failed to append buffer");
    
    if(buffer)
        CVBufferRelease(buffer);
    
    [NSThread sleepForTimeInterval:0.05];
    
    
    //    int reverseSort = NO;
    //    NSArray *newArray = [array sortedArrayUsingFunction:sort context:&reverseSort];
    
    //    delta = 1.0/[newArray count];
    
    //    int fps = (int)fpsSlider.value;
    int fps = 2;
    
    int i = 0;
    for (UIImage *imgFrame in array)
    {
        if (adaptor.assetWriterInput.readyForMoreMediaData)
        {
            
            i++;
            NSLog(@"inside for loop %d ",i);
            CMTime frameTime = CMTimeMake(1, fps);
            CMTime lastTime=CMTimeMake(i, fps);
            CMTime presentTime=CMTimeAdd(lastTime, frameTime);
            
            //            NSString *filePath = [documents stringByAppendingPathComponent:filename];
            //            NSString *filePath = filename;
            
            //            UIImage *imgFrame = [UIImage imageWithContentsOfFile:filePath] ;
            //            UIImage *imgFrame = [array]
            buffer = [self pixelBufferFromCGImage:[imgFrame CGImage]];
            BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
            
            if (result == NO) //failes on 3GS, but works on iphone 4
            {
                NSLog(@"failed to append buffer");
                NSLog(@"The error is %@", [videoWriter error]);
            }
            if(buffer)
                CVBufferRelease(buffer);
            [NSThread sleepForTimeInterval:0.05];
        }
        else
        {
            NSLog(@"error");
            i--;
        }
        [NSThread sleepForTimeInterval:0.02];
    }
    
    //Finish the session:
    [writerInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        
        
    }];
    
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
    
    
    
    
    NSURL *outputURL = [NSURL URLWithString:path];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            });
        }];
    }
    
}
*/

//- (void)videoOutput
//{
//    // 1 - Early exit if there's no video file selected
//    if (!self.videoAsset) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Load a Video Asset First"
//                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
//    
//    // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
//    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
//    
//    // 3 - Video track
//    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
//                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration)
//                        ofTrack:[[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
//                         atTime:kCMTimeZero error:nil];
//    
//    
//    // 3 - Audio track
//    if (self.audioAsset!=nil){
////        AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
////                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
//        AVMutableCompositionTrack *audioTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeAudio][0]mutableCopy];
//        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.audioAsset.duration)
//                            ofTrack:[[self.audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
//    }
//    
//    
//    
//    // 3.1 - Create AVMutableVideoCompositionInstruction
//
//    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
//    
//    
//    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
//    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
//    AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
//    BOOL isVideoAssetPortrait_  = NO;
//    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
//    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
//        videoAssetOrientation_ = UIImageOrientationRight;
//        isVideoAssetPortrait_ = YES;
//    }
//    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
//        videoAssetOrientation_ =  UIImageOrientationLeft;
//        isVideoAssetPortrait_ = YES;
//    }
//    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
//        videoAssetOrientation_ =  UIImageOrientationUp;
//    }
//    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
//        videoAssetOrientation_ = UIImageOrientationDown;
//    }
//    
//    
//    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
//    [videolayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
//    
//    // 3.3 - Add instructions
//    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
//    
//    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
//    
//    CGSize naturalSize;
//    if(isVideoAssetPortrait_){
//        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
//    } else {
//        naturalSize = videoAssetTrack.naturalSize;
//    }
//    
//    float renderWidth, renderHeight;
//    renderWidth = naturalSize.width;
//    renderHeight = naturalSize.height;
//    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
//    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
//    
////    NSMutableArray *instructions = [@[]mutableCopy];
////    CMTime t = CMTimeMake(0, <#int32_t timescale#>)
////    CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
////    for(NSInteger index = 0; index < 2; index++){
////        AVMutableVideoCompositionInstruction *instruction = [mainInstruction copy];
////        instruction.timeRange = CMTimeMake(<#int64_t value#>, <#int32_t timescale#>)
//        [self applyBorderToComposition:mainCompositionInst size:naturalSize];
//        [self applyTextToComposition:mainCompositionInst size:naturalSize];
//    
////    }
//    
//    
//    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
//    
//    
//    
//    // 4 - Get path
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
//                             [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000]];
//    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
//    
//    // 5 - Create exporter
//    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
//                                                                      presetName:AVAssetExportPresetHighestQuality];
//    exporter.outputURL=url;
//    exporter.outputFileType = AVFileTypeQuickTimeMovie;
//    exporter.shouldOptimizeForNetworkUse = YES;
//    exporter.videoComposition = mainCompositionInst;
//    [exporter exportAsynchronouslyWithCompletionHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self exportDidFinish:exporter];
//        });
//    }];
//}
//
//- (void)exportDidFinish:(AVAssetExportSession*)session {
//    if (session.status == AVAssetExportSessionStatusCompleted) {
//        NSURL *outputURL = session.outputURL;
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
//            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (error) {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
//                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                    } else {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
//                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//
//                    }
//                });
//            }];
//        }
//    }
//}
//
//
//- (void)applyBorderToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
//{
//    UIImage *borderImage = nil;
//    
////    if (_colorSegment.selectedSegmentIndex == 0) {
////        borderImage = [self imageWithColor:[UIColor blueColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
////    } else if(_colorSegment.selectedSegmentIndex == 1) {
//        borderImage = [self imageWithColor:[UIColor redColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
////    } else if(_colorSegment.selectedSegmentIndex == 2) {
////        borderImage = [self imageWithColor:[UIColor greenColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
////    } else if(_colorSegment.selectedSegmentIndex == 3) {
////        borderImage = [self imageWithColor:[UIColor whiteColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
////    }
//    
//    CALayer *backgroundLayer = [CALayer layer];
//    [backgroundLayer setContents:(id)[borderImage CGImage]];
//    backgroundLayer.frame = CGRectMake(0, 0, size.width, size.height);
//    [backgroundLayer setMasksToBounds:YES];
//    
//    
//    CALayer *videoLayer = [CALayer layer];
////    videoLayer.frame = CGRectMake(_widthBar.value, _widthBar.value,
////                                  size.width-(_widthBar.value*2), size.height-(_widthBar.value*2));
//    videoLayer.frame = CGRectMake(10, 10, size.width-(10*2), size.height-(10*2));
//
//    CALayer *parentLayer = [CALayer layer];
//    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
//    [parentLayer addSublayer:backgroundLayer];
//    [parentLayer addSublayer:videoLayer];
//    
//    composition.animationTool = [AVVideoCompositionCoreAnimationTool
//                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
//}
//
//- (UIImage *)imageWithColor:(UIColor *)color rectSize:(CGRect)imageSize {
//    CGRect rect = imageSize;
//    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
//    [color setFill];
//    UIRectFill(rect);   // Fill it with your color
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}
//
//
//- (void)applyTextToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
//{
//    // 1 - Set up the text layer
//    CATextLayer *subtitle1Text = [[CATextLayer alloc] init];
//    [subtitle1Text setFont:@"Helvetica-Bold"];
//    [subtitle1Text setFontSize:36];
//    [subtitle1Text setFrame:CGRectMake(0, 0, size.width, 100)];
//    [subtitle1Text setString:@"-122.23sdf52, 37.925235"];
//    [subtitle1Text setAlignmentMode:kCAAlignmentCenter];
//    [subtitle1Text setForegroundColor:[[UIColor whiteColor] CGColor]];
//    
//    // 2 - The usual overlay
//    CALayer *overlayLayer = [CALayer layer];
//    [overlayLayer addSublayer:subtitle1Text];
//    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
//    [overlayLayer setMasksToBounds:YES];
//    
//    CALayer *parentLayer = [CALayer layer];
//    CALayer *videoLayer = [CALayer layer];
//    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
//    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
//    [parentLayer addSublayer:videoLayer];
//    [parentLayer addSublayer:overlayLayer];
//    
//    composition.animationTool = [AVVideoCompositionCoreAnimationTool
//                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
//    
//}




@end

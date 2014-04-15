//
//  VWWAppDelegate.m
//  APM Logger
//
//  Created by Zakk Hoyt on 3/24/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWAppDelegate.h"
#import "AP2Data.h"
#import "VWWFileController.h"

@implementation VWWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
#if defined(DEBUG)
    VWW_LOG_INFO(@"App finished launching with dictionary: %@", launchOptions.description);
    VWW_LOG_INFO(@"URL for logs dir: %@", [VWWFileController urlForLogsDirectory]);
    VWW_LOG_INFO(@"URL for videos dir: %@", [VWWFileController urlForVideosDirectory]);

    // Copy a few log files in the logs directory so we have a few to work with
    [VWWFileController copyLogFileFromBundleToLogsDir];
#endif
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    VWW_LOG_DEBUG(@"App was launched from %@ with file at URL%@", sourceApplication, url);
    
    if([VWWFileController copyFileAtURLToLogsDir:url] == NO){
        VWW_LOG_ERROR(@"Failed to copy file to logs dir");
    } else {
        VWW_LOG_DEBUG(@"Copied log file to logs dir");
        VWW_LOG_TODO_TASK(@"Launch appropriate view controller. NSNotification");
    }
#if defined(DEBUG)
    [VWWFileController printURLsForLogs];
#endif
    
    return YES;
}

@end

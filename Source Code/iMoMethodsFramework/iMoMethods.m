//
//  iMoMethods.m
//  iMoMethodsFramework
//
//  Created by Mokhlas Hussein on 04/07/15.
//  Copyright (c) 2015 Mokhlas Hussein. All rights reserved.
//

#import "iMoMethods.h"
#import <sys/types.h>
#import <sys/stat.h>
#include <spawn.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "ProgressHUD.h"
#import "ARSpeechActivity.h"
#import "TTOpenInAppActivity.h"

NSBundle *mainFrameBundle(){
    return [NSBundle bundleForClass:[iMoMethods class]];
}
// PRIVATES
@interface UIDevice (Private)
- (id)_deviceInfoForKey:(NSString *)key;
@end

@interface UIImage (Private)
+ (UIImage *)imageNamed:(NSString *)named inBundle:(NSBundle *)bundle;
@end

@interface iMoMethods () <MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate> {
    MFMailComposeViewController *mailComposer;
}
@property (nonatomic, strong) UIWindow *mainWindow;
@end

@implementation iMoMethods
+ (iMoMethods *)sharedMethods {
    static dispatch_once_t once;
    static iMoMethods *sharedInstance;
    
    dispatch_once(&once, ^{ sharedInstance = [[self alloc] init];});
    
    return sharedInstance;
}
- (id)init {
    if ((self = [super init])) {
        // init some UI
        _mainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        //[[UIApplication sharedApplication] windows][0]; // u can change it as u want ;)
        _mainViewController = [[UIViewController alloc] init];
        [_mainViewController.view setFrame:[[UIScreen mainScreen] bounds]];
        [_mainViewController.view setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}
// show window
- (void)showWindow {
    [_mainWindow setWindowLevel:UIWindowLevelStatusBar + 500];
    [_mainWindow setRootViewController:_mainViewController];
    [_mainWindow setHidden:NO];
}
// hide window
- (void)hideWindow {
    [_mainWindow setRootViewController:nil];
    [_mainWindow setHidden:YES];
}

// Class Bundle
- (NSBundle *)mainClassBundle {
    return mainFrameBundle();
}
#pragma mark - Important Actions

// get your device UDID ( USES PRIVATE API )
- (NSString *)deviceUDIDValue {
    return [[UIDevice currentDevice] _deviceInfoForKey:@"UniqueDeviceID"];
}
// get your device sys name
- (NSString *)deviceSysName {
    return [UIDevice currentDevice].systemName;
}
// get your device sys version
- (NSString *)deviceSysVersion {
    return [UIDevice currentDevice].systemVersion;
}
// get your device hardware id
- (NSString *)deviceHardware {
    return [self hardwareDescription];
}
// share any file with other apps ( supports OpenIN )
- (void)shareFileAtPath:(NSString *)path {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing File....."];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *URL = [NSURL fileURLWithPath:path];
        TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:_mainViewController.view andRect:_mainViewController.view.frame];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[openInAppActivity]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            openInAppActivity.superViewController = activityViewController;
            [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                NSLog(@"[iMoMethods] completed: %@, \n%d, \n%@, \n%@,", activityType, completed, returnedItems, activityError);
                if (completed && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[iMoMethods sharedInstance] dismissMainWindow];
                }
                if (activityError && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[iMoMethods sharedInstance] dismissMainWindow];
                }
            }];
            // Show UIActivityViewController
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mainViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        } else {
            // Create pop up
            UIPopoverPresentationController *presentPOP = activityViewController.popoverPresentationController;
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(400,200,0,0);
            activityViewController.popoverPresentationController.sourceView = _mainViewController.view;
            presentPOP.permittedArrowDirections = UIPopoverArrowDirectionRight;
            presentPOP.delegate = self;
            presentPOP.sourceRect = CGRectMake(700,80,0,0);
            presentPOP.sourceView = _mainViewController.view;
            openInAppActivity.superViewController = presentPOP;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mainViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        }
        
    });
}
// share any text with other apps ( supports Speech )
- (void)shareText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing Text....."];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:@[[[ARSpeechActivity alloc] init]]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                NSLog(@"[iMoMethods] completed: %@, \n%d, \n%@, \n%@,", activityType, completed, returnedItems, activityError);
                if (completed && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[iMoMethods sharedInstance] dismissMainWindow];
                }
                if (activityError && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[iMoMethods sharedInstance] dismissMainWindow];
                }
            }];
            // Show UIActivityViewController
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mainViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        } else {
            // Create pop up
            UIPopoverPresentationController *presentPOP = activityViewController.popoverPresentationController;
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(400,200,0,0);
            activityViewController.popoverPresentationController.sourceView = _mainViewController.view;
            presentPOP.permittedArrowDirections = UIPopoverArrowDirectionRight;
            presentPOP.delegate = self;
            presentPOP.sourceRect = CGRectMake(700,80,0,0);
            presentPOP.sourceView = _mainViewController.view;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mainViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        }
        
    });
}
// share items array
- (void)shareItemsArray:(NSArray *)array {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing Sharing....."];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:array applicationActivities:@[[[ARSpeechActivity alloc] init]]];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                NSLog(@"[iMoMethods] completed: %@, \n%d, \n%@, \n%@,", activityType, completed, returnedItems, activityError);
                if (completed && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[iMoMethods sharedInstance] dismissMainWindow];
                }
                if (activityError && ![activityType isEqualToString:@"TTOpenInAppActivity"]) {
                    // [[iMoMethods sharedInstance] dismissMainWindow];
                }
            }];
            // Show UIActivityViewController
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mainViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        } else {
            // Create pop up
            UIPopoverPresentationController *presentPOP = activityViewController.popoverPresentationController;
            activityViewController.popoverPresentationController.sourceRect = CGRectMake(400,200,0,0);
            activityViewController.popoverPresentationController.sourceView = _mainViewController.view;
            presentPOP.permittedArrowDirections = UIPopoverArrowDirectionRight;
            presentPOP.delegate = self;
            presentPOP.sourceRect = CGRectMake(700,80,0,0);
            presentPOP.sourceView = _mainViewController.view;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_mainViewController presentViewController:activityViewController animated:YES completion:NULL];
                [ProgressHUD showSuccess:@"Finished....."];
            });
        }
        
    });
}
// get last taken image
- (void)getLastImageCompletion:(finishedWithImage)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Preparing Image....."];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        __block UIImage *latestPhoto;
        // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            // Within the group enumeration block, filter to enumerate just photos.
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            // Chooses the photo at the last index
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                
                // The end of the enumeration is signaled by asset == nil.
                if (alAsset) {
                    ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                    latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                    image(latestPhoto);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ProgressHUD showSuccess:@"Finished....."];
                    });
                    // lastTakenImage = latestPhoto;
                    // Stop the enumerations
                    *stop = YES; *innerStop = YES;
                    
                }
            }];
        } failureBlock: ^(NSError *error) {
            // Typically you should handle an error more gracefully than this.
            NSLog(@"**[ DevelopersLib_WAE] No groups");
        }];
    });
}
// send email to developer
- (void)sendEmailTo:(NSString *)emailAddress subject:(NSString *)subject text:(NSString *)text attachment:(NSData *)attachment mimeType:(NSString *)mimeType fileName:(NSString *)filename {
    if ([MFMailComposeViewController canSendMail]) {
        mailComposer = [[MFMailComposeViewController alloc]init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setToRecipients:[NSArray arrayWithObject:emailAddress]];
        [mailComposer setSubject:subject];
        [mailComposer setMessageBody:[NSString stringWithFormat:@"Don't delete any information here\n---------------------------------\n%@: %@\nDevice Type: %@\n%@\n\n[Write your message after]\n\n %@ \n\n[Write your message before]", [self deviceSysName], [self deviceSysVersion], [self deviceHardware], [self deviceUDIDValue], text] isHTML:NO];
        
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/cydia.log"] mimeType:@"text/plain" fileName:@"cydia.log"];
        
        const char *args[] = {"/usr/bin/dpkg", "-l", ">/tmp/dpkgl.log", NULL};
        pid_t pid;
        int stat;
        posix_spawn(&pid, args[0], NULL, NULL, (char **) args, NULL);
        waitpid(pid, &stat, 0);
        
//        system("/usr/bin/dpkg -l >/tmp/dpkgl.log"); OLD :P
        [mailComposer addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.log"];
        
        if (attachment != nil && [mimeType length] == 0 && [filename length] == 0) {
            return;
        } else if (attachment != nil && [mimeType length] > 1 && [filename length] > 1) {
            [mailComposer addAttachmentData:attachment mimeType:mimeType fileName:filename];
        }
        [_mainWindow setHidden:NO];
        if (_mainViewController.splitViewController.viewControllers.count > 0) {
            [_mainViewController.splitViewController.viewControllers[0] presentViewController:mailComposer animated:YES completion:nil];
        } else {
            [_mainViewController presentViewController:mailComposer animated:YES completion:nil];
        }
        
        //        [self.navigationController presentViewController:mailComposer animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Info"
                                  message:@"There is no Email Account Available in your device"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - mail compose delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed: {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send Email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MFMailComposeResultSent: {
            UIAlertView *sucessAlert = [[UIAlertView alloc] initWithTitle:@"Sucess" message:@"Mail Sent [Thanks]!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [sucessAlert show];
            break;
        }
        default:
            break;
    }
    [self hideWindow];
    
}

#pragma mark - Helper

- (NSString *)hardwareString {
    int name[] = {CTL_HW,HW_MACHINE};
    size_t size = 100;
    sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
    char *hw_machine = malloc(size);
    
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}
- (NSString*)hardwareDescription {
    NSString *hardware = [self hardwareString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([hardware isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([hardware isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([hardware isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([hardware isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (GSM Rev. A)";
    if ([hardware isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([hardware isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([hardware isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([hardware isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (Global)";
    if ([hardware isEqualToString:@"iPhone5,3"])    return @"iPhone 5C (GSM)";
    if ([hardware isEqualToString:@"iPhone5,4"])    return @"iPhone 5C (Global)";
    if ([hardware isEqualToString:@"iPhone6,1"])    return @"iPhone 5S (GSM)";
    if ([hardware isEqualToString:@"iPhone6,2"])    return @"iPhone 5S (Global)";
    
    if ([hardware isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([hardware isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([hardware isEqualToString:@"iPod1,1"])      return @"iPod Touch (1 Gen)";
    if ([hardware isEqualToString:@"iPod2,1"])      return @"iPod Touch (2 Gen)";
    if ([hardware isEqualToString:@"iPod3,1"])      return @"iPod Touch (3 Gen)";
    if ([hardware isEqualToString:@"iPod4,1"])      return @"iPod Touch (4 Gen)";
    if ([hardware isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([hardware isEqualToString:@"iPad1,1"])      return @"iPad (WiFi)";
    if ([hardware isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([hardware isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([hardware isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([hardware isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([hardware isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi Rev. A)";
    if ([hardware isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([hardware isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([hardware isEqualToString:@"iPad2,7"])      return @"iPad Mini (CDMA)";
    if ([hardware isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,2"])      return @"iPad 3 (CDMA)";
    if ([hardware isEqualToString:@"iPad3,3"])      return @"iPad 3 (Global)";
    if ([hardware isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([hardware isEqualToString:@"iPad3,5"])      return @"iPad 4 (CDMA)";
    if ([hardware isEqualToString:@"iPad3,6"])      return @"iPad 4 (Global)";
    if ([hardware isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([hardware isEqualToString:@"iPad4,2"])      return @"iPad Air (WiFi+GSM)";
    if ([hardware isEqualToString:@"iPad4,3"])      return @"iPad Air (WiFi+CDMA)";
    if ([hardware isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([hardware isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (WiFi+CDMA)";
    if ([hardware isEqualToString:@"iPad4,6"])      return @"iPad Mini Retina (Wi-Fi + Cellular CN)";
    if ([hardware isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (Wi-Fi)";
    if ([hardware isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Wi-Fi + Cellular)";
    if ([hardware isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (Wi-Fi)";
    if ([hardware isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Wi-Fi + Cellular)";
    if ([hardware isEqualToString:@"i386"])         return @"Simulator";
    if ([hardware isEqualToString:@"x86_64"])       return @"Simulator";
    
    NSLog(@"[iMoMethods] This is a device is not listed in this category");
    NSLog(@"[iMoMethods] Your device hardware string is: %@", hardware);
    if ([hardware hasPrefix:@"iPhone"]) return @"iPhone";
    if ([hardware hasPrefix:@"iPod"]) return @"iPod";
    if ([hardware hasPrefix:@"iPad"]) return @"iPad";
    return nil;
}
@end

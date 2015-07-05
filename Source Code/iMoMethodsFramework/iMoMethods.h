//
//  iMoMethods.h
//  iMoMethodsFramework
//
//  Created by Mokhlas Hussein on 04/07/15.
//  Copyright (c) 2015 Mokhlas Hussein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Blocks
typedef void(^finishedWithImage)(UIImage *image);

@interface iMoMethods : NSObject
// main view controller use it to present view controller after showin the main Window
@property (nonatomic, strong) UIViewController *mainViewController;
+ (iMoMethods *)sharedMethods;
// show window
- (void)showWindow;
// hide window
- (void)hideWindow;
// get your device UDID ( USES PRIVATE API )
- (NSString *)deviceUDIDValue;
// get your device sys name
- (NSString *)deviceSysName;
// get your device sys version
- (NSString *)deviceSysVersion;
// get your device hardware id
- (NSString *)deviceHardware;
// share any file with other apps ( supports OpenIN )
- (void)shareFileAtPath:(NSString *)path;
// share any text with other apps ( supports Speech )
- (void)shareText:(NSString *)text;
// share items array
- (void)shareItemsArray:(NSArray *)array;
// get last taken image
- (void)getLastImageCompletion:(finishedWithImage)image;
// send email to developer
- (void)sendEmailTo:(NSString *)emailAddress subject:(NSString *)subject text:(NSString *)text attachment:(NSData *)attachment mimeType:(NSString *)mimeType fileName:(NSString *)filename;
@end

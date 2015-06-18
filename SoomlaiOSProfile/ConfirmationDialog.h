//
// Created by Shubin Fedor on 18/05/15.
// Copyright (c) 2015 SOOMLA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ConfirmationDialog : NSObject<UIAlertViewDelegate>
@property(nonatomic, strong) UIAlertView *alert;

+ (ConfirmationDialog *)showWithTitle:(NSString *)title withMessage:(NSString *)message withResult:(void (^)(bool result))result;

- (id)initWithTitle:(NSString *)title withMessage:(NSString *)message withSuccess:(void (^)(bool result))result;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
@end
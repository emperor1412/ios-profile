//
// Created by Shubin Fedor on 18/05/15.
// Copyright (c) 2015 SOOMLA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfirmationDialog.h"


@interface ConfirmationDialog ()
@property(nonatomic, copy) void (^result)(bool result);
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@end

@implementation ConfirmationDialog {

    UIAlertView *_alert;
}

+ (ConfirmationDialog *)showWithTitle:(NSString *)title withMessage:(NSString *)message withResult:(void (^)(bool result))result {
    ConfirmationDialog *confirmationDialog = [[ConfirmationDialog alloc]
            initWithTitle:title
              withMessage:message
              withSuccess:result];

    if (confirmationDialog) {
        [confirmationDialog show];
    }
    return confirmationDialog;
}

- (id)initWithTitle:(NSString *)title withMessage:(NSString *)message withSuccess:(void (^)(bool result))result {
    ConfirmationDialog *res = [self init];
    if (res) {
        self.title = title;
        self.message = message;
        self.result = result;

        return self;
    } else {
        return nil;
    }
}

- (void)show {
    _alert = [[UIAlertView alloc] initWithTitle:self.title
                                                    message:self.message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Cancel", nil];
    [_alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    _result(buttonIndex == 0);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    _result(buttonIndex == 0);
}


@end
/*
 Copyright (C) 2012-2014 Soomla Inc.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ISocialProvider.h"

#import <FacebookSDK/FacebookSDK.h>

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedClassInspection"
/**
 This class creates a plugin for *ios-store* using Facebook as its social provider
 With this plugin, you can use our pre-cooked social actions (login, share status etc.)
 already integrated with Facebook, and tie them to rewards.  Use this plugin when you want
 to reward your users with coins (or any other virtual items) in exchange 
 for social actions they perform.
 */
@interface SoomlaFacebook : NSObject <ISocialProvider> {
    loginSuccess loginSuccess;
    loginFail loginFail;
    loginCancel loginCancel;
    logoutSuccess logoutSuccess;
}

@property (strong, nonatomic) loginSuccess loginSuccess;
@property (strong, nonatomic) loginFail loginFail;
@property (strong, nonatomic) loginCancel loginCancel;
@property (strong, nonatomic) logoutSuccess logoutSuccess;

// Make this method public to allow access from App Delegate

/**
 A handler method which is called every time the Facebook session state is changed.
 The Facebook SDK uses a session state machine to control the session lifecycle. 
 These states are used by the Facebook SDK to allow or deny access to the other Facebook APIs, 
 handle access token storage or retrieval, and deal with any error scenarios.
 
 @param session The current Facebook session object
 @param state The state to which the session just changed
 @param error An error if such occurred
 */
- (void)sessionStateChanged:(__unused FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end

#pragma clang diagnostic pop
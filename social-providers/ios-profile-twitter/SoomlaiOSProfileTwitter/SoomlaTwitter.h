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

#import "STTwitterAPI.h"

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedClassInspection"
/**
 This class creates a plugin for *ios-profile* using Twitter as its social provider
 With this plugin, you can use our pre-cooked social actions (login, share status etc.)
 already integrated with Twitter, and tie them to rewards.  Use this plugin when you want
 to reward your users with coins (or any other virtual items) in exchange 
 for social actions they perform.
 */
@interface SoomlaTwitter : NSObject <ISocialProvider> {
    loginSuccess loginSuccess;
    loginFail loginFail;
    loginCancel loginCancel;
    
    @private
    BOOL webOnly;
    
    @private
    BOOL webAvailable;
    
    @private
    NSString *loggedInUser;
}

@property (strong, nonatomic, readonly) NSString *consumerKey;
@property (strong, nonatomic, readonly) NSString *consumerSecret;

@property (strong, nonatomic) loginSuccess loginSuccess;
@property (strong, nonatomic) loginFail loginFail;
@property (strong, nonatomic) loginCancel loginCancel;
@property (strong, nonatomic) logoutSuccess logoutSuccess;

@property (strong, nonatomic, readonly) NSString *oauthToken;
@property (strong, nonatomic, readonly) NSString *oauthSecret;

@end

#pragma clang diagnostic pop
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

#import "SoomlaProfile.h"
#import "Reward.h"
#import "AuthController.h"
#import "SocialController.h"
#import "UserProfileUtils.h"

@implementation SoomlaProfile


- (id)init {
    if (self = [super init]) {
        authController = [[AuthController alloc] init];
        socialController = [[SocialController alloc] init];
    }
    
    return self;
}

- (void)loginWithProvider:(enum Provider)provider {
    [self loginWithProvider:provider andReward:nil];
}

- (void)loginWithProvider:(enum Provider)provider andReward:(Reward *)reward {
    @try {
        [authController loginWithProvider:provider andReward:reward];
    }
    @catch (NSException *exception) {

        // TODO: implement logic like in java that will raise the exception. Currently not raised
        [socialController loginWithProvider:provider andReward:reward];
    }
}

- (void)logoutWithProvider:(enum Provider)provider {
    @try {
        [authController logoutWithProvider:provider];
    }
    @catch (NSException *exception) {

        // TODO: implement logic like in java that will raise the exception. Currently not raised
        [socialController logoutWithProvider:provider];
    }
}

- (UserProfile *)getStoredUserProfileWithProvider:(enum Provider)provider {
    @try {
        [authController getStoredUserProfileWithProvider:provider];
    }
    @catch (NSException *exception) {
        
        // TODO: implement logic like in java that will raise the exception. Currently not raised
        [socialController getStoredUserProfileWithProvider:provider];
    }
}

- (void)updateStatusWithProvider:(enum Provider)provider andStatus:(NSString *)status andReward:(Reward *)reward {
    [socialController updateStatusWithProvider:provider andStatus:status andReward:reward];
}

- (void)updateStoryWithProvider:(enum Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                      andReward:(Reward *)reward {
    [socialController updateStoryWithProvider:provider andMessage:message andName:name andCaption:caption
                               andDescription:description andLink:link andPicture:picture andReward:reward];
}

//- (void)uploadImageWithProvider:(enum Provider)provider
//                     andMessage:(NSString *)message
//                    andFileName:(NSString *)fileName
//       andAndroidGraphicsBitmap:(AndroidGraphicsBitmap *)bitmap
//                 andJpegQuality:(int)jpegQuality
//                      andReward:(Reward *)reward {
//    [socialController uploadImageWithProvider:provider andMessage:message andFileName:fileName
//                                    andBitmap:bitmap andJpegQuality:jpegQuality andReward:reward];
//}

- (void)uploadImageWithProvider:(enum Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                      andReward:(Reward *)reward {
    [socialController uploadImageWithProvider:provider andMessage:message andFilePath:filePath andReward:reward];
}

- (void)getContactsWithProvider:(enum Provider)provider andReward:(Reward *)reward {
    [socialController getContactsWith:provider andReward:reward];
}

- (void)getFeedWithProvider:(enum Provider)provider andReward:(Reward *)reward {
    [socialController getFeed:provider andReward:reward];
}



// private

+ (SoomlaProfile*)getInstance {
    static SoomlaProfile* _instance = nil;
    
    @synchronized( self ) {
        if( _instance == nil ) {
            _instance = [[SoomlaProfile alloc ] init];
        }
    }
    
    return _instance;
}

@end

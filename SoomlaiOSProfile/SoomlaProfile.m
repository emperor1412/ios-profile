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
#import "ProfileEventHandling.h"
#import "UserProfileNotFoundException.h"
#import "UserProfileStorage.h"

#import <UIKit/UIKit.h>

// if using Unity social provider this is YES
BOOL UsingExternalProvider;

@implementation SoomlaProfile

+ (void)usingExternalProvider:(BOOL)isExternal {
    
    UsingExternalProvider = isExternal;
}

+ (BOOL)isUsingExternalProvider {
    return UsingExternalProvider;
}

- (void)initialize {
    [self initialize:nil];
}

- (void)initialize:(NSDictionary *)customParams {
    if (UsingExternalProvider) {
        authController = [[AuthController alloc] initWithoutLoadingProviders];
        socialController = [[SocialController alloc] initWithoutLoadingProviders];
    }
    else {
        authController = [[AuthController alloc] initWithParameters:customParams];
        socialController = [[SocialController alloc] initWithParameters:customParams];
    }
    
    [ProfileEventHandling postProfileInitialized];
}

- (void)loginWithProvider:(Provider)provider {
    [self loginWithProvider:provider andPayload:@"" andReward:nil];
}

- (void)loginWithProvider:(Provider)provider andReward:(Reward *)reward {
    [self loginWithProvider:provider andPayload:@"" andReward:reward];
}

- (void)loginWithProvider:(Provider)provider andPayload:(NSString *)payload andReward:(Reward *)reward {
    @try {
        [authController loginWithProvider:provider andPayload:payload andReward:reward];
    }
    @catch (NSException *exception) {

        // TODO: implement logic like in java that will raise the exception. Currently not raised
        [socialController loginWithProvider:provider andPayload:payload andReward:reward];
    }
}

- (void)logoutWithProvider:(Provider)provider {
    @try {
        [authController logoutWithProvider:provider];
    }
    @catch (NSException *exception) {

        // TODO: implement logic like in java that will raise the exception. Currently not raised
        [socialController logoutWithProvider:provider];
    }
}

- (BOOL)isLoggedInWithProvider:(Provider)provider {
    @try {
        return [authController isLoggedInWithProvider:provider];
    }
    @catch (NSException *exception) {
        
        // TODO: implement logic like in java that will raise the exception. Currently not raised
        return [socialController isLoggedInWithProvider:provider];
    }

}

- (UserProfile *)getStoredUserProfileWithProvider:(Provider)provider {
    @try {
        return [authController getStoredUserProfileWithProvider:provider];
    }
    @catch (NSException *exception) {
        
        // TODO: implement logic like in java that will raise the exception. Currently not raised
        return [socialController getStoredUserProfileWithProvider:provider];
    }
}

- (NSArray *)getStoredUserProfiles {
    NSArray* providers = [UserProfileUtils availableProviders];
    NSMutableArray* userProfiles = [NSMutableArray array];
    for(NSNumber* providerNum in providers) {
        @try {
            UserProfile* userProfile = [UserProfileStorage getUserProfile:(Provider)[providerNum intValue]];
            if (userProfile) {
                [userProfiles addObject:userProfile];
            }
        }@catch (NSException *exception) {
            // Skip
        }
    }
    return userProfiles;
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward andConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage {
    [socialController updateStatusWithProvider:provider andStatus:status andPayload:payload andReward:reward andConfirmation:showConfirmation andCustomMessage:customMessage];
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward {
    [self updateStatusWithProvider:provider andStatus:status andPayload:payload andReward:reward andConfirmation:false andCustomMessage:nil];
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andReward:(Reward *)reward {
    [self updateStatusWithProvider:provider andStatus:status andPayload:@"" andReward:reward andConfirmation:false andCustomMessage:nil];
}

- (void)updateStatusWithProviderDialog:(Provider)provider andLink:(NSString *)link andPayload:(NSString *)payload andReward:(Reward *)reward {
    [socialController updateStatusWithProviderDialog:provider andLink:link andPayload:payload andReward:reward];
}

- (void)updateStatusWithProviderDialog:(Provider)provider andLink:(NSString *)link andReward:(Reward *)reward {
    [self updateStatusWithProviderDialog:provider andLink:link andPayload:@"" andReward:reward];
}

- (void)updateStoryWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward {

    [self updateStoryWithProvider:provider andMessage:message andName:name andCaption:caption andDescription:description andLink:link andPicture:picture andPayload:payload andReward:reward andShowConfirmation:false andCustomMessage:NULL];
}

- (void)updateStoryWithProvider:(Provider)provider andMessage:(NSString *)message andName:(NSString *)name andCaption:(NSString *)caption andDescription:(NSString *)description andLink:(NSString *)link andPicture:(NSString *)picture andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage {

    [socialController updateStoryWithProvider:provider
                                   andMessage:message
                                      andName:name
                                   andCaption:caption
                               andDescription:description
                                      andLink:link
                                   andPicture:picture
                                   andPayload:payload
                                    andReward:reward
                          andShowConfirmation:showConfirmation
                             andCustomMessage: customMessage];
}



- (void)updateStoryWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                        andName:(NSString *)name
                     andCaption:(NSString *)caption
                 andDescription:(NSString *)description
                        andLink:(NSString *)link
                     andPicture:(NSString *)picture
                      andReward:(Reward *)reward {
    [self updateStoryWithProvider:provider andMessage:message andName:name andCaption:caption
                   andDescription:description andLink:link andPicture:picture andPayload:@"" andReward:reward];
}

- (void)updateStoryWithProviderDialog:(Provider)provider
                                  andName:(NSString *)name
                               andCaption:(NSString *)caption
                           andDescription:(NSString *)description
                                  andLink:(NSString *)link
                               andPicture:(NSString *)picture
                           andPayload:(NSString *)payload
                                andReward:(Reward *)reward {
    [socialController updateStoryWithProviderDialog:provider andName:name andCaption:caption
                               andDescription:description andLink:link andPicture:picture andPayload:payload andReward:reward];
}

- (void)updateStoryWithProviderDialog:(Provider)provider
                              andName:(NSString *)name
                           andCaption:(NSString *)caption
                       andDescription:(NSString *)description
                              andLink:(NSString *)link
                           andPicture:(NSString *)picture
                            andReward:(Reward *)reward {
    [self updateStoryWithProviderDialog:provider andName:name andCaption:caption
                   andDescription:description andLink:link andPicture:picture andPayload:@"" andReward:reward];
}

- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward {

    [self uploadImageWithProvider:provider andMessage:message andFilePath:filePath andPayload:payload andReward:reward andConfirmation:false andCustomMessage:nil];
}

- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
               andImageFileName: (NSString *)fileName
                   andImageData:(NSData *)imageData
                     andPayload:(NSString *)payload
                      andReward:(Reward *)reward {

    [socialController uploadImageWithProvider:provider andMessage:message andImageFileName:fileName andImageData:imageData andPayload:payload andReward:reward andShowConfirmation: false];
}


- (void)uploadImageWithProvider:(Provider)provider andMessage:(NSString *)message andFilePath:(NSString *)filePath andPayload:(NSString *)payload andReward:(Reward *)reward andConfirmation:(BOOL)showConfirmation andCustomMessage:(NSString *)customMessage {

    [socialController uploadImageWithProvider:provider
                                   andMessage:message
                                  andFilePath:filePath
                                   andPayload:payload
                                    andReward:reward
                          andShowConfirmation:showConfirmation
                             andCustomMessage:customMessage];
}



- (void)uploadImageWithProvider:(Provider)provider
                     andMessage:(NSString *)message
                    andFilePath:(NSString *)filePath
                      andReward:(Reward *)reward {
    [self uploadImageWithProvider:provider andMessage:message andFilePath:filePath andPayload:@"" andReward:reward];
}

- (void)getContactsWithProvider:(Provider)provider andPayload:(NSString *)payload andReward:(Reward *)reward {
    [socialController getContactsWith:provider andFromStart:false andPayload:payload andReward:reward];
}

- (void)getContactsWithProvider:(Provider)provider andFromStart: (bool)fromStart andPayload:(NSString *)payload andReward:(Reward *)reward {
    [socialController getContactsWith:provider andFromStart:fromStart andPayload:payload andReward:reward];
}

- (void)getContactsWithProvider:(Provider)provider andReward:(Reward *)reward {
    [self getContactsWithProvider:provider andPayload:@"" andReward:reward];
}

- (void)getFeedWithProvider:(Provider)provider andFromStart:(bool)fromStart andPayload:(NSString *)payload andReward:(Reward *)reward {
    [socialController getFeedProvider:provider andFromStart:false andPayload:payload andReward:reward];
}

- (void)getFeedWithProvider:(Provider)provider andReward:(Reward *)reward {
    [self getFeedWithProvider:provider andFromStart:NO andPayload:@"" andReward:reward];
}

- (void)like:(Provider)provider andPageId:(NSString *)pageId andReward:(Reward *)reward {
    [socialController like:provider andPageId:pageId andReward:reward];
}

- (void)openAppRatingPage {
    NSString* templateReviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString* reviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:appID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
    
    [ProfileEventHandling postUserRating];
}

- (void)multiShareWithText:(NSString *)text andImageFilePath:(NSString *)imageFilePath {
    NSArray *postItems;
    if (imageFilePath && imageFilePath.length > 0) {
        UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
        postItems = @[text, image];
    } else {
        postItems = @[text];
    }

    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
            initWithActivityItems:postItems
            applicationActivities:nil];

    UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    if ( [rootViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityVC.popoverPresentationController.sourceView = rootViewController.view;
    }
    [rootViewController presentViewController:activityVC animated:YES completion:nil];
}

- (BOOL)tryHandleOpenURL:(Provider)provider openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [socialController tryHandleOpenURL:provider openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [socialController tryHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
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

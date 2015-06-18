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

#import <UIKit/UIKit.h>
#import "SocialController.h"
#import "ISocialProvider.h"
#import "ProfileEventHandling.h"
#import "SocialActionUtils.h"
#import "Reward.h"
#import "SoomlaUtils.h"
#import "ISocialProvider.h"
#import "ConfirmationDialog.h"

@interface SocialController ()
@property(nonatomic, strong) ConfirmationDialog *confirmationDialog;
@end

@implementation SocialController

static NSString* TAG = @"SOOMLA SocialController";


- (id)initWithParameters:(NSDictionary *)providerParams {
    if (self = [super initWithoutLoadingProviders]) {
        
        // TODO: Check if providerPkgPrefix can be omitted completely in iOS
        if (![self loadProvidersWithProtocol:@protocol(ISocialProvider) andProviderParams:providerParams]) {
            NSString* msg = @"You don't have a ISocialProvider service attached. \
            Decide which ISocialProvider you want, and add its static libraries \
            and headers to the target's search path.";
            LogDebug(TAG, msg);
        }
    }
    
    return self;
}

- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward andConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage {

    if (showConfirmation) {

        NSString *messageToShow = customMessage ? customMessage : [NSString
                stringWithFormat:@"Are you sure you want to publish this message to %@: \"%@\"?",
                        [UserProfileUtils providerEnumToString:provider],
                        status
        ];

        self.confirmationDialog = [ConfirmationDialog showWithTitle:@"Confirmation"
                                                        withMessage:messageToShow
                                                         withResult:^(bool result){
                                                             self.confirmationDialog = nil;
                                                             if (result) {
                                                                 [self internalUpdateStatusWithProvider:provider
                                                                                              andStatus:status
                                                                                             andPayload:payload
                                                                                              andReward:reward];
                                                             }
                                                         }];
    } else {
        [self internalUpdateStatusWithProvider:provider
                                     andStatus:status
                                    andPayload:payload
                                     andReward:reward];
    }
}

- (void)updateStatusWithProviderDialog:(Provider)provider andLink:(NSString *)link andPayload:(NSString *)payload andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    
    // Perform update status process with dialog
    [ProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STATUS withPayload:payload];
    [socialProvider updateStatusWithProviderDialog:link success:^{
        if (reward) {
            [reward give];
        }
        
        [ProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STATUS withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STATUS withMessage:message withPayload:payload];
    }];
}

- (void)updateStoryWithProvider:(Provider)provider andMessage:(NSString *)message andName:(NSString *)name andCaption:(NSString *)caption andDescription:(NSString *)description andLink:(NSString *)link andPicture:(NSString *)picture andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage {
    if (showConfirmation) {
        NSString *messageToShow = customMessage ? customMessage :
                [NSString stringWithFormat:@"Are you sure you want to publish to %@?",
                                [UserProfileUtils providerEnumToString:provider]];

        self.confirmationDialog = [ConfirmationDialog showWithTitle:@"Confirmation"
                                                        withMessage:messageToShow
                                                         withResult:^(bool result) {
                                                             self.confirmationDialog = nil;
                                                             if (result) {
                                                                 [self internalUpdateStoryWithProvider:provider
                                                                                            andMessage:message
                                                                                               andName:name
                                                                                            andCaption:caption
                                                                                        andDescription:description
                                                                                               andLink:link
                                                                                            andPicture:picture
                                                                                            andPayload:payload
                                                                                             andReward:reward];
                                                             }
                                                         }];
    } else {
        [self internalUpdateStoryWithProvider:provider
                                   andMessage:message
                                      andName:name
                                   andCaption:caption
                               andDescription:description
                                      andLink:link
                                   andPicture:picture
                                   andPayload:payload
                                    andReward:reward];
    }

}

- (void)updateStoryWithProviderDialog:(Provider)provider
                              andName:(NSString *)name
                           andCaption:(NSString *)caption
                       andDescription:(NSString *)description
                              andLink:(NSString *)link
                           andPicture:(NSString *)picture
                           andPayload:(NSString *)payload
                            andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform update story process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STORY withPayload:payload];
    [socialProvider updateStoryWithMessageDialog:name andCaption:caption
                            andDescription:description andLink:link andPicture:picture success:^{
                                if (reward) {
                                    [reward give];
                                }
                                
                                [ProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STORY withPayload:payload];
                            } fail:^(NSString *message) {
                                [ProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STORY withMessage:message withPayload:payload];
                            }];
}

- (void)uploadImageWithProvider:(Provider)provider andMessage:(NSString *)message andFilePath:(NSString *)filePath andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage {

    if (showConfirmation) {
        NSString *messageToShow = customMessage ? customMessage :
                [NSString stringWithFormat:@"Are you sure you want to upload image to %@?",
                                [UserProfileUtils providerEnumToString:provider]];

        self.confirmationDialog = [ConfirmationDialog showWithTitle:@"Confirmation"
                                                        withMessage:messageToShow
                                                         withResult:^(bool result) {
                                                             self.confirmationDialog = nil;
                                                             if (result) {
                                                                 [self internalUploadImageWithProvider:provider
                                                                                            andMessage:message
                                                                                      andFilePath:filePath
                                                                                            andPayload:payload
                                                                                             andReward:reward];
                                                             }
                                                         }];
    } else {
        [self internalUploadImageWithProvider:provider
                                   andMessage:message
                                  andFilePath:filePath
                                   andPayload:payload
                                    andReward:reward];
    }

}

- (void)uploadImageWithProvider:(Provider)provider andMessage:(NSString *)message andImageFileName:(NSString *)fileName andImageData:(NSData *)imageData andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation {

    if (showConfirmation) {
        self.confirmationDialog = [ConfirmationDialog showWithTitle:@"Confirmation"
                                                        withMessage:[NSString
                                                                stringWithFormat:@"Are you sure you want to upload image to %@?",
                                                                                 [UserProfileUtils providerEnumToString:provider]
                                                        ]
                                                         withResult:^(bool result) {
                                                             self.confirmationDialog = nil;
                                                             if (result) {
                                                                 [self internalUploadImageWithProvider:provider
                                                                                            andMessage:message
                                                                                      andImageFileName:fileName
                                                                                          andImageData:imageData
                                                                                            andPayload:payload
                                                                                             andReward:reward
                                                                                   andShowConfirmation:showConfirmation];
                                                             }
                                                         }];
    } else {
        [self internalUploadImageWithProvider:provider
                                   andMessage:message
                             andImageFileName:fileName
                                 andImageData:imageData
                                   andPayload:payload
                                    andReward:reward
                          andShowConfirmation:showConfirmation];
    }
}

- (void)getContactsWith:(Provider)provider andFromStart:(bool)fromStart andPayload:(NSString *)payload andReward:(Reward *)reward {
    
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    // Perform get contacts process
    [ProfileEventHandling postGetContactsStarted:provider withType:GET_CONTACTS withFromStart:fromStart withPayload:payload];
    [socialProvider getContacts: fromStart
                        success:^(NSArray *contacts, bool hasMore) {
        if (reward) {
            [reward give];
        }
                            [ProfileEventHandling postGetContactsFinished:provider
                                                                 withType:GET_CONTACTS
                                                             withContacts:contacts
                                                              withPayload:payload
                                                              withHasMore:hasMore];

    }                      fail:^(NSString *message) {
                [ProfileEventHandling postGetContactsFailed:provider
                                                   withType:GET_CONTACTS
                                                withMessage:message
                                              withFromStart:fromStart
                                                withPayload:payload];
    }];
}

- (void)getFeedProvider:(Provider)provider
           andFromStart:(bool)fromStart
             andPayload:(NSString *)payload
              andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];

    // Perform get feed process
    [ProfileEventHandling postGetFeedStarted:provider withType:GET_FEED withFromStart:fromStart withPayload:payload];

    [socialProvider getFeed: fromStart
                    success:^(NSArray *feeds, bool hasMore) {
        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postGetFeedFinished:provider withType:GET_FEED withContacts:feeds withPayload:payload withHasMore:hasMore];
    }
                       fail:^(NSString *message) {
        [ProfileEventHandling postGetFeedFailed:provider withType:GET_FEED withMessage:message withFromStart:fromStart withPayload:payload];
    }];
}

- (void)like:(Provider)provider andPageId:(NSString *)pageId andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];
    
    [socialProvider like:pageId];
    if (reward) {
        [reward give];
    }
}

- (void)internalUpdateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];

    // Perform update status process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STATUS withPayload:payload];
    [socialProvider updateStatus:status success:^{
        if (reward) {
            [reward give];
        }

        [ProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STATUS withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STATUS withMessage:message withPayload:payload];
    }];
}

- (void)internalUpdateStoryWithProvider:(Provider)provider andMessage:(NSString *)message andName:(NSString *)name andCaption:(NSString *)caption andDescription:(NSString *)description andLink:(NSString *)link andPicture:(NSString *)picture andPayload:(NSString *)payload andReward:(Reward *)reward {
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];

    // Perform update story process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPDATE_STORY withPayload:payload];
    [socialProvider updateStoryWithMessage:message andName:name andCaption:caption
                            andDescription:description andLink:link andPicture:picture success:^{
                if (reward) {
                    [reward give];
                }

                [ProfileEventHandling postSocialActionFinished:provider withType:UPDATE_STORY withPayload:payload];
            } fail:^(NSString *message) {
                [ProfileEventHandling postSocialActionFailed:provider withType:UPDATE_STORY withMessage:message withPayload:payload];
            }];
}

- (void)internalUploadImageWithProvider:(Provider)provider andMessage:(NSString *)message andImageFileName:(NSString *)fileName andImageData:(NSData *)imageData andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation {
    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];

    // Perform upload image process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPLOAD_IMAGE withPayload:payload];
    [socialProvider uploadImageWithMessage:message andImageFileName:fileName andImageData:imageData success:^{
        [ProfileEventHandling postSocialActionFinished:provider withType:UPLOAD_IMAGE withPayload:payload];
        if (reward) {
            [reward give];
        }
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPLOAD_IMAGE withMessage:message withPayload:payload];
    }];
}

- (void)internalUploadImageWithProvider:(Provider)provider andMessage:(NSString *)message andFilePath:(NSString *)filePath andPayload:(NSString *)payload andReward:(Reward *)reward {

    id<ISocialProvider> socialProvider = (id<ISocialProvider>)[self getProvider:provider];

    // Perform upload image process
    [ProfileEventHandling postSocialActionStarted:provider withType:UPLOAD_IMAGE withPayload:payload];
    [socialProvider uploadImageWithMessage:message andFilePath:filePath success:^{

        if (reward) {
            [reward give];
        }
        [ProfileEventHandling postSocialActionFinished:provider withType:UPLOAD_IMAGE withPayload:payload];
    } fail:^(NSString *message) {
        [ProfileEventHandling postSocialActionFailed:provider withType:UPLOAD_IMAGE withMessage:message withPayload:payload];
    }];
}

@end

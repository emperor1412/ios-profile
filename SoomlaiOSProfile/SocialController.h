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

#import "AuthController.h"
#import "UserProfileUtils.h"

@class Reward;

/**
 A class that loads all social providers and performs social
 actions on with them.  This class wraps the provider's social
 actions in order to connect them to user profile data and rewards.
 
 Inheritance: SocialController > AuthController > ProviderLoader
 */
@interface SocialController : AuthController

/**
 Constructor
 
 Loads all social providers
 @param providerParams Special initialization parameters for loaded providers
 */
- (id)initWithParameters:(NSDictionary *)providerParams;

/**
 Shares the given status to the user's feed
 
 @param provider the provider to use
 @param status the text to share
 @param payload a String to receive when the function returns.
 @param reward the reward to grant for sharing
 @param showConfirmation If true, shows confirmation dialog before the action
 @param customMessage the message to show in the dialog
 @exception ProviderNotFoundException if the provider is not supported
 */
- (void)updateStatusWithProvider:(Provider)provider andStatus:(NSString *)status andPayload:(NSString *)payload andReward:(Reward *)reward andConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage;

/**
 Shares the given status and link to the user's feed using the provider's
 native dialog (when available)
 
 @param provider the provider to use
 @param link the link to share (could be nil when not needed)
 @param payload a String to receive when the function returns.
 @param reward the reward to grant for sharing
 @exception ProviderNotFoundException if the provider is not supported
 */
- (void)updateStatusWithProviderDialog:(Provider)provider andLink:(NSString *)link andPayload:(NSString *)payload andReward:(Reward *)reward;

/**
 Shares a story to the user's feed.  This is very oriented for Facebook.
 
 @param provider The provider to use
 @param message The main text which will appear in the story
 @param name The headline for the link which will be integrated in the
 story
 @param caption The sub-headline for the link which will be
 integrated in the story
 @param description The description for the link which will be
 integrated in the story
 @param link The link which will be integrated into the user's story
 @param picture a Link to a picture which will be featured in the link
 @param payload a String to receive when the function returns.
 @param reward The reward to give the user
 @param showConfirmation If true, shows confirmation dialog before the action
 @param customMessage the message to show in the dialog
 @exception ProviderNotFoundException if the provider is not supported
 */
- (void)updateStoryWithProvider:(Provider)provider andMessage:(NSString *)message andName:(NSString *)name andCaption:(NSString *)caption andDescription:(NSString *)description andLink:(NSString *)link andPicture:(NSString *)picture andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage;

/**
 Shares a story to the user's feed and grants the user a reward, using the 
 provider's native dialog (when available)
 
 @param provider The provider to use
 @param name The headline for the link which will be integrated in the
 story
 @param caption The sub-headline for the link which will be
 integrated in the story
 @param description The description for the link which will be
 integrated in the story
 @param link The link which will be integrated into the user's story
 @param picture a Link to a picture which will be featured in the link
 @param payload a String to receive when the function returns.
 @param reward The reward to give the user
 */
- (void)updateStoryWithProviderDialog:(Provider)provider
                              andName:(NSString *)name
                           andCaption:(NSString *)caption
                       andDescription:(NSString *)description
                              andLink:(NSString *)link
                           andPicture:(NSString *)picture
                           andPayload:(NSString *)payload
                            andReward:(Reward *)reward;

/**
 Shares a photo to the user's feed.  This is very oriented for Facebook.
 
 @param provider The provider to use
 @param message A text that will accompany the image
 @param filePath The desired image's location on the device (full path)
 @param payload a String to receive when the function returns.
 @param reward The reward to grant for sharing the photo
 @param showConfirmation If true, shows confirmation dialog before the action
 @param customMessage the message to show in the dialog
 @exception ProviderNotFoundException if the provider is not supported
 */
- (void)uploadImageWithProvider:(Provider)provider andMessage:(NSString *)message andFilePath:(NSString *)filePath andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation andCustomMessage:(NSString *)customMessage;

/**
 Shares a photo to the user's feed.  This is very oriented for Facebook.

 @param provider The provider to use
 @param message A text that will accompany the image
 @param fileName The desired image's name
 @param imageData The desired image's data
 @param payload a String to receive when the function returns.
 @param reward The reward to grant for sharing the photo
 @param showConfirmation If true, shows confirmation dialog before the action
 @exception ProviderNotFoundException if the provider is not supported
 */
- (void)uploadImageWithProvider:(Provider)provider andMessage:(NSString *)message andImageFileName:(NSString *)fileName andImageData:(NSData *)imageData andPayload:(NSString *)payload andReward:(Reward *)reward andShowConfirmation:(bool)showConfirmation;

/**
 Fetches the user's contact list
 
 @param provider The provider to use
 @param payload a String to receive when the function returns.
 @param reward The reward to grant
 @exception ProviderNotFoundException if the provider is not supported
 */
- (void)getContactsWith:(Provider)provider andFromStart:(bool)fromStart andPayload:(NSString *)payload andReward:(Reward *)reward;

/**
 Fetches the user's feed.
 
 @param provider The provider to use
 @param payload a String to receive when the function returns.
 @param reward The reward to grant
 @exception ProviderNotFoundException if the provider is not supported
*/
- (void)getFeedProvider:(Provider)provider andFromStart:(bool)fromStart andPayload:(NSString *)payload andReward:(Reward *)reward;

/**
 Opens up a page to like for the user (external)
 
 @param provider The provider to like page on
 @param pageId The page to open on the provider
 @param reward The reward to grant when page is liked
 @exception ProviderNotFoundException if the provider is not supported
 */
- (void)like:(Provider)provider
            andPageId:(NSString *)pageId
            andReward:(Reward *)reward;

@end

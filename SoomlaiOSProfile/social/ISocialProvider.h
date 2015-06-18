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

#import "IAuthProvider.h"
#import "SocialCallbacks.h"

/**
 A provider that exposes social capabilities such as sharing, fetching user
 feeds, uploading images etc.
 */
@protocol ISocialProvider <IAuthProvider>

/**
 Shares the given status to the user's feed

 @param status the text to share
 @param success a status update success callback
 @param fail a status update failure callback
 */
- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail;

/**
 Shares the given status and link to the user's feed using the provider's
 native dialog (when available)

 @param link the link to share (could be nil when not needed)
 @param success a status update success callback
 @param fail a status update failure callback
 */
- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail;

/**
 Share a story to the user's feed.  This is very oriented for Facebook.

 @param message The main text which will appear in the story
 @param name The headline for the link which will be integrated in the
 story
 @param caption The sub-headline for the link which will be
 integrated in the story
 @param description The description for the link which will be
 integrated in the story
 @param link The link which will be integrated into the user's story
 @param picture a Link to a picture which will be featured in the link
 @param socialActionListener an update story failure callback
 */
- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail;

/**
 Share a story to the user's feed.  This is very oriented for Facebook.
 Using the provider's native dialog (when available)

 @param name The headline for the link which will be integrated in the
 story
 @param caption The sub-headline for the link which will be
 integrated in the story
 @param description The description for the link which will be
 integrated in the story
 @param link The link which will be integrated into the user's story
 @param picture a Link to a picture which will be featured in the link
 @param socialActionListener an update story failure callback
 */
- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail;

/**
 Fetches the user's contact list

 @param fromStart Should we reset pagination or request the next page
 @param success a contacts fetch success callback
 @param fail a contacts fetch failure callback
 */
- (void)getContacts:(bool)fromStart success:(contactsActionSuccess)success fail:(contactsActionFail)fail;

/**
 Fetches the user's feed

 @param success a contacts fetch success callback
 @param fail a contacts fetch failure callback
 */
- (void)getFeed:(bool)fromStart success:(feedsActionSuccess)success fail:(feedsActionFail)fail;

/**
 Shares a photo to the user's feed

 @param message A text that will accompany the image
 @param filePath The desired image's location on the device
 @param success an upload image success callback
 @param fail an upload image failure callback
 */
- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail;

/**
 Shares a photo to the user's feed using image data

 @param message A text that will accompany the image
 @param fileName The desired image's location on the device
 @param imageData The desierd image's data
 @param success an upload image success callback
 @param fail an upload image failure callback
 */
- (void)uploadImageWithMessage:(NSString *)message
              andImageFileName: (NSString *)fileName
                  andImageData: (NSData *)imageData
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail;

/**
 Opens up a page to like for the user (external)

 @param pageId The page to open on the provider
 @param reward The reward to grant when page is liked
 */
- (void)like:(NSString *)pageId;

@end

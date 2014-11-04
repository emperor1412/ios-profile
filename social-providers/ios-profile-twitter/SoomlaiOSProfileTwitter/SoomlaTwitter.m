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

#import "STTwitterOS.h"
#import "STTwitterOAuth.h"

#import "SoomlaTwitter.h"
#import "UserProfile.h"
#import "UserProfileStorage.h"

#import "SoomlaUtils.h"
#import "KeyValueStorage.h"

NSString *const TWITTER_OAUTH_TOKEN     = @"oauth.token";
NSString *const TWITTER_OAUTH_SECRET    = @"oauth.secret";

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedClassInspection"

// Private properties

@interface SoomlaTwitter ()

@property (strong, nonatomic) STTwitterAPI *twitter;

@end

@implementation SoomlaTwitter

@synthesize loginSuccess, loginFail, loginCancel,
            logoutSuccess;

static SoomlaTwitter *instance;

static NSString* DB_KEY_PREFIX  = @"soomla.profile.twitter.";
static NSString *TAG            = @"SOOMLA SoomlaTwitter";

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    _consumerKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SoomlaTwitterConsumerKey"];
    _consumerSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SoomlaTwitterConsumerSecret"];
    
    if ([self isEmptyString:self.consumerKey] || [self isEmptyString:self.consumerSecret]) {
        LogDebug(TAG, @"Either consumer key or consumer secret were not provided in plist, falling back to native only");
        webAvailable = NO;
    }
    else {
        webAvailable = YES;
    }
    
    @synchronized( self ) {
        if( instance == nil ) {
            instance = self;
        }
    }

    return self;
}

- (void)dealloc {
}

- (Provider)getProvider {
    return TWITTER;
}

- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {
    LogDebug(TAG, @"Login started...");
    
    if (webOnly) {
        [self loginWithWeb:success fail:fail cancel:cancel];
    }
    else {
        self.twitter = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            loggedInUser = username;
            success([self getProvider]);
        } errorBlock:^(NSError *error) {
            if (error.code == STTwitterOSUserDeniedAccessToTheirAccounts) {
                LogError(TAG, @"User denied access");
                fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
            }
            else {
                LogDebug(TAG, @"Unable to natively login to Twitter trying via web");
                [self loginWithWeb:success fail:fail cancel:cancel];
            }
        }];
    }
}

- (void)loginWithWeb:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {
    
    if (!webAvailable) {
        return;
    }
    
    if ([self tryLoginFromDB:success fail:fail cancel:cancel]) {
        return;
    }
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:self.consumerKey
                                                 consumerSecret:self.consumerSecret];
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        self.loginSuccess = success;
        self.loginFail = fail;
        self.loginCancel = cancel;
        [[UIApplication sharedApplication] openURL:url];
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(NO)
                    screenName:nil
                 oauthCallback:[NSString stringWithFormat:@"%@://twitter_access_tokens/", [self getURLScheme]]
                    errorBlock:^(NSError *error) {
                        LogError(TAG, @"Unable to login via web");
                        fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
                    }];
}

- (BOOL)tryLoginFromDB:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel {
    NSString *oauthToken = [KeyValueStorage getValueForKey:[self getTwitterStorageKey:TWITTER_OAUTH_TOKEN]];
    NSString *oauthSecret = [KeyValueStorage getValueForKey:[self getTwitterStorageKey:TWITTER_OAUTH_SECRET]];
    
    if ([self isEmptyString:oauthToken] || [self isEmptyString:oauthSecret]) {
        return NO;
    }
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:_consumerKey consumerSecret:_consumerSecret
                                                     oauthToken:oauthToken oauthTokenSecret:oauthSecret];
    
    [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
        loggedInUser = username;
        success([self getProvider]);
    } errorBlock:^(NSError *error) {
        // Something's wrong with my oauth tokens, retry login from web
        [self cleanTokensFromDB];
        [self loginWithWeb:success fail:fail cancel:cancel];
    }];
    
    return YES;
}

- (void) applyOauthTokens:(NSString *)token andVerifier:(NSString *)verifier {
    [self.twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        
        [KeyValueStorage setValue:oauthToken forKey:[self getTwitterStorageKey:TWITTER_OAUTH_TOKEN]];
        [KeyValueStorage setValue:oauthTokenSecret forKey:[self getTwitterStorageKey:TWITTER_OAUTH_SECRET]];
        
        loggedInUser = screenName;
        self.loginSuccess([self getProvider]);
        
        [self clearLoginBlocks];
    } errorBlock:^(NSError *error) {
        LogError(TAG, @"Unable to login via web");
        self.loginFail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
    }];
}

- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail {
    [self.twitter getUserInformationFor:loggedInUser successBlock:^(NSDictionary *user) {
        UserProfile *userProfile = [self parseUserProfile:user];
        success(userProfile);
    } errorBlock:^(NSError *error) {
        fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
    }];
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail {
    loggedInUser = nil;
    [self cleanTokensFromDB];
    self.twitter = nil;
    
    success();
}

- (BOOL)isLoggedIn {
    return ![self isEmptyString:loggedInUser] && self.twitter;
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail {
    if (![self testLoggedIn:fail]) {
        return;
    }
    
    LogDebug(TAG, @"Updating status");
    [self.twitter postStatusUpdate:status inReplyToStatusID:nil latitude:nil longitude:nil placeID:nil displayCoordinates:nil trimUser:nil successBlock:^(NSDictionary *status) {
        LogDebug(TAG, @"Updating status success");
        success();
    } errorBlock:^(NSError *error) {
        fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
    }];
}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail {
    LogDebug(TAG, @"Dialogs are not available in Twitter");
    fail(@"Dialogs are not available in Twitter");
}

- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail {
    // These parameters cannot be added to the tweet.
    // Please use cards (https://dev.twitter.com/cards) and add these parameters
    // to the supplied link's HTML
    [self updateStatus:[NSString stringWithFormat:@"%@ %@", message, link] success:success fail:fail];
}

- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail {
    LogDebug(TAG, @"Dialogs are not available in Twitter");
    fail(@"Dialogs are not available in Twitter");
}

- (void)getContacts:(contactsActionSuccess)success fail:(contactsActionFail)fail {
    if (![self testLoggedIn:fail]) {
        return;
    }
    
    LogDebug(TAG, @"Getting contacts");
    
    [self.twitter getFriendsListForUserID:loggedInUser orScreenName:loggedInUser cursor:nil count:@"200" skipStatus:@(YES) includeUserEntities:@(YES)
                             successBlock:^(NSArray *users, NSString *previousCursor, NSString *nextCursor) {
                                 LogDebug(TAG, ([NSString stringWithFormat:@"Get contacts success: %@", users]));
                                 
                                 NSMutableArray *contacts = [NSMutableArray array];
                                 
                                 for (NSDictionary *userDict in users) {
                                     UserProfile *contact = [self parseUserProfile:userDict];
                                     [contacts addObject:contact];
                                 }
                                 
                                 success(contacts);
                                 
                             } errorBlock:^(NSError *error) {
                                 LogError(TAG, ([NSString stringWithFormat:@"Get contacts error: %@", error.localizedDescription]));
                                 
                                 fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
                             }];
}

- (void)getFeed:(feedsActionSuccess)success fail:(feedsActionFail)fail {
    if (![self testLoggedIn:fail]) {
        return;
    }
    
    LogDebug(TAG, @"Getting feed");
    
    [self.twitter getUserTimelineWithScreenName:loggedInUser count:200
                                   successBlock:^(NSArray *statuses) {
                                       LogDebug(TAG, ([NSString stringWithFormat:@"Get feed success: %@", statuses]));
                                       
                                       NSMutableArray *feeds = [NSMutableArray array];
                                       for (NSDictionary *statusDict in statuses) {
                                           NSString *str;
                                           str = statusDict[@"text"];
                                           if (str) {
                                               [feeds addObject:str];
                                           }
                                       }
                                       success(feeds);
                                       
                                   } errorBlock:^(NSError *error) {
                                       LogError(TAG, ([NSString stringWithFormat:@"Get feed error: %@", error]));
                                   }];
}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail {
    if (![self testLoggedIn:fail]) {
        return;
    }
    
    LogDebug(TAG, @"Uploading image");
    
    [self.twitter postMediaUpload:[NSURL fileURLWithPath:filePath]
              uploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
                  // nothing to do here
              } successBlock:^(NSDictionary *imageDictionary, NSString *mediaID, NSString *size) {
                  [self.twitter postStatusUpdate:message inReplyToStatusID:nil
                                        mediaIDs:[NSArray arrayWithObject:mediaID] latitude:nil longitude:nil placeID:nil displayCoordinates:@(NO) trimUser:nil
                                    successBlock:^(NSDictionary *status) {
                                        LogDebug(TAG, ([NSString stringWithFormat:@"Upload image (status) success: %@", status]));
                                        success();
                                    } errorBlock:^(NSError *error) {
                                        LogError(TAG, ([NSString stringWithFormat:@"Upload image (status) error: %@", error]));
                                        fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
                                    }];
              } errorBlock:^(NSError *error) {
                  LogError(TAG, ([NSString stringWithFormat:@"Upload image error: %@", error]));
                  fail([NSString stringWithFormat:@"%ld: %@", (long)error.code, error.localizedDescription]);
              }];
}

- (void)like:(NSString *)pageName {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"https://www.twitter.com/", pageName]];
    [[UIApplication sharedApplication] openURL:url];
}

- (NSString *) getURLScheme {
    return [[NSString stringWithFormat:@"tw%@", self.consumerKey] lowercaseString];
}

+ (SoomlaTwitter *) getInstance {
    return instance;
}

//
// Private Methods
//


/*
 Helper methods for clearing callback blocks
 */

- (void)clearLoginBlocks {
    self.loginSuccess = nil;
    self.loginFail = nil;
    self.loginCancel = nil;
}

- (void)cleanTokensFromDB {
    [KeyValueStorage deleteValueForKey:[self getTwitterStorageKey:TWITTER_OAUTH_TOKEN]];
    [KeyValueStorage deleteValueForKey:[self getTwitterStorageKey:TWITTER_OAUTH_SECRET]];
}

- (BOOL) isEmptyString:(NSString *)target {
    return !target || ([target length] == 0);
}

- (NSString *) getTwitterStorageKey:(NSString *)postfix {
    return [NSString stringWithFormat:@"%@%@", DB_KEY_PREFIX, postfix];
}

- (BOOL)testLoggedIn:(socialActionFail)fail {
    if (![self isLoggedIn]) {
        fail(@"User did not login to Twitter, did you forget to login?");
        return NO;
    }
    
    return YES;
}

- (UserProfile *)parseUserProfile:(NSDictionary *)user {
    NSString *fullName = user[@"name"];
    NSString *firstName = @"";
    NSString *lastName = @"";
    if (fullName) {
        NSArray *names = [fullName componentsSeparatedByString:@" "];
        if (names && ([names count] > 0)) {
            firstName = names[0];
            if ([names count] > 1) {
                lastName = names[1];
            }
        }
    }
    
    // According to: https://dev.twitter.com/rest/reference/get/users/show
    //
    // - Twitter does not supply email access: https://dev.twitter.com/faq#26
    UserProfile *userProfile = [[UserProfile alloc] initWithProvider:TWITTER
                                                        andProfileId:user[@"id_str"]
                                                         andUsername:user[@"screen_name"]
                                                            andEmail:@""
                                                        andFirstName:firstName
                                                         andLastName:lastName];
    
    // No gender information on Twitter:
    // https://twittercommunity.com/t/how-to-find-male-female-accounts-in-following-list/7367
    userProfile.gender = @"";
    
    // No birthday on Twitter:
    // https://twittercommunity.com/t/how-can-i-get-email-of-user-if-i-use-api/7019/16
    userProfile.birthday = @"";
    
    userProfile.language = user[@"lang"];
    userProfile.location = user[@"location"];
    userProfile.avatarLink = user[@"profile_image_url"];
    return userProfile;
}

@end

#pragma clang diagnostic pop
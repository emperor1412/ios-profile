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

#import "ProfileEventHandling.h"
#import "UserProfile.h"
#import "BadgeReward.h"


@implementation ProfileEventHandling

+ (void)observeAllEventsWithObserver:(id)observer withSelector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_PROFILE_INITIALIZED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_USER_RATING object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_USER_PROFILE_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGIN_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGIN_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGIN_CANCELLED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGIN_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGOUT_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGOUT_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_LOGOUT_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_SOCIAL_ACTION_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_SOCIAL_ACTION_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_SOCIAL_ACTION_CANCELLED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_SOCIAL_ACTION_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_CONTACTS_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_CONTACTS_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_CONTACTS_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_FEED_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_FEED_FINISHED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:EVENT_UP_GET_FEED_FAILED object:nil];
}

+ (void)postProfileInitialized {
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_PROFILE_INITIALIZED object:self userInfo:@{}];
}

+ (void)postUserRating {
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_USER_RATING object:self userInfo:@{}];
}

+ (void)postUserProfileUpdated:(UserProfile *)userProfile {
    NSDictionary *userInfo = @{DICT_ELEMENT_USER_PROFILE: userProfile};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_USER_PROFILE_UPDATED object:self userInfo:userInfo];
}

+ (void)postLoginStarted:(Provider)provider withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: [NSNumber numberWithInt:provider], DICT_ELEMENT_PAYLOAD: payload};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGIN_STARTED object:self userInfo:userInfo];
}

+ (void)postLoginFinished:(UserProfile *)userProfile withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{DICT_ELEMENT_USER_PROFILE: userProfile, DICT_ELEMENT_PAYLOAD: payload};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGIN_FINISHED object:self userInfo:userInfo];
}

+ (void)postLoginCancelled:(Provider)provider withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_PAYLOAD: payload};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGIN_CANCELLED object:self userInfo:userInfo];
}

+ (void)postLoginFailed:(Provider)provider withMessage:(NSString *)message withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_MESSAGE: message, DICT_ELEMENT_PAYLOAD: payload};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGIN_FAILED object:self userInfo:userInfo];
}

+ (void)postLogoutStarted:(Provider)provider {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGOUT_STARTED object:self userInfo:userInfo];
}

+ (void)postLogoutFinished:(Provider)provider {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider)};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGOUT_FINISHED object:self userInfo:userInfo];
}

+ (void)postLogoutFailed:(Provider)provider withMessage:(NSString *)message {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_MESSAGE: message};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_LOGOUT_FAILED object:self userInfo:userInfo];
}

+ (void)postSocialActionStarted:(Provider)provider withType:(SocialActionType)socialActionType withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType), DICT_ELEMENT_PAYLOAD: payload};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_SOCIAL_ACTION_STARTED object:self userInfo:userInfo];
}

+ (void)postSocialActionFinished:(Provider)provider withType:(SocialActionType)socialActionType withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType), DICT_ELEMENT_PAYLOAD: payload};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_SOCIAL_ACTION_FINISHED object:self userInfo:userInfo];
}

+ (void)postSocialActionCancelled:(Provider)provider withType:(SocialActionType)socialActionType withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider), DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType), DICT_ELEMENT_PAYLOAD: payload};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_SOCIAL_ACTION_CANCELLED object:self userInfo:userInfo];
}

+ (void)postSocialActionFailed:(Provider)provider withType:(SocialActionType)socialActionType withMessage:(NSString *)message withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{DICT_ELEMENT_PROVIDER: @(provider),
                               DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
                               DICT_ELEMENT_MESSAGE: message,
                               DICT_ELEMENT_PAYLOAD: payload};
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_SOCIAL_ACTION_FAILED object:self userInfo:userInfo];
}

+ (void)postGetContactsStarted:(Provider)provider withType:(SocialActionType)socialActionType withFromStart:(bool)fromStart withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{
            DICT_ELEMENT_PROVIDER: @(provider),
            DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
            DICT_ELEMENT_FROM_START: @(fromStart),
            DICT_ELEMENT_PAYLOAD: payload
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_CONTACTS_STARTED object:self userInfo:userInfo];
}

+ (void)postGetContactsFinished:(Provider)provider withType:(SocialActionType)socialActionType withContacts:(NSArray *)contacts withPayload:(NSString *)payload withHasMore:(bool)hasMore {
    NSDictionary *userInfo = @{
            DICT_ELEMENT_PROVIDER: @(provider),
            DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
            DICT_ELEMENT_CONTACTS: contacts,
            DICT_ELEMENT_PAYLOAD: payload,
            DICT_ELEMENT_HAS_MORE: @(hasMore)
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_CONTACTS_FINISHED object:self userInfo:userInfo];
}

+ (void)postGetContactsFailed:(Provider)provider withType:(SocialActionType)socialActionType withMessage:(NSString *)message withFromStart:(bool)fromStart withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{
            DICT_ELEMENT_PROVIDER: @(provider),
            DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
            DICT_ELEMENT_MESSAGE: message,
            DICT_ELEMENT_FROM_START: @(fromStart),
            DICT_ELEMENT_PAYLOAD: payload
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_CONTACTS_FAILED object:self userInfo:userInfo];
}

+ (void)postGetFeedStarted:(Provider)provider withType:(SocialActionType)socialActionType withFromStart:(bool)fromStart withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{
            DICT_ELEMENT_PROVIDER: @(provider),
            DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
            DICT_ELEMENT_FROM_START: @(fromStart),
            DICT_ELEMENT_PAYLOAD: payload
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_FEED_STARTED object:self userInfo:userInfo];
}

+ (void)postGetFeedFinished:(Provider)provider withType:(SocialActionType)socialActionType withContacts:(NSArray *)feeds withPayload:(NSString *)payload withHasMore:(bool)hasMore {
    NSDictionary *userInfo = @{
            DICT_ELEMENT_PROVIDER: @(provider),
            DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
            DICT_ELEMENT_FEEDS: feeds,
            DICT_ELEMENT_PAYLOAD: payload,
            DICT_ELEMENT_HAS_MORE: @(hasMore)
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_FEED_FINISHED object:self userInfo:userInfo];
}

+ (void)postGetFeedFailed:(Provider)provider withType:(SocialActionType)socialActionType withMessage:(NSString *)message withFromStart:(bool)fromStart withPayload:(NSString *)payload {
    NSDictionary *userInfo = @{
            DICT_ELEMENT_PROVIDER: @(provider),
            DICT_ELEMENT_SOCIAL_ACTION_TYPE: @(socialActionType),
            DICT_ELEMENT_MESSAGE: message,
            DICT_ELEMENT_FROM_START: @(fromStart),
            DICT_ELEMENT_PAYLOAD: payload
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_UP_GET_FEED_FAILED object:self userInfo:userInfo];
}

@end

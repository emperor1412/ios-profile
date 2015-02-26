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

#import "UserProfile.h"
#import "JSONConsts.h"
#import "SoomlaUtils.h"
#import "PJSONConsts.h"

@implementation UserProfile

@synthesize provider, profileId, email, username, firstName, lastName, avatarLink, location, gender, language, birthday, accessToken;


- (id)initWithProvider:(Provider)oProvider
          andProfileId:(NSString *)oProfileId
           andUsername:(NSString *)oUsername
              andEmail:(NSString *)oEmail
          andFirstName:(NSString *)oFirstName
           andLastName:(NSString *)oLastName {

    if (self = [super init]) {
        provider = oProvider;
        self.profileId = oProfileId;
        self.username = oUsername;
        self.email = oEmail;
        self.firstName = oFirstName;
        self.lastName = oLastName;
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        provider = [UserProfileUtils providerStringToEnum:[dict objectForKey:UP_PROVIDER]];
        self.profileId = [dict objectForKey:UP_PROFILEID];
        self.username = [dict objectForKey:UP_USERNAME];
        self.email = [dict objectForKey:UP_EMAIL];
        self.firstName = [dict objectForKey:UP_FIRSTNAME];
        self.lastName = [dict objectForKey:UP_LASTNAME];
        self.avatarLink = [dict objectForKey:UP_AVATAR];
        self.location = [dict objectForKey:UP_LOCATION];
        self.gender = [dict objectForKey:UP_GENDER];
        self.language = [dict objectForKey:UP_LANGUAGE];
        self.birthday = [dict objectForKey:UP_BIRTHDAY];
        self.accessToken = [dict objectForKey: UP_ACCESSTOKEN];
    }
    
    return self;
}

- (NSDictionary*)toDictionary {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            [SoomlaUtils getClassName:self], SOOM_CLASSNAME,
            [UserProfileUtils providerEnumToString:self.provider], UP_PROVIDER,
            (self.profileId ?: [NSNull null]), UP_PROFILEID,
            (self.username ?: [NSNull null]), UP_USERNAME,
            (self.email ?: [NSNull null]), UP_EMAIL,
            (self.firstName ?: [NSNull null]), UP_FIRSTNAME,
            (self.lastName ?: [NSNull null]), UP_LASTNAME,
            (self.avatarLink ?: [NSNull null]), UP_AVATAR,
            (self.location ?: [NSNull null]), UP_LOCATION,
            (self.gender ?: [NSNull null]), UP_GENDER,
            (self.language ?: [NSNull null]), UP_LANGUAGE,
            (self.birthday ?: [NSNull null]), UP_BIRTHDAY,
            (self.accessToken ?: [NSNull null]), UP_ACCESSTOKEN,
            nil];
}

- (NSString *)getFullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end

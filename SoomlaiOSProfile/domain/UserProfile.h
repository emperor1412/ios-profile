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

#import "UserProfileUtils.h"

/**
 A domain object that represents the user's profile attributes.
 */
@interface UserProfile : NSObject {
    
    @private
    
    Provider provider;
    NSString* profileId;
    NSString* username;
    NSString* email;
    NSString* firstName;
    NSString* lastName;
    NSString* avatarLink;
    NSString* location;
    NSString* gender;
    NSString* language;
    NSString* birthday;
    NSString* accessToken;
}

@property (readonly, nonatomic) Provider provider;
@property (strong, nonatomic) NSString* profileId;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* email;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* avatarLink;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSString* gender;
@property (strong, nonatomic) NSString* language;
@property (strong, nonatomic) NSString* birthday;
@property (strong, nonatomic) NSString* accessToken;

/**
 Constructor
 
 @param oProvider the provider which the user's data is associated to
 @param oProfileId the profile ID for the given provider
 @param oUsername the user's username as used with the given provider
 @param oEmail the user's email
 @param oFirstName the user's first name
 @param oLastName the user's last name
 */
- (id)initWithProvider:(Provider)oProvider
          andProfileId:(NSString *)oProfileId
           andUsername:(NSString *)oUsername
              andEmail:(NSString *)oEmail
          andFirstName:(NSString *)oFirstName
           andLastName:(NSString *)oLastName;

/**
 Constructor
 
 @param dict An `NSDictionary` representation of the `UserProfile.`
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/**
 Converts the current `UserProfile` to an `NSDictionary`.
 
 @return This instance of `UserProfile` as an `NSDictionary`.
 */
- (NSDictionary*)toDictionary;

/**
 Gets the user's first and last name.
 */
- (NSString *)getFullName;


@end

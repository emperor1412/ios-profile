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

#import "SoomlaGooglePlus.h"
#import "UserProfile.h"
#import "SoomlaUtils.h"
#import "SoomlaProfile.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@interface SoomlaGooglePlus ()

@property (nonatomic, strong) id lastPageToken;
@property (nonatomic, strong) UIViewController *webVC;

@end

@implementation SoomlaGooglePlus {
    BOOL _autoLogin;
}

@synthesize loginSuccess, loginFail, loginCancel, logoutSuccess, logoutFail, socialActionSuccess, socialActionFail, clientId;

static NSString *TAG = @"SOOMLA SoomlaGooglePlus";
static NSString *GoogleKeychainName;

-(NSArray *)scopes {
    static NSArray *_scopes = nil;
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _scopes = @[
                kGTLAuthScopePlusLogin,
                kGTLAuthScopePlusUserinfoProfile
        ];
    });
    return _scopes;
}

#pragma mark Swizzle URL-schemes routing

static IMP originalImplementation = nil;
static Method originalMethod = nil;
static Method swizzledMethod = nil;

-(BOOL)openURL:(NSURL *)url {
    //when original method is swizzled, swizzled method will contain original implementation
    BOOL flag = [[SoomlaProfile getInstance] tryHandleOpenURL:url sourceApplication:[[NSBundle mainBundle] bundleIdentifier] annotation:nil];
    UIApplication* app =[UIApplication sharedApplication];
    BOOL flag2 = ((BOOL (*)(id, Method, ...))method_invoke)(app, swizzledMethod, url);
    return flag || flag2;
}

/*
    swizzling [UIApplication openURL:] method to intercept opening URLs with 'http'-scheme
    it's working like method overriding (we'll call original method if swizzled method returns NO) but better
    it's better than overriding because brings some flavour of DI and doesn't oblige user to make changes with his code :)
    @param forward sets direction of swizzling: if YES - we're replacing original method with our own, else - we're setting original method
 */
-(void)openURLSwizzle:(BOOL)forward {
    static BOOL methodReplaced = NO;
    if (!(forward ^ methodReplaced)) //we can swap method implementations only if this condition if true
        return;
    if (originalMethod == nil) {
        originalMethod = class_getInstanceMethod([UIApplication class], @selector(openURL:));
        swizzledMethod = class_getInstanceMethod([self class], @selector(openURL:));
    }
    method_exchangeImplementations(originalMethod, swizzledMethod);
    methodReplaced = !methodReplaced; //signalize that implementations was swapped
    LogDebug(TAG, forward ? @"Method openURL of UIApplication was overrided." : @"Method openURL of UIApplication was re-setted to original.");

}

- (id)init {
    self = [super init];
    
    if (!self)
        return nil;

    
    
    //replace `openURL:` original method
//    [self openURLSwizzle:YES];

    GoogleKeychainName = [NSString stringWithFormat:@"SoomlaGooglePlus: %@", [[NSBundle mainBundle] bundleIdentifier]];
    //subscribe to notification from unity via UnityAppController AppController_SendNotificationWithArg(kUnityOnOpenURL, notifData)
    LogDebug(TAG, @"addObserver kUnityOnOpenURL notification");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(innerHandleOpenURL:)
                                                 name:@"kUnityOnOpenURL"
                                               object:nil];
    
    return self;
}

- (void)applyParams:(NSDictionary *)providerParams{
    if (providerParams){
        _autoLogin = providerParams[@"autoLogin"] != nil ? [providerParams[@"autoLogin"] boolValue] : NO;
        clientId = providerParams[@"clientId"];
    } else {
        _autoLogin = NO;
    }
}

- (void)login:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel{
    LogDebug(TAG, @"Login");
    
    [self setLoginBlocks:success fail:fail cancel:cancel];
    
    NSString *authParamsCheckResult = [self checkAuthParams];
    
    if (authParamsCheckResult){
        fail([NSString stringWithFormat:@"Authentication params check failed: %@", authParamsCheckResult]);
        return;
    }

    [self startGooglePlusAuth];
}

-(BOOL)startWebGooglePlusAuth:(NSURL *)url {
    if (![self checkIsFallbackURL:url]) {
        return NO;
    }
    self.webVC = [[UIViewController alloc] init];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 20, 300, 500)];
    webView.backgroundColor = [UIColor whiteColor];
    webView.scalesPageToFit = YES;
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:self.webVC animated:YES completion:nil];
    [self.webVC.view addSubview:webView];

    NSDictionary *views = NSDictionaryOfVariableBindings(webView);

    [self.webVC.view addConstraints:
            [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                    options:0
                                                    metrics:nil
                                                      views:views]];

    [self.webVC.view addConstraints:
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|"
                                                    options:0
                                                    metrics:nil
                                                      views:views]];

    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    return YES;
}

- (void)startGooglePlusAuth{
    /*
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
    NSArray* scopes = @[kGTLAuthScopePlusLogin, kGTLAuthScopePlusUserinfoProfile];
    
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.attemptSSO = YES; // tries to use other installed Google apps
    signIn.clientID = self.clientId;
    signIn.keychainName = GoogleKeychainName;
    signIn.scopes = scopes;
    
    signIn.delegate = self;


    [signIn authenticate];
     */
    
    GPPShare *share = [GPPShare sharedInstance];
    share.delegate = self;
    
    GIDSignIn* signIn = [GIDSignIn sharedInstance];

    signIn.shouldFetchBasicProfile = YES;
    signIn.clientID = self.clientId;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    
    [signIn signIn];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    if (error) {
        if ([error code] == -1)
            self.loginCancel();
        else
            self.loginFail([error localizedDescription]);
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

#pragma mark - GIDSignInDelegate method
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSLog(@"%@", signIn);
    [self finishedWithAuth:nil error:error];
}
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    NSLog(@"%@", signIn);
    [self finishedWithAuth:nil error:error];
}

#pragma mark - GIDSignInUIDelegate methods
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -


-(void)refreshInterfaceBasedOnSignIn {
//    if ([[GPPSignIn sharedInstance] authentication]) {
    if ([[GIDSignIn sharedInstance] currentUser]) {
        self.loginSuccess(GOOGLE);
    } else {
        [self clearLoginBlocks];
        self.loginFail(@"GooglePlus Authentication failed.");
    }
}

- (void)getUserProfile:(userProfileSuccess)success fail:(userProfileFail)fail{
    LogDebug(TAG, @"getUserProfile");
    
    if([GPPSignIn sharedInstance].authentication) {
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
        plusService.retryEnabled = YES;
        
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        LogError(TAG, @"Failed getting user profile");
                        fail([error localizedDescription]);
                    } else {
                        UserProfile *userProfile = [self parseGoogleContact:person withExtraData:YES];
                        success(userProfile);
                    }
                }];
    }
    else if([[GIDSignIn sharedInstance] currentUser] && [[GIDSignIn sharedInstance] currentUser].authentication){
        GIDGoogleUser* currentUser = [[GIDSignIn sharedInstance] currentUser];
        
        NSDictionary *extraDict = @{
                                    @"access_token": currentUser.authentication.accessToken,
                                    @"refresh_token": currentUser.authentication.refreshToken,
                                    @"expiration_date": @((NSInteger) currentUser.authentication.accessTokenExpirationDate.timeIntervalSince1970)
                                    };
        
        NSString* firstName = @"";
        NSString* lastName = @"";
        NSArray* separate = [currentUser.profile.name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if([separate count] > 0) {
            firstName = [separate objectAtIndex:0];
            lastName = [[currentUser.profile.name substringFromIndex:[firstName length]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        
        UserProfile * profile =
        [[UserProfile alloc] initWithProvider:GOOGLE
                                 andProfileId:currentUser.userID
                                  andUsername: @""
                                     andEmail:currentUser.profile.email
                                 andFirstName:firstName
                                  andLastName:lastName
                                     andExtra:extraDict];
        success(profile);
    }
    else {
        fail(@"User profile is null");
    }
    
}

- (void)logout:(logoutSuccess)success fail:(logoutFail)fail{
    LogDebug(TAG, @"logout");
    self.logoutSuccess = success;
    self.logoutFail = fail;
    
//    [[GPPSignIn sharedInstance] disconnect];
    [[GIDSignIn sharedInstance] signOut];
}

- (void)didDisconnectWithError:(NSError *)error {
    if (error) {
        self.logoutFail([error localizedDescription]);
    } else {
        [self clearLoginBlocks];
        self.logoutSuccess();
    }
}

- (BOOL)isLoggedIn{
    LogDebug(TAG, @"isLoggedIn");
//    return ([GPPSignIn sharedInstance].authentication != nil);
    return ([GIDSignIn sharedInstance].currentUser != nil);
}

- (BOOL)isAutoLogin {
    return _autoLogin;
}

-(BOOL)checkIsFallbackURL:(NSURL *)url {
    if (![url.host isEqualToString:@"accounts.google.com"]) {
        return NO;
    }
    if ([url.absoluteString componentsSeparatedByString:@"?"].count < 2) {
        return NO;
    }
    NSArray *rawParameters = [[url.absoluteString componentsSeparatedByString:@"?"][1] componentsSeparatedByString:@"&"];
    NSMutableDictionary *processedParameters = [NSMutableDictionary new];
    for (NSString *current in rawParameters) {
        if ([current componentsSeparatedByString:@"="].count < 2) {
            return NO;
        }
        NSArray *params = [current componentsSeparatedByString:@"="];
        processedParameters[params[0]] = params[1];
    }
    return [processedParameters[@"redirect_uri"] isEqualToString:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@"%3A%2Foauth2callback"]] &&
            [processedParameters[@"client_id"] isEqualToString:clientId];
}

- (BOOL)tryHandleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    sourceApplication = @"com.apple.mobilesafari"; //GPPURLHandler doesn't want to catch URLSchemas from another apps (excluding google apps)
    
//    BOOL handledByGoogle = [GPPURLHandler handleURL:url
//                                  sourceApplication:sourceApplication
//                                         annotation:annotation];
    
    BOOL handledByGoogle = [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication
                               annotation:annotation];
    if (handledByGoogle) {
        if (self.webVC != nil) {
            [self.webVC dismissViewControllerAnimated:YES completion:nil];
            self.webVC = nil;
        }
    }
    
    return handledByGoogle || [self startWebGooglePlusAuth:url];
}

- (void)updateStatus:(NSString *)status success:(socialActionSuccess)success fail:(socialActionFail)fail{
    LogDebug(TAG, @"updateStatus");
    [self setSocialActionBlocks:success fail:fail];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:status];
    [shareBuilder open];
}

- (void)updateStatusWithProviderDialog:(NSString *)link success:(socialActionSuccess)success fail:(socialActionFail)fail{
    LogDebug(TAG, @"updateStatus");
    [self setSocialActionBlocks:success fail:fail];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setURLToShare:[NSURL URLWithString:link]];
    [shareBuilder open];
}

- (void)updateStoryWithMessage:(NSString *)message
                       andName:(NSString *)name
                    andCaption:(NSString *)caption
                andDescription:(NSString *)description
                       andLink:(NSString *)link
                    andPicture:(NSString *)picture
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    [self setSocialActionBlocks:success fail:fail];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:message];
    [shareBuilder setURLToShare:[NSURL URLWithString:link]];
    [shareBuilder open];
}

- (void)updateStoryWithMessageDialog:(NSString *)name
                          andCaption:(NSString *)caption
                      andDescription:(NSString *)description
                             andLink:(NSString *)link
                          andPicture:(NSString *)picture
                             success:(socialActionSuccess)success
                                fail:(socialActionFail)fail
{
    fail(@"updateStoryWithMessageDialog is not implemented");
}

- (void)uploadImageWithMessage:(NSString *)message
                   andFilePath:(NSString *)filePath
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail
{
    LogDebug(TAG, @"uploadImage");
    [self setSocialActionBlocks:success fail:fail];
    [GPPShare sharedInstance].delegate = self;
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [shareBuilder setPrefillText:message];
    [shareBuilder attachImage:[UIImage imageWithContentsOfFile:filePath]];
    [shareBuilder open];
}

- (void)uploadImageWithMessage:(NSString *)message
              andImageFileName: (NSString *)fileName
                  andImageData: (NSData *)imageData
                       success:(socialActionSuccess)success
                          fail:(socialActionFail)fail{
    LogDebug(TAG, @"uploadImage");
    [self setSocialActionBlocks:success fail:fail];
    [GPPShare sharedInstance].delegate = self;
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];

    [shareBuilder setPrefillText:message];

    UIImage *image = [UIImage imageWithData:imageData];
    [shareBuilder attachImage:image];

    [shareBuilder open];
}

- (void)finishedSharingWithError:(NSError *)error {
    
    if (!error) {
        self.socialActionSuccess();
    } else if (error.code == kGPPErrorShareboxCanceled) {
        self.socialActionFail(@"Social Action Cancelled");
    } else {
        self.socialActionFail([NSString stringWithFormat:@"Social Action Failed (%@)", [error localizedDescription]]);
    }
    [self clearSocialActionBlocks];
}

- (void)getContacts:(bool)fromStart success:(contactsActionSuccess)success fail:(contactsActionFail)fail {
    LogDebug(TAG, @"getContacts");
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    GTLQueryPlus *query =
    [GTLQueryPlus queryForPeopleListWithUserId:@"me"
                                    collection:kGTLPlusCollectionVisible];

    NSString *pageToken = fromStart ? nil : self.lastPageToken;
    self.lastPageToken = nil;
    if (pageToken) {
        [query setPageToken: pageToken];
    }

    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPeopleFeed *peopleFeed,
                                NSError *error) {

                self.lastPageToken = peopleFeed.nextPageToken;

                if (error) {
                    LogError(TAG, @"Failed getting contacts");
                    fail([error localizedDescription]);
                } else {

                    NSArray* rawContacts = peopleFeed.items;
                    
                    NSMutableArray *contacts = [NSMutableArray array];
                    
                    for (GTLPlusPerson *rawContact in rawContacts) {
                        UserProfile *contact = [self parseGoogleContact:rawContact];
                        
                        [contacts addObject:contact];
                    }
                    
                    success(contacts, peopleFeed.nextPageToken != nil);
                }
            }];
}

- (void)getFeed:(bool)fromFirst success:(feedsActionSuccess)success fail:(feedsActionFail)fail {
    LogDebug(TAG, @"getFeed");
    fail(@"getFeed is not implemented!");
}

- (Provider)getProvider {
    return GOOGLE;
}

- (void)like:(NSString *)pageId{
    
    NSString *baseURL = @"gplus://plus.google.com/";

    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:baseURL]])
    {
        baseURL = @"https://plus.google.com/";
    }
    
    if ([pageId rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
        pageId = [NSString stringWithFormat:@"+%@", pageId];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, pageId]]];
}

-(UserProfile *)parseGoogleContact:(GTLPlusPerson *)googleContact withExtraData:(BOOL)withExtraData {
    NSString* displayName = googleContact.displayName;
    NSString* firstName, *lastName;

    if (displayName)
    {
        NSArray *names = [displayName componentsSeparatedByString:@" "];
        if (names && ([names count] > 0)) {
            firstName = names[0];
            if ([names count] > 1) {
                lastName = names[1];
            }
        }
    }

    GTLPlusPersonEmailsItem *email = [googleContact.emails objectAtIndex:0];
    GTMOAuth2Authentication *auth = [GPPSignIn sharedInstance].authentication;
    NSDictionary *extraDict = nil;
    if (withExtraData) {
        extraDict = @{
                @"access_token": auth.accessToken,
                @"refresh_token": auth.refreshToken,
                @"expiration_date": @((NSInteger)auth.expirationDate.timeIntervalSince1970)
        };
    }

    UserProfile * profile =
            [[UserProfile alloc] initWithProvider:GOOGLE
                                     andProfileId:[self parseGoogleContactInfoString:googleContact.identifier]
                                      andUsername: @""
                                         andEmail:[self parseGoogleContactInfoString:[email value]]
                                     andFirstName:firstName
                                      andLastName:lastName
                                         andExtra:extraDict];

    profile.username = @"";
    profile.gender = [self parseGoogleContactInfoString:googleContact.gender];
    profile.birthday = [self parseGoogleContactInfoString:googleContact.birthday];
    profile.location = [self parseGoogleContactInfoString:googleContact.currentLocation];
    profile.avatarLink = [self parseGoogleContactInfoString:[googleContact.image url]];
    profile.language = [self parseGoogleContactInfoString:googleContact.language];

    return profile;
}

-(UserProfile *) parseGoogleContact: (GTLPlusPerson *)googleContact{
    return [self parseGoogleContact:googleContact withExtraData:NO];
}

- (NSString *)parseGoogleContactInfoString:(NSString * )orig{
    return (orig) ? orig : @"";
}

-(void)setLoginBlocks:(loginSuccess)success fail:(loginFail)fail cancel:(loginCancel)cancel{
    self.loginSuccess = success;
    self.loginFail = fail;
    self.loginCancel = cancel;
}

-(void)setSocialActionBlocks:(socialActionSuccess)success fail:(socialActionFail)fail{
    self.socialActionSuccess = success;
    self.socialActionFail = fail;
}

- (void)clearLoginBlocks {
    self.loginSuccess = nil;
    self.loginFail = nil;
    self.loginCancel = nil;
}

- (void)clearSocialActionBlocks {
    self.socialActionSuccess = nil;
    self.socialActionFail = nil;
}

- (NSString *)checkAuthParams{
    if (!clientId)
        return @"Missing client id";
    return nil;
}

- (void)innerHandleOpenURL:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"kUnityOnOpenURL"]) {
        LogDebug(TAG, @"Successfully received the kUnityOnOpenURL notification!");
        
        NSURL *url = [[notification userInfo] valueForKey:@"url"];
        NSString *sourceApplication = [[notification userInfo] valueForKey:@"sourceApplication"];
        id annotation = [[notification userInfo] valueForKey:@"annotation"];
        
        /*
        BOOL urlWasHandled = [GPPURLHandler handleURL:url
                                    sourceApplication:sourceApplication
                                           annotation:annotation];
         */
        
        BOOL urlWasHandled = [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication
                                                          annotation:annotation];

        
        LogDebug(TAG,
                 ([NSString stringWithFormat:@"urlWasHandled: %@",
                   urlWasHandled ? @"True" : @"False"]));
    }
}

- (void)dealloc {
    [self openURLSwizzle:NO];
    LogDebug(TAG, @"removeObserver kUnityOnOpenURL notification");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

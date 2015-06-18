*This project is a part of The [SOOMLA](http://www.soom.la) Framework, which is a series of open source initiatives with a joint goal to help mobile game developers do more together. SOOMLA encourages better game design, economy modeling, social engagement, and faster development.*

Haven't you ever wanted an in-app purchase one liner that looks like this ?!

```objective-c
[[SoomlaProfile getInstance] updateStatusWithProvider:FACEBOOK
                             andStatus:@"I Love This GAME !"
                             andReward:appDelegate.updateStatusReward];
```

ios-profile
---

*SOOMLA's Profile Module for iOS*

*As of v1.0 **ios-profile** supports Facebook, Google+ and Twitter*

**ios-profile** is an open code initiative as part of The SOOMLA Project. It is an Objective-C API that unifies interaction with social and identity providers APIs, and optionally ties it together with the game's virtual economy.
This enables to easily reward players with social actions they perform in-game, and to leverage user profiles.

![SOOMLA's Profile Module](http://know.soom.la/img/tutorial_img/soomla_diagrams/Profile.png)

## Download

####Pre baked libraries:

[ios-profile 1.1.1](http://library.soom.la/fetch/ios-profile/1.1.1?cf=github)

Getting Started
---

#### **WE USE ARC !**

1. The static libs and headers you need are in the zip you downloaded from the link above.

  * Set your project's "Library Search Paths" and "Header Search Paths" to that folder with `recursive` option.
  * Add `-ObjC -lSoomlaiOSProfile -lSoomlaiOSCore` to the project's "Other Linker Flags".

1. Make sure you have the following frameworks in your application's project: **Security, libsqlite3.0.dylib**.

1. Initialize **Soomla** with a secret that you chose to encrypt the user data. (For those who came from older versions, this should be the same as the old "custom secret"):

    ```objective-c
    [Soomla initializeWithSecret:@"[YOUR CUSTOM GAME SECRET HERE]"];
    ```
> The secret is your encryption secret for data saved in the DB.

1. If integrating a virtual economy with the store module, please see [ios-store](https://github.com/soomla/ios-store) for store setup.

1. Initalize Soomla Profile:
  ```objective-c
  [[SoomlaProfile getInstance] initialize];
  ```
  Note that some providers will need initialization parameters (see their sections below), in that case you'll need to supply their parameters here, each with its dictionary:
  ```objective-c
  NSDictionary* providerParams = @{ @([provider]) : @{...}
                                    ... };
    [[SoomlaProfile getInstance] initialize:providerParams];
  ```
  1. **Facebook** - No parameters
  1. **Google+** - Please provide **CLIENT ID** from the "API&Auth" -> "Credentials" -> "Client ID for iOS applicatio" section in [Google Developer Console Projects](https://console.developers.google.com/project/), like so:
    ```objective-c
      @(GOOGLE) : @{ @"clientId": @"[CLIENT ID]" }
    ```
  1. **Twitter** - Please provide **Consumer Key** and **Consumer Secret** from the "Keys and Access Tokens" section in [Twitter Apps](https://apps.twitter.com/), like so:
    ```objective-c
      @(TWITTER) : @{ @"consumerKey": @"[YOUR CONSUMER KEY]",
                      @"consumerSecret": @"[YOUR CONSUMER SECRET]" }
    ```
      1. (OPTIONAL) You can supply the `forceWeb` key in the parameters (with a `BOOL`) value if you would like to force browser-based authorization, like so:
      ```objective-c
        @(TWITTER): @{ ..., @"forceWeb": @(YES) },
      ```
1. Refer to the [next section](https://github.com/soomla/ios-profile#whats-next-selecting-social-providers) for information of selecting social providers and setting them up.

1. Access the Profile functionality through `SoomlaProfile`

    ```objective-c
    [[SoomlaProfile getInstance] ...];
    ```

And that's it ! You have social network capabilities.

## What's next? Selecting Social Providers

**ios-profile** is structured to support multiple social networks (Facebook, Twitter, etc.), at the time of writing this the framework only supports Facebook, Twitter and Google+ integration.

### Facebook

Facebook is supported out-of-the-box, you just have to follow the next steps to make it work:

1. Add the Facebook SDK for iOS to the project's Frameworks and make sure your project links to the project

1. Refer to [Getting Started with the Facebook iOS SDK](https://developers.facebook.com/docs/ios/getting-started/) for more information

1. Add `-lSoomlaiOSProfileFacebook` to the project's "Other Linker Flags"

### Twitter

Twitter is supported out-of-the-box, authentication is done either through the signed in Twitter account (iOS 5+) or through web browser (fallback). Follow the next steps to make it work:

1. Create your Twitter app at https://apps.twitter.com/

1. Add a URL scheme to your application:
  1. Go to the application's "Info" section in the build target
  1. Under "URL Types" add a new URL type
  1. In the "URL Schemes" fill in `tw<Your Twitter app consumer key>` (without the braces)

1. Make sure you have the following frameworks in your application's project: **Twitter, Social, Accounts**.

1. Add `-lSoomlaiOSProfileTwitter -lSTTwitter` to the project's "Other Linker Flags"
  > **ios-profile** uses the [STTWitter](https://github.com/nst/STTwitter) library (v 0.1.5) to support Twitter integration

### Google Plus

Google Plus is supported out-of-the-box, authentication is done either through the signed in Google Plus account or through web browser (fallback). Follow the next steps to make it work:

1. Follow [Step 1. Creating the Google Developers Console project](https://developers.google.com/+/mobile/ios/getting-started#step_1_creating_the_console_name_project) and create a google+ app for iOS.

  > **NOTE:** Set the BUNDLE ID of the google+ app to the bundle identifier of your app.

1. Follow [Step 3. Add a URL type](https://developers.google.com/+/mobile/ios/getting-started#step_3_add_a_url_type) and add url type to your application to allow browser based authentication.

1. Navigate to [social-providers/ios-profile-google/libs](https://github.com/soomla/ios-profile/tree/master/social-providers/ios-profile-google/libs) and add the following frameworks to your application:
    * GooglePlus.framework
    * GoogleOpenSource.framework
    * GooglePlus.bundle

  > **ios-profile** uses [Google Plus SDK 1.7.1](https://developers.google.com/+/mobile/ios/upgrading-sdk) to support Google Plus integration.

1. Add additional frameworks to your project:
    * AddressBook.framework
    * AssetsLibrary.framework
    * Foundation.framework
    * CoreLocation.framework
    * CoreMotion.framework
    * CoreGraphics.framework
    * CoreText.framework
    * MediaPlayer.framework
    * Security.framework
    * SystemConfiguration.framework
    * UIKit.framework

1. Add `-lSoomlaiOSProfileGoogle` to the project's "Other Linker Flags"

### Browser-based Authentication

Most social framework SDKs support authentication through your web browser, when the user finishes authenticating through the browser your application will be called dependent on the URL schemes you have defined.

The callback to this process is `openURL` which should be defined in your `AppDelegate`, **ios-profile** provides you with a helper method to handle the `openURL` callback through its providers. Add the following code to your `AppDelegate` to handle this properly:

```objective-c
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL urlWasHandled = [[SoomlaProfile getInstance] tryHandleOpenURL:url sourceApplication:sourceApplication annotation:annotation];

    if (urlWasHandled) {
        return urlWasHandled;
    }

    // Profile was unable to handle callback, do some custom handling
    return NO;
}
```

## UserProfile

As part of a login call to a provider, Soomla will internally try to also fetch the online user profile details via
`UserProfile` and store them in the secure [Soomla Storage](https://github.com/soomla/ios-store#storage--meta-data)
Later, this can be retrieved locally (in offline mode) via:

```objective-c
UserProfile *userProfile = [[SoomlaProfile getInstance] getStoredUserProfileWithProvider:FACEBOOK];
```

This can throw a `UserProfileNotFoundException` if something strange happens to the local storage, in that case, you need to require a new login to get the `UserProfile` again.

## Rewards feature

One of the big benefits of using Soomla's profile module for social networks interactions is that you can easily tie it in with the game's virtual economy.
This is done by the ability to specify a `Reward` (perhaps more specifically, a `VirtualItemReward`) to most social actions defined in `SoomlaProfile`.

For example, to reward a user with a "sword" virtual item upon login to Facebook:

```objective-c
Reward *reward = [[VirtualItemReward alloc] initWithRewardId:@"..."
                                            andName:@"Update Status for sword"
                                            andAmount:1
                                            andAssociatedItemId:@"sword"];
[[SoomlaProfile getInstance] loginWithProvider:FACEBOOK andReward:reward];
```

Once login completes sucessfully (wait for `EVENT_UP_LOGIN_FINISHED`), the reward will be automatically given, and synchronized with Soomla's storage.

The reward ID is something you manage and should be unique, much like virtual items.


## Debugging

In order to debug ios-profile, set `DEBUG_LOG` (see [SoomlaConfig](https://github.com/soomla/soomla-ios-core/blob/master/SoomlaiOSCore/SoomlaConfig.m)) to `YES`. This will print all of _ios-profile's_ debugging messages to Log Navigator.

## Storage

The on-device storage is encrypted and kept in a SQLite database. SOOMLA is preparing a cloud-based storage service that will allow this SQLite to be synced to a cloud-based repository that you'll define.

## Security

If you want to protect your application from 'bad people' (and who doesn't?!), you might want to follow some guidelines:

+ SOOMLA keeps the game's data in an encrypted database. In order to encrypt your data, SOOMLA generates a private key out of several parts of information. Soomla's secret (before v3.4.0 is was known as custom secret) is one of them. SOOMLA recommends that you change this value before you release your game. BE CAREFUL: You can change this value once! If you try to change it again, old data from the database will become unavailable.


## Event Handling

SOOMLA lets you get notifications on various events and implement your own application specific behavior.

> Your behavior is an addition to the default behavior implemented by SOOMLA. You don't replace SOOMLA's behavior.

In order to observe store events you need to import `EventHandling.h` and then you can add a notification to `NSNotificationCenter`:

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(yourCustomSelector:) name:EVENT_UP_LOGIN_STARTED object:nil];
```

OR, you can observe all events with the same selector by calling:

```objective-c
[UserProfileEventHandling observeAllEventsWithObserver:self withSelector:@selector(yourCustomSelector:)];
```

[List of events](https://github.com/soomla/ios-profile/blob/master/SoomlaiOSProfile/UserProfileEventHandling.h)

## Example Project

The **ios-profile** project contains an [example project](https://github.com/soomla/ios-profile/tree/master/SoomlaiOSProfileExample) which shows most of the functionality Profile provides, and the correct setup.
In order to run the project follow this steps:

1. NOTE: The example project is dependent upon [ios-store](https://github.com/soomla/ios-store) and assumes the project is cloned in a sibling folder to **ios-profile**. Refer to [ios-store](https://github.com/soomla/ios-store) on instructions on how to clone the project
1. Open the `SoomlaiOSProfileExample.xcodeproj` project in XCode
1. Run the project on Simulator or on Device

## Facebook Caveats

1. **Facebook Application** - You must create a Facebook application and use its details in your Profile-based application (with Facebook)

1. **Facebook ID and Display name** - The Facebook application's ID and Name must be used in your application, this information must be added to the application's `plist` file, under `FacebookAppID` (App ID) and `FacebookDisplayName` (Application name)

1. **URL Schemes and openURL** - To support web-based authorization and dialogs the application needs to handle URL schemes (see [here](https://developers.facebook.com/docs/facebook-login/ios/v2.1) for more information):
  1. Under the project's info add an entry to `URL Types` and under `URL Schemes` add the string `fbxxxxxxx` the x's should be replaced with your Facebook App ID.
  1. See [Browser-based Authentication](#browser-based-authentication)
1. **Facebook Permissions** - Profile will request `publish_actions` from the user of the application, to test the application please make sure you test with either Admin, Developer or Tester roles


## Twitter Caveats

1. **Login method returns 401 error** - this could be the result of a few issues:
  1. Have you supplied the correct consumer key and secret in `SoomlaProfile` initialization?
  1. Have you supplied a `Callback URL` in your Twitter application settings?

## Google Plus Caveats

1. **401. That's an error. Error:invalid_client** - this could be the result of a few issues:
  1. Have you supplied the correct client id in `SoomlaProfile` initialization?
  1. Does your google+ app BUNDLE ID equal to the Bundle Identifier of your iOS app?
  1. Did you add a URL type with identifier and Url Schemes set to your Bundle Identifier?
1. Did you add all required the frameworks?

Our way of saying "Thanks !"
---

Other open-source projects that we use:

* [FBEncryptor](https://github.com/dev5tec/FBEncryptor)

Contribution
---
SOOMLA appreciates code contributions! You are more than welcome to extend the capabilities of SOOMLA.

Fork -> Clone -> Implement -> Add documentation -> Test -> Pull-Request.

IMPORTANT: If you would like to contribute, please follow our [Documentation Guidelines](https://github.com/soomla/ios-store/blob/master/documentation.md). Clear, consistent comments will make our code easy to understand.

## SOOMLA, Elsewhere ...

+ [Framework Website](http://www.soom.la/)
+ [Knowledge Base](http://know.soom.la/)


<a href="https://www.facebook.com/pages/The-SOOMLA-Project/389643294427376"><img src="http://know.soom.la/img/tutorial_img/social/Facebook.png"></a><a href="https://twitter.com/Soomla"><img src="http://know.soom.la/img/tutorial_img/social/Twitter.png"></a><a href="https://plus.google.com/+SoomLa/posts"><img src="http://know.soom.la/img/tutorial_img/social/GoogleP.png"></a><a href ="https://www.youtube.com/channel/UCR1-D9GdSRRLD0fiEDkpeyg"><img src="http://know.soom.la/img/tutorial_img/social/Youtube.png"></a>

License
---
Apache License. Copyright (c) 2012-2014 SOOMLA. http://project.soom.la
+ http://opensource.org/licenses/Apache-2.0

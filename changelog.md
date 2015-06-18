### v1.1.2 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.1...v1.1.2)

* Fixes
  * multiShare crash on iPad with iOS8
* Changes
  * avoid Safari login in FB
  * avoid Safari login in Twitter
  * improve working with the permissions in FB

### v1.1.1 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.1.0...v1.1.1)

* Fixes
  * Fix `publish_actions` permission

### v1.1.0 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.5...v1.1.0)

**BREAKING API VERSION**

* New Features
  * Implemented Pagination for getContactsWithProvider and getFeedWithProvider
  * Implemented multi-sharing (sharing with the native functionality of your target platform)
  * Implemented methods to show confirmation dialog before some actions
  * Supporting permissions param in FB

* Changes
  * Changed signature of `-[SoomlaProfile like:andPageId:andReward:]` (***breaking change***)

### v1.0.5 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.4...v1.0.5)

* Changes
  * Fixes to KVS from submodule

### v1.0.4 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.3...v1.0.4)

* New Features
  * Supporting uploadImage with NSData

### v1.0.3 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.2...v1.0.3)

* Fixes
  * Giving rewards before sending completion events
  * Making getStoredUserProfiles unrelated to profile init

### v1.0.2 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.1...v1.0.2)

* New Features
  * Adding getStoredUserProfiles
  * Upgrading example functionality

### v1.0.1 [view commit logs](https://github.com/soomla/ios-profile/compare/v1.0.0...v1.0.1)

* Changes
  * Fixed the name of event handling class.

### v1.0.0 (17.11.14)
* Features
  * The module is integrated with Facebook, Google Plus and Twitter
  * Ability to preform following actions on multiple social networks (parallel):
    * Login/Logout
    * Update status
    * Update Story (supported fully in Facebook only)
    * Upload image
    * Get user profile + store it on the device
    * Get user's contacts (not all social networks provide all information)
    * Get user's most recent feed (not supported in Google Plus)
  * Common interface to handling URL callbacks from web authentication within module

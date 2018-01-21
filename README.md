# Mathdoku

Steps to get up and running: 
1) pull the master branch
2) install cocoapods
3) run 'pod install' from the root directory
4) open the Xcode workspace
5) You will need to add the following files:
   - Secrets/AppKeys.swift
   - Secrets/AppSecrets.swift
   - GoogleServices-Info.plist
  
5a is an Enum of the following information: 
```swift
enum AppKeys {
    case adMobAppId
    case adMobPuzzleBannerAdId
    case moreKeysYouMayWant
    
    var key: String {
        switch self {
        case .adMobAppId: return ""
        case .adMobPuzzleBannerAdId: return ""
        case .moreKeysYouMayWant: return ""
    }
}
```

5b is a struct with the following information:
```swift
struct AppSecrets {
    static let domainRoot = ""
}
```

5c has to be obtained from Google for their services. Services I use are:
- Google Firebase
- Google AdMob (keys placed in 5a)

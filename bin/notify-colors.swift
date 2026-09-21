import Foundation

let names = [
    "AppleColorPreferencesChangedNotification",
    "AppleAquaColorVariantChanged",
]

for name in names {
    DistributedNotificationCenter.default().post(name: Notification.Name(name), object: nil)
}

import Foundation

var versionTimestamp: Double {
    get { UserDefaults.standard.double(forKey: "SyncManager.versionTimestamp") }
    set { UserDefaults.standard.set(newValue, forKey: "SyncManager.versionTimestamp") }
}

var versionDate: Date {
    Date(timeIntervalSince1970: versionTimestamp)
}

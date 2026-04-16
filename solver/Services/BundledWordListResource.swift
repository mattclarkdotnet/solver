import Foundation

enum BundledWordListResource {
    static func url(
        bundle: Bundle,
        baseResourceName: String,
        group: WordListGroup
    ) -> URL? {
        let resourceName = group.resourceName(for: baseResourceName)

        return bundle.url(
            forResource: resourceName,
            withExtension: "txt",
            subdirectory: group.resourceSubdirectory
        ) ?? bundle.url(forResource: resourceName, withExtension: "txt")
    }
}

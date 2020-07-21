import Logging

public var logger = Logger(label: "com.github.vox-humana.AppReviewPostman.AppReview")

public extension Logger {
    func appending(metadata: Logger.Metadata.Value, with key: String) -> Self {
        var logger = self
        logger[metadataKey: key] = metadata
        return logger
    }
}

import Logging

#if DEBUG
    let logLevel: Logger.Level = .debug
#else
    let logLevel: Logger.Level = .info
#endif

let logger: Logger = {
    var logger = Logger(label: "com.github.vox-humana.AppReviewPostman")
    logger.logLevel = logLevel
    return logger
}()

extension Logger {
    func appending(metadata: Logger.Metadata.Value, with key: String) -> Self {
        var logger = self
        logger[metadataKey: key] = metadata
        return logger
    }
}

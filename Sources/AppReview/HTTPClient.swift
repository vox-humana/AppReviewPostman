import Foundation
import Logging
import NIO
import NIOHTTP1
import NIOSSL

public class HTTPClient {
    private let group: EventLoopGroup
    private let sslContext: NIOSSLContext

    public init(group: EventLoopGroup) throws {
        self.group = group
        let configuration = TLSConfiguration.forClient()
        sslContext = try NIOSSLContext(configuration: configuration)
    }

    public func send(request: HTTPRequest) -> EventLoopFuture<Data> {
        var requestLogger = logger
        requestLogger[metadataKey: "request-uuid"] = "\(UUID())"
        let promise: EventLoopPromise<Data> = group.next().makePromise(of: Data.self)

        return ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { [sslContext] channel in
                let openSslHandler = try! NIOSSLClientHandler(context: sslContext, serverHostname: request.host)
                return channel.pipeline.addHandler(openSslHandler).flatMap {
                    channel.pipeline.addHTTPClientHandlers()
                }
                .flatMap {
                    channel.pipeline.addHandler(HTTPResponseHandler(promise, logger: requestLogger))
                }
            }
            .connect(host: request.host, port: request.port)
            .flatMap { channel in
                requestLogger.info("Sending request...")
                return channel.send(request: request)
            }
            .flatMap {
                promise.futureResult
            }
    }
}

private extension Channel {
    func send(request: HTTPRequest) -> EventLoopFuture<Void> {
        var headers = HTTPHeaders([
            ("Host", request.host),
            ("Accept", "*/*"),
        ])

        if let body = request.body {
            headers.add(name: "Content-Type", value: body.type.description)
            headers.add(name: "Content-Length", value: "\(body.data.count)")
        }

        request.headers.forEach { key, value in
            headers.add(name: key, value: value)
        }

        let requestHead = HTTPRequestHead(
            version: HTTPVersion(major: 1, minor: 1),
            method: request.method,
            uri: request.uri,
            headers: headers
        )

        write(HTTPClientRequestPart.head(requestHead), promise: nil)

        if let data = request.body?.data {
            let buffer = allocator.buffer(bytes: data)
            write(HTTPClientRequestPart.body(.byteBuffer(buffer)), promise: nil)
        }

        return writeAndFlush(HTTPClientRequestPart.end(nil))
    }
}

private final class HTTPResponseHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPClientResponsePart

    private let logger: Logger
    private var promise: EventLoopPromise<Data>?
    private var receivedData = Data()
    private var httpError: HTTPError?

    init(_ promise: EventLoopPromise<Data>, logger: Logger) {
        logger.debug("Create response handler")
        self.logger = logger
        self.promise = promise
    }

    func channelRead(context _: ChannelHandlerContext, data: NIOAny) {
        let httpResponsePart = unwrapInboundIn(data)
        switch httpResponsePart {
        case let .head(httpResponseHeader):
            if httpResponseHeader.status != .ok {
                httpError = HTTPError(status: httpResponseHeader.status, response: nil)
                logger.error("Response: \(httpResponseHeader.status.code) \(httpResponseHeader.status.reasonPhrase)")
            } else {
                logger.info("Response: \(httpResponseHeader.status.code) \(httpResponseHeader.status.reasonPhrase)")
            }
            logger.debug("Headers: \(httpResponseHeader.headers)")
        case let .body(byteBuffer):
            receivedData.append(contentsOf: byteBuffer.readableBytesView)
            logger.debug("Received: '\(String(buffer: byteBuffer))' back from the server.")
        case .end:
            logger.debug("Closing channel")
            if var error = httpError {
                error.response = receivedData
                promise?.fail(error)
            } else {
                promise?.succeed(receivedData)
            }
            promise = nil
        }
    }

    func channelInactive(context _: ChannelHandlerContext) {
        promise?.fail(ChannelError.inputClosed)
        promise = nil
    }

    func errorCaught(context _: ChannelHandlerContext, error: Error) {
        logger.error("Channel error: \(error)")
        promise?.succeed(receivedData)
        promise = nil
    }
}

struct HTTPError: Error {
    let status: HTTPResponseStatus
    var response: Data?
}

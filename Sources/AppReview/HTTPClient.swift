import Foundation
import NIO
import NIOHTTP1
import NIOSSL

public struct HTTPRequest {
    let url: URL
    let method: HTTPMethod
    let body: Data?

    public init(_ url: URL, method: HTTPMethod, body: Data?) {
        self.url = url
        self.method = method
        self.body = body
    }
}

extension HTTPRequest {
    var host: String {
        url.host ?? "localhost"
    }

    var uri: String {
        var string = url.path.isEmpty ? "/" : url.path
        if let query = url.query {
            string += "?\(query)"
        }
        return string
    }

    var port: Int {
        url.port ?? (url.scheme?.lowercased() == "https" ? 443 : 80)
    }
}

public class HTTPClient {
    private let group: EventLoopGroup
    private let sslContext: NIOSSLContext

    public init(group: EventLoopGroup) throws {
        self.group = group
        let configuration = TLSConfiguration.forClient()
        sslContext = try NIOSSLContext(configuration: configuration)
    }

    public func send(request: HTTPRequest) -> EventLoopFuture<Data> {
        let promise: EventLoopPromise<Data> = group.next().makePromise(of: Data.self)

        return ClientBootstrap(group: group)
            .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { [sslContext] channel in
                let openSslHandler = try! NIOSSLClientHandler(context: sslContext, serverHostname: request.host)
                return channel.pipeline.addHandler(openSslHandler).flatMap {
                    channel.pipeline.addHTTPClientHandlers()
                }
                .flatMap {
                    channel.pipeline.addHandler(HTTPResponseHandler(promise))
                }
            }
            .connect(host: request.host, port: request.port)
            .flatMap { channel in
                channel.send(request: request)
            }
            .flatMap {
                promise.futureResult
            }
    }
}

extension Channel {
    func send(request: HTTPRequest) -> EventLoopFuture<Void> {
        var headers = HTTPHeaders([
            ("Host", request.host),
            ("Accept", "*/*"),
        ])

        if let data = request.body {
            headers.add(name: "Content-Type", value: "application/json")
            headers.add(name: "Content-Length", value: "\(data.count)")
        }

        let requestHead = HTTPRequestHead(
            version: HTTPVersion(major: 1, minor: 1),
            method: request.method,
            uri: request.uri,
            headers: headers
        )

        write(HTTPClientRequestPart.head(requestHead), promise: nil)

        if let data = request.body {
            let buffer = allocator.buffer(bytes: data)
            write(HTTPClientRequestPart.body(.byteBuffer(buffer)), promise: nil)
        }

        return writeAndFlush(HTTPClientRequestPart.end(nil))
    }
}

private final class HTTPResponseHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPClientResponsePart

    private var promise: EventLoopPromise<Data>?
    private var receivedData = Data()

    init(_ promise: EventLoopPromise<Data>) {
        self.promise = promise
    }

    func channelRead(context _: ChannelHandlerContext, data: NIOAny) {
        let httpResponsePart = unwrapInboundIn(data)
        switch httpResponsePart {
        case let .head(httpResponseHeader):
            print("\(httpResponseHeader.version) \(httpResponseHeader.status.code) \(httpResponseHeader.status.reasonPhrase)")
            for (name, value) in httpResponseHeader.headers {
                print("\(name): \(value)")
            }
        case let .body(byteBuffer):
            receivedData.append(contentsOf: byteBuffer.readableBytesView)
            let string = String(buffer: byteBuffer)
            print("Received: '\(string)' back from the server.")
        case .end:
            print("Closing channel.")
            promise?.succeed(receivedData)
            promise = nil
        }
    }

    func channelInactive(context _: ChannelHandlerContext) {
        promise?.fail(ChannelError.inputClosed)
        promise = nil
    }

    func errorCaught(context _: ChannelHandlerContext, error: Error) {
        print("Error: ", error)
        promise?.succeed(receivedData)
        promise = nil
    }
}

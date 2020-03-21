//
//  Session.swift
//  AppExtension
//
//  Created by ZJaDe on 2019/1/3.
//  Copyright © 2019 ZJaDe. All rights reserved.
//

import Foundation
import RxSwift
#if canImport(RxSwiftExt)
import RxSwiftExt
#endif
import Alamofire
/** ZJaDe:
 订阅Request消息后，请求会开始发送，
 在response、progress或者map方法里面可以截取到获取的数据
 */
// MARK: -

extension Session: ReactiveCompatible {}
extension Reactive where Base: Session {
    // MARK: Request
    public func request(_ method: HTTPMethod,
                        _ url: URLConvertible,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil,
                        interceptor: RequestInterceptor? = nil) -> Observable<DataRequest> {
        getRequest { $0.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers, interceptor: interceptor) }
    }
    public func request(_ urlRequest: URLRequestConvertible, interceptor: RequestInterceptor? = nil) -> Observable<DataRequest> {
        getRequest { $0.request(urlRequest, interceptor: interceptor) }
    }
    // MARK: Upload
    public func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        with request: URLRequestConvertible,
        usingThreshold encodingMemoryThreshold: UInt64 = MultipartFormData.encodingMemoryThreshold,
        interceptor: RequestInterceptor? = nil,
        fileManager: FileManager = .default
    ) -> Observable<UploadRequest> {
        getRequest { $0.upload(multipartFormData: multipartFormData, with: request, usingThreshold: encodingMemoryThreshold, interceptor: interceptor, fileManager: fileManager) }
    }
    public func upload(
        multipartFormData: MultipartFormData,
        with request: URLRequestConvertible,
        usingThreshold encodingMemoryThreshold: UInt64 = MultipartFormData.encodingMemoryThreshold,
        interceptor: RequestInterceptor? = nil,
        fileManager: FileManager = .default
    ) -> Observable<UploadRequest> {
        getRequest { $0.upload(multipartFormData: multipartFormData, with: request, usingThreshold: encodingMemoryThreshold, interceptor: interceptor, fileManager: fileManager) }
    }
    // MARK: Download
    public func download(_ urlRequest: URLRequestConvertible,
                         interceptor: RequestInterceptor? = nil,
                         to destination: DownloadRequest.Destination? = nil) -> Observable<DownloadRequest> {
        getRequest { $0.download(urlRequest, interceptor: interceptor, to: destination) }
    }
    public func download(resumeData: Data,
                         interceptor: RequestInterceptor? = nil,
                         to destination: DownloadRequest.Destination? = nil) -> Observable<DownloadRequest> {
        getRequest { $0.download(resumingWith: resumeData, interceptor: interceptor, to: destination) }
    }
}
extension Reactive where Base: Session {
    /**
     订阅时发送一个信号 启动数据流
     后面接收到数据后自己根据情况控制信号结束
     不在这里控制信号的结束是 防止请求提前结束
     */
    private func getRequest<R: Request>(_ createRequest: @escaping (Session) -> R) -> Observable<R> {
        Observable<R>.create { observer -> Disposable in
            let session = self.base
            let request = createRequest(session)
            observer.onNext(request)
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
// MARK: -
public extension Reactive where Base: Session {
    @inline(__always)
    func request<T: TargetTypeConvertible>(_ token: T) -> Observable<DataRequest> {
        request(token.asTargetType())
    }
    @inline(__always)
    func upload<T: TargetTypeConvertible>(multipartFormData: @escaping (MultipartFormData) -> Void, _ token: T) -> Observable<UploadRequest> {
        upload(multipartFormData: multipartFormData, with: token.asTargetType())
    }
    @inline(__always)
    func download<T: TargetTypeConvertible>(_ token: T) -> Observable<DownloadRequest> {
        download(token.asTargetType())
    }
}

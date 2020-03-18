//
//  Request.swift
//  AppExtension
//
//  Created by ZJaDe on 2019/1/3.
//  Copyright © 2019 ZJaDe. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
// MARK: - Response
extension ObservableType where Element: DataRequest {
    public func response(queue: DispatchQueue = .main) -> Observable<RNDataResponse<Data?>> {
        flatMapNetwork {
            $0.asObservable { (request, completionHandler) in
                request.response(queue: queue, completionHandler: completionHandler)
            }
        }
    }
    public func response<T: DataResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Observable<RNDataResponse<T.SerializedObject>> {
        flatMapNetwork {
            $0.asObservable { (request, completionHandler) in
                request.response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
            }
        }
    }
}
extension ObservableType where Element: DownloadRequest {
    public func cancel() -> Observable<Data?> {
        flatMapNetwork { (request) -> Observable<Data?> in
            Observable.create { observer in
                request.cancel { (resumeData) in
                    observer.onNext(resumeData)
                    observer.onError(NetworkStateError.end)
                }
                return Disposables.create()
            }
        }
    }
    public func response(queue: DispatchQueue = .main) -> Observable<RNDownloadResponse<URL?>> {
        flatMapNetwork {
            $0.asObservable { (request, completionHandler) in
                request.response(queue: queue, completionHandler: completionHandler)
            }
        }
    }
    public func response<T: DownloadResponseSerializerProtocol>(queue: DispatchQueue = .main, responseSerializer: T) -> Observable<RNDownloadResponse<T.SerializedObject>> {
        flatMapNetwork {
            $0.asObservable { (request, completionHandler) in
                request.response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
            }
        }
    }
}

///flatMapLatest内部接收到最终数据后，通过NetworkStateError结束整个信号流
private enum NetworkStateError: Swift.Error {
    case end
}
extension ObservableType where Element: Request {
    private func flatMapNetwork<Source: ObservableConvertibleType>(_ selector: @escaping (Element) -> Source)
        -> Observable<Source.Element> {
            flatMapLatest(selector).catchError { (error) -> Observable<Source.Element> in
                if case .end = error as? NetworkStateError {
                    return Observable.empty()
                }
                /// 一般不会走这里 有些信号是外部接进来的，还是有可能会出现的
                throw error._mapError()
            }
    }
}
extension DataRequest {
    typealias DataResponseFunc<V> = (DataRequest, @escaping (AFDataResponse<V>) -> Void) -> Void
    @inline(__always)
    fileprivate func asObservable<V>(_ responseFunc: @escaping DataResponseFunc<V>) -> Observable<RNDataResponse<V>> {
        Observable.create { observer in
            responseFunc(self) { (response) -> Void in
                observer.onNext(response)
                observer.onError(NetworkStateError.end)
            }
            return Disposables.create()
        }
    }
}
extension DownloadRequest {
    typealias DownloadResponseFunc<V> = (DownloadRequest, @escaping (AFDownloadResponse<V>) -> Void) -> Void
    @inline(__always)
    fileprivate func asObservable<V>(_ responseFunc: @escaping DownloadResponseFunc<V>) -> Observable<RNDownloadResponse<V>> {
        Observable.create { observer in
            responseFunc(self) { (response) -> Void in
                observer.onNext(response)
                observer.onError(NetworkStateError.end)
            }
            return Disposables.create()
        }
    }
}
// MARK: - ResponseMap
let dataResponseSerializer = DataResponseSerializer()

extension ObservableType where Element: DataRequest {
    @inline(__always)
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<RNDataResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    @inline(__always)
    public func responseData(queue: DispatchQueue = .main) -> Observable<RNDataResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}
extension ObservableType where Element: DownloadRequest {
    @inline(__always)
    public func responseMap<T: Decodable>(type: T.Type, atKeyPath keyPath: String? = nil) -> Observable<RNDownloadResponse<T>> {
        response(queue: .main, responseSerializer: KeyPathDecodableResponseSerializer<T>(atKeyPath: keyPath))
    }
    @inline(__always)
    public func responseData(queue: DispatchQueue = .main) -> Observable<RNDownloadResponse<Data>> {
        response(queue: queue, responseSerializer: dataResponseSerializer)
    }
}

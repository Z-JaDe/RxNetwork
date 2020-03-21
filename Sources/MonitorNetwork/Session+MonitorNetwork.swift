//
//  Session+MonitorNetwork.swift
//  AppExtension
//
//  Created by ZJaDe on 2019/1/9.
//  Copyright © 2019 ZJaDe. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
extension Reactive where Base: Session {
    /// 无网时 继续监听 有网时直接返回
    public func monitorNetwork<T>(_ value: T) -> Observable<T> {
        self.monitorNetwork().map({ (hasNetwork) -> T in
            if hasNetwork {
                return value
            } else {
                throw NetworkError.noNetwork
            }
        })
    }
    /// 无网时 继续监听 有网时直接返回
    private func monitorNetwork() -> Observable<Bool> {
        Observable.create({ (observer) -> Disposable in
            let monitorNetwork = MonitorNetwork.shared
            if monitorNetwork.isListening {
                let disposable = monitorNetwork.networkChanged.subscribe(onNext: { (status) in
                    switch status {
                    case .notReachable, .unknown:
                        observer.onNext(false)
                    case .reachable:
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                })
                return Disposables.create([disposable])
            } else {
                observer.onNext(true)
                observer.onCompleted()
                return Disposables.create()
            }
        })
    }
}

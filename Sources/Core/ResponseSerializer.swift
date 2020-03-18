//
//  ResponseSerializer.swift
//  RxNetwork
//
//  Created by Apple on 2019/10/11.
//  Copyright © 2019 ZJaDe. All rights reserved.
//

import Foundation
import Alamofire

public final class KeyPathDecodableResponseSerializer<T: Decodable>: ResponseSerializer {
    public let dataPreprocessor: DataPreprocessor
    public let decoder: DataDecoder
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>
    public let keyPath: String?

    lazy var jsonSerializer: JSONResponseSerializer = JSONResponseSerializer(dataPreprocessor: dataPreprocessor, emptyResponseCodes: emptyResponseCodes, emptyRequestMethods: emptyRequestMethods)
    lazy var decodeSerializer: DecodableResponseSerializer<T> = DecodableResponseSerializer<T>(dataPreprocessor: dataPreprocessor, decoder: decoder, emptyResponseCodes: emptyResponseCodes, emptyRequestMethods: emptyRequestMethods)
    public init(dataPreprocessor: DataPreprocessor = JSONResponseSerializer.defaultDataPreprocessor,
                decoder: DataDecoder = JSONDecoder(),
                emptyResponseCodes: Set<Int> = JSONResponseSerializer.defaultEmptyResponseCodes,
                emptyRequestMethods: Set<HTTPMethod> = JSONResponseSerializer.defaultEmptyRequestMethods,
                atKeyPath keyPath: String?) {
        self.dataPreprocessor = dataPreprocessor
        self.decoder = decoder
        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
        self.keyPath = keyPath
    }

    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        do {
            var data = data
            if let keyPath = keyPath {
                let jsonData = try jsonSerializer.serialize(request: request, response: response, data: data, error: error)
                guard let jsonObject = (jsonData as? NSDictionary)?.value(forKeyPath: keyPath) else {
                    throw NetworkError.objectMapping("没有keyPath: \(keyPath)")
                }
                data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            }
            return try decodeSerializer.serialize(request: request, response: response, data: data, error: error)
        } catch let error {
            throw NetworkError.jsonMapping(error)
        }
    }
}

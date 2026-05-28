//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Fernando Campo Garcia on 27/05/26.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOk: Bool {
        statusCode == HTTPURLResponse.OK_200
    }
}

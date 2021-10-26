//
//  KinletAudioGenerator.swift
//  Kase
//
//  Created by George Sequeira on 3/26/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import Foundation


class KinletApi {
    var dataTask: URLSessionDataTask?

    init() {
        self.dataTask = nil
    }

    let sessionManager: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // seconds
        configuration.timeoutIntervalForResource = 30 // seconds
        return URLSession(configuration: .default)
    }()
    
    func createClip(attempt: Int, episodeId: String, startTs: Int, endTs: Int, completionHandler: @escaping (String) -> Void, errorHandler: @escaping (String) -> Void) {

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "kinlet.appspot.com"
        urlComponents.path = "/v0/api/clip"

        let urlStr = urlComponents.url!.absoluteString

        if let url = URL(string: urlStr) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            let parameters: [String: Any] = [
                "episodeId": episodeId,
                "startTs": startTs,
                "endTs": endTs
            ]

            request.httpBody = parameters.percentEncoded()
            // If another datatask is running, we cancel it.
            if dataTask?.state == URLSessionTask.State.running {
                dataTask!.cancel()
            }
            let task = self.sessionManager.dataTask(with: request) {(data, response, error) in
                if error != nil {
                    if error.debugDescription.contains("cancelled") {
                        print("Cancelled task no worries")
                    }else {
                        errorHandler(urlStr)
                    }
                    return
                }

                if let safeData = data {
                    if let httpResponse = response as? HTTPURLResponse {
                        if (500...550).contains(httpResponse.statusCode) {
                            if attempt < 3{
                                self.createClip(attempt: attempt+1, episodeId: episodeId, startTs: startTs, endTs: endTs, completionHandler: completionHandler, errorHandler: errorHandler)
                                return
                            } else {
                                errorHandler(urlStr)
                                return
                            }
                        }
                        if httpResponse.statusCode != 200 {
                            errorHandler(urlStr)
                            return
                        }
                    } else {
                        errorHandler(urlStr)
                        return
                    }
                    
                    let str = String(decoding: safeData, as: UTF8.self)
                    completionHandler(str)
                }
            }
            self.dataTask = task
            task.resume()
        }
    }


    func parseJson(requestData: Data) -> PodcastInformation? {
        let decoder = JSONDecoder()
        do{
            return try decoder.decode(PodcastInformation.self, from: requestData)
        } catch {
            print(error)
            return nil
        }
    }

}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

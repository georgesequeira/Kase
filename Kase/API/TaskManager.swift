//
//  TaskManager.swift
//  Kase
//
//  Created by George Sequeira on 2/13/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//
import CoreData

class TaskManager {
    let sessionManager: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // seconds
        configuration.timeoutIntervalForResource = 30 // seconds
        return URLSession(configuration: .default)
    }()
    
    func getData(episodeName: String, podcastName: String, completionHandler: @escaping (PodcastInformation) -> Void, errorHandler: @escaping (String) -> Void) {

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "kinlet.appspot.com"
        urlComponents.path = "/v0/api/episodeInformation"
        urlComponents.queryItems = [
           URLQueryItem(name: "episodeName", value: episodeName),
           URLQueryItem(name: "podcastName", value: podcastName)
        ]

        let urlStr = urlComponents.url!.absoluteString
        // TODO: come back to review this thing above us that can technically not turn into a string
        print("Doing \(urlStr)")
        if let url = URL(string: urlStr) {
            let task = sessionManager.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    print(error!)
                    errorHandler(urlStr)
                    return
                }

                if let safeData = data {
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        errorHandler(urlStr)
                        return
                    }
                    if httpResponse.statusCode != 200 {
                        errorHandler(urlStr)
                    }

                    let podcastInformation = self.parseJson(requestData: safeData)
                    if let podInfo = podcastInformation {
                        print("This is fine.")
                        if podInfo.error {
                            errorHandler(urlStr)
                        } else {
                            completionHandler(podInfo)
                        }
                    }
                }
            }
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

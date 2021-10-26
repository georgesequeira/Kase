//
//  PodcastInformation.swift
//  Kase
//
//  Created by George Sequeira on 2/13/20.
//  Copyright © 2020 George Sequeira. All rights reserved.
//


struct PodcastInformation: Decodable {
    let partial_episode_name: String
    let episode_name: String
    let podcast_name: String
    let description: String
    let audio_url: String
    let audio_length_sec: Int
    let found: Bool
    let error: Bool
    let error_msg: String
    let image_url: String
    let id: String
}

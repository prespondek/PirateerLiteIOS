//
//  Sound.swift
//  PirateerOnline
//
//  Created by Peter Respondek on 10/2/19.
//  Copyright © 2019 Peter Respondek. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AudioManager : NSObject, AVAudioPlayerDelegate {

    
    private var players = Dictionary<String,AVAudioPlayer>()

    static let sharedInstance = AudioManager()
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        players.forEach({ if $0.value === player {
            players[$0.key] = nil
            }})
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        players.forEach({ if $0.value === player {
            players[$0.key] = nil
            }})
    }
    
    override init() {
        super.init()
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playSound( sound: String, looping: Bool = false ) {
        if players[sound] != nil {
            return
        }
        let soundData = NSDataAsset(name: sound)
        do {
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            //player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            let player = try AVAudioPlayer(data: soundData!.data)
            player.delegate = self
            if looping {
                player.numberOfLoops = -1
            }
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            players[sound] = player
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

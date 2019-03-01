//
//  ViewController.swift
//  WarApp
//
//  Created by Benjamin Howlett on 2019-02-24.
//  Copyright © 2019 Benjamin Howlett. All rights reserved.
//

import UIKit

// Class to define a deck of cards
class Deck {
    
    // Declare some arrays for the cards in the deck and the cards that have been dealt
    var cards = [String]()
    var cardsDealt = [String]()
    
    // Initialize a new deck object by populating it with all 52 cards and shuffling
    init() {
        populateCards()
        shuffle()
    }
    
    // Populate the deck with all 52 cards
    func populateCards() {
        let suits = ["Spades", "Hearts", "Clubs", "Diamonds"]
        let values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"]
        cards = []
        
        for suit in suits {
            for value in values {
                cards.append("\(suit)\(value)")
            }
        }
    }
    
    // Shuffle the cards
    func shuffle() {
        cards.shuffle()
    }
    
    // Reset the deck by populating it with all 52 cards and shuffling them
    func reset() {
        populateCards()
        shuffle()
    }
    
    // Deal one card. Remove that card from the deck and add it to the pile of cards that have been dealt
    func dealCard() -> String {
        // If there are no more cards, return a "ooc" (out of cards) message
        if cards.count == 0 {
            return("ooc")
        }
        
        let card = cards[0]
        cardsDealt.append(cards[0])
        cards.remove(at: 0)
        return card
    }
    
    // Deal the specified number of cards. Remove those cards from the deck and add them to the pile of cards that have been dealt
    func dealCards(_ numberOfCards: Int) -> [String] {
        if cards.count < numberOfCards {
            return(["ooc"])
        }
        var hand = [String]()
        for _ in 1 ... numberOfCards {
            hand.append(cards[0])
            cardsDealt.append(cards[0])
            cards.remove(at: 0)
        }
        return hand
    }
}

// Main game view
class GameViewController: UIViewController {
    
    // Link up all my images and labels
    @IBOutlet weak var playerNumberOfCards: UILabel!
    
    @IBOutlet weak var cpuNumberOfCards: UILabel!
    
    @IBOutlet weak var playerCardStack: UIImageView!
    
    @IBOutlet weak var cpuCardStack: UIImageView!
    
    @IBOutlet weak var playerCurrentCard: UIImageView!
    
    @IBOutlet weak var cpuCurrentCard: UIImageView!
    
    @IBOutlet weak var playerWinsBanner: UILabel!
    
    @IBOutlet weak var cpuWinsBanner: UILabel!
    
    @IBOutlet weak var warBanner: UILabel!
    
    @IBOutlet weak var dealButton: UIButton!
    
    @IBOutlet weak var opponentStack: UIStackView!
    
    @IBOutlet weak var youWin: UILabel!
    
    @IBOutlet weak var youLose: UILabel!
    
    // Create variables to hold the cards
    // This is the deck of cards
    var deck = Deck()
    
    // Player's pile of cards
    var playerPile = [String]()
    
    // Opponent's pile of cards
    var cpuPile = [String]()
    
    // Cards currently played (held until a winner is resolved, then is added to the winner's pile)
    var cardsPlayed = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Deal out the cards between the players
        while deck.cards.count > 0 {
            playerPile += [deck.dealCard()]
            cpuPile += [deck.dealCard()]
        }
        
        // Update the label showing the current number of cards
        playerNumberOfCards.text = String(playerPile.count)
        cpuNumberOfCards.text = String(cpuPile.count)
        
    }
    
    // This is the only real user interaction, tapping a "deal" button
    @IBAction func dealTapped(_ sender: Any) {
        
        // Disable the button until the hand is resolved, maybe there is a better way to do this?
        dealButton.isEnabled = false
        
        // Create some needed variables
        var playerCard:String?
        var cpuCard:String?
        var isWar = true
        
        // Get the top card (last dealt) from each pile and display them in the play area.
        func playCards() {
            
            // Get the player and opponent cards and remove them from their respective stacks
            playerCard = playerPile[playerPile.count - 1]
            playerPile.remove(at: playerPile.count - 1)
            cpuCard = cpuPile[cpuPile.count - 1]
            cpuPile.remove(at: cpuPile.count - 1)
            
            // Add both cards to the currently played array
            cardsPlayed += [playerCard!, cpuCard!]
            
            // Update the played card images
            playerCurrentCard.image = UIImage(named: playerCard!)
            cpuCurrentCard.image = UIImage(named: cpuCard!)
            
            // Update the number of cards left in each stack
            playerNumberOfCards.text = String(playerPile.count)
            cpuNumberOfCards.text = String(cpuPile.count)
        }
        
        // Main game logic
        func play() {
            
            // Play the cards
            playCards()
        
            // Check if someone one
            if getCardRank(playerCard!) > getCardRank(cpuCard!) {
                playerWins()
                isWar = false
            }
            else if getCardRank(cpuCard!) > getCardRank(playerCard!) {
                cpuWins()
                isWar = false
            }
            // If it is a tie, then it is War time
            else {
                // Show war message
                warBanner.isHidden = false
                // Wait 1.5s the execute
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                    // Hide war message
                    self.warBanner.isHidden = true
                    
                    // Add one more card, face down (not shown), to the current cards played
                    self.cardsPlayed += [self.playerPile[self.playerPile.count - 1], self.cpuPile[self.cpuPile.count - 1]]
                    
                    // Remove those cards from the piles
                    self.playerPile.remove(at: self.playerPile.count - 1)
                    self.cpuPile.remove(at: self.cpuPile.count - 1)
                    
                    // Update the current card images to show the card back
                    self.playerCurrentCard.image = UIImage(named: "back")
                    self.cpuCurrentCard.image = UIImage(named: "back")
                    
                    // Wait another 0.5s then execute
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                        
                        // Run the game logic again
                        play()
                    })
                })
            }
            
            // If no war
            if !isWar {
                // Wait for previous 1.5s delay to finish then execute
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                    // Reset current card images to placeholders
                    self.playerCurrentCard.image = UIImage(named: "placeholder")
                    self.cpuCurrentCard.image = UIImage(named: "placeholder")
                    
                    // Update the current number of cards in the piles
                    self.playerNumberOfCards.text = String(self.playerPile.count)
                    self.cpuNumberOfCards.text = String(self.cpuPile.count)
                    
                })
            }
        }
        
        // Start the main game logic
        play()
        
        // Check if someone won
        // If player won
        if cpuPile.count == 0 {
            // Wait for previous 1.5s delay to finish then execute
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                // Show you won message
                self.youWin.isHidden = false
                
                // Wait 2s then execute
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
                    // Hide you won message and segue back to start view
                    self.youWin.isHidden = true
                    self.performSegue(withIdentifier: "backToStart", sender: self)
                })
            })
        }
        // If player lost
        else if playerPile.count == 0 {
            // Wait for previous 1.5s delay to finish then execute
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
                // Show you lost message
                self.youLose.isHidden = false
                
                // Wait 2s then execute
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000), execute: {
                    // Hide you lost message and segue back to start view
                    self.youLose.isHidden = true
                    self.performSegue(withIdentifier: "backToStart", sender: self)
                })
            })
        }
        
    }
    
    // Run if player wins
    func playerWins() {
        
        // Show player won message
        playerWinsBanner.isHidden = false
        
        // Wait 1.5s then execute
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
            
            // Hide player won message and re-enable deal button
            self.playerWinsBanner.isHidden = true
            self.dealButton.isEnabled = true
        })
        
        // Add cards played to player pile and zero out cards played
        playerPile = cardsPlayed + playerPile
        cardsPlayed = []
    }
    
    // Run if cpu wins
    func cpuWins() {
        
        // Show cpu won message
        cpuWinsBanner.isHidden = false
        
        // Wait 1.5s then execute
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500), execute: {
            
            // Hide cpu won message and re-enable deal button
            self.cpuWinsBanner.isHidden = true
            self.dealButton.isEnabled = true
        })
        
        // Add cards played to player pile and zero out cards played
        cpuPile = cardsPlayed + cpuPile
        cardsPlayed = []
    }
    
    // Get card rank from card name string
    func getCardRank(_ card: String) -> Int {
        let rankString = matches(for: "\\d+$", in: card)
        let rank:Int? = Int(rankString[0])
        return rank!
    }
    
    // This is to make Swift's dumb regex work. This can't be a permenant solution???
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}


//
//  CardStack.swift
//  CardGame
//
//  Created by 심 승민 on 2017. 11. 30..
//  Copyright © 2017년 JK. All rights reserved.
//

import Foundation

// 특정 개수의 카드 뭉치 클래스.
class CardStack: Sequence {
    private(set) var cards: Observable<[Card]>
    let start: Int
    init() {
        self.cards = Observable([])
        self.start = 0
    }

    // 내부 카드들에 접근 가능.
    func makeIterator() -> ClassIteratorOf<Card> {
        return ClassIteratorOf(self.cards.value)
    }
}

extension CardStack: CardGameStack {
    var count: Int {
        return self.cards.value.count
    }
    var isEmpty: Bool {
        return self.cards.value.isEmpty
    }

    func push(card: Card) {
        self.cards.value.append(card)
    }

    func pop() -> Card? {
        return self.cards.value.popLast()
    }

    func peek() -> Card? {
        return self.cards.value.last
    }

    func shuffle() {
        guard let shuffledCards = self.cards.value.shuffle() else { return }
        self.cards = Observable(shuffledCards)
    }

    func reset() {
        self.cards = Observable([])
    }
}

extension CardStack: PokerScoreable {
    // 카드 숫자 기준 오름차순으로 정렬된 카드 배열 반환.
    func sortCards() -> [Card] {
        return self.sorted(by: <)
    }

    // 소유한 카드에서 가장 좋은 패의 랭크 반환.
    func getBestHand() -> PokerHands.HandRanks {
        let hands = PokerHands(sortCards())
        let bestHand = hands.findBestHand()
        return bestHand
    }

    // 정렬된 카드 배열에서 가장 높은 카드 반환.
    func getTopCard() -> Card? {
        return self.sortCards().last
    }

}

// 스택 내의 모든 카드 출력 포맷. [ 카드, 카드, 카드, 카드, 카드 ] 형태.
//extension CardStack: CustomStringConvertible {
//    var description: String {
//        var result = "["
//        for card in self.cards {
//            result += card.frontImageName + ", "
//        }
//        result.removeLast()
//        result.removeLast()
//        result += "]"
//        return result
//    }
//
//}

//
//  CurrencyViewModel.swift
//  CurrencyTools
//
//  Created by Eric on 12/3/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

enum API {
    /// Request supported RatePairs
    static func supportedPairs() -> Observable<[String]> {
        guard let url = URL(string: "https://www.freeforexapi.com/api/live") else {
            return Observable.just([])
        }
        
        return URLSession.shared.rx.json(url: url)
        .catchErrorJustReturn([])
        .map { (json) -> [String] in
                guard let items = json as? [String: Any]  else {
                    return []
                }
                
                guard let supportedPairs = items["supportedPairs"] as? [String] else { return []}
                
            return supportedPairs
        }
    }

    /// Using supported RatePairs for request latest rates
    static func ratepairsBy(pairsKey: [String]) -> Observable<[RatePair]> {
        guard !pairsKey.isEmpty,
            let url = URL(string: "https://www.freeforexapi.com/api/live?pairs=\(pairsKey.joined(separator: ","))") else {
            return Observable.just([])
         }
        
        return URLSession.shared.rx.json(url: url)
        .catchErrorJustReturn([])
            .map { (json) -> [RatePair] in
                guard let items = json as? [String: Any]  else {
                    //return [RatePair.init(pair: "EURUSD", rate: 1.170228 + Double.random(in: -0.1...0.1), timeStamp: Date.init(timeIntervalSince1970: 1532428704963), originalRate: 0)]
                    
                    //MARK: Don't know why API always return null, un-comments code for sim result
                    
                    return []
                }
                
                guard let rates = items["rates"] as? [String: [String: Any]] else {
//                    return [RatePair.init(pair: "EURUSD", rate: 1.170228 + Double.random(in: -0.1...0.1), timeStamp: Date.init(timeIntervalSince1970: 1532428704963), originalRate: 0)]
                    
                    //MARK: Don't know why API always return null, un-comments code for sim result
                    
                    return []
                }
                let flatMapped = rates.compactMap {RatePair(pair: $0.key, rate: $0.value["rate"] as! Double, timeStamp: Date.init(timeIntervalSince1970: $0.value["timestamp"] as! TimeInterval), originalRate: 0) }
                
                
                return flatMapped.sorted { $0.pair < $1.pair }
        }
    }
}

struct TableViewSectionModel {
    var header: BalanceData
    var items: [RatePair]
}

extension TableViewSectionModel: SectionModelType{
    
    init(original: TableViewSectionModel, items: [RatePair]) {
        self = original
        self.items = items
    }
}

final class CurrencyViewModel {
    static private let emptyBalanceData = BalanceData.init(equity: 0, margin: 0, used: 0, balance: 0)
    static private let emptySection = TableViewSectionModel.init(header: CurrencyViewModel.emptyBalanceData, items: [])
    
    
    internal let pairsItem: BehaviorRelay<[RatePair]> = BehaviorRelay(value: [])
    internal let supportedPairs: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    private var originalRates: BehaviorRelay<[String:Double]> = BehaviorRelay(value: [String:Double]())
    
    let sectionsData: BehaviorRelay<[TableViewSectionModel]> = BehaviorRelay.init(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        fetchSupportedPairs()
        supportedPairs.asObservable().subscribe(onNext: { (result) in
            if(!result.isEmpty){
                self.fetchLatestRates()
            }
            }).disposed(by: disposeBag)
        
        
        pairsItem.flatMap(CurrencyViewModel.constructDataBy).asDriver(onErrorJustReturn: []).drive(sectionsData).disposed(by: disposeBag)
    }
    
    func fetchSupportedPairs(){
        API.supportedPairs().asDriver(onErrorJustReturn: []).drive(supportedPairs).disposed(by: disposeBag)
    }
    
    func fetchLatestRates(){
        pairsItem.asObservable()
            .takeWhile({ (_) -> Bool in
                return self.originalRates.value.isEmpty
                //MARK: Only run when never received rates
            })
            .subscribe(onNext: {pairs in
                let originalRateData = pairs.reduce([String:Double]()) { (dict, pair) -> [String:Double] in
                    var dict = dict
                    dict[pair.pair] = pair.rate
                    return dict
                }
                self.originalRates.accept(originalRateData)
                //MARK: Store first time rates, using for comparison of rate change
            })
            .disposed(by: disposeBag)
        
        supportedPairs.flatMap(API.ratepairsBy).flatMap({ (pairs) -> Observable<[RatePair]> in
            let pairWithOriginalRate = pairs.map { (pair) -> RatePair in
                return RatePair(pair: pair.pair, rate: pair.rate, timeStamp: pair.timeStamp, originalRate: self.originalRates.value[pair.pair] ?? 0)
            }
            
            // MARK: Fit original rate to RatePair object for passthrough to Cell
            return Observable.just(pairWithOriginalRate)
        }).asDriver(onErrorJustReturn: []).drive(pairsItem).disposed(by: disposeBag)
    }
    
    static func constructDataBy(ratePairs: [RatePair]) -> Observable<[TableViewSectionModel]>{
        guard !ratePairs.isEmpty else {
            return Observable.just([])
        }
        
        
        let equity = ratePairs.map({($0.rate)*10000}).reduce(0, +)
        
        let balanceData = BalanceData(equity: equity, margin: 10000.0, used: 10000.0, balance: Double(10000 * ratePairs.count))
        //MARK: Margin and Used is placeHolder
        return Observable.just([TableViewSectionModel.init(header: balanceData, items: ratePairs)])
    }
}

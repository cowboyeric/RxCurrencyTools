//
//  CurrencyToolsTests.swift
//  CurrencyToolsTests
//
//  Created by Eric on 12/2/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

@testable import CurrencyTools

class CurrencyToolsTests: XCTestCase {
    
    let disposeBag = DisposeBag()
    var viewController: ViewController!
    
    func testFetchSupportedPair(){
        let expect = expectation(description: "supportedPairs should contain values when viewModel did init")
        
        let viewModel = viewController.viewModel
        viewModel.supportedPairs.asObservable().subscribe(onNext: { (result) in
            if(!result.isEmpty){
                expect.fulfill()
            }
        }).disposed(by: disposeBag)
        
        wait(for: [expect], timeout: 2)
    }
    
    func testFetchLatestRates(){
        let expect = expectation(description: "pairItems should contain values when viewModel did init")
        
        let viewModel = viewController.viewModel
        viewModel.pairsItem.asObservable().subscribe(onNext: { (result) in
            if(!result.isEmpty){
                expect.fulfill()
            }
        }).disposed(by: disposeBag)
        
        wait(for: [expect], timeout: 5)
    }
    
    func testBalanceData(){
        let fetchRatesExpect = expectation(description: "pairItems should contain values when viewModel did init")
        
        let viewModel = viewController.viewModel
        viewModel.pairsItem.asObservable().subscribe(onNext: { (result) in
            if(!result.isEmpty){
                fetchRatesExpect.fulfill()
            }
        }).disposed(by: disposeBag)
        
        let balanceCalculateExpect = expectation(description: "Balance should calculate when pairItems update")
        viewModel.sectionsData.asObservable().subscribe(onNext: { (sectionsData) in
            guard let balanceValue = sectionsData.first?.header.balance else { return }
            guard let equityValue = sectionsData.first?.header.equity else { return }
            if(balanceValue > 0.0 && equityValue > 0.0){
                balanceCalculateExpect.fulfill()
                XCTAssert(balanceValue == Double(viewModel.pairsItem.value.count * 10000), "Balance should be $10,000 USD * Number of forex pairings available, and change after API call")
                
                
                let sum = viewModel.pairsItem.value.reduce(0) { (result: Double, pair: RatePair) in
                    return result + (pair.rate * 10000)
                }
                XCTAssertTrue(equityValue == sum, "Equity is calculated by the current value of your total assets")
            }
            }).disposed(by: disposeBag)
        
         wait(for: [fetchRatesExpect, balanceCalculateExpect], timeout: 10)
    }
    
    override func setUp() {
        self.viewController = ViewController()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

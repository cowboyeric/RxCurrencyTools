//
//  ViewController.swift
//  CurrencyTools
//
//  Created by Eric on 12/2/19.
//  Copyright © 2019 Eric. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    internal let viewModel = CurrencyViewModel()
    private let disposeBag = DisposeBag()
    
    var dataSource:RxTableViewSectionedReloadDataSource<TableViewSectionModel>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Markets"
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindViewModel()
    }
    
    private func registerCell() {
        self.tableView.register(UINib.init(nibName: "CurrencyRateTableViewCell", bundle: nil), forCellReuseIdentifier: "CurrencyRateTableViewCell")
        self.tableView.register(UINib.init(nibName: "CurrencyRateTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CurrencyRateTableHeaderView")
        
        self.tableView.rx
        .setDelegate(self)
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        Observable<Int>.interval(RxTimeInterval.seconds(60), scheduler: MainScheduler())
            .subscribe(onNext: { (state) in
                self.viewModel.fetchLatestRates()
            })
            .disposed(by: disposeBag)
        //MARK: Update each 60 seconds
        
        let dataSource = RxTableViewSectionedReloadDataSource<TableViewSectionModel>(
          configureCell: { dataSource, tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyRateTableViewCell", for: indexPath) as? CurrencyRateTableViewCell else {
                return UITableViewCell()
            }
            cell.ratePair = item
            return cell
        })
        
        self.dataSource = dataSource
        
        viewModel.sectionsData.asDriver().drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        //MARK: Sections data bind to dataSource, dataSource update trigger tableView refresh
    }
}

extension ViewController{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerData = dataSource?[section].header else {return UIView()}
        
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CurrencyRateTableHeaderView") as? CurrencyRateTableHeaderView else {return UIView()}
        
        headerView.balanceData = headerData
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let _ = dataSource?[section].header else {return 0}
        //MARK: No display header when no data ready
        
        
        return 134
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

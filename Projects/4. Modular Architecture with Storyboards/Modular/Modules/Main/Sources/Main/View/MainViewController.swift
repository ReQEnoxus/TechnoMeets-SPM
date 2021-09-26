//
//  MainViewController.swift
//  Modular
//
//  Created by Enoxus on 16.01.2021.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import Models
import UserDetail

public class MainViewController: UIViewController {
    
    public static func instantiate() -> UIViewController? {
        return UIStoryboard(name: "Main", bundle: .module).instantiateInitialViewController()
    }
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()

    @IBOutlet weak var mainTableView: UITableView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBindings()
        viewModel.loadUsers()
    }

    private func setupTableView() {
        mainTableView.tableFooterView = .init()
        mainTableView.register(UINib(nibName: "UserTableViewCell", bundle: .module), forCellReuseIdentifier: "userTableViewCell")
    }
    
    private func setupBindings() {
        viewModel.users.bind(
            to: mainTableView.rx.items(
                cellIdentifier: "userTableViewCell",
                cellType: UserTableViewCell.self
            )
        ) { _, data, cell in
            cell.configure(with: data)
        }.disposed(by: disposeBag)
        
        mainTableView.rx
            .itemSelected
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.performSegue(withIdentifier: "showDetail", sender: self?.viewModel.users.value[$0.row])
            })
            .disposed(by: disposeBag)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showDetail", let user = sender as? UserViewData {
            let destination = segue.destination as! UserDetailViewController
            destination.configure(with: user)
        }
    }
}



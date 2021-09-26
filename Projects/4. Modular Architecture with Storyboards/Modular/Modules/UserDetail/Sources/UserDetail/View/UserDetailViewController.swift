//
//  UserDetailViewController.swift
//  Modular
//
//  Created by Enoxus on 16.01.2021.
//

import UIKit
import RxSwift
import RxCocoa
import Models

public class UserDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var friendRequestButton: UIButton!
    
    private let viewModel = UserDetailViewModel()
    private let disposeBag = DisposeBag()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        viewModel.name.bind(to: nameLabel.rx.text).disposed(by: disposeBag)
        viewModel.username.bind(to: usernameLabel.rx.text).disposed(by: disposeBag)
        viewModel.city.bind(to: cityLabel.rx.text).disposed(by: disposeBag)
        viewModel.email.bind(to: emailLabel.rx.text).disposed(by: disposeBag)
        viewModel.company.bind(to: companyLabel.rx.text).disposed(by: disposeBag)
        
        friendRequestButton.rx
            .tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    public func configure(with data: UserViewData) {
        viewModel.accept(data)
    }
}


//
//  File.swift
//  
//
//  Created by Enoxus on 16.01.2021.
//

import Foundation
import UIKit
import SnapKit

public final class RandomPictureController: UIViewController {
    
    private var currentTask: URLSessionDataTask?
    
    private lazy var getNewPictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.setTitle(NSLocalizedString("button.title", bundle: .module, comment: "Title of the button"), for: .normal)
        
        return button
    }()
    
    private lazy var frameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.image = UIImage(named: "frame", in: .module, compatibleWith: nil)
        
        return imageView
    }()
    
    private lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadNewPicture()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: .module)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        addSubviews()
        makeConstraints()
        setupActions()
    }
    
    private func setupActions() {
        getNewPictureButton.addTarget(self, action: #selector(getNewPictureTouchUpInside), for: .touchUpInside)
    }
    
    private func addSubviews() {
        view.addSubview(frameImageView)
        view.addSubview(contentImageView)
        view.addSubview(getNewPictureButton)
    }
    
    private func makeConstraints() {
        frameImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.size.equalTo(300)
        }
        
        contentImageView.snp.makeConstraints { make in
            make.center.equalTo(frameImageView)
            make.size.equalTo(frameImageView).multipliedBy(0.81)
        }
        
        getNewPictureButton.snp.makeConstraints { make in
            make.width.equalTo(frameImageView)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
            make.top.equalTo(frameImageView.snp.bottom).offset(16)
        }
    }
    
    private func loadNewPicture() {
        guard let url = URL(string: "https://picsum.photos/243") else { return }
        currentTask?.cancel()
        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data,
                  let self = self else { return }
            let image = UIImage(data: data)
            
            DispatchQueue.main.async {
                self.contentImageView.image = image
             }
        }
        currentTask?.resume()
    }
    
    @objc private func getNewPictureTouchUpInside() {
        loadNewPicture()
    }
}

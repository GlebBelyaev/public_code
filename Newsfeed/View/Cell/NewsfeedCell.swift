import Foundation

class NewsfeedCell: UITableViewCell {
    let taskName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let secondLineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let thirdLineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let stackViewH: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        return stack
    }()
    
    let stackViewV: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    let buttonContainer: UIView = UIView()
    
    let statusView: CalendarsButton = {
        let button = CalendarsButton(frame: CGRect(origin: .zero, size: CGSize(width: 67, height: 28)))
        button.isUserInteractionEnabled = false
        
        button.tintColor = .systemGreen
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 5)
        
        button.cornerRadius = 6
        button.backgroundColor = .systemGreen.withAlphaComponent(0.15)
        
        button.setTitle("Task", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        
        return button
    }()
    
    let spaceView1 = UIView()
    let spaceView2 = UIView()
    
    let feedUnderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.cornerRadius = 12
        return view
    }()
    
    let feedStackViewV: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    let feedFirstLine: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    let feedSecondLine: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = .secondaryLabel
        
        return label
    }()
    
    var type: NewsfeedType = .create {
        didSet {
            switch type {
            case .create:
                statusView.tintColor = .systemGreen
                statusView.setImage(UIImage(systemName: "plus"), for: .normal)
                statusView.imageEdgeInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 5)
                
                statusView.cornerRadius = 6
                statusView.backgroundColor = .systemGreen.withAlphaComponent(0.15)
                
                statusView.setTitle("Task", for: .normal)
                statusView.setTitleColor(.systemGreen, for: .normal)
            case .changeStatus:
                statusView.tintColor = .systemOrange
                statusView.setImage(UIImage(systemName: "chevron.up.chevron.down"), for: .normal)
                statusView.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 13), forImageIn: .normal)
                
                statusView.cornerRadius = 6
                statusView.backgroundColor = .systemOrange.withAlphaComponent(0.15)
                
                statusView.setTitle("Status", for: .normal)
                statusView.setTitleColor(.systemOrange, for: .normal)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackViewH)
        
        stackViewV.addArrangedSubview(taskName)
        
        stackViewH.addArrangedSubview(stackViewV)
        
        stackViewH.addArrangedSubview(spaceView2)
        
        buttonContainer.addSubview(statusView)
        stackViewH.addArrangedSubview(buttonContainer)
        
        contentView.addSubview(feedUnderView)
        contentView.addSubview(feedStackViewV)
        
        feedStackViewV.addArrangedSubview(feedFirstLine)
        feedStackViewV.addArrangedSubview(feedSecondLine)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        spaceView2.snp.makeConstraints { make in
            make.width.equalTo(12)
        }
        
        buttonContainer.snp.makeConstraints { make in
            make.width.equalTo(67)
        }
        
        statusView.snp.makeConstraints { make in
            make.width.equalTo(67)
            make.height.equalTo(28)
            make.centerY.equalToSuperview()
        }
        
        stackViewH.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(30)
        }
        
        feedStackViewV.snp.makeConstraints { make in
            make.top.equalTo(stackViewH.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(32)
            make.bottom.equalToSuperview().offset(-24)
            make.right.equalToSuperview().offset(-32)
            make.height.greaterThanOrEqualTo(15)
        }
        
        feedUnderView.snp.makeConstraints { make in
            make.top.equalTo(feedStackViewV.snp.top).offset(-12)
            make.left.equalTo(feedStackViewV.snp.left).offset(-16)
            make.bottom.equalTo(feedStackViewV.snp.bottom).offset(12)
            make.right.equalTo(feedStackViewV.snp.right).offset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSecondLine(text: String) {
        let view = UIView()
        view.snp.makeConstraints { make in
            make.height.equalTo(2)
        }
        
        stackViewV.removeAllArrangedSubviews()
        stackViewV.addArrangedSubview(taskName)
        stackViewV.addArrangedSubview(view)
        stackViewV.addArrangedSubview(secondLineLabel)
        stackViewV.addArrangedSubview(spaceView1)
        secondLineLabel.text = text
    }
    
    func setThirdLine(text: String) {
        let view = UIView()
        view.snp.makeConstraints { make in
            make.height.equalTo(2)
        }
        
        stackViewV.removeAllArrangedSubviews()
        stackViewV.addArrangedSubview(taskName)
        stackViewV.addArrangedSubview(view)
        stackViewV.addArrangedSubview(secondLineLabel)
        stackViewV.addArrangedSubview(thirdLineLabel)
        stackViewV.addArrangedSubview(spaceView1)
        
        thirdLineLabel.text = text
    }
}

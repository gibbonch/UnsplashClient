import UIKit

final class FilterCell: UICollectionViewListCell {
    
    private var model: FilterCellModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ThemeManager.shared.register(self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ThemeManager.shared.unregister(self)
    }
    
    func configure(with model: FilterCellModel) {
        self.model = model
        
        var configuration = UIListContentConfiguration.cell()
        configuration.text = model.filter.text
        configuration.textProperties.font = model.isSelected ? Typography.bodyMedium : Typography.bodySmall
        configuration.textProperties.color = model.isSelected ? Colors.textPrimary : Colors.textSecondary
        
        configuration.image = model.image
        
        configuration.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 8,
            leading: 16,
            bottom: 8,
            trailing: 18
        )
        
        contentConfiguration = configuration
        
        if model.isSelected {
            accessories = [.checkmark(displayed: .always, options: .init(tintColor: Colors.accent))]
        } else {
            accessories = []
        }
        
        applyTheme()
    }
}

// MARK: - Themeable

extension FilterCell: Themeable {
    func applyTheme() {
        var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
        backgroundConfig.backgroundColor = Colors.backgroundSecondary
        backgroundConfiguration = backgroundConfig
        
        if let model = model {
            var currentConfig = contentConfiguration as? UIListContentConfiguration ?? UIListContentConfiguration.cell()
            currentConfig.textProperties.color = model.isSelected ? Colors.textPrimary : Colors.textSecondary
            contentConfiguration = currentConfig
            
            if model.isSelected {
                accessories = [.checkmark(displayed: .always, options: .init(tintColor: Colors.accent))]
            } else {
                accessories = []
            }
        }
    }
}

// MARK: - Model

struct FilterCellModel: Hashable {
    let filter: AnySearchFilter
    let isSelected: Bool
    let image: UIImage?
    
    init(filter: any SearchFilter, isSelected: Bool, image: UIImage? = nil) {
        self.filter = filter.eraseToAnySearchFilter()
        self.isSelected = isSelected
        self.image = image
    }
}

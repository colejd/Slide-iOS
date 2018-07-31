//
//  SelfSizingWaterfallCollectionViewLayout.swift
//
//  Created by Jonathan Cole on 7/26/18.
//
//  This is a port of SelfSizingWaterfallCollectionView by Adam Waite. The original license is as follows:
//
//  Created by Adam Waite on 01/10/2014.
//  Copyright (c) 2014 adamjwaite.co.uk. All rights reserved.
//

import UIKit

fileprivate extension Collection where Element: Numeric {
    func sum() -> Element {
        return self.reduce(0, +)
    }
}

/**
 An object conforming to SelfSizingWaterfallCollectionViewLayoutDelegate may provide layout information for a SelfSizingWaterfallCollectionViewLayout instance. All of the methods in this protocol are optional. If you do not implement a particular method, the layout uses values in its own properties for the appropriate layout information.

 The self sizing waterfall layout object expects the collection view’s delegate object to adopt this protocol. Therefore, implement this protocol on object assigned to your collection view’s delegate property.
 */
@objc protocol SelfSizingWaterfallCollectionViewLayoutDelegate {
    /**
     Asks the delegate for the margins to apply to content in the specified section.

     @param collectionView       The collection view object displaying the waterfall layout.
     @param collectionViewLayout The layout object requesting the information.
     @param section              The section in which the layout information is needed.

     @return The margins to apply to items in the section.
     */
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets

    /**
     Asks the delegate how many columns a section should contain.

     @param collectionView       The collection view object displaying the waterfall layout.
     @param collectionViewLayout The layout object requesting the information.
     @param section              The section in which the layout information is needed.

     @return The number of columns for the section.
     */
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int

    /**
     Asks the delegate for the horizontal spacing between columns.

     @param collectionView       The collection view object displaying the waterfall layout.
     @param collectionViewLayout The layout object requesting the information.
     @param section              The section in which the layout information is needed.

     @return Asks the delegate for the horizontal spacing between columns.
     */
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat

    /**
     Asks the delegate for the vertical spacing between successive items in a column of a section.

     @param collectionView       The collection view object displaying the waterfall layout.
     @param collectionViewLayout The layout object requesting the information.
     @param section              The section in which the layout information is needed.

     @return Vertical spacing between successive items in a column of a section.
     */
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat

    /**
     Asks the delegate for the size of the header view in the specified section.
     @param collectionView       The collection view object displaying the waterfall layout.
     @param collectionViewLayout The layout object requesting the information.
     @param section              The section in which the layout information is needed.

     @note A value returned by `preferredLayoutAttributesFittingAttributes:` would have ideally determined the final layout but self sizing hasn't hasn't been implemented by Apple for supplementary views as far as I can tell, so this value is final...

     @return The size of the header view in the specified section
     */
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize

    /**
     Asks the delegate for the size of the footer view in the specified section.

     @param collectionView       The collection view object displaying the waterfall layout.
     @param collectionViewLayout The layout object requesting the information.
     @param section              The section in which the layout information is needed.

     @note A value returned by `preferredLayoutAttributesFittingAttributes:` would have ideally determined the final layout but self sizing hasn't hasn't been implemented by Apple for supplementary views as far as I can tell, so this value is final...

     @return The size of the footer view in the specified section
     */
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize

    /**
     Asks the delegate for an estimate of the height of the specified item’s cell for a preliminary layout pass.

     @note For apps requiring iOS7 compatibility, use this method to return a final value rather than an estimate.

     @param collectionView       The collection view object displaying the waterfall layout.
     @param collectionViewLayout The layout object requesting the information.
     @param indexPath            The indexPath in which the layout information is needed.

     @return An estimate of the height for the cell at the indexPath.
     */
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, estimatedHeightForItemAtIndexPath indexPath: IndexPath) -> CGFloat

}

/**
 SelfSizingWaterfallCollectionViewLayout is a concrete layout object that organizes items into a grid of variable columnns with optional header and footer views for each section. The items in the collection view flow from one row or column to the next, with each item being placed beneath the shortest column in the section (as if you're winning at Tetris upside-down). Collection view items can be the same size or different sizes and should implement `preferredLayoutAttributesFittingAttributes:` to provide final layout information.
 */
class SelfSizingWaterfallCollectionViewLayout: UICollectionViewLayout {

    func reset() {
//        prepare()
//        invalidateLayout()
    }

    weak var delegate: SelfSizingWaterfallCollectionViewLayoutDelegate?

    var numberOfSections: Int {
        return collectionView?.numberOfSections ?? 1
    }

    /**
     The margins used to lay out content in a section. Default: UIEdgeInsetsZero.
     */
    var sectionInset: UIEdgeInsets = .zero {
        didSet {
            if !UIEdgeInsetsEqualToEdgeInsets(sectionInset, oldValue) {
                invalidateLayout()
            }
        }
    }

    /**
     The number of columns in the layout. Default: 2.
     */
    var numberOfColumns: Int = 2 {
        didSet {
            if numberOfColumns != oldValue {
                invalidateLayout()
            }
        }
    }

    /**
     The minimum spacing to use between items in the same row. Default: 8.0f;
     */
    var minimumInteritemSpacing: CGFloat = 8.0 {
        didSet {
            if minimumInteritemSpacing != oldValue {
                invalidateLayout()
            }
        }
    }

    /**
     The minimum spacing to use between lines of items in the layout. Default: 8.0f;
     */
    var minimumLineSpacing: CGFloat = 8.0 {
        didSet {
            if minimumLineSpacing != oldValue {
                invalidateLayout()
            }
        }
    }

    /**
     The size for collection view headers. Default: CGSizeZero;

     @note A value returned by `preferredLayoutAttributesFittingAttributes:` should determine the final value but it appears Apple haven't implemented self sizing for supplementaries...? Meaning that this value is final unless the delegate implements `collectionView:layout:referenceSizeForHeaderInSection:`
     */
    var headerReferenceSize: CGSize = .zero {
        didSet {
            if headerReferenceSize != oldValue {
                invalidateLayout()
            }
        }
    }

    /**
     The size for collection view footers. Default: CGSizeZero;

     @note A value returned by `preferredLayoutAttributesFittingAttributes:` should determine the final value but it appears Apple haven't implemented self sizing for supplementaries...? Meaning that this value is final unless the delegate implements `collectionView:layout:referenceSizeForFooterInSection:`
     */
    var footerReferenceSize: CGSize = .zero {
        didSet {
            if footerReferenceSize != oldValue {
                invalidateLayout()
            }
        }
    }

    /**
     An estimate for an item's height for use in a preliminary layout. A value returned by `preferredLayoutAttributesFittingAttributes:` in a UICollectionViewCell will take precedence over this value. Default: 200.0f.
     */
    var estimatedItemHeight: CGFloat = 200.0 {
        didSet {
            if estimatedItemHeight != oldValue {
                invalidateLayout()
            }
        }
    }

    // MARK: -
    // MARK: Init

    override init() {
        super.init()
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        // TODO: He sets up defaults here but they're already done in Swift at declaration time.

    }

    // MARK: -
    // MARK: Accessors

    // MARK: Delegate

//    func delegate() -> SelfSizingWaterfallCollectionViewLayoutDelegate? {
//        return collectionView?.delegate as? SelfSizingWaterfallCollectionViewLayoutDelegate
//    }

    // MARK: Layout Properties and Convenient Access

    func sectionInsets(inSection section: Int) -> UIEdgeInsets {
        return collectionView.flatMap { delegate?.collectionView?($0, layout: self, insetForSectionAtIndex: section) } ?? sectionInset
    }

    func numberOfColumns(inSection section: Int) -> Int {
        return collectionView.flatMap { delegate?.collectionView?($0, layout: self, numberOfColumnsInSection: section) } ?? numberOfColumns
    }

    func minimumInteritemSpacing(inSection section: Int) -> CGFloat {
        return collectionView.flatMap { delegate?.collectionView?($0, layout: self, minimumInteritemSpacingForSectionAtIndex: section) } ?? minimumInteritemSpacing
    }

    func minimumLineSpacing(inSection section: Int) -> CGFloat {
        return collectionView.flatMap { delegate?.collectionView?($0, layout: self, minimumLineSpacingForSectionAtIndex: section) } ?? minimumLineSpacing
    }

    func headerReferenceSize(inSection section: Int) -> CGSize {
        return collectionView.flatMap { delegate?.collectionView?($0, layout: self, referenceSizeForHeaderInSection: section) } ?? headerReferenceSize
    }

    func footerReferenceSize(inSection section: Int) -> CGSize {
        return collectionView.flatMap { delegate?.collectionView?($0, layout: self, referenceSizeForFooterInSection: section) } ?? footerReferenceSize
    }

    func estimatedItemHeightForItem(atIndexPath indexPath: IndexPath) -> CGFloat {
        return collectionView.flatMap { delegate?.collectionView?($0, layout: self, estimatedHeightForItemAtIndexPath: indexPath) } ?? estimatedItemHeight
    }

    // MARK: Internal State

    private var _columnHeights: [[CGFloat]] = []
    var columnHeights: [[CGFloat]] {
        get {
            if _columnHeights.isEmpty {
                for section in 0 ..< numberOfSections {
                    let numberOfColumns: Int = self.numberOfColumns(inSection: section)
                    _columnHeights.append(Array(repeating: 0, count: numberOfColumns))
                }
            }
            return _columnHeights
        }
        set {
            _columnHeights = newValue
        }
    }

    var headerAttributes: [UICollectionViewLayoutAttributes?] = []
    var footerAttributes: [UICollectionViewLayoutAttributes?] = []

    var allItemAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    var preferredItemAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]

    // MARK: -
    // MARK: Layout Preparation

    override func prepare() {
        super.prepare()

        if allItemAttributes.keys.isEmpty {
            resetColumnHeights()

            for section in 0 ..< numberOfSections {
                prepareSection(section: section)
            }
        }
    }

    func resetColumnHeights() {

        columnHeights.removeAll()
        allItemAttributes.removeAll()

        // TODO: Probably don't need these.
        headerAttributes.removeAll()
        footerAttributes.removeAll()

        headerAttributes = Array(repeating: nil, count: numberOfSections)
        footerAttributes = Array(repeating: nil, count: numberOfSections)

    }

    func prepareSection(section: Int) {

        // TODO: Guard collectionview here?

        let numberOfColumns = self.numberOfColumns(inSection: section)
        let reverseTetrisPoint: CGFloat = self.allSectionHeights().sum()

        let topInset = sectionInsets(inSection: section).top
        for column in 0 ..< numberOfColumns {
            appendHeight(topInset, toColumn: column, inSection: section)
        }

        let headerSize = headerReferenceSize(inSection: section)
        if headerSize.height > 0 {

            let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
            headerAttributes.frame = CGRect(x: 0, y: reverseTetrisPoint, width: headerSize.width, height: headerSize.height)
            for column in 0 ..< numberOfColumns {
                appendHeight(headerSize.height, toColumn: column, inSection: section)
            }
            self.headerAttributes[section] = headerAttributes
        }

        let leftInset: CGFloat = sectionInsets(inSection: section).left
        let rightInset: CGFloat = sectionInsets(inSection: section).right
        let cellContentAreaWidth: CGFloat = (collectionView?.frame.width ?? CGFloat(0)) - (leftInset + rightInset)
        let numberOfGutters: CGFloat = CGFloat(numberOfColumns - 1)
        let singleGutterWidth: CGFloat = minimumInteritemSpacing(inSection: section)
        let totalGutterWidth: CGFloat = singleGutterWidth * numberOfGutters
        let minimumLineSpacing: CGFloat = self.minimumLineSpacing(inSection: section)
        let itemCount: Int = collectionView?.numberOfItems(inSection: section) ?? 0
        let itemWidth: CGFloat = ((cellContentAreaWidth - totalGutterWidth) / CGFloat(numberOfColumns)).rounded(.down)

        for item in 0 ..< itemCount {
            let indexPath = IndexPath(item: item, section: section)
            let shortestColumnIndex = self.shortestColumn(inSection: section)
            let xOffset = leftInset + ((itemWidth + singleGutterWidth) * CGFloat(shortestColumnIndex))
            let yOffset = reverseTetrisPoint + shortestColumnHeight(inSection: section)

            var itemHeight = estimatedItemHeightForItem(atIndexPath: indexPath)

            if let preferredAttributes = self.preferredItemAttributes[indexPath] {
                itemHeight = preferredAttributes.size.height
            }

            let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            cellAttributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)

            appendHeight((cellAttributes.frame.height + minimumLineSpacing).rounded(.up), toColumn: shortestColumnIndex, inSection: section)
            self.allItemAttributes[indexPath] = cellAttributes
        }

        let bottomInset = sectionInsets(inSection: section).bottom
        for column in 0 ..< numberOfColumns {
            appendHeight(bottomInset, toColumn: column, inSection: section)
        }

        let otherReverseTetrisPoint = allSectionHeights().sum()

        let footerSize = footerReferenceSize(inSection: section)

        if footerSize.height > 0 {
            let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
            footerAttributes.frame = CGRect(x: 0, y: otherReverseTetrisPoint, width: footerSize.width, height: footerSize.height)
            for column in 0 ..< numberOfColumns {
                appendHeight(footerSize.height, toColumn: column, inSection: section)
            }
            self.footerAttributes[section] = footerAttributes
        }

    }

    // MARK: -
    // MARK: Provide Layout

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesForElementsInRect: [UICollectionViewLayoutAttributes] = []

        allItemAttributes.values.forEach { layoutAttributes in
            if rect.intersects(layoutAttributes.frame) {
                layoutAttributesForElementsInRect.append(layoutAttributes)
            }
        }

        headerAttributes.forEach { layoutAttributes in
            if let layoutAttributes = layoutAttributes {
                if rect.intersects(layoutAttributes.frame) {
                    layoutAttributesForElementsInRect.append(layoutAttributes)
                }
            }
        }

        footerAttributes.forEach { layoutAttributes in
            if let layoutAttributes = layoutAttributes {
                if rect.intersects(layoutAttributes.frame) {
                    layoutAttributesForElementsInRect.append(layoutAttributes)
                }
            }
        }

        return layoutAttributesForElementsInRect
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return allItemAttributes[indexPath]
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeader {
            return headerAttributes[indexPath.section]
        }

        if elementKind == UICollectionElementKindSectionFooter {
            return footerAttributes[indexPath.section]
        }

        return nil
    }

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }

        var contentSize: CGSize = collectionView.bounds.size

        if columnHeights.isEmpty {
            return contentSize
        }

        contentSize.height = allSectionHeights().sum()

        return contentSize
    }

    // MARK: -
    // MARK: Calculation and Utility

    func columnHeights(inSection section: Int) -> [CGFloat] {
        return self.columnHeights[section]
    }

    func shortestColumnHeight(inSection section: Int) -> CGFloat {
        return columnHeights(inSection: section).min() ?? 0
    }

    func shortestColumn(inSection section: Int) -> Int {
        let shortestHeight = shortestColumnHeight(inSection: section)
        return columnHeights(inSection: section).index(of: shortestHeight) ?? 0
    }

    func largestColumnHeight(inSection section: Int) -> CGFloat {
        return columnHeights(inSection: section).max() ?? 0
    }

    func largestColumn(inSection section: Int) -> Int {
        let largestHeight = largestColumnHeight(inSection: section)
        return columnHeights(inSection: section).index(of: largestHeight) ?? 0
    }

    func appendHeight(_ height: CGFloat, toColumn column: Int, inSection section: Int) {
        columnHeights[section][column] += height
    }

    func sectionHeight(_ section: Int) -> CGFloat {
        return largestColumnHeight(inSection: section)
    }

    func allSectionHeights() -> [CGFloat] {
        return (0 ..< numberOfSections).map { section -> CGFloat in
            return sectionHeight(section)
        }
    }

    // MARK: -
    // MARK: Self Sizing Cells

    // TODO: look into this, this is where it starts to ask for preferredLayoutAttributesFitting
    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {

        if preferredAttributes.representedElementCategory == .cell {
            preferredItemAttributes[preferredAttributes.indexPath] = preferredAttributes
        }

        return preferredAttributes.size.height != originalAttributes.size.height
    }

    // TODO: This function does nothing the way it's written.
    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {

        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
        context.invalidateEverything // TODO: This doesn't do anything

        return context
    }

    // MARK: -
    // MARK: Invalidation

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // TODO: Maybe only check width
        return collectionView.flatMap { newBounds.width != $0.frame.width } ?? false
//        return false
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)

        resetColumnHeights()

        for section in 0 ..< numberOfSections {
            prepareSection(section: section)
        }
    }

}

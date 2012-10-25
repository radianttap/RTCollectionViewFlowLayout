//
//  RTCollectionViewFlowLayout.m
//  RTCollectionViewFlowLayout
//
//  Created by Aleksandar Vacić on 28.9.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import "RTCollectionViewFlowLayout.h"

NSString *const RTCollectionElementKindGlobalHeader = @"RTCollectionElementKindGlobalHeader";
NSString *const RTCollectionElementKindGlobalFooter = @"RTCollectionElementKindGlobalFooter";

//	PRIVATE API
@interface RTCollectionViewFlowLayout()

@property (nonatomic) CGRect globalHeaderFrame;
@property (nonatomic) CGRect globalFooterFrame;

@property (nonatomic) CGSize originalContentSize;
@property (nonatomic) CGSize newContentSize;

@end

#pragma mark -

@implementation RTCollectionViewFlowLayout

-(id)init {
	self = [super init];

	if (self) {
		self.globalHeaderReferenceSize = CGSizeZero;
		self.globalFooterReferenceSize = CGSizeZero;
		self.originalContentSize = CGSizeZero;
		self.newContentSize = CGSizeZero;
	}

	return self;
}

#pragma mark - Layout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {

	NSMutableArray *layoutAttributesArray = [NSMutableArray array];

	//	header
	CGRect normalizedHeaderFrame = self.globalHeaderFrame;
	if (CGRectIntersectsRect(normalizedHeaderFrame, rect)) {
		UICollectionViewLayoutAttributes *layoutAttributes;
		layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:RTCollectionElementKindGlobalHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
		layoutAttributes.frame = normalizedHeaderFrame;
		[layoutAttributesArray addObject:layoutAttributes];
	}
	
	//	adjust returned frames
	BOOL isHorizontal = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
	NSArray *laArray = [super layoutAttributesForElementsInRect:rect];
	for (UICollectionViewLayoutAttributes *la in laArray) {
		CGRect f = la.frame;
		if (isHorizontal) {
			f.origin.x += self.globalHeaderFrame.origin.x + self.globalHeaderFrame.size.width;
		} else {
			f.origin.y += self.globalHeaderFrame.origin.y + self.globalHeaderFrame.size.height;
		}
		la.frame = f;
		[layoutAttributesArray addObject:la];
	}
	
	//	footer
	CGRect normalizedFooterFrame = self.globalFooterFrame;
	if (CGRectIntersectsRect(normalizedFooterFrame, rect)) {
		UICollectionViewLayoutAttributes *layoutAttributes;
		layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:RTCollectionElementKindGlobalFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
		layoutAttributes.frame = normalizedFooterFrame;
		[layoutAttributesArray addObject:layoutAttributes];
	}

	return layoutAttributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

	UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
	
	if ([kind isEqualToString:RTCollectionElementKindGlobalHeader]) {
		layoutAttributes.frame = self.globalHeaderFrame;

	} else if ([kind isEqualToString:RTCollectionElementKindGlobalFooter]) {
		layoutAttributes.frame = self.globalFooterFrame;
			
	} else {
		//	make room for header frame
		BOOL isHorizontal = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
		CGRect f = layoutAttributes.frame;
		if (isHorizontal) {
			f.origin.x += self.globalHeaderFrame.origin.x + self.globalHeaderFrame.size.width;
		} else {
			f.origin.y += self.globalHeaderFrame.origin.y + self.globalHeaderFrame.size.height;
		}
		layoutAttributes.frame = f;

	}

	return layoutAttributes;
}

- (CGSize)collectionViewContentSize {
	return self.newContentSize;
}

#pragma mark - Invalidating the Layout

- (void)invalidateLayout {
	//	use this method to clear any cached layout data
	[super invalidateLayout];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
	return [super shouldInvalidateLayoutForBoundsChange:newBounds];

	// we need to recalculate on width changes
//	if ((self.collectionView.bounds.size.width != newBounds.size.width && self.scrollDirection == UICollectionViewScrollDirectionHorizontal) || (self.collectionView.bounds.size.height != newBounds.size.height && self.scrollDirection == UICollectionViewScrollDirectionVertical)) {
//		return YES;
//	}
//	return NO;
}

// return a point at which to rest after scrolling - for layouts that want snap-to-point scrolling behavior
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
	return proposedContentOffset;
}

- (void)prepareLayout {
	[super prepareLayout];

	[self fetchItemsInfo];

}

#pragma mark - Private

- (void)fetchItemsInfo {
	[self getSizingInfos];

	[self updateItemsLayout];
}

//	get size of all items, if delegate has supplied them
- (void)getSizingInfos {
	
	BOOL isHorizontal = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
	
	//	adjust header/footer frames to span entire respective dimension of the collection view
	if (isHorizontal) {
		self.globalHeaderReferenceSize = CGSizeMake(self.globalHeaderReferenceSize.width, self.collectionView.bounds.size.height);
		self.globalFooterReferenceSize = CGSizeMake(self.globalFooterReferenceSize.width, self.collectionView.bounds.size.height);
	} else {
		self.globalHeaderReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, self.globalHeaderReferenceSize.height);
		self.globalFooterReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, self.globalFooterReferenceSize.height);
	}

	self.globalHeaderFrame = (CGRect){.size=self.globalHeaderReferenceSize};
	self.globalFooterFrame = (CGRect){.size=self.globalFooterReferenceSize};
}

- (void)updateItemsLayout {
	CGSize originalContentSize = [super collectionViewContentSize];
	self.originalContentSize = originalContentSize;

	BOOL isHorizontal = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);

	CGSize contentSize = originalContentSize;

	//	global header
	if (isHorizontal) {
		contentSize.width += self.globalHeaderFrame.size.width;
		contentSize.height = fmaxf(contentSize.height, self.globalHeaderFrame.size.height);
	} else {
		contentSize.width = fmaxf(contentSize.width, self.globalHeaderFrame.size.width);
		contentSize.height += self.globalHeaderFrame.size.height;
	}


	//	global footer
	CGPoint footerOrigin = CGPointZero;
	if (isHorizontal) {
		footerOrigin.x = contentSize.width;
		contentSize.width += self.globalFooterFrame.size.width;
		contentSize.height = fmaxf(contentSize.height, self.globalFooterFrame.size.height);
	} else {
		footerOrigin.y = contentSize.height;
		contentSize.width = fmaxf(contentSize.width, self.globalFooterFrame.size.width);
		contentSize.height += self.globalFooterFrame.size.height;
	}
	self.globalFooterFrame = (CGRect){.origin=footerOrigin, .size=self.globalFooterFrame.size};
	
	self.newContentSize = contentSize;
}

@end
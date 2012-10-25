//
//  RTCollectionViewFlowLayout.h
//  RTCollectionViewFlowLayout
//
//  Created by Aleksandar Vacić on 28.9.12..
//  Copyright (c) 2012. Aleksandar Vacić. All rights reserved.
//

#import <UIKit/UIKit.h>

//	supplementary views
UIKIT_EXTERN NSString *const RTCollectionElementKindGlobalHeader;
UIKIT_EXTERN NSString *const RTCollectionElementKindGlobalFooter;


@class RTCollectionViewFlowLayout;

//	PUBLIC API
@interface RTCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (nonatomic) CGSize globalHeaderReferenceSize;						//	default is Zero, can be only one header
@property (nonatomic) CGSize globalFooterReferenceSize;						//	default is Zero, can be only one footer

@end



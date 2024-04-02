//
//  ZEDCurrentBookshelfViewOutput.h
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZEDDataSourceProtocol.h"
#import <UIKit/UIKit.h>

@protocol ZEDCurrentBookshelfViewOutput <ZEDDataSourceProtocol>

- (void)didTriggerViewReadyEvent;

- (void)needOpenAboutBookWithIndexPath:(NSIndexPath *)indexPath;
- (void)needMarkedAsReadBookWithIndexPath:(NSIndexPath *)indexPath;
- (NSArray *)needRemoveBooksAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)returnDeletedBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect;
- (void)completeRemoveBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect;
- (void)takeOffBooksAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths afterMultiSelect:(BOOL)multiSelect;
- (void)userDidSelectBookAtIndexPath:(NSIndexPath *)indexPath fromFrame:(CGRect)frame;

- (void)removeCurrentBookshelf;
- (void)updateTitleBookshelf:(NSString *)title;
- (void)updateHiddenBooksState;

- (NSString *)titleBookshelf;

- (BOOL)isHiddenBooks;
- (BOOL)canDeleteBookshelf;
- (BOOL)shelfWithMarkedReadBooks;

@property (nonatomic, assign) BOOL viewAppeared;

@end

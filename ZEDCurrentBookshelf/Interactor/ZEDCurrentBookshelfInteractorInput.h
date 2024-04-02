//
//  ZEDCurrentZEDBookshelfInteractorInput.h
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZEDBookViewProtocol;
@class ZEDBook, ZEDBookshelf;

@protocol ZEDCurrentBookshelfInteractorInput <NSObject>

- (void)updateTitle:(NSString *)newTitle forBookshelf:(ZEDBookshelf *)bookshelf;
- (void)withdrawBooks:(NSArray *)books fromBookshelf:(ZEDBookshelf *)bookshelf;
- (void)addBooks:(NSArray *)books onBookshelf:(ZEDBookshelf *)bookshelf;
- (void)changeHiddenBooksStateForBookshelf:(ZEDBookshelf *)bookshelf;
- (void)removeBookshelf:(ZEDBookshelf *)bookshelf;

- (void)markedAsReadBook:(ZEDBook *)book;
- (void)markBook:(NSArray *)books asDeleted:(BOOL)deleted;
- (void)removeBooks:(NSArray *)books;

// analytics
- (void)analyticsDeleteBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect fromShelf:(ZEDBookshelf *)shelf;
- (void)analyticsTakeOffBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect fromShelf:(ZEDBookshelf *)shelf;
- (void)analyticsCancelDeleteBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect;
- (void)analyticsDeleteBookshelf:(ZEDBookshelf *)shelf;
- (void)analyticsHiddenBooksOnBookshelf:(ZEDBookshelf *)shelf;
- (void)analyticsOpenBook:(ZEDBook *)book;

@end

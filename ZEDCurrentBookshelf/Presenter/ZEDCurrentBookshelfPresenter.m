//
//  ZEDCurrentBookshelfPresenter.m
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import "ZEDCurrentBookshelfPresenter.h"

#import "ZEDCurrentBookshelfViewInput.h"
#import "ZEDCurrentBookshelfInteractorInput.h"
#import "ZEDCurrentBookshelfRouterInput.h"

#import "ZEDAboutBookModuleOutput.h"

#import "ZEDBook.h"
#import "ZEDAuthor.h"
#import "ZEDBookshelf.h"
#import "ZEDServerBook.h"

#import "ZEDGlobals.h"

#import "ZEDNotificationManager.h"
#import "ZEDAppPreferencesProtocol.h"
#import <Typhoon/TyphoonAutoInjection.h>

@interface ZEDCurrentBookshelfPresenter() <ZEDAboutBookModuleOutput>

@property (strong, nonatomic) ZEDBookshelf *bookshelf;
@property (strong, nonatomic) NSMutableArray *books;

@property (nonatomic, weak) InjectedClass(ZEDNotificationManager) notifyManager;
@property (nonatomic, weak) InjectedProtocol(ZEDAppPreferencesProtocol) appPreferences;

@end

@implementation ZEDCurrentBookshelfPresenter

#pragma mark - Методы ZEDCurrentZEDBookshelfModuleInput

- (void)configureModuleWithBookshelf:(ZEDBookshelf *)bookshelf {
    self.bookshelf = bookshelf;
    self.books = bookshelf.books;
}

#pragma mark - Методы ZEDCurrentZEDBookshelfViewOutput

- (void)didTriggerViewReadyEvent {
    [self.view setupInitialState];
}

- (BOOL)isHiddenBooks {
    return self.bookshelf.hiddenBooks;
}

- (BOOL)canDeleteBookshelf {
    return (self.bookshelf.type != ZEDBookshelfReadType);
}

- (BOOL)shelfWithMarkedReadBooks {
    return self.bookshelf.shelfWithMarkedReadBooks;
}

- (void)updateHiddenBooksState {
    [self.interactor changeHiddenBooksStateForBookshelf:self.bookshelf];
    [self.interactor analyticsHiddenBooksOnBookshelf:self.bookshelf];
}

- (NSString *)titleBookshelf {
    if (self.bookshelf.shelfWithMarkedReadBooks) {
        return [NSString stringWithFormat:@"     %@", self.bookshelf.name];
    }
    return self.bookshelf.name;
}

- (void)updateTitleBookshelf:(NSString *)title {
    [self.interactor updateTitle:title forBookshelf:self.bookshelf];
}

- (void)removeCurrentBookshelf {
    [self.interactor removeBookshelf:self.bookshelf];
    [self.moduleOutput needReloadBookshelves];
}

- (void)needMarkedAsReadBookWithIndexPath:(NSIndexPath *)indexPath {
    ZEDBook *book = self.books[indexPath.row];
    [self.interactor markedAsReadBook:book];
    
    if (self.bookshelf.shelfWithMarkedReadBooks && book) {
        [self.interactor withdrawBooks:@[book] fromBookshelf:self.bookshelf];
        [self.view updateCollections];
    }
}

- (NSArray *)needRemoveBooksAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray *selectedBooks = [NSMutableArray new];
    for (NSIndexPath *indexPath in indexPaths) {
        id book = [self objectAtIndexPath:indexPath];
        if (book) [selectedBooks addObject:book];
    }
    
    [self.view setEditing:NO];
    
    [self.interactor markBook:selectedBooks asDeleted:YES];
    [self.books removeObjectsInArray:selectedBooks];
    
    [self.view updateCollections];
    return selectedBooks;
}

- (void)returnDeletedBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect {
    [self.interactor markBook:books asDeleted:NO];
    [self.interactor analyticsCancelDeleteBooks:books afterMultiSelect:multiSelect];
    
    [self.books addObjectsFromArray:books];
    NSArray *descriptors = self.appPreferences.booksFilter.sortDescriptions;
    [self.books sortUsingDescriptors:descriptors];
    
    [self.view updateCollections];
    
    if (!self.viewAppeared) {
        [self.moduleOutput needReloadLastReadBook];
        [self.moduleOutput needReloadBookshelves];
        [self.moduleOutput needReloadBooks];
    }
}

- (void)completeRemoveBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect {
    [self.interactor removeBooks:books];
    [self.interactor analyticsDeleteBooks:books afterMultiSelect:multiSelect fromShelf:self.bookshelf];
}

- (void)takeOffBooksAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths afterMultiSelect:(BOOL)multiSelect {
    NSMutableArray *selectedBooks = [NSMutableArray new];
    for (NSIndexPath *indexPath in indexPaths) {
        id book = [self objectAtIndexPath:indexPath];
        if (book) [selectedBooks addObject:book];
    }
    
    [self.interactor withdrawBooks:selectedBooks fromBookshelf:self.bookshelf];
    [self.interactor analyticsTakeOffBooks:selectedBooks afterMultiSelect:multiSelect fromShelf:self.bookshelf];
    
    [self.view updateCollections];
    [self.view setEditing:NO];
    
    NSString *format = self.bookshelf.shelfWithMarkedReadBooks ? @"books removed from shelf Finished" : @"books removed from shelf";
    NSString *message = [NSString stringWithFormat:NSLocalizedString(format, nil), selectedBooks.count];
    [self.notifyManager scheduleNotificationWithType:ZEDNotificationNeutralType andMessage:message];
}

- (void)userDidSelectBookAtIndexPath:(NSIndexPath *)indexPath fromFrame:(CGRect)frame {
    ZEDBook *book = [self objectAtIndexPath:indexPath];
    [self needOpenBook:book withCoverFrame:frame];
}

- (void)needOpenBook:(ZEDBook *)book withCoverFrame:(CGRect)frame {
    if (!book.existsFile) return;
    
    [self.interactor analyticsOpenBook:book];
    [self.router openReaderWithBook:book fromFrame:frame];
}

- (void)needRemoveBook:(ZEDBook *)book {
    if ([self.books containsObject:book]) {
        [self.books removeObject:book];
    }
}

- (void)markAsReadWasUpdateForBook:(ZEDBook *)book {
    if (!self.bookshelf.shelfWithMarkedReadBooks || !book) return;
    
    if (book.markedRead) {
        [self.interactor addBooks:@[book]
                      onBookshelf:self.bookshelf];
    } else {
        [self.interactor withdrawBooks:@[book]
                         fromBookshelf:self.bookshelf];
    }
}

- (void)needOpenAboutBookWithIndexPath:(NSIndexPath *)indexPath {
    ZEDBook *book = [self objectAtIndexPath:indexPath];
    [self.router openAboutBookModuleWithBook:book];
}


#pragma mark - Методы ZEDDataSourceProtocol
- (NSIndexPath *)indexPathOfObject:(id)object {
    NSInteger index = [self.books indexOfObject:object];
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:0];
    }
    return nil;
}

- (BOOL)isEmpty {
    return !self.books.count;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.books.count)
        return self.books[indexPath.row];
    return nil;
}

- (void)updateAll {
    
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return self.books.count;
}

- (NSInteger)numberOfSections {
    return 1;
}

@synthesize viewAppeared;

@end

//
//  ZEDCurrentZEDBookshelfInteractor.m
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import "ZEDCurrentBookshelfInteractor.h"
#import "ZEDAnalyticsServiceImp.h"
#import "ZEDCurrentBookshelfInteractorOutput.h"
#import "ZEDBStatisticConstants.h"
#import "ZEDAuthor.h"
#import "ZEDImage.h"
#import "ZEDGlobals.h"

#import "ZEDAnalyticsService.h"
#import "ZEDDataStorageService.h"
#import "ZEDAppPreferencesProtocol.h"
#import <Typhoon/TyphoonAutoInjection.h>

#import "NSArray+Amplitude.h"
#import "ZEDBook+Amplitude.h"
#import "ZEDBookshelf+Amplitude.h"

@interface ZEDCurrentBookshelfInteractor ()

@property (nonatomic, weak) InjectedProtocol(ZEDAnalyticsService) analytics;
@property (nonatomic, weak) InjectedProtocol(ZEDDataStorageService) storage;
@property (nonatomic, weak) InjectedProtocol(ZEDAppPreferencesProtocol) appPreferences;

@end

@implementation ZEDCurrentBookshelfInteractor

#pragma mark - Методы ZEDCurrentZEDBookshelfInteractorInput

- (void)removeBooks:(NSArray *)books {
    [self.storage deleteBooks:books];
}

- (void)markedAsReadBook:(ZEDBook *)book {
    [self.storage markedAsReadBook:book];
}

- (void)markBook:(NSArray *)books asDeleted:(BOOL)deleted {
    [self.storage markBooks:books asDeleted:deleted];
}

- (void)withdrawBooks:(NSArray *)books fromBookshelf:(ZEDBookshelf *)bookshelf {
    for (ZEDBook *book in books) {
        for (ZEDBook *bookOnBookshlef in [bookshelf.books copy]) {
            if ([book.uuid isEqualToString:bookOnBookshlef.uuid]) {
                [bookshelf.books removeObject:bookOnBookshlef];
                [self.analytics sendActionWithActioncategory:CATEGORY_BOOK_ON_BOOKSHELF
                                                      action:ACTION_WITHDRAW_BOOKSHELF
                                                       label:book.fullNameWithAuthor
                                                       value:nil];
            }
        }
    }
    
    [self.storage updateBookshelf:bookshelf];
}

- (void)addBooks:(NSArray *)books onBookshelf:(ZEDBookshelf *)bookshelf {
    for (ZEDBook *book in books) {
        if (![bookshelf.books containsObject:book]) {
            [bookshelf.books addObject:book];
        }
    }
    
    [self.storage updateBookshelf:bookshelf];
}

- (void)updateTitle:(NSString *)newTitle forBookshelf:(ZEDBookshelf *)bookshelf {
    if (![bookshelf.name isEqualToString:newTitle]) {
        NSString *label = [NSString stringWithFormat:@"%@ — %@", bookshelf.name, newTitle];
        [self.analytics sendActionWithActioncategory:CATEGORY_ADD_BOOKSHELF action:ACTION_EDIT_BOOKSHELF_NAME label:label value:nil];
        
        NSMutableDictionary *properties = [bookshelf amplitudeShelfRenamePropertiesOldName:bookshelf.name andNewName:newTitle];
        [self.analytics amplitudeLogUpdateShelfWithProperties:properties];
        
        bookshelf.name = newTitle;
        [self.storage updateBookshelf:bookshelf];
    }
}

- (void)removeBookshelf:(ZEDBookshelf *)bookshelf {
    [self.storage deleteBookshelf:bookshelf];
}

- (void)changeHiddenBooksStateForBookshelf:(ZEDBookshelf *)bookshelf {
    bookshelf.hiddenBooks = !bookshelf.hiddenBooks;
    [self.storage updateBookshelf:bookshelf];
}

#pragma mark - analytics
- (void)analyticsDeleteBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect fromShelf:(ZEDBookshelf *)shelf {
    for (ZEDBook *book in books) {
        [self.analytics sendActionWithActioncategory:CATEGOR_REMOVE_BOOKS action:ACTION_BOOK label:book.fullNameWithAuthor value:nil];
        [self.analytics sendActionWithActioncategory:CATEGOR_REMOVE_BOOKS action:ACTION_FORMAT label:book.extension value:nil];
        [self.analytics sendActionWithActioncategory:CATEGOR_REMOVE_BOOKS action:ACTION_PLACE label:LABEL_BOOKSHELF value:nil];
    }
    
    NSMutableDictionary *properties = [books amplitudeDeleteBooksPropertyAfterMultiSelect:multiSelect];
    [self.analytics amplitudeLogDeleteBooksWithProperties:properties];
}

- (void)analyticsTakeOffBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect fromShelf:(ZEDBookshelf *)shelf {
    NSMutableDictionary *properties = [shelf amplitudeShelfPropertiesRemoveBooksCount:books.count afterMultiSelect:multiSelect];
    [self.analytics amplitudeLogChangeContentShelfWithProperties:properties];
}

- (void)analyticsCancelDeleteBooks:(NSArray *)books afterMultiSelect:(BOOL)multiSelect {
    NSMutableDictionary *properties = [books amplitudeDeleteBooksPropertyAfterMultiSelect:multiSelect];
    [self.analytics amplitudeLogCancelDeleteBooksWithProperties:properties];
}

- (void)analyticsDeleteBookshelf:(ZEDBookshelf *)shelf {
    NSMutableDictionary *properties = [shelf amplitudeShelfProperties];
    [self.analytics amplitudeLogDeleteShelfWithProperties:properties];
}

- (void)analyticsHiddenBooksOnBookshelf:(ZEDBookshelf *)shelf {
    if (shelf.hiddenBooks) {
        [self.analytics sendActionWithActioncategory:@"Свойства полки"
                                              action:@"Скрытие книг"
                                               label:shelf.name
                                               value:nil];
    } else {
        [self.analytics sendActionWithActioncategory:@"Свойства полки"
                                              action:@"Возврат книг в библиотеку"
                                               label:shelf.name
                                               value:nil];
    }
    
    NSMutableDictionary *properties = [shelf amplitudeShelfHiddenBooksProperties];
    [self.analytics amplitudeLogUpdateShelfWithProperties:properties];
}

- (void)analyticsOpenBook:(ZEDBook *)book {
    NSString* sortField = self.appPreferences.booksFilter.analyticsInfo;
    
    [self.analytics sendActionWithActioncategory:CATEGORY_MOVE_TO_READING action:ACTION_PLACE label:sortField value:nil];
    [self.analytics sendActionWithActioncategory:CATEGORY_MOVE_TO_READING action:ACTION_BOOK label:book.fullNameWithAuthor value:nil];
    [self.analytics sendActionWithActioncategory:CATEGORY_MOVE_TO_READING action:ACTION_FORMAT label:book.extension value:nil];
    
    NSString *defaulfBooks = [[NSUserDefaults standardUserDefaults] objectForKey:@"DEFAULT_BOOKS_AND_GUIDES"];
    if(defaulfBooks.length > 0) {
        if(![defaulfBooks containsString:book.uuid]) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_FIRST_OPEN_MY_BOOK"]) {
                [self.analytics sendActionWithActioncategory:CATEGORY_FUNNELS action:ACTION_START_TO_USE label:LABEL_OPEN_MY_BOOK value:nil];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_FIRST_OPEN_MY_BOOK"];
            } else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_SECOND_OPEN_MY_BOOK"]) {
                [self.analytics sendActionWithActioncategory:CATEGORY_FUNNELS action:ACTION_START_TO_USE label:LABEL_OPEN_NEXT_BOOKS value:nil];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_SECOND_OPEN_MY_BOOK"];
            }
        }
    }
    
    NSMutableDictionary *properties = [book amplitudeBookProperties];
    [self.analytics amplitudeLogOpenBookWithProperties:properties];
}


@end

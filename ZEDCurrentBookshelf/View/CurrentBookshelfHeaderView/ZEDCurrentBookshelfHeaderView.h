//
//  ZEDCurrentBookshelfHeaderView.h
//  ZedBooks
//
//  Created by Aliev Yuriy on 10.08.2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZEDUpdateBookshelfTitleDelegate

- (void)updateBookshelfTitle:(NSString *)newTitle;
- (void)updateTableViewHeader;

@end

@interface ZEDCurrentBookshelfHeaderView : UIView

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL hiddenBooks;
@property (nonatomic, assign) BOOL shelfWithReadBooks;

@property (weak, nonatomic) id<ZEDUpdateBookshelfTitleDelegate> delegate;

- (void)setupWithName:(NSString *)name andBooksCount:(NSUInteger)count;

@end

//
//  ZEDCurrentBookshelfHeaderView.m
//  ZedBooks
//
//  Created by Aliev Yuriy on 10.08.2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import "ZEDCurrentBookshelfHeaderView.h"

@interface ZEDCurrentBookshelfHeaderView () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *booksCountLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *maxHeightPlaceholder;

@property (weak, nonatomic) IBOutlet UIImageView *hiddenBooksEye;
@property (weak, nonatomic) IBOutlet UIImageView *markReaddBook;

@end

#define COUNT_COLOR [UIColor colorWithRed:0.96 green:0.29 blue:0.40 alpha:1.0]
#define TEXT_COLOR  [UIColor colorWithRed:0.61 green:0.61 blue:0.61 alpha:1.0]

@implementation ZEDCurrentBookshelfHeaderView

- (void)setupWithName:(NSString *)name andBooksCount:(NSUInteger)count {
    if (name.length) {
        self.titleTextView.backgroundColor = UIColor.whiteColor;
        self.titleTextView.text = name;
        self.placeholderLabel.text = name;
    } else {
        self.titleTextView.text = @"";
        self.placeholderLabel.text = NSLocalizedString(@"Enter shelf name", @"Enter shelf name");
        self.titleTextView.backgroundColor = UIColor.clearColor;
    }
    
    NSString *countBooks = [NSString localizedStringWithFormat:NSLocalizedString(@"count books", @"count books"), count];
    NSMutableAttributedString * bookCountStr = [[NSMutableAttributedString alloc] initWithString:countBooks];
    NSRange range = [countBooks rangeOfString:[NSString stringWithFormat:@"%@", @(count)] options:NSCaseInsensitiveSearch];
    [bookCountStr addAttribute:NSForegroundColorAttributeName value:COUNT_COLOR range:range];
    [bookCountStr addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR range:NSMakeRange(range.length, countBooks.length - range.length)];
    self.booksCountLabel.attributedText = bookCountStr;
    
    NSInteger maxHeight = CGRectGetHeight([UIScreen mainScreen].bounds) / 2.5;
    NSInteger countLines = maxHeight / self.placeholderLabel.font.lineHeight;
    self.maxHeightPlaceholder.constant = countLines * self.placeholderLabel.font.lineHeight;
    self.maxHeightPlaceholder.active = NO;
    
    [self updateTableView];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.markReaddBook.hidden = YES;
    self.titleTextView.text = [self.titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.placeholderLabel.text = self.titleTextView.text;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.text.length) {
        textView.backgroundColor = UIColor.whiteColor;
        self.placeholderLabel.text = textView.text;
    } else {
        self.placeholderLabel.text = NSLocalizedString(@"Enter shelf name", @"Enter shelf name");
        textView.backgroundColor = UIColor.clearColor;
    }
    
    self.titleTextView.scrollEnabled = YES;
    self.maxHeightPlaceholder.active = YES;
    
    [self.titleTextView scrollRangeToVisible:NSMakeRange(textView.text.length - 1, 1)];

    [self updateTableView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self updateTableView];
        return NO;
    }
    
    NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (newText.length) {
        textView.backgroundColor = UIColor.whiteColor;
        self.placeholderLabel.text = newText;
        [self updateTableView];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *newText = textView.text;
    if (newText.length == 0) {
        self.placeholderLabel.text = NSLocalizedString(@"Enter shelf name", @"Enter shelf name");
        textView.backgroundColor = UIColor.clearColor;
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    self.titleTextView.scrollEnabled = NO;
    self.maxHeightPlaceholder.active = NO;
    [self updateTableView];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self updateTableView];
    
    NSString *newTitle = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.shelfWithReadBooks) {
        self.titleTextView.text = [NSString stringWithFormat:@"     %@", newTitle];
        self.placeholderLabel.text = self.titleTextView.text;
        self.markReaddBook.hidden = NO;
    }
    
    [self.delegate updateBookshelfTitle:newTitle];
}

- (void)updateTableView {
    [UIView animateWithDuration:0.1 animations:^{
        [self setNeedsUpdateConstraints];
        [self layoutIfNeeded];
        
        [self.delegate updateTableViewHeader];
    }];
}

- (void)setHiddenBooks:(BOOL)hiddenBooks {
    _hiddenBooks = hiddenBooks;
    _hiddenBooksEye.hidden = !hiddenBooks;
}

- (void)setShelfWithReadBooks:(BOOL)shelfWithReadBooks {
    _shelfWithReadBooks = shelfWithReadBooks;
    _markReaddBook.hidden = !shelfWithReadBooks;
}

@end

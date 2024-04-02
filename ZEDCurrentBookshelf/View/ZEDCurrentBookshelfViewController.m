//
//  ZEDCurrentZEDBookshelfViewController.m
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import "ZEDCurrentBookshelfViewController.h"
#import "ZEDCurrentBookshelfHeaderView.h"
#import "ZEDCurrentBookshelfViewOutput.h"
#import "ZEDBookTableViewCell.h"

#import "UIViewController+Amplitude.h"
#import "ZEDAlertViewController.h"
#import "ZEDAlertActionTitle.h"
#import "ZEDTextFieldOption.h"
#import "ZEDCheckboxView.h"

#import "ZEDNotificationManager.h"
#import <Typhoon/TyphoonAutoInjection.h>

#import "ZEDBookshelf.h"
#import "ZEDBook.h"

@interface ZEDCurrentBookshelfViewController () <UITableViewDelegate, UITableViewDataSource, ZEDUpdateBookshelfTitleDelegate>

@property (nonatomic, assign) BOOL editing;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButton;

@property (strong, nonatomic) IBOutlet ZEDCurrentBookshelfHeaderView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *noBooksLabel;
@property (strong, nonatomic) IBOutlet UIView *selectedAllView;
@property (strong, nonatomic) IBOutlet ZEDCheckboxView *checkBoxView;
@property (strong, nonatomic) IBOutlet UIButton *selectAllButton;

@property (nonatomic, weak) IBOutlet UIButton *deleteBooksButton;
@property (nonatomic, weak) IBOutlet UIButton *takeOffBooksButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintActionButton;

@property (nonatomic, weak) InjectedClass(ZEDNotificationManager) notificationManager;
@property (nonatomic, weak) InjectedProtocol(ZEDDownloadBooksService) downloadService;

@end

@implementation ZEDCurrentBookshelfViewController

#pragma mark - Методы жизненного цикла

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Полка";
    self.amplitudeScreenName = kZEDAmplitudeOpenScreenShelf;
    
    [self.output didTriggerViewReadyEvent];
    
    [self setupHeaderView];
    
    self.tableView.tableFooterView = self.footerView;
    self.tableView.tableHeaderView = self.headerView;
    
    self.title = NSLocalizedString(@"Bookshelf", @"Bookshelf");
    self.navigationItem.leftBarButtonItems = @[];
    self.navigationItem.rightBarButtonItems = @[self.editBarButton];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willChangeOrientation)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
    
    NSString *identifier = NSStringFromClass(ZEDBookTableViewCell.class);
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil]
         forCellReuseIdentifier:identifier];
}

- (void)dealloc {
    self.amplitudeScreenName = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateCollections];
    [super viewWillAppear:animated];
    self.output.viewAppeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.output.viewAppeared = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBar.tintColor = UIColor.whiteColor;
}

- (void)setupHeaderView {
    self.headerView.delegate = self;
    NSString *title = [self.output titleBookshelf];
    NSInteger countBooks = [self.output numberOfRowsInSection:0];
    [self.headerView setupWithName:title andBooksCount:countBooks];
    [self.headerView setHiddenBooks:[self.output isHiddenBooks]];
    self.headerView.shelfWithReadBooks = self.output.shelfWithMarkedReadBooks;
}

- (void)setEditing:(BOOL)editing {
    [self.tableView setContentOffset:CGPointZero animated:NO];
    
    _editing = editing;
    
    [self.tableView setEditing:editing animated:YES];
    
    if (editing) {
        [self.navigationItem setLeftBarButtonItem:self.cancelBarButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:YES];
    } else {
        [self.view endEditing:YES];
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
        [self.navigationItem setRightBarButtonItem:self.editBarButton animated:YES];
        [self.navigationItem setTitle:NSLocalizedString(@"Bookshelf", @"Bookshelf")];
        [self setupHeaderView];
    }
    
    self.deleteBooksButton.enabled = NO;
    self.takeOffBooksButton.enabled = NO;
    self.checkBoxView.selected = NO;
    self.selectedAllView.hidden = !editing;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomConstraintActionButton.constant = editing ? 0 : -106; // V:|-30-(ActionButtons(46))-30-|
        [self.view layoutIfNeeded];
    }];
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Методы ZEDCurrentBookshelfViewInput
- (void)setupInitialState {
    [self.selectAllButton setTitle:NSLocalizedString(@"Select all", nil) forState:UIControlStateNormal&UIControlStateHighlighted];
    [self.takeOffBooksButton setTitle:NSLocalizedString(@"Take off books", nil) forState:UIControlStateNormal&UIControlStateHighlighted];
    [self.deleteBooksButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal&UIControlStateHighlighted];
    [self.noBooksLabel setText:NSLocalizedString(@"No books", nil)];
}

#pragma mark - Методы UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.editing ? 44.0f : 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.editing ? self.selectedAllView : UIView.new;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.output numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 128.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZEDBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ZEDBookTableViewCell.class)];
    cell.downloadService = self.downloadService;
    
    __weak typeof(self) weakSelf = self;
    ZEDBook *book = [self.output objectAtIndexPath:indexPath];
    
    [cell setupBook:book];
    
    [cell setupRemoveActionWithCallback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        [weakSelf needDeleteBooksAtIndexPaths:@[indexPath] afterMultiSelect:NO];
        return YES;
    }];
    [cell setupFromBookshelfActionWithCallback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        [weakSelf.output takeOffBooksAtIndexPaths:@[indexPath] afterMultiSelect:NO];
        return YES;
    }];
    [cell setupAboutBookActionWithCallback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        [weakSelf.output needOpenAboutBookWithIndexPath:indexPath];
        return NO;
    }];
    
    [cell setupMarkedReadActionWithCallback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        [weakSelf.output needMarkedAsReadBookWithIndexPath:indexPath];
        [weakSelf.tableView reloadData];
        return YES;
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        NSInteger countRow = [self.output numberOfRowsInSection:indexPath.section];
        NSInteger countSelected = [tableView indexPathsForSelectedRows].count;
        self.checkBoxView.selected = countRow == countSelected;
        self.deleteBooksButton.enabled = countSelected > 0;
        self.takeOffBooksButton.enabled = countSelected > 0;
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Selected: %u", @"Selected: ${selected_number}"), countSelected];
    } else {
        if (![self.output isEmpty]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            ZEDBookTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            CGRect frame = [cell.coverImage convertRect:cell.coverImage.bounds toView:self.view];
            [self.output userDidSelectBookAtIndexPath:indexPath fromFrame:frame];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        NSInteger countSelected = [tableView indexPathsForSelectedRows].count;
        self.deleteBooksButton.enabled = countSelected > 0;
        self.takeOffBooksButton.enabled = countSelected > 0;
        self.checkBoxView.selected = NO;
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Selected: %u", @"Selected: ${selected_number}"), countSelected];
    }
}

#pragma mark - IBAction
- (IBAction)selectAllRows {
    NSUInteger countRow = [self.output numberOfRowsInSection:1];
    NSUInteger countSelectRow = [self.tableView indexPathsForSelectedRows].count;
    
    BOOL needSelect = countRow != countSelectRow;
    self.checkBoxView.selected = needSelect;
    
    for (NSInteger row = 0; row < countRow; row += 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        if (needSelect) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
    countSelectRow = [self.tableView indexPathsForSelectedRows].count;
    self.deleteBooksButton.enabled = countSelectRow > 0;
    self.takeOffBooksButton.enabled = countSelectRow > 0;
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Selected: %u", @"Selected: ${selected_number}"), countSelectRow];
}

- (IBAction)startEditing {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([self.output numberOfRowsInSection:1]) {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Select books", @"Select books") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.editing = YES;
        }]];
    }
    
    NSString *titleAction = NSLocalizedString(@"Hide books", nil);
    if (self.output.isHiddenBooks) titleAction = NSLocalizedString(@"Show books", nil);
    [alert addAction:[UIAlertAction actionWithTitle:titleAction style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.output updateHiddenBooksState];
        self.headerView.hiddenBooks = [self.output isHiddenBooks];
    }]];
    
    if (self.output.canDeleteBookshelf) {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Remove bookshelf", @"Remove bookshelf") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self tryDeleteBookshelf];
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        alert.popoverPresentationController.barButtonItem = self.editBarButton;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)cancelEditing {
    self.editing = NO;
}

- (IBAction)doneEditing {
    self.editing = NO;
}

- (IBAction)tryDeleteBookshelf {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Remove bookshelf?", @"Remove bookshelf?")
                                                                    message:NSLocalizedString(@"No book will be deleted", @"No book will be deleted")
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"Delete")
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * action) {
                                                          [self.output removeCurrentBookshelf];
                                                          [self.navigationController popViewControllerAnimated:YES];
                                                      }];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action){}];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)endEditing {
    [self.view endEditing:YES];
}

- (IBAction)deleteBooks {
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    [self needDeleteBooksAtIndexPaths:indexPaths afterMultiSelect:YES];
}

- (IBAction)takeOffBooksFromBookshekf {
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    [self.output takeOffBooksAtIndexPaths:indexPaths afterMultiSelect:YES];
}

- (void)updateCollections {
    self.footerView.hidden = ![self.output isEmpty];
    [self.tableView reloadData];
    [self setupHeaderView];
}

- (void)deleteIndexPathsFromCollections:(NSArray<NSIndexPath *> *)indexPaths{
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
}

- (void)needDeleteBooksAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths afterMultiSelect:(BOOL)multiSelect {
    NSString *message = [NSString localizedStringWithFormat:NSLocalizedString(@"deleted books", nil), indexPaths.count];
    NSArray *selectedBooks = [self.output needRemoveBooksAtIndexPaths:indexPaths];
    NSString *actionTitle = NSLocalizedString(@"Return", nil);
    
    [self.notificationManager scheduleNotificationWithType:ZEDNotificationAttentionType
                                                andMessage:message
                                            andActionTitle:actionTitle
                                       andActionCompletion:^(BOOL success) {
                                           if (success) {
                                               [self.output returnDeletedBooks:selectedBooks afterMultiSelect:multiSelect];
                                           } else {
                                               [self.output completeRemoveBooks:selectedBooks afterMultiSelect:multiSelect];
                                           }
                                       }];
}

#pragma mark - ZEDUpdateBookshelfTitleDelegate
- (void)updateBookshelfTitle:(NSString *)newTitle {
    if (newTitle.length) [self.output updateTitleBookshelf:newTitle];
}

- (void)updateTableViewHeader {
    CGSize size = [self.headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, size.width, size.height);
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Notification action
- (void)willChangeOrientation {
    NSArray *cells = [self.tableView visibleCells];
    for (MGSwipeTableCell *cell in cells) {
        if ([cell isKindOfClass:MGSwipeTableCell.class]) {
            if (cell.swipeState) [cell hideSwipeAnimated:NO];
        }
    }
}

@end

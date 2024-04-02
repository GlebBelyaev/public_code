//
//  ZEDCurrentBookshelfModuleOutput.h
//  ZedBooks
//
//  Created by Aliev Yuriy on 17.08.2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ViperMcFlurry/ViperMcFlurry.h>

@protocol ZEDCurrentBookshelfModuleOutput<RamblerViperModuleOutput>

- (void)needReloadLastReadBook;
- (void)needReloadBookshelves;
- (void)needReloadBooks;

@end

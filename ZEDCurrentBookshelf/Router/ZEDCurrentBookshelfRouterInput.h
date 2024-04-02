//
//  ZEDCurrentZEDBookshelfRouterInput.h
//  beebooks.ios
//
//  Created by g.belyaev on 02/07/2018.
//  Copyright © 2018 ZedTema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZEDBookReaderRouterInput.h"

NS_ASSUME_NONNULL_BEGIN

@class ZEDBook;

@protocol ZEDCurrentBookshelfRouterInput <ZEDBookReaderRouterInput>

- (void)openAboutBookModuleWithBook:(ZEDBook *)book;

@end

NS_ASSUME_NONNULL_END

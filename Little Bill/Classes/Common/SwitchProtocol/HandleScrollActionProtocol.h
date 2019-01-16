//
//  HandleScrollActionProtocol.h
//  Little Bill
//
//  Created by SU on 2017/9/25.
//  Copyright © 2017年 SU. All rights reserved.
//

#ifndef HandleScrollActionProtocol_h
#define HandleScrollActionProtocol_h

@protocol HandleScrollActionProtocol <NSObject>

@required
- (void)handleScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)handleScrollViewWillBeginDecelerating:(UIScrollView *)scrollView;

@end

#endif /* HandleScrollActionProtocol_h */

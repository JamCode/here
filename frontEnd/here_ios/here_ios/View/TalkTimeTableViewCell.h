//
//  TalkTimeTableViewCell.h
//  CarSocial
//
//  Created by wang jam on 10/16/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalkTimeTableViewCell : UITableViewCell

- (void)setTimeStamp:(long)time;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end

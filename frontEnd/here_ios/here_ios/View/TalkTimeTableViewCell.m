//
//  TalkTimeTableViewCell.m
//  CarSocial
//
//  Created by wang jam on 10/16/14.
//  Copyright (c) 2014 jam wang. All rights reserved.
//

#import "TalkTimeTableViewCell.h"
#import "macro.h"
#import "Constant.h"
#import "Tools.h"

@implementation TalkTimeTableViewCell
{
    UILabel* timeLabel;
    NSString* timeStr;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        timeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:timeLabel];
    }
    return self;
}



- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTimeStamp:(long)time
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    int nowTime = [[NSDate date] timeIntervalSince1970];
    
    if (nowTime - time <24*3600) {
        [formatter setDateFormat:@"HH:mm"];
        //[formatter setTimeStyle:NSDateFormatterShortStyle];

    }else if(nowTime - time <24*3600*365&&nowTime - time>=24*3600){
        [formatter setDateFormat:@"MM-dd HH:mm"];
        
        //[formatter setDateStyle:NSDateFormatterShortStyle];

    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        //[formatter setDateStyle:NSDateFormatterShortStyle];

    }
    
    //[formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    //[date set]
    timeStr = [formatter stringFromDate:date];
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:timeStr];
    NSRange range = NSMakeRange(0, attrStr.length);
    NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];   // 获取该段
    
    CGRect size = [timeStr boundingRectWithSize:CGSizeMake(ScreenWidth, 400) options:NSStringDrawingTruncatesLastVisibleLine attributes:dic context:nil];
    
    timeLabel.frame = CGRectMake(0, 0, size.size.width, size.size.height);
    timeLabel.text = timeStr;
    timeLabel.font = [UIFont fontWithName:@"Arial" size:12];
    timeLabel.textColor = [UIColor grayColor];
    timeLabel.center = self.contentView.center;
    
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    
    
}

@end

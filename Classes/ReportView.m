//
//  ReportView.m
//  4x MMO Mobile Strategy Game
//
//  Created by Shankar Nathan (shankqr@gmail.com) on 3/24/09.
/*
 Copyright © 2017 SHANKAR NATHAN (shankqr@gmail.com). All rights reserved.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "ReportView.h"
#import "ReportDetail.h"
#import "Globals.h"

@interface ReportView ()

@property (nonatomic, strong) NSMutableArray *reportArray;
@property (nonatomic, strong) ReportDetail *reportDetail;
@property (nonatomic, strong) NSString *view_title;

@property (nonatomic, assign) NSTimeInterval serverTimeInterval;

@end

@implementation ReportView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self notificationRegister];
}

- (void)notificationRegister
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:@"CloseTemplateBefore"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:@"UpdateReportView"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:@"ChooseReport"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:@"TabReports"
                                               object:nil];
    
}

- (void)notificationReceived:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"CloseTemplateBefore"])
    {
        NSDictionary *userInfo = notification.userInfo;
        NSString *view_title = [userInfo objectForKey:@"view_title"];
        
        if ([self.title isEqualToString:view_title])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
    else if ([[notification name] isEqualToString:@"UpdateReportView"])
    {
        [self refreshTable];
    }
    else if ([[notification name] isEqualToString:@"TabReports"])
    {
        [self updateView];
    }
    else if ([[notification name] isEqualToString:@"ChooseReport"])
    {
        NSDictionary *userInfo = notification.userInfo;
        
        if (userInfo != nil)
        {
            NSNumber *report_index = [userInfo objectForKey:@"report_index"];
            
            NSLog(@"report_index : %@",report_index);
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[report_index intValue] inSection:0];
            
            DynamicCell *customCellView = (DynamicCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            NSLog(@"customCellView ReportList : %@",customCellView);
            
            
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.tableView.delegate tableView:self.tableView willSelectRowAtIndexPath:indexPath];
            
        }

    }
}

- (void)updateView
{
    NSDictionary *row0 = @{@"r1": NSLocalizedString(@"No reports received yet.", nil), @"r1_align": @"1", @"r1_color": @"1", @"nofooter": @"1"};
    NSArray *rows1 = @[row0];
    self.ui_cells_array = [@[rows1] mutableCopy];
    
    [Globals.i updateReports:^(BOOL success, NSData *data)
    {
        [self refreshTable];
    }];
}

- (void)refreshTable
{
    self.serverTimeInterval = [Globals.i updateTime];
    self.reportArray = [Globals.i gettLocalReportData];
    
    if (self.reportArray.count > 0)
    {
        self.ui_cells_array = [@[self.reportArray] mutableCopy];
    }
    
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

- (NSDictionary *)getRowData:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = nil;
    
    if ((indexPath.section == 0) && (self.reportArray.count > 0)) //Report List
    {
    NSDictionary *row1 = self.ui_cells_array[indexPath.section][indexPath.row];
    
    NSString *bkg = @"";
    NSString *bold = @"";
    NSString *r1_font = @"";
    NSString *r2_font = @"";
    if ([row1[@"open_read"] isEqualToString:@"1"])
    {
        bkg = @"bkg3";
        bold = @"1";
        r1_font = @"11.0";
        r2_font = @"10.0";
    }
    else
    {
        bkg = @"";
        bold = @"1";
        r1_font = @"12.0";
        r2_font = @"11.0";
    }
    
    NSString *profile1_face = @"";
    NSString *profile2_face = @"";
    if (row1[@"profile1_face"] != nil)
    {
        if ([row1[@"profile1_face"] integerValue] > 0)
        {
            profile1_face = [NSString stringWithFormat:@"face_%@", row1[@"profile1_face"]];
        }
    }
    if (row1[@"profile2_face"] != nil)
    {
        if ([row1[@"profile2_face"] integerValue] > 0)
        {
            profile2_face = [NSString stringWithFormat:@"face_%@", row1[@"profile2_face"]];
        }
    }
    
    NSString *profile1_name = @"";
    NSString *profile2_name = @"";
    if (row1[@"profile1_name"] != nil && ![row1[@"profile1_name"] isEqualToString:@""])
    {
        profile1_name = row1[@"profile1_name"];
    }
    if (row1[@"profile2_name"] != nil && ![row1[@"profile2_name"] isEqualToString:@""])
    {
        profile2_name = row1[@"profile2_name"];
    }
    
    if (row1[@"profile1_tag"] != nil && ![row1[@"profile1_tag"] isEqualToString:@""])
    {
        profile1_name = [NSString stringWithFormat:@"[%@]%@", row1[@"profile1_tag"], profile1_name];
    }
    if (row1[@"profile2_tag"] != nil && ![row1[@"profile2_tag"] isEqualToString:@""])
    {
        profile2_name = [NSString stringWithFormat:@"[%@]%@", row1[@"profile2_tag"], profile2_name];
    }
    
    NSString *profile1_city = @"";
    NSString *profile2_city = @"";
    if (row1[@"profile1_base_name"] != nil && ![row1[@"profile1_base_name"] isEqualToString:@""])
    {
        profile1_city = row1[@"profile1_base_name"];
    }
    if (row1[@"profile2_base_name"] != nil && ![row1[@"profile2_base_name"] isEqualToString:@""])
    {
        profile2_city = row1[@"profile2_base_name"];
    }
    
    //NSString *profile1_location = [NSString stringWithFormat:@"at (X:%@ Y:%@)", row1[@"profile1_x"], row1[@"profile1_y"]];
    NSString *profile2_location = [NSString stringWithFormat:@"at (X:%@ Y:%@)", row1[@"profile2_x"], row1[@"profile2_y"]];
    
    NSString *i0 = @"";
    NSString *i1 = @"";
    NSString *r1 = @"";
    NSString *r2 = [Globals.i getTimeAgo:row1[@"date_posted"]];
    
    if ([row1[@"report_type"] isEqualToString:@"60"]) //Capture sent to npc village
    {
        NSString *strDate = row1[@"date_arrive"];
        
        NSDate *queueDate = [Globals.i dateParser:strDate];
        NSTimeInterval queueTime = [queueDate timeIntervalSince1970];
        NSInteger march_time_left = queueTime - self.serverTimeInterval;
        
        if (march_time_left > 1)
        {
            self.view_title = NSLocalizedString(@"Capture Village", nil);
            i1 = profile2_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            i0 = @"report_attack_victory";
            r1 = NSLocalizedString(@"Marching full force towards Barbarian Village.", nil);
        }
        else //Capture village done so update report type to 61 and set openread to 0
        {
            self.ui_cells_array[indexPath.section][indexPath.row][@"report_type"] = @"61";
            self.ui_cells_array[indexPath.section][indexPath.row][@"open_read"] = @"0";
            [Globals.i settLocalReportData:self.ui_cells_array[indexPath.section]];
            [self.tableView reloadData];
        }
    }
    else if ([row1[@"report_type"] isEqualToString:@"61"]) //Capture is over
    {
        self.view_title = NSLocalizedString(@"Capture Village", nil);
        if ([row1[@"profile1_id"] isEqualToString:Globals.i.wsWorldProfileDict[@"profile_id"]])
        {
            i1 = profile2_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            if ([row1[@"victory"] isEqualToString:@"1"])
            {
                i0 = @"report_attack_victory";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"You have captured %@'s village %@", nil), profile2_name, profile2_city];
            }
            else
            {
                i0 = @"report_attack_defeat";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"You failed to capture %@'s village %@", nil), profile2_name, profile2_city];
            }
        }
        else
        {
            i1 = profile1_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            if ([row1[@"victory"] isEqualToString:@"1"])
            {
                i0 = @"report_attack_defeat";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"%@ has captured your village %@", nil), profile1_name, profile2_city];
            }
            else
            {
                i0 = @"report_attack_victory";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"%@ has failed to capture your village %@", nil), profile1_name, profile2_city];
            }
        }
    }
    else if ([row1[@"report_type"] isEqualToString:@"10"]) //Attack sent to npc village
    {
        NSString *strDate = row1[@"date_arrive"];
        
        NSDate *queueDate = [Globals.i dateParser:strDate];
        NSTimeInterval queueTime = [queueDate timeIntervalSince1970];
        NSInteger march_time_left = queueTime - self.serverTimeInterval;
        
        if (march_time_left > 1)
        {
            self.view_title = NSLocalizedString(@"Attack", nil);
            i1 = profile2_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            i0 = @"report_attack_victory";
            r1 = NSLocalizedString(@"You have sent an Attack to Barbarian Village.", nil);
        }
        else //Attack village done so update report type to 11 and set openread to 0
        {
            self.ui_cells_array[indexPath.section][indexPath.row][@"report_type"] = @"11";
            self.ui_cells_array[indexPath.section][indexPath.row][@"open_read"] = @"0";
            [Globals.i settLocalReportData:self.ui_cells_array[indexPath.section]];
            [self.tableView reloadData];
        }
    }
    if ([row1[@"report_type"] isEqualToString:@"11"]) //Attack is over
    {
        self.view_title = NSLocalizedString(@"Attack", nil);
        if ([row1[@"profile1_id"] isEqualToString:Globals.i.wsWorldProfileDict[@"profile_id"]])
        {
            i1 = profile2_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            if ([row1[@"victory"] isEqualToString:@"1"])
            {
                i0 = @"report_attack_victory";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"You have raided %@'s city %@", nil), profile2_name, profile2_city];
            }
            else
            {
                i0 = @"report_attack_defeat";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"You failed to raid %@'s city %@", nil), profile2_name, profile2_city];
            }
        }
        else
        {
            i1 = profile1_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            if ([row1[@"victory"] isEqualToString:@"1"])
            {
                i0 = @"report_attack_defeat";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"%@ has raided your city %@", nil), profile1_name, profile2_city];
            }
            else
            {
                i0 = @"report_attack_victory";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"%@ has failed to raid your city %@", nil), profile1_name, profile2_city];
            }
        }
    }
    else if ([row1[@"report_type"] isEqualToString:@"21"]) //Spy
    {
        self.view_title = NSLocalizedString(@"Spy Report", nil);
        if ([row1[@"profile1_id"] isEqualToString:Globals.i.wsWorldProfileDict[@"profile_id"]])
        {
            i1 = profile2_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            if ([row1[@"victory"] isEqualToString:@"1"])
            {
                i0 = @"report_spy_victory";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"You have spied upon %@'s city %@", nil), profile2_name, profile2_city];
            }
            else
            {
                i0 = @"report_spy_defeat";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"You failed to spy upon %@'s city %@", nil), profile2_name, profile2_city];
            }
        }
        else
        {
            i1 = profile1_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            if ([row1[@"victory"] isEqualToString:@"1"])
            {
                i0 = @"report_spy_defeat";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"%@ has spied upon your city %@", nil), profile1_name, profile2_city];
            }
            else
            {
                i0 = @"report_spy_victory";
                r1 = [NSString stringWithFormat:NSLocalizedString(@"%@ has failed to spy upon your city %@", nil), profile1_name, profile2_city];
            }
            
        }
    }
    else if ([row1[@"report_type"] isEqualToString:@"30"]) //Trade - Incoming / Sending
    {
        NSString *strDate = row1[@"date_arrive"];
        
        NSDate *queueDate = [Globals.i dateParser:strDate];
        NSTimeInterval queueTime = [queueDate timeIntervalSince1970];
        NSInteger march_time_left = queueTime - self.serverTimeInterval;
        if (march_time_left > 1)
        {
            self.view_title = NSLocalizedString(@"Trade", nil);
            i0 = @"report_trade";
            if ([row1[@"profile1_id"] isEqualToString:Globals.i.wsWorldProfileDict[@"profile_id"]])
            {
                i1 = profile2_face;
                r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
                r1 = [NSString stringWithFormat:NSLocalizedString(@"Your resource help has started it's journey to %@'s city '%@'", nil), profile2_name, profile2_city];
            }
            else
            {
                i1 = profile1_face;
                r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
                r1 = [NSString stringWithFormat:NSLocalizedString(@"%@ is sending your city '%@' resources", nil), profile1_name, profile2_city];
            }
        }
        else //Have arrived so update report type to 31 and set openread to 0
        {
            self.ui_cells_array[indexPath.section][indexPath.row][@"report_type"] = @"31";
            self.ui_cells_array[indexPath.section][indexPath.row][@"open_read"] = @"0";
            [Globals.i settLocalReportData:self.ui_cells_array[indexPath.section]];
            [self.tableView reloadData];
        }
    }
    else if ([row1[@"report_type"] isEqualToString:@"31"]) //Trade - Received / Delivered
    {
        self.view_title = NSLocalizedString(@"Trade", nil);
        i0 = @"report_trade";
        
        if ([row1[@"profile1_id"] isEqualToString:Globals.i.wsWorldProfileDict[@"profile_id"]])
        {
            i1 = profile2_face;
            r1 = [NSString stringWithFormat:NSLocalizedString(@"Your resource help has been successfuly delivered to %@'s city '%@'", nil), profile2_name, profile2_city];
        }
        else
        {
            i1 = profile1_face;
            r1 = [NSString stringWithFormat:NSLocalizedString(@"Your city '%@' has received resources from %@", nil), profile2_city, profile1_name];
        }
        
        r2 = [Globals.i getTimeAgo:row1[@"date_arrive"]];
        r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
    }
    else if ([row1[@"report_type"] isEqualToString:@"40"]) //Reinforce - Incoming / Sending
    {
        NSString *strDate = row1[@"date_arrive"];
        
        NSDate *queueDate = [Globals.i dateParser:strDate];
        NSTimeInterval queueTime = [queueDate timeIntervalSince1970];
        NSInteger march_time_left = queueTime - self.serverTimeInterval;
        if (march_time_left > 1)
        {
            self.view_title = NSLocalizedString(@"Reinforcements", nil);
            i0 = @"report_reinforce";
            if ([row1[@"profile1_id"] isEqualToString:Globals.i.wsWorldProfileDict[@"profile_id"]])
            {
                i1 = profile2_face;
                r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
                r1 = [NSString stringWithFormat:NSLocalizedString(@"Your reinforcements is marching towards %@'s city '%@'", nil), profile2_name, profile2_city];
            }
            else
            {
                i1 = profile1_face;
                r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
                r1 = [NSString stringWithFormat:NSLocalizedString(@"%@ is sending your city '%@' reinforcements", nil), profile1_name, profile2_city];
            }
        }
        else //Have arrived so update report type to 41 and set openread to 0
        {
            self.ui_cells_array[indexPath.section][indexPath.row][@"report_type"] = @"41";
            self.ui_cells_array[indexPath.section][indexPath.row][@"open_read"] = @"0";
            [Globals.i settLocalReportData:self.ui_cells_array[indexPath.section]];
            [self.tableView reloadData];
        }
    }
    else if ([row1[@"report_type"] isEqualToString:@"41"]) //Reinforce - Received / Delivered
    {
        self.view_title = NSLocalizedString(@"Reinforcements", nil);
        i0 = @"report_reinforce";
        
        if ([row1[@"profile1_id"] isEqualToString:Globals.i.wsWorldProfileDict[@"profile_id"]])
        {
            i1 = profile2_face;
            r1 = [NSString stringWithFormat:NSLocalizedString(@"Your reinforcements have arrived at %@'s city '%@'", nil), profile2_name, profile2_city];
        }
        else
        {
            i1 = profile1_face;
            r1 = [NSString stringWithFormat:NSLocalizedString(@"%@'s reinforcements have arrived at your city '%@'", nil), profile1_name, profile2_city];
        }

        r2 = [Globals.i getTimeAgo:row1[@"date_arrive"]];
        r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
    }
    else if ([row1[@"report_type"] isEqualToString:@"50"]) //Transfer - Incoming / Sending
    {
        NSString *strDate = row1[@"date_arrive"];
        
        NSDate *queueDate = [Globals.i dateParser:strDate];
        NSTimeInterval queueTime = [queueDate timeIntervalSince1970];
        NSInteger march_time_left = queueTime - self.serverTimeInterval;
        if (march_time_left > 1)
        {
            self.view_title = NSLocalizedString(@"Troop Transfer", nil);
            i0 = @"report_reinforce";
            i1 = profile1_face;
            r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
            r1 = [NSString stringWithFormat:NSLocalizedString(@"Transfered troops are marching towards your other city '%@'", nil), profile2_city];
        }
        else //Have arrived so update report type to 51 and set openread to 0
        {
            self.ui_cells_array[indexPath.section][indexPath.row][@"report_type"] = @"51";
            self.ui_cells_array[indexPath.section][indexPath.row][@"open_read"] = @"0";
            [Globals.i settLocalReportData:self.ui_cells_array[indexPath.section]];
            [self.tableView reloadData];
        }
    }
    else if ([row1[@"report_type"] isEqualToString:@"51"]) //Transfer - Received / Delivered
    {
        self.view_title = NSLocalizedString(@"Troop Transfer", nil);
        i0 = @"report_reinforce";
        i1 = profile1_face;
        r2 = [Globals.i getTimeAgo:row1[@"date_arrive"]];
        r2 = [NSString stringWithFormat:@"%@ %@", r2, profile2_location];
        r1 = [NSString stringWithFormat:NSLocalizedString(@"Transfered troops have arrived at your city '%@'", nil), profile2_city];
    }
    
    if (row1[@"title"] != nil && ![row1[@"title"] isEqualToString:@""])
    {
        r1 = row1[@"title"];
    }
    
    rowData = @{@"bkg_prefix": bkg, @"i0": i0, @"i1": i1, @"i2": @"arrow_right", @"i1_aspect": @"1", @"r1": r1, @"r2": r2, @"r1_bold": bold, @"r1_font": r1_font, @"r2_bold": bold, @"r2_font": r2_font, @"r2_color": @"5"};
    }
    else
    {
        rowData = self.ui_cells_array[indexPath.section][indexPath.row];
    }
    
    return rowData;
}

- (void)button1_tap:(id)sender
{
    NSDictionary *row101 = @{@"r1": NSLocalizedString(@"Delete Reports:", nil), @"r1_align": @"1", @"r1_bold": @"1", @"r1_font": CELL_FONT_SIZE, @"nofooter": @"1"};
    NSArray *rows1 = @[row101];
    NSMutableArray *rows = [@[rows1] mutableCopy];
    
    NSDictionary *row201 = @{@"r1": NSLocalizedString(@"All Read Only", nil), @"r1_button": @"2", @"c1": NSLocalizedString(@"Everything", nil), @"c1_button": @"2", @"nofooter": @"1"};
    NSArray *rows2 = @[row201];
    [rows addObject:rows2];
    
    [UIManager.i showDialogBlockRow:rows
                            title:@"DeleteReportType"
                             type:8
                              :^(NSInteger index, NSString *text)
     {
         if (index == 1)
         {
             [self deleteAllRead];
         }
         else if (index == 2)
         {
             [self deleteAll];
         }
     }];
}

- (void)deleteAllRead
{
    for (NSMutableDictionary *rowData in self.reportArray)
    {
        if ([rowData[@"open_read"] isEqualToString:@"1"])
        {
            [Globals.i deleteLocalReport:rowData[@"report_id"]];
        }
    }

    [self.tableView reloadData];
    
    [UIManager.i showToast:NSLocalizedString(@"Deleted all Read!", nil)
             optionalTitle:@"AllReadReportDeleted"
             optionalImage:@"icon_check"];
}

- (void)deleteAll
{
    for (NSMutableDictionary *rowData in self.reportArray)
    {
        [Globals.i deleteLocalReport:rowData[@"report_id"]];
    }
    
    [self.tableView reloadData];
    
    [UIManager.i showToast:NSLocalizedString(@"Deleted all Reports!", nil)
           optionalTitle:@"AllReportDeleted"
           optionalImage:@"icon_check"];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (self.reportArray.count > 0))
    {
        self.ui_cells_array[indexPath.section][indexPath.row][@"open_read"] = @"1";
        [Globals.i settLocalReportData:self.ui_cells_array[indexPath.section]];
        [self.tableView reloadData];
        
        if (self.reportDetail == nil)
        {
            self.reportDetail = [[ReportDetail alloc] initWithStyle:UITableViewStylePlain];
        }
        
        NSMutableDictionary *rd = [[self getRowData:indexPath] mutableCopy];
        [rd removeObjectsForKeys:@[@"bkg_prefix", @"i2"]];
        
        self.reportDetail.rowData = rd;
        self.reportDetail.reportData = self.ui_cells_array[indexPath.section][indexPath.row];
        self.reportDetail.is_popup = @"0";
        self.reportDetail.title = self.view_title;
        [self.reportDetail updateView];
        
        [UIManager.i showTemplate:@[self.reportDetail] :self.reportDetail.title];
    }

	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.reportArray.count > 0)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, TABLE_HEADER_VIEW_HEIGHT)];
        [headerView setBackgroundColor:[UIColor blackColor]];
        
        CGFloat button_width = 280.0f*SCALE_IPAD;
        CGFloat button_height = 44.0f*SCALE_IPAD;
        CGFloat button_x = (UIScreen.mainScreen.bounds.size.width - button_width)/2;
        CGFloat button_y = (TABLE_HEADER_VIEW_HEIGHT - button_height);
        
        UIButton *button1 = [UIManager.i dynamicButtonWithTitle:NSLocalizedString(@"Delete Reports", nil)
                                                         target:self
                                                       selector:@selector(button1_tap:)
                                                          frame:CGRectMake(button_x, button_y, button_width, button_height)
                                                           type:@"2"];
        
        [headerView addSubview:button1];
        
        return headerView;
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.reportArray.count > 0)
    {
        return TABLE_FOOTER_VIEW_HEIGHT;
    }
    else
    {
        return 0;
    }
}

@end

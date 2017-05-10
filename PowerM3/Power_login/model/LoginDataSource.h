//
//  LoginDataSource.h
//  PowerM3
//
//  Created by ImperialSeal on 16/12/3.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFJModel.h"

@interface LoginDataSource : RFJModel
JProperty(NSString *logoImage, Logo);
JProperty(NSString *subTitle, SubTitle);
JProperty(NSString *title, Title);
@end

@interface LoginSuccessedDataSource : RFJModel
JProperty(NSString *app_email, app_email);
JProperty(NSString *app_mobile, app_mobile);
JProperty(NSString *humanid, humanid);
JProperty(NSString *sessionid, sessionid);
JProperty(NSString *app_autoOpenUrl, app_autoOpenUrl);
JProperty(NSString *app_downloadCookie, app_downloadCookie);
JProperty(NSString *app_smallheadid, app_smallheadid);
JProperty(NSString *name, app_humanname);
@end

@interface LoginWebViewURL : RFJModel
JProperty(NSString *icon, icon);
JProperty(NSString *iconselected, iconselected);
JProperty(NSString *name, name);
JProperty(NSString *url, url);
JProperty(NSString *title, title);
JProperty(NSString *titleid, titleid);
- (void)replaceEpsProjIdOrHumainId;
@end


@interface PowerProjectListModel :RFJModel
JProperty(BOOL projectType, project_type);
JProperty(NSString *project_guid, project_guid);
JProperty(NSString *project_name, project_name);
JProperty(NSString *parent_guid, parent_guid);
JProperty(NSString *project_shortname, project_shortname);
@end

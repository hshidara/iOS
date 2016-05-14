//
//  DetailsViewController.h
//  Waffle_Test_Obj-C
//
//  Created by Hidekazu Shidara on 5/12/16.
//  Copyright © 2016 Hidekazu Shidara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UIViewController

@property NSMutableString *title_text, *publisher_text, *url_text;
@property NSMutableArray<NSString *> *ingredients_text;
@property UIImage *image;
@property UIImageView *photo;

-(void)setLabels;
-(void)setTitle;
-(void)setPublisher;
-(void)setURL;
-(void)setPhoto;
-(void)setIngredients;

@end

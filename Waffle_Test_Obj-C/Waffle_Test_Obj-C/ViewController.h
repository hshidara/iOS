//
//  ViewController.h
//  Waffle_Test_Obj-C
//
//  Created by Hidekazu Shidara on 5/11/16.
//  Copyright © 2016 Hidekazu Shidara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Recipe : NSObject{
    NSMutableArray<NSMutableString *> *ingredients;
}

@property NSMutableString *publisher,*title,*photo_url,*link,*recipeID;
@property UIImage *photo;
@property (nonatomic,retain) NSMutableArray<NSMutableString *> *ingredients;

-(id)initWithName:(NSDictionary *)dictionary;
-(UIImage *)getPhoto: (NSString *)str;
-(void)fetchIngredients:(NSString *)Id;

@end

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *tableView;
    NSMutableArray<Recipe *> *recipes;
    //  This is basically the indexPath.row for each cell, but had to pass it to the PrepareForSegue
    //  method somehow.
    NSInteger recipe_index;
}

-(void)setTableView;
-(void)fetchRecipes;

@end

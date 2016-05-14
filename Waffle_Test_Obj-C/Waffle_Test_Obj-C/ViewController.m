//
//  ViewController.m
//  Waffle_Test_Obj-C
//
//  Created by Hidekazu Shidara on 5/11/16.
//  Copyright © 2016 Hidekazu Shidara. All rights reserved.
//

#import "ViewController.h"
#import "DetailsViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"2016 Best Recipes";
    recipes = [[NSMutableArray<Recipe *> alloc]init];
    recipe_index = 0;
    
    [self setTableView];
    [self fetchRecipes];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//  MARK: Setup Methods

-(void)setTableView{
    tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    tableView.delegate      = self;
    tableView.dataSource    = self;
    [self.view addSubview:tableView];
}

//  MARK: TableView Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return recipes.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].selected = false;
    recipe_index = indexPath.row;
    [self performSegueWithIdentifier:@"segue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier  isEqual: @"segue"]){
        DetailsViewController *vc   = [segue destinationViewController];
        vc.title_text               = recipes[recipe_index].title;
        vc.publisher_text           = recipes[recipe_index].publisher;
        vc.url_text                 = recipes[recipe_index].link;
        vc.image                    = recipes[recipe_index].photo;
        vc.ingredients_text         = recipes[recipe_index].ingredients;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //  FIXME: Very inefficient, allocates space for each and every cell, should use deque.
    UITableViewCell *cell               = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    if(recipes.count > 0){
        cell.accessoryType              = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text             = recipes[indexPath.row].title;
        cell.detailTextLabel.text       = recipes[indexPath.row].publisher;
        //  Format the pictures
        cell.imageView.image            = recipes[indexPath.row].photo;
        cell.imageView.contentMode      = UIViewContentModeScaleAspectFill;
    }
    return cell;
}

//  MARK: Fetching Methods
-(void)fetchRecipes{
    NSURL *url = [NSURL URLWithString:@"http://food2fork.com/api/search?key={API_KEY}&sort=t"];
    NSURLSession *session = [NSURLSession sharedSession];
    //  Queries the network for the recipes.
    //  The way it works is that it queries once for the list of recipes. Then for each recipe,
    //  a single query is made to retrieve it's info.
    //  FIXME: A better and more efficient way is to retrieve info of a specific query after the cell is
    //  selected, most likely this will save many queries, right now, the implementation costs 31 queries
    //  at every time. Can be offsetted with the new strategy and by saving recipes using CoreData.
    NSURLSessionDataTask *data_task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error){
            NSDictionary *list = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSMutableArray<NSDictionary *> *ar = list[@"recipes"];
            //  Time to fill up the recipe list
            for (int i = 0; i < ar.count-1; i++) {
                [recipes addObject:[[Recipe alloc]initWithName:ar[i]]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadData];
            });
            
        }
        else{
            NSLog(@"ERROR");
        }
    }];
    [data_task resume];
}

@end

//  Recipe Class
@interface Recipe ()

@end

//  Class to hold the recipes.
@implementation Recipe

-(id)initWithName:(NSDictionary *)dictionary{
    self = [super init];
    if(self){
        //  init variables here
        _publisher      = dictionary[@"publisher"];
        _title          = dictionary[@"title"];
        _photo_url      = dictionary[@"image_url"];
        _link           = dictionary[@"source_url"];
        _recipeID       = dictionary[@"recipe_id"];
        _photo          = [self getPhoto:_photo_url];
        _ingredients    = [[NSMutableArray<NSMutableString *> alloc] init];
    }
    [self fetchIngredients :_recipeID];
    return self;
}

//  Queries upon instantiation all the information about the specific recipe.
-(void)fetchIngredients:(NSString *)Id{
    NSMutableString *str = [NSMutableString stringWithFormat:@"http://food2fork.com/api/get?key={API_KEY}&rId="];
    [str appendString:Id];
    NSURL *url = [NSURL URLWithString:str];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *data_task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error){
            NSDictionary *list = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSDictionary *recipe_list = list[@"recipe"];
            NSArray<NSMutableString *> *ingredients_list = recipe_list[@"ingredients"];
            [_ingredients addObjectsFromArray:ingredients_list];
        }
        else{
            NSLog(@"%@",error);
        }
    }];
    [data_task resume];
}

//  Done Synchronously, retrieves photo from the url and returns it.
-(UIImage *)getPhoto: (NSString *)str{
    NSURL *url = [NSURL URLWithString:str];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:data];
}

-(void)dealloc{
    self.publisher = nil;
    self.title = nil;
    self.photo_url = nil;
    self.link = nil;
    self.recipeID = nil;
    self.photo = nil;
    self.ingredients = nil;
}

@end

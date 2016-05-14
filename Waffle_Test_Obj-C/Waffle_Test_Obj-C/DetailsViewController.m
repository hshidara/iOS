//
//  DetailsViewController.m
//  Waffle_Test_Obj-C
//
//  Created by Hidekazu Shidara on 5/12/16.
//  Copyright © 2016 Hidekazu Shidara. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *title_label;
@property (weak, nonatomic) IBOutlet UILabel *publisher_label;
@property (weak, nonatomic) IBOutlet UIButton *url_label;
@property (weak, nonatomic) IBOutlet UILabel *ingredients_label;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLabels];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)did_press_url:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_url_text]];
}

-(void)setLabels{
    //  Setting up the text for each label.
    [self setTitle];
    [self setPublisher];
    [self setURL];
    [self setPhoto];
    [self setIngredients];
}

-(void)setTitle{
    _title_label.text               = _title_text;
    
    _title_label.backgroundColor    = [UIColor clearColor];
    _title_label.font               = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];

}
-(void)setPublisher{
    _publisher_label.text       = @"Brought to you by:\n";
    _publisher_label.text       = [_publisher_label.text stringByAppendingString:_publisher_text];
    
    _publisher_label.backgroundColor    = [UIColor clearColor];
    _publisher_label.font           = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:15];
}

-(void)setURL{
    [_url_label setTitle:_url_text forState:UIControlStateNormal];
    _url_label.tintColor = [UIColor redColor];
    _url_label.titleLabel.numberOfLines = 4;
    
    _url_label.backgroundColor          = [UIColor clearColor];

}

-(void)setPhoto{
    _photo                = [[UIImageView alloc]initWithImage:_image];
    _photo.frame          = [UIScreen mainScreen].bounds;
    _photo.contentMode    = UIViewContentModeScaleAspectFill;
    _photo.alpha          = 0.4;
    _photo.tintColor      = [UIColor blackColor];
    
    [self.view addSubview:_photo];
    [self.view sendSubviewToBack:_photo];
}

-(void)setIngredients{
    _ingredients_label.text     = @"";
    for (int i = 0; i < _ingredients_text.count; i++) {
        _ingredients_label.text = [_ingredients_label.text stringByAppendingString:_ingredients_text[i]];
        _ingredients_label.text = [_ingredients_label.text stringByAppendingString:@"\n"];
    }
    
    _ingredients_label.backgroundColor  = [UIColor clearColor];
    
    //  Some basic arithmetic is done to determine the size of the ingredient text. If there are a lot
    //  of ingredients, the size of the text will shrink, likewise, it will grow if there are fewer
    //  ingredients.
    //  FIXME: Can be done more dynamically and more smoothly.
    if(150/_ingredients_text.count < 13){
        _ingredients_label.font     = [UIFont fontWithName:@"Futura-Medium" size:150/_ingredients_text.count];
    }
    else{
        _ingredients_label.font     = [UIFont fontWithName:@"Futura-Medium" size:13];
    }
}

@end

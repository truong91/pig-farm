/**
* Name: FoodDiseaseFactor
* Author: Lê Đức Toàn
*/


model FoodDiseaseFactor


import './factor.gaml'


species FoodDiseaseFactor parent: Factor {
	init {
		b <- 100.0;
	}
}
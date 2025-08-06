/**
* Name: WaterDiseaseFactor
* Author: Lê Đức Toàn
*/


model WaterDiseaseFactor

import './factor.gaml'


species WaterDiseaseFactor parent: Factor {
	init {
		b <- 10.0;
	}
}
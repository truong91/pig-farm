model Simulator

import './farm.gaml'
import './pig.gaml'
import './gas-concentration.gaml'

global {
	int speed;
	string experiment_id;

	init {
		file pigs <- csv_file("../includes/input/pigs.csv", true);
		speed <- 45;
		create Pig from: pigs with: [feeding_regime::2];
		create Pigpen number: 1;
		create Trough number: 5;
		loop i from: 0 to: 4 {
			Trough[i].location <- trough_locs[i];
		}

		ask Pigpen {
			do update_emissions(list(Pig));
		}

	}

	reflex update_concentration when: mod(cycle, 24 * 60) = 0 {
		ask Pigpen {
			do update_emissions(list(Pig));
		}

	}

	reflex stop when: cycle = 60 * 24 * 55 {
		do pause;
	}

}

experiment NormalFixedDiet {
	float co2_concentration <- 0.0;
	float ch4_concentration <- 0.0;
	rgb co2_color <- #green;
	rgb ch4_color <- #green;
	int current_day <- -1;
	parameter "Experiment ID" var: experiment_id <- "";
	output {
		display Simulator name: "Simulator" {
			grid Background;
			species Pig aspect: base;
			overlay position: {2, 2} size: {10, 5} background: #black transparency: 1 {
				int new_day <- floor(cycle / (24 * 60));
				if (new_day != current_day) {
					co2_concentration <- Pigpen(0).co2_concentration();
					ch4_concentration <- Pigpen(0).ch4_concentration();
					co2_color <- (co2_concentration > 1500) ? #red : #green;
					ch4_color <- (ch4_concentration > 500) ? #red : #green;
					current_day <- new_day;
				}

				draw "Day " + current_day color: #black at: {0, 20} font: font("Arial", 14, #plain);
				draw "CO2 level: " + co2_concentration with_precision 0 + " PPM" at: {0, 60} color: co2_color font: font("Arial", 14, #plain);
				draw "CH4 level: " + ch4_concentration with_precision 0 + " PPM" at: {0, 90} color: ch4_color font: font("Arial", 14, #plain);
			}

		}

		display DFI name: "DFI" refresh: every((60 * 24) #cycles) {
			chart "DFI" type: series {
				loop pig over: Pig {
					data string(pig.id) value: pig.dfi;
				}

			}

		}

		display Weight name: "Weight" refresh: every((60 * 24) #cycles) {
			chart "Weight" type: histogram {
				loop pig over: Pig {
					data string(pig.id) value: pig.weight;
				}

			}

		}

		//		display CFIPig0 name: "CFIPig0" refresh: every((60 * 24) #cycles) {
		//			chart "CFI vs Target CFI" type: series {
		//				data 'CFI' value: Pig[0].cfi;
		//				data 'Target CFI' value: Pig[0].target_cfi;
		//			}
		//
		//		}
		//
		//		display DFIPig0 name: "DFIPig0" refresh: every((60 * 24) #cycles) {
		//			chart "DFI vs Target DFI" type: series {
		//				data 'DFI' value: Pig[0].dfi;
		//				data 'Target DFI' value: Pig[0].target_dfi;
		//			}
		//
		//		}
		display DailyCO2Emission name: "DailyCO2Emission" refresh: every((60 * 24) #cycles) {
			chart "Daily CO2 emission (kg)" type: series {
				loop pig over: Pig {
					data string(pig.id) value: pig.daily_co2_emission;
				}

			}

		}

		display DailyCH4Emission name: "DailyCH4Emission" refresh: every((60 * 24) #cycles) {
			chart "Daily CH4 emission (kg)" type: series {
				loop pig over: Pig {
					data string(pig.id) value: pig.daily_ch4_emission;
				}

			}

		}

		display TotalCO2Emission name: "TotalCO2Emission" refresh: every((60 * 24) #cycles) {
			chart "Total cumulative CO2 emission (kg)" type: series {
				data "CO2" value: Pig sum_of (each.cumulative_co2_emission) color: #blue;
			}

		}

		display TotalCH4Emission name: "TotalCH4Emission" refresh: every((60 * 24) #cycles) {
			chart "Total cumulative CH4 emission (kg)" type: series {
				data "CH4" value: Pig sum_of (each.cumulative_ch4_emission) color: #red;
			}

		}

	}

	reflex log when: mod(cycle, 24 * 60) = 0 {
		ask simulations {
			float total_CO2_emission <- Pig sum_of (each.cumulative_co2_emission);
			float total_CH4_emission <- Pig sum_of (each.cumulative_ch4_emission);
			loop pig over: Pig {
				save
				[floor(cycle / (24 * 60)), pig.id, pig.target_dfi, pig.dfi, pig.target_cfi, pig.cfi, pig.weight, pig.eat_count, pig.excrete_each_day, pig.excrete_count, pig.daily_co2_emission, pig.daily_ch4_emission, pig.cumulative_co2_emission, pig.cumulative_ch4_emission]
				to: "../includes/output/normal-fixeddiet/" + experiment_id + "-" + string(pig.id) + ".csv" rewrite: false format: "csv";
			}

			save [floor(cycle / (24 * 60)), total_CO2_emission, total_CH4_emission] to: "../includes/output/normal-fixeddiet/" + experiment_id + "-emission-fixeddiet" + ".csv" rewrite: false format: "csv";
		}

	}

//	reflex capture when: mod(cycle, speed) = 0 {
//		ask simulations {
//			save (snapshot(self, "Simulator", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-simulator-" + string(cycle) + ".png";
//			save (snapshot(self, "DFI", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-dfi-" + string(cycle) + ".png";
//			save (snapshot(self, "Weight", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-weight-" + string(cycle) + ".png";
//			save (snapshot(self, "CFIPig0", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-cfipig0-" + string(cycle) + ".png";
//			save (snapshot(self, "DFIPig0", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-dfipig0-" + string(cycle) + ".png";
//			save (snapshot(self, "DailyCO2Emission", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-dailyco2emission-" + string(cycle) + ".png";
//			save (snapshot(self, "DailyCH4Emission", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-dailych4emission-" + string(cycle) + ".png";
//			save (snapshot(self, "TotalCO2Emission", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-totalco2emission-" + string(cycle) + ".png";
//			save (snapshot(self, "TotalCH4Emission", {500.0, 500.0})) to: "../includes/output/normal/" + experiment_id + "-totalch4emission-" + string(cycle) + ".png";
//		}
//
//	}

}
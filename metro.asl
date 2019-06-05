// Agent metro in project metroTest.mas2j



/* Initial beliefs and rules */

/* Initial goals */
!initStationsAndTrains.

/* Plans */
//Создание агентов линий и агентов поездов,
//основываясь на количестве линий и станций,
//полученных от среды
+!initStationsAndTrains <- 
.findall(LineName, line(LineName, _), L);
for(.member(Line, L)) {
	?line(Line, LineStations);
	for(.member(Station, LineStations)) {
		.nth(I, LineStations, Station);
		.concat(Line, "_station", I, StationName);		
		.create_agent(StationName, "station.asl");
		.send(Station, tell, mainLine(Line));
		.concat(Line, "_train", I, TrainName);		
		.create_agent(TrainName, "train.asl");
		.send(TrainName, tell, mainLine(Line));
	}
};
.broadcast(tell, metroIsOpen).



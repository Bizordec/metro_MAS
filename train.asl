// Agent train in project metroTest2.mas2j

/* Initial beliefs and rules */
p_list([]).

/* Initial goals */

/* Plans */
+metroIsOpen <- 
!getStartStation;
!go.

//Получение начального направления и начальной станции
+!getStartStation <-
?mainLine(MainLine);
?line(MainLine, StationList);
D = math.round(math.random(1));
+direction(D);
.length(StationList, StationListLength);
StationPosition = math.round(math.random(StationListLength - 1));
.nth(StationPosition, StationList, Station);
.send(Station, askOne, train(D), A);
//Если на полученной станции уже есть поезд,
//то получить станцию заново
if (A \== false) {
	!getStartStation;
} else {
	-+currentStation(Station);
}.

//Здесь описывается движение поезда по направлению 0 или 1
//0 - от "меньшей" станции к "большей" (например, от station0 к station1)
//1 - от "большей" станции к "меньшей" (например, от station1 к station0)
+!go <-
?currentStation(CurrentStation);
?direction(D);
//Удаление из базы убеждения текущей станции данный поезд
.send(CurrentStation, untell, train(D));
?mainLine(MainLine);
?line(MainLine, StationList);
.nth(StationPosition, StationList, CurrentStation);
.length(StationList, StationListLength);
//Если поезд приезжает на конечную станцию,
//то сменить направление
if(D == 0) {
	NextStationPosition = StationPosition + 1;
	if(NextStationPosition == StationListLength) {
		.nth(NextStationPosition - 1, StationList, NextStation);
		-+direction(1);
		!checkNextTrain(1, NextStation);
	} else {
		.nth(NextStationPosition, StationList, NextStation);
		!checkNextTrain(0, NextStation);
	}
} elif(D == 1){
	NextStationPosition = StationPosition - 1;
	if(NextStationPosition < 0) {
		.nth(0, StationList, NextStation);
		-+direction(0);
		!checkNextTrain(0, NextStation);
	} else {
		.nth(NextStationPosition, StationList, NextStation);
		!checkNextTrain(1, NextStation);
	}
}.

//Проверка наличия поезда на следующей линии
+!checkNextTrain(D, NextStation) <-
.send(NextStation, askOne, train(D), A);
-+currentStation(NextStation);
?p_list(PL);
//Добавление в базу убеждения следующей станции данный поезд
.send(NextStation, tell, train(D));
//Прибытие на следующую станцию
.send(NextStation, achieve, arrived(D, PL)).

//Обновление списка пассажиров
+!updatePassengers(NewPassengersOnTrain)[source(Station)] <-
.abolish(p_list(_));
+p_list(NewPassengersOnTrain).

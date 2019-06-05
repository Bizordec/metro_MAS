// Agent passenger in project metroTest.mas2j

/* Initial beliefs and rules */

/* Initial goals */

/* Plans */
+metroIsOpen <- 
//Получение информации о количестве линий в метро
.count(line(_, _), LN);
//Инициализация начальной станции и линии
!initStation(LN, LB, B);
+currentLine(LB);
+currentStation(B);
//Инициализация конечной станции
!initStation(LN, LE, E);
//Получение пути от среды по алгоритму Дейкстры
getPath(B, E);
?path(Path);
.print("My path is ", Path);
!checkStation.

+!initStation(LN, S_line, S_name) <-
//Выборка линии
L_rand = math.round(math.random(LN - 1)) + 1;
.concat(line, L_rand, L_stringName);
.term2string(S_lineTemp, L_stringName);
//Выборка станции на линии
?line(S_lineTemp, S_list);
.length(S_list, S_listLength);
S_posTemp = math.round(math.random(S_listLength - 1));
.nth(S_posTemp, S_list, S_nameTemp);
//Если конечная станция будет равна стартовой, 
//то провести инициализацию заново
if(currentStation(C) & C == S_nameTemp) {
	!initStation(LN, S_line, S_name);
} else {
	S_line = S_lineTemp;
	S_name = S_nameTemp;
}.

//Получение направления
+!getDirection([Current, Next|_]) <-
	?currentStation(CurrentStation);
	?currentLine(CurrentLine);
	?line(CurrentLine, LineStations);
	//Если следующая станция находится на текущей линии, то
	//получаем номера текущей и следующей станции и сравниваем их
	if(.member(Next, LineStations)) {
		.concat(CurrentLine, "_station", LineX_station);
		.delete(LineX_station, CurrentStation, CurrentStringNumber);
		.term2string(CurrentNumber, CurrentStringNumber);
		.delete(LineX_station, Next, NextStringNumber);
		.term2string(NextNumber, NextStringNumber);
		if(CurrentNumber < NextNumber) {
			-+direction(0);
		} else {
			-+direction(1);
		};
		?direction(D);
		.my_name(Name);
		.send(CurrentStation, tell, passenger(D))
	//Если следующая станция находится на другой линии, то нужно сделать пересадку
	} else {
		?path(Path);
		!transfer(Next, Path);
	}.

//Пересадка
+!transfer(Next, [_|PathAfterTransfer]) <-
	//Заменяем текущую станцию и линию на следующие
	.findall(LineName, line(LineName, _), Lines);
	for(.member(NextLine, Lines)) {
		?line(NextLine, Stations);
		if(.member(Next, Stations)) {
			-+currentLine(NextLine);
		}
	}
	-+currentStation(Next);
	-+path(PathAfterTransfer)[source(percept)];
	//Если в списке пути после пересадки еще есть станции, то ищем направление
	if(.length(PathAfterTransfer, PathLength) & PathLength > 1) {
		!getDirection(PathAfterTransfer);
	//Если нет - пассажир приехал
	} else {
		.print("!!!!!!!!!!!!!!!!!!!! I arrived to my destination (", Next, ") after transfer !!!!!!!!!!!!!!!!!!!!");
		.my_name(N);
		.kill_agent(N);
	}.

//Если начальная и следующая станции находятся на разных линиях,
//то сделать пересадку
+!checkStation[source(self)] : currentStation(Station) & 
							path([Station, TransferStation|Other]) & 
							currentLine(CurrentLine) &
							line(CurrentLine, LineStations) & 
							not .member(TransferStation, LineStations) <-
-+currentStation(Station);
?path(Path);
?currentStation(Curr);
.print("---------- Was on ", Station, ", making transfer to ", TransferStation, " ----------");
.send(Station, tell, passengerArrived);
!getDirection(Path).

//Если начальная и следующая станции находятся на одной линии,
//то найти направление
+!checkStation[source(self)] <-
?path(Path);
!getDirection(Path).

//Если в списке пути больше нет станций, 
//то пассажир приехал на конечную станцию
+!checkStation[source(Station)] : path([_, Station|[]]) <-
-+currentStation(Station);
.send(Station, tell, passengerArrived);
.print("!!!!!!!!!!!!!!!!!!!! I arrived to my destination (", Station, ") !!!!!!!!!!!!!!!!!!!!");
.my_name(N);
.kill_agent(N).

//Если текущая и следующая станции находятся на разных линиях,
//то пассажир приехал на станцию пересадки
+!checkStation[source(Station)] : path([_, Station, TransferStation|Other]) & 
							currentLine(CurrentLine) &
							line(CurrentLine, LineStations) & 
							not .member(TransferStation, LineStations) <-
-+currentStation(Station);
?path([_|Path]);
-+path(Path)[source(percept)];
.send(Station, tell, passengerArrived);
?currentStation(Curr);
.print("---------- Was on ", Station, ", making transfer to ", TransferStation, " ----------");
!transfer(TransferStation, Path).

//Если текущая и следующая станции находятся на одной линии,
//то пассажир едет дальше
+!checkStation[source(Station)]: path([_, Station|_]) <-
-+currentStation(Station);
?path([_|Path]);
-+path(Path)[source(percept)];
.print("Not my station yet.");.


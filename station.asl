// Agent station in project metroTest2.mas2j

/* Initial beliefs and rules */

/* Initial goals */

/* Plans */
+!arrived(D, PassengersOnTrain)[source(T)] <-
?mainLine(MainLine);
.my_name(StationName);
//Получение списка пассажиров на станции
.findall(Name, passenger(D)[source(Name)], PassengersOnStation);
//Удаление всех пассажиров из базы убеждения данной станции 
.abolish(passenger(D));
//Если пассажир приехал, 
//то удалить его из списка поезда
for(.member(PT, PassengersOnTrain)) {
	.send(PT, achieve, checkStation);
	.wait({+passengerArrived[source(PT)]}, 100, Time);
	if(Time < 100) {
		.send(T, askOne, p_list(CurrentPassengers), p_list(CurrentPassengers));
		.delete(PT, CurrentPassengers, NewPassengersOnTrain);
		.send(T, achieve, updatePassengers(NewPassengersOnTrain));
		.abolish(passengerArrived[source(PT)]);
	}
}
//Конкатенация получившегося списка поезда со списком станции и
//отправление нового списка поезду
.send(T, askOne, p_list(PassengersAfterArrival), p_list(PassengersAfterArrival));
.concat(PassengersAfterArrival, PassengersOnStation, NewPassengersOnTrain);
.send(T, achieve, updatePassengers(NewPassengersOnTrain));
//Вывод на экран только тех поездов, у которых имеется непустой список пассажиров
.concat(PassengersOnTrain, NewPassengersOnTrain, List);
if(.length(List, Length) & Length > 0) {
	.print("----- ", T, "(direction ", D, ") ----- arrived with ", PassengersOnTrain, ", departed with ", NewPassengersOnTrain);
}
//Задержка для имитации остановки поезда на станции
.wait(1000);
//Отправка поезду сигнала о продолжении движения
.send(T, achieve, go).

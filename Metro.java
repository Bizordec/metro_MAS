import java.util.*;

class Metro {
    private HashSet<Node> stations = new HashSet<>();
    private HashMap<String, Node> stationsMap = new HashMap<>();

    private void populateStationsMap(LinkedList<String> line){
        for (String stationName : line) {
            if (!stationsMap.containsKey(stationName)){
                Node currentStation = new Node(stationName);
                stationsMap.put(stationName, currentStation);
            }
        }
    }

    public void addLine(LinkedList<String> line) {
        populateStationsMap(line);
        for (String stationName : line) {
            addAdjacentStations(line, getStation(stationName));
            stations.add(getStation(stationName));
        }
    }

    public void addTransfer(LinkedList<String> line) {
        populateStationsMap(line);
        for (String station : line) {
            for (String anotherStation : line) {
                if (!anotherStation.equals(station)){
                    getStation(station).addDestination(getStation(anotherStation),1);
                }
            }
            stations.add(getStation(station));
        }
    }

    private void addAdjacentStations(LinkedList<String> line, Node currentStation){
        int index = line.indexOf(currentStation.getName());
        if (index < line.size() - 1)
            currentStation.addDestination(getStation(line.get(index + 1)), 1);
        if (index - 1 >= 0)
            currentStation.addDestination(getStation(line.get(index - 1)), 1);
    }

    public Node getStation(String stationName){
        return stationsMap.get(stationName);
    }

    public synchronized  List<String> calculateFastestPath(String start, String end){
        stations.forEach(Node::reset);
        Dijkstra.calculateShortestPathFromSource(getStation(start));
        List<String> pathStations = new LinkedList<>();
        for (Node station : getStation(end).getShortestPath()) {
            pathStations.add(station.getName());
        }
        pathStations.add(end);
        return pathStations;
    }
}
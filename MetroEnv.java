// Environment code for project metro.mas2j

import java.util.*;
import jason.asSyntax.*;
import jason.environment.*;
import jason.runtime.*;
import java.util.logging.*;

public class MetroEnv extends jason.environment.TimeSteppedEnvironment {

    private Logger logger = Logger.getLogger("metro.mas2j." + MetroEnv.class.getName());
	private Metro metro = new Metro();
	
    /** Called before the MAS execution with the args informed in .mas2j */
    @Override
    public void init(String[] args) {
        super.init(new String[] { "500" } );
        setOverActionsPolicy(OverActionsPolicy.ignoreSecond);
		LinkedList<String> line1 = new LinkedList<>();
		LinkedList<String> line2 = new LinkedList<>();
		LinkedList<String> line3 = new LinkedList<>();
		try {
			for (int i = 0; i <= 6; i++) {
				String stationName = "line1_station" + i;
				line1.add(stationName);
			}
			for (int i = 0; i <= 5; i++) {
				String stationName = "line2_station" + i;
				line2.add(stationName);
			}
			for (int i = 0; i <= 4; i++) {
				String stationName = "line3_station" + i;
				line3.add(stationName);
			}
		} catch(Exception e){
			logger.info("Failed to init stations!");
		};

        LinkedList<String> transfer1 = new LinkedList<>();
        transfer1.add("line1_station2");
        transfer1.add("line2_station2");

        LinkedList<String> transfer2 = new LinkedList<>();
        transfer2.add("line2_station3");
        transfer2.add("line3_station2");

        LinkedList<String> transfer3 = new LinkedList<>();
        transfer3.add("line1_station4");
        transfer3.add("line3_station3");
		
        metro.addLine(line1);
        metro.addLine(line2);
        metro.addLine(line3);

        metro.addTransfer(transfer1);
        metro.addTransfer(transfer2);
        metro.addTransfer(transfer3);
		metro.calculateFastestPath("line1_station6", "line2_station5");
        metro.calculateFastestPath("line2_station3", "line1_station0");
		
		addPercept(Literal.parseLiteral("line(line1, " + line1.toString() + ")"));
		addPercept(Literal.parseLiteral("line(line2, " + line2.toString() + ")"));
		addPercept(Literal.parseLiteral("line(line3, " + line3.toString() + ")"));
    }

    @Override
	public boolean executeAction(String agName, Structure action) {
		if (action.getFunctor().equals("getPath")) {
				List<String> path = metro.calculateFastestPath(action.getTerms().get(0).toString(),
															action.getTerms().get(1).toString());
				addPercept(agName, Literal.parseLiteral("path(" + path.toString() + ")"));
		}
        return true; // the action was executed with success
    }
	
    /** Called before the end of MAS execution */
    @Override
    public void stop() {
        super.stop();
    }
}



package tfg.fuzzy.primitives.creation;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.LogoList;
import org.nlogo.api.Syntax;

import tfg.fuzzy.general.SupportFunctions;
import tfg.fuzzy.sets.points.IntervalWithPointsSet;

/**
 * This class creates a new interval with points set. Implements the primitive
 * "interval-with-points-set".
 * 
 * @author Marcos Almendres.
 *
 */
public class Interval extends DefaultReporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a list and returns a Wildcard.
	 */
	public Syntax getSyntax() {
		return Syntax.reporterSyntax(new int[] { Syntax.ListType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A new IntervalWithPointsSet.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		LogoList params = arg0[0].getList();
		LogoList paramsDef = (LogoList) params.get(0);
		LogoList paramsPoints = (LogoList) params.get(1);
		// Checks the format of the parameters
		double[] universe = SupportFunctions.IWPFormat(params);
		// Checks the format of the list of points inside the parameters
		// Creates and return the new set
		return new IntervalWithPointsSet(
				SupportFunctions.checkListFormat(paramsPoints), true,
				"Interval", universe, (Double) paramsDef.get(1));
	}
}

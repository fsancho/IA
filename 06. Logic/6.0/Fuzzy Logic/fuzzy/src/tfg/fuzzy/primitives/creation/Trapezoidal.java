package tfg.fuzzy.primitives.creation;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.LogoList;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.SupportFunctions;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class creates a new piecewise linear set representing a trapezoidal set.
 * Implements the primitive "trapezoidal-set"
 * 
 * @author Marcos Almendres.
 *
 */
public class Trapezoidal implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a list and returns a Wildcard.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.ListType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A new PiecewiseLinearSet.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		LogoList args = arg0[0].getList();
		// Checks the format of the arguments
		// Create the universe
		// Create and return the new set
		return new PiecewiseLinearSet(SupportFunctions.trapezoidalFormat(args),
				true, "piecewise", new double[] { (Double) args.first(),
						(Double) args.get(5) });
	}
}

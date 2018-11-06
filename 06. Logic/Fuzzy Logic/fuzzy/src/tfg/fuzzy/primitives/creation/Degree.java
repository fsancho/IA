package tfg.fuzzy.primitives.creation;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class calculate the degree of fulfillment of two sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class Degree implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives 2 wildcards and returns a number.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(
				new int[] { Syntax.WildcardType(), Syntax.WildcardType() },
				Syntax.NumberType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the degree of
	 * fulfillment of 2 given sets.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case two
	 *            wildcards(Objects from java).
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return The degree of fulfillment of the two sets.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		// Get both sets
		FuzzySet a = (FuzzySet) arg0[0].get();
		FuzzySet b = (FuzzySet) arg0[1].get();
		// If both are not continuous call to discrete fulfillment
		if (!a.isContinuous() && !b.isContinuous()) {
			return DegreeOfFulfillment.discreteFulfillment((PointSet) a,
					(PointSet) b);
		} else if (a instanceof PiecewiseLinearSet
				&& b instanceof PiecewiseLinearSet) {// If both piecewise call
														// piecewise fulfillment
			return DegreeOfFulfillment.piecewiseFulfillment((PointSet) a,
					(PointSet) b);
		} else {// In any other case call mixed fulfillment
			return DegreeOfFulfillment.mixedFulfillment(a, b);
		}
	}
}

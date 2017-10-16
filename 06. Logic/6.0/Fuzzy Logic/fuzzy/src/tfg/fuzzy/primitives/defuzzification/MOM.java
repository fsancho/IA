package tfg.fuzzy.primitives.defuzzification;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.SupportFunctions;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class implements the mom-of primitive.Middle of Maxima.
 * 
 * @author Marcos Almendres.
 *
 */
public class MOM implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and returns a number.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.WildcardType() },
				Syntax.NumberType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the middle of
	 * the maximum values of a fuzzy set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A number with the middle of maxima of the fuzzy set.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzySet f = (FuzzySet) arg0[0].get();
		double[] universe = f.getUniverse();
		double maximum = Double.NEGATIVE_INFINITY;
		double maximum2 = Double.NEGATIVE_INFINITY;
		double maxVal = Double.NEGATIVE_INFINITY;
		boolean twoMax = false;
		// If universe empty
		if (universe.length == 0) {
			new ExtensionException(
					"You have tried to compute the FOM of an empty set");
		}
		// If continuous but not piecewise
		if (f.isContinuous() && !(f instanceof PiecewiseLinearSet)) {
			// First number to evaluate
			double x = universe[0];
			// Number of points to evaluate(Depends on resolution)
			double steps = Math
					.floor(1 + ((universe[1] - universe[0]) * SupportFunctions
							.getResolution()));
			double eval = 0;
			for (int i = 0; i < steps; i++) {
				eval = f.evaluate(x);
				// if bigger than the stored max value, save the x, update max
				// value and set false the two-maximum-found boolean
				if (eval > maxVal) {
					maximum = x;
					maxVal = eval;
					twoMax = false;
				} else if (eval == maxVal) {// if equal to the stored max value,
											// save the x in the second maximum
											// and set the boolean to true
					maximum2 = x;
					twoMax = true;
				}
				// Increment 1/Resolution times
				x = x + (1 / SupportFunctions.getResolution());
			}
		} else {
			PointSet ps = (PointSet) f;
			for (double[] point : ps.getParameters()) {
				double y = point[1];
				// if bigger than the stored max value, save the x, update max
				// value and set false the two-maximum-found boolean
				if (y > maxVal) {
					maximum = point[0];
					maxVal = y;
					twoMax = false;
				} else if (y == maxVal) {// if equal to the stored max value,
											// save the x in the second maximum
											// and set the boolean to true
					maximum2 = point[0];
					twoMax = true;
				}
			}
		}
		if (twoMax) {
			return (maximum + maximum2) / 2;
		} else {
			return maximum;
		}
	}

}

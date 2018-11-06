package tfg.fuzzy.primitives.defuzzification;

import java.util.List;

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
 * This class implements the cog-of primitive.Center of gravity.
 * 
 * @author Marcos Almendres.
 *
 */
public class COG implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and returns a number.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.WildcardType() },
				Syntax.NumberType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the center of
	 * gravity of a fuzzy set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A number with the center of gravity of a fuzzy set.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzySet f = (FuzzySet) arg0[0].get();
		double[] universe = f.getUniverse();
		// If universe empty
		if (universe.length == 0) {
			new ExtensionException(
					"You have tried to compute the FOM of an empty set");
		}
		if (f.isContinuous()) {
			// If continuous and piecewise linear
			if (f instanceof PiecewiseLinearSet) {
				return piecewiseCOG((PointSet) f);
			} else {// If just continuous
				return continuousCOG(f);
			}
		} else {// If discrete
			return discreteCOG((PointSet) f);
		}
	}

	/**
	 * Calculate the center of gravity of a piecewise linear set.
	 * 
	 * @param f
	 *            The piecewise linear set.
	 * @return The center of gravity.
	 */
	public double piecewiseCOG(PointSet f) {
		List<double[]> params = f.getParameters();
		double[] universe = f.getUniverse();
		int i = 0;
		double massesTimes2 = 0;
		double centerTimesmassesTimes6 = 0;
		double[] point1;
		double[] point2;
		double x1, x2, y1, y2 = 0;
		// Iterate over the parameters
		while (i < params.size() - 1) {
			point1 = params.get(i);
			point2 = params.get(i + 1);
			x1 = point1[0];
			x2 = point2[0];
			y1 = point1[1];
			y2 = point2[1];
			// Calculate massesTimes2
			// (x2 - x1)*(y1 + y2)
			massesTimes2 += (x2 - x1) * (y1 + y2);
			// Calculate centersTimesMassesTimes6
			// (x2-x1)*(x1*(2y1 + y2) + x2*(y1 + 2y2))
			centerTimesmassesTimes6 += (x2 - x1)
					* (x1 * ((2 * y1) + y2) + x2 * (y1 + 2 * (y2)));
			i++;
		}
		if (massesTimes2 == 0) {
			return (universe[1] - universe[0]) / 2;
		}
		return centerTimesmassesTimes6 / (3 * massesTimes2);
	}

	/**
	 * Calculate the center of gravity of a continuous set.
	 * 
	 * @param f
	 *            The continuous set.
	 * @return The center of gravity.
	 */
	public double continuousCOG(FuzzySet f) {
		double[] universe = f.getUniverse();
		// Steps or points where the fuzzy set will be evaluated.
		double steps = Math.floor((universe[1] - universe[0])
				* SupportFunctions.getResolution());
		double x = f.getUniverse()[0]
				+ (1 / (2 * SupportFunctions.getResolution()));
		double eval = 0;
		double massTimesResolution = 0;
		double centersTimesV = 0;
		for (int i = 0; i < steps; i++) {
			eval = f.evaluate(x);
			// Sum y values
			massTimesResolution += eval;
			// Sum y*x
			centersTimesV += (eval * x);
			x += (1 / SupportFunctions.getResolution());
		}
		if (massTimesResolution == 0) {
			return (universe[1] + universe[0]) / 2;
		} else {
			// sumY*X / sumY
			return centersTimesV / massTimesResolution;
		}
	}

	/**
	 * Calculate the center of gravity of a discrete set.
	 * 
	 * @param f
	 *            The discrete set.
	 * @return The center of gravity.
	 */
	public double discreteCOG(PointSet f) {
		List<double[]> params = f.getParameters();
		double sum = 0;
		double sumY = 0;
		for (double[] point : params) {
			sum += point[0] * point[1];
			sumY += point[1];
		}
		return sum / sumY;
	}

}

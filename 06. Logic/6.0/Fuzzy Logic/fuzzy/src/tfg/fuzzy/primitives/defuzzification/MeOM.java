package tfg.fuzzy.primitives.defuzzification;

import java.util.ArrayList;
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
 * This class implements the meom-of primitive.Mean of Maxima.
 * 
 * @author Marcos Almendres.
 *
 */
public class MeOM implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and returns a number.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.WildcardType() },
				Syntax.NumberType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the mean of the
	 * maximum values of a fuzzy set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A number with the mean of maxima of a fuzzy set.
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
		// If continuous but not piecewise
		if (f.isContinuous() && !(f instanceof PiecewiseLinearSet)) {
			return continuousMeOM(f);
		} else {
			// If piecewise linear
			if (f instanceof PiecewiseLinearSet) {
				return piecewiseMeOM((PointSet) f);
			} else {
				return discreteMeOM(f);
			}

		}
	}

	/**
	 * Calculate the mean of Maxima of a continuous set.
	 * 
	 * @param f
	 *            The continuous set.
	 * @return The mean of Maxima.
	 */
	public double continuousMeOM(FuzzySet f) {
		double sumOfMax = Double.NEGATIVE_INFINITY;
		double maxVal = Double.NEGATIVE_INFINITY;
		double samples = 0;
		double[] universe = f.getUniverse();
		// First number to evaluate
		double x = universe[0];
		// Number of points to evaluate(Depends on resolution)
		double steps = Math
				.floor(1 + ((universe[1] - universe[0]) * SupportFunctions
						.getResolution()));
		double eval = 0;
		for (int i = 0; i < steps; i++) {
			eval = f.evaluate(x);
			// If a new maximum value is found
			if (eval > maxVal) {
				// Restart the sum of maximums
				sumOfMax = x;
				// Save the new maximum
				maxVal = eval;
				// Restart the samples count.
				samples = 1;
			} else if (eval == maxVal) {// If more maximum values are found
				// Increment the sum of maximums
				sumOfMax += x;
				// Increment the sample count.
				samples++;
			}
			// Increment 1/Resolution times
			x = x + (1 / SupportFunctions.getResolution());
		}
		return sumOfMax / samples;
	}

	/**
	 * Calculate the mean of maxima of a piecewise linear set.
	 * 
	 * @param f
	 *            The piecewise linear set.
	 * @return The mean of maxima.
	 */
	public double piecewiseMeOM(PointSet f) {
		double maxVal = Double.NEGATIVE_INFINITY;
		double y = 0;
		double[] interval = new double[2];
		// This flag shows if the previous point was a maximum.
		boolean inRow = false;
		// This flag shows if an interval of maximum values has been found
		boolean intervalComplete = false;
		List<double[]> intervals = new ArrayList<double[]>();
		double[] point;
		List<double[]> params = f.getParameters();
		for (int i = 0; i < params.size(); i++) {
			point = params.get(i);
			y = point[1];
			// If a new maximum value is found
			if (y > maxVal) {
				// Clear the intervals in order to avoid previous maximums
				intervals.clear();
				interval = new double[2];
				intervalComplete = false;
				maxVal = y;
				// Sets the first x of the interval
				interval[0] = point[0];
				inRow = true;
			} else if (y == maxVal) {// If more maximum values are found.
				// if the previous point was the same maximum too.
				if (inRow) {
					// sets the second x of the interval
					interval[1] = point[0];
					intervalComplete = true;
					// If this is the last point of the parameters add the
					// interval
					if (i == params.size() - 1) {
						intervals.add(interval.clone());
					}
				} else {
					// If not in a row, set the first x of the interval
					interval[0] = point[0];
					inRow = true;
				}
			} else {// If y < maxVal
					// If it comes from a complete interval add it to the list
				if (intervalComplete) {
					intervals.add(interval.clone());
				}
				inRow = false;
				intervalComplete = false;
			}
		}
		// If no maximum intervals are found call to discrete mean of maxima
		// method.
		if (intervals.size() == 0) {
			return discreteMeOM(f);
		} else {
			// Calculate and return the mean of the interval found.
			return meanOfMax(intervals);
		}
	}

	/**
	 * Calculate the mean of the intervals on a list.
	 * 
	 * @param intervals
	 *            The list where the intervals are.
	 * @return The mean of the intervals.
	 */
	public double meanOfMax(List<double[]> intervals) {
		double num = 0;
		double denom = 0;
		// Iterate over the intervals
		for (double[] interval : intervals) {
			// ((x1-x0)^2)/2
			num += (((interval[1] - interval[0]) * (interval[1] + interval[0])) / 2);
			// (x1-x0)
			denom += (interval[1] - interval[0]);
		}
		return num / denom;
	}

	/**
	 * Calculate the mean of maxima of a discrete set.
	 * 
	 * @param f
	 *            The discrete set.
	 * @return The mean of maxima.
	 */
	public double discreteMeOM(FuzzySet f) {
		PointSet ps = (PointSet) f;
		double maxVal = Double.NEGATIVE_INFINITY;
		double y = 0;
		double sumMaxima = 0;
		double length = 0;
		for (double[] point : ps.getParameters()) {
			y = point[1];
			// Each time a new max value is found reset length and sumMaxima
			if (y > maxVal) {
				length = 1;
				sumMaxima = point[0];
				maxVal = y;
			} else if (y == maxVal) {// Each time the max value is found
										// increase length and sumMaxima
				sumMaxima += point[0];
				length++;
			}
		}
		return sumMaxima / length;
	}

}

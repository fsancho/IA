package tfg.fuzzy.primitives.operators;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.nlogo.core.LogoList;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * Class to support Operators primitives with common methods.
 * 
 * @author Marcos Almendres.
 * 
 */
public class SupportOperators {

	/**
	 * Calculate the parameters and the universe of continuous sets.
	 * 
	 * @param l
	 *            Logolist containing all the fuzzysets.
	 * @return A tuple containing the resulting parameters(List<FuzzySet>) and
	 *         the universe(double[]).
	 */
	public static Tuple<FuzzySet> continuousParamsUniverse(LogoList l) {
		List<FuzzySet> params = new ArrayList<FuzzySet>();
		// Get and add the first fuzzy set
		FuzzySet f = (FuzzySet) l.first();
		params.add(f);
		// Get the universe of the first fuzzy set
		double[] universe = f.getUniverse();
		// Iterate over all the fuzzy sets
		for (int i = 1; i < l.size(); i++) {
			// Add fuzzy sets as parameters to the new set
			f = (FuzzySet) l.get(i);
			params.add(f);
			// Calculate the new universe
			universe = DegreeOfFulfillment.andInterval(universe,
					f.getUniverse());
		}
		return new Tuple<FuzzySet>(params, universe);
	}

	/**
	 * Checks the type of all the fuzzy sets.
	 * 
	 * @param l
	 *            The list where the fuzzy sets are.
	 * @return 1 if all discrete, 2 if all piecewise, 3 if all continuous or 0
	 *         if all the sets are not the same type.
	 */
	public static int allType(LogoList l) {
		int discrete = 0;
		int piecewise = 0;
		int continuous = 0;
		// Count the type of all the fuzzy sets inside the list
		Iterator<Object> it = l.javaIterator();
		while (it.hasNext()) {
			Object o = it.next();
			FuzzySet f = (FuzzySet) o;
			if (f.isContinuous()) {
				if (f instanceof PiecewiseLinearSet) {
					piecewise++;
				}
				continuous++;
			} else {
				discrete++;
			}
		}
		// If all the sets of the list are discrete return 1
		if (discrete == l.size()) {
			return 1;
		}
		// If all the sets of the list are piecewise return 2
		// Check first piecewise linear cause piecewise linear is also
		// continuous
		if (piecewise == l.size()) {
			return 2;
		}
		// If all the sets of the list are continuous return 3
		if (continuous == l.size()) {
			return 3;
		}
		// If the sets are mixed return 0;
		return 0;
	}

	/**
	 * Calculate the parameters and the universe of discrete operations.
	 * 
	 * @param l
	 *            the list where the sets are.
	 * @param operator
	 *            The operation to perform.
	 * @return A tuple containing the resulting parameters(List<double[]>) and
	 *         universe(double[]).
	 */
	public static Tuple<double[]> discreteOperations(LogoList l,
			Command operator) {
		// First discrete set and his parameters
		PointSet set = (PointSet) l.first();
		List<double[]> resultParameters = set.getParameters();
		double[] universe = new double[2];
		// Iterate over the sets
		for (int i = 1; i < l.size(); i++) {
			set = (PointSet) l.get(i);
			// Calculate the parameters of two sets
			resultParameters = discretePairOperation(resultParameters,
					set.getParameters(), operator);
		}
		// Calculate universe
		double[] point = resultParameters.get(0);
		universe[0] = point[0];
		point = resultParameters.get(resultParameters.size() - 1);
		universe[1] = point[0];
		return new Tuple<double[]>(resultParameters, universe);
	}

	/**
	 * Calculate the parameters of two discrete fuzzysets.
	 * 
	 * @param a
	 *            The parameters of the first fuzzy set.
	 * @param b
	 *            The parameters of the second fuzzy set.
	 * @param operator
	 *            The operation to perform.
	 * @return The resulting parameters.
	 */
	public static List<double[]> discretePairOperation(List<double[]> a,
			List<double[]> b, Command operator) {
		List<double[]> paramsA = a;
		List<double[]> paramsB = b;
		List<double[]> result = new ArrayList<double[]>();
		double[] pointA;
		double[] pointB;
		double[] resultPoint;
		double xA, xB;
		int i = 0, j = 0;
		// If there are points in both lists keep iterating
		while (i < paramsA.size() && j < paramsB.size()) {
			resultPoint = new double[2];
			// Get the points
			pointA = paramsA.get(i);
			pointB = paramsB.get(j);
			// Get the x values of the points
			xA = pointA[0];
			xB = pointB[0];
			// If the x values are the same
			if (xA == xB) {
				// Get the resulting point depending on the operation
				resultPoint = operator.execute(pointA, pointB);
				// Add the point to the result
				result.add(resultPoint.clone());
				// Next point of both parameters.
				i++;
				j++;
			} else {// If the x value are not the same step to the next point in the lower one
				if (xA < xB) {
					i++;
				} else {
					j++;
				}
			}
		}
		return result;
	}

	/**
	 * Build the label of the operation sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @param operation
	 *            The string to concatenate the set's label.
	 * @return The resulting string.
	 */
	public static String buildLabel(LogoList l, String operation) {
		String name = "(" + operation + " of Sets: "
				+ ((FuzzySet) l.first()).getLabel();
		for (int i = 1; i < l.size(); i++) {
			name += "," + ((FuzzySet) l.get(i)).getLabel();
		}
		name += ")";
		return name;
	}
}

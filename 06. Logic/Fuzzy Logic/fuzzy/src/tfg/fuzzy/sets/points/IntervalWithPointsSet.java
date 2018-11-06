package tfg.fuzzy.sets.points;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;

/**
 * This class represents a interval with points set.
 * 
 * @author Marcos Almendres.
 *
 */
public class IntervalWithPointsSet extends PointSet {

	/**
	 * Interval with points sets have a list of points, and the rest of the
	 * universe they have a default value.
	 */
	private double defaultValue;

	/**
	 * Call the constructor of PointSet.
	 * 
	 * @param value
	 *            a value where there is no point defined.
	 * 
	 * @see tfg.fuzzy.sets.general.PointSet#PointSet(String, List, boolean, String,
	 *      double[])
	 */
	public IntervalWithPointsSet(List<double[]> param, boolean continuous,
			String label, double[] universe, double value) {
		super("Interval With Points", param, continuous, label, universe);
		defaultValue = value;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		double[] universe = getUniverse();
		List<double[]> params = getParameters();
		double x;
		// if the number is out of the universe return not a number
		if (d < universe[0] || d > universe[1]) {
			return Double.NaN;
		}
		// Iterate over the points of parameters
		for (double[] point : params) {
			x = point[0];
			// If the number to evaluate is the same as the x value of the point
			// return the y value
			if (d == x) {
				return point[1];
			}
			// If the number is bigger than the x value we stop looking for more
			// points cause they are sorted.
			if (x > d) {
				break;
			}
		}
		// If there wasn't a point with that x value return the default value.
		return defaultValue;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(FuzzySet f) {
		if (f.isContinuous()) {
			return DegreeOfFulfillment.continuousFulfillment(this, f);
		} else {
			return DegreeOfFulfillment.mixedFulfillment(this, f);
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public String getNLTypeName() {
		return "IntervalWithPoints";
	}

}

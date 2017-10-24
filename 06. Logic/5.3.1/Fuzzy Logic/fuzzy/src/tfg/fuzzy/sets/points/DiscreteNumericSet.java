package tfg.fuzzy.sets.points;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;

/**
 * This class represents discrete numeric sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class DiscreteNumericSet extends PointSet {

	/**
	 * Call the constructor of PointSet.
	 * 
	 * @see tfg.fuzzy.sets.general.PointSet#PointSet(String, List, boolean, String,
	 *      double[])
	 */
	public DiscreteNumericSet(List<double[]> param, boolean continuous,
			String label, double[] universe) {
		super("Discrete", param, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		// Obtain the parameters of the FuzzySet and iterate over them
		List<double[]> parameters = getParameters();
		for (double[] point : parameters) {
			// Each parameter is a point(x,y).
			// If the x value of the point equals d, return the y value of the
			// point.
			if (point[0] == d) {
				return point[1];
			}
		}
		return Double.NaN;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(FuzzySet f) {
		if (f.isContinuous()) {
			// If 1 discrete and 1 continuous call mixedFulfillment
			return DegreeOfFulfillment.mixedFulfillment(this, f);
		} else {
			// If both discrete call discreteFulfillment
			return DegreeOfFulfillment.discreteFulfillment(this, (PointSet) f);
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public String getNLTypeName() {
		return "DiscreteNumeric";
	}
}

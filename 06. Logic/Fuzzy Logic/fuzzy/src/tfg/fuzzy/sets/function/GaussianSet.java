package tfg.fuzzy.sets.function;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FunctionSet;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class represents gaussian sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class GaussianSet extends FunctionSet {

	/**
	 * Call the constructor of FunctionSet.
	 * 
	 * @see tfg.fuzzy.sets.general.FunctionSet#FunctionSet(String, List, boolean, String,
	 *      double[])
	 */
	public GaussianSet(List<Double> param, boolean continuous, String label,
			double[] universe) {
		super("Gaussian", param, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		List<Double> params = getParameters();
		double[] univ = getUniverse();
		// If out of the universe the function return undefined(Not a Number)
		if (d < univ[0] || d > univ[1]) {
			return Double.NaN;
		}
		double s = params.get(1);
		double m = params.get(0);
		// if standard deviations is 0 return the mean.
		if (s == 0) {
			return m;
		} else {
			// e^(-((x-m)^2)/(2*(s^2)))
			return Math.pow(Math.E, -(Math.pow(d - m, 2))
					/ (2 * Math.pow(s, 2)));
		}
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
		return "Gaussian";
	}

}

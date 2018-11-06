package tfg.fuzzy.sets.function;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FunctionSet;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class represents exponential sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class ExponentialSet extends FunctionSet {

	/**
	 * Call the constructor of FunctionSet.
	 * 
	 * @see tfg.fuzzy.sets.general.FunctionSet#FunctionSet(String, List, boolean, String,
	 *      double[])
	 */
	public ExponentialSet(List<Double> param, boolean continuous, String label,
			double[] universe) {
		super("Exponential", param, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		List<Double> params = getParameters();
		double[] univ = getUniverse();
		double result;
		// If out of the universe the function return undefined(Not a Number)
		if (d < univ[0] || d > univ[1]) {
			return Double.NaN;
		}
		// a*e^(b*(x-c))
		result = (params.get(0))
				* Math.pow(Math.E, (params.get(1)) * (d - params.get(2)));
		// if the result is higher than 1 or lower than 0, it is clipped
		if (result > 1) {
			result = 1;
		} else if (result < 0) {
			result = 0;
		}
		return result;
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
		return "Exponential";
	}
}

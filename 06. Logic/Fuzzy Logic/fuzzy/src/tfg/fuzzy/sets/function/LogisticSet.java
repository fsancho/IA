package tfg.fuzzy.sets.function;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FunctionSet;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class represents logistic sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class LogisticSet extends FunctionSet {

	/**
	 * Call the constructor of FunctionSet.
	 * 
	 * @see tfg.fuzzy.sets.general.FunctionSet#FunctionSet(String, List, boolean, String,
	 *      double[])
	 */
	public LogisticSet(List<Double> param, boolean continuous, String label,
			double[] universe) {
		super("Logistic", param, continuous, label, universe);
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

		// 1/(1+a*e^(-b*(x-x0)))
		return 1 / (1 + (params.get(1))
				* Math.pow(Math.E, (-(params.get(2)) * (d - (params.get(0))))));
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
		return "Logistic";
	}

}

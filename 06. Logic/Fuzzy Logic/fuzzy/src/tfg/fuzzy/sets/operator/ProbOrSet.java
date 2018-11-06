package tfg.fuzzy.sets.operator;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.OperatorSet;

/**
 * This class represents probabilistic-or sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class ProbOrSet extends OperatorSet {

	/**
	 * Call the constructor from FunctionSet.
	 * 
	 * @see tfg.fuzzy.sets.general.OperatorSet#OperatorSet(String, List, boolean, String,
	 *      double[])
	 */
	public ProbOrSet(List<FuzzySet> params, boolean continuous, String label,
			double[] universe) {
		super("Prob-or", params, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		List<FuzzySet> parameters = getParameters();
		double result = parameters.get(0).evaluate(d);
		double b = 0;
		for (int i = 1; i < parameters.size(); i++) {
			b = parameters.get(i).evaluate(d);
			// (x+y - x*y)
			result = result + (b * (1 - result));
		}
		return result;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(FuzzySet f) {
		if (!f.isContinuous()) {
			return DegreeOfFulfillment.mixedFulfillment(this, f);
		} else {
			return DegreeOfFulfillment.continuousFulfillment(this, f);
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public String getNLTypeName() {
		return "Prob-or-set";
	}

}

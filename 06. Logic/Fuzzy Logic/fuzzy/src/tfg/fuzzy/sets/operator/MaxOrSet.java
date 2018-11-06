package tfg.fuzzy.sets.operator;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.OperatorSet;

/**
 * This class represents max(also known by or) sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class MaxOrSet extends OperatorSet {

	/**
	 * Call the constructor from FunctionSet.
	 * 
	 * @see tfg.fuzzy.sets.general.OperatorSet#OperatorSet(String, List, boolean, String,
	 *      double[])
	 */
	public MaxOrSet(List<FuzzySet> params, boolean continuous, String label,
			double[] universe) {
		super("Max", params, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		double max = Double.NEGATIVE_INFINITY;
		double eval = Double.NEGATIVE_INFINITY;
		// Iterate over the fuzzy sets.
		for (FuzzySet f : getParameters()) {
			eval = f.evaluate(d);
			// if one of them return NaN the MaxOr set too.
			if (eval == Double.NaN) {
				return Double.NaN;
			}
			// Look for the greatest of the evaluations.
			if (eval > max) {
				max = eval;
			}
		}
		return max;
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
		return "max-or-set";
	}

}

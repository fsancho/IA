package tfg.fuzzy.sets.operator;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.OperatorSet;

/**
 * This class represents min(also known by and) sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class MinAndSet extends OperatorSet {

	/**
	 * Call the constructor from FunctionSet.
	 * 
	 * @see tfg.fuzzy.sets.general.OperatorSet#OperatorSet(String, List, boolean, String,
	 *      double[])
	 */
	public MinAndSet(List<FuzzySet> params, boolean continuous, String label,
			double[] universe) {
		super("Min", params, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		double min = Double.POSITIVE_INFINITY;
		double eval = Double.POSITIVE_INFINITY;
		// Iterate over the fuzzy sets
		for (FuzzySet f : getParameters()) {
			// evaluate all the fuzzy sets
			eval = f.evaluate(d);
			// If one of them return NaN, Min-And will return NaN too.
			if (eval == Double.NaN) {
				return Double.NaN;
			}
			// Look for the lowest evaluation.
			if (eval < min) {
				min = eval;
			}
		}
		return min;
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
		return "min-and-set";
	}
}

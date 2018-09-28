package tfg.fuzzy.sets.operator;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.OperatorSet;

/**
 * This class represents sum sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class SumSet extends OperatorSet {

	/**
	 * Call the constructor from FunctionSet.
	 * 
	 * @see tfg.fuzzy.sets.general.OperatorSet#OperatorSet(String, List, boolean, String,
	 *      double[])
	 */
	public SumSet(List<FuzzySet> params, boolean continuous, String label,
			double[] universe) {
		super("Sum", params, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		double eval, sum = 0;
		// Sum the evaluations of all fuzzy sets.
		for (FuzzySet f : getParameters()) {
			eval = f.evaluate(d);
			if (eval == Double.NaN) {
				return Double.NaN;
			}
			sum += eval;
		}
		// If the result is greater than 1, it is clipped.
		if (sum > 1) {
			return 1;
		} else {
			return sum;
		}
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
		return "sum-set";
	}

}

package tfg.fuzzy.sets.operator;

import java.util.List;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.OperatorSet;

/**
 * This class represents the not sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class NotSet extends OperatorSet {

	/**
	 * Call the constructor from FunctionSet.
	 * 
	 * @see tfg.fuzzy.sets.general.OperatorSet#OperatorSet(String, List, boolean, String,
	 *      double[])
	 */
	public NotSet(List<FuzzySet> params, boolean continuous, String label,
			double[] universe) {
		super("Not", params, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		double eval = getParameters().get(0).evaluate(d);
		if (eval == Double.NaN) {
			return Double.NaN;
		} else {
			// return the opposite value, fuzzy logic works between 0 and 1.
			return 1 - eval;
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
		return "not-set";
	}
}

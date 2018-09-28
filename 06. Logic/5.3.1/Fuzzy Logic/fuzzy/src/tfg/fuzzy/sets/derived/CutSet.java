package tfg.fuzzy.sets.derived;


import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.DerivedSet;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * When a continuous fuzzy set is truncated, a new cut-set is created. This
 * class represents cut-sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class CutSet extends DerivedSet {

	/**
	 * Call the constructor of DerivedSet.
	 * 
	 * @see tfg.fuzzy.sets.general.DerivedSet#DerivedSet(String, FuzzySet, double,
	 *      boolean, String, double[])
	 */
	public CutSet(FuzzySet param, double limit, boolean continuous,
			String label, double[] universe) {
		super("truncate", param, limit, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		double eval = param.evaluate(d);
		// If the fuzzy set is not defined in the number, return Not a Number
		if (eval == Double.NaN) {
			return Double.NaN;
		}
		// Truncate the evaluation result if greater than the parameter.
		if (eval > c) {
			return c;
		} else {
			return eval;
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(FuzzySet f) {
		// If one set continuous and the other discrete.
		if (!f.isContinuous()) {
			return DegreeOfFulfillment.mixedFulfillment(this, f);
		} else {// If both sets continuous
			return DegreeOfFulfillment.continuousFulfillment(this, f);
		}
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public String getNLTypeName() {
		return "continuous-cut";
	}
}

package tfg.fuzzy.sets.derived;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.DerivedSet;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * When a continuous fuzzy set is powered, a new power set is created. This
 * class represents power sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class PowerSet extends DerivedSet {

	/**
	 * Call the constructor of DerivedSet.
	 * 
	 * @see tfg.fuzzy.sets.general.DerivedSet#DerivedSet(String, FuzzySet, double,
	 *      boolean, String, double[])
	 */
	public PowerSet(FuzzySet param, double limit, boolean continuous,
			String label, double[] universe) {
		super("power", param, limit, continuous, label, universe);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public double evaluate(double d) {
		double eval = param.evaluate(d);
		if (eval == Double.NaN) {
			return Double.NaN;
		}
		return Math.pow(eval, c);
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
		return "continuous-power";
	}

}

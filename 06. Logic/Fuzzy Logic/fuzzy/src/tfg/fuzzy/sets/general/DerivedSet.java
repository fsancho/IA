package tfg.fuzzy.sets.general;

import java.util.ArrayList;
import java.util.List;

/**
 * This sets contains a continuous fuzzy set and a number that somehow modifies
 * the fuzzy set.
 * 
 * @author Marcos Almendres.
 *
 */
public abstract class DerivedSet extends FuzzySet {

	/**
	 * A fuzzy set.
	 */
	protected FuzzySet param;
	/**
	 * A number that modifies the fuzzy set.
	 */
	protected double c;

	/**
	 * Call the constructor in FuzzySet. Save the parameters of a Derived set.
	 * 
	 * @param param
	 *            The fuzzy set.
	 * @param limit
	 *            The number that modifies the fuzzy set.
	 * @see tfg.fuzzy.sets.general.FuzzySet#FuzzySet(String description, boolean
	 *      continuous, String label,double[] universe).
	 */
	public DerivedSet(String description, FuzzySet param, double limit,
			boolean continuous, String label, double[] universe) {
		super(description, continuous, label, universe);
		this.param = param;
		c = limit;
	}

	/**
	 * Return the fuzzy set. Since his parent(FuzzySet) returns a List, a
	 * derived set must add his fuzzy set to a list.
	 * 
	 * @return The fuzzy set.
	 */
	public List<FuzzySet> getParameters() {
		List<FuzzySet> l = new ArrayList<FuzzySet>();
		l.add(param);
		return l;
	}

	/**
	 * @return The fuzzy set.
	 */
	public FuzzySet getSet() {
		return param;
	}

	/**
	 * @return The limit of the set.
	 */
	public double getLimit() {
		return c;
	}

	/**
	 * {@inheritDoc}
	 */
	public String dump(boolean readable, boolean exporting, boolean reference) {
		return "[set parameters: " + param.dump(true, true, true)
				+ " modified by " + c + "]";
	}
}

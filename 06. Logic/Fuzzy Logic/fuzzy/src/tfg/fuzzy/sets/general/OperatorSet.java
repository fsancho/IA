package tfg.fuzzy.sets.general;

import java.util.ArrayList;
import java.util.List;

/**
 * This set contains several fuzzy sets. It is used for the operator primitives.
 * 
 * @author Marcos Almendres.
 *
 */
public abstract class OperatorSet extends FuzzySet {

	/**
	 * A list of Fuzzy sets.
	 */
	protected List<FuzzySet> parameters;

	/**
	 * Call the constructor in FuzzySet. Save the parameters of a Operator Set.
	 * 
	 * @param params
	 *            The parameters of a Point set.
	 * @see tfg.fuzzy.sets.general.FuzzySet#FuzzySet(String description, boolean
	 *      continuous, String label,double[] universe).
	 */
	public OperatorSet(String description, List<FuzzySet> params,
			boolean continuous, String label, double[] universe) {
		super(description, continuous, label, universe);
		parameters = new ArrayList<FuzzySet>();
		parameters.addAll(params);
	}

	@Override
	/**
	 * Clone and return the parameters of the sets.
	 * @return The parameters of the sets.
	 */
	public List<FuzzySet> getParameters() {
		List<FuzzySet> backParams = new ArrayList<FuzzySet>();
		backParams.addAll(parameters);
		return backParams;
	}

	/**
	 * {@inheritDoc}
	 */
	public String dump(boolean readable, boolean exporting, boolean reference) {
		String s = "[";
		for (FuzzySet f : parameters) {
			s += "[" + f.getDescription() + " " + f.dump(true, true, true)
					+ "] ";
		}
		s += "]";
		return s;
	}
}

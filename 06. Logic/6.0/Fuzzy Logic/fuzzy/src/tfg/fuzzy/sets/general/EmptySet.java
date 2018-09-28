package tfg.fuzzy.sets.general;

import java.util.List;

/**
 * This sets contains nothing.
 * 
 * @author Marcos Almendres.
 *
 */
public class EmptySet extends FuzzySet {

	/**
	 * Call the constructor in FuzzySet.
	 * 
	 * @see tfg.fuzzy.sets.general.FuzzySet#FuzzySet(String description, boolean
	 *      continuous, String label,double[] universe).
	 */
	public EmptySet(String description, boolean continuous, String label,
			double[] universe) {
		super(description, continuous, label, universe);
	}

	/**
	 * Empty constructor, easier and faster to use. Call the constructor in
	 * FuzzySet with an empty universe.
	 */
	public EmptySet() {
		super("empty", true, "empty", new double[] {});
	}

	@Override
	public double evaluate(double d) {
		return Double.NaN;
	}

	@Override
	public double evaluate(FuzzySet f) {
		return Double.NaN;
	}

	@Override
	public List<Object> getParameters() {
		return null;
	}

	@Override
	public String getNLTypeName() {
		return "EmptySet";
	}

}

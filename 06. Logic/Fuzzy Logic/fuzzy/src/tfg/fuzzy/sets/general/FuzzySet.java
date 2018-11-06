package tfg.fuzzy.sets.general;

import java.util.List;

import org.nlogo.core.ExtensionObject;

/**
 * This class represents all fuzzy sets.
 * 
 * @author Marcos Almendres.
 *
 */
public abstract class FuzzySet implements ExtensionObject {

	/**
	 * Name of the fuzzy set.
	 */
	private String description;
	/**
	 * Name that the user gives to the set.
	 */
	private String label;
	/**
	 * True if the set is continuous(defined in all points of his universe),
	 * false if not.
	 */
	private boolean continuous;
	/**
	 * The universe of the set. i.e.: [0 10]
	 */
	private double[] universe;

	/**
	 * Creates a new fuzzy set.
	 * @param description The description of the set.
	 * @param continuous The continuity of the set.
	 * @param label A name for the set.
	 * @param universe The universe of the set.
	 */
	public FuzzySet(String description, boolean continuous, String label,
			double[] universe) {
		this.description = description;
		this.continuous = continuous;
		this.label = label;
		this.universe = universe.clone();
	}

	/**
	 * Evaluate a number in the fuzzy set.
	 * 
	 * @param d
	 *            The number to evaluate.
	 * @return The evaluation result.
	 */
	public abstract double evaluate(double d);

	/**
	 * Evaluate a fuzzy set in this fuzzy set.
	 * 
	 * @param f
	 *            The fuzzy set to evaluate.
	 * @return The evaluation result.
	 */
	public abstract double evaluate(FuzzySet f);

	@SuppressWarnings("rawtypes")
	/**
	 * Return the parameters of the fuzzy set.
	 * @return The parameters.
	 */
	public abstract List getParameters();

	/**
	 * This method is used by Netlogo when a variable with this object is
	 * called.
	 */
	@Override
	public String dump(boolean arg0, boolean arg1, boolean arg2) {
		return label;
	}

	/**
	 * String identifying the extension.
	 */
	@Override
	public String getExtensionName() {
		return "fuzzylogic";
	}

	/**
	 * String identifying the object.
	 */
	@Override
	public abstract String getNLTypeName();

	@Override
	public boolean recursivelyEqual(Object arg0) {
		return false;
	}

	/**
	 * 
	 * @return the description of the set.
	 */
	public String getDescription() {
		return description;
	}

	/**
	 * Sets a description for the set.
	 * 
	 * @param description
	 *            the new description of the set.
	 */
	public void setDescription(String description) {
		this.description = description;
	}

	/**
	 * 
	 * @return the universe of the set.
	 */
	public double[] getUniverse() {
		return universe.clone();
	}

	/**
	 * 
	 * @return the label of the set.
	 */
	public String getLabel() {
		return label;
	}

	/**
	 * sets a new label for the set.
	 * 
	 * @param label
	 *            the new label.
	 */
	public void setLabel(String label) {
		this.label = label;
	}

	/**
	 * 
	 * @return the continuity of the set.
	 */
	public boolean isContinuous() {
		return continuous;
	}
}

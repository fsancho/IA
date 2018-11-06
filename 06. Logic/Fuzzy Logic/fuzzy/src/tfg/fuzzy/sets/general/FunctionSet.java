package tfg.fuzzy.sets.general;

import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * This class represents all sets based on formulas.
 * 
 * @author Marcos Almendres.
 *
 */
public abstract class FunctionSet extends FuzzySet {

	/**
	 * List of doubles.i.e:(1 2 3).
	 */
	protected List<Double> parameters;

	/**
	 * Call the constructor in FuzzySet. Save the parameters of a Function set.
	 * 
	 * @param params
	 *            The parameters of a Function set.
	 * @see tfg.fuzzy.sets.general.FuzzySet#FuzzySet(String description, boolean
	 *      continuous, String label,double[] universe).
	 */
	public FunctionSet(String description, List<Double> params,
			boolean continuous, String label, double[] universe) {
		super(description, continuous, label, universe);
		parameters = new ArrayList<Double>();
		parameters.addAll(params);
	}

	/**
	 * Clone and return the parameters of the sets.
	 * 
	 * @return The parameters of the sets.
	 */
	public List<Double> getParameters() {
		List<Double> params = new ArrayList<Double>(parameters);
		return params;
	}

	/**
	 * {@inheritDoc}
	 */
	public String dump(boolean readable, boolean exporting, boolean reference) {
		String s = "[ ";
		NumberFormat nf = NumberFormat.getNumberInstance(Locale.ENGLISH);
		for (double param : parameters) {
			s += nf.format(param) + " ";
		}
		s += "]";
		return s;
	}
}

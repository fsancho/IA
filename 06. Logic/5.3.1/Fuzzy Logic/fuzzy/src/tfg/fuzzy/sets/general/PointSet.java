package tfg.fuzzy.sets.general;

import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * This class represent all sets based on points.
 * 
 * @author Marcos Almendres.
 *
 */
public abstract class PointSet extends FuzzySet {

	/**
	 * List of 2 point arrays. i.e.: ([0 0] [1 1] [2 0] [3 1]).
	 */
	protected List<double[]> parameters;

	/**
	 * Call the constructor in FuzzySet. Save the parameters of a Point Set.
	 * 
	 * @param params
	 *            The parameters of a Point set.
	 * @see tfg.fuzzy.sets.general.FuzzySet#FuzzySet(String description, boolean
	 *      continuous, String label,double[] universe).
	 */
	public PointSet(String description, List<double[]> params,
			boolean continuous, String label, double[] universe) {
		super(description, continuous, label, universe);
		parameters = new ArrayList<double[]>(params);
	}

	/**
	 * Clone and return the parameters of the sets.
	 * 
	 * @return The parameters of the sets.
	 */
	public List<double[]> getParameters() {
		List<double[]> params = new ArrayList<double[]>();
		params.addAll(parameters);
		return params;
	}

	/**
	 * {@inheritDoc}
	 */
	public String dump(boolean readable, boolean exporting, boolean reference) {
		String s = "[";
		NumberFormat nf = NumberFormat.getNumberInstance(Locale.ENGLISH);
		for (double[] param : parameters) {
			s += "[" + nf.format(param[0]) + " " + nf.format(param[1]) + "]";
		}
		s += "]";
		return s;
	}
}

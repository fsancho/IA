package tfg.fuzzy.general;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.nlogo.api.Context;
import org.nlogo.api.ExtensionException;
//import org.nlogo.api.I18N;
import org.nlogo.core.LogoList;


//import org.nlogo.nvm.ExtensionContext;
//import org.nlogo.window.GUIWorkspace;

import tfg.fuzzy.sets.general.FuzzySet;


/**
 * This class is used by all creation of fuzzy sets primitives.
 * 
 * @author Marcos Almendres.
 * 
 */
public class SupportFunctions {

	/**
	 * Number of points to evaluate continuous sets.
	 */
	private static double resolution = 32;

	/**
	 * Get the resolution of the model.
	 * 
	 * @return the resolution.
	 */
	public static double getResolution() {
		return resolution;
	}

	/**
	 * Sets the resolution of the model.
	 * 
	 * @param d
	 *            The resolution we want to set.
	 */
	public static void setResolution(double d) {
		resolution = d;
	}

	/**
	 * Calculate the universe of the parameters that comes from netlogo.
	 * 
	 * @param params
	 *            Parameters of a fuzzy set.
	 * @return the universe of the parameters.
	 */
	public static double[] universe(LogoList params) {
		double[] universe = new double[2];
		// Save the first and the last x value[x1,x2]
		LogoList first = (LogoList) params.first();
		LogoList last = (LogoList) params.get(params.size() - 1);
		universe[0] = (Double) first.first();
		universe[1] = (Double) last.first();
		return universe;
	}

	/**
	 * Checks the format of the sets defined with points.
	 * 
	 * @param params
	 *            Parameters of the fuzzy set.
	 * @return A valid list with the parameters of the set sorted.
	 * @throws ExtensionException
	 */
	public static List<double[]> checkListFormat(LogoList params)
			throws ExtensionException {
		int n = 0;
		List<double[]> sortingList = new ArrayList<double[]>();
		double[] point = new double[2];
		// If this is an empty list throw and exception
		if (params.size() == 0) {
			throw new ExtensionException(
					"The list is empty, please enter a valid list: [[a b] [c d] [e f]]");
		}
		// Iterate over the parameters
		Iterator<Object> it = params.javaIterator();
		while (it.hasNext()) {
			Object o = it.next();
			// Checks the elements are lists
			if (!(o instanceof LogoList)) {
				throw new ExtensionException(
						"List of 2 elements lists expected. The element in the position "
								+ Double.valueOf(n) + " is not a list");
			}
			LogoList l = (LogoList) o;
			// Checks if the lists contains 2 elements
			if (l.size() != 2) {
				throw new ExtensionException(
						"List of 2 elements lists expected. The element in the position "
								+ Double.valueOf(n)
								+ " is not a list of two elements");
			}
			point[0] = (Double) l.first();
			point[1] = (Double) l.get(1);
			// Add to a list to use the Collections.sort method
			sortingList.add(point.clone());
			// Checks if the elements are doubles
			if ((Double) l.get(1) > 1 || (Double) l.get(1) < 0) {
				throw new ExtensionException(
						"The second number of each list should be between 0 and 1 "
								+ Double.valueOf(n) + " is not between 0 and 1");
			}
			n++;
		}
		return sortListOfPoints(sortingList);
	}

	/**
	 * Sort the points inside a list.
	 * 
	 * @param list
	 *            the list with all points.
	 * @return The sorted list.
	 */
	public static List<double[]> sortListOfPoints(List<double[]> list) {
		// Implement the Comparator for double[2]
		Comparator<double[]> comp = new Comparator<double[]>() {
			public int compare(double[] a, double[] b) {
				// Returns required by comparators(1 if the first is bigger, -1
				// if smaller and 0 if equal)
				if (a[0] > b[0]) {
					return 1;
				} else if (b[0] > a[0]) {
					return -1;
				} else {
					return 0;
				}
			}
		};
		Collections.sort(list, comp);
		// Build the sorted List to store in the FuzzySet
		return list;
	}

	/**
	 * Checks the format of Logistic,Exponential and Gaussian sets
	 * 
	 * @param params
	 *            the parameters of the set
	 * @param n
	 *            Integer to check if 3 or 4 parameters required
	 * @return The universe of the set [lower-limit, upper-limit]
	 * @throws ExtensionException
	 */
	public static double[] LGEFormat(LogoList params, int n)
			throws ExtensionException {
		double[] universe = new double[2];
		// Checks the number of elements, could be 3 or 4 actually
		if (params.size() != n) {
			throw new ExtensionException("must be a list with " + (n - 1)
					+ " numbers and one 2-number list");
		}
		// Iterate over the parameters
		for (int i = 0; i < params.size(); i++) {
			// The last element is the universe, the other n-1 the paramers
			if (i < n - 1) {
				// The first n-1 elements must be doubles
				if (!(params.get(i) instanceof Double)) {
					throw new ExtensionException("The first " + (n - 1)
							+ " parameters must be numbers");
				}
			} else {
				// The last element must be a logo list
				if (!(params.get(i) instanceof LogoList)) {
					throw new ExtensionException("The " + n
							+ "th item must be a list of 2 elements list");
				}
				LogoList l = (LogoList) params.get(i);
				// If the universe are not 2 elements
				if (l.size() != 2) {
					throw new ExtensionException("The " + n
							+ "th item must be a list of 2 elements list");
				}
				universe = new double[] { (Double) l.first(), (Double) l.get(1) };
			}
		}
		return universe;
	}

	/**
	 * Checks the parameters of Interval with points sets.
	 * @param params The parameters of the set.
	 * @return The universe of the set.
	 * @throws ExtensionException
	 */
	public static double[] IWPFormat(LogoList params) throws ExtensionException {
		// Checks the list cointains two lists
		if (!(params.first() instanceof LogoList)
				|| !(params.get(1) instanceof LogoList)) {
			throw new ExtensionException("The list should contain 2 lists");
		}
		LogoList f = (LogoList) params.first();
		// Checks the first parameter is a 2 element list with the first element
		// a list and the second a number
		if (f.size() != 2 || !(f.first() instanceof LogoList)
				|| !(f.get(1) instanceof Double)) {
			throw new ExtensionException(
					"The first element of parameters must look like [[low-limit high-limit] value]");
		}
		LogoList interval = (LogoList) f.first();
		// Checks the first element(of the first parameter) is a list of 2
		// numbers
		if (interval.size() != 2 || !(interval.first() instanceof Double)
				|| !(interval.get(1) instanceof Double)) {
			throw new ExtensionException(
					"The interval must be a list of two numbers");
		}
		// The universe in interval with point sets is stored in a different
		// way.
		// [lower-limit,higher-limit] this is the normal way to store universes.
		// [lower-limit,higher-limit,default-value] this is how universe is
		// stored in interval with point sets.
		double[] universe = new double[] { (Double) interval.first(),
				(Double) interval.get(1), (Double) f.get(1) };
		// If the first point of the universe is greater than the last throw an
		// exception
		if (universe[0] >= universe[1]) {
			throw new ExtensionException(
					"The interval should be like[lower higher]");
		}
		return universe;
	}

	/**
	 * Checks the format of the trapezoidal sets.
	 * 
	 * @param params
	 *            The parameters of the trapezoidal set.
	 * @return The parameters in a list.
	 * @throws ExtensionException
	 */
	public static List<double[]> trapezoidalFormat(LogoList params)
			throws ExtensionException {
		// Checks the list has 7 parameters
		if (params.size() != 7) {
			throw new ExtensionException(
					"The first argument must be a list of 7 numbers");
		}
		List<double[]> resultParams = new ArrayList<double[]>();
		for (int i = 0; i <= 6; i++) {
			// Checks the list has only Doubles inside
			if (!(params.get(i) instanceof Double)) {
				throw new ExtensionException(
						"The list can only contain numbers");
			}
			// list-of-parameters is a list [a, b, c, d, e, f, HEIGHT]
			// The membership function equals 0 in the interval [a,b],
			// increases linearly from 0 to HEIGHT in the range b to c,
			// is equal to HEIGHT in the range c to d,
			// decreases linearly from HEIGHT to 0 in the range d to e,
			// and equals 0 in the interval [e,f].
			if (i <= 1) {
				resultParams.add(new double[] { (Double) params.get(i), 0 });
			} else if (i <= 3) {
				resultParams.add(new double[] { (Double) params.get(i),
						(Double) params.get(6) });
			} else if (i <= 5) {
				resultParams.add(new double[] { (Double) params.get(i), 0 });
			}
		}
		return resultParams;
	}

	/**
	 * Add the fuzzy set with label to the registry of sets.
	 * 
	 * @param f
	 *            The fuzzy set.
	 * @param name
	 *            The label of the fuzzy set.
	 * @param c
	 *            The context of netlogo.
	 * @throws ExtensionException
	 */
	public static void addToRegistry(FuzzySet f, String name, Context c)
			throws ExtensionException {
		
		
		Map<String, FuzzySet> registry = FuzzyLogic.getRegistry();
		// If the label is already registered just override it.
		if (registry.containsKey(name)) {
			/*
			 * GUIWorkspace gw = (GUIWorkspace) ((ExtensionContext) c).workspace();
			 * String text = "The label: "
				+ name
				+ " had been previously assigned to an existing fuzzy set. The label "
				+ name + " is now assigned to another fuzzy set";
			 * 	registry.remove(name);
			 * 	registry.put(name, f);
			 *  org.nlogo.swing.OptionDialog.show(gw.getFrame(), "warning", text,
					new String[] { I18N.gui().get("common.buttons.ok") });
			 */
			throw new ExtensionException("You cannot assign the same label (" + name + ") to two different fuzzy sets.");
		// If the fuzzy set is already registered throw an exception
		} else if (registry.containsValue(f)) {
			throw new ExtensionException(
					"You cannot assign two labels to the same fuzzy set.");
		} else {
			registry.put(name, f);
		}
	}
}

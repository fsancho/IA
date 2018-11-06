package tfg.fuzzy.general;

import java.util.ArrayList;
import java.util.List;

import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;

/**
 * This class implements the degree of fulfillment of two sets. This is a static
 * class because it is used in all fuzzy sets.
 * 
 * @author Marcos Almendres.
 * 
 */
public class DegreeOfFulfillment {

	/**
	 * Calculate the degree of fulfillment of two discrete sets.
	 * 
	 * @param a
	 *            One of the discrete sets.
	 * @param b
	 *            The other discrete set.
	 * @return The degree of fulfillment of the two sets.
	 */
	public static double discreteFulfillment(PointSet a, PointSet b) {
		// Save the parameters of the 2 FuzzySets(Both Discrete)
		List<double[]> paramsA = a.getParameters();
		List<double[]> paramsB = b.getParameters();
		double degree = Double.NEGATIVE_INFINITY;
		double minimum = Double.POSITIVE_INFINITY;
		double[] elementA;
		double[] elementB;
		int i = 0, j = 0;
		// While the 2 index inside the limit
		while (i < paramsA.size() & j < paramsB.size()) {
			// Save one point of each set
			elementA = paramsA.get(i);
			elementB = paramsB.get(j);
			// If the x value is the same
			if (elementA[0] == elementB[0]) {
				// Save the minimum y value of them
				if (elementA[1] < elementB[1]) {
					minimum = elementA[1];
				} else {
					minimum = elementB[1];
				}
				// The degree is the maximum value found.
				if (degree < minimum) {
					degree = minimum;
				}
				// Increment both index
				i++;
				j++;
			} else {// The x values are different
					// If the x value of A is lower than the the x value of B
					// increment A, if not increment B
				if (elementA[0] < elementB[0]) {
					i++;
				} else {
					j++;
				}
			}
		}
		return degree;
	}

	/**
	 * Calculate the degree of fulfillment of a continuous and a discrete set.
	 * 
	 * @param a
	 *            One of the sets.
	 * @param b
	 *            The other set.
	 * @return The degree of fulfillment of the two sets.
	 */
	public static double mixedFulfillment(FuzzySet a, FuzzySet b) {
		PointSet discrete;
		FuzzySet continuous;
		// See which one is the continuous
		if (a.isContinuous()) {
			continuous = a;
			discrete = (PointSet) b;
		} else {
			continuous = b;
			discrete = (PointSet) a;
		}
		// Get the parameters of the discrete fuzzy set
		List<double[]> elementsD = discrete.getParameters();
		double x;
		double[] universe = continuous.getUniverse();
		List<Double> numbersToEvaluate = new ArrayList<Double>();
		// Iterate over the parameters and add to a list the first number(x) of
		// each points
		for (double[] point : elementsD) {
			x = point[0];
			// If x is in the universe of the continuous set add it
			if (x >= universe[0] && x <= universe[1]) {
				numbersToEvaluate.add(x);
			}
		}
		double max = Double.NEGATIVE_INFINITY;
		double evCont, evDisc;
		// Iterate over the numbersToEvaluate
		for (double d : numbersToEvaluate) {
			// Evaluate the number in each Fuzzy Set
			evCont = continuous.evaluate(d);
			evDisc = discrete.evaluate(d);
			// Get the lower of them
			if (evCont < evDisc) {// evCont is lower
				// Compare to the max value, if its greater save it
				if (evCont > max) {
					max = evCont;
				}
			} else {// evDisc is lower
				if (evDisc > max) {
					max = evDisc;
				}
			}
		}
		return max;
	}

	/**
	 * Calculate the degree of fulfillment of two continuous sets.
	 * 
	 * @param a
	 *            One of the continuous sets.
	 * @param b
	 *            The other continuous set.
	 * @return The degree of fulfillment of the two sets.
	 */
	public static double continuousFulfillment(FuzzySet a, FuzzySet b) {
		// The resulting universe is the intersection of a and b
		double[] universe = andInterval(a.getUniverse(), b.getUniverse());
		// if the universe is empty return Not a Number
		if (universe.length > 0) {
			// Calculate the steps,depending on the resolution
			double resolution = SupportFunctions.getResolution();
			double steps = Math
					.floor(1 + ((universe[1] - universe[0]) * resolution));
			double x = universe[0];
			double evalA = 0;
			double evalB = 0;
			double minimum = Double.POSITIVE_INFINITY;
			double degree = Double.NEGATIVE_INFINITY;
			// Iterate over the defined steps
			for (int i = 0; i < steps; i++) {
				evalA = a.evaluate(x);
				evalB = b.evaluate(x);
				// Save the lower value
				if (evalA <= evalB) {
					minimum = evalA;
				} else {
					minimum = evalB;
				}
				// Save the greater of the lower values
				if (minimum > degree) {
					degree = minimum;
				}
				// Increase x
				x += 1 / resolution;
			}
			return degree;
		} else {
			return Double.NaN;
		}
	}

	/**
	 * Calculate where the two universes are defined.
	 * 
	 * @param universe1
	 *            the first universe.
	 * @param universe2
	 *            the last universe.
	 * @return the and-universe.
	 */
	public static double[] andInterval(double[] universe1, double[] universe2) {
		double[] resultUniverse = new double[2];
		// Look for the greater low-limit
		if (universe1[0] > universe2[0]) {
			resultUniverse[0] = universe1[0];
		} else {
			resultUniverse[0] = universe2[0];
		}
		// Look for the lower great-limit
		if (universe1[1] < universe2[1]) {
			resultUniverse[1] = universe1[1];
		} else {
			resultUniverse[1] = universe2[1];
		}
		// If the universe does not intersect return and empty universe
		if (resultUniverse[0] < resultUniverse[1]) {
			return resultUniverse.clone();
		} else {
			return new double[] {};
		}
	}

	/**
	 * Calculate the points where we should evaluate for 2 piecewise linear
	 * sets.
	 * 
	 * @param paramsA
	 *            The parameters of one set.
	 * @param paramsB
	 *            The parameters of the other set.
	 * @param andUniverse
	 *            The universe where the both sets are defined.
	 * @return A list with all the point where we should evaluate.
	 */
	public static List<Double> pointsToEvaluate(List<double[]> paramsA,
			List<double[]> paramsB, double[] andUniverse) {
		double xA = 0;
		double xB = 0;
		int i1 = 0;
		int i2 = 0;
		double[] pointA, pointB;
		List<Double> pointsDef = new ArrayList<Double>();
		// While the index in both sets is inside the limits.
		while (i1 < paramsA.size() && i2 < paramsB.size()) {
			pointA = paramsA.get(i1);
			pointB = paramsB.get(i2);
			xA = pointA[0];
			xB = pointB[0];
			// Look for the lower x of both points
			if (xA <= xB) {
				// Check if the point is inside the and-universe
				// In order to avoid duplicate values, check if the list
				// contains the point before adding it
				if (xA >= andUniverse[0] && xA <= andUniverse[1]
						&& !(pointsDef.contains(xA))) {
					pointsDef.add(xA);
				}
				i1++;
			} else {
				// In order to avoid duplicate values, check if the list
				// contains the point before adding it
				if (xB >= andUniverse[0] && xB <= andUniverse[1]
						&& !(pointsDef.contains(xB))) {
					pointsDef.add(xB);
				}
				i2++;
			}
		}
		return pointsDef;
	}

	/**
	 * Calculate the lower envelope of two piecewise linear sets.
	 * 
	 * @param a
	 *            One piecewise linear set.
	 * @param b
	 *            The other piecewise linear set.
	 * @return A list with the points of the lower envelope.
	 */
	public static List<double[]> lowerEnvelope(PointSet a, PointSet b) {
		// If the and-interval
		if (andInterval(a.getUniverse(), b.getUniverse()).length == 0) {
			return null;
		}
		// Take the points to evaluate
		List<Double> points = pointsToEvaluate(a.getParameters(),
				b.getParameters(),
				andInterval(a.getUniverse(), b.getUniverse()));
		double evalA = 0;
		double evalB = 0;
		boolean aLowerThanB = false;
		double pointAux = 0;
		double[] paramAux = new double[2];
		List<double[]> params = new ArrayList<double[]>();
		// Iterate over the points where the fuzzy sets must be evaluated(the x
		// value)
		for (int i = 0; i < points.size(); i++) {
			double d = points.get(i);
			// Evaluate the number in both sets.
			evalA = a.evaluate(d);
			evalB = b.evaluate(d);
			// If this is the first point, just introduce it
			if (params.isEmpty()) {
				// Add the lower of them.
				if (evalA <= evalB) {
					params.add(new double[] { d, evalA });
					aLowerThanB = true;
				} else {
					params.add(new double[] { d, evalB });
					aLowerThanB = false;
				}
			} else {// If this is not the first point
				if (evalA <= evalB) {
					// if evalA is lower and previous evalA was lower too, just
					// put the point
					if (aLowerThanB) {
						params.add(new double[] { d, evalA });
					} else {// if the lines crosses, calculate the cross point
							// and add it. The lower evaluated point should be
							// added too.
							// Calculate the cross point
						pointAux = points.get(i - 1);
						paramAux = crossPoint(pointAux, b.evaluate(pointAux),
								a.evaluate(pointAux), d, evalB, evalA);
						// Add the cross point
						params.add(new double[] { paramAux[0], paramAux[1] });
						// Add the last point
						params.add(new double[] { d, evalA });
						aLowerThanB = true;
					}
				} else if (evalA > evalB) {
					// If evalB is lower and previous evalB was lower too, just
					// put the point
					if (!aLowerThanB) {
						params.add(new double[] { d, evalB });
					} else {// if the lines crosses, calculate the cross point
							// and add it. The lower evaluated point should be
							// added too.
							// Calculate the cross point
						pointAux = points.get(i - 1);
						paramAux = crossPoint(pointAux, a.evaluate(pointAux),
								b.evaluate(pointAux), d, evalA, evalB);
						// Add the cross point
						params.add(new double[] { paramAux[0], paramAux[1] });
						// add the last point
						params.add(new double[] { d, evalB });
						aLowerThanB = false;
					}
				}
			}
		}
		return params;
	}

	/**
	 * Calculate the upper envelope of two piecewise linear sets.
	 * 
	 * @param a
	 *            One piecewise linear set.
	 * @param b
	 *            The other piecewise linear set.
	 * @return A list with the points of the upper envelope.
	 */
	public static List<double[]> upperEnvelope(PointSet a, PointSet b) {
		// Take the points to evaluate
		List<Double> points = pointsToEvaluate(a.getParameters(),
				b.getParameters(),
				andInterval(a.getUniverse(), b.getUniverse()));
		double evalA = 0;
		double evalB = 0;
		boolean aBiggerThanB = false;
		double pointAux = 0;
		double[] paramAux = new double[2];
		List<double[]> params = new ArrayList<double[]>();
		// Iterate over the points where the fuzzy sets must be evaluated
		for (int i = 0; i < points.size(); i++) {
			double d = points.get(i);
			evalA = a.evaluate(d);
			evalB = b.evaluate(d);
			// If this is the first point, just introduce it
			if (params.isEmpty()) {
				if (evalA >= evalB) {
					params.add(new double[] { d, evalA });
					aBiggerThanB = true;
				} else {
					params.add(new double[] { d, evalB });
					aBiggerThanB = false;
				}
			} else {// If this is not the first point
				if (evalA >= evalB) {
					// if evalA is bigger and previous evalA was bigger too,
					// just put the point
					if (aBiggerThanB) {
						params.add(new double[] { d, evalA });
					} else {// if the lines crosses, calculate the cross point
							// and add it. The greater evaluated point should be
							// added too.
							// Calculate the cross point
						pointAux = points.get(i - 1);
						paramAux = crossPoint(pointAux, b.evaluate(pointAux),
								a.evaluate(pointAux), d, evalB, evalA);
						// Add the cross point
						params.add(new double[] { paramAux[0], paramAux[1] });
						// Add the last point
						params.add(new double[] { d, evalA });
						aBiggerThanB = true;
					}
				} else if (evalA < evalB) {
					// If evalB is bigger and previous evalB was bigger too,
					// just put the point
					if (!aBiggerThanB) {
						params.add(new double[] { d, evalB });
					} else {// if the lines crosses, calculate the cross point
							// and add it. The lower evaluated point should be
							// added too.
							// Calculate the cross point
						pointAux = points.get(i - 1);
						paramAux = crossPoint(pointAux, a.evaluate(pointAux),
								b.evaluate(pointAux), d, evalA, evalB);
						// Add the cross point
						params.add(new double[] { paramAux[0], paramAux[1] });
						// add the last point
						params.add(new double[] { d, evalB });
						aBiggerThanB = false;
					}
				}
			}
		}
		return params;
	}

	/**
	 * Calculate where 2 lines crosses, both lines start and end in the same
	 * places. The lines are defined with two points(x,y).
	 * 
	 * @param x1
	 *            The first x value.
	 * @param a1
	 *            The y value of line a in the first x.
	 * @param b1
	 *            The y value of line b in the first x.
	 * @param x2
	 *            The last x value.
	 * @param a2
	 *            The y value of line a in the last x.
	 * @param b2
	 *            The y value of line b in the last x.
	 * @return The resultant point.
	 */
	private static double[] crossPoint(double x1, double a1, double b1,
			double x2, double a2, double b2) {
		double[] crossPoint = new double[2];
		// Calculate the y value.
		crossPoint[1] = ((b2 * a1) - (a2 * b1)) / ((a1 - b1) + (b2 - a2));
		if (b2 == b1) {
			crossPoint[0] = x1 + ((x2 - x1) * (a1 - b2) / (a1 - a2));
			crossPoint[1] = b2;
		} else {
			crossPoint[0] = x1 + ((x2 - x1) * (crossPoint[1] - b1) / (b2 - b1));
		}
		return crossPoint.clone();
	}

	/**
	 * Calculate the degree of fulfillment of two piecewise linear sets.
	 * 
	 * @param a
	 *            One piecewise linear set.
	 * @param b
	 *            The other piecewise linear set.
	 * @return The degree of fulfillment of both sets.
	 */
	public static double piecewiseFulfillment(PointSet a, PointSet b) {
		// Calculate the lower envelope of the sets
		List<double[]> paramsEnvelope = lowerEnvelope(a, b);
		double max = Double.NEGATIVE_INFINITY;
		// If there aren't points return not a number
		if (paramsEnvelope == null) {
			return Double.NaN;
		}
		// Calculate the max value of all points of the lower envelope
		for (double[] point : paramsEnvelope) {
			if (point[1] > max) {
				max = point[1];
			}
		}
		return max;
	}

}

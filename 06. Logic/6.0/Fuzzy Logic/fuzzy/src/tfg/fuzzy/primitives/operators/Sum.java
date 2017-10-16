package tfg.fuzzy.primitives.operators;

import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.LogoList;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.primitives.implication.Cut;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.operator.SumSet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class implements the primitives "sum".
 * 
 * @author Marcos Almendres.
 * 
 */
public class Sum implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a list and returns a Wildcard.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.ListType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return The new fuzzy set with the sum of all fuzzy sets.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		LogoList listOfSets = arg0[0].getList();
		int type = -1;
		// If there is only one set just report that set.
		if (listOfSets.size() == 1) {
			return listOfSets.first();
		}
		// Checks the types of all the fuzzy sets inside the list.
		type = SupportOperators.allType(listOfSets);
		// Call to the appropriate method.
		switch (type) {
		case 0:
			throw new ExtensionException(
					"The fuzzy sets must be all discrete or all continuous");
		case 1:
			return sumDiscrete(listOfSets);
		case 2:
			return sumPiecewise(listOfSets);
		case 3:
			return sumContinuous(listOfSets);
		default:
			return null;
		}
	}

	/**
	 * Calculate the sum of two or more discrete sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet sumDiscrete(LogoList l) {
		// Calculate parameters and universe
		Tuple<double[]> t = SupportOperators.discreteOperations(l, new Add());
		// Create and return the new set.
		return new DiscreteNumericSet(t.getParams(), false,
				SupportOperators.buildLabel(l, "Sum"), t.getUniverse());
	}

	/**
	 * Calculate the sum of two or more piecewise sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet sumPiecewise(LogoList l) {
		PointSet setA = (PointSet) l.first();
		PointSet setB;
		List<Double> points;
		double[] universe = setA.getUniverse();
		List<double[]> result = setA.getParameters();
		// Im not proud at all about this implementation
		// Sum the parameters of the piecewise linear sets 2 by 2.
		for (int i = 1; i < l.size(); i++) {
			setB = (PointSet) l.get(i);
			// and-universe of 2 sets
			universe = DegreeOfFulfillment.andInterval(universe,
					setB.getUniverse());
			// points where we should evaluate
			points = DegreeOfFulfillment.pointsToEvaluate(result,
					setB.getParameters(), universe);
			result.clear();
			// Create parameters with the sum of the two actual piecewise sets.
			for (double d : points) {
				result.add(new double[] { d,
						setA.evaluate(d) + setB.evaluate(d) });
			}
			setA = new PiecewiseLinearSet(result, true, "inter", universe);
		}
		// Cut the set with a line in y=1 to clip values above 1.
		Cut c = new Cut();
		return c.cutting(
				new PiecewiseLinearSet(result, true, SupportOperators
						.buildLabel(l, "Sum"), universe), 1.0);
	}

	/**
	 * Calculate the sum of two or more continuous sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet sumContinuous(LogoList l) {
		Tuple<FuzzySet> t = SupportOperators.continuousParamsUniverse(l);
		return new SumSet(t.getParams(), true, SupportOperators.buildLabel(l,
				"Sum"), t.getUniverse());
	}

	/**
	 * Inner class that implements the command to perform in sum operations. Add
	 * the values of two points.
	 * 
	 * @author Marcos Almendres.
	 * 
	 */
	public class Add implements Command {

		/**
		 * {@inheritDoc}Sum the y value of two points.
		 */
		@Override
		public double[] execute(double[] pointA, double[] pointB) {
			double[] resultPoint = new double[2];
			resultPoint[0] = pointA[0];
			// Sum the y values.
			resultPoint[1] = pointA[1] + pointB[1];
			// If greater than 1 clip it.
			if (resultPoint[1] > 1) {
				resultPoint[1] = 1;
			}
			return resultPoint.clone();
		}

	}

}

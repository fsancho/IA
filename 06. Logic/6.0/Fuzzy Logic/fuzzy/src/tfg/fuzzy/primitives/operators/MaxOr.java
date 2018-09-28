package tfg.fuzzy.primitives.operators;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.LogoList;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.operator.MaxOrSet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class implements the primitives "max" and "or".
 * 
 * @author Marcos Almendres.
 * 
 */
public class MaxOr implements Reporter {

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
	 * @return The new fuzzy set with the max of all fuzzy sets.
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
			return maxDiscrete(listOfSets);
		case 2:
			return maxPiecewise(listOfSets);
		case 3:
			return maxContinuous(listOfSets);
		default:
			return null;
		}
	}

	/**
	 * Calculate the max of two or more discrete sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet maxDiscrete(LogoList l) {
		Tuple<double[]> t = SupportOperators.discreteOperations(l, new Max());
		// Create a new Discrete numeric set with the resulting parameters
		return new DiscreteNumericSet(t.getParams(), false,
				SupportOperators.buildLabel(l, "Max"), t.getUniverse());
	}

	/**
	 * Calculate the max of two or more piecewise sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet maxPiecewise(LogoList l) {
		PointSet setA = (PointSet) l.first();
		double[] universe = new double[2];
		PointSet setB;
		// Iterate over the sets
		for (int i = 1; i < l.size(); i++) {
			setB = (PointSet) l.get(i);
			// Calculate the andUniverse of the two sets
			universe = DegreeOfFulfillment.andInterval(setA.getUniverse(),
					setB.getUniverse());
			// Create a new set, the min piecewise of 2 piecewise.
			// Calculate the max of all sets 2 by 2.
			setA = new PiecewiseLinearSet(DegreeOfFulfillment.upperEnvelope(
					setA, setB), true, SupportOperators.buildLabel(l, "Max"),
					universe);
		}
		return setA;
	}

	/**
	 * Calculate the max of two or more continuous sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet maxContinuous(LogoList l) {
		Tuple<FuzzySet> t = SupportOperators.continuousParamsUniverse(l);
		return new MaxOrSet(t.getParams(), true, SupportOperators.buildLabel(l,
				"Max"), t.getUniverse());
	}

	/**
	 * Inner class that implements the command to perform in max operations.
	 * Take the maximum value of two points.
	 * 
	 * @author Marcos Almendres.
	 * 
	 */
	public class Max implements Command {

		/**
		 * {@inheritDoc} Take the max value of them.
		 */
		@Override
		public double[] execute(double[] pointA, double[] pointB) {
			double[] resultPoint = new double[2];
			resultPoint[0] = pointA[0];
			// find the max value
			if (pointA[1] >= pointB[1]) {
				resultPoint[1] = pointA[1];
			} else {
				resultPoint[1] = pointB[1];
			}
			return resultPoint.clone();
		}
	}
}

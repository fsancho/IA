package tfg.fuzzy.primitives.operators;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultReporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.LogoList;
import org.nlogo.api.Syntax;

import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.operator.ProbOrSet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;

/**
 * This class implements the primitives "prob-or".
 * 
 * @author Marcos Almendres.
 * 
 */
public class ProbOr extends DefaultReporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a list and returns a Wildcard.
	 */
	public Syntax getSyntax() {
		return Syntax.reporterSyntax(new int[] { Syntax.ListType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return The new fuzzy set with the probabilistic-or of all fuzzy sets.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzySet set;
		LogoList listOfSets = arg0[0].getList();
		if (listOfSets.size() == 1) {
			return listOfSets.first();
		}
		boolean allContinuous = true;
		boolean allDiscrete = true;
		// Checks if all continuous or all discrete.
		for (Object o : listOfSets) {
			set = (FuzzySet) o;
			allContinuous &= set.isContinuous();
			allDiscrete &= !set.isContinuous();
		}
		// Call the appropriate method
		if (allContinuous) {
			return probContinuous(listOfSets);
		} else if (allDiscrete) {
			return probDiscrete(listOfSets);
		} else {
			throw new ExtensionException(
					"The sets must be all continuous or all discrete");
		}
	}

	/**
	 * Calculate the probabilistic-or of two or more discrete sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet probDiscrete(LogoList l) {
		Tuple<double[]> t = SupportOperators.discreteOperations(l, new Prob());
		return new DiscreteNumericSet(t.getParams(), false,
				SupportOperators.buildLabel(l, "Prob-or"), t.getUniverse());
	}

	/**
	 * Calculate the probabilistic-or of two or more piecewise sets.
	 * 
	 * @param l
	 *            The list with the fuzzy sets.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet probContinuous(LogoList l) {
		Tuple<FuzzySet> t = SupportOperators.continuousParamsUniverse(l);
		return new ProbOrSet(t.getParams(), true, SupportOperators.buildLabel(
				l, "Prob-or"), t.getUniverse());
	}

	/**
	 * Inner class that implements the command to perform in probabilistic or
	 * operations. Apply the formula: y1 + y2 -(y1*y2).
	 * 
	 * @author Marcos Almendres.
	 * 
	 */
	public class Prob implements Command {

		/**
		 * {@inheritDoc}Apply the formula: y1 + y2 -(y1*y2) to two points.
		 */
		@Override
		public double[] execute(double[] pointA, double[] pointB) {
			double[] resultPoint = new double[2];
			resultPoint[0] = pointA[0];
			resultPoint[1] = pointA[1] + pointB[1] - pointA[1] * pointB[1];
			return resultPoint.clone();
		}

	}

}

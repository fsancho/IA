package tfg.fuzzy.primitives.implication;

import java.util.ArrayList;
import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.DegreeOfFulfillment;
import tfg.fuzzy.sets.derived.CutSet;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class implements the primitive truncate.
 * 
 * @author Marcos Almendres.
 *
 */
public class Cut implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and a number, returns a wildcard.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(
				new int[] { Syntax.WildcardType(), Syntax.NumberType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the truncated
	 * fuzzy set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A fuzzy set.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		double c = arg0[1].getDoubleValue();
		// Checks the number is between 0 and 1
		if (c < 0 || c > 1) {
			throw new ExtensionException(
					"The value of the number must be between 0 and 1");
		}
		FuzzySet f = (FuzzySet) arg0[0].get();
		return cutting(f, c);
	}

	/**
	 * Checks what kind of fuzzy set is passed and execute the correct action.
	 * 
	 * @param f
	 *            The fuzzy set to be truncated.
	 * @param c
	 *            The number to truncate the fuzzy set.
	 * @return The fuzzy set truncated by the number.
	 */
	public FuzzySet cutting(FuzzySet f, double c) {
		if (f.isContinuous()) {
			// If piecewise
			if (f instanceof PiecewiseLinearSet) {
				return cutPiecewise((PointSet) f, c);
			} else {// If continuous
				return new CutSet(f, c, true, "continuous-cut", f.getUniverse());
			}
		} else {// If discrete
			return cutDiscrete((PointSet) f, c);
		}
	}

	/**
	 * Truncate a discrete set.
	 * 
	 * @param f
	 *            The discrete set.
	 * @param c
	 *            The number to truncate the set.
	 * @return The truncated discrete set.
	 */
	public FuzzySet cutDiscrete(PointSet f, double c) {
		List<double[]> params = new ArrayList<double[]>();
		double[] resultPoint = new double[2];
		// Iterate over the parameters
		for (double[] point : f.getParameters()) {
			resultPoint[0] = point[0];
			// If the y value is greater than c, clip it.
			if (point[1] > c) {
				resultPoint[1] = c;
			} else {
				resultPoint[1] = point[1];
			}
			params.add(resultPoint.clone());
		}
		// Create and return the new truncated set.
		return new DiscreteNumericSet(params, false, "discrete-cut",
				f.getUniverse());
	}

	/**
	 * Truncate a piecewise linear set.
	 * 
	 * @param f
	 *            The piecewise linear set.
	 * @param c
	 *            The number to truncate the set.
	 * @return The truncated piecewise linear set.
	 */
	public FuzzySet cutPiecewise(PointSet f, double c) {
		// Create a line in the whole universe with y = c
		double[] firstPoint = new double[] { f.getUniverse()[0], c };
		double[] lastPoint = new double[] { f.getUniverse()[1], c };
		List<double[]> paramsLine = new ArrayList<double[]>();
		paramsLine.add(firstPoint);
		paramsLine.add(lastPoint);
		PointSet cutLine = new PiecewiseLinearSet(paramsLine, true, "cut-line",
				f.getUniverse());
		// Calculate the lower envelope and create the resulting set
		// This will clip all values above c
		return new PiecewiseLinearSet(DegreeOfFulfillment.lowerEnvelope(f,
				cutLine), true, "piecewise-cut", f.getUniverse());
	}

}

package tfg.fuzzy.primitives.operators;

import java.util.ArrayList;
import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.operator.NotSet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class implements the primitives "not".
 * 
 * @author Marcos Almendres.
 * 
 */
public class Not implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and returns a Wildcard.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.WildcardType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a fuzzy set.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return The new fuzzy set with the operation "not" of a fuzzy sets.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzySet f = (FuzzySet) arg0[0].get();
		// Call to the appropriate method
		if (f.isContinuous()) {
			if (f instanceof PiecewiseLinearSet) {
				return notPiecewise((PointSet) f);
			} else {
				return notContinuous(f);
			}
		} else {
			return notDiscrete((PointSet) f);
		}
	}

	/**
	 * Calculate the logical not of a discrete set.
	 * 
	 * @param f
	 *            The discrete set.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet notDiscrete(PointSet f) {
		List<double[]> params = new ArrayList<double[]>();
		double[] createPoint = new double[2];
		// Apply to all points in the set: y = 1 - y
		for (double[] point : f.getParameters()) {
			createPoint[0] = point[0];
			createPoint[1] = 1 - point[1];
			params.add(createPoint.clone());
		}
		return new DiscreteNumericSet(params, false, "Not of set: "
				+ f.getLabel(), f.getUniverse());
	}

	/**
	 * Calculate the logical not of a piecewise set.
	 * 
	 * @param f
	 *            The piecewise linear set.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet notPiecewise(PointSet f) {
		List<double[]> params = new ArrayList<double[]>();
		double[] createPoint = new double[2];
		for (double[] point : f.getParameters()) {
			createPoint[0] = point[0];
			createPoint[1] = 1 - point[1];
			params.add(createPoint.clone());
		}
		return new PiecewiseLinearSet(params, true, "Not of set: "
				+ f.getLabel(), f.getUniverse());
	}

	/**
	 * Calculate the logical not of a continuous set.
	 * 
	 * @param f
	 *            The fuzzy set.
	 * @return The resulting fuzzy set.
	 */
	private FuzzySet notContinuous(FuzzySet f) {
		List<FuzzySet> params = new ArrayList<FuzzySet>();
		params.add(f);
		return new NotSet(params, true, "Not of set: " + f.getLabel(),
				f.getUniverse());
	}

}

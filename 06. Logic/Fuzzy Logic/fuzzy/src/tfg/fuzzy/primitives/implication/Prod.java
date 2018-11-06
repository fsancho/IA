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

import tfg.fuzzy.sets.derived.ProdSet;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class implements the prod primitive.
 * 
 * @author Marcos Almendres.
 *
 */
public class Prod implements Reporter {

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
	 * This method respond to the call from Netlogo and returns the prodded fuzzy
	 * set.
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
		return prodding(f, c);
	}

	/**
	 * Checks what kind of fuzzy set is passed and execute the correct action.
	 * 
	 * @param f
	 *            The fuzzy set to prodded.
	 * @param c
	 *            The number to prod the fuzzy set.
	 * @return The fuzzy set prodded by the number.
	 */
	public FuzzySet prodding(FuzzySet f, double c) {
		if (f.isContinuous()) {
			if (f instanceof PiecewiseLinearSet) {
				return prodPiecewise((PointSet) f, c);
			} else {
				return new ProdSet(f, c, true, "continuous-prob",
						f.getUniverse());
			}
		} else {
			return prodDiscrete((PointSet) f, c);
		}
	}

	/**
	 * Apply prod to a piecewise linear set.
	 * 
	 * @param p
	 *            The piecewise linear set.
	 * @param c
	 *            The number to prod the set.
	 * @return The piecewise linear set after applying prod.
	 */
	public FuzzySet prodPiecewise(PointSet p, double c) {
		List<double[]> params = new ArrayList<double[]>();
		double[] resultPoint = new double[2];
		for (double[] point : p.getParameters()) {
			resultPoint[0] = point[0];
			resultPoint[1] = point[1] * c;
			params.add(resultPoint.clone());
		}
		return new PiecewiseLinearSet(params, true, "piecewise-prod",
				p.getUniverse());
	}

	/**
	 * Apply prod to a discrete set.
	 * 
	 * @param p
	 *            The discrete set.
	 * @param c
	 *            The number to prod the set.
	 * @return The discrete set after applying prod.
	 */
	public FuzzySet prodDiscrete(PointSet p, double c) {
		List<double[]> params = new ArrayList<double[]>();
		double[] resultPoint = new double[2];
		for (double[] point : p.getParameters()) {
			resultPoint[0] = point[0];
			resultPoint[1] = point[1] * c;
			params.add(resultPoint.clone());
		}
		return new DiscreteNumericSet(params, false, "discrete-prod",
				p.getUniverse());
	}

}

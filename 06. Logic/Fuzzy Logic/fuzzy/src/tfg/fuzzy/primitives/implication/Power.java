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

import tfg.fuzzy.sets.derived.PowerSet;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;

/**
 * This class implements the primitive power.
 * 
 * @author Marcos Almendres.
 *
 */
public class Power implements Reporter {

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
	 * This method respond to the call from Netlogo and returns the powered
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
		double exp = arg0[1].getDoubleValue();
		// Checks the exponent is greater than 0.
		if (exp < 0) {
			throw new ExtensionException(
					"The value of the number must be greater than 0");
		}
		FuzzySet f = (FuzzySet) arg0[0].get();
		if (f.isContinuous()) {
			return new PowerSet(f, exp, true, "continuous-power",
					f.getUniverse());
		} else {
			return powerDiscrete((PointSet) f, exp);
		}
	}

	/**
	 * Power a discrete set to the exponent given.
	 * 
	 * @param p
	 *            The discrete set.
	 * @param exp
	 *            The exponent.
	 * @return The resultant discrete set.
	 */
	public FuzzySet powerDiscrete(PointSet p, double exp) {
		List<double[]> params = new ArrayList<double[]>();
		double[] resultPoint = new double[2];
		for (double[] point : p.getParameters()) {
			resultPoint[0] = point[0];
			resultPoint[1] = Math.pow(point[1], exp);
			params.add(resultPoint.clone());
		}
		return new DiscreteNumericSet(params, false, "discrete-power",
				p.getUniverse());
	}

}

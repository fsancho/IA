package tfg.fuzzy.primitives.rules;

import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.primitives.implication.Prod;
import tfg.fuzzy.sets.general.EmptySet;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class implements the max-prod-rule primitive.
 * 
 * @author Marcos Almendres.
 *
 */
public class MaxProdRule implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a list and a wildcard, returns a wildcard.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(
				new int[] { Syntax.ListType(), Syntax.WildcardType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the prodded
	 * fuzzy set after applying the rules given.
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
		FuzzySet conseq = (FuzzySet) arg0[1].get();
		// Checks the format and evaluate all the rules inside the list.
		List<Double> evaluations = SupportRules.variadicRulesChecks(arg0[0]
				.getList());
		double max = Double.NEGATIVE_INFINITY;
		for (double d : evaluations) {
			// If one evaluation is Not a Number return an empty set.
			if (d == Double.NaN) {
				return new EmptySet();
			}
			// Look for the max evaluated value.
			if (d > max) {
				max = d;
			}
		}
		Prod p = new Prod();
		// Prod the fuzzy set with the maximum value found
		return p.prodding(conseq, max);
	}

}

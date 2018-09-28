package tfg.fuzzy.primitives.rules;

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
 * This class implements the prod-rule primitive.
 * 
 * @author Marcos Almendres.
 *
 */
public class ProdRule implements Reporter {

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
	 * fuzzy set after applying the rule given.
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
		double eval = 0;
		FuzzySet conseq = (FuzzySet) arg0[1].get();
		// Checks the format of the list and evaluate the rule inside.
		eval = SupportRules.simpleRulesChecks(arg0[0].getList());
		// If Not a Number return an empty set.
		if (eval == Double.NaN) {
			return new EmptySet();
		} else {
			// Prod the fuzzy set with the evaluated number.
			Prod p = new Prod();
			return p.prodding(conseq, eval);
		}
	}

}

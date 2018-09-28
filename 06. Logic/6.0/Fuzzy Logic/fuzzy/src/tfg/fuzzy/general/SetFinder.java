package tfg.fuzzy.general;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

/**
 * This class implements the fuzzy-set-with-label primitive.
 * 
 * @author Marcos Almendres.
 * 
 */
public class SetFinder implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a string and returns a Wildcard.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.StringType() },
				Syntax.WildcardType());
	}

	@Override
	/**
	 * This method respond to the call from Netlogo and returns the set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A Fuzzy Set.
	 */
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		// If the string is not in the map throw an exception
		if (FuzzyLogic.getRegistry().containsKey(arg0[0].getString())) {
			// Get the fuzzy set with the label given.
			return FuzzyLogic.getRegistry().get(arg0[0].getString());
		} else {
			throw new ExtensionException("There is no Fuzzy Set with label: "
					+ arg0[0].getString());
		}
	}
}

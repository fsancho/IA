package tfg.fuzzy.primitives.labeling;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.FuzzyLogic;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class implements the primitive has-label?.
 * @author Marcos Almendres.
 *
 */
public class HasLabel implements Reporter{
	
	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and report a boolean.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.WildcardType() },
				Syntax.BooleanType());
	}

	/**
	 * This method respond to the call from Netlogo and checks if the given
	 * fuzzy set has a label assigned.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a fuzzy set.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		return(FuzzyLogic.getRegistry().containsValue((FuzzySet) arg0[0].get()));	
	}

}

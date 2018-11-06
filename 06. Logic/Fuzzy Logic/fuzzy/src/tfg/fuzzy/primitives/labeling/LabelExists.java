package tfg.fuzzy.primitives.labeling;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.FuzzyLogic;

/**
 * This class implements the primitive label-exists?.
 * 
 * @author Marcos Almendres.
 *
 */
public class LabelExists implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a string and report a boolean.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.StringType() },
				Syntax.BooleanType());
	}

	/**
	 * This method respond to the call from Netlogo and checks if the given
	 * label exists.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a string.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		return FuzzyLogic.getRegistry().containsKey(arg0[0].getString());
	}

}

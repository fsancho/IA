package tfg.fuzzy.primitives.creation;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Command;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.SupportFunctions;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class implements the primitive set-label.
 * @author Marcos Almendres.
 *
 */
public class SetLabel implements Command {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and a string and report nothing because it is a command.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.commandSyntax(new int[] { Syntax.WildcardType(),
				Syntax.StringType() });
	}

	/**
	 * This method respond to the call from Netlogo and assign a label to a fuzzy set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a fuzzy set and a string.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public void perform(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzySet f = (FuzzySet) arg0[0].get();
		String label = arg0[1].getString();
		f.setLabel(label);
		SupportFunctions.addToRegistry(f, label, arg1);
	}
}

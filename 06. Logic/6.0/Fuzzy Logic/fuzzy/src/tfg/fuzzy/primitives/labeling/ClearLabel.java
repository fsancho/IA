package tfg.fuzzy.primitives.labeling;

import java.util.Map;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Command;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.FuzzyLogic;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class implements the primitive clear-label.
 * @author Marcos Almendres.
 *
 */
public class ClearLabel implements Command {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a string and report nothing because it is a command.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.commandSyntax(new int[] { Syntax.StringType() });
	}

	/**
	 * This method respond to the call from Netlogo and erase the label assigned
	 * to a fuzzy set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a string.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public void perform(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		String label = arg0[0].getString();
		Map<String, FuzzySet> r = FuzzyLogic.getRegistry();
		if (r.containsKey(label)) {
			r.remove(label);
		} else {
			throw new ExtensionException("That label does not exist");
		}
	}
}

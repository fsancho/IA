package tfg.fuzzy.primitives.labeling;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.DefaultCommand;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.Syntax;

import tfg.fuzzy.general.FuzzyLogic;

/**
 * This class implments the primitive clear.
 * 
 * @author Marcos Almendres.
 *
 */
public class Clear extends DefaultCommand {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives nothing and report nothing because it is a command.
	 */
	public Syntax getSyntax() {
		return Syntax.commandSyntax();
	}

	/**
	 * This method respond to the call from Netlogo and clear the mapping of
	 * fuzzy sets with label.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public void perform(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzyLogic.resetRegistry();
	}

}

package tfg.fuzzy.primitives.creation;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Command;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.SupportFunctions;

/**
 * This class allows users(from Netlogo) to change the resolution used for
 * working with continuous sets.
 * 
 * @author Marcos Almendres.
 *
 */
public class Resolution implements Command {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a number and returns nothing cause this is command.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.commandSyntax(new int[] { Syntax.NumberType() });
	}

	/**
	 * This method perform the call from Netlogo and sets the given resolution.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a number.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public void perform(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		SupportFunctions.setResolution(arg0[0].getDoubleValue());
	}
}

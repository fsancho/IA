package tfg.fuzzy.primitives.creation;

import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.SupportFunctions;
import tfg.fuzzy.sets.points.DiscreteNumericSet;

/**
 * This class creates a new discrete numeric set. Implements the primitive
 * "discrete-numeric-set".
 * 
 * @author Marcos Almendres.
 *
 */
public class DiscreteNumeric implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a list and returns a Wildcard.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.ListType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A new DiscreteNumericSet.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		double[] universe = new double[] { Double.POSITIVE_INFINITY,
				Double.NEGATIVE_INFINITY };
		// Checks the list format and store the parameters of the set in a list.
		List<double[]> ej = SupportFunctions.checkListFormat(arg0[0].getList());
		// Sets the universe.
		universe[0] = ej.get(0)[0];
		universe[1] = ej.get(ej.size() - 1)[0];
		// Create and return the new discrete numeric set
		return new DiscreteNumericSet(ej, false, "discrete", universe);
	}
}

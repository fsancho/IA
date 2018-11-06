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
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;

/**
 * This class creates a new discrete numeric set with the label given.
 * Implements the primitive "discrete-numeric-set-with-label".
 * 
 * @author Marcos Almendres.
 *
 */
public class DiscreteNumericWithLabel implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a string and a list and returns a Wildcard.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(
				new int[] { Syntax.StringType(), Syntax.ListType() },
				Syntax.WildcardType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a string and a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A new DiscreteNumericSet.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		// The same as DiscreteNumeric
		double[] universe = new double[] { Double.POSITIVE_INFINITY,
				Double.NEGATIVE_INFINITY };
		List<double[]> ej = SupportFunctions.checkListFormat(arg0[1].getList());
		universe[0] = ej.get(0)[0];
		universe[1] = ej.get(ej.size() - 1)[0];
		FuzzySet createdSet = new DiscreteNumericSet(ej, false,
				arg0[0].getString(), universe);
		// Add the set to a registry, allowing to look for it in the future.
		SupportFunctions.addToRegistry(createdSet, arg0[0].getString(),arg1);
		return createdSet;
	}
}

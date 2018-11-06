package tfg.fuzzy.primitives.creation;

import java.util.ArrayList;
import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.LogoList;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.SupportFunctions;
import tfg.fuzzy.sets.function.GaussianSet;

/**
 * This class creates a new gaussian set. Implements the primitive
 * "gaussian-set".
 * 
 * @author Marcos Almendres.
 *
 */
public class Gaussian implements Reporter {

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
	 * @return A new GaussianSet.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		LogoList params = arg0[0].getList();
		List<Double> resultParams = new ArrayList<Double>();
		// Checks the format of the parameters
		double[] universe = SupportFunctions.LGEFormat(params, 3);
		// Add the parameters to a list
		resultParams.add((Double) params.first());
		resultParams.add((Double) params.get(1));
		// Create and return the new set
		return new GaussianSet(resultParams, true, "gaussian", universe);
	}
}

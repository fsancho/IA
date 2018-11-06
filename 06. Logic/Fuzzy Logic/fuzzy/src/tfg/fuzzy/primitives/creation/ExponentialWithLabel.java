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
import tfg.fuzzy.sets.function.ExponentialSet;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class creates a new exponential set with the label given. Implements the
 * primitive "exponential-set-with-label".
 * 
 * @author Marcos Almendres.
 *
 */
public class ExponentialWithLabel implements Reporter {

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
	 * @return A new ExponentialSet.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		// The same as Exponential
		LogoList params = arg0[1].getList();
		List<Double> finalParams = new ArrayList<Double>();
		double[] universe = SupportFunctions.LGEFormat(params, 4);
		finalParams.add((Double) params.first());
		finalParams.add((Double) params.get(1));
		finalParams.add((Double) params.get(2));
		FuzzySet createdSet = new ExponentialSet(finalParams, true,
				arg0[0].getString(), universe);
		// Add the set to a registry, allowing to look for it in the future.
		SupportFunctions.addToRegistry(createdSet, arg0[0].getString(),arg1);
		return createdSet;
	}
}

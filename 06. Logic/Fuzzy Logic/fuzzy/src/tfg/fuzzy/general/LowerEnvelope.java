package tfg.fuzzy.general;

import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.sets.general.PointSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class implements the lower-envelope primitive.
 * 
 * @author Marcos Almendres.
 * 
 */
public class LowerEnvelope implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives 2 lists and returns another list.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(
				new int[] { Syntax.ListType(), Syntax.ListType() },
				Syntax.ListType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the lower
	 * envelope parameters.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A new lower envelope.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		LogoListBuilder endAux = new LogoListBuilder();
		LogoListBuilder end = new LogoListBuilder();
		List<double[]> result;
		// Build the both piecewise linear sets.
		PointSet a = new PiecewiseLinearSet(
				SupportFunctions.checkListFormat(arg0[0].getList()), true,
				"uno", SupportFunctions.universe(arg0[0].getList()));
		PointSet b = new PiecewiseLinearSet(
				SupportFunctions.checkListFormat(arg0[1].getList()), true,
				"otro", SupportFunctions.universe(arg0[1].getList()));
		// Calculate the lower envelope
		result = DegreeOfFulfillment.lowerEnvelope(a, b);
		// Add the points of the lower envelope in the logolist
		for (double[] point : result) {
			endAux = new LogoListBuilder();
			endAux.add(point[0]);
			endAux.add(point[1]);
			end.add(endAux.toLogoList());
		}
		return end.toLogoList();
	}

}

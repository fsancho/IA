package tfg.fuzzy.general;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.LogoList;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

/**
 * This class calculate the and-universe of two sets.
 * @author Marcos Almendres.
 *
 */
public class AndInterval implements Reporter{
	
	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives two lists and report another list.
	 */
	public Syntax getSyntax(){
		return SyntaxJ.reporterSyntax(new int[]{Syntax.ListType(),Syntax.ListType()},Syntax.ListType());
	}

	@Override
	/**
	 * This method respond to the call from Netlogo and returns the and-interval.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a 2 list.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A list representing the and-universe.
	 */
	public Object report(Argument[] arg0, Context arg1) throws ExtensionException, LogoException {
		LogoList universe1 = arg0[0].getList();
		LogoList universe2 = arg0[1].getList();
		double[] univ1 = new double[]{(Double) universe1.first(),(Double) universe1.get(1)};
		double[] univ2 = new double[]{(Double) universe2.first(),(Double) universe2.get(1)};
		double[] fin = DegreeOfFulfillment.andInterval(univ1, univ2);
		LogoListBuilder log = new LogoListBuilder();
		if(fin.length == 2){
			log.add(fin[0]);
			log.add(fin[1]);
		}else{
			throw new ExtensionException("Vacio");
		}

		return log.toLogoList();
	}

}

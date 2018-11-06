package tfg.fuzzy.primitives.labeling;

import java.util.Map;
import java.util.Map.Entry;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.general.FuzzyLogic;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class implements the primitive label-of.
 * 
 * @author Marcos Almendres.
 *
 */
public class LabelOfSet implements Reporter {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and report a string.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.reporterSyntax(new int[] { Syntax.WildcardType() },
				Syntax.StringType());
	}

	/**
	 * This method respond to the call from Netlogo and returns the label of the
	 * given fuzzy set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a fuzzy set.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzySet f =(FuzzySet) arg0[0].get();
		Map<String,FuzzySet> reg = FuzzyLogic.getRegistry();
		if(reg.containsValue(f)){
			for(Entry<String, FuzzySet> ent : reg.entrySet()){
				if(ent.getValue() == f){
					return ent.getKey();
				}
			}
		}else{
			throw new ExtensionException("The fuzzy set has not a label assigned");
		}
		return null;
	}

}

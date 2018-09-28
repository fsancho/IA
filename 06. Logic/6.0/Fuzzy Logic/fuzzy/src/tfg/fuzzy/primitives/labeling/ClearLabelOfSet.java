package tfg.fuzzy.primitives.labeling;

import java.util.Map;
import java.util.Map.Entry;

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
 * This class implements the primitive clear-label-of.
 * @author Marcos Almendres.
 *
 */
public class ClearLabelOfSet implements Command {

	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and report nothing because it is a command.
	 */
	public Syntax getSyntax() {
		return SyntaxJ.commandSyntax(new int[] { Syntax.WildcardType() });
	}

	/**
	 * This method respond to the call from Netlogo and delete the label of the given fuzzy set.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a fuzzy set.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public void perform(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzySet f = (FuzzySet) arg0[0].get();
		String key;
		Map<String,FuzzySet> reg = FuzzyLogic.getRegistry();
		//If the registry contains the fuzzy set given
		if(reg.containsValue(f)){
			//Iterate over the entries
			for(Entry<String,FuzzySet> entry : reg.entrySet()){
				//If the fuzzy set is the same delete that mapping
				if(f == entry.getValue()){
					key = entry.getKey();
					reg.remove(key);
					break;
				}
			}
		}else{
			throw new ExtensionException("That fuzzy set has not label");
		}
	}

}

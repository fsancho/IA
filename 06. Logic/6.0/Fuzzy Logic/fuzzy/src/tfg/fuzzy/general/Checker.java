package tfg.fuzzy.general;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.sets.general.FunctionSet;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.general.OperatorSet;
import tfg.fuzzy.sets.general.PointSet;

/**
 * This class shows in netlogo the variables of the Fuzzy set.
 * @author Marcos Almendres.
 *
 */
public class Checker implements Reporter {
	
	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a Wildcard and returns a list.
	 */
	public Syntax getSyntax(){
		return SyntaxJ.reporterSyntax(new int[] {Syntax.WildcardType()},Syntax.ListType());
	}

	@Override
	/**
	 * This method respond to the call from Netlogo and returns the list with the variables.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a fuzzy set.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 * @return A list with the variables.
	 */
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		FuzzySet setToCheck = (FuzzySet) arg0[0].get();
		LogoListBuilder list = new LogoListBuilder();
		LogoListBuilder param = new LogoListBuilder();
		LogoListBuilder aux = new LogoListBuilder();
		//Add the description of the set
		list.add(setToCheck.getDescription());
		//If Point set
		if(setToCheck instanceof PointSet){
			PointSet ps = (PointSet) setToCheck;
			//Add the parameters
			for(double[] point : ps.getParameters()){
				aux = new LogoListBuilder();
				aux.add(point[0]);
				aux.add(point[1]);
				param.add(aux.toLogoList());
			}
		//If Function set
		}else if(setToCheck instanceof FunctionSet){
			FunctionSet ps = (FunctionSet) setToCheck;
			//Add the parameters
			for(double point : ps.getParameters()){
				param.add(point);
			}
		}else{//If operator set
			OperatorSet ms = (OperatorSet) setToCheck;
			//Iterate over the fuzzy sets
			for(FuzzySet set : ms.getParameters()){
					param.add(set.getDescription());
					//Add the parameters
					if(set instanceof PointSet){
						PointSet ps = (PointSet) set;
						for(double[] point : ps.getParameters()){
							aux = new LogoListBuilder();
							aux.add(point[0]);
							aux.add(point[1]);
							param.add(aux.toLogoList());
						}
					}else if(set instanceof FunctionSet){
						FunctionSet fs = (FunctionSet) set;
						aux = new LogoListBuilder();
						for(double d : fs.getParameters()){
							aux.add(d);
						}
						param.add(aux.toLogoList());
					}
			}
		}
		list.add(param.toLogoList());
		LogoListBuilder universe = new LogoListBuilder();
		universe.add(setToCheck.getUniverse()[0]);
		universe.add(setToCheck.getUniverse()[1]);
		list.add(universe.toLogoList());
		list.add(setToCheck.getLabel());
		return list.toLogoList();
	}

}

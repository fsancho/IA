package tfg.fuzzy.general;

import java.util.Iterator;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.LogoList;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class implements the evaluation primitive
 * @author Marcos Almendres.
 *
 */
public class Evaluation implements Reporter {
	
	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a list and returns a Wildcard.
	 */
	public Syntax getSyntax(){
		return SyntaxJ.reporterSyntax(new int[] {Syntax.WildcardType(),Syntax.WildcardType()},Syntax.ReadableType());
	}

	@Override
	/**
	 * When the extension is loaded call this method.
	 */
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		//Checks if the first argument is a FuzzySet.
		if(!(arg0[0].get() instanceof FuzzySet)){
			throw new ExtensionException("The first argument must be a fuzzySet");
		}
		FuzzySet fuzzySet = (FuzzySet) arg0[0].get();
		Object obj = arg0[1].get();
		//If the second argument is a fuzzySet call degreeOfFulfillment
		//if its a Double call singleEvaluation
		//if its a LogoList call multipleEvaluation
		//if its any other class it throw a extension exception
		if(obj instanceof FuzzySet){
			return fuzzySet.evaluate((FuzzySet)obj);
		}else if(obj instanceof Double){
			return fuzzySet.evaluate((Double) obj);
		}else if(obj instanceof LogoList){
			return multipleEvaluation(fuzzySet,(LogoList) obj);
		}else{
			throw new ExtensionException("The second argument must be a fuzzySet, a Number or a List");
		}
	}
	
	/**
	 * Calculate all the evaluations of the logo list elements.
	 * @param a The fuzzy set where the we should evaluate.
	 * @param b The logo list that contains the elements.
	 * @return A Logo list with all the evaluation results.
	 * @throws ExtensionException
	 */
	public Object multipleEvaluation(FuzzySet a, LogoList b) throws ExtensionException{
		LogoListBuilder result = new LogoListBuilder();
		//Iterate over the LogoList
		Iterator<Object> it = b.javaIterator();
		while (it.hasNext()) {
			Object o = it.next();
			//If object is a fuzzySet call degreeOfFulfillment
			//if its a Double call singleEvaluation
			//if its any other class it throw a extension exception
			//Add the results to a LogoListBuilder to return a LogoList with all the evaluation results.
			if(o instanceof FuzzySet){
				result.add(a.evaluate((FuzzySet) o));
			}else if(o instanceof Double){
				result.add(a.evaluate((Double) o));
			}else{
				throw new ExtensionException("The list can only cointain FuzzySets or Numbers");
			}
		}
		return result.toLogoList();
	}

}

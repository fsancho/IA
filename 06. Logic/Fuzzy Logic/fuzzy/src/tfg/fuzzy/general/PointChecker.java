package tfg.fuzzy.general;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.LogoList;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

public class PointChecker implements Reporter{
	
	public Syntax getSyntax(){
		return SyntaxJ.reporterSyntax(new int[]{Syntax.ListType(),Syntax.ListType()},Syntax.ListType());
	}

	@Override
	public Object report(Argument[] arg0, Context arg1)
			throws ExtensionException, LogoException {
		LogoList elementsD = arg0[0].getList();
		LogoList point;
		Double x;
		LogoList uni = arg0[1].getList();
		Double[] universe = new Double[]{(Double) uni.first(),(Double) uni.get(1)};
		List<Double> numbersToEvaluate = new ArrayList<Double>();
		//Iterate over the parameters and add to a list the first number(x) of each points
		Iterator<Object> it = elementsD.javaIterator();
		while (it.hasNext()) {
			Object o = it.next();
			point =(LogoList) o;
			x = (Double) point.first();
			double min = universe[0];
			double max = universe[1];
			//If not in the universe of the continuous set dont add it
			if(x >= min && x <= max){
				numbersToEvaluate.add((Double) point.first());
			}	
		}
		LogoListBuilder result = new LogoListBuilder();
		result.addAll(numbersToEvaluate);
		return result.toLogoList();
	}

}

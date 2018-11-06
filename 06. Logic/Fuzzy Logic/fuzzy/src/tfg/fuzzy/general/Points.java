package tfg.fuzzy.general;

import java.util.ArrayList;
import java.util.List;

import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Reporter;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.api.LogoListBuilder;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;

import tfg.fuzzy.sets.general.FuzzySet;

public class Points implements Reporter{
	
	public Syntax getSyntax(){
		return SyntaxJ.reporterSyntax(new int[]{Syntax.WildcardType(),Syntax.WildcardType()},Syntax.ListType());
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object report(Argument[] arg0, Context arg1) throws ExtensionException, LogoException {
		FuzzySet a = (FuzzySet) arg0[0].get();
		FuzzySet b = (FuzzySet) arg0[1].get();
		List<Double> l = new ArrayList<Double>();
		l = DegreeOfFulfillment.pointsToEvaluate(a.getParameters(), b.getParameters(), DegreeOfFulfillment.andInterval(a.getUniverse(), b.getUniverse()));
		LogoListBuilder log = new LogoListBuilder();
		log.addAll(l);
		return log.toLogoList();
	}

}

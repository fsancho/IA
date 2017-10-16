package tfg.fuzzy.primitives.rules;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.LogoList;

import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class is a support for all primitive rules.
 * 
 * @author Marcos Almendres.
 *
 */
public class SupportRules {

	/**
	 * Checks the format of the list given and evaluate the rule inside, only
	 * one rule.
	 * 
	 * @param l
	 *            the list with the evaluation parameters inside.
	 * @return The evaluation of the rule given.
	 */
	public static double simpleRulesChecks(LogoList l)
			throws ExtensionException, LogoException {
		double evaluationNumber;
		FuzzySet evaluationSet;
		FuzzySet evaluationOwnerSet;
		double eval = 0;
		// Take the fuzzy where the evaluation is done.
		if (l.get(1) instanceof FuzzySet) {
			evaluationOwnerSet = (FuzzySet) l.get(1);
		} else {// If not a fuzzy set throw exception
			throw new ExtensionException(
					"The second element of the list must be a fuzzy set.");
		}
		// The first element can be a number or another fuzzy set.
		// Cast and evaluate them.
		if (l.first() instanceof Double) {
			evaluationNumber = (Double) l.first();
			eval = evaluationOwnerSet.evaluate(evaluationNumber);
		} else if (l.first() instanceof FuzzySet) {
			evaluationSet = (FuzzySet) l.first();
			eval = evaluationOwnerSet.evaluate(evaluationSet);
		} else {// If wrong format throw exception
			throw new ExtensionException(
					"The first element of the list must be a number or a fuzzy set.");
		}
		return eval;
	}

	/**
	 * Checks the format of the list given and evaluate the rules inside, more
	 * than one.
	 * 
	 * @param l
	 *            the list with the evaluation parameters inside.
	 * @return The evaluation of all rules given.
	 */
	public static List<Double> variadicRulesChecks(LogoList l)
			throws ExtensionException, LogoException {
		LogoList element;
		FuzzySet evaluationSet;
		double evaluationNumber;
		FuzzySet evaluationOwnerSet;
		double eval = 0;
		List<Double> result = new ArrayList<Double>();
		// List of lists inside where each list is a rule.
		// Iterate over the rules
		Iterator<Object> it = l.javaIterator();
		while (it.hasNext()) {
			Object o = it.next();
			element = (LogoList) o;
			// The second element of each rule must be a fuzzy set.
			if (element.get(1) instanceof FuzzySet) {
				evaluationOwnerSet = (FuzzySet) element.get(1);
			} else {
				throw new ExtensionException(
						"The second element of the list must be a fuzzy set.");
			}
			// The first element of each rule must be a double or another fuzzy
			// set.
			if (element.first() instanceof Double) {
				// Cast evaluate and add the result.
				evaluationNumber = (Double) element.first();
				eval = evaluationOwnerSet.evaluate(evaluationNumber);
				result.add(eval);
			} else if (element.first() instanceof FuzzySet) {
				// Cast evaluate and add the result.
				evaluationSet = (FuzzySet) element.first();
				eval = evaluationOwnerSet.evaluate(evaluationSet);
				result.add(eval);
			} else {
				throw new ExtensionException(
						"The first element of the list must be a number or a fuzzy set.");
			}
		}
		return result;
	}

}

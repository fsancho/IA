package tfg.fuzzy.general;

import java.util.Map;
import java.util.WeakHashMap;

import org.nlogo.api.DefaultClassManager;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.PrimitiveManager;

import tfg.fuzzy.primitives.creation.*;
import tfg.fuzzy.primitives.defuzzification.*;
import tfg.fuzzy.primitives.implication.Cut;
import tfg.fuzzy.primitives.implication.Power;
import tfg.fuzzy.primitives.implication.Prod;
import tfg.fuzzy.primitives.labeling.Clear;
import tfg.fuzzy.primitives.labeling.ClearLabel;
import tfg.fuzzy.primitives.labeling.ClearLabelOfSet;
import tfg.fuzzy.primitives.labeling.HasLabel;
import tfg.fuzzy.primitives.labeling.LabelExists;
import tfg.fuzzy.primitives.labeling.LabelOfSet;
import tfg.fuzzy.primitives.operators.*;
import tfg.fuzzy.primitives.rules.CutRule;
import tfg.fuzzy.primitives.rules.MaxCutRule;
import tfg.fuzzy.primitives.rules.MaxProdRule;
import tfg.fuzzy.primitives.rules.MinCutRule;
import tfg.fuzzy.primitives.rules.MinProdRule;
import tfg.fuzzy.primitives.rules.ProdRule;
import tfg.fuzzy.sets.general.FuzzySet;

/**
 * This class is where all primitives of the extension are declared.
 * 
 * @author Marcos Almendres.
 *
 */
public class FuzzyLogic extends DefaultClassManager {

	/**
	 * A map to store the fuzzy sets with label.
	 */
	private static Map<String, FuzzySet> registry = new WeakHashMap<String, FuzzySet>();
	public static boolean errorShown = false;

	public static Map<String, FuzzySet> getRegistry() {
		return registry;
	}
	
	public static void resetRegistry(){
		registry.clear();
	}

	@Override
	public void load(PrimitiveManager primitiveManager)
			throws ExtensionException {
		// Creation of fuzzy sets
		primitiveManager.addPrimitive("evaluation", new Evaluation());
		primitiveManager.addPrimitive("discrete-numeric-set",
				new DiscreteNumeric());
		primitiveManager.addPrimitive("piecewise-linear-set",
				new PiecewiseLinear());
		primitiveManager.addPrimitive("trapezoidal-set", new Trapezoidal());
		primitiveManager.addPrimitive("logistic-set", new Logistic());
		primitiveManager.addPrimitive("gaussian-set", new Gaussian());
		primitiveManager.addPrimitive("exponential-set", new Exponential());
		primitiveManager.addPrimitive("interval-with-points-set",
				new Interval());
		primitiveManager.addPrimitive("discrete-numeric-set-with-label",
				new DiscreteNumericWithLabel());
		primitiveManager.addPrimitive("piecewise-linear-set-with-label",
				new PiecewiseLinearWithLabel());
		primitiveManager.addPrimitive("trapezoidal-set-with-label",
				new TrapezoidalWithLabel());
		primitiveManager.addPrimitive("logistic-set-with-label",
				new LogisticWithLabel());
		primitiveManager.addPrimitive("gaussian-set-with-label",
				new GaussianWithLabel());
		primitiveManager.addPrimitive("exponential-set-with-label",
				new ExponentialWithLabel());
		primitiveManager.addPrimitive("interval-with-points-set-with-label",
				new IntervalWithLabel());
		// Defuzzification
		primitiveManager.addPrimitive("FOM-of", new FOM());
		primitiveManager.addPrimitive("LOM-of", new LOM());
		primitiveManager.addPrimitive("MOM-of", new MOM());
		primitiveManager.addPrimitive("MeOM-of", new MeOM());
		primitiveManager.addPrimitive("COG-of", new COG());
		// Check results
		primitiveManager.addPrimitive("plot", new FuzzyPlot());
		primitiveManager.addPrimitive("evaluation-of", new Evaluation());
		// Operators with fuzzy sets
		primitiveManager.addPrimitive("min", new MinAnd());
		primitiveManager.addPrimitive("and", new MinAnd());
		primitiveManager.addPrimitive("max", new MaxOr());
		primitiveManager.addPrimitive("or", new MaxOr());
		primitiveManager.addPrimitive("sum", new Sum());
		primitiveManager.addPrimitive("prob-or", new ProbOr());
		primitiveManager.addPrimitive("not", new Not());
		// Implication Operators and hedges
		primitiveManager.addPrimitive("truncate", new Cut());
		primitiveManager.addPrimitive("prod", new Prod());
		primitiveManager.addPrimitive("power", new Power());
		// Rules
		primitiveManager.addPrimitive("rule", new CutRule());
		primitiveManager.addPrimitive("truncate-rule", new CutRule());
		primitiveManager.addPrimitive("prod-rule", new ProdRule());
		primitiveManager.addPrimitive("min-truncate-rule", new MinCutRule());
		primitiveManager.addPrimitive("and-rule", new MinCutRule());
		primitiveManager.addPrimitive("min-prod-rule", new MinProdRule());
		primitiveManager.addPrimitive("max-truncate-rule", new MaxCutRule());
		primitiveManager.addPrimitive("or-rule", new MaxCutRule());
		primitiveManager.addPrimitive("max-prod-rule", new MaxProdRule());
		// Additional functions(Required)
		primitiveManager.addPrimitive("set-with-label", new SetFinder());
		// Additional functions
		primitiveManager.addPrimitive("set-resolution", new Resolution());
		primitiveManager.addPrimitive("show", new Checker());
		primitiveManager.addPrimitive("checkPoint", new PointChecker());
		primitiveManager.addPrimitive("and-interval", new AndInterval());
		primitiveManager.addPrimitive("points", new Points());
		primitiveManager.addPrimitive("lower-envelope", new LowerEnvelope());
		primitiveManager.addPrimitive("degree-of-fulfillment", new Degree());
		//Labeling
		primitiveManager.addPrimitive("clear-all-labels", new Clear());
		primitiveManager.addPrimitive("clear-label", new ClearLabel());
		primitiveManager.addPrimitive("set-label-of", new SetLabel());
		primitiveManager.addPrimitive("label-exists?", new LabelExists());
		primitiveManager.addPrimitive("clear-label-of", new ClearLabelOfSet());
		primitiveManager.addPrimitive("has-label?", new HasLabel());
		primitiveManager.addPrimitive("label-of", new LabelOfSet());
	}

}

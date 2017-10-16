package tfg.fuzzy.primitives.operators;

/**
 * Interface to define the operation to perform in the discrete sets.
 * 
 * @see SupportOperators#discreteOperations(org.nlogo.api.LogoList, Command).
 * @author Marcos Almendres.
 * 
 */
public interface Command {

	/**
	 * Perform an operation with two points.
	 * 
	 * @param pointA
	 *            One point.
	 * @param pointB
	 *            The other point.
	 * @return The resulting point.
	 */
	public double[] execute(double[] pointA, double[] pointB);
}

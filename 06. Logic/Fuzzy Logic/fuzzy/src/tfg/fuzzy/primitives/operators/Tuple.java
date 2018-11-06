package tfg.fuzzy.primitives.operators;

import java.util.List;

/**
 * Wrapper class for a the return type of some methods.
 * 
 * @see SupportOperators#continuousParamsUniverse(LogoList)
 * @see SupportOperators#discreteOperations(LogoList, Command).
 * @author Marcos Almendres.
 * 
 * @param <E>
 *            This use to be Fuzzy sets parameters.
 */
public class Tuple<E> {

	private List<E> f;
	private double[] universe;

	/**
	 * Constructor of tuple.
	 * 
	 * @param f
	 *            Fuzzy sets parameters.
	 * @param universe
	 *            universe.
	 */
	public Tuple(List<E> f, double[] universe) {
		this.f = f;
		this.universe = universe;
	}

	/**
	 * Take the parameters of the tuple.
	 * 
	 * @return The parameters.
	 */
	public List<E> getParams() {
		return f;
	}

	/**
	 * Take the universe of the tuple.
	 * 
	 * @return the universe.
	 */
	public double[] getUniverse() {
		return universe;
	}

}

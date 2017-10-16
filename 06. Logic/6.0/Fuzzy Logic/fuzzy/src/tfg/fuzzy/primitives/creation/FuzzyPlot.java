package tfg.fuzzy.primitives.creation;


import org.nlogo.api.Argument;
import org.nlogo.api.Context;
import org.nlogo.api.Command;
import org.nlogo.api.ExtensionException;
import org.nlogo.api.LogoException;
import org.nlogo.core.Syntax;
import org.nlogo.core.SyntaxJ;
import org.nlogo.nvm.ExtensionContext;
import org.nlogo.plot.Plot;
import org.nlogo.plot.PlotManager;
import org.nlogo.plot.PlotPen;
import org.nlogo.workspace.AbstractWorkspaceScala;

import tfg.fuzzy.general.SupportFunctions;
import tfg.fuzzy.sets.general.FuzzySet;
import tfg.fuzzy.sets.points.DiscreteNumericSet;
import tfg.fuzzy.sets.points.PiecewiseLinearSet;

/**
 * This class performs the plot operation
 * @author Marcos Almendres.
 *
 */
public class FuzzyPlot implements Command{
	
	/**
	 * This method tells Netlogo the appropriate syntax of the primitive.
	 * Receives a wildcard and report nothing because it is a command.
	 */
	public Syntax getSyntax(){
		return SyntaxJ.commandSyntax(new int[]{Syntax.WildcardType()});
	}

	/**
	 * This method respond to the call from Netlogo and perform the plot.
	 * 
	 * @param arg0
	 *            Arguments from Netlogo call, in this case a fuzzy set.
	 * @param arg1
	 *            Context of Netlogo when the call was done.
	 */
	@Override
	public void perform(Argument[] arg0, Context arg1) throws ExtensionException, LogoException {
		FuzzySet f =(FuzzySet) arg0[0].get();
		ExtensionContext ec = (ExtensionContext) arg1;	
		AbstractWorkspaceScala gw = (AbstractWorkspaceScala) ec.workspace();
		PlotManager pm = (PlotManager) gw.plotManager();
		Plot p = pm.currentPlot().get();
		//setRanges(p, f.getUniverse());
		if(f.isContinuous()){
			if(f instanceof PiecewiseLinearSet){
				piecewisePlot(p,(PiecewiseLinearSet) f);
			}else{
				continuousPlot(p, f);
			}
		}else{
			discretePlot(p,(DiscreteNumericSet) f);
		}
		p.makeDirty();
	}
	
	/**
	 * This method set the ranges of the plot. Adjust them to the universe of the set that will be plotted.
	 * This method is never used actually but it can be useful to someone else.
	 * @param p The plot where the set is drawn.
	 * @param universe The universe of the set.
	 */
	public void setRanges(Plot p, double[] universe){
		double minRange = universe[0];
		double maxRange = universe[1];
		//Calculate X range
//		if(p.xMin() <= minRange){
//			minRange = p.xMin();
//		}
//		if(p.xMax() >= maxRange){
//			maxRange = p.xMax();
//		}
		if(minRange == maxRange){
			p.defaultXMin_$eq(0);
			p.defaultXMax_$eq(2*minRange);
		}else{
			p.defaultXMin_$eq(minRange);
			p.defaultXMax_$eq(maxRange);
		}
		//set y range	
		p.defaultYMin_$eq(0);
		p.defaultYMax_$eq(1);
	}
	
	/**
	 * This method plots the piecewise linear sets.
	 * @param p The plot where the set is drawn.
	 * @param f The piecewise linear set.
	 */
	public void piecewisePlot(Plot p, PiecewiseLinearSet f){
		//Take the current pen
		PlotPen pp = p.currentPen().get();
		pp.mode_$eq(0);
		//Plot pen up
		pp.isDown_$eq(false);
		//Iterate over the parameters
		double previousX = Double.NaN;
		double x = Double.NaN;
		for(double[] point : f.getParameters()){
			x = point[0];
			if(x == previousX){
				pp.isDown_$eq(false);
			}
			//move to (x,y)
			pp.plot(x, point[1]);
			//plot pen down
			pp.isDown_$eq(true);
			previousX = x;
		}
		pp.isDown_$eq(false);
	}
	
	/**
	 * This method plots the continuous sets.
	 * @param p The plot where the set is drawn.
	 * @param f The continuous set.
	 */
	public void continuousPlot(Plot p, FuzzySet f){
		double[] universe = f.getUniverse();
		//Take the current pen
		PlotPen pp = p.currentPen().get();
		//Make sure it is in mode 2
		if(pp.mode() != 2){
			pp.mode_$eq(2);
		}
		/*
		//Create, configure and add a new Pen if its not in mode 2
		if(pp.mode() != 2){
			int color = p.currentPen().get().color();
			pp = p.createPlotPen("one", true);
			pp.color_$eq(color);
			pp.mode_$eq(2);
		}
		*/
		//Steps to iterate
		double steps = Math.floor(1 + ((universe[1] - universe[0]) * SupportFunctions.getResolution()));
		double x = universe[0];
		//plot pen up
		pp.isDown_$eq(false);
		for(int i = 0 ; i < steps ; i++){
			//plot(x,y)
			pp.plot(x, f.evaluate(x));
			//plot pen down
			pp.isDown_$eq(true);
			//increment x
			x += 1/SupportFunctions.getResolution();
		}
		pp.isDown_$eq(false);
	}
	
	/**
	 * This method plots the discrete sets.
	 * @param p The plot where the set is drawn.
	 * @param f The discrete set.
	 */
	public void discretePlot(Plot p, DiscreteNumericSet f){
		//Take the current pen
		PlotPen pp = p.currentPen().get();
		pp.mode_$eq(0);
		//Iterate over the parameters
		double x = 0;
		for(double[] point: f.getParameters()){
			pp.isDown_$eq(false);
			x = point[0];
			//Plot pen up
			//Move to the point(x,0)
			pp.plot(x, 0);
			//Plot pen down
			pp.isDown_$eq(true);
			//Move to the point(x,y)
			pp.plot(x,point[1]);
		}
		pp.isDown_$eq(false);
	}
}

/**
 * User: booster
 * Date: 11/12/14
 * Time: 12:00
 */
package stork.game {

public class DelegateActionNode extends GameActionNode {
    private var _onActionUpdatedFunction:Function;  // function(dt:Number):void

    private var _onActionStartedFunction:Function;  // function():void
    private var _onStepStartedFunction:Function;    // function():void
    private var _onStepFinishedFunction:Function;   // function():void
    private var _onActionFinishedFunction:Function; // function():void
    private var _onActionCanceledFunction:Function; // function():void

    public function DelegateActionNode(priority:int = int.MAX_VALUE, name:String = "DelegateAction", onActionUpdatedFunction:Function = null) {
        super(priority, name);

        _onActionUpdatedFunction = onActionUpdatedFunction;
    }

    public function get onActionUpdatedFunction():Function { return _onActionUpdatedFunction; }
    public function set onActionUpdatedFunction(value:Function):void { _onActionUpdatedFunction = value; }

    public function get onActionStartedFunction():Function { return _onActionStartedFunction; }
    public function set onActionStartedFunction(value:Function):void { _onActionStartedFunction = value; }

    public function get onStepStartedFunction():Function { return _onStepStartedFunction; }
    public function set onStepStartedFunction(value:Function):void { _onStepStartedFunction = value; }

    public function get onStepFinishedFunction():Function { return _onStepFinishedFunction; }
    public function set onStepFinishedFunction(value:Function):void { _onStepFinishedFunction = value; }

    public function get onActionFinishedFunction():Function { return _onActionFinishedFunction; }
    public function set onActionFinishedFunction(value:Function):void { _onActionFinishedFunction = value; }

    public function get onActionCanceledFunction():Function { return _onActionCanceledFunction; }
    public function set onActionCanceledFunction(value:Function):void { _onActionCanceledFunction = value; }

    override protected function actionStarted():void {
        if(_onActionStartedFunction != null)
            _onActionStartedFunction();
    }

    override protected function stepStarted():void {
        if(_onStepStartedFunction != null)
            _onStepStartedFunction();
    }

    override protected function actionUpdated(dt:Number):void {
        if(_onActionUpdatedFunction != null)
            _onActionUpdatedFunction(dt);
    }

    override protected function stepFinished():void {
        if(_onStepFinishedFunction != null)
            _onStepFinishedFunction();
    }

    override protected function actionFinished():void {
        if(_onActionFinishedFunction != null)
            _onActionFinishedFunction();
    }

    override protected function actionCanceled():void {
        if(_onActionCanceledFunction != null)
            _onActionCanceledFunction();
    }
}
}

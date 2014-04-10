/**
 * User: booster
 * Date: 05/03/14
 * Time: 13:54
 */
package stork.game {
import stork.core.Node;
import stork.event.game.GameActionEvent;

public class GameActionNode extends Node {
    private var _stepFinishedDt:Number  = 0;
    private var _actionFinished:Boolean = false;
    private var _actionCanceled:Boolean = false;
    private var _autoReset:Boolean      = true;

    private var _totalTime:Number       = 0;
    private var _stepTime:Number        = 0;
    private var _currentStep:int        = 0;

    protected var _startedEvent:GameActionEvent     = new GameActionEvent(GameActionEvent.STARTED);
    protected var _stepEvent:GameActionEvent        = new GameActionEvent(GameActionEvent.STEP);
    protected var _finishedEvent:GameActionEvent    = new GameActionEvent(GameActionEvent.FINISHED);
    protected var _canceledEvent:GameActionEvent    = new GameActionEvent(GameActionEvent.CANCELED);

    public function GameActionNode(name:String = "GameActionNode") {
        super(name);
    }

    // abstract methods

    protected function actionStarted():void { }
    protected function stepStarted():void { }
    protected function actionUpdated(dt:Number):void { throw new Error("abstract method call"); }
    protected function stepFinished():void {}
    protected function actionFinished():void { }
    protected function actionCanceled():void { }

    // implemented methods

    public function get autoReset():Boolean { return _autoReset; }
    public function set autoReset(value:Boolean):void { _autoReset = value; }

    public function get totalTime():Number { return _totalTime; }
    public function get stepTime():Number { return _stepTime; }
    public function get currentStep():int { return _currentStep; }

    public function get finished():Boolean { return _actionFinished; }
    public function get canceled():Boolean { return _actionCanceled; }

    public function advance(dt:Number):void {
        if(_actionFinished || _actionCanceled)
            return;

        if(dt == 0)
            return;

        if(_totalTime == 0) {
            actionStarted();

            dispatchStartedEvent();
        }

        while(true) {
            if(_stepTime == 0)
                stepStarted();

            actionUpdated(dt);

            // finishAction() called
            if(_actionFinished) {
                stepFinished();
                actionFinished();

                _totalTime += dt;
                _stepTime += dt;

                dispatchFinishedEvent(); // don't dispatch step event

                break;
            }

            // cancelAction() called
            else if(_actionCanceled) {
                actionCanceled();

                _totalTime += dt;
                _stepTime += dt;

                dispatchCanceledEvent();

                break;
            }

            // finishStep() called
            else if(_stepFinishedDt > 0) {
                stepFinished();

                if(_stepFinishedDt < dt) {
                    dt -= _stepFinishedDt;
                }
                else {
                    _stepFinishedDt = dt;
                    dt = 0;
                }

                ++_currentStep;

                _totalTime     += _stepFinishedDt;
                _stepTime      += _stepFinishedDt;
                _stepFinishedDt = 0;

                dispatchStepEvent();

                // start next step
                _stepTime = 0;
            }

            // nothing called, current step will continue on next advance() call
            else {
                _totalTime += dt;
                _stepTime += dt;

                break;
            }
        }

        if(_autoReset && (_actionCanceled || _actionFinished))
            reset();
    }

    public function reset():void {
        _stepFinishedDt = 0;
        _actionFinished = false;
        _actionCanceled = false;

        _totalTime      = 0;
        _stepTime       = 0;
        _currentStep    = 0;

        removeEventListeners();
        removeFromParent();
    }

    protected function finishStep(dt:Number):void { _stepFinishedDt = dt; }
    protected function finishAction():void { _actionFinished = true; }
    protected function cancelAction():void { _actionCanceled = true; }

    protected function dispatchStartedEvent():void { dispatchEvent(_startedEvent.reset()); }
    protected function dispatchStepEvent():void { dispatchEvent(_stepEvent.reset()); }
    protected function dispatchFinishedEvent():void { dispatchEvent(_finishedEvent.reset()); }
    protected function dispatchCanceledEvent():void { dispatchEvent(_canceledEvent.reset()); }
}
}

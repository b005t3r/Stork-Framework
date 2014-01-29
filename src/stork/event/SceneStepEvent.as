/**
 * User: booster
 * Date: 29/01/14
 * Time: 10:00
 */
package stork.event {
import stork.core.stork_internal;

public class SceneStepEvent extends SceneEvent {
    public static const STEP:String = "step";

    private var _dt:Number;

    public function SceneStepEvent() {
        super(type);
    }

    public function get dt():Number { return _dt; }

    stork_internal function resetDt(dt:Number):SceneStepEvent {
        _dt = dt;

        return reset() as SceneStepEvent;
    }
}
}

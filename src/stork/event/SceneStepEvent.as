/**
 * User: booster
 * Date: 29/01/14
 * Time: 10:00
 */
package stork.event {
import stork.core.SceneNode;
import stork.core.stork_internal;

public class SceneStepEvent extends Event {
    public static const STEP:String = "step";

    private var _dt:Number;

    public function SceneStepEvent() {
        super(type, false);
    }

    public function get dt():Number { return _dt; }
    public function get sceneNode():SceneNode { return target as SceneNode; }

    stork_internal function resetDt(dt:Number):SceneStepEvent {
        _dt = dt;

        return reset() as SceneStepEvent;
    }
}
}

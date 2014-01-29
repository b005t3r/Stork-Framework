/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:13
 */
package stork.core {
import stork.event.SceneStepEvent;

public class SceneNode extends ContainerNode{
    private var _stepEvent:SceneStepEvent = new SceneStepEvent();

    public function SceneNode(name:String = "SceneNode") {
        super(name);
    }

    public function step(dt:Number):void {
        dispatchEvent(_stepEvent.stork_internal::resetDt(dt));
    }
}
}

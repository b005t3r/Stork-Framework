/**
 * User: booster
 * Date: 29/01/14
 * Time: 11:58
 */
package stork.event {
import stork.core.SceneNode;

public class SceneEvent extends Event {
    public static const SCENE_STARTED:String = "sceneStarted";

    public function SceneEvent(type:String) {
        super(type, false);
    }

    public function get sceneNode():SceneNode { return target as SceneNode; }
}
}

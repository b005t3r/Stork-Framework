/**
 * User: booster
 * Date: 29/01/14
 * Time: 15:58
 */
package stork.event {
public class SceneObjectEvent extends SceneEvent {
    public static const OBJECT_ADDED_TO_SCENE:String        = "objectAddedToSceneNode";
    public static const OBJECT_REMOVED_FROM_SCENE:String    = "objectRemovedFromSceneNode";

    private var _object:Object  = null;
    private var _name:Object    = null;

    public function SceneObjectEvent(type:String) {
        super(type);
    }

    public function get object():Object { return _object; }

    public function resetObject(object:Object, name:String):SceneObjectEvent {
        _object = object;
        _name   = name;

        return reset() as SceneObjectEvent;
    }
}
}

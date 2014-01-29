/**
 * User: booster
 * Date: 29/01/14
 * Time: 11:00
 */
package stork.core.plugin {
import flash.utils.getQualifiedClassName;

import stork.core.SceneNode;
import stork.core.stork_internal;
import stork.event.plugin.ScenePluginEvent;

public class ScenePlugin {
    private var _name:String;
    private var _sceneNode:SceneNode;

    public function ScenePlugin(name:String) {
        _name = name;
    }

    public function get name():String { return _name; }
    public function get sceneNode():SceneNode { return _sceneNode; }

    public function canBeActivated(sceneNode:SceneNode):Boolean { return true; }

    public function activate():void {
        // do nothing
    }

    public function deactivate():void {
        // do nothing
    }

    public function toString():String { return "[" + getQualifiedClassName(this).split("::").pop() + " name=\"" + _name + "]"; }

    stork_internal function setSceneNode(sceneNode:SceneNode):void { _sceneNode = sceneNode; }

    protected function fireActivatedEvent():void { sceneNode.dispatchEvent(new ScenePluginEvent(ScenePluginEvent.PLUGIN_ACTIVATED, this)); }
    protected function fireDeactivatedEvent():void { sceneNode.dispatchEvent(new ScenePluginEvent(ScenePluginEvent.PLUGIN_DEACTIVATED, this)); }
}
}

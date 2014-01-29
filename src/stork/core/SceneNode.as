/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:13
 */
package stork.core {
import flash.errors.IllegalOperationError;

import stork.core.plugin.ScenePlugin;
import stork.event.SceneEvent;
import stork.event.SceneStepEvent;
import stork.event.plugin.ScenePluginEvent;

use namespace stork_internal;

public class SceneNode extends ContainerNode{
    private var _stepEvent:SceneStepEvent = new SceneStepEvent();

    private var _registeredPlugins:Vector.<ScenePlugin> = new <ScenePlugin>[];
    private var _activePlugins:Vector.<ScenePlugin> = new <ScenePlugin>[];

    private var _started:Boolean;

    private var _activatingPlugins:Boolean;

    public function SceneNode(name:String = "SceneNode") {
        super(name);
    }

    public function get started():Boolean { return _started; }

    public function step(dt:Number):void {
        if(! _started) return;

        dispatchEvent(_stepEvent.stork_internal::resetDt(dt));
    }

    public function _registerPlugin(plugin:ScenePlugin):void {
        if(_started)
            throw new IllegalOperationError("new plugins can be registered only before calling start()");

        if(_registeredPlugins.indexOf(plugin) >= 0)
            return;

        _registeredPlugins[_registeredPlugins.length] = plugin;
    }

    public function _unregisterPlugin(plugin:ScenePlugin):void {
        if(_started)
            throw new IllegalOperationError("plugins can be unregistered only before calling start()");

        var index:int = _registeredPlugins.indexOf(plugin);

        if(index < 0) return;

        _registeredPlugins.splice(index, 1);
    }

    public function start():void {
        if(_started)
            throw new IllegalOperationError("this scene is already started");

        addEventListener(ScenePluginEvent.PLUGIN_ACTIVATED, onPluginActivated);
        //addEventListener(ScenePluginEvent.PLUGIN_DEACTIVATED, onPluginDeactivated);

        activatePlugins();
    }

    private function activatePlugins():void {
        if(_activatingPlugins)
            return;

        _activatingPlugins = true;

        var count:int = _registeredPlugins.length;
        for(var i:int = 0; i < count; i++) {
            var plugin:ScenePlugin = _registeredPlugins[i];
            var activatedIndex:int = _activePlugins.indexOf(plugin);

            if(activatedIndex >= 0 || ! plugin.canBeActivated(this))
                continue;

            plugin.setSceneNode(this);
            plugin.activate();
        }

        if(_registeredPlugins.length == _activePlugins.length)
            startScene();

        _activatingPlugins = false;
    }

    private function startScene():void {
        _started = true;

        dispatchEvent(new SceneEvent(SceneEvent.SCENE_STARTED));
    }

    private function onPluginActivated(event:ScenePluginEvent):void {
        if(_activePlugins.indexOf(event.plugin) >= 0)
            throw new IllegalOperationError("plugin already active: " + event.plugin);

        _activePlugins[_activePlugins.length] = event.plugin;

        if(_registeredPlugins.length == _activePlugins.length)
            startScene();
        else
            activatePlugins();
    }

// TODO: not tested, not sure if even necessary
//    private function onPluginDeactivated(event:ScenePluginEvent):void {
//        var index:int = _activePlugins.indexOf(event.plugin);
//
//        if(index < 0)
//            throw new IllegalOperationError("plugin not active: " + event.plugin);
//
//        _activePlugins.splice(index, 1);
//    }
}
}

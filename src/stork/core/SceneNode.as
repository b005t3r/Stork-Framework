/**
 * User: booster
 * Date: 24/01/14
 * Time: 9:13
 */
package stork.core {
import flash.errors.IllegalOperationError;

import stork.core.plugin.ScenePlugin;
import stork.core.reference.GlobalReference;
import stork.core.reference.LocalReference;
import stork.core.reference.ReferenceUtil;
import stork.core.stork_internal;
import stork.event.SceneEvent;
import stork.event.SceneObjectEvent;
import stork.event.SceneStepEvent;
import stork.event.plugin.ScenePluginEvent;

use namespace stork_internal;

public class SceneNode extends ContainerNode {
    private var _stepEvent:SceneStepEvent               = new SceneStepEvent(SceneStepEvent.STEP);
    private var _objectAddedEvent:SceneObjectEvent      = new SceneObjectEvent(SceneObjectEvent.OBJECT_ADDED_TO_SCENE);
    private var _objectRemovedEvent:SceneObjectEvent    = new SceneObjectEvent(SceneObjectEvent.OBJECT_REMOVED_FROM_SCENE);

    private var _objects:Vector.<ObjectHolder>          = new <ObjectHolder>[];

    private var _registeredPlugins:Vector.<ScenePlugin> = new <ScenePlugin>[];
    private var _activePlugins:Vector.<ScenePlugin>     = new <ScenePlugin>[];

    private var _started:Boolean                        = false;
    private var _activatingPlugins:Boolean              = false;

    public function SceneNode(name:String = "SceneNode") {
        super(name);
    }

    public function get started():Boolean { return _started; }

    public function get objectCount():int { return _objects.length; }

    public function addObject(object:Object, name:String = null):void {
        addObjectAt(object, objectCount, name);
    }

    public function addObjectAt(object:Object, index:int, name:String = null):void {
        var count:int = _objects.length;

        if(index >= 0 && index <= count) {
            // 'splice' creates a temporary object, so we avoid it if it's not necessary
            if(index == count)  _objects[count] = new ObjectHolder(object, name);
            else                _objects.splice(index, 0, new ObjectHolder(object, name));

            dispatchEvent(_objectAddedEvent.resetObject(object, name));
        }
        else {
            throw new RangeError("invalid object index");
        }
    }

    public function removeObject(object:Object):void {
        var objectIndex:int = getObjectIndex(object);

        if (objectIndex != -1)
            removeObjectAt(objectIndex);
    }

    public function removeObjectAt(index:int):void {
        if(index >= 0 && index < objectCount) {
            var holder:ObjectHolder = _objects[index];

            dispatchEvent(_objectRemovedEvent.resetObject(holder.object, holder.name));

            index = _objects.indexOf(holder); // index might have changed by event handler

            if(index >= 0)
                _objects.splice(index, 1);
        }
        else {
            throw new RangeError("invalid object index");
        }
    }

    public function removeObjects(beginIndex:int = 0, endIndex:int = -1):void {
        if(endIndex < 0 || endIndex >= objectCount)
            endIndex = objectCount - 1;

        for(var i:int = beginIndex; i <= endIndex; ++i)
            removeObjectAt(beginIndex);
    }

    public function getObjectIndex(object:Object):int {
        var count:int = object.length;
        for(var i:int = 0; i < count; i++) {
            var holder:ObjectHolder = object[i];

            if(object == holder.object)
                return i;
        }

        return -1;
    }

    public function setObjectIndex(object:Object, index:int):void {
        var oldIndex:int = getObjectIndex(object);

        if (oldIndex == index) return;
        if (oldIndex == -1) throw new ArgumentError("object not added to scene");

        var holder:ObjectHolder = _objects[oldIndex];

        _objects.splice(oldIndex, 1);
        _objects.splice(index, 0, holder);
    }

    public function swapObjects(objA:Object, objB:Object):void {
        var indexA:int = getObjectIndex(objA);
        var indexB:int = getObjectIndex(objB);

        if (indexA == -1 || indexB == -1) throw new ArgumentError("object(s) not added to scene");

        swapObjectsAt(indexA, indexB);
    }

    public function swapObjectsAt(indexA:int, indexB:int):void {
        var child1:ObjectHolder = _objects[indexA];
        var child2:ObjectHolder = _objects[indexB];

        _objects[indexA] = child2;
        _objects[indexB] = child1;
    }

    public function getObjectAt(index:int):Object { return _objects[index].object; }

    public function getObjectByName(name:String):Object {
        var count:int = _objects.length;
        for(var i:int = 0; i < count; ++i)
            if(_objects[i].name == name)
                return _objects[i].object;

        return null;
    }

    public function getObjectByClass(objectClass:Class):Object {
        var count:int = _objects.length;
        for(var i:int = 0; i < count; ++i)
            if(_objects[i].object is objectClass)
                return _objects[i].object;

        return null;
    }

    public function getObjectsByClass(objectClass:Class, objects:Vector.<Object> = null):Vector.<Object> {
        if(objects == null) objects = new <Object>[];

        var count:int = _objects.length;
        for(var i:int = 0; i < count; ++i)
            if(_objects[i].object is objectClass)
                objects[objects.length] = _objects[i];

        return objects;
    }

    public function registerPlugin(plugin:ScenePlugin):void {
        if(_started)
            throw new IllegalOperationError("new plugins can be registered only before calling start()");

        if(_registeredPlugins.indexOf(plugin) >= 0)
            return;

        _registeredPlugins[_registeredPlugins.length] = plugin;
    }

    public function unregisterPlugin(plugin:ScenePlugin):void {
        if(_started)
            throw new IllegalOperationError("plugins can be unregistered only before calling start()");

        var index:int = _registeredPlugins.indexOf(plugin);

        if(index < 0) return;

        _registeredPlugins.splice(index, 1);
    }

    public function get pluginCount():int { return _activePlugins.length; }

    public function getPluginIndex(plugin:ScenePlugin):int { return _activePlugins.indexOf(plugin); }

    public function getPluginAt(index:int):ScenePlugin { return _activePlugins[index]; }

    public function getPluginByName(name:String):ScenePlugin {
        var count:int = _activePlugins.length;
        for(var i:int = 0; i < count; ++i)
            if(_activePlugins[i].name == name)
                return _activePlugins[i];

        return null;
    }

    public function getPluginByClass(pluginClass:Class):ScenePlugin {
        var count:int = _activePlugins.length;
        for(var i:int = 0; i < count; ++i)
            if(_activePlugins[i] is pluginClass)
                return _activePlugins[i];

        return null;
    }

    public function start():void {
        if(_started)
            throw new IllegalOperationError("this scene is already started");

        addEventListener(ScenePluginEvent.PLUGIN_ACTIVATED, onPluginActivated);
        // TODO: not sure if necessary
        //addEventListener(ScenePluginEvent.PLUGIN_DEACTIVATED, onPluginDeactivated);

        activatePlugins();
    }

    stork_internal function step(dt:Number):void {
        if(! _started) return;

        dispatchEvent(_stepEvent.stork_internal::resetDt(dt));
    }

    private function activatePlugins():void {
        if(_activatingPlugins)
            return;

        var activeCount:int     = _activePlugins.length;
        var activatedCount:int  = 0;

        _activatingPlugins = true;

        var count:int = _registeredPlugins.length;
        for(var i:int = 0; i < count; i++) {
            var plugin:ScenePlugin = _registeredPlugins[i];
            var activatedIndex:int = _activePlugins.indexOf(plugin);

            if(activatedIndex >= 0 || ! plugin.canBeActivated(this))
                continue;

            ++activatedCount;

            plugin.setSceneNode(this);
            plugin.activate();
        }

        _activatingPlugins = false;

        // all plugins active, start
        if(_registeredPlugins.length == _activePlugins.length)
            startScene();
        // all plugins activated on this call are already active, try activating the rest
        else if(_activePlugins.length == activeCount + activatedCount)
            activatePlugins();
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

class ObjectHolder {
    public var object:Object;
    public var name:String;

    public function ObjectHolder(object:Object, name:String) {
        this.object = object;
        this.name = name;
    }
}

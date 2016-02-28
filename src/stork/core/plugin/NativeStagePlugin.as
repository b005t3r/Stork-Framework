/**
 * User: booster
 * Date: 26/02/16
 * Time: 15:38
 */
package stork.core.plugin {
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.utils.getTimer;

import stork.core.stork_internal;

use namespace stork_internal;

public class NativeStagePlugin extends ScenePlugin {
    public static const PLUGIN_NAME:String = "Stork-Plugin-NativeStage";

    private var _main:Sprite;
    private var _prevTime:int = -1;

    public function NativeStagePlugin(main:Sprite) {
        super(PLUGIN_NAME);

        _main = main;
    }

    override public function activate():void {
        if(_main == null)
            throw new UninitializedError("main Sprite not set");

        if (_main.stage)
            init();
        else
            _main.addEventListener(Event.ADDED_TO_STAGE, init);
    }

    // TODO: this is probably not the best implementation in the world, but it's currently only used by unit tests
    override public function deactivate():void {
        _main.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function init(event:Event = null):void {
        _main.removeEventListener(Event.ADDED_TO_STAGE, init);

        _main.stage.scaleMode  = StageScaleMode.NO_SCALE;
        _main.stage.align      = StageAlign.TOP_LEFT;

/*
        NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, onActivate);
        NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, onDeactivate);
*/

        _main.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        fireActivatedEvent();
    }

    private function onEnterFrame(event:Event):void {
        if(sceneNode == null) return;

        if(_prevTime == -1) {
            _prevTime = getTimer();
        }
        else {
            var currTime:int    = getTimer();
            var dt:Number       = (currTime - _prevTime) / 1000.0;

            sceneNode.stork_internal::step(dt);

            _prevTime = currTime;
        }
    }
/*
    private function onActivate(event:flash.events.Event):void { _starling.start(); }
    private function onDeactivate(event:flash.events.Event):void { _starling.stop(true); }
*/
}
}
/**
 * User: booster
 * Date: 29/01/14
 * Time: 12:12
 */
package stork.core {
import org.flexunit.asserts.assertEquals;

import stork.core.plugin.ScenePlugin;
import stork.event.SceneEvent;

public class SceneNodeTest {
    private var scene:SceneNode;

    [Before]
    public function setUp():void {
        scene = new SceneNode();
    }

    [After]
    public function tearDown():void {
        scene = null;
    }

    [Test]
    public function testSimpleStart():void {
        var started:Boolean = false;

        scene.addEventListener(SceneEvent.SCENE_STARTED, function(e:SceneEvent):void {
            assertEquals(scene, e.sceneNode);

            started = e.sceneNode.started;
        });

        scene.start();

        assertEquals(scene.started, true);
        assertEquals(started, true);
    }

    [Test]
    public function testSynchronousPluginActivation():void {
        var started:Boolean = false;

        scene.addEventListener(SceneEvent.SCENE_STARTED, function(e:SceneEvent):void {
            assertEquals(scene, e.sceneNode);

            started = e.sceneNode.started;
        });

        var firstPlugin:ScenePlugin = new SynchronousPlugin();
        var secondPlugin:ScenePlugin = new DependentSynchronousPlugin();

        scene.registerPlugin(secondPlugin);
        scene.registerPlugin(firstPlugin);

        scene.start();

        assertEquals(scene.started, true);
        assertEquals(started, true);

        // both plugins had to be activated and added in this order
        assertEquals(scene.getPluginIndex(firstPlugin), 0);
        assertEquals(scene.getPluginIndex(secondPlugin), 1);
    }
}
}

import stork.core.SceneNode;
import stork.core.plugin.ScenePlugin;

class SynchronousPlugin extends ScenePlugin {
    public function SynchronousPlugin() {
        super("First");
    }

    override public function activate():void {
        fireActivatedEvent();
    }
}

class DependentSynchronousPlugin extends ScenePlugin {
    public function DependentSynchronousPlugin() {
        super("Second");
    }

    override public function canBeActivated(sceneNode:SceneNode):Boolean {
        var plugin:ScenePlugin = sceneNode.getPluginByClass(SynchronousPlugin);

        return plugin != null;
    }

    override public function activate():void {
        fireActivatedEvent();
    }
}

/**
 * User: booster
 * Date: 06/01/15
 * Time: 11:02
 */
package stork.core.reference {
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

import stork.core.SceneNode;

public class ReferenceHandlerTest {
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
    public function simpleReferenceHandlerTest():void {
        var nodeA:NodeA = new NodeA();
        var nodeB:NodeB = new NodeB();
        var nodeC:NodeC = new NodeC();

        scene.addNode(nodeA);
        scene.addNode(nodeB);
        scene.addNode(nodeC);

        assertTrue(nodeA.initialized);
        assertTrue(nodeB.initialized);
        assertFalse(nodeC.initialized);

        nodeB.removeFromParent();

        assertFalse(nodeA.initialized);
        assertFalse(nodeB.initialized);
        assertFalse(nodeC.initialized);

        scene.addNode(nodeB);

        assertTrue(nodeA.initialized);
        assertTrue(nodeB.initialized);
        assertFalse(nodeC.initialized);
    }
}
}

import stork.core.Node;

class NodeA extends Node {
    [LocalReference("NodeB")]
    public var nodeB:NodeB;

    [LocalReference("NodeC")]
    public var nodeC:NodeC;

    public var initialized:Boolean;

    [OnReferenceChanged("nodeB, nodeC")]
    public function referenceHandler(allSet:Boolean):void {
        initialized = allSet;
    }

    public function NodeA() { super("NodeA"); }
}

class NodeB extends Node {
    [LocalReference("NodeA")]
    public var nodeA:NodeA;

    [LocalReference("NodeC")]
    public var nodeC:NodeC;

    public var initialized:Boolean;

    [OnReferenceChanged("nodeA, nodeC")]
    public function referenceHandler(allSet:Boolean):void {
        initialized = allSet;
    }

    public function NodeB() { super("NodeB"); }
}

class NodeC extends Node {
    [LocalReference("NodeA")]
    public var nodeA:NodeA;

    [LocalReference("NeverSet")]
    public var nodeB:NodeB;

    public var initialized:Boolean;

    [OnReferenceChanged("nodeA, nodeB")]
    public function referenceHandler(allSet:Boolean):void {
        initialized = allSet;
    }

    public function NodeC() { super("NodeC"); }
}

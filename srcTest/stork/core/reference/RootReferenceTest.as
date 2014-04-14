/**
 * User: booster
 * Date: 03/04/14
 * Time: 8:54
 */
package stork.core.reference {
import org.flexunit.asserts.assertEquals;

import stork.core.ContainerNode;

import stork.core.SceneNode;
import stork.core.reference.test.PublicReferencedNode;

public class RootReferenceTest {
    private var scene:SceneNode;
    private var rootOne:ContainerNode;
    private var rootTwo:ContainerNode;

    [Before]
    public function setUp():void {
        scene = new SceneNode();
        rootOne = new RootContainerNode();
        rootTwo = new RootContainerNode();

        scene.addNode(rootOne);
        scene.addNode(rootTwo);
    }

    [After]
    public function tearDown():void {
        scene = null;
    }

    [Test]
    public function globalReferenceTest():void {
        var referencingOne:SimpleGlobalReferencingNode = new SimpleGlobalReferencingNode();
        var referencedOne:ReferencedNode = new ReferencedNode("mySibling");
        var publicReferencedOne:PublicReferencedNode = new PublicReferencedNode();

        var referencingTwo:SimpleGlobalReferencingNode = new SimpleGlobalReferencingNode();
        var referencedTwo:ReferencedNode = new ReferencedNode("mySibling");
        var publicReferencedTwo:PublicReferencedNode = new PublicReferencedNode();

        assertEquals(referencingOne.refName, null);
        assertEquals(referencingOne.refClass, null);
        assertEquals(referencingTwo.refName, null);
        assertEquals(referencingTwo.refClass, null);

        rootOne.addNode(referencingOne);
        rootTwo.addNode(referencingTwo);

        assertEquals(referencingOne.refName, null);
        assertEquals(referencingOne.refClass, null);
        assertEquals(referencingTwo.refName, null);
        assertEquals(referencingTwo.refClass, null);

        rootOne.addNode(referencedOne);
        rootTwo.addNode(referencedTwo);

        assertEquals(referencingOne.refName, referencedOne);
        assertEquals(referencingOne.refClass, null);
        assertEquals(referencingTwo.refName, referencedTwo);
        assertEquals(referencingTwo.refClass, null);

        referencedOne.removeFromParent();
        referencedTwo.removeFromParent();

        assertEquals(referencingOne.refName, null);
        assertEquals(referencingOne.refClass, null);
        assertEquals(referencingTwo.refName, null);
        assertEquals(referencingTwo.refClass, null);

        rootOne.addNode(referencedOne);
        rootTwo.addNode(referencedTwo);

        assertEquals(referencingOne.refName, referencedOne);
        assertEquals(referencingOne.refClass, null);
        assertEquals(referencingTwo.refName, referencedTwo);
        assertEquals(referencingTwo.refClass, null);

        referencingOne.removeFromParent();
        referencingTwo.removeFromParent();

        assertEquals(referencingOne.refName, null);
        assertEquals(referencingOne.refClass, null);
        assertEquals(referencingTwo.refName, null);
        assertEquals(referencingTwo.refClass, null);

        rootOne.addNode(publicReferencedOne);
        rootOne.addNode(referencingOne);
        rootTwo.addNode(publicReferencedTwo);
        rootTwo.addNode(referencingTwo);

        assertEquals(referencingOne.refName, referencedOne);
        assertEquals(referencingOne.refClass, publicReferencedOne);
        assertEquals(referencingTwo.refName, referencedTwo);
        assertEquals(referencingTwo.refClass, publicReferencedTwo);

        publicReferencedOne.removeFromParent();
        publicReferencedTwo.removeFromParent();

        assertEquals(referencingOne.refName, referencedOne);
        assertEquals(referencingOne.refClass, null);
        assertEquals(referencingTwo.refName, referencedTwo);
        assertEquals(referencingTwo.refClass, null);

        rootOne.addNode(publicReferencedOne);
        referencedOne.removeFromParent();
        rootTwo.addNode(publicReferencedTwo);
        referencedTwo.removeFromParent();

        assertEquals(referencingOne.refName, null);
        assertEquals(referencingOne.refClass, publicReferencedOne);
        assertEquals(referencingTwo.refName, null);
        assertEquals(referencingTwo.refClass, publicReferencedTwo);
    }
}
}

import stork.core.ContainerNode;
import stork.core.Node;
import stork.core.reference.test.PublicReferencedNode;

class SimpleGlobalReferencingNode extends Node {
    private var _refName:ReferencedNode;

    [GlobalReference("RootContainer://@PublicReferencedNode")]
    public var refClass:PublicReferencedNode;

    [GlobalReference("RootContainer://mySibling")]
    public function get refName():ReferencedNode { return _refName; }
    public function set refName(value:ReferencedNode):void { _refName = value; }
}

class ReferencedNode extends Node {
    public function ReferencedNode(name:String) {
        super(name);
    }
}

class RootContainerNode extends ContainerNode {
    public function RootContainerNode(name:String = "RootContainer") {
        super(name);
    }
}

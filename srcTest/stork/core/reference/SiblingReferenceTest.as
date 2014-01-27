/**
 * User: booster
 * Date: 27/01/14
 * Time: 14:39
 */
package stork.core.reference {
import org.flexunit.asserts.assertEquals;

import stork.core.SceneNode;

public class SiblingReferenceTest {
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
    public function addSiblingReferenceTest():void {
        var referencing:ReferencingByNameNode = new ReferencingByNameNode();
        var referenced:ReferencedNode = new ReferencedNode("mySibling");

        assertEquals(referencing.refName, null);

        scene.addNode(referencing);

        assertEquals(referencing.refName, null);

        scene.addNode(referenced);

        assertEquals(referencing.refName, referenced);

        referenced.removeFromParent();

        assertEquals(referencing.refName, null);

        scene.addNode(referenced);

        assertEquals(referencing.refName, referenced);

        referencing.removeFromParent();

        assertEquals(referencing.refName, null);
    }
}
}

import stork.core.Node;

class ReferencingByNameNode extends Node {
    [LocalReference("mySibling")]
    public var refName:ReferencedNode;

    [LocalReference("@OtherReferencedNode")]
    private var _refClass:ReferencedNode;

    public function get refClass():ReferencedNode { return _refClass; }
    public function set refClass(value:ReferencedNode):void { _refClass = value; }
}

class ReferencedNode extends Node {
    public function ReferencedNode(name:String) {
        super(name);
    }
}

class OtherReferencedNode extends Node {
}

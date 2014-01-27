/**
 * User: booster
 * Date: 27/01/14
 * Time: 9:24
 */
package stork.core {
import org.flexunit.asserts.assertEquals;

public class AddRemoveNodeTest {
    private var sceneA:SceneNode;
    private var sceneB:SceneNode;

    [Before]
    public function setUp():void {
        sceneA = new SceneNode();
        sceneB = new SceneNode();
    }

    [After]
    public function tearDown():void {
        sceneA = sceneB = null;
    }

    [Test]
    public function testSimpleAddRemoveNode():void {
        var node:Node = new Node();

        sceneA.addNode(node);

        assertEquals(node.parentNode, sceneA);
        assertEquals(node.sceneNode, sceneA);
        assertEquals(sceneA.nodeCount, 1);
        assertEquals(sceneA.getNodeAt(0), node);

        sceneB.addNode(node);

        assertEquals(node.parentNode, sceneB);
        assertEquals(node.sceneNode, sceneB);
        assertEquals(sceneA.nodeCount, 0);
        assertEquals(sceneB.nodeCount, 1);
        assertEquals(sceneB.getNodeAt(0), node);

        node.removeFromParent();

        assertEquals(node.parentNode, null);
        assertEquals(node.sceneNode, null);
        assertEquals(sceneA.nodeCount, 0);
        assertEquals(sceneB.nodeCount, 0);
    }

    [Test]
    public function testContainerAddRemoveNode():void {
        var node:Node           = new Node();
        var contA:ContainerNode = new ContainerNode();
        var contB:ContainerNode = new ContainerNode();

        sceneA.addNode(contA);

        assertEquals(contA.parentNode, sceneA);
        assertEquals(contA.sceneNode, sceneA);
        assertEquals(contA.nodeCount, 0);
        assertEquals(contB.parentNode, null);
        assertEquals(contB.sceneNode, null);
        assertEquals(contB.nodeCount, 0);
        assertEquals(sceneA.nodeCount, 1);
        assertEquals(sceneA.getNodeAt(0), contA);
        assertEquals(sceneB.nodeCount, 0);
        assertEquals(node.parentNode, null);
        assertEquals(node.sceneNode, null);

        sceneB.addNode(contB);

        assertEquals(contA.parentNode, sceneA);
        assertEquals(contA.sceneNode, sceneA);
        assertEquals(contA.nodeCount, 0);
        assertEquals(contB.parentNode, sceneB);
        assertEquals(contB.sceneNode, sceneB);
        assertEquals(contB.nodeCount, 0);
        assertEquals(sceneA.nodeCount, 1);
        assertEquals(sceneA.getNodeAt(0), contA);
        assertEquals(sceneB.nodeCount, 1);
        assertEquals(sceneB.getNodeAt(0), contB);
        assertEquals(node.parentNode, null);
        assertEquals(node.sceneNode, null);

        contA.addNode(node);

        assertEquals(contA.parentNode, sceneA);
        assertEquals(contA.sceneNode, sceneA);
        assertEquals(contA.nodeCount, 1);
        assertEquals(contA.getNodeAt(0), node);
        assertEquals(contB.parentNode, sceneB);
        assertEquals(contB.sceneNode, sceneB);
        assertEquals(contB.nodeCount, 0);
        assertEquals(sceneA.nodeCount, 1);
        assertEquals(sceneA.getNodeAt(0), contA);
        assertEquals(sceneB.nodeCount, 1);
        assertEquals(sceneB.getNodeAt(0), contB);
        assertEquals(node.parentNode, contA);
        assertEquals(node.sceneNode, sceneA);

        contB.addNode(node);

        assertEquals(contA.parentNode, sceneA);
        assertEquals(contA.sceneNode, sceneA);
        assertEquals(contA.nodeCount, 0);
        assertEquals(contB.parentNode, sceneB);
        assertEquals(contB.sceneNode, sceneB);
        assertEquals(contB.nodeCount, 1);
        assertEquals(contB.getNodeAt(0), node);
        assertEquals(sceneA.nodeCount, 1);
        assertEquals(sceneA.getNodeAt(0), contA);
        assertEquals(sceneB.nodeCount, 1);
        assertEquals(sceneB.getNodeAt(0), contB);
        assertEquals(node.parentNode, contB);
        assertEquals(node.sceneNode, sceneB);

        sceneA.addNode(contB);

        assertEquals(contA.parentNode, sceneA);
        assertEquals(contA.sceneNode, sceneA);
        assertEquals(contA.nodeCount, 0);
        assertEquals(contB.parentNode, sceneA);
        assertEquals(contB.sceneNode, sceneA);
        assertEquals(contB.nodeCount, 1);
        assertEquals(contB.getNodeAt(0), node);
        assertEquals(sceneA.nodeCount, 2);
        assertEquals(sceneA.getNodeAt(0), contA);
        assertEquals(sceneA.getNodeAt(1), contB);
        assertEquals(sceneB.nodeCount, 0);
        assertEquals(node.parentNode, contB);
        assertEquals(node.sceneNode, sceneA);

        contA.addNode(contB);

        assertEquals(contA.parentNode, sceneA);
        assertEquals(contA.sceneNode, sceneA);
        assertEquals(contA.nodeCount, 1);
        assertEquals(contA.getNodeAt(0), contB);
        assertEquals(contB.parentNode, contA);
        assertEquals(contB.sceneNode, sceneA);
        assertEquals(contB.nodeCount, 1);
        assertEquals(contB.getNodeAt(0), node);
        assertEquals(sceneA.nodeCount, 1);
        assertEquals(sceneA.getNodeAt(0), contA);
        assertEquals(sceneB.nodeCount, 0);
        assertEquals(node.parentNode, contB);
        assertEquals(node.sceneNode, sceneA);

        sceneB.addNode(contA);

        assertEquals(contA.parentNode, sceneB);
        assertEquals(contA.sceneNode, sceneB);
        assertEquals(contA.nodeCount, 1);
        assertEquals(contA.getNodeAt(0), contB);
        assertEquals(contB.parentNode, contA);
        assertEquals(contB.sceneNode, sceneB);
        assertEquals(contB.nodeCount, 1);
        assertEquals(contB.getNodeAt(0), node);
        assertEquals(sceneA.nodeCount, 0);
        assertEquals(sceneB.nodeCount, 1);
        assertEquals(sceneB.getNodeAt(0), contA);
        assertEquals(node.parentNode, contB);
        assertEquals(node.sceneNode, sceneB);
    }
}
}

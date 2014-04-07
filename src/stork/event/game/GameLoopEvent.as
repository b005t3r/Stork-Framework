/**
 * User: booster
 * Date: 05/03/14
 * Time: 13:37
 */
package stork.event.game {
import stork.event.*;
import stork.game.GameLoopNode;

public class GameLoopEvent extends Event {
    public static const PRE_LOOP:String = "preLoopGameLoopEvent";
    public static const POST_LOOP:String = "postLoopGameLoopEvent";

    public function GameLoopEvent(type:String) {
        super(type, false);
    }

    public function get gameLoop():GameLoopNode { return target as GameLoopNode; }
}
}

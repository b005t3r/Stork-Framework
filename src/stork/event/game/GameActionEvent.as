/**
 * User: booster
 * Date: 05/03/14
 * Time: 16:44
 */
package stork.event.game {
import stork.event.*;
import stork.game.GameActionNode;

public class GameActionEvent extends Event {
    public static const STARTED:String  = "startedGameActionEvent";
    public static const STEP:String     = "stepGameActionEvent";
    public static const FINISHED:String = "finishedGameActionEvent";
    public static const CANCELED:String = "canceledGameActionEvent";

    public function GameActionEvent(type:String) {
        super(type, false);
    }

    public function get action():GameActionNode { return target as GameActionNode; }
}
}

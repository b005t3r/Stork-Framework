/**
 * User: booster
 * Date: 30/01/14
 * Time: 8:50
 */
package flash.display {
import flash.errors.IllegalOperationError;

public class StorkMain extends Sprite {
    private static var _instance:StorkMain = null;

    public static function get instance():StorkMain { return _instance; }

    public function StorkMain() {
        if(_instance != null)
            throw new IllegalOperationError("only one instance of Main class can be created");

        _instance = this;
    }

}
}

/**
 * User: booster
 * Date: 29/01/14
 * Time: 11:21
 */
package stork.event.plugin {
import stork.core.SceneNode;
import stork.core.plugin.ScenePlugin;
import stork.event.Event;

public class ScenePluginEvent extends Event {
    public static const PLUGIN_ACTIVATED:String     = "pluginActivated";
    public static const PLUGIN_DEACTIVATED:String   = "pluginDeactivated";

    private var _plugin:ScenePlugin;

    public function ScenePluginEvent(type:String, plugin:ScenePlugin) {
        super(type, false);

        _plugin = plugin;
    }

    public function get plugin():ScenePlugin { return _plugin; }
    public function get sceneNode():SceneNode { return target as SceneNode; }
}
}

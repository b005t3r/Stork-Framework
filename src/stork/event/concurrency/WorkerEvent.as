/**
 * User: booster
 * Date: 25/07/15
 * Time: 12:07
 */
package stork.event.concurrency {
import stork.concurrency.WorkerNode;
import stork.event.Event;

public class WorkerEvent extends Event {
    public static const STARTED:String      = "startedWorkerEvent";
    public static const TERMINATED:String   = "terminatedWorkerEvent";

    public function WorkerEvent(type:String) {
        super(type, false);
    }

    public function get workerNode():WorkerNode { return target as WorkerNode; }
}
}

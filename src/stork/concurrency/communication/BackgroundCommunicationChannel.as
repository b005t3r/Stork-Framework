/**
 * User: booster
 * Date: 25/07/15
 * Time: 11:17
 */
package stork.concurrency.communication {
import flash.events.Event;
import flash.system.MessageChannel;
import flash.system.Worker;

import medkit.collection.HashMap;
import medkit.object.ObjectInputStream;
import medkit.object.ObjectOutputStream;

public class BackgroundCommunicationChannel implements ICommunicationChannel {
    private var _worker:Worker;
    private var _workerToMainChannels:HashMap = new HashMap();
    private var _mainToWorkerChannels:HashMap = new HashMap();

    public function BackgroundCommunicationChannel(worker:Worker) {
        _worker = worker != Worker.current ? worker : null;
    }

    public function createMessageChannel(channelID:String, channelMessageHandler:Function = null):void {
        var workerToMain:MessageChannel;
        var mainToWorker:MessageChannel;

        if(_worker != null) {
            workerToMain = _worker.createMessageChannel(Worker.current);
            mainToWorker = Worker.current.createMessageChannel(_worker);

            _worker.setSharedProperty(channelID + ".workerToMain", workerToMain);
            _worker.setSharedProperty(channelID + ".mainToWorker", mainToWorker);

            _workerToMainChannels.put(channelID, workerToMain);
            _mainToWorkerChannels.put(channelID, mainToWorker);

            if(channelMessageHandler != null)
                workerToMain.addEventListener(Event.CHANNEL_MESSAGE, function(e:Event):void { channelMessageHandler(); });
        }
        else {
            workerToMain = Worker.current.getSharedProperty(channelID + ".workerToMain");
            mainToWorker = Worker.current.getSharedProperty(channelID + ".mainToWorker");

            if(workerToMain == null || mainToWorker == null)
                throw new ArgumentError("channel '" + channelID + "' not created by the main process");

            var oldWorkerToMain:MessageChannel = _workerToMainChannels.put(channelID, workerToMain);
            var oldMainToWorker:MessageChannel = _mainToWorkerChannels.put(channelID, mainToWorker);

            if(oldWorkerToMain != null || oldMainToWorker != null)
                throw new ArgumentError("channel '" + channelID + "' already exists");

            if(channelMessageHandler != null)
                mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, channelMessageHandler);
        }
    }

    public function send(channelID:String, payload:*, mode:SharingMode):void {
        var channel:MessageChannel = _worker != null ? _mainToWorkerChannels.get(channelID) : _workerToMainChannels.get(channelID);

        if(channel == null)
            throw new ArgumentError("channel '" + channelID + "' is does not exist");

        if(mode == SharingMode.Serialize) {
            var oos:ObjectOutputStream = new ObjectOutputStream();
            oos.writeObject(payload, "payload");
            payload = oos.jsonData;
        }

        channel.send(payload);
    }

    public function receive(channelID:String, mode:SharingMode):* {
        var channel:MessageChannel = _worker != null ? _workerToMainChannels.get(channelID) : _mainToWorkerChannels.get(channelID);

        if(channel == null)
            throw new ArgumentError("channel '" + channelID + "' is does not exist");

        var payload:* = channel.receive(true);

        if(mode == SharingMode.Serialize) {
            var ois:ObjectInputStream = new ObjectInputStream(payload);
            payload = ois.readObject("payload");
        }

        return payload;
    }
}
}

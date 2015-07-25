/**
 * User: booster
 * Date: 24/07/15
 * Time: 16:59
 */
package stork.concurrency {
import flash.display.Sprite;
import flash.system.Worker;

import stork.concurrency.communication.BackgroundCommunicationChannel;
import stork.concurrency.communication.ICommunicationChannel;

public class BackgroundProcess extends Sprite {
    private var _commChannel:ICommunicationChannel;

    public function BackgroundProcess() {
        if(! Worker.current.isPrimordial)
            _commChannel = new BackgroundCommunicationChannel(null);
        else
            throw new Error("foreground execution not supported");
    }

    protected final function createMessageChannel(channelID:String, channelMessageHandler:Function = null):void {
        _commChannel.createMessageChannel(channelID, channelMessageHandler);
    }

    protected final function send(channelID:String, payload:*, serialize:Boolean):void {
        _commChannel.send(channelID, payload, serialize);
    }

    protected final function receive(channelID:String, deserialize:Boolean):* {
        return _commChannel.receive(channelID, deserialize);
    }
}
}

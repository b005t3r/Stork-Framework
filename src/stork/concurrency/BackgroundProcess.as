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
import stork.concurrency.communication.SharingMode;

public class BackgroundProcess extends Sprite {
    private var _commChannel:ICommunicationChannel;

    public function BackgroundProcess() {
        if(! Worker.current.isPrimordial)
            _commChannel = new BackgroundCommunicationChannel(null);
        else
            trace("foreground execution not supported for workers - doing nothing");
    }

    protected final function createMessageChannel(channelID:String, channelMessageHandler:Function = null):void {
        _commChannel.createMessageChannel(channelID, channelMessageHandler);
    }

    protected final function send(channelID:String, payload:*, sharingMode:SharingMode):void {
        _commChannel.send(channelID, payload, sharingMode);
    }

    protected final function receive(channelID:String, sharingMode:SharingMode):* {
        return _commChannel.receive(channelID, sharingMode);
    }
}
}

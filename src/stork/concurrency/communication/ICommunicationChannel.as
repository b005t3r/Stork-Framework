/**
 * User: booster
 * Date: 25/07/15
 * Time: 11:10
 */
package stork.concurrency.communication {
public interface ICommunicationChannel {
    function createMessageChannel(channelID:String, channelMessageHandler:Function = null):void
    function send(channelID:String, payload:*, mode:SharingMode):void
    function receive(channelID:String, mode:SharingMode):*
}
}

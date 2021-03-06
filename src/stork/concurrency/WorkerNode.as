/**
 * User: booster
 * Date: 24/07/15
 * Time: 17:21
 */
package stork.concurrency {
import flash.display.Loader;
import flash.errors.IOError;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Worker;
import flash.system.WorkerDomain;
import flash.system.WorkerState;

import stork.concurrency.communication.BackgroundCommunicationChannel;
import stork.concurrency.communication.ICommunicationChannel;
import stork.concurrency.communication.SharingMode;
import stork.core.Node;
import stork.event.concurrency.WorkerEvent;

public class WorkerNode extends Node {
    private var _worker:Worker;
    private var _creatingChannels:Boolean;
    private var _commChannel:ICommunicationChannel;

    private var _startedEvent:WorkerEvent       = new WorkerEvent(WorkerEvent.STARTED);
    private var _terminatedEvent:WorkerEvent    = new WorkerEvent(WorkerEvent.TERMINATED);

    private var _receivingMessage:Boolean;
    private var _receiveCalled:Boolean;

    public function WorkerNode(name:String = "Worker") {
        super(name);
    }

    public final function get running():Boolean { return _worker != null; }

    protected function onWorkerStarted():void {
        // do nothing, implement in subclass if needed
    }

    protected function onWorkerTerminated():void {
        // do nothing, implement in subclass if needed
    }

    protected final function startBackgroundProcess(swfPath:String, createMessageChannelsBlock:Function = null):void {
        if(_commChannel != null)
            throw new IllegalOperationError("worker already started");

/*
        var loader:URLLoader    = new URLLoader();
        loader.dataFormat       = URLLoaderDataFormat.BINARY;

        loader.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
        loader.load(new URLRequest(swfPath));
 */

        var urlRequest:URLRequest   = new URLRequest(swfPath);
        var loader:Loader           = new Loader();
        var lc:LoaderContext        = new LoaderContext(false, ApplicationDomain.currentDomain, null);

        //adding event handler
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
        loader.load(urlRequest, lc);

        function onLoadComplete(event:Event):void {
            //_worker         = WorkerDomain.current.createWorker(event.target.data);
            _worker         = WorkerDomain.current.createWorker(event.target.bytes);
            _commChannel    = new BackgroundCommunicationChannel(_worker);

            if(createMessageChannelsBlock != null) {
                _creatingChannels = true;
                createMessageChannelsBlock();
                _creatingChannels = false;
            }

            _worker.addEventListener(Event.WORKER_STATE, onWorkerStateChanged);
            _worker.start();
        }

        function onLoadIOError(event:IOErrorEvent):void {
            throw new IOError("IO error: " + event.toString(), event.errorID);
        }
    }

    protected final function terminateBackgroundProcess():void {
        if(_worker == null)
            throw new IllegalOperationError("worker not running");

        _worker.terminate();
    }

    protected final function createMessageChannel(channelID:String, channelMessageHandler:Function = null):void {
        if(! _creatingChannels)
            throw new UninitializedError("channels can only be created using createBackgroundWorker() method");

        _commChannel.createMessageChannel(channelID, channelMessageHandler == null ? null : function():void {
            _receivingMessage = true;
            _receiveCalled = false;

            channelMessageHandler();

            _receivingMessage = false;
            _receiveCalled = false;
        });
    }

    protected final function send(channelID:String, payload:*, sharingMode:SharingMode):void {
        _commChannel.send(channelID, payload, sharingMode);
    }

    protected final function receive(channelID:String, sharingMode:SharingMode):* {
        if(! _receivingMessage)
            throw new Error("receive() can only be called inside a message channel handler function");

        if(_receiveCalled)
            throw new Error("receive() already called on this message channel handler call - wait for the next message to call it again");

        _receiveCalled = true;
        return _commChannel.receive(channelID, sharingMode);
    }

    private function onWorkerStateChanged(event:Event):void {
        if(_worker.state == WorkerState.RUNNING) {
            onWorkerStarted();

            dispatchEvent(_startedEvent.reset());
        }
        else if(_worker.state == WorkerState.TERMINATED) {
            onWorkerTerminated();

            dispatchEvent(_terminatedEvent.reset());

            _worker = null;
            _commChannel = null;
        }
    }
}
}

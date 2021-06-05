using Godot;
using System;
using MQTTnet;
using MQTTnet.Client;
using MQTTnet.Extensions.ManagedClient;
using MQTTnet.Client.Options;
using MQTTnet.Client.Connecting;
using MQTTnet.Client.Disconnecting;
using MQTTnet.Client.Receiving;



public class MQTT : Node 
{
    [Signal] public delegate void Connected();
    [Signal] public delegate void Disconnected();
    [Signal] public delegate void Subscribed(string topic);
    [Signal] public delegate void Unsubscribed(String[] topics);
    [Signal] public delegate void MessageReceived(string topic, string payload);
    [Signal] public delegate void MessagePublished(string topic, string payload);
    public string clientId = "";
    public string mqttURI = "vps-d2eaf76a.vps.ovh.net";
    public string mqttUser = "";
    public string mqttPassword = "";
    public int mqttPort = 1883;
    public bool mqttSecure = false;

    public string client_topic = "firefliotclient";
    public string factory_code = "tecnarredo-abi03412";

    private IManagedMqttClient mqttClient;
    private ManagedMqttClientOptions options;

    public override void _Ready()
    {
        base._Ready();
        client_topic += "_"+factory_code+"/glue/shared";
    }

    private void OnSubscriberConnected(MqttClientConnectedEventArgs x)
    {
        //GD.Print("Client Connected: ", x.AuthenticateResult.ResultCode);
        EmitSignal(nameof(Connected));
    }

    private void OnSubscriberDisconnected(MqttClientDisconnectedEventArgs x)
    {
        //GD.Print("Client Disconnected.");
        EmitSignal(nameof(Disconnected));
    }
    
    private void OnSubscriberMessageReceived(MqttApplicationMessageReceivedEventArgs x)
    {
        var item = $"Timestamp: {DateTime.Now:O} | Topic: {x.ApplicationMessage.Topic} | Payload: {x.ApplicationMessage.ConvertPayloadToString()} | QoS: {x.ApplicationMessage.QualityOfServiceLevel}";
        EmitSignal(nameof(MessageReceived), x.ApplicationMessage.Topic, x.ApplicationMessage.ConvertPayloadToString());
        //GD.Print(item);
    }

    private void ConnectHandlers()
    {
        mqttClient.ConnectedHandler = new MqttClientConnectedHandlerDelegate(OnSubscriberConnected);
        mqttClient.DisconnectedHandler = new MqttClientDisconnectedHandlerDelegate(OnSubscriberDisconnected);
        mqttClient.ApplicationMessageReceivedHandler = new MqttApplicationMessageReceivedHandlerDelegate(OnSubscriberMessageReceived);        
    }

    public void SetupClient(string host, int port, string id)
    {
        options = new ManagedMqttClientOptionsBuilder()
        .WithAutoReconnectDelay(TimeSpan.FromSeconds(5))
        .WithClientOptions(new MqttClientOptionsBuilder()
        .WithClientId("firefliot-client#"+id)
        .WithTcpServer(host, port))
        .Build();
        mqttURI = host;
        mqttPort = port;
        clientId = id;
        mqttClient = new MqttFactory().CreateManagedMqttClient();
        if ( !mqttClient.IsConnected ) ConnectHandlers();
    }

    public async void ConnectClient(string host, int port, string id) 
    {
        SetupClient(host, port, id);
        if ( mqttClient.IsConnected ) { await mqttClient.StopAsync(); }
        await mqttClient.StartAsync(options);
    }

    public async void PublishMessage(string topic, string payload, bool retainFlag = false, int qos = 1) {
        await mqttClient.PublishAsync(new MqttApplicationMessageBuilder()
        .WithTopic(topic)
        .WithPayload(payload)
        .WithQualityOfServiceLevel((MQTTnet.Protocol.MqttQualityOfServiceLevel)qos)
        .WithRetainFlag(retainFlag)
        .Build());
        EmitSignal(nameof(MessagePublished), topic, payload);
    }

    public async void SubscribeToTopic(string topic)
    {
        await mqttClient.SubscribeAsync(new MqttTopicFilterBuilder().WithTopic(topic).Build());
        EmitSignal(nameof(Subscribed), topic);
    }
    public async void UnsubscribeFromTopics(String[] topics)
    {
        await mqttClient.UnsubscribeAsync(topics);
        EmitSignal(nameof(Unsubscribed), topics);
    }
}
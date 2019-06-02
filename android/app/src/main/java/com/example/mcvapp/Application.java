package com.example.mcvapp;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterView;

public class Application extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {

    @Override
    public void onCreate() {
        super.onCreate();
        BackgroundFetchPlugin.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry pluginRegistry) {
        GeneratedPluginRegistrant.registerWith(pluginRegistry);
    }
}

package com.accessibility.service.accessibility_service

import android.media.AudioManager
import android.media.AudioPlaybackConfiguration
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

/** AccessibilityServicePlugin */
class AccessibilityServicePlugin :
    FlutterPlugin,
    EventChannel.StreamHandler
{
    private lateinit var eventChannel: EventChannel

    private lateinit var audioManager: AudioManager
    private var audioPlaybackCallback: Any? = null

    private var announcementStateSink: EventChannel.EventSink? = null

    private var wasPlayingAccessibilityAudio: Boolean = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            "accessibility_service/announcement_state"
        )

        audioManager = flutterPluginBinding.applicationContext.getSystemService(
            android.content.Context.AUDIO_SERVICE
        ) as AudioManager

        eventChannel.setStreamHandler(this)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        wasPlayingAccessibilityAudio = false
        unregisterAudioCallback()

        announcementStateSink = null
        eventChannel.setStreamHandler(null)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        announcementStateSink = events

        registerAudioCallback()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCancel(arguments: Any?) {
        announcementStateSink = null
        wasPlayingAccessibilityAudio = false

        unregisterAudioCallback()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun registerAudioCallback() {
        val callback = object : AudioManager.AudioPlaybackCallback() {
            override fun onPlaybackConfigChanged(configs: MutableList<AudioPlaybackConfiguration>) {
                super.onPlaybackConfigChanged(configs)

                handlePlaybackConfigChange(configs)
            }
        }

        audioPlaybackCallback = callback
        audioManager.registerAudioPlaybackCallback(callback, null)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun unregisterAudioCallback() {
        (audioPlaybackCallback as? AudioManager.AudioPlaybackCallback)?.let {
            audioManager.unregisterAudioPlaybackCallback(it)
        }
        audioPlaybackCallback = null
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun handlePlaybackConfigChange(configs: MutableList<AudioPlaybackConfiguration>) {
        val isPlaying =
            configs.any { it.audioAttributes.usage == android.media.AudioAttributes.USAGE_ASSISTANCE_ACCESSIBILITY }

        if (!isPlaying && wasPlayingAccessibilityAudio) {
            announcementStateSink?.success(null)
        }

        wasPlayingAccessibilityAudio = isPlaying
    }
}

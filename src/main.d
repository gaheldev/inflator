module main;

import std.math;
import std.algorithm;

import dplug.core,
       dplug.dsp,
       dplug.client;

import gui;

import inflator;

mixin(pluginEntryPoints!ExampleClient);

enum : int
{
	paramClip,
	paramCurve,
	paramEffect,
	paramIn,
	paramInput,
	paramOutput,
}


final class ExampleClient : FaustClient
{
public:
nothrow:
@nogc:

    this()
    {
        super();
    }

    override void processAudio(const(float*)[] inputs, float*[]outputs, int frames, TimeInfo info)
    {
        assert(frames <= 512);
        super.processAudio(inputs, outputs, frames, info);

        if (ExampleGUI gui = cast(ExampleGUI) graphicsAcquire())
        {
            graphicsRelease();
        }
    }

    override IGraphics createGraphics()
    {
        return mallocNew!ExampleGUI(this);
    }
}


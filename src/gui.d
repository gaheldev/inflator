module gui;

import dplug.gui;
import dplug.flatwidgets;
import dplug.client;
import dplug.canvas;

import main;

class ExampleGUI : FlatBackgroundGUI!("background.png",
                                      `/home/gael/code/audio/plugins/faust/inflator/gfx/`)
{
public:
nothrow:
@nogc:

    ExampleClient _client;

    this(ExampleClient client)    
    {
        _client = client;

        static immutable float[7] ratios = [0.5f, 1.0f, 1.5f, 2.0f, 3.0f];
        super( makeSizeConstraintsDiscrete(352, 108, ratios) );

        setUpdateMargin(0);

        OwnedImage!RGBA knobImage = loadOwnedImage(cast(ubyte[])(import("knob.png")));
		OwnedImage!RGBA switchOnImage = loadOwnedImage(cast(ubyte[])(import("switchOn.png")));
        OwnedImage!RGBA switchOffImage = loadOwnedImage(cast(ubyte[])(import("switchOff.png")));

        int numFrames = 100;

		_clipSwitch = mallocNew!UIImageSwitch(context(), cast(BoolParameter) _client.param(paramClip), switchOnImage, switchOffImage);
        addChild(_clipSwitch);

		_effectInSwitch = mallocNew!UIImageSwitch(context(), cast(BoolParameter) _client.param(paramIn), switchOnImage, switchOffImage);
        addChild(_effectInSwitch);

        _curveKnob = mallocNew!UIFilmstripKnob(context(), cast(FloatParameter) _client.param(paramCurve), knobImage, numFrames);
        addChild(_curveKnob);

        _effectKnob = mallocNew!UIFilmstripKnob(context(), cast(FloatParameter) _client.param(paramEffect), knobImage, numFrames);
        addChild(_effectKnob);

        _inputKnob = mallocNew!UIFilmstripKnob(context(), cast(FloatParameter) _client.param(paramInput), knobImage, numFrames);
        addChild(_inputKnob);

        _outputKnob = mallocNew!UIFilmstripKnob(context(), cast(FloatParameter) _client.param(paramOutput), knobImage, numFrames);
        addChild(_outputKnob);

        addChild(_resizerHint = mallocNew!UIWindowResizer(context()));        
    }

    override void reflow()
    {
        super.reflow();

        int W = position.width;
        int H = position.height;

        float S = W / cast(float)(context.getDefaultUIWidth());

        immutable int knobWidth = 64;
        immutable int knobHeight = 64;

        immutable int switchWidth = 32;
        immutable int switchHeight = 16;

        _inputKnob.position      =    rectangle(12, 32, knobWidth, knobHeight).scaleByFactor(S);
        _curveKnob.position      =    rectangle(100, 32, knobWidth, knobHeight).scaleByFactor(S);
        _effectKnob.position     =    rectangle(188, 32, knobWidth, knobHeight).scaleByFactor(S);
        _outputKnob.position     =    rectangle(276, 32, knobWidth, knobHeight).scaleByFactor(S);

        _clipSwitch.position     =    rectangle(40,  8, switchWidth, switchHeight).scaleByFactor(S);
        _effectInSwitch.position =    rectangle(140, 8, switchWidth, switchHeight).scaleByFactor(S);

        _resizerHint.position    =    rectangle(W-30, H-30, 30, 30);
    }

private:
    UIImageSwitch   _clipSwitch;
    UIImageSwitch   _effectInSwitch;
    UIFilmstripKnob _curveKnob;
    UIFilmstripKnob _effectKnob;
    UIFilmstripKnob _inputKnob;
    UIFilmstripKnob _outputKnob;
    UIWindowResizer _resizerHint;
}

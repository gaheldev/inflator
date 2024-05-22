
/+ dub.sdl:
	name "inflator"
	dependency "dplug:core" version="*"
+/
module inflator;
/* ------------------------------------------------------------
name: "inflator"
Code generated with Faust 2.74.3 (https://faust.grame.fr)
Compilation options: -a dplug.d -lang dlang -ct 1 -cn Inflator -es 1 -mcd 16 -mdd 1024 -mdy 33 -single -ftz 0 -vec -lv 0 -vs 32
------------------------------------------------------------ */
/************************************************************************
 IMPORTANT NOTE : this file contains two clearly delimited sections :
 the ARCHITECTURE section (in two parts) and the USER section. Each section
 is governed by its own copyright and license. Please check individually
 each section for license and copyright information.
 *************************************************************************/

/*******************BEGIN ARCHITECTURE SECTION (part 1/2)****************/

/************************************************************************
 FAUST Architecture File
 Copyright (C) 2003-2019 GRAME, Centre National de Creation Musicale
 ---------------------------------------------------------------------
 This Architecture section is free software; you can redistribute it
 and/or modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 3 of
 the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; If not, see <http://www.gnu.org/licenses/>.
 
 EXCEPTION : As a special exception, you may create a larger work
 that contains this FAUST architecture section and distribute
 that work under terms of your choice, so long as this FAUST
 architecture section is not modified.
 
 ************************************************************************
 ************************************************************************/

// faust -a dplug.d -lang dlang noise.dsp -o noise.d

import dplug.core.vec;
import dplug.client;
import core.stdc.stdlib : strtol;

alias FAUSTFLOAT = float;

class Meta {
nothrow:
@nogc:
    void declare(string name, string value) {}
}

class UI {
nothrow:
@nogc:
    void declare(string id, string key, string value) {}
    void declare(int id, string key, string value) {}
    void declare(FAUSTFLOAT* id, string key, string value) {}

    // -- layout groups

    void openTabBox(string label) {}
    void openHorizontalBox(string label) {}
    void openVerticalBox(string label) {}
    void closeBox() {}

    // -- active widgets

    void addButton(string label, FAUSTFLOAT* val) {}
    void addCheckButton(string label, FAUSTFLOAT* val) {}
    void addVerticalSlider(string label, FAUSTFLOAT* val, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) {}
    void addHorizontalSlider(string label, FAUSTFLOAT* val, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) {}
    void addNumEntry(string label, FAUSTFLOAT* val, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step) {}

    // -- passive display widgets

    void addHorizontalBargraph(string label, FAUSTFLOAT* val, FAUSTFLOAT min, FAUSTFLOAT max) {}
    void addVerticalBargraph(string label, FAUSTFLOAT* val, FAUSTFLOAT min, FAUSTFLOAT max) {}
}

interface dsp {
nothrow:
@nogc:
public:
    void metadata(Meta* m);
    int getNumInputs();
    int getNumOutputs();
    void buildUserInterface(UI* uiInterface);
    int getSampleRate();
    void instanceInit(int sample_rate);
    void instanceResetUserInterface();
    void compute(int count, FAUSTFLOAT*[] inputs, FAUSTFLOAT*[] outputs);
    void initialize(int sample_rate);
}

/**
 * Implements and overrides the methods that would provide parameters for use in 
 * a plug-in or GUI.  These parameters are stored in a vector which can be accesed via
 * `readParams()`
 */
class FaustParamAccess : UI {
nothrow:
@nogc:
    this()
    {
        _faustParams = makeVec!FaustParam();
    }

    override void declare(FAUSTFLOAT* id, string key, string value)
    {
        if (value == "")
        {
            nextParamId = cast(int)strtol(key.ptr, null, 0);
        }
        else if (key == "unit")
        {
            nextParamUnit = value;
        }
    }

    override void addButton(string label, FAUSTFLOAT* val)
    {
        _faustParams.pushBack(FaustParam(label, nextParamUnit, val, 0, 0, 0, 0, true, nextParamId));
        resetNextParamMeta();
    }
    
    override void addCheckButton(string label, FAUSTFLOAT* val)
    {
        _faustParams.pushBack(FaustParam(label, nextParamUnit, val, 0, 0, 0, 0, true, nextParamId));
        resetNextParamMeta();
    }
    
    override void addVerticalSlider(string label, FAUSTFLOAT* val, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
    {
        _faustParams.pushBack(FaustParam(label, nextParamUnit, val, init, min, max, step, false, nextParamId));
        resetNextParamMeta();
    }

    override void addHorizontalSlider(string label, FAUSTFLOAT* val, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
    {
        _faustParams.pushBack(FaustParam(label, nextParamUnit, val, init, min, max, step, false, nextParamId));
        resetNextParamMeta();
    }

    override void addNumEntry(string label, FAUSTFLOAT* val, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
    {
        _faustParams.pushBack(FaustParam(label, nextParamUnit, val, init, min, max, step, false, nextParamId));
        resetNextParamMeta();
    }

    FaustParam[] readParams()
    {
        /* return _faustParams.releaseData(); */
        /* Vec!FaustParam _sortedList = makeVec!FaustParam(); */
        return sortParams(_faustParams.releaseData());
    }

    FaustParam readParam(int index)
    {
        return _faustParams[index];
    }

    ulong length()
    {
        return _faustParams.length();
    }

private:
    Vec!FaustParam _faustParams;
    int nextParamId = -1;
    string nextParamUnit = "";

    void resetNextParamMeta()
    {
        nextParamId = -1;
        nextParamUnit = "";
    }

    // simple bubble sort
    FaustParam[] sortParams(FaustParam[] params)
    {
        bool success = true;
        do
        {
            success = true;
            for(int i = 0; i < params.length - 1; ++i)
            {
                auto left = params[i];
                auto right = params[i + 1];
                if (right.ParamId < left.ParamId)
                {
                    params[i] = right;
                    params[i + 1] = left;
                    success = false;
                }
            }
        }
        while(!success);
        return params;
    }
}

struct FaustParam
{
    string label;
    string unit;
    FAUSTFLOAT* val;
    FAUSTFLOAT initial;
    FAUSTFLOAT min;
    FAUSTFLOAT max;
    FAUSTFLOAT step;
    bool isButton = false;
    int ParamId;
}

version(unittest){}
version(faustoverride){}
else
mixin(pluginEntryPoints!FaustClient);

class FaustClient : dplug.client.Client
{
public:
nothrow:
@nogc:

    this()
    {
        buildFaustModule();
    }

    void buildFaustModule()
    {
        _dsp = mallocNew!(FAUSTCLASS)();
        FaustParamAccess _faustUI = mallocNew!FaustParamAccess();
        _dsp.buildUserInterface(cast(UI*)(&_faustUI));
        _faustParams = _faustUI.readParams();
    }

    override PluginInfo buildPluginInfo()
    {
        // Plugin info is parsed from plugin.json here at compile time.
        // Indeed it is strongly recommended that you do not fill PluginInfo 
        // manually, else the information could diverge.
        static immutable PluginInfo pluginInfo = parsePluginInfo(import("plugin.json"));
        return pluginInfo;
    }

    // This is an optional overload, default is zero parameter.
    // Caution when adding parameters: always add the indices
    // in the same order as the parameter enum.
    override Parameter[] buildParameters()
    {
        auto params = makeVec!Parameter();

        // Add faust parameters
        buildFaustModule();
        int faustParamIndexStart = 0;
        foreach(param; _faustParams)
        {
            if (param.isButton)
            {
                params ~= mallocNew!BoolParameter(faustParamIndexStart++, param.label, cast(bool)(*param.val));
            }
            else if (param.step == 1.0f) {
                params ~= mallocNew!IntegerParameter(faustParamIndexStart++, param.label, param.unit, cast(int)param.min, cast(int)param.max, cast(int)param.initial);
            }
            else
            {
                params ~= mallocNew!LinearFloatParameter(faustParamIndexStart++, param.label, param.unit, param.min, param.max, param.initial);
            }
        }

        return params.releaseData();
    }

    override LegalIO[] buildLegalIO()
    {
        auto io = makeVec!LegalIO();
        if (_dsp is null)
        {
            _dsp = mallocNew!(FAUSTCLASS)();
        }
        io ~= LegalIO(_dsp.getNumInputs(), _dsp.getNumOutputs());
        return io.releaseData();
    }

    // This override is optional, the default implementation will
    // have one default preset.
    override Preset[] buildPresets() nothrow @nogc
    {
        auto presets = makeVec!Preset();
        presets ~= makeDefaultPreset();
        return presets.releaseData();
    }

    // This override is also optional. It allows to split audio buffers in order to never
    // exceed some amount of frames at once.
    // This can be useful as a cheap chunking for parameter smoothing.
    // Buffer splitting also allows to allocate statically or on the stack with less worries.
    override int maxFramesInProcess() const //nothrow @nogc
    {
        return 512;
    }

    override void reset(double sampleRate, int maxFrames, int numInputs, int numOutputs) nothrow @nogc
    {
        // Clear here any state and delay buffers you might have.
        _dsp.initialize(cast(int)sampleRate);
        assert(maxFrames <= 512); // guaranteed by audio buffer splitting
    }

    void updateFaustParams()
    {
        foreach(param; params())
        {            
            int paramIndex = param.index();
            foreach(faustParam; _faustParams)
            {
                if (paramIndex == faustParam.ParamId)
                {
                    if (cast(FloatParameter)param)
                    {
                        *(faustParam.val) = (cast(FloatParameter)param).valueAtomic();
                    }
                    else if (cast(IntegerParameter)param)
                    {
                        *(faustParam.val) = cast(FAUSTFLOAT)((cast(IntegerParameter)param).valueAtomic());
                    }
                    else if (cast(BoolParameter)param)
                    {
                        *(faustParam.val) = cast(FAUSTFLOAT)((cast(BoolParameter)param).valueAtomic());
                    }
                    else
                    {
                        assert(false, "Parameter type not implemented");
                    }
                }
            }
        }
    }

    override void processAudio(const(float*)[] inputs, float*[]outputs, int frames,
                               TimeInfo info) nothrow @nogc
    {
        assert(frames <= 512); // guaranteed by audio buffer splitting

        int numInputs = cast(int)inputs.length;
        int numOutputs = cast(int)outputs.length;

        int minChan = numInputs > numOutputs ? numOutputs : numInputs;

        // do reverb
        updateFaustParams();
        _dsp.compute(frames, cast(float*[])inputs, cast(float*[])outputs);

        // fill with zero the remaining channels
        for (int chan = minChan; chan < numOutputs; ++chan)
            outputs[chan][0..frames] = 0; // D has array slices assignments and operations
    }

protected:
    FAUSTCLASS _dsp;
    UI _faustUI;
    FaustParam[] _faustParams;
}

/******************************************************************************
 *******************************************************************************
 
 VECTOR INTRINSICS
 
 *******************************************************************************
 *******************************************************************************/


/********************END ARCHITECTURE SECTION (part 1/2)****************/

/**************************BEGIN USER SECTION **************************/

import std.math;
import std.algorithm : min, max;
import dplug.core.nogc: mallocNew, mallocSlice, destroyFree, assumeNothrowNoGC;
alias FAUSTCLASS = Inflator;
static float Inflator_faustpower2_f(float value) nothrow @nogc {
	return value * value;
}
static float Inflator_faustpower4_f(float value) nothrow @nogc {
	return value * value * value * value;
}
static float Inflator_faustpower3_f(float value) nothrow @nogc {
	return value * value * value;
}

class Inflator : dsp
{
nothrow:
@nogc:
	
 private:
	
	FAUSTFLOAT fCheckbox0;
	FAUSTFLOAT fHslider0;
	FAUSTFLOAT fCheckbox1;
	FAUSTFLOAT fHslider1;
	FAUSTFLOAT fHslider2;
	FAUSTFLOAT fHslider3;
	int fSampleRate;
	
 public:
	
	void metadata(Meta* m) nothrow @nogc { 
		m.declare("basics.lib/name", "Faust Basic Element Library");
		m.declare("basics.lib/tabulateNd", "Copyright (C) 2023 Bart Brouns <bart@magnetophon.nl>");
		m.declare("basics.lib/version", "1.16.0");
		m.declare("compile_options", "-a dplug.d -lang dlang -ct 1 -cn Inflator -es 1 -mcd 16 -mdd 1024 -mdy 33 -single -ftz 0 -vec -lv 0 -vs 32");
		m.declare("filename", "inflator.dsp");
		m.declare("name", "inflator");
	}

	int getNumInputs() nothrow @nogc {
		return 2;
	}
	int getNumOutputs() nothrow @nogc {
		return 2;
	}
	
	static void classInit(int sample_rate) nothrow @nogc {
	}
	
	void instanceConstants(int sample_rate) nothrow @nogc {
		fSampleRate = sample_rate;
	}
	
	void instanceResetUserInterface() nothrow @nogc {
		fCheckbox0 = cast(FAUSTFLOAT)(0.0);
		fHslider0 = cast(FAUSTFLOAT)(0.0);
		fCheckbox1 = cast(FAUSTFLOAT)(0.0);
		fHslider1 = cast(FAUSTFLOAT)(0.0);
		fHslider2 = cast(FAUSTFLOAT)(0.0);
		fHslider3 = cast(FAUSTFLOAT)(0.0);
	}
	
	void instanceClear() nothrow @nogc {
	}
	
	void initialize(int sample_rate) nothrow @nogc {
		classInit(sample_rate);
		instanceInit(sample_rate);
	}
	void instanceInit(int sample_rate) nothrow @nogc {
		instanceConstants(sample_rate);
		instanceResetUserInterface();
		instanceClear();
	}
	
	Inflator clone() {
		return (mallocNew!Inflator());
	}
	
	int getSampleRate() nothrow @nogc {
		return fSampleRate;
	}
	
	void buildUserInterface(UI* uiInterface) nothrow @nogc {
		uiInterface.openVerticalBox("inflator");
		uiInterface.declare(&fHslider0, "0", "");
		uiInterface.addHorizontalSlider("input", &fHslider0, cast(FAUSTFLOAT)0.0, cast(FAUSTFLOAT)-6.0, cast(FAUSTFLOAT)12.0, cast(FAUSTFLOAT)0.1);
		uiInterface.declare(&fHslider1, "1", "");
		uiInterface.addHorizontalSlider("curve", &fHslider1, cast(FAUSTFLOAT)0.0, cast(FAUSTFLOAT)-5e+01, cast(FAUSTFLOAT)5e+01, cast(FAUSTFLOAT)0.1);
		uiInterface.declare(&fHslider2, "2", "");
		uiInterface.addHorizontalSlider("effect", &fHslider2, cast(FAUSTFLOAT)0.0, cast(FAUSTFLOAT)0.0, cast(FAUSTFLOAT)1e+02, cast(FAUSTFLOAT)0.1);
		uiInterface.declare(&fCheckbox1, "3", "");
		uiInterface.addCheckButton("clip", &fCheckbox1);
		uiInterface.declare(&fCheckbox0, "4", "");
		uiInterface.addCheckButton("effect in", &fCheckbox0);
		uiInterface.declare(&fHslider3, "5", "");
		uiInterface.addHorizontalSlider("output", &fHslider3, cast(FAUSTFLOAT)0.0, cast(FAUSTFLOAT)-12.0, cast(FAUSTFLOAT)0.0, cast(FAUSTFLOAT)0.1);
		uiInterface.closeBox();
	}
	
	void compute(int count, FAUSTFLOAT*[] inputs, FAUSTFLOAT*[] outputs) nothrow @nogc {
		FAUSTFLOAT* input0_ptr = inputs[0];
		FAUSTFLOAT* input1_ptr = inputs[1];
		FAUSTFLOAT* output0_ptr = outputs[0];
		FAUSTFLOAT* output1_ptr = outputs[1];
		int iSlow0 = cast(int)(cast(float)(fCheckbox0));
		float fSlow1 = pow(1e+01, 0.05 * cast(float)(fHslider0));
		float[32] fZec0;
		int iSlow2 = cast(int)(cast(float)(fCheckbox1));
		float[32] fZec1;
		float[32] fZec2;
		float[32] fZec3;
		float[32] fZec4;
		float fSlow3 = 0.01 * cast(float)(fHslider1);
		float fSlow4 = fSlow3 + 0.5;
		float fSlow5 = 0.5 - fSlow3;
		float fSlow6 = 0.01 * cast(float)(fHslider2);
		float fSlow7 = fSlow1 * (1.0 - fSlow6);
		float fSlow8 = pow(1e+01, 0.05 * cast(float)(fHslider3));
		float[32] fZec5;
		float[32] fZec6;
		float[32] fZec7;
		float[32] fZec8;
		float[32] fZec9;
		int vindex = 0;
		/* Main loop */
		for (vindex = 0; vindex <= (count - 32); vindex = vindex + 32) {
			FAUSTFLOAT* input0 = &input0_ptr[vindex];
			FAUSTFLOAT* input1 = &input1_ptr[vindex];
			FAUSTFLOAT* output0 = &output0_ptr[vindex];
			FAUSTFLOAT* output1 = &output1_ptr[vindex];
			int vsize = 32;
			/* Vectorizable loop 0 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec0[i] = fSlow1 * cast(float)(input0[i]);
			}
			/* Vectorizable loop 1 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec5[i] = fSlow1 * cast(float)(input1[i]);
			}
			/* Vectorizable loop 2 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec1[i] = 0.25 * (fZec0[i] + 1.0);
			}
			/* Vectorizable loop 3 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec6[i] = 0.25 * (fZec5[i] + 1.0);
			}
			/* Vectorizable loop 4 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec2[i] = ((iSlow2) ? ((iSlow2) ? fmax(fmin(fZec0[i], 1.0), -1.0) : fZec0[i]) : 2.0 * fabs(2.0 * (fZec1[i] - floor(fZec1[i] + 0.5))) + -1.0);
			}
			/* Vectorizable loop 5 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec7[i] = ((iSlow2) ? ((iSlow2) ? fmax(fmin(fZec5[i], 1.0), -1.0) : fZec5[i]) : 2.0 * fabs(2.0 * (fZec6[i] - floor(fZec6[i] + 0.5))) + -1.0);
			}
			/* Vectorizable loop 6 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec3[i] = Inflator_faustpower2_f(fZec2[i]);
			}
			/* Vectorizable loop 7 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec4[i] = cast(float)(((fZec2[i] <= 0.0) ? -1 : 1));
			}
			/* Vectorizable loop 8 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec8[i] = Inflator_faustpower2_f(fZec7[i]);
			}
			/* Vectorizable loop 9 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec9[i] = cast(float)(((fZec7[i] <= 0.0) ? -1 : 1));
			}
			/* Vectorizable loop 10 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				output0[i] = cast(FAUSTFLOAT)(fSlow8 * ((iSlow0) ? fSlow7 * cast(float)(input0[i]) + fSlow6 * (fSlow5 * (1.5 * fZec2[i] - (0.375 * Inflator_faustpower3_f(fZec2[i]) + 0.0625 * fZec4[i] * (fZec3[i] + Inflator_faustpower4_f(fZec2[i])))) + fSlow4 * (2.0 * fZec2[i] - fZec4[i] * fZec3[i])) : fZec0[i]));
			}
			/* Vectorizable loop 11 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				output1[i] = cast(FAUSTFLOAT)(fSlow8 * ((iSlow0) ? fSlow7 * cast(float)(input1[i]) + fSlow6 * (fSlow5 * (1.5 * fZec7[i] - (0.375 * Inflator_faustpower3_f(fZec7[i]) + 0.0625 * fZec9[i] * (fZec8[i] + Inflator_faustpower4_f(fZec7[i])))) + fSlow4 * (2.0 * fZec7[i] - fZec9[i] * fZec8[i])) : fZec5[i]));
			}
		}
		/* Remaining frames */
		if (vindex < count) {
			FAUSTFLOAT* input0 = &input0_ptr[vindex];
			FAUSTFLOAT* input1 = &input1_ptr[vindex];
			FAUSTFLOAT* output0 = &output0_ptr[vindex];
			FAUSTFLOAT* output1 = &output1_ptr[vindex];
			int vsize = count - vindex;
			/* Vectorizable loop 0 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec0[i] = fSlow1 * cast(float)(input0[i]);
			}
			/* Vectorizable loop 1 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec5[i] = fSlow1 * cast(float)(input1[i]);
			}
			/* Vectorizable loop 2 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec1[i] = 0.25 * (fZec0[i] + 1.0);
			}
			/* Vectorizable loop 3 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec6[i] = 0.25 * (fZec5[i] + 1.0);
			}
			/* Vectorizable loop 4 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec2[i] = ((iSlow2) ? ((iSlow2) ? fmax(fmin(fZec0[i], 1.0), -1.0) : fZec0[i]) : 2.0 * fabs(2.0 * (fZec1[i] - floor(fZec1[i] + 0.5))) + -1.0);
			}
			/* Vectorizable loop 5 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec7[i] = ((iSlow2) ? ((iSlow2) ? fmax(fmin(fZec5[i], 1.0), -1.0) : fZec5[i]) : 2.0 * fabs(2.0 * (fZec6[i] - floor(fZec6[i] + 0.5))) + -1.0);
			}
			/* Vectorizable loop 6 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec3[i] = Inflator_faustpower2_f(fZec2[i]);
			}
			/* Vectorizable loop 7 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec4[i] = cast(float)(((fZec2[i] <= 0.0) ? -1 : 1));
			}
			/* Vectorizable loop 8 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec8[i] = Inflator_faustpower2_f(fZec7[i]);
			}
			/* Vectorizable loop 9 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				fZec9[i] = cast(float)(((fZec7[i] <= 0.0) ? -1 : 1));
			}
			/* Vectorizable loop 10 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				output0[i] = cast(FAUSTFLOAT)(fSlow8 * ((iSlow0) ? fSlow7 * cast(float)(input0[i]) + fSlow6 * (fSlow5 * (1.5 * fZec2[i] - (0.375 * Inflator_faustpower3_f(fZec2[i]) + 0.0625 * fZec4[i] * (fZec3[i] + Inflator_faustpower4_f(fZec2[i])))) + fSlow4 * (2.0 * fZec2[i] - fZec4[i] * fZec3[i])) : fZec0[i]));
			}
			/* Vectorizable loop 11 */
			/* Compute code */
			for (int i = 0; i < vsize; i = i + 1) {
				output1[i] = cast(FAUSTFLOAT)(fSlow8 * ((iSlow0) ? fSlow7 * cast(float)(input1[i]) + fSlow6 * (fSlow5 * (1.5 * fZec7[i] - (0.375 * Inflator_faustpower3_f(fZec7[i]) + 0.0625 * fZec9[i] * (fZec8[i] + Inflator_faustpower4_f(fZec7[i])))) + fSlow4 * (2.0 * fZec7[i] - fZec9[i] * fZec8[i])) : fZec5[i]));
			}
		}
	}

}

/***************************END USER SECTION ***************************/

/*******************BEGIN ARCHITECTURE SECTION (part 2/2)***************/

/********************END ARCHITECTURE SECTION (part 2/2)****************/


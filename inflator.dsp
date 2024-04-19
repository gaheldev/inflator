import("stdfaust.lib");

// [x] input gain
// [x] output gain
// [x] effect
// [x] curve
//     - [x] +50
//     - [x] -50
//     - [x] crossfade
// [x] clip
// [x] in
// [ ] band split (3 bands)


N = 2; //number of channels


// TODO: wave 1 and 2 don't yield same volume when maxing everything and clipping
input_gain = ba.db2linear(hslider("input", 0, -6, 12, 0.1));
output_gain = ba.db2linear(hslider("output", 0, -12, 0, 0.1));

effect_in = checkbox("effect in"); // allow or bypass effect chain
clipping =  checkbox("clip");

effect = hslider("effect", 0, 0, 100, 0.1) / 100; //normalized between 0 and 1
curve = hslider("curve", 0,-50,50,0.1) / 100; // normalized between -1 and 1



clipper(x) = ba.if(clipping, max(min(x,1), -1), x); // only clips when bool is 1



warp(x) = fmod(x+1,4) <: _ * (_<=2), (4-_) * (_>2) :> _ - 1; // make x cycle back and forth [-1,1]

sign(x) = 1, -1 : select2(x<=0);

wave_1(x) = 2*x - sign(x) * x^2; // defined between -1 and 1
wave_2(x) = 1.5*x - sign(x)*0.0625*x^2 - 0.375*x^3 - sign(x)*0.0625*x^4; // defined between -1 and 1

shaper_1(x) = wave_1(warp(x));
shaper_2(x) = wave_2(warp(x));

waveshaper(x) = shaper_1(x) * max(curve, 0) + shaper_2(x) * max(-curve,0) + x*(1-abs(curve)); // 0 is linear, 1 is full shaper_1, -1 is full shaper_2
effect_chain(x) = effect * waveshaper(clipper(x)) + (1-effect)*x;
apply_effect(x) =  ba.if(effect_in, effect_chain(x), x);

inflator = _ * input_gain : apply_effect : _ * output_gain;
process = par(i,N, inflator);


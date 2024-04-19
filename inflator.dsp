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


input_gain = ba.db2linear(hslider("input", 0, -6, 12, 0.1));
output_gain = ba.db2linear(hslider("output", 0, -12, 0, 0.1));

bypass = checkbox("bypass"); // opposite of in button
clipping =  checkbox("clip");

effect = hslider("effect", 0, 0, 100, 0.1) / 100; //normalized between 0 and 1
curve = hslider("curve", 0,-50,50,0.1) / 100; // normalized between -1 and 1



clipper(x) = ba.if(clipping, max(min(x,1), -1), x); // only clips when bool is 1



shaper_1(x) = 2*x - x^2;
shaper_2(x) = 1.5*x - 0.0625*x^2 - 0.325*x^3 - 0.0625*x^4;

// TODO: check curve when >1 or <-1 => use sine? 
waveshaper(x) = shaper_1(x) * max(curve, 0) + shaper_2(x) * max(-curve,0) + x*(1-abs(curve)); // 0 is linear, 1 is full shaper_1, -1 is full shaper_2
effect_chain(x) = effect * waveshaper(clipper(x)) + (1-effect)*x;


inflator = _ * input_gain  <: effect_chain*(1-bypass), _*bypass :> _ * output_gain;
process = par(i,N, inflator);


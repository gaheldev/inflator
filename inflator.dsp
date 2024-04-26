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


N = 2;  //number of channels


input_gain = ba.db2linear(hslider("input", 0, -6, 12, 0.1));
output_gain = ba.db2linear(hslider("output", 0, -12, 0, 0.1));

effect_in = checkbox("effect in");  // allow or bypass effect chain
clipping =  checkbox("clip");

effect = hslider("effect", 0, 0, 100, 0.1) / 100;       //normalized between 0 and 1
curve = hslider("curve", 0,-50,50,0.1) / 100 + 0.5;     // normalized between 0 and 1


// tools
mix(a,b,mix_value) = a * (1-mix_value) + b * mix_value;     // 0 returns a and 1 returns b, mix_value is a float in [0,1]

sign(x) = 1, -1 : select2(x<=0);


// clipper
clipper(x) = ba.if(clipping, max(min(x,1), -1), x);     // only clips when bool is 1


// simulates aliasing or clipping for values out of [-1,1]
warp(x) = ba.if(clipping, clipper(x), triangle_warp(x,4));
triangle_warp(x,period) = 2 * abs(2*((x+1)/period - floor((x+1)/period+0.5))) - 1; 


// wave shapers
wave_1(x) = 2*x - sign(x) * x^2;                                            // defined between -1 and 1
wave_2(x) = 1.5*x - sign(x)*0.0625*x^2 - 0.375*x^3 - sign(x)*0.0625*x^4;    // defined between -1 and 1

shaper_1(x) = wave_1(warp(x));
shaper_2(x) = wave_2(warp(x));

waveshaper(x) = mix(shaper_2(x), shaper_1(x), curve);   // +50 is full shaper_1, -50 is full shaper_2


// put it all together
effect_chain(x) = mix(x, waveshaper(x), effect);
apply_effect(x) =  ba.if(effect_in, effect_chain(x), x);

inflator = _ * input_gain : apply_effect : _ * output_gain;
process = par(i,N, inflator);


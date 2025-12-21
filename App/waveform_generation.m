% =========================================================================
% FMCW Waveform Generation Script
% Phase 1, Task 1.2: Waveform Generation
% =========================================================================

%% Step 0 Variable Retrivement
radar_config;

%% Step 1 Sampling Specification
fs = 2 * BW; % Sampling frequency according to Nyquist rate

%% Step 2 Time Vector
t = 0:(1 / fs):T_chirp; % Duration of one chirp

%% Step 3 Signal Synthesis
Tx = exp(1i * pi * S * t.^2);

%{
A baseband signal has been used instead of a carrier. This is because the
high carrier frequency (77GHz) is impractical to simulate using a basic
student device. The use of a carrier has the following 3 benefits:

1. Propagation Efficiency
A higher frequency signal requires a shorter antenna to transmit, the
baseband signal requires an antenna of a few metres while the carrier only
requires an antenna in milimetres.

2. Velocity Sensitivity
The doppler shift introduced by the velocity of the object alters the phase
by a percentage of the frequency. Hence, using a higher frequency in that
of a carrier makes the phase shift much more noticeable.

3. Spectrum Isolation
By using a high carrier frequency, it avoids low frequency interference
generated from a variety of everyday devices.

So by losing the carrier, the following mitigation needs to be performed:

1. As this stage only includes simulation, the antenna length requirement
is not an issue. In potential project extensions including hardware, a VCO
will be implemented to generate a 77GHz carrier signal.

2. In the simulation, the doppler shift will be implemented as if the
transmitted signal is at the carrier frequency.

3. Interference from other devices are not part of the simulation, so this
point brings no issues.

An exponential implementation was used to align with real world
implementations. Using a single sine or cosine wave makes it impossible to
distinguish the direction of velocity, as the sign of phase shift will not
be determinable cos(x) = cos(-x). As a complex exponential contains both
sine and cosine components, it allows the sign of phase shift to be
determined.
%}